#[test_only]
module dexlyn_tokenomics::poc_finding_6_zero_weight_emission_loss {
    use std::signer::address_of;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap::scripts;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{Self, BTC, USDT};
    use test_helpers::test_multisig;
    use test_helpers::test_pool::{create_lp_owner, initialize_liquidity_pool};

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    // Constants
    const WEEK: u64 = 604800;
    const MAXTIME: u64 = 126144000;
    const DXLYN_DECIMAL: u64 = 100000000;

    public fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun get_liquidity_balance(user: address, token: address): u64 {
        primary_fungible_store::balance(user, address_to_object<Metadata>(token))
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

        liquidity_pool::generate_lp_object_address<BTC, USDT, Uncorrelated>()
    }

    // PoC for Finding 6: First week emission loss when total_weight = 0
    // This test demonstrates that when the protocol launches and no votes have been cast
    // in the first week, the entire week's gauge emission is permanently lost
    #[test(dev = @dexlyn_tokenomics)]
    fun test_first_week_emission_loss_zero_weight(dev: &signer) {
        // ============================================
        // STEP 1: Initialize protocol (NO voting yet)
        // ============================================
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Create pool and gauge
        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_address = btc_usdt_pool(&coin_admin, &lp_owner);

        // Whitelist pool and create gauge
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_address);
        let gauge_address = gauge_cpmm::get_gauge_address(pool_address);

        // Get voter's initial DXLYN balance (should be 0)
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_address();
        let voter_address = voter::get_voter_address();
        let voter_balance_before = get_liquidity_balance(voter_address, dxlyn_metadata);
        assert!(voter_balance_before == 0, 0x1001);

        // Verify initial voter index is 0
        let (_, _, _, _, voter_index_before, _, _) = voter::get_voter_state();
        assert!(voter_index_before == 0, 0x1002);

        // ============================================
        // STEP 2: Fast forward 1 week WITHOUT voting
        // ============================================
        // At this point, total_weights_per_epoch[epoch=0] = 0 (no votes cast)
        timestamp::fast_forward_seconds(WEEK);

        // Set minter to enable emission
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // ============================================
        // STEP 3: Trigger update_period() - Emission will be transferred
        // ============================================
        voter::update_period();

        // Get voter's DXLYN balance after update_period (should have received emission)
        let voter_balance_after_update = get_liquidity_balance(voter_address, dxlyn_metadata);

        // Verify that voter DID receive DXLYN from minter
        assert!(voter_balance_after_update > voter_balance_before, 0x2001);
        let emission_received = voter_balance_after_update - voter_balance_before;

        // Get voter index after notify_reward_amount
        let (_, _, _, _, voter_index_after_notify, _, _) = voter::get_voter_state();

        // 🔴 BUG: voter.index should have increased, but it DIDN'T because total_weight = 0
        assert!(voter_index_after_notify == voter_index_before, 0x2002);

        // ============================================
        // STEP 4: Try to distribute - Should fail to allocate
        // ============================================
        // Fast forward another week to enable distribution
        timestamp::fast_forward_seconds(WEEK);

        // Try to distribute
        voter::distribute_all(dev);

        // Get claimable amount for the gauge (should be 0 due to delta = 0)
        let claimable = voter::get_claimable(gauge_address);

        // 🔴 BUG: claimable should be > 0, but it's 0 because delta = index - supply_index = 0
        assert!(claimable == 0, 0x3001);

        // ============================================
        // STEP 5: Verify accounting invariant is BROKEN
        // ============================================
        // Get voter's final DXLYN balance (should still have the emission)
        let voter_balance_final = get_liquidity_balance(voter_address, dxlyn_metadata);

        // 🔴 BUG: Accounting invariant broken
        // voter_balance should equal sum(claimable[all_gauges])
        // But here: voter_balance = emission_received, claimable = 0
        assert!(voter_balance_final == emission_received, 0x4001);
        assert!(voter_balance_final > claimable, 0x4002);

        // The emission is permanently stuck in voter contract
        // No gauge can claim it because claimable = 0
        // This breaks the accounting invariant: voter_balance > sum(claimable[gauge])
    }

    // PoC variant: Even with votes in CURRENT week, if PREVIOUS week had no votes,
    // the emission for current week distribution is still lost
    #[test(dev = @dexlyn_tokenomics)]
    fun test_emission_loss_despite_current_votes(dev: &signer) {
        // ============================================
        // STEP 1: Initialize protocol
        // ============================================
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_address = btc_usdt_pool(&coin_admin, &lp_owner);

        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_address);
        let gauge_address = gauge_cpmm::get_gauge_address(pool_address);

        // Get initial state
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_address();
        let voter_address = voter::get_voter_address();

        // ============================================
        // STEP 2: Fast forward 1 week WITHOUT voting
        // ============================================
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // ============================================
        // STEP 3: Vote in CURRENT week (but too late for PREVIOUS week)
        // ============================================
        // Create a veNFT and vote
        dxlyn_coin::register_and_mint(dev, address_of(dev), 100 * DXLYN_DECIMAL);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + MAXTIME;
        voting_escrow::create_lock(dev, 100 * DXLYN_DECIMAL, unlock_time);

        // Vote for the pool
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[pool_address], vector[100]);

        // Verify we now have voting weight for THIS week
        let total_weight_current = voter::total_weight();
        assert!(total_weight_current > 0, 0x5001);

        // ============================================
        // STEP 4: Trigger update_period - Uses PREVIOUS week's weight (which is 0)
        // ============================================
        voter::update_period();

        let voter_balance_after_update = get_liquidity_balance(voter_address, dxlyn_metadata);
        let emission_received = voter_balance_after_update;

        // Verify emission was received
        assert!(emission_received > 0, 0x5002);

        // Get voter index
        let (_, _, _, _, voter_index_after, _, _) = voter::get_voter_state();

        // 🔴 BUG: Even though we have votes NOW, the emission distribution uses
        // PREVIOUS week's weight, which was 0, so index doesn't increase
        assert!(voter_index_after == 0, 0x5003);

        // ============================================
        // STEP 5: Distribute - Still fails
        // ============================================
        timestamp::fast_forward_seconds(WEEK);
        voter::distribute_all(dev);

        let claimable = voter::get_claimable(gauge_address);

        // 🔴 BUG: claimable is still 0 despite having votes, because the
        // emission distribution looked at PREVIOUS week's weight
        assert!(claimable == 0, 0x5004);

        // Accounting invariant still broken
        let voter_balance_final = get_liquidity_balance(voter_address, dxlyn_metadata);
        assert!(voter_balance_final > claimable, 0x5005);
    }

    // PoC variant: Multiple weeks of zero weight lead to cumulative loss
    #[test(dev = @dexlyn_tokenomics)]
    fun test_cumulative_emission_loss_multiple_weeks(dev: &signer) {
        // ============================================
        // STEP 1: Initialize protocol
        // ============================================
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_address = btc_usdt_pool(&coin_admin, &lp_owner);

        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_address);
        let gauge_address = gauge_cpmm::get_gauge_address(pool_address);

        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_address();
        let voter_address = voter::get_voter_address();
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // ============================================
        // STEP 2: Simulate 3 weeks without voting
        // ============================================
        // Week 1
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();
        let balance_1 = get_liquidity_balance(voter_address, dxlyn_metadata);

        // Week 2
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();
        let balance_2 = get_liquidity_balance(voter_address, dxlyn_metadata);
        assert!(balance_2 > balance_1, 0x6001); // More emission accumulated

        // Week 3
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();
        let balance_3 = get_liquidity_balance(voter_address, dxlyn_metadata);
        assert!(balance_3 > balance_2, 0x6002); // Even more emission accumulated

        let total_emission_lost = balance_3;

        // ============================================
        // STEP 3: Try to distribute all weeks
        // ============================================
        timestamp::fast_forward_seconds(WEEK);
        voter::distribute_all(dev);

        let claimable = voter::get_claimable(gauge_address);

        // 🔴 BUG: Despite 3 weeks of emissions accumulated, claimable is still 0
        assert!(claimable == 0, 0x6003);

        // 🔴 BUG: All 3 weeks of emission are stuck
        let voter_balance_final = get_liquidity_balance(voter_address, dxlyn_metadata);
        assert!(voter_balance_final == total_emission_lost, 0x6004);
        assert!(voter_balance_final > 0, 0x6005);

        // The accounting gap grows with each week
        // voter_balance increases, but claimable remains 0
    }
}
