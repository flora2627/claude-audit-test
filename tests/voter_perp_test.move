#[test_only]
module dexlyn_perp::voter_perp_test
{

    use std::signer::address_of;
    use std::string::utf8;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_perp::house_lp::DXLP;
    use supra_framework::account;
    use supra_framework::account::{create_account_for_test, create_signer_for_test};
    use supra_framework::coin;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use test_helpers::test_multisig;
    use test_helpers::test_pool::create_lp_owner;

    use dexlyn_tokenomics::bribe;
    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_perp;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    struct TestAssetT {}

    struct TestAssetT2 {}

    struct Dummy {}


    // Constants used across tests
    // Developer address for test setup
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// DXLP (Perpetual dex pool)
    const DXLP_POOL: u8 = 2;

    // One week in seconds (7 days)
    const WEEK: u64 = 604800;

    // Max vote delay allowed in seconds
    const MAX_VOTE_DELAY: u64 = 604800;

    // One day in seconds
    const DAY: u64 = 86400;

    const INITIAL_SUPPLY: u64 = 100_000_000;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // 4 years in seconds
    const MAXTIME: u64 = 126144000;

    // Scaling factor for reward calculations
    const MULTIPLIER: u64 = 100000000;

    public fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun get_liquidity_balance(user: address, token: address): u64 {
        primary_fungible_store::balance(user, address_to_object<Metadata>(token))
    }

    fun get_dxlp_asset_address(): address {
        gauge_perp::get_dxlp_coin_address<TestAssetT>()
    }

    fun get_dxlp_asset2_address(): address {
        gauge_perp::get_dxlp_coin_address<TestAssetT2>()
    }

    fun create_dummy_coin() {
        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        test_internal_coins::init_legacy_coin<TestAssetT2>(
            dexlyn_perp_signer, utf8(b"Dummy"), utf8(b"DUMMT"), 8, true
        );
    }

    public fun create_dexlyn_perp_signer(): signer {
        create_account_for_test(@dexlyn_perp)
    }

    fun create_coins() {
        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        test_internal_coins::init_legacy_coin<DXLP<TestAssetT>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT"), utf8(b"DXLP_TAT"), 8, true
        );

        test_internal_coins::init_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT2"), utf8(b"DXLP_TAT2"), 8, true
        );
    }

    // Test setup function to initialize the environment
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    public fun setup_coins_and_lp_owner(): (signer) {
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        create_coins();
        let mint_amount = 1000000000000;

        let lp_owner = create_lp_owner();
        let lp_owner_address = address_of(&lp_owner);

        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT>>(
            dexlyn_perp_signer,
            lp_owner_address,
            mint_amount
        );
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer,
            lp_owner_address,
            mint_amount
        );

        (lp_owner)
    }

    // Function to mint DXLYN and create a lock for voting
    fun mint_and_create_lock(
        account: &signer, lock_time: u64, value: u64
    ) {
        //register and mint DXLYN to alice account
        dxlyn_coin::register_and_mint(account, address_of(account), value);

        // Set unlock time
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + lock_time;

        // Create lock
        voting_escrow::create_lock(account, value, unlock_time);
    }

    fun setup_test(dev: &signer) {
        // Create developer account
        account::create_account_for_test(address_of(dev));

        // Initialize DXLYN coin (platform token)
        test_internal_coins::init_coin(dev);

        // Initialize USDT coin (reward token)
        test_internal_coins::init_usdt_coin(dev);

        // Initialize USDC coin (reward token)
        test_internal_coins::init_usdc_coin(dev);

        // Initialize voting escrow (tracks locked tokens for voting power)
        voting_escrow::initialize(dev);

        // Initialize fee distributor contract
        fee_distributor::initialize(dev);

        // Initialize voter  contract
        voter::initialize(dev);
    }


    #[test(dev = @dexlyn_tokenomics)]
    fun test_multiple_whitelist_blacklist_same_dxlp_pool(dev: &signer) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::blacklist(dev, vector[asset_address]);
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::blacklist(dev, vector[asset_address]);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        voter::create_gauge(dev, asset_address)
    }

    // Test 1: Initialize voter contract and check initial state
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_initialize(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (owner, voter_admin, governance, minter, index, vote_delay, dxlyn_balance) =
            voter::get_voter_state();

        let dev_address = address_of(dev);

        // Assert all values match expected initialization
        assert!(owner == dev_address, 0x1);
        assert!(voter_admin == dev_address, 0x2);
        assert!(governance == dev_address, 0x3);
        assert!(minter == dev_address, 0x4);
        assert!(index == 0, 0x5);
        assert!(vote_delay == 0, 0x6);
        assert!(dxlyn_balance == 0, 0x7);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_whitelist_cpmm_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        //check lp token is not whitelisted yet
        assert!(!voter::is_pool_whitelisted(asset_address), 0x1);

        //Whitelist Lp<BTC, USDT, Uncorrelated>
        voter::whitelist_perp_pool<TestAssetT>(dev);

        //Check lp token is whitelisted
        assert!(voter::is_pool_whitelisted(asset_address), 0x2);
    }

    // Test 2: Fail when called by non-governance
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE)]
    fun test_voting_perp_whitelist_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_) = setup_coins_and_lp_owner();
        create_account_for_test(address_of(alice));
        voter::whitelist_perp_pool<TestAssetT>(alice);
    }

    // Test 3: Fail when pool already whitelisted
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = voter::ERROR_POOL_ALREADY_WHITELISTED
    )]
    fun test_voting_perp_whitelist_already_whitelisted(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_) = setup_coins_and_lp_owner();

        // Whitelist first
        voter::whitelist_perp_pool<TestAssetT>(dev);
        // Try whitelisting again
        voter::whitelist_perp_pool<TestAssetT>(dev);
    }

    // Test 4: Fail when pool does not exist
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_INVALID_COIN_TYPE)]
    fun test_voting_perp_whitelist_pool_not_exists(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        create_dummy_coin();

        // Initialize without registering the pool
        voter::whitelist_perp_pool<Dummy>(dev);
    }

    // Test 1: Successful blacklisting by governance
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_blacklist_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool first
        voter::whitelist_perp_pool<TestAssetT>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);

        // Blacklist the pool
        let pools = vector::singleton(asset_address);
        voter::blacklist(dev, pools);

        // Verify pool is no longer whitelisted
        assert!(!voter::is_pool_whitelisted(asset_address), 0x2);
    }

    // Test 2: Fail when called by non-governance
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE)]
    fun test_voting_perp_blacklist_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        voter::whitelist_perp_pool<TestAssetT>(dev);

        account::create_account_for_test(address_of(alice));
        let pools = vector::singleton(asset_address);

        //Trying to blacklist pool using non governance account
        voter::blacklist(alice, pools);
    }

    // Test 3: Fail when blacklisting zero address
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_ZERO_ADDRESS)]
    fun test_voting_perp_blacklist_zero_address(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let pools = vector::singleton(@0x0);
        voter::blacklist(dev, pools);
    }

    // Test 4: Fail when blacklisting non-whitelisted pool
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_POOL_NOT_WHITELISTED)]
    fun test_voting_perp_blacklist_non_whitelisted(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        let pools = vector::singleton(asset_address);

        //Should faild becuase pool is not whitelisted before blacklisting
        voter::blacklist(dev, pools);
    }

    // Test 1: Successful gauge killing by governance
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_kill_gauge_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_address = gauge_perp::get_gauge_address(asset_address);
        let epoch_time = voter::epoch_timestamp();

        // Verify gauge is valid and alive
        assert!(voter::is_gauge_valid(gauge_address), 0x1);
        assert!(voter::is_gauge_alive(gauge_address), 0x2);

        // Kill gauge
        voter::kill_gauge(dev, gauge_address);

        // Verify state changes
        assert!(!voter::is_gauge_alive(gauge_address), 0x3);
        assert!(voter::get_claimable(gauge_address) == 0, 0x4);
        assert!(voter::total_weight_at(epoch_time) == 0, 0x5); // Assuming no weights initially
    }

    // Test 2: Fail when called by non-governance
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE)]
    fun test_voting_perp_kill_gauge_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_address = gauge_perp::get_gauge_address(asset_address);

        account::create_account_for_test(address_of(alice));
        voter::kill_gauge(alice, gauge_address);
    }

    // Test 3: Fail when gauge already killed
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_ALREADY_KILLED)]
    fun test_voting_perp_kill_gauge_already_killed(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_address = gauge_perp::get_gauge_address(asset_address);

        voter::kill_gauge(dev, gauge_address);
        voter::kill_gauge(dev, gauge_address);
    }

    // Test 4: Fail when gauge does not exist
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_perp_kill_gauge_non_existent(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let non_existent_gauge = @0x999;
        voter::kill_gauge(dev, non_existent_gauge);
    }

    // Test 1: Successful gauge revival by governance
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_revive_gauge_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        let gauge_address = gauge_perp::get_gauge_address(asset_address);
        // Kill gauge first
        voter::kill_gauge(dev, gauge_address);
        assert!(!voter::is_gauge_alive(gauge_address), 0x1);
        assert!(voter::is_gauge_valid(gauge_address), 0x2);

        // Revive gauge
        voter::revive_gauge(dev, gauge_address);

        // Verify gauge is alive
        assert!(voter::is_gauge_alive(gauge_address), 0x3);
    }

    // Test 2: Fail when called by non-governance
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE)]
    fun test_voting_perp_revive_gauge_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_address = gauge_perp::get_gauge_address(asset_address);

        voter::kill_gauge(dev, gauge_address);
        account::create_account_for_test(address_of(alice));
        voter::revive_gauge(alice, gauge_address);
    }

    // Test 3: Fail when gauge is already alive
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_ALIVE)]
    fun test_voting_perp_revive_gauge_already_alive(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_address = gauge_perp::get_gauge_address(asset_address);

        voter::revive_gauge(dev, gauge_address);
    }

    // Test 4: Fail when gauge does not exist
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_perp_revive_gauge_non_existent(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let non_existent_gauge = @0x999;
        voter::revive_gauge(dev, non_existent_gauge);
    }

    // Test 1: Successful vote to gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_vote(dev: &signer) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges for one pool
        let pools = vector[asset_address, asset2_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        //check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_vote == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(usdc_usdt_pool_votes_before_vote == 0, 0x8);
        assert!(last_voted_before == 0, 0x9);

        let pool_weight_to_vote = vector[50, 50];
        //Vote 50% 50% to both pool
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_vote = voter::weights(asset_address);
        let usdc_usdt_pool_weight_after_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        //check voted on any pool or not
        assert!(voted_on_pools == 2, 0x10);
        //50% of veDxlyn power to btc-usdt pool
        assert!(
            btc_usdt_pool_weight_after_vote == current_vedxlyn_power / 2,
            0x11
        );
        //50% of veDxlyn power to usdc-usdt pool
        assert!(
            usdc_usdt_pool_weight_after_vote == current_vedxlyn_power / 2,
            0x12
        );
        //total vote for current epoch is total of nft total power
        assert!(
            current_total_weights_per_epoch_after_vote == current_vedxlyn_power,
            0x13
        );
        assert!(
            btc_usdt_pool_votes_after_vote == current_vedxlyn_power / 2,
            0x14
        );
        assert!(
            usdc_usdt_pool_votes_after_vote == current_vedxlyn_power / 2,
            0x15
        );
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x15
        );
    }

    // Test 2: Single pool vote
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_vote_single_pool(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);

        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
        assert!(voter::weights(asset_address) == power, 0x2);
        assert!(voter::total_weight() == power, 0x3);
        assert!(voter::get_votes(nft_token_address, asset_address) == power, 0x4);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x5
        );
    }

    // Test 3: Precision handling with small voting power
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_vote_precision(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges for one pool
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 1 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 1 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_vote == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(usdc_usdt_pool_votes_before_vote == 0, 0x8);
        assert!(last_voted_before == 0, 0x9);

        let pool_weight_to_vote = vector[33, 67];
        // Vote 33% to BTC/USDT, 67% to USDC/USDT
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address
        );
        let btc_usdt_pool_weight_after_vote =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_after_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 2, 0x10);
        // 33% of veDxlyn power to btc-usdt pool
        assert!(
            btc_usdt_pool_weight_after_vote == current_vedxlyn_power * 33 / 100,
            0x11
        );
        // 67% of veDxlyn power to usdc-usdt pool
        assert!(
            usdc_usdt_pool_weight_after_vote == current_vedxlyn_power * 67 / 100,
            0x12
        );
        // Total vote for current epoch is total of nft total power
        assert!(
            current_total_weights_per_epoch_after_vote == current_vedxlyn_power,
            0x13
        );
        assert!(
            btc_usdt_pool_votes_after_vote == current_vedxlyn_power * 33 / 100,
            0x14
        );
        assert!(
            usdc_usdt_pool_votes_after_vote == current_vedxlyn_power * 67 / 100,
            0x15
        );
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x16
        );
    }

    // Test 4: Vote throwing error when voting delay is not passed
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY)]
    fun test_voting_perp_vote_with_voting_delay(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        //Set voting delay to 2 dyas
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);

        //Should fail because voting delay is not pass
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
    }

    // Test 5: Voting after voting delay
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_vote_after_voting_delay(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        //Set voting delay to 2 days
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        dxlyn_coin::mint(dev, address_of(dev), 1 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);

        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
        assert!(voter::weights(asset_address) == power, 0x2);
        assert!(voter::total_weight() == power, 0x3);
        assert!(voter::get_votes(nft_token_address, asset_address) == power, 0x4);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x5
        );

        //fast forward time to 3 days
        timestamp::fast_forward_seconds(3 * DAY);

        //Should fail because voting delay is not pass
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);

        //fetch new power because of we fast forwarded time so new power is also changed
        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        //Same for vote cast twice in week
        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x6);
        assert!(voter::weights(asset_address) == power, 0x7);
        assert!(voter::total_weight() == power, 0x8);
        assert!(voter::get_votes(nft_token_address, asset_address) == power, 0x9);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x10
        );
    }

    // Test 6: Fail when vote length of pool and weigh mismatch
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH
    )
    ]
    fun test_voting_perp_vote_lenght_of_pool_and_weigh_mismatch(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address],
            vector[100, 100]
        );
    }

    // Test 7: Mixed active/inactive gauges
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_vote_mixed_gauges(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges for one pool
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Kill USDC/USDT gauge
        let gauge_asset2 = voter::get_gauge_for_pool(asset2_address);
        voter::kill_gauge(dev, gauge_asset2);

        // Mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_vote == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(usdc_usdt_pool_votes_before_vote == 0, 0x8);
        assert!(last_voted_before == 0, 0x9);

        let pool_weight_to_vote = vector[50, 50];
        // Vote 50% to BTC/USDT, 50% to USDC/USDT (inactive gauge)
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_vote =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_after_vote =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 1, 0x10);
        // 100% of veDxlyn power to btc-usdt pool (due to inactive USDC/USDT gauge)
        assert!(btc_usdt_pool_weight_after_vote == current_vedxlyn_power, 0x11);
        // No votes to usdc-usdt pool
        assert!(usdc_usdt_pool_weight_after_vote == 0, 0x12);
        // Total vote for current epoch is total of nft total power
        assert!(
            current_total_weights_per_epoch_after_vote == current_vedxlyn_power,
            0x12
        );
        assert!(btc_usdt_pool_votes_after_vote == current_vedxlyn_power, 0x13);
        assert!(usdc_usdt_pool_votes_after_vote == 0, 0x14);
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x15
        );
    }

    // Test 8: Vote with zero weight
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO
    )
    ]
    fun test_voting_perp_vote_with_zero_weight(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock max time
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        voter::vote(dev, nft_token_address, vector[asset_address], vector[0]);
    }

    // Test 8: Vote with no veDxlyn power
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO
    )
    ]
    fun test_voting_perp_vote_with_no_vedxlyn_power(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock max time
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Fast forward time to ensure no veDxlyn power
        timestamp::fast_forward_seconds(MAXTIME + 1);

        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
    }

    // Test 9: Fail vote while unknown nft owner
    #[test(dev = @dexlyn_tokenomics, alice= @0x123)]
    #[
    expected_failure(
        abort_code = voting_escrow::ERROR_NOT_NFT_OWNER,
        location = voting_escrow
    )
    ]
    fun test_vote_unknown_owner(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        create_account_for_test(address_of(alice));

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Create gauges for one pool
        let pools = vector[asset_address];

        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        voter::vote(
            alice,
            nft_token_address,
            vector[asset_address],
            vector[100]
        );
    }

    // Test 1: Successful vote reset
    #[test(dev = @dexlyn_tokenomics)]
    fun test_reset_success(dev: &signer) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_reset =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_reset =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_reset = voter::total_weight();
        let btc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 2, 0x3);
        assert!(
            btc_usdt_pool_weight_before_reset == current_vedxlyn_power / 2,
            0x4
        );
        assert!(
            usdc_usdt_pool_weight_before_reset == current_vedxlyn_power / 2,
            0x5
        );
        assert!(
            current_total_weights_per_epoch_before_reset == current_vedxlyn_power,
            0x6
        );
        assert!(
            btc_usdt_pool_votes_before_reset == current_vedxlyn_power / 2,
            0x7
        );
        assert!(
            usdc_usdt_pool_votes_before_reset == current_vedxlyn_power / 2,
            0x8
        );
        assert!(
            last_voted_before == voter::epoch_timestamp() + 1,
            0x9
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);

        // Reset votes
        voter::reset(dev, nft_token_address);

        // Post-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_reset =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_after_reset =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_after_reset = voter::total_weight();
        let btc_usdt_pool_votes_after_reset =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_after_reset =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x9);
        assert!(btc_usdt_pool_weight_after_reset == 0, 0x10);
        assert!(usdc_usdt_pool_weight_after_reset == 0, 0x11);
        assert!(current_total_weights_per_epoch_after_reset == 0, 0x12);
        assert!(btc_usdt_pool_votes_after_reset == 0, 0x13);
        assert!(usdc_usdt_pool_votes_after_reset == 0, 0x14);
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x14
        );
    }

    // Test 2: Reset with no prior votes
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTES_NOT_FOUND)]
    fun test_voting_perp_reset_no_votes(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_reset =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_reset =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_reset = voter::total_weight();
        let btc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_reset == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_reset == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_reset == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_reset == 0, 0x7);
        assert!(usdc_usdt_pool_votes_before_reset == 0, 0x8);
        assert!(last_voted_before == 0, 0x9);

        // Reset votes
        voter::reset(dev, nft_token_address);
    }

    // Test 3: Fail reset during same epoch
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY)]
    fun test_reset_same_epoch(dev: &signer) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Attempt to reset in same epoch
        voter::reset(dev, nft_token_address);
    }

    // Test:4 Fail rest test unknown nft owner
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_NFT_OWNER, location = voting_escrow)]
    fun test_reset_unknown_nft_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);

        create_account_for_test(address_of(alice));

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Attempt to reset in same epoch
        voter::reset(alice, nft_token_address);
    }

    // Test 1: Successful poke after voting with increased voting power
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_poke_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_poke =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_poke =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_poke = voter::total_weight();
        let btc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 2, 0x3);
        assert!(
            btc_usdt_pool_weight_before_poke == current_vedxlyn_power / 2,
            0x4
        );
        assert!(
            usdc_usdt_pool_weight_before_poke == current_vedxlyn_power / 2,
            0x5
        );
        assert!(
            current_total_weights_per_epoch_before_poke == current_vedxlyn_power,
            0x6
        );
        assert!(
            btc_usdt_pool_votes_before_poke == current_vedxlyn_power / 2,
            0x7
        );
        assert!(
            usdc_usdt_pool_votes_before_poke == current_vedxlyn_power / 2,
            0x8
        );
        assert!(
            last_voted_before == voter::epoch_timestamp() + 1,
            0x9
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);

        let new_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Poke to update voting power
        voter::poke(dev, nft_token_address);

        // Post-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_poke =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_after_poke =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_after_poke = voter::total_weight();
        let btc_usdt_pool_votes_after_poke =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_after_poke =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 2, 0x10);
        assert!(
            btc_usdt_pool_weight_after_poke == new_vedxlyn_power / 2,
            0x11
        );
        assert!(
            usdc_usdt_pool_weight_after_poke == new_vedxlyn_power / 2,
            0x12
        );
        assert!(current_total_weights_per_epoch_after_poke == new_vedxlyn_power, 0x13);
        assert!(
            btc_usdt_pool_votes_after_poke == new_vedxlyn_power / 2,
            0x14
        );
        assert!(
            usdc_usdt_pool_votes_after_poke == new_vedxlyn_power / 2,
            0x15
        );
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x16
        );
    }

    // Test 2: Poke with no prior votes
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTES_NOT_FOUND)]
    fun test_voting_perp_poke_no_votes(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_poke =
            voter::weights(asset_address);
        let usdc_usdt_pool_weight_before_poke =
            voter::weights(asset2_address);
        let current_total_weights_per_epoch_before_poke = voter::total_weight();
        let btc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, asset_address);
        let usdc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, asset2_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_poke == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_poke == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_poke == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_poke == 0, 0x7);
        assert!(usdc_usdt_pool_votes_before_poke == 0, 0x8);
        assert!(last_voted_before == 0, 0x9);

        // Poke without votes
        voter::poke(dev, nft_token_address);
    }

    // Test 3: Fail poke during same epoch
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY)]
    fun test_voting_perp_poke_same_epoch(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Attempt to poke in same epoch
        voter::poke(dev, nft_token_address);
    }

    // Test 4: Fail poke unknown nft owner
    #[test(dev = @dexlyn_tokenomics, alice= @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_NFT_OWNER, location = voting_escrow)]
    fun test_poke_unknown_nft_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        create_signer_for_test(address_of(alice));

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pools
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Attempt to poke using unknown owner
        voter::poke(alice, nft_token_address);
    }

    // Test 1: Successful gauge creation by owner
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_create_gauge_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, asset_address);

        // Verify gauge creation
        let gauge_address = gauge_perp::get_gauge_address(asset_address);
        assert!(voter::is_gauge_for_pool(asset_address), 0x2);
        assert!(voter::get_gauge_for_pool(asset_address) == gauge_address, 0x3);
        assert!(voter::get_pool_for_gauge(gauge_address) == asset_address, 0x4);
        assert!(voter::is_gauge_valid(gauge_address), 0x5);
        assert!(voter::is_gauge_alive(gauge_address), 0x6);
        assert!(voter::is_pool_in_pools(asset_address), 0x7);
        assert!(voter::get_supply_index(gauge_address) == 0, 0x8);
        assert!(
            voter::get_external_bribe(gauge_address)
                == voter::get_external_bribe_address(asset_address),
            0x9
        );
    }

    // Test 2: Successful multiple gauge creation by owner
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_create_gauges_success(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        assert!(voter::is_pool_whitelisted(asset_address), 0x1);
        assert!(voter::is_pool_whitelisted(asset2_address), 0x2);

        // Create gauges for one pool
        let pools = vector[asset_address, asset2_address];
        // Arbitrary gauge type
        voter::create_gauges(dev, pools);

        // Verify gauge creation
        let gauge_address = gauge_perp::get_gauge_address(asset_address);
        assert!(voter::is_gauge_for_pool(asset_address), 0x2);
        assert!(
            voter::get_gauge_for_pool(asset_address) == gauge_address,
            0x3
        );
        assert!(
            voter::get_pool_for_gauge(gauge_address) == asset_address,
            0x4
        );
        assert!(voter::is_gauge_alive(gauge_address), 0x6);
        assert!(voter::is_gauge_valid(gauge_address), 0x5);
        assert!(voter::is_pool_in_pools(asset_address), 0x7);
        assert!(voter::get_supply_index(gauge_address) == 0, 0x8);
        assert!(
            voter::get_external_bribe(gauge_address)
                == voter::get_external_bribe_address(asset_address),
            0x9
        );
    }

    // Test 3: Fail when called by non-owner
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_OWNER)]
    fun test_voting_perp_create_gauge_non_owner(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);

        account::create_account_for_test(address_of(alice));
        voter::create_gauge(alice, asset_address);
    }

    // Test 4: Fail when gauge already exists for pool
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_GAUGE_ALREADY_EXIST_FOR_POOL
    )
    ]
    fun test_voting_perp_create_gauge_already_exists(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset_address);
    }

    // Test 5: Fail when pool is not whitelisted
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_POOL_NOT_WHITELISTED)]
    fun test_voting_perp_create_gauge_not_whitelisted(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        voter::create_gauge(dev, asset_address);
    }

    // Test 1: get_external_bribe_address
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_get_external_bribe_address(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let expected_bribe_address = voter::get_external_bribe_address(asset_address);

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, asset_address);

        let bribe_address = voter::get_external_bribe_address(asset_address);
        assert!(bribe_address == expected_bribe_address, 0x1);
    }

    // Test 2: length
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_length(dev: &signer) {
        setup_test_with_genesis(dev);

        // Initially, no pools
        assert!(voter::length() == 0, 0x1);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist the pool
        voter::whitelist_perp_pool<TestAssetT>(dev);
        assert!(voter::is_pool_whitelisted(asset_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, asset_address);

        assert!(voter::length() == 1, 0x2);
    }

    // Test 3: pool_vote_length
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_pool_vote_length(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // No votes initially
        assert!(voter::pool_vote_length(dev_address) == 0, 0x1);

        // Whitelist pools and create gauges
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        let pools = vector[asset_address, asset2_address];

        voter::create_gauges(dev, pools);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote for both pool
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        assert!(voter::pool_vote_length(nft_token_address) == 2, 0x2);
    }

    // Test 4: weights
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_weights(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // No votes initially
        assert!(voter::weights(asset_address) == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        assert!(
            voter::weights(asset_address) == current_vedxlyn_power,
            0x2
        );
    }

    // Test 5: weights_at
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_weights_at(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let initial_epoch = voter::epoch_timestamp();

        // No votes initially
        assert!(voter::weights_at(asset_address, initial_epoch) == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);


        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote in initial epoch
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        assert!(
            voter::weights_at(asset_address, initial_epoch)
                == current_vedxlyn_power,
            0x2
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let next_epoch = voter::epoch_timestamp();

        // No votes in next epoch
        assert!(voter::weights_at(asset_address, next_epoch) == 0, 0x3);
    }

    // Test 6: total_weight
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_total_weight(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // No votes initially
        assert!(voter::total_weight() == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);


        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        assert!(voter::total_weight() == current_vedxlyn_power, 0x2);
    }

    // Test 7: total_weight_at
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_total_weight_at(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let initial_epoch = voter::epoch_timestamp();

        // No votes initially
        assert!(voter::total_weight_at(initial_epoch) == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote in initial epoch
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        assert!(
            voter::total_weight_at(initial_epoch) == current_vedxlyn_power, 0x2
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);

        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let next_epoch = voter::epoch_timestamp();

        // No votes in next epoch
        assert!(voter::total_weight_at(next_epoch) == 0, 0x3);
    }

    // Test 1: Successful notify reward with non-zero total weight
    #[
    test(
        dev = @dexlyn_tokenomics,
        supra_framework = @supra_framework,
        minter = @dexlyn_tokenomics
    )
    ]
    fun test_voting_perp_notify_reward_success(
        dev: &signer, minter: &signer
    ) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let minter_address = address_of(minter);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);

        // Mint and lock tokens for dev
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_current_vedxlyn_power, 0x1);

        // Mint DXLYN for minter
        dxlyn_coin::register_and_mint(minter, minter_address, 1000 * DXLYN_DECIMAL);
        let initial_minter_balance = dxlyn_coin::balance_of(minter_address);
        let (_, _, _, _, _, _, initial_voter_balance) = voter::get_voter_state();

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Get previous week emission which is used for rewards distribution
        let previous_week_emission = minter::get_previous_emission();

        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);

        let rebase =
            minter::test_calculate_rebase(
                ve_supply, dxlyn_supply, (previous_week_emission as u256)
            );

        let previous_epoch = voter::epoch_timestamp() - WEEK;

        // Notify reward
        let reward_amount = 500 * DXLYN_DECIMAL;
        voter::set_minter(dev, minter_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Post-notify checks
        let final_minter_balance = dxlyn_coin::balance_of(minter_address);
        let (_, _, _, _, index, _, final_voter_balance) = voter::get_voter_state();

        // Calculate expected index based on previous week emission and total weight
        let expected_ratio =
            (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256)
                / (total_weight as u256) as u64);
        // Calculate expected index based on reward amount and total weight
        let expected_ratio_of_notify =
            (((reward_amount) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);
        // Final index is the sum of both ratios
        let expected_index = expected_ratio + expected_ratio_of_notify;

        assert!(
            final_minter_balance == initial_minter_balance - reward_amount,
            0x2
        );
        assert!(
            final_voter_balance
                == (previous_week_emission - rebase) + initial_voter_balance
                + reward_amount,
            0x3
        );
        assert!(index == expected_index, 0x4);
        assert!(voter::total_weight_at(previous_epoch) == total_weight, 0x5);
    }

    // Test 2: Successful notify reward with zero total weight
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_notify_reward_zero_weight(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let minter_address = address_of(dev);

        // No votes, so total weight is 0
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let previous_epoch = voter::epoch_timestamp() - WEEK;
        assert!(voter::total_weight_at(previous_epoch) == 0, 0x6);

        // Mint DXLYN for minter
        dxlyn_coin::register_and_mint(dev, minter_address, 1000 * DXLYN_DECIMAL);
        let initial_minter_balance = dxlyn_coin::balance_of(minter_address);
        let (_, _, _, _, _, _, initial_voter_balance) = voter::get_voter_state();

        // Notify reward
        let reward_amount = 500 * DXLYN_DECIMAL;
        voter::set_minter(dev, minter_address);

        voter::notify_reward_amount(dev, reward_amount);

        // Post-notify checks
        let final_minter_balance = dxlyn_coin::balance_of(minter_address);
        let (_, _, _, _, index, _, final_voter_balance) = voter::get_voter_state();

        assert!(
            final_minter_balance == initial_minter_balance - reward_amount,
            0x7
        );
        assert!(
            final_voter_balance == initial_voter_balance + reward_amount,
            0x8
        );
        assert!(index == 0, 0x9); // Index unchanged due to zero weight
    }

    // Test 3: Fail notify reward with non-minter
    #[test(
        dev = @dexlyn_tokenomics, non_minter = @0x456
    )]
    #[expected_failure(abort_code = voter::ERROR_NOT_MINTER)]
    fun test_voting_perp_notify_reward_non_minter(
        dev: &signer, non_minter: &signer
    ) {
        setup_test_with_genesis(dev);

        let non_minter_address = address_of(non_minter);
        account::create_account_for_test(non_minter_address);

        // Mint DXLYN for non-minter
        dxlyn_coin::register_and_mint(dev, non_minter_address, 1000 * DXLYN_DECIMAL);

        // Attempt to notify reward as non-minter
        voter::notify_reward_amount(non_minter, 500 * DXLYN_DECIMAL);
    }

    // Test 4: Fail notify reward with insufficient DXLYN
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = voter::ERROR_INSUFFICIENT_DXLYN_COIN
    )]
    fun test_voting_perp_notify_reward_insufficient_balance(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);

        // Attempt to notify reward with amount > balance
        voter::notify_reward_amount(dev, INITIAL_SUPPLY * DXLYN_DECIMAL + 100);
    }

    // Test 1: Successful distribution to multiple gauges with non-zero claimable rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_all_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);
        let gauge_asset = voter::get_gauge_for_pool(asset_address);
        let gauge_asset2 = voter::get_gauge_for_pool(asset_address);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let dev_voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_asset2);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_asset_distribution_time_before == 0, 0x4);
        assert!(gauge_asset2_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        timestamp::fast_forward_seconds(DAY * 2);
        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);
        // Distribute rewards to all gauges
        voter::distribute_all(dev);

        // Get previous week emission which is used for rewards distribution
        let previous_week_emission = minter::get_previous_emission();

        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);

        let rebase =
            minter::test_calculate_rebase(
                ve_supply, dxlyn_supply, (previous_week_emission as u256)
            );

        // Calculate expected rewards per pool
        let expected_ratio =
            (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256)
                / (total_weight as u256) as u64);
        let expected_share_per_pool =
            (((dev_voting_power as u256) / (2 as u256)) * (expected_ratio as u256)
                / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset2);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_asset_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_asset2_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    // Test 2: Successful distribution with no pools
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_all_no_pools(
        dev: &signer
    ) {
        // Initialize test environment without pools
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        timestamp::fast_forward_seconds(DAY * 2);

        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);

        // Verify no pools are whitelisted
        let pool_count = voter::length();
        assert!(pool_count == 0, 0x14);

        // Distribute rewards (should do nothing)
        voter::distribute_all(dev);

        // Verify no state changes in voter contract
        let (_, _, _, _, index, _, voter_balance) = voter::get_voter_state();
        assert!(index == 0, 0x15);
        assert!(voter_balance == 0, 0x16);
    }

    // Test 3: Successful distribution to a killed gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_all_killed_gauge(
        dev: &signer
    ) {
        // Initialize test environment with a pool
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dev_address = address_of(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_asset = voter::get_gauge_for_pool(asset_address);

        // Mint and lock DXLYN tokens for voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote for the pool
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1);

        // Move to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Notify rewards to generate claimable amount
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 500 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Kill the gauge to prevent reward distribution
        voter::kill_gauge(dev, gauge_asset);
        assert!(!voter::is_gauge_alive(gauge_asset), 0x2);

        // Check gauge state before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);

        assert!(btc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_asset_distribution_time_before == 0, 0x4);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x5);

        // Distribute rewards (should skip killed gauge)
        timestamp::fast_forward_seconds(DAY * 2);
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_all(dev);

        // Check gauge state after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let claimable = voter::get_claimable(gauge_asset);
        let (_, _, _, _, index, _, _) = voter::get_voter_state();

        // Verify no rewards distributed and state unchanged
        assert!(btc_usdt_pool_balance_after == 0, 0x6);
        assert!(gauge_asset_distribution_time_after == 0, 0x7);
        assert!(btc_usdt_gauge_supply_index_after == index, 0x8);
        assert!(claimable == 0, 0x9);
    }

    // Test 4: Successful distribution with zero claimable rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_all_zero_claimable(
        dev: &signer
    ) {
        // Initialize test environment with a pool
        setup_test_with_genesis(dev);

        // Allow checkpoint token for distribution
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward timer to allow check pointing
        timestamp::fast_forward_seconds(DAY * 2);

        // Set up DXLYN minter and voter
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();

        // Whitelist pool and create gauge
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::create_gauge(dev, asset_address);
        let gauge_asset = voter::get_gauge_for_pool(asset_address);

        // Mint and lock DXLYN tokens for voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote for the pool
        voter::vote(dev, nft_token_address, vector[asset_address], vector[100]);
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1);

        // Check gauge state before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(gauge_asset);
        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);
        let claimable = voter::get_claimable(gauge_asset);

        // Verify no rewards available
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(gauge_asset_distribution_time_before == 0, 0x3);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x4);
        assert!(claimable == 0, 0x5);

        // Distribute rewards (should do nothing) because update period is not called
        voter::distribute_all(dev);

        // Check gauge state after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let final_claimable = voter::get_claimable(gauge_asset);

        // Verify no rewards distributed and state unchanged
        assert!(btc_usdt_pool_balance_after == 0, 0x6);
        assert!(gauge_asset_distribution_time_after == 0, 0x7);
        assert!(btc_usdt_gauge_supply_index_after == 0, 0x8);
        assert!(final_claimable == 0, 0x9);
    }

    // Test 1: Successful distribution to a range of gauges with non-zero claimable rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_range_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);
        let gauge_asset = voter::get_gauge_for_pool(asset_address);
        let gauge_asset2 = voter::get_gauge_for_pool(asset2_address);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_asset2);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_asset_distribution_time_before == 0, 0x4);
        assert!(gauge_asset2_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        // Distribute rewards to all gauges
        timestamp::fast_forward_seconds(DAY * 2);
        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_range(dev, 0, 2);

        // Get previous week emission which is used for rewards distribution
        let previous_week_emission = minter::get_previous_emission();

        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
        let rebase =
            minter::test_calculate_rebase(
                ve_supply, dxlyn_supply, (previous_week_emission as u256)
            );

        // Calculate expected index based on previous week emission and total weight
        let expected_ratio =
            (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256)
                / (total_weight as u256) as u64);
        // Calculate expected index based on reward amount and total weight
        let expected_ratio_of_notify =
            (((reward_amount) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);
        // Final index is the sum of both ratios
        let expected_index = expected_ratio + expected_ratio_of_notify;


        let expected_share_per_pool = (((voting_power as u256) / (2 as u256)) * (expected_index as u256) / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset2);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_asset_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_asset2_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    // Test 2: Error when start >= finish
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_START_MUST_BE_LESS_THEN_FINISH
    )
    ]
    fun test_voting_perp_distribute_range_start_not_less_than_finish(
        dev: &signer
    ) {
        // Initialize test environment
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        timestamp::fast_forward_seconds(DAY * 2);

        // Attempt to distribute with invalid range (start >= finish)
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        voter::distribute_range(dev, 2, 1);

        // Expect ERROR_START_MUST_BE_LESS_THEN_FINISH (0x19)
    }

    // Test 1: Successful distribution to gauges with non-zero claimable rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_distribute_gauges_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();
        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);
        let gauge_asset = voter::get_gauge_for_pool(asset_address);
        let gauge_asset2 = voter::get_gauge_for_pool(asset2_address);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_asset2);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_asset_distribution_time_before == 0, 0x4);
        assert!(gauge_asset2_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        // Distribute rewards to all gauges
        timestamp::fast_forward_seconds(DAY * 2);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_gauges(dev, vector[gauge_asset, gauge_asset2]);

        // Get previous week emission which is used for rewards distribution
        let previous_week_emission = minter::get_previous_emission();

        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);

        let rebase =
            minter::test_calculate_rebase(
                ve_supply, dxlyn_supply, (previous_week_emission as u256)
            );

        // Calculate expected index based on previous week emission and total weight
        let expected_ratio =
            (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256)
                / (total_weight as u256) as u64);
        // Calculate expected index based on reward amount and total weight
        let expected_ratio_of_notify =
            (((reward_amount) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);
        // Final index is the sum of both ratios
        let expected_index = expected_ratio + expected_ratio_of_notify;


        let expected_share_per_pool = (((voting_power as u256) / (2 as u256)) * (expected_index as u256) / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(
                gauge_perp::get_gauge_address(asset2_address)
            );
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset2);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_asset_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_asset2_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    // Test 2: Error when pass invalid gauge address
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_perp_distribute_gauges_start_not_less_than_finish(
        dev: &signer
    ) {
        // Initialize test environment
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);

        timestamp::fast_forward_seconds(DAY * 2);

        // Attempt to distribute with invalid gauge addresses
        voter::distribute_gauges(dev, vector[@0x1, @0x2]);
    }

    // claim_emission
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_claim_emission(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);

        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);


        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();
        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);
        let gauge_asset = gauge_perp::get_gauge_address(asset_address);
        let gauge_asset2 = gauge_perp::get_gauge_address(asset2_address);

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);

        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches nft power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(gauge_asset);
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_perp::get_gauge_state(gauge_asset2);

        let gauge_asset_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_asset2);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_asset_distribution_time_before == 0, 0x4);
        assert!(gauge_asset2_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        // Distribute rewards to all gauges
        timestamp::fast_forward_seconds(DAY * 2);
        voter::distribute_all(dev);

        // Get previous week emission which is used for rewards distribution
        let previous_week_emission = minter::get_previous_emission();

        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);

        let rebase = minter::test_calculate_rebase(ve_supply, dxlyn_supply, (previous_week_emission as u256));

        // Calculate expected index based on previous week emission and total weight
        let expected_ratio = (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);

        let expected_share_per_pool = (((voting_power as u256) / (2 as u256)) * (expected_ratio as u256) / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(gauge_asset);
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_perp::get_gauge_state(gauge_asset2);
        let gauge_asset_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset);
        let gauge_asset2_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_asset2);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_asset2);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);

        assert!(gauge_asset_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_asset2_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);

        let balance_before_claim = dxlyn_coin::balance_of(dev_address);

        // Fast forward to week end to allow claiming rewards
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + WEEK);

        let expected_claimable = gauge_perp::earned(gauge_asset, dev_address);

        // Dev stacked lp for one week, so they can claim rewards
        voter::claim_emission(dev, vector[gauge_asset, gauge_asset2]);

        let balance_after_claim = dxlyn_coin::balance_of(dev_address);

        assert!(
            balance_after_claim == balance_before_claim + (expected_claimable * 2),
            0x14
        );
    }

    // Test 1: Successful bribe claiming with rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_claim_bribe(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(
            dev,
            asset_address,
            usdt_metadata,
            reward
        );

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);

        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        let dev_votes = voter::get_votes(nft_token_address, asset_address);

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(asset_address);

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribes(
            dev,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        // Calculate expected rewards per token
        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        // Calculate expected reward for dev based on their vote
        let expected_dev_reward = (dev_votes * reward_per_token) / MULTIPLIER;

        let dev_usdt_balance_after_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(
            dev_usdt_balance_after_claim
                == dev_usdt_balance_before_claim + expected_dev_reward,
            0x2
        );
    }

    // Test 2: Error when claiming bribes for a pool with no rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_claim_bribes_no_rewards(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();
        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);

        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribes(
            dev,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        let dev_usdt_balance_after_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(dev_usdt_balance_after_claim == dev_usdt_balance_before_claim, 0x2);
    }

    // Test 3: Error when claiming bribes with mismatched lengths
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH
    )
    ]
    fun test_voting_perp_claim_bribes_length_not_match(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);

        // Get dev address and pool addresses
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();
        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        // Claim bribes for the pool
        voter::claim_bribes(dev, vector[asset_address], vector[]);
    }

    // Test 1: Successful bribe claiming with rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_claim_bribe_for_user(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();
        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(
            dev,
            asset_address,
            usdt_metadata,
            reward
        );

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);

        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches nft power

        let nft_votes = voter::get_votes(nft_token_address, asset_address);

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(asset_address);

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes rewards for a specific address
        voter::claim_bribes_for_address(
            dev_address,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        // Calculate expected rewards per token
        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        // Calculate expected reward for dev based on their vote
        let expected_dev_reward = (nft_votes * reward_per_token) / MULTIPLIER;

        let dev_usdt_balance_after_claim = test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(
            dev_usdt_balance_after_claim
                == dev_usdt_balance_before_claim + expected_dev_reward,
            0x2
        );
    }

    // Test 2: Error when claiming bribes for a pool with no rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_perp_claim_bribes_for_address_no_rewards(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);

        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);


        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribes_for_address(
            dev_address,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        let dev_usdt_balance_after_claim = test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(dev_usdt_balance_after_claim == dev_usdt_balance_before_claim, 0x2);
    }

    // Test 3: Error when claiming bribes with mismatched lengths
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH
    )
    ]
    fun test_voting_perp_claim_bribes_for_address_length_not_match(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);

        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        // Claim bribes for the pool
        voter::claim_bribes_for_address(
            dev_address, vector[asset_address], vector[]
        );
    }


    // Test 1: Successful bribe claiming with rewards for nft token owner
    #[test(dev = @dexlyn_tokenomics, alice= @0x123)]
    fun test_claim_bribe_for_token(
        dev: &signer, alice: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        create_account_for_test(address_of(alice));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(
            dev,
            asset_address,
            usdt_metadata,
            reward
        );

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);


        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches nft power

        let nft_votes = voter::get_votes(nft_token_address, asset_address);

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();

        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(asset_address);

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes rewards for a specific nft token owner
        voter::claim_bribe_for_token(
            alice,
            nft_token_address,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        // Calculate expected rewards per token
        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        // Calculate expected reward for dev based on their vote
        let expected_dev_reward = (nft_votes * reward_per_token) / MULTIPLIER;

        let dev_usdt_balance_after_claim = test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(
            dev_usdt_balance_after_claim
                == dev_usdt_balance_before_claim + expected_dev_reward,
            0x2
        );
    }

    // Test 2: Error when claiming bribes for a pool with no rewards
    #[test(dev = @dexlyn_tokenomics, alice= @0x123)]
    fun test_claim_bribes_for_token_no_rewards(
        dev: &signer, alice: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        create_account_for_test(address_of(alice));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (lp_owner) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        //TODO:Add USDT as a reward token to bribe mock will shift to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, asset_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        //Stake BTC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(&lp_owner, lp_amount);

        //Stake USDC-USDT to gauge
        let lp_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT2>(&lp_owner, lp_amount);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[asset_address, asset2_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribe_for_token(
            alice,
            nft_token_address,
            vector[asset_address],
            vector[vector[usdt_metadata]]
        );

        let dev_usdt_balance_after_claim = test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(dev_usdt_balance_after_claim == dev_usdt_balance_before_claim, 0x2);
    }

    // Test 3: Error when claiming bribes with mismatched lengths
    #[test(dev = @dexlyn_tokenomics, alice= @0x123)]
    #[
    expected_failure(
        abort_code = voter::ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH
    )
    ]
    fun test_claim_bribes_for_token_length_not_match(
        dev: &signer, alice: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);

        create_account_for_test(address_of(alice));

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_) = setup_coins_and_lp_owner();
        let asset_address = get_dxlp_asset_address();
        let asset2_address = get_dxlp_asset2_address();

        // Whitelist pools and create gauges for reward distribution
        voter::whitelist_perp_pool<TestAssetT>(dev);
        voter::whitelist_perp_pool<TestAssetT2>(dev);
        voter::create_gauge(dev, asset_address);
        voter::create_gauge(dev, asset2_address);

        // Claim bribes for the pool
        voter::claim_bribe_for_token(
            alice, dev_address, vector[asset_address, asset2_address], vector[]
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voter_perp_gauge_multi_epoch(dev: &signer) {
        // ===========================================
        // INITIAL SETUP - Pool and Token Creation
        // ===========================================
        setup_test_with_genesis(dev);

        let (lp_owner) = setup_coins_and_lp_owner();
        let asset2_address = get_dxlp_asset2_address();
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Check LP tokens are not whitelisted yet
        assert!(!voter::is_pool_whitelisted(asset2_address), 0x1);

        // Whitelist both pool types
        voter::whitelist_perp_pool<TestAssetT2>(dev);

        // Verify pools are now whitelisted
        assert!(voter::is_pool_whitelisted(asset2_address), 0x1);

        // ===========================================
        // GAUGE CREATION AND BRIBE SETUP
        // ===========================================
        // Create gauges for both pools
        let pools = vector[asset2_address];
        voter::create_gauges(dev, pools);

        // Get gauge addresses
        let gauge_perp = gauge_perp::check_and_get_gauge_address(asset2_address);

        // Setup bribe rewards
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);

        // Add reward tokens to bribes
        bribe::add_reward_token(
            dev, asset2_address, usdc_metadata
        );

        let lp_owner_addr = address_of(&lp_owner);

        // ===========================================
        // INITIAL VOTING LOCK AND DEPOSITS
        // ===========================================
        // Create voting escrow lock
        let amount_lock = 100 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, lp_owner_addr, amount_lock);

        // Set unlock time
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + MAXTIME;

        // Create lock
        voting_escrow::create_lock(&lp_owner, amount_lock, unlock_time);


        let balance_before_deposit = coin::balance<DXLP<TestAssetT2>>(lp_owner_addr);
        gauge_perp::deposit<TestAssetT2>(&lp_owner, balance_before_deposit);
        let balance_after_deposit = coin::balance<DXLP<TestAssetT2>>(lp_owner_addr);

        assert!(balance_after_deposit == 0, 1);

        // Set minter for reward distribution
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // ===========================================
        // MULTI-EPOCH TESTING LOOP
        // ===========================================
        // Define voting patterns for each epoch (pool weight percentages)
        let epoch_voting_patterns = vector[
            vector[55], // Epoch 1: 55% CLMM
            vector[40], // Epoch 2: 40% CLMM
            vector[70]  // Epoch 3: 70% CLMM
        ];

        // Rewards for each epoch
        let epoch_rewards = vector[
            1 * DXLYN_DECIMAL, // Epoch 1 reward
            2 * DXLYN_DECIMAL, // Epoch 2 reward (increased)
            1500000000 // Epoch 3 reward (1.5 * DXLYN_DECIMAL)
        ];

        let epoch_count = 3;
        let i = 0;

        while (i < epoch_count) {
            // print_formatted(b"========== STARTING EPOCH", i + 1);

            // ===========================================
            // EPOCH SPECIFIC SETUP
            // ===========================================
            let current_voting_weights = *vector::borrow(&epoch_voting_patterns, i);
            let current_reward = *vector::borrow(&epoch_rewards, i);

            // print_formatted(b"CPMM Pool Weight %", cpmm_weight);
            // print_formatted(b"CLMM Pool Weight %", clmm_weight);
            // print_formatted(b"Epoch Reward Amount", current_reward);

            // ===========================================
            // BRIBE REWARDS SETUP FOR CURRENT EPOCH
            // ===========================================
            // Mint tokens for bribe rewards
            let total_bribe_amount = current_reward; // Enough for both pools
            test_internal_coins::register_and_mint_usdt(
                dev, address_of(dev), total_bribe_amount
            );
            test_internal_coins::register_and_mint_usdc(
                dev, address_of(dev), total_bribe_amount
            );

            // Notify bribe rewards for this epoch
            bribe::notify_reward_amount(
                dev,
                asset2_address,
                usdc_metadata,
                current_reward
            );

            // ===========================================
            // VOTING FOR CURRENT EPOCH
            // ===========================================
            // Get current voting power
            // Get the token address and object
            let (nft_token_address, _) = get_nft_token_address(1);

            // Cast votes with current epoch's weights
            let clmm_power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

            voter::vote(
                &lp_owner,
                nft_token_address,
                vector[asset2_address],
                current_voting_weights
            );
            let total_weight = voter::total_weight();

            // ===========================================
            // VOTING VERIFICATION
            // ===========================================
            assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
            assert!(voter::weights(asset2_address) == clmm_power, 0x2);
            assert!(total_weight == clmm_power, 0x3);
            assert!(voter::get_votes(nft_token_address, asset2_address) == clmm_power, 0x4);

            // print_formatted(b"Voting verification passed for epoch", i + 1);

            // ===========================================
            // EPOCH PROGRESSION AND REWARD DISTRIBUTION
            // ===========================================
            // Fast forward to next epoch
            timestamp::fast_forward_seconds(WEEK);

            // Distribute rewards for this epoch
            voter::distribute_all(dev);

            // ===========================================
            // GAUGE REWARD VERIFICATION
            // ===========================================
            // let (_, _, _, _, _, _, _, _, _, _, clmm_coin_bal) = gauge_clmm::get_gauge_state(gauge_clmm);
            // print_formatted(b"CLMM Gauge Balance", clmm_coin_bal);

            // Calculate expected rewards for verification
            // let previous_week_emission = minter::get_previous_emission();
            // let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
            // let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
            // let rebase = minter::test_calculate_rebase(ve_supply, dxlyn_supply, (previous_week_emission as u256));


            // let expected_ratio = (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);
            // let expected_share_per_pool = (((clmm_power as u256)) * (expected_ratio as u256) / (DXLYN_DECIMAL as u256) as u64);

            // let clmm_pool_share = ((expected_share_per_pool * clmm_weight) / 100);
            // print_formatted(b"Expected CLMM Share", clmm_pool_share);

            // ===========================================
            // BRIBE CLAIMING AND VERIFICATION
            // ===========================================
            // Record balances before claiming bribes
            // let dev_usdt_balance_before =
            //     primary_fungible_store::balance(
            //         dev_address,
            //         address_to_object<Metadata>(usdt_metadata)
            //     );
            let dev_usdc_balance_before =
                primary_fungible_store::balance(
                    lp_owner_addr,
                    address_to_object<Metadata>(usdc_metadata)
                );

            // Get total supplies for reward calculation
            let total_clmm_supply =
                bribe::total_supply(asset2_address);

            // Fast forward another week to enable bribe claiming
            timestamp::fast_forward_seconds(WEEK);
            voter::distribute_all(dev);

            // Claim bribes for both pools
            voter::claim_bribes(
                &lp_owner,
                vector[asset2_address],
                vector[vector[usdc_metadata]]
            );

            // Calculate expected bribe rewards
            let reward_clmm = (current_reward * MULTIPLIER) / total_clmm_supply;
            let expected_clmm_reward = (clmm_power * reward_clmm) / MULTIPLIER;

            // Verify bribe rewards received
            // let dev_usdt_balance_after =
            //     primary_fungible_store::balance(
            //         dev_address,
            //         address_to_object<Metadata>(usdt_metadata)
            //     );
            let dev_usdc_balance_after =
                primary_fungible_store::balance(
                    lp_owner_addr,
                    address_to_object<Metadata>(usdc_metadata)
                );

            // print_formatted(b"Expected CLMM Bribe Reward", expected_clmm_reward);
            // print_formatted(b"Actual USDT Received", dev_usdt_balance_after - dev_usdt_balance_before);
            // print_formatted(b"Actual USDC Received", dev_usdc_balance_after - dev_usdc_balance_before);

            // Verify bribe rewards are correct
            assert!(
                dev_usdc_balance_after
                    == dev_usdc_balance_before + expected_clmm_reward,
                0x20 + i
            );

            // ===========================================
            // GAUGE REWARD CLAIMING
            // ===========================================
            // print_formatted(b"Claiming gauge rewards for epoch", i + 1);

            // Get gauge rewards for user
            gauge_perp::get_reward(&lp_owner, gauge_perp);

            // Verify gauge balances after claiming
            // let (_, _, _, _, _, _, _, _, _, _, cpmm_coin_bal_after) = gauge_perp::get_gauge_state(gauge_cpmm);
            // let (_, _, _, _, _, _, _, _, _, _, clmm_coin_bal_after) = gauge_clmm::get_gauge_state(gauge_clmm);

            // print_formatted(b"CPMM Gauge Balance After Claim", cpmm_coin_bal_after);
            // print_formatted(b"CLMM Gauge Balance After Claim", clmm_coin_bal_after);

            // print_separator();
            // print_formatted(b"========== EPOCH COMPLETED", i + 1);
            // print_separator();

            i = i + 1;
        };

        // ===========================================
        // FINAL CLEANUP - WITHDRAW FROM GAUGES
        // ===========================================
        // print_formatted(b"========== FINAL CLEANUP", 0);

        // Withdraw CLMM liquidity
        let total_bal = gauge_perp::balance_of(gauge_perp, lp_owner_addr);
        gauge_perp::withdraw<TestAssetT2>(&lp_owner, total_bal);

        let balance_after_withdraw = coin::balance<DXLP<TestAssetT2>>(lp_owner_addr);
        assert!(balance_after_withdraw == balance_before_deposit, 1);


        // print_formatted(b"========== ALL EPOCHS COMPLETED SUCCESSFULLY", 0);
        // print_formatted(b"Total epochs tested", epoch_count);
        // print_formatted(b"All withdrawals completed", 1);
    }
}
