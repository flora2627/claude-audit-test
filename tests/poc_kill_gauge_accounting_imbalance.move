#[test_only]
module dexlyn_tokenomics::poc_kill_gauge_accounting_imbalance
{
    use std::signer::address_of;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap::scripts;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{Self, BTC, USDC, USDT};
    use test_helpers::test_multisig;
    use test_helpers::test_pool::{create_lp_owner, initialize_liquidity_pool};

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    const WEEK: u64 = 604800;
    const DXLYN_DECIMAL: u64 = 100000000;
    const MAXTIME: u64 = 126144000;

    public fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    fun setup_test(dev: &signer) {
        account::create_account_for_test(address_of(dev));
        test_internal_coins::init_coin(dev);
        test_internal_coins::init_usdt_coin(dev);
        test_internal_coins::init_usdc_coin(dev);
        voting_escrow::initialize(dev);
        fee_distributor::initialize(dev);
        voter::initialize(dev);
    }

    public fun setup_coins_and_lp_owner(): (signer, signer) {
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        initialize_liquidity_pool();

        let coin_admin = test_coins::create_admin_with_coins();
        let lp_owner = create_lp_owner();

        coin::register<USDC>(&lp_owner);
        coin::register<USDT>(&lp_owner);
        coin::register<BTC>(&lp_owner);

        (coin_admin, lp_owner)
    }

    public fun btc_usdt_pool(coin_admin: &signer, lp_owner: &signer): address {
        let coin_value = get_quants(10_000_000_000);

        scripts::register_pool<BTC, USDT, Uncorrelated>(lp_owner);

        let usdt_coins = test_coins::mint<USDT>(coin_admin, coin_value);
        let btc_coins = test_coins::mint<BTC>(coin_admin, coin_value);

        coin::deposit(address_of(lp_owner), usdt_coins);
        coin::deposit(address_of(lp_owner), btc_coins);

        scripts::add_liquidity<BTC, USDT, Uncorrelated>(
            lp_owner,
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
        );

        let pool_addr = liquidity_pool::generate_lp_object_address<BTC, USDT, Uncorrelated>();
        pool_addr
    }

    public fun usdc_usdt_pool(coin_admin: &signer, lp_owner: &signer): address {
        let coin_value = get_quants(1000000);

        scripts::register_pool<USDC, USDT, Uncorrelated>(lp_owner);

        let usdt_coins = test_coins::mint<USDT>(coin_admin, coin_value);
        let usdc_coins = test_coins::mint<USDC>(coin_admin, coin_value);

        coin::deposit(address_of(lp_owner), usdc_coins);
        coin::deposit(address_of(lp_owner), usdt_coins);

        scripts::add_liquidity<USDC, USDT, Uncorrelated>(
            lp_owner,
            get_quants(101),
            get_quants(101),
            get_quants(10100),
            get_quants(10100),
        );

        let pool_addr = liquidity_pool::generate_lp_object_address<USDC, USDT, Uncorrelated>();
        pool_addr
    }

    fun mint_and_create_lock(account: &signer, lock_time: u64, value: u64) {
        dxlyn_coin::register_and_mint(account, address_of(account), value);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + lock_time;
        voting_escrow::create_lock(account, value, unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_kill_gauge_causes_accounting_imbalance(dev: &signer) {
        // ========== STEP 1: ENVIRONMENT SETUP ==========
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Setup pools
        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_btc_usdt = btc_usdt_pool(&coin_admin, &lp_owner);
        let pool_usdc_usdt = usdc_usdt_pool(&coin_admin, &lp_owner);

        // Whitelist pools and create gauges
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_btc_usdt);
        voter::create_gauge(dev, pool_usdc_usdt);

        let gauge_btc_usdt = voter::get_gauge_for_pool(pool_btc_usdt);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(pool_usdc_usdt);

        // ========== STEP 2: SETUP VOTING POWER ==========
        // Mint and lock DXLYN to get voting power
        mint_and_create_lock(dev, MAXTIME, 1000 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[pool_btc_usdt, pool_usdc_usdt],
            vector[50, 50]
        );

        // ========== STEP 3: TRIGGER EMISSION AND GET FUNDS TO VOTER ==========
        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // Update period will trigger minter to send emission to voter
        voter::update_period();

        // Record voter balance after receiving emission
        let (_, _, _, _, _, _, voter_balance_after_emission) = voter::get_voter_state();

        // Voter should have received DXLYN
        assert!(voter_balance_after_emission > 0, 98);

        // Fast forward to make distribute valid
        timestamp::fast_forward_seconds(WEEK);

        // ========== STEP 4: RECORD STATE BEFORE KILL ==========
        // At this point:
        // - voter contract holds DXLYN from emission
        // - claimable is still 0 (not yet distributed)
        let claimable_btc_before_kill = voter::get_claimable(gauge_btc_usdt);
        let claimable_usdc_before_kill = voter::get_claimable(gauge_usdc_usdt);

        // Claimable should be 0 (not yet distributed)
        assert!(claimable_btc_before_kill == 0, 100);
        assert!(claimable_usdc_before_kill == 0, 101);

        // ========== STEP 6: EXECUTE KILL_GAUGE ==========
        // Kill the BTC-USDT gauge BEFORE distribute
        voter::kill_gauge(dev, gauge_btc_usdt);

        // ========== STEP 7: NOW DISTRIBUTE ==========
        // Set minter back to dxlyn_minter for distribute_all
        voter::set_minter(dev, dxlyn_minter);
        // Distribute will only accumulate claimable for alive gauges
        voter::distribute_all(dev);

        // ========== STEP 8: RECORD STATE AFTER DISTRIBUTE ==========
        let (_, _, _, _, _, _, voter_balance_after_distribute) = voter::get_voter_state();
        let claimable_btc_after = voter::get_claimable(gauge_btc_usdt);
        let claimable_usdc_after = voter::get_claimable(gauge_usdc_usdt);
        let total_claimable_after = claimable_btc_after + claimable_usdc_after;

        // ========== STEP 9: VERIFY VULNERABILITY ==========

        // PROOF 1: killed gauge's claimable should be zero
        assert!(claimable_btc_after == 0, 200);

        // PROOF 2: alive gauge should have accumulated claimable
        // Since both gauges had 50% weight, and one was killed,
        // only one gauge got claimable from the emission
        assert!(claimable_usdc_after > 0, 201);

        // CRITICAL PROOF 3: ACCOUNTING INVARIANT IS BROKEN
        // voter_balance should equal sum of claimable, but it doesnt
        // because the killed gauges share was never accumulated as claimable
        assert!(voter_balance_after_distribute > total_claimable_after, 202);

        // CRITICAL PROOF 4: Calculate the locked amount
        // The locked amount is approximately 50% of emission (killed gauges share)
        let locked_amount = voter_balance_after_distribute - total_claimable_after;

        // Since both gauges had 50% weight, the locked amount should be approximately
        // equal to the alive gauges claimable (both should be ~50% of emission)
        // Allow 2% tolerance for rounding and rebase differences
        let tolerance = voter_balance_after_emission / 50;  // 2% of total emission

        let diff = if (locked_amount > claimable_usdc_after) {
            locked_amount - claimable_usdc_after
        } else {
            claimable_usdc_after - locked_amount
        };
        assert!(diff < tolerance, 203);

        // PROOF 5: Both locked amount and claimable are significant (not dust)
        assert!(locked_amount > voter_balance_after_emission / 10, 204);  // At least 10% of emission
        assert!(claimable_usdc_after > voter_balance_after_emission / 10, 205);

        // ========== STEP 10: VERIFY NO RECOVERY MECHANISM ==========
        // Try to revive the gauge
        voter::revive_gauge(dev, gauge_btc_usdt);

        // Check if claimable is restored (it should NOT be)
        let claimable_btc_after_revive = voter::get_claimable(gauge_btc_usdt);

        // PROOF 6: Reviving does NOT restore the lost emission
        assert!(claimable_btc_after_revive == 0, 206);

        // PROOF 7: Accounting imbalance persists after revive
        let (_, _, _, _, _, _, voter_balance_final) = voter::get_voter_state();
        let claimable_final = voter::get_claimable(gauge_btc_usdt) + voter::get_claimable(gauge_usdc_usdt);
        assert!(voter_balance_final > claimable_final, 207);

        // PROOF 8: The locked DXLYN remains permanently in voter contract
        let permanently_locked = voter_balance_final - claimable_final;
        assert!(permanently_locked == locked_amount, 208);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_multiple_kill_gauge_accumulates_locked_funds(dev: &signer) {
        // This test demonstrates that multiple kill_gauge calls accumulate locked funds

        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Setup pools
        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_btc_usdt = btc_usdt_pool(&coin_admin, &lp_owner);
        let pool_usdc_usdt = usdc_usdt_pool(&coin_admin, &lp_owner);

        // Whitelist and create gauges
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_btc_usdt);
        voter::create_gauge(dev, pool_usdc_usdt);

        let gauge_btc_usdt = voter::get_gauge_for_pool(pool_btc_usdt);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(pool_usdc_usdt);

        // Setup voting
        mint_and_create_lock(dev, MAXTIME, 1000 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[pool_btc_usdt, pool_usdc_usdt], vector[50, 50]);

        // First emission cycle
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let emission1 = minter::get_previous_emission();
        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
        let rebase1 = minter::test_calculate_rebase(ve_supply, dxlyn_supply, (emission1 as u256));
        let emission_to_voter1 = emission1 - rebase1;

        let minter_address = address_of(dev);
        voter::set_minter(dev, minter_address);
        dxlyn_coin::register_and_mint(dev, minter_address, emission_to_voter1);
        voter::notify_reward_amount(dev, emission_to_voter1);

        timestamp::fast_forward_seconds(WEEK);

        // Kill first gauge
        let claimable_btc_round1 = voter::get_claimable(gauge_btc_usdt);
        voter::kill_gauge(dev, gauge_btc_usdt);

        let (_, _, _, _, _, _, voter_balance_after_kill1) = voter::get_voter_state();
        let total_claimable_after_kill1 = voter::get_claimable(gauge_btc_usdt) + voter::get_claimable(gauge_usdc_usdt);
        let locked_after_kill1 = voter_balance_after_kill1 - total_claimable_after_kill1;

        // Verify first lock
        assert!(locked_after_kill1 == claimable_btc_round1, 300);

        // Revive and accumulate more emissions
        voter::revive_gauge(dev, gauge_btc_usdt);
        voter::reset(dev, nft_token_address);
        voter::vote(dev, nft_token_address, vector[pool_btc_usdt, pool_usdc_usdt], vector[50, 50]);

        // Second emission cycle
        timestamp::fast_forward_seconds(WEEK);
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let emission2 = minter::get_previous_emission();
        dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
        let rebase2 = minter::test_calculate_rebase(ve_supply, dxlyn_supply, (emission2 as u256));
        let emission_to_voter2 = emission2 - rebase2;

        voter::set_minter(dev, minter_address);
        dxlyn_coin::register_and_mint(dev, minter_address, emission_to_voter2);
        voter::notify_reward_amount(dev, emission_to_voter2);

        timestamp::fast_forward_seconds(WEEK);

        // Kill both gauges
        let claimable_btc_round2 = voter::get_claimable(gauge_btc_usdt);
        let claimable_usdc_round2 = voter::get_claimable(gauge_usdc_usdt);

        voter::kill_gauge(dev, gauge_btc_usdt);
        voter::kill_gauge(dev, gauge_usdc_usdt);

        // Verify accumulated locks
        let (_, _, _, _, _, _, voter_balance_final) = voter::get_voter_state();
        let total_claimable_final = voter::get_claimable(gauge_btc_usdt) + voter::get_claimable(gauge_usdc_usdt);
        let total_locked = voter_balance_final - total_claimable_final;

        // Total locked should equal: first kill + second round kills
        let expected_locked = claimable_btc_round1 + claimable_btc_round2 + claimable_usdc_round2;
        assert!(total_locked == expected_locked, 301);

        // Verify claimable is zero for both
        assert!(voter::get_claimable(gauge_btc_usdt) == 0, 302);
        assert!(voter::get_claimable(gauge_usdc_usdt) == 0, 303);

        // But voter still holds all the DXLYN
        assert!(voter_balance_final == expected_locked, 304);
    }
}
