#[test_only]
module dexlyn_tokenomics::vesting_test {

    use std::signer::address_of;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account;
    use supra_framework::account::create_signer_for_test;
    use supra_framework::genesis;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::vesting;
    use dexlyn_tokenomics::vesting::{ERROR_CONTRACT_NOT_FOUND,
        ERROR_CONTRACT_STILL_ACTIVE,
        ERROR_INVALID_GRANT,
        ERROR_INVALID_PERIOD_DURATION,
        ERROR_INVALID_SHAREHOLDER, ERROR_NO_DUPLICATE_SHAREHOLDER, ERROR_NOT_ADMIN, ERROR_SHAREHOLDER_NOT_EXISTS,
        ERROR_TERMINATED_CONTRACT,
    };

    // A amount to vested
    const GRANT_AMOUNT: u64 = 10000;
    const DXLYN_DECIMAL: u64 = 100000000;
    const DEPLOYER: address = @dexlyn_tokenomics;
    const FRAMEWORK: address = @0x1;

    /// 1 Year in sec = 31536000
    const VESTING_SCHEDULE_CLIFF: u64 = 31536000;
    /// 1 Month in sec = 2592000
    const MONTH_IN_SECONDS: u64 = 30 * 24 * 60 * 60;
    /// 1 day 86400
    const ONE_DAY: u64 = 24 * 60 * 60;
    /// 1 Week 604800
    const ONE_WEEK: u64 = 7 * 24 * 60 * 60;

    /// The vested amount is invalid
    const ERROR_INVALID_VEST_AMOUNT: u64 = 115;
    const ERROR_INVALID_WITHDRAW_AMOUNT: u64 = 116;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

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
            &mut accounts,
            |addr| {
                if (!account::exists_at(*addr)) {
                    account::create_account_for_test(*addr);
                }
            }
        )
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_initialize(deployer: &signer) {
        setup(deployer);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_re_initialize(deployer: &signer) {
        setup(deployer);
        vesting::test_init(deployer);
        vesting::test_init(deployer);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // #[test(deployer = @dexlyn_tokenomics, user_1 = @0x234)]
    fun test_vesting_with_zero_cliff_period(
        deployer: &signer, user_1: &signer
    ) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = address_of(user_1);
        let amount = get_quants(1000);

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[amount],
                vector[1], // 100% immediate vesting
                10,
                current_time, // No cliff period
                MONTH_IN_SECONDS,
                deployer_addr
            );
        vesting::vest(contract_addr);

        assert!(dxlyn_coin::balance_of(user1_addr) == amount, 0); // With rounding
    }

    #[test(deployer = @dexlyn_tokenomics, user_1 = @0x234)]
    fun test_partial_vesting_before_full_completion(
        deployer: &signer, user_1: &signer
    ) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = address_of(user_1);
        let amount = 1000;

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[amount],
                vector[10],
                100,
                current_time,
                ONE_DAY,
                deployer_addr
            );

        // After 10 days
        timestamp::fast_forward_seconds(ONE_DAY * 9);
        vesting::vest_individual(contract_addr, user1_addr);

        let expected = 900;

        let user_balance = dxlyn_coin::balance_of(user1_addr);
        assert!(user_balance == expected - 1, user_balance);

        timestamp::fast_forward_seconds(ONE_DAY);
        vesting::vest_individual(contract_addr, user1_addr);

        let user_balance = dxlyn_coin::balance_of(user1_addr);
        assert!(user_balance == amount - 2, user_balance);

        timestamp::fast_forward_seconds(ONE_DAY);
        vesting::vest_individual(contract_addr, user1_addr);

        let user_balance = dxlyn_coin::balance_of(user1_addr);
        assert!(user_balance == amount, user_balance);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_multiple_vesting_contracts_simultaneously(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1 = @0x111;
        let user2 = @0x222;

        create_test_account(vector[deployer_addr, user1, user2]);

        let current_time = timestamp::now_seconds();
        let amount = get_quants(1000);

        // Create two separate contracts
        let contract1 =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1],
                vector[amount],
                vector[50],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        let contract2 =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user2],
                vector[amount],
                vector[100],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        assert!(dxlyn_coin::balance_of(contract1) == amount, 0);
        assert!(dxlyn_coin::balance_of(contract2) == amount, 0);
    }

    #[test(deployer = @dexlyn_tokenomics, user_1 = @0x234)]
    fun test_vesting_record_updates_correctly(
        deployer: &signer, user_1: &signer
    ) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = address_of(user_1);
        let amount = get_quants(1000);

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[amount],
                vector[50],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        let (period_duration, _, _) = vesting::get_contract_schedule(contract_addr);
        timestamp::fast_forward_seconds(period_duration);

        vesting::vest_individual(contract_addr, user1_addr);

        let (init_amount, left_amount, last_period) =
            vesting::get_shareholder_vesting_record(contract_addr, user1_addr);

        assert!(init_amount == amount, init_amount);
        assert!(left_amount < amount, left_amount);
        assert!(last_period == 1, last_period);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_large_number_of_shareholders(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let shareholders = vector[@0x111, @0x222, @0x333, @0x444, @0x555];
        let individual_share = get_quants(200);
        let shares = vector[
            individual_share,
            individual_share,
            individual_share,
            individual_share,
            individual_share
        ];
        let total_amount = individual_share * 5;

        create_test_account(shareholders);


        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                shareholders,
                shares,
                vector[100],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        assert!(dxlyn_coin::balance_of(contract_addr) == total_amount, 0);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_SHAREHOLDER)]
    fun test_empty_shareholders_vector(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        create_test_account(vector[deployer_addr]);

        let current_time = timestamp::now_seconds();
        vesting::schedule_vesting_contract(
            deployer,
            vector[], // Empty shareholders
            vector[],
            vector[100],
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_SHAREHOLDER)]
    fun test_mismatched_shareholders_and_shares_length(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        create_test_account(vector[deployer_addr, @0x111]);

        let current_time = timestamp::now_seconds();
        vesting::schedule_vesting_contract(
            deployer,
            vector[@0x111, @0x222], // 2 shareholders
            vector[get_quants(1000)], // 1 share amount - mismatch!
            vector[100],
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_GRANT)]
    fun test_zero_total_amount(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        create_test_account(vector[deployer_addr, @0x111]);

        let current_time = timestamp::now_seconds();
        vesting::schedule_vesting_contract(
            deployer,
            vector[@0x111],
            vector[0], // Zero amount
            vector[100],
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_TERMINATED_CONTRACT)]
    fun test_percentages_not_100_but_overcalled(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user_address = @0x111;
        create_test_account(vector[deployer_addr, user_address]);


        let current_time = timestamp::now_seconds();
        let contract_addr = vesting::schedule_vesting_contract(
            deployer,
            vector[user_address],
            vector[get_quants(1000)],
            vector[50, 20], // Only sums to 80%, not 100%
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
        for (i in 0..10) {
            timestamp::fast_forward_seconds(2592000);
            vesting::vest(contract_addr);
        };
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_percentages_not_100_success(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user_address = @0x111;
        create_test_account(vector[deployer_addr, user_address]);


        let current_time = timestamp::now_seconds();
        let contract_addr = vesting::schedule_vesting_contract(
            deployer,
            vector[user_address],
            vector[get_quants(1000)],
            vector[50, 20, 10], // Only sums to 80%, not 100%
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
        for (i in 0..6) {
            timestamp::fast_forward_seconds(2592000);
            vesting::vest(contract_addr);
        };
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_PERIOD_DURATION)]
    fun test_zero_period_duration(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        create_test_account(vector[deployer_addr, @0x111]);

        let current_time = timestamp::now_seconds();
        vesting::schedule_vesting_contract(
            deployer,
            vector[@0x111],
            vector[get_quants(1000)],
            vector[100],
            100,
            current_time,
            0, // Zero period duration
            deployer_addr
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 65540, location = supra_framework::fungible_asset)]
    fun test_insufficient_balance_for_vesting(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        create_test_account(vector[deployer_addr, @0x111]);

        let current_time = timestamp::now_seconds();
        vesting::schedule_vesting_contract(
            deployer,
            vector[@0x111],
            vector[get_quants(GRANT_AMOUNT) + 100],
            vector[100],
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_vesting_before_cliff_period(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let amount = get_quants(500);
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[amount],
                vector[50, 50],
                100,
                current_time + VESTING_SCHEDULE_CLIFF, // Future cliff
                MONTH_IN_SECONDS,
                deployer_addr
            );

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // Before cliff  no vesting
        vesting::vest(contract_addr);
        let pre_vest_balance = primary_fungible_store::balance(user1_addr, metadata);
        // Must be 0 because cliff not reached
        assert!(pre_vest_balance == 0, ERROR_INVALID_VEST_AMOUNT);

        // After cliff + 1 month  first vest
        timestamp::fast_forward_seconds(VESTING_SCHEDULE_CLIFF + MONTH_IN_SECONDS);
        vesting::vest(contract_addr);
        let first_vest_balance = primary_fungible_store::balance(user1_addr, metadata);
        // Must release half of the amount
        assert!(first_vest_balance == amount / 2, ERROR_INVALID_VEST_AMOUNT);

        // Re-vest immediately without advancing time no extra release
        vesting::vest(contract_addr);
        let next_vest_balance = primary_fungible_store::balance(user1_addr, metadata);
        // Must stay same as first_vest_balance
        assert!(first_vest_balance == next_vest_balance, ERROR_INVALID_VEST_AMOUNT);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_CONTRACT_NOT_FOUND)]
    fun test_vest_non_existent_contract(deployer: &signer) {
        setup(deployer);

        let fake_contract_addr = @0x999999;
        vesting::vest(fake_contract_addr);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_SHAREHOLDER_NOT_EXISTS)]
    fun test_vest_individual_non_existent_beneficiary(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;
        let fake_user = @0x999;

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[get_quants(1000)],
                vector[100],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        // Try to vest for non-existent beneficiary
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::vest_individual(contract_addr, fake_user);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_NO_DUPLICATE_SHAREHOLDER)]
    fun test_duplicate_shareholders(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let amount = get_quants(1000);
        vesting::schedule_vesting_contract(
            deployer,
            vector[user1_addr, user1_addr], // Duplicate shareholder
            vector[amount, amount],
            vector[50],
            100,
            current_time,
            MONTH_IN_SECONDS,
            deployer_addr
        );
    }

    fun test_already_fully_vested_user(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr],
                vector[get_quants(1000)],
                vector[100],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);

        // Vest once
        vesting::vest_individual(contract_addr, user1_addr);

        // Try to vest again when already fully vested
        vesting::vest_individual(contract_addr, user1_addr);
    }

    #[
    test(
        deployer = @dexlyn_tokenomics,
        user_1 = @0x234,
        user_2 = @0x345,
        withdrawal = @111
    )
    ]
    fun test_create_vesting_schedule(
        deployer: &signer,
        user_1: &signer,
        user_2: &signer,
        withdrawal: &signer
    ) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let withdrawal_addr = address_of(withdrawal);
        let user1_addr = address_of(user_1);
        let user2_addr = address_of(user_2);

        let shareholders = vector[user1_addr, user2_addr];
        let grant = get_quants(GRANT_AMOUNT);
        let user1_share = grant * 20 / 100;
        let user2_share = grant * 80 / 100;
        let shares = vector[user1_share, user2_share];

        create_test_account(
            vector[deployer_addr, withdrawal_addr, user1_addr, user2_addr]
        );


        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                shareholders,
                shares,
                vector[10],
                100,
                current_time + VESTING_SCHEDULE_CLIFF,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        assert!(dxlyn_coin::balance_of(contract_addr) == grant, 0);
        assert!(dxlyn_coin::balance_of(user1_addr) == 0, 0);
        assert!(dxlyn_coin::balance_of(user2_addr) == 0, 0);

        let (period_duration, start_timestamp_secs, _) =
            vesting::get_contract_schedule(contract_addr);

        timestamp::fast_forward_seconds(start_timestamp_secs + period_duration);
        vesting::vest(contract_addr);

        // Example calculation:
        // 10_000 * 10^8 = 1_0000_000000000
        // 80% of that = 800_000000000
        // Due to precision loss, the computed result = 79_999999888
        let vested_amount_2 = 79999999888;
        let user2_balance = dxlyn_coin::balance_of(user2_addr);

        assert!(user2_balance == vested_amount_2, 1);

        // After 9 completed periods + 1 more, vesting is complete.
        // At the 11th call, the user will receive all remaining (lost) tokens.
        timestamp::fast_forward_seconds(period_duration * 10);
        vesting::vest(contract_addr);
        let user2_balance = dxlyn_coin::balance_of(user2_addr);
        assert!(user2_balance == user2_share, user2_balance);
    }

    #[test(deployer = @dexlyn_tokenomics, user_1 = @0x234)]
    public fun test_monthly_vesting_10_percent_each_month_until_complete(
        deployer: &signer, user_1: &signer
    ) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = address_of(user_1);

        let total_share = 1000;
        let shareholders = vector[user1_addr];
        let shares = vector[total_share];

        create_test_account(vector[deployer_addr, user1_addr]);

        let current_time = timestamp::now_seconds();
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                shareholders,
                shares,
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        // Final balance checks
        let vested_amount_1 = 0;
        assert!(dxlyn_coin::balance_of(contract_addr) == total_share, 0);
        assert!(dxlyn_coin::balance_of(user1_addr) == 0, 0);

        let (period_duration, _, _) = vesting::get_contract_schedule(contract_addr);

        // Loop throw 10 moths
        timestamp::fast_forward_seconds(timestamp::now_seconds() + period_duration);
        for (i in 1..11) {
            vested_amount_1 = vested_amount_1 + 99; // 10% of 100 is 99 with rounding

            vesting::vest_individual(contract_addr, user1_addr);
            let user1_balance = dxlyn_coin::balance_of(user1_addr);

            let (init_amount, left_amount, last_vested_period) =
                vesting::get_shareholder_vesting_record(contract_addr, user1_addr);

            assert!(init_amount == total_share, vested_amount_1);
            assert!(
                left_amount == total_share - vested_amount_1,
                vested_amount_1
            );
            assert!(last_vested_period == i, vested_amount_1);

            assert!(user1_balance == vested_amount_1, user1_balance);
            timestamp::fast_forward_seconds(period_duration);
        };
        let user1_balance = dxlyn_coin::balance_of(user1_addr);
        let contract_bal = dxlyn_coin::balance_of(contract_addr);

        assert!(
            user1_balance + contract_bal == total_share,
            contract_bal
        );
    }

    #[test(deployer= @dexlyn_tokenomics)]
    fun test_vest_multiple_shares(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        let current_time = timestamp::now_seconds();
        let share1 = get_quants(1000);
        let share2 = get_quants(500);

        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr, user2_addr],
                vector[share1, share2],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        for (i in 0..11) {
            timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
            vesting::vest(contract_addr);
        };

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        assert!(primary_fungible_store::balance(user1_addr, metadata) == share1, ERROR_INVALID_VEST_AMOUNT);
        assert!(primary_fungible_store::balance(user2_addr, metadata) == share2, ERROR_INVALID_VEST_AMOUNT);
    }

    #[test(deployer= @dexlyn_tokenomics)]
    fun test_vesting_contribute(deployer: &signer) {
        setup(deployer);

        let dev_address = @0x122;
        let dev = &create_signer_for_test(dev_address);
        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let pre_balance = get_quants(10000);
        let contribute_amount = get_quants(1000);

        dxlyn_coin::mint(deployer, dev_address, contribute_amount);
        let dev_balance = primary_fungible_store::balance(dev_address, metadata);

        vesting::contribute(dev, contribute_amount);

        let vesting_store_addr = vesting::get_vesting_store_address();
        assert!(primary_fungible_store::balance(vesting_store_addr, metadata) == contribute_amount + pre_balance, 1);
        let dev_balance_after = primary_fungible_store::balance(dev_address, metadata);
        assert!(dev_balance_after == dev_balance - contribute_amount, 2);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_TERMINATED_CONTRACT)]
    fun test_terminate_vesting_when_balance_is_zero(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        for (i in 0..11) {
            timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
            vesting::vest(contract_addr);
        };

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // All vested tokens have been distributed, including recovered losses
        assert!(primary_fungible_store::balance(user1_addr, metadata) == amount, ERROR_INVALID_VEST_AMOUNT);
        assert!(primary_fungible_store::balance(user2_addr, metadata) == amount, ERROR_INVALID_VEST_AMOUNT);

        // Contract balance should now be zero
        assert!(primary_fungible_store::balance(contract_addr, metadata) == 0, ERROR_INVALID_VEST_AMOUNT);

        // With zero balance, the contract should be terminated
        vesting::vest(contract_addr);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_TERMINATED_CONTRACT)]
    fun test_cannot_terminate_already_terminated_vesting(deployer: &signer) {
        setup(deployer);

        let deployer_addr = address_of(deployer);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                deployer,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        for (i in 0..11) {
            timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
            vesting::vest(contract_addr);
        };

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // All vested tokens have been distributed, including recovered losses
        assert!(primary_fungible_store::balance(user1_addr, metadata) == amount, ERROR_INVALID_VEST_AMOUNT);
        assert!(primary_fungible_store::balance(user2_addr, metadata) == amount, ERROR_INVALID_VEST_AMOUNT);

        // Contract balance should now be zero
        assert!(primary_fungible_store::balance(contract_addr, metadata) == 0, ERROR_INVALID_VEST_AMOUNT);

        // With zero balance, the contract should already be terminated
        vesting::vest(contract_addr);

        // Attempting to terminate again should fail (already terminated)
        vesting::terminate_vesting_contract(deployer, contract_addr);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_NOT_ADMIN)]
    fun test_only_admin_can_termiante_contract(dev: &signer) {
        setup(dev);

        let deployer_addr = address_of(dev);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        // Schedule a vesting contract with 2 shareholders
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                1,
                deployer_addr
            );

        // --- Non Admin terminates after vesting period ---
        timestamp::fast_forward_seconds(2);
        let non_admin = &create_signer_for_test(@0x444);
        vesting::terminate_vesting_contract(non_admin, contract_addr);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_admin_terminate_executes_pending_vesting_first(dev: &signer) {
        setup(dev);

        let deployer_addr = address_of(dev);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        // Schedule a vesting contract with 2 shareholders
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        // --- First vesting period ---
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::vest(contract_addr);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let loose = 70; // precision loss observed in calculation

        // Verify each user received their first vest amount (minus precision loss)
        let user1_bal = primary_fungible_store::balance(user1_addr, metadata);
        let user2_bal = primary_fungible_store::balance(user2_addr, metadata);

        let expected = ((amount * 10) / 100) - loose;
        assert!(user1_bal == expected, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal == expected, ERROR_INVALID_VEST_AMOUNT);

        // --- Admin terminates AFTER another vesting period has passed ---
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::terminate_vesting_contract(dev, contract_addr);

        // Contract must now be terminated
        let (_, _, _, _, state) = vesting::get_vesting_schedule(contract_addr);
        assert!(state == 2, 1);

        // Termination must vest the pending tokens
        let user1_bal_after = primary_fungible_store::balance(user1_addr, metadata);
        let user2_bal_after = primary_fungible_store::balance(user2_addr, metadata);

        assert!(user1_bal_after == user1_bal + expected, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal_after == user2_bal + expected, ERROR_INVALID_VEST_AMOUNT);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_terminate_vesting_before_next_period(dev: &signer) {
        setup(dev);

        let deployer_addr = address_of(dev);
        let user1_addr = @0x111;
        let user2_addr = @0x222;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        // Schedule a vesting contract with 2 shareholders
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                deployer_addr
            );

        // --- First vesting period ---
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::vest(contract_addr);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let loose = 70; // precision loss observed in calculation

        // Verify each user received their first vest amount (minus precision loss)
        let user1_bal = primary_fungible_store::balance(user1_addr, metadata);
        let user2_bal = primary_fungible_store::balance(user2_addr, metadata);

        let expected = ((amount * 10) / 100) - loose;
        assert!(user1_bal == expected, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal == expected, ERROR_INVALID_VEST_AMOUNT);

        // --- Admin terminates BEFORE the next vesting period completes ---
        vesting::terminate_vesting_contract(dev, contract_addr);

        // Contract must now be terminated
        let (_, _, _, _, state) = vesting::get_vesting_schedule(contract_addr);
        assert!(state == 2, 1);

        // No additional vesting should occur at termination
        let user1_bal_after = primary_fungible_store::balance(user1_addr, metadata);
        let user2_bal_after = primary_fungible_store::balance(user2_addr, metadata);

        assert!(user1_bal_after == user1_bal, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal_after == user2_bal, ERROR_INVALID_VEST_AMOUNT);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_admin_remove_shareholder(dev: &signer) {
        setup(dev);

        let deployer_addr = address_of(dev);
        let user1_addr = @0x111;
        let user2_addr = @0x222;
        let withdrawal_addr = @0x333;

        create_test_account(vector[deployer_addr, user1_addr, user2_addr]);

        // --- Schedule a vesting contract with 2 shareholders ---
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr, user2_addr],
                vector[amount, amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                withdrawal_addr
            );

        // --- First vesting period completes ---
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::vest(contract_addr);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let loose = 70; // precision loss observed in calculation

        // --- Verify each user received their first vest amount (minus precision loss) ---
        let user1_bal = primary_fungible_store::balance(user1_addr, metadata);
        let user2_bal = primary_fungible_store::balance(user2_addr, metadata);

        let expected = ((amount * 10) / 100) - loose;
        assert!(user1_bal == expected, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal == expected, ERROR_INVALID_VEST_AMOUNT);

        // --- Admin removes one shareholder (user1) from the vesting contract ---
        // Get the remaining vesting amount for the shareholder before removal
        let (_, remaining_vested_amount, _) = vesting::get_shareholder_vesting_record(contract_addr, user1_addr);

        // Record withdrawal account balance before shareholder removal
        let balance_before_withdrawal = primary_fungible_store::balance(withdrawal_addr, metadata);

        // Remove the shareholder from the vesting contract
        vesting::remove_shareholder(dev, contract_addr, user1_addr);

        // Record withdrawal account balance after shareholder removal
        let balance_after_withdrawal = primary_fungible_store::balance(withdrawal_addr, metadata);

        // Ensure that the withdrawn amount equals the shareholder leftover vesting amount
        assert!(
            balance_after_withdrawal == balance_before_withdrawal + remaining_vested_amount,
            ERROR_INVALID_WITHDRAW_AMOUNT
        );

        // --- Verify user1 no longer exists in the shareholders list ---
        let shareholders = vesting::view_shareholders(contract_addr);
        let found = vector::contains(&shareholders, &user1_addr);
        assert!(!found, 2);

        // --- Move forward to the next vesting period ---
        timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
        vesting::vest(contract_addr);

        // --- Verify balances after removal ---
        // user1 should NOT receive any more tokens after being removed
        let user1_bal_after = primary_fungible_store::balance(user1_addr, metadata);
        // user2 should continue receiving tokens normally
        let user2_bal_after = primary_fungible_store::balance(user2_addr, metadata);

        assert!(user1_bal == user1_bal_after, ERROR_INVALID_VEST_AMOUNT);
        assert!(user2_bal_after == user2_bal + expected, ERROR_INVALID_VEST_AMOUNT);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_SHAREHOLDER_NOT_EXISTS)]
    fun test_remove_non_existent_shareholder(dev: &signer) {
        setup(dev);

        // --- Step 1: Deploy a vesting contract with a single shareholder (user1) ---
        let user1_addr = @0x111;
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr],
                vector[amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                address_of(dev)
            );

        // --- Step 2: Try removing a shareholder that was never added ---
        let fake_user = @0x1132;

        // Expected behavior:
        // This must fail, since fake_user does not exist in the contract shareholders.
        // Abort with ERROR_SHAREHOLDER_NOT_EXISTS.
        vesting::remove_shareholder(dev, contract_addr, fake_user);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_NOT_ADMIN)]
    fun test_non_admin_remove_shareholder(dev: &signer) {
        setup(dev);

        // --- Step 1: Deploy a vesting contract with a single shareholder (user1) ---
        let user1_addr = @0x111;
        let current_time = timestamp::now_seconds();
        let amount = get_quants(GRANT_AMOUNT) / 2;
        let contract_addr =
            vesting::schedule_vesting_contract(
                dev,
                vector[user1_addr],
                vector[amount],
                vector[10],
                100,
                current_time,
                MONTH_IN_SECONDS,
                address_of(dev)
            );

        // --- Step 2: Attempt shareholder removal with a non-admin signer ---
        let fake_admin = &create_signer_for_test(@0x1132);

        // Expected behavior:
        // This must fail, since only the designated admin (deployer) can remove shareholders.
        // Abort with ERROR_NOT_ADMIN.
        vesting::remove_shareholder(fake_admin, contract_addr, user1_addr);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_NOT_ADMIN)]
    fun test_withdraw_funds_should_fail_when_called_by_non_admin(dev: &signer) {
        setup(dev);

        // --- Step 1: Deploy a vesting contract with a single shareholder ---
        let shareholder_addr = @0x111;
        let current_time = timestamp::now_seconds();
        let amount_per_shareholder = get_quants(GRANT_AMOUNT) / 2;

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[shareholder_addr],
            vector[amount_per_shareholder],
            vector[10],
            100,
            current_time,
            1,
            address_of(dev)
        );

        // --- Step 2: Terminate the contract as admin (valid step) ---
        timestamp::fast_forward_seconds(2);
        vesting::terminate_vesting_contract(dev, contract_addr);

        // --- Step 3: Attempt to withdraw using a non-admin signer ---
        let non_admin_signer = &create_signer_for_test(@0x1132);

        // Expected behavior:
        // Abort with ERROR_NOT_ADMIN, since only admin can withdraw funds.
        vesting::admin_withdraw(non_admin_signer, contract_addr);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_admin_should_withdraw_funds_successfully_after_termination(dev: &signer) {
        setup(dev);

        // --- Step 1: Deploy a vesting contract with a single shareholder ---
        let shareholder_addr = @0x111;
        let withdraw_recipient = @0x222; // Admin withdraw destination
        let current_time = timestamp::now_seconds();
        let amount_per_shareholder = get_quants(GRANT_AMOUNT) / 2;

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[shareholder_addr],
            vector[amount_per_shareholder],
            vector[10],
            100,
            current_time,
            1,
            withdraw_recipient                // Withdraw recipient address
        );

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        // Balances before termination
        let contract_balance_before = primary_fungible_store::balance(contract_addr, metadata);
        let shareholder_balance_before = primary_fungible_store::balance(shareholder_addr, metadata);

        // --- Step 2: Terminate the contract ---
        timestamp::fast_forward_seconds(1);
        vesting::terminate_vesting_contract(dev, contract_addr);

        // Balances after termination
        let contract_balance_after = primary_fungible_store::balance(contract_addr, metadata);
        let shareholder_balance_after = primary_fungible_store::balance(shareholder_addr, metadata);

        // Verify correct vesting to shareholder
        let expected_vest = ((amount_per_shareholder * 10) / 100) - 70; // Adjusted for precision loss
        assert!(
            shareholder_balance_after == shareholder_balance_before + expected_vest,
            ERROR_INVALID_VEST_AMOUNT
        );
        assert!(
            contract_balance_after == contract_balance_before - expected_vest,
            ERROR_INVALID_VEST_AMOUNT
        );

        // --- Step 3: Perform admin withdrawal ---
        let withdraw_balance_before = primary_fungible_store::balance(withdraw_recipient, metadata);
        vesting::admin_withdraw(dev, contract_addr);
        let withdraw_balance_after = primary_fungible_store::balance(withdraw_recipient, metadata);

        // Verify that withdraw_recipient received leftover funds
        assert!(
            withdraw_balance_after == withdraw_balance_before + contract_balance_after,
            ERROR_INVALID_WITHDRAW_AMOUNT
        );

        // Verify total consistency (withdrawn + shareholder vested == total amount)
        assert!(
            withdraw_balance_after + shareholder_balance_after == amount_per_shareholder,
            ERROR_INVALID_WITHDRAW_AMOUNT
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_CONTRACT_STILL_ACTIVE)]
    fun test_withdraw_should_fail_when_contract_is_active(dev: &signer) {
        setup(dev);

        // --- Step 1: Deploy a vesting contract with a single shareholder ---
        let shareholder_addr = @0x111;
        let current_time = timestamp::now_seconds();
        let amount_per_shareholder = get_quants(GRANT_AMOUNT) / 2;

        let contract_addr = vesting::schedule_vesting_contract(
            dev,
            vector[shareholder_addr],
            vector[amount_per_shareholder],
            vector[10],
            100,
            current_time,
            1,
            address_of(dev)  // admin is deployer
        );

        // --- Step 2: Attempt withdrawal without termination ---
        timestamp::fast_forward_seconds(2);

        // Expected behavior:
        // Abort with ERROR_CONTRACT_STILL_ACTIVE, since contract is not terminated yet.
        vesting::admin_withdraw(dev, contract_addr);
    }
}
