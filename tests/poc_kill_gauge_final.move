#[test_only]
module dexlyn_tokenomics::poc_kill_gauge_final
{
    use std::signer::address_of;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap::scripts;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{Self, BTC, USDC, USDT};
    use test_helpers::test_multisig;
    use test_helpers::test_pool::{create_lp_owner, initialize_liquidity_pool};

    use dexlyn_tokenomics::fee_distributor;
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
        account::create_account_for_test(address_of(dev));
        test_internal_coins::init_coin(dev);
        test_internal_coins::init_usdt_coin(dev);
        test_internal_coins::init_usdc_coin(dev);
        voting_escrow::initialize(dev);
        fee_distributor::initialize(dev);
        voter::initialize(dev);
    }

    fun setup_pool<X, Y>(coin_admin: &signer, lp_owner: &signer): address {
        let coin_value = get_quants(10_000_000_000);
        scripts::register_pool<X, Y, Uncorrelated>(lp_owner);
        let x_coins = test_coins::mint<X>(coin_admin, coin_value);
        let y_coins = test_coins::mint<Y>(coin_admin, coin_value);
        coin::deposit(address_of(lp_owner), x_coins);
        coin::deposit(address_of(lp_owner), y_coins);
        scripts::add_liquidity<X, Y, Uncorrelated>(
            lp_owner,
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
        );
        liquidity_pool::generate_lp_object_address<X, Y, Uncorrelated>()
    }

    /// POC: Demonstrates kill_gauge causes permanent DXLYN lockup in voter contract
    ///
    /// Vulnerability scenario:
    /// 1. Two gauges (BTC-USDT and USDC-USDT) each with 50% voting weight
    /// 2. Emission is sent to voter contract via update_period (voter balance increases)
    /// 3. Governance kills BTC-USDT gauge BEFORE distribute
    /// 4. When distribute is called, only alive gauge (USDC-USDT) accumulates claimable
    /// 5. Result: voter balance = 100%, but claimable = 50% (only alive gauge)
    /// 6. The 50% allocated to killed gauge is permanently locked in voter contract
    ///
    /// This breaks the core accounting invariant: voter_balance == sum(claimable)
    #[test(dev = @dexlyn_tokenomics)]
    fun test_poc_kill_gauge_causes_permanent_lockup(dev: &signer) {
        // ========== SETUP ==========
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Setup liquidity pools
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        initialize_liquidity_pool();
        let coin_admin = test_coins::create_admin_with_coins();
        let lp_owner = create_lp_owner();
        coin::register<BTC>(&lp_owner);
        coin::register<USDC>(&lp_owner);
        coin::register<USDT>(&lp_owner);

        let pool_btc_usdt = setup_pool<BTC, USDT>(&coin_admin, &lp_owner);
        let pool_usdc_usdt = setup_pool<USDC, USDT>(&coin_admin, &lp_owner);

        // Whitelist pools and create gauges
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_btc_usdt);
        voter::create_gauge(dev, pool_usdc_usdt);

        let gauge_btc_usdt = voter::get_gauge_for_pool(pool_btc_usdt);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(pool_usdc_usdt);

        // Create voting power and vote 50%-50%
        dxlyn_coin::register_and_mint(dev, address_of(dev), 1000 * DXLYN_DECIMAL);
        voting_escrow::create_lock(dev, 1000 * DXLYN_DECIMAL, timestamp::now_seconds() + MAXTIME);
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[pool_btc_usdt, pool_usdc_usdt], vector[50, 50]);

        // ========== STEP 1: TRIGGER EMISSION ==========
        // Fast forward one week and trigger emission via update_period
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Record voter balance after emission
        let (_, _, _, _, _, _, voter_balance_after_emission) = voter::get_voter_state();

        // VERIFICATION 1: Voter received DXLYN from emission
        assert!(voter_balance_after_emission > 0, 1);

        // VERIFICATION 2: Claimable is still 0 for both gauges (not yet distributed)
        assert!(voter::get_claimable(gauge_btc_usdt) == 0, 2);
        assert!(voter::get_claimable(gauge_usdc_usdt) == 0, 3);

        // ========== STEP 2: KILL GAUGE (BEFORE DISTRIBUTE) ==========
        timestamp::fast_forward_seconds(WEEK);

        // Governance kills BTC-USDT gauge
        voter::kill_gauge(dev, gauge_btc_usdt);

        // VERIFICATION 3: Claimable still 0 (kill_gauge just sets is_alive=false and claimable=0)
        assert!(voter::get_claimable(gauge_btc_usdt) == 0, 4);
        assert!(voter::get_claimable(gauge_usdc_usdt) == 0, 5);

        // ========== STEP 3: DISTRIBUTE (ONLY ALIVE GAUGES GET CLAIMABLE) ==========
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_all(dev);

        // Record state after distribute
        let (_, _, _, _, _, _, voter_balance_after_distribute) = voter::get_voter_state();
        let claimable_btc_after = voter::get_claimable(gauge_btc_usdt);
        let claimable_usdc_after = voter::get_claimable(gauge_usdc_usdt);
        let total_claimable = claimable_btc_after + claimable_usdc_after;

        // ========== CRITICAL VERIFICATIONS ==========

        // PROOF 1: Killed gauge has 0 claimable
        assert!(claimable_btc_after == 0, 100);

        // PROOF 2: Alive gauge has 0 claimable (because after distribute, it was transferred to gauge)
        // But voter still holds some DXLYN
        assert!(voter_balance_after_distribute > 0, 101);

        // PROOF 3: Accounting invariant BROKEN
        // If accounting was correct: voter_balance should equal sum(claimable_still_in_voter)
        // But we have DXLYN in voter with no corresponding claimable
        // The locked amount represents the killed gauge's share that was never distributed
        let locked_amount = voter_balance_after_distribute - total_claimable;
        assert!(locked_amount > 0, 102);

        // PROOF 4: The locked amount is significant (approximately the killed gauge's share)
        // Since both gauges had 50% weight, locked should be roughly 50% of emission
        assert!(locked_amount > voter_balance_after_emission / 10, 103);  // At least 10% of emission

        // ========== STEP 4: VERIFY NO RECOVERY MECHANISM ==========

        // Try to revive the gauge
        voter::revive_gauge(dev, gauge_btc_usdt);

        // PROOF 5: Reviving does NOT restore the locked funds
        let claimable_after_revive = voter::get_claimable(gauge_btc_usdt);
        assert!(claimable_after_revive == 0, 104);

        // PROOF 6: Locked funds remain permanently in voter contract
        let (_, _, _, _, _, _, voter_balance_final) = voter::get_voter_state();
        let total_claimable_final = voter::get_claimable(gauge_btc_usdt) + voter::get_claimable(gauge_usdc_usdt);
        let permanently_locked = voter_balance_final - total_claimable_final;
        assert!(permanently_locked == locked_amount, 105);

        // PROOF 7: No function exists to recover these locked funds
        // (This is proven by code inspection - there's no treasury withdrawal or recovery mechanism)
    }

    /// POC: Demonstrates accumulation of locked funds across multiple kill_gauge operations
    ///
    /// This test shows that the issue compounds over time:
    /// - Each kill_gauge operation locks additional DXLYN
    /// - Multiple gauges can be killed, each locking their pending emissions
    /// - The locked funds accumulate and can reach significant amounts
    #[test(dev = @dexlyn_tokenomics)]
    fun test_poc_multiple_kills_accumulate_locked_funds(dev: &signer) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Setup
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        initialize_liquidity_pool();
        let coin_admin = test_coins::create_admin_with_coins();
        let lp_owner = create_lp_owner();
        coin::register<BTC>(&lp_owner);
        coin::register<USDC>(&lp_owner);
        coin::register<USDT>(&lp_owner);

        let pool_btc_usdt = setup_pool<BTC, USDT>(&coin_admin, &lp_owner);
        let pool_usdc_usdt = setup_pool<USDC, USDT>(&coin_admin, &lp_owner);

        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_btc_usdt);
        voter::create_gauge(dev, pool_usdc_usdt);

        let gauge_btc = voter::get_gauge_for_pool(pool_btc_usdt);
        let gauge_usdc = voter::get_gauge_for_pool(pool_usdc_usdt);

        // Vote 50%-50%
        dxlyn_coin::register_and_mint(dev, address_of(dev), 1000 * DXLYN_DECIMAL);
        voting_escrow::create_lock(dev, 1000 * DXLYN_DECIMAL, timestamp::now_seconds() + MAXTIME);
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[pool_btc_usdt, pool_usdc_usdt], vector[50, 50]);

        // ========== CYCLE 1: Kill BTC gauge ==========
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let (_, _, _, _, _, _, balance_before_kill1) = voter::get_voter_state();

        timestamp::fast_forward_seconds(WEEK);
        voter::kill_gauge(dev, gauge_btc);
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_all(dev);

        let (_, _, _, _, _, _, balance_after_dist1) = voter::get_voter_state();
        let locked_after_kill1 = balance_after_dist1 - (voter::get_claimable(gauge_btc) + voter::get_claimable(gauge_usdc));

        // VERIFICATION: Funds locked after first kill
        assert!(locked_after_kill1 > 0, 200);

        // ========== CYCLE 2: Revive BTC, vote again, kill USDC ==========
        voter::revive_gauge(dev, gauge_btc);

        // Wait for vote delay before voting again
        timestamp::fast_forward_seconds(WEEK);

        voter::reset(dev, nft_token_address);
        voter::vote(dev, nft_token_address, vector[pool_btc_usdt, pool_usdc_usdt], vector[50, 50]);

        timestamp::fast_forward_seconds(WEEK);
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        timestamp::fast_forward_seconds(WEEK);
        voter::kill_gauge(dev, gauge_usdc);
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_all(dev);

        let (_, _, _, _, _, _, balance_after_dist2) = voter::get_voter_state();
        let locked_after_kill2 = balance_after_dist2 - (voter::get_claimable(gauge_btc) + voter::get_claimable(gauge_usdc));

        // CRITICAL VERIFICATION: Locked funds ACCUMULATE
        // The second kill added more locked funds on top of the first
        assert!(locked_after_kill2 > locked_after_kill1, 201);

        // PROOF: Both locked amounts are significant
        assert!(locked_after_kill1 > balance_before_kill1 / 20, 202);  // >5% of emission
        assert!(locked_after_kill2 > balance_before_kill1 / 20, 203);  // >5% of emission

        // PROOF: Total locked is substantial
        assert!(locked_after_kill2 > balance_before_kill1 / 10, 204);  // >10% of first emission
    }
}
