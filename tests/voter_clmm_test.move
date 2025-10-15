#[test_only]
module dexlyn_tokenomics::voter_clmm_test {

    use std::signer::address_of;
    use std::string::utf8;
    use std::vector;

    use aptos_token_objects::token;
    use aptos_token_objects::token::Token;
    use dexlyn_clmm::clmm_router;
    use dexlyn_clmm::factory;
    use dexlyn_clmm::pool;
    use dexlyn_clmm::position_nft;
    use dexlyn_clmm::test_helpers;
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account;
    use supra_framework::account::{create_account_for_test, create_signer_for_test};
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::bribe;
    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_clmm;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voter::get_edit_vote_penalty;
    use dexlyn_tokenomics::voter_cpmm_test::get_quants;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    // Constants used across tests
    // Developer address for test setup
    const SC_ADMIN: address = @dexlyn_tokenomics;
    // One week in seconds (7 days)
    const WEEK: u64 = 604800; // 600

    // Max vote delay allowed in seconds
    const MAX_VOTE_DELAY: u64 = 604800; // 600

    // One day in seconds
    const DAY: u64 = 86400; // 80

    const INITIAL_SUPPLY: u64 = 100_000_000;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // 4 years in seconds
    const MAXTIME: u64 = 126144000; // 3600

    // Scaling factor for reward calculations
    const MULTIPLIER: u64 = 100000000;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    fun setup_test(dev: &signer) {
        genesis::setup();
        // Mint initial DXLYN supply to developer account
        timestamp::update_global_time_for_test_secs(1746057600);

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

        // Initialize voter contract
        voter::initialize(dev);

        let dev2 = create_signer_for_test(@dexlyn_clmm);
        factory::init_factory_module(&dev2);
        clmm_router::add_fee_tier(&dev2, 200, 1000);
    }

    public fun create_pool(dev: &signer): (u64, address, address, address) {
        let (token_a_name, token_b_name) = (utf8(b"BTC"), utf8(b"USDC"));
        let token_a = test_helpers::setup_fungible_assets(dev, token_a_name, utf8(b"TB"));
        let token_b = test_helpers::setup_fungible_assets(dev, token_b_name, utf8(b"TU"));

        let tick_spacing = 200;
        let init_sqrt_price = 18446744073709551616; // at 0

        let pool_address =
            factory::create_pool(
                dev,
                tick_spacing,
                init_sqrt_price,
                utf8(b""),
                token_a,
                token_b
            );
        (tick_spacing, token_a, token_b, pool_address)
    }

    fun create_pool2(dev: &signer): (u64, address, address, address) {
        let (token_a_name, token_b_name) = (utf8(b"UDT"), utf8(b"USC"));
        let token_a = test_helpers::setup_fungible_assets(dev, token_a_name, utf8(b"TT"));
        let token_b = test_helpers::setup_fungible_assets(dev, token_b_name, utf8(b"TC"));

        let tick_spacing = 200;
        let init_sqrt_price = 18446744073709551616; // at 0

        let pool_address =
            factory::create_pool(
                dev,
                tick_spacing,
                init_sqrt_price,
                utf8(b""),
                token_b,
                token_a,
            );

        (tick_spacing, token_b, token_a, pool_address)
    }

    public fun add_liquidity(
        pool_address: address,
        provider: &signer,
        pool_index: u64
    ): address {
        let (token_a, token_b) = pool::get_pool_assets(pool_address);
        clmm_router::add_liquidity_fix_value(
            provider,
            pool_address,
            100000,
            100000,
            false,
            18446744073709549616, // -2000
            0, // 0
            true,
            0,
        );
        let tick_spacing = 200;

        let collection = position_nft::collection_name(tick_spacing, token_a, token_b);
        let token_name = position_nft::position_name(pool_index, 1);
        let token_address =
            token::create_token_address(&pool_address, &collection, &token_name);

        // Check token is for valid pool
        assert!(position_nft::is_valid_nft(token_address, pool_address), 123);
        assert!(
            object::owner<Token>(address_to_object<Token>(token_address))
                == address_of(provider),
            11
        );

        token_address
    }

    // Function to mint DXLYN and create a lock for voting
    public fun mint_and_create_lock(
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

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_whitelist_success(dev: &signer) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        //check lp token is not whitelisted yet
        assert!(!voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        //check lp token is whitelisted
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_clmm_create_gauge_failed(dev: &signer) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        //check lp token is not whitelisted yet
        assert!(!voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        //check lp token is whitelisted
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        gauge_clmm::check_and_get_gauge_address(btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_vote(dev: &signer)
    {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        // Whitelist the pool
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote =
            voter::weights(btc_usdc_pool_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let last_voted_before = voter::get_last_voted(nft_token_address);

        //check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(last_voted_before == 0, 0x9);

        //Vote 50% to pool
        let pool_weight_to_vote = vector[50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_vote = voter::weights(btc_usdc_pool_address);

        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let last_voted_after = voter::get_last_voted(nft_token_address);

        //check voted on any pool or not
        assert!(voted_on_pools == 1, 0x10);
        //50% of veDxlyn power to btc-usdt pool

        assert!(
            btc_usdt_pool_weight_after_vote == current_vedxlyn_power,
            0x11
        );
        //total vote for current epoch is total of nft total power
        assert!(
            current_total_weights_per_epoch_after_vote == current_vedxlyn_power,
            0x13
        );
        assert!(
            btc_usdt_pool_votes_after_vote == current_vedxlyn_power,
            0x14
        );
        assert!(
            last_voted_after == voter::epoch_timestamp() + 1,
            0x15
        );
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE, location = voter)]
    fun test_voting_clmm_whitelist_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        //check lp token is not whitelisted yet
        assert!(!voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        //Whitelist Lp
        create_account_for_test(address_of(alice));
        voter::whitelist_clmm_pool(alice, btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = voter::ERROR_POOL_ALREADY_WHITELISTED, location = voter
    )]
    fun test_voting_clmm_whitelist_already_whitelisted(
        dev: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        // Try whitelisting again
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_POOL_NOT_EXISTS, location = voter)]
    fun test_voting_clmm_whitelist_pool_not_exists(
        dev: &signer
    ) {
        // Initialize without registering the pool
        setup_test(dev);
        voter::whitelist_clmm_pool(dev, @0x1223);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_blacklist_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Blacklist the pool
        let pools = vector::singleton(btc_usdc_pool_address);
        voter::blacklist(dev, pools);

        // Verify pool is no longer whitelisted
        assert!(!voter::is_pool_whitelisted(btc_usdc_pool_address), 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE, location = voter)]
    fun test_voting_clmm_blacklist_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        account::create_account_for_test(address_of(alice));
        let pools = vector::singleton(btc_usdc_pool_address);

        //Trying to blacklist pool using non governance account
        voter::blacklist(alice, pools);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_POOL_NOT_WHITELISTED, location = voter)]
    fun test_voting_clmm_blacklist_non_whitelisted(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let pools = vector::singleton(btc_usdc_pool_address);

        //Should faild becuase pool is not whitelisted before blacklisting
        voter::blacklist(dev, pools);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_kill_gauge_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);
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

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE, location = voter)]
    fun test_voting_clmm_kill_gauge_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);

        account::create_account_for_test(address_of(alice));
        voter::kill_gauge(alice, gauge_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_ALREADY_KILLED, location = voter)]
    fun test_voting_clmm_kill_gauge_already_killed(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);

        voter::kill_gauge(dev, gauge_address);
        voter::kill_gauge(dev, gauge_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_clmm_kill_gauge_non_existent(
        dev: &signer
    ) {
        setup_test(dev);

        let non_existent_gauge = @0x999;
        voter::kill_gauge(dev, non_existent_gauge);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_revive_gauge_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);
        // Kill gauge first
        voter::kill_gauge(dev, gauge_address);
        assert!(!voter::is_gauge_alive(gauge_address), 0x1);
        assert!(voter::is_gauge_valid(gauge_address), 0x2);

        // Revive gauge
        voter::revive_gauge(dev, gauge_address);

        // Verify gauge is alive
        assert!(voter::is_gauge_alive(gauge_address), 0x3);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_GOVERNANCE, location = voter)]
    fun test_voting_clmm_revive_gauge_non_governance(
        dev: &signer, alice: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);

        voter::kill_gauge(dev, gauge_address);
        account::create_account_for_test(address_of(alice));
        voter::revive_gauge(alice, gauge_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_ALIVE, location = voter)]
    fun test_voting_clmm_revive_gauge_already_alive(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);

        voter::revive_gauge(dev, gauge_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST)]
    fun test_voting_clmm_revive_gauge_non_existent(
        dev: &signer
    ) {
        setup_test(dev);

        let non_existent_gauge = @0x999;
        voter::revive_gauge(dev, non_existent_gauge);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_vote_single_pool(
        dev: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);

        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
        assert!(voter::weights(btc_usdc_pool_address) == power, 0x2);
        assert!(voter::total_weight() == power, 0x3);
        assert!(voter::get_votes(nft_token_address, btc_usdc_pool_address) == power, 0x4);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x5
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_vote_precision(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usdt_pool_address) =
            create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::whitelist_clmm_pool(dev, usdc_usdt_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usdt_pool_address), 0x2);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address, usdc_usdt_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 1 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 1 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_vote =
            voter::weights(usdc_usdt_pool_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, usdc_usdt_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_vote == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(dev_btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(dev_usdc_usdt_pool_votes_before_vote == 0, 0x8);
        assert!(dev_last_voted_before == 0, 0x9);

        let pool_weight_to_vote = vector[33, 67];
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        // Vote 33% to BTC/USDT, 67% to USDC/USDT
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_vote = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_after_vote =
            voter::weights(usdc_usdt_pool_address);
        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let dev_btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, usdc_usdt_pool_address);
        let dev_last_voted_after = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 2, 0x10);
        // 33% of dev veDxlyn power to btc-usdt pool
        assert!(
            btc_usdt_pool_weight_after_vote == dev_current_vedxlyn_power * 33 / 100,
            0x11
        );
        // 67% of dev veDxlyn power to usdc-usdt pool
        assert!(
            usdc_usdt_pool_weight_after_vote == dev_current_vedxlyn_power * 67 / 100,
            0x12
        );
        // Total vote for current epoch is total of dev total power
        assert!(
            current_total_weights_per_epoch_after_vote == dev_current_vedxlyn_power,
            0x13
        );
        assert!(
            dev_btc_usdt_pool_votes_after_vote == dev_current_vedxlyn_power * 33 / 100,
            0x14
        );
        assert!(
            dev_usdc_usdt_pool_votes_after_vote == dev_current_vedxlyn_power * 67 / 100,
            0x15
        );
        assert!(
            dev_last_voted_after == voter::epoch_timestamp() + 1,
            0x16
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY, location = voter)]
    fun test_voting_clmm_vote_with_voting_delay(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        //Set voting delay to 2 dyas
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        //Should fail becuase voting delay is not pass
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_vote_after_voting_delay(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        //Set voting delay to 2 dyas
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        dxlyn_coin::mint(dev, address_of(dev), 1 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);

        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
        assert!(voter::weights(btc_usdc_pool_address) == power, 0x2);
        assert!(voter::total_weight() == power, 0x3);
        assert!(voter::get_votes(nft_token_address, btc_usdc_pool_address) == power, 0x4);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x5
        );

        //fast forward time to 3 days
        timestamp::fast_forward_seconds(3 * DAY);
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);

        //fetch new power becuas of we fast forwarded time so new power is also changed
        let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        //Same for vote cast twice in week
        assert!(voter::pool_vote_length(nft_token_address) == 1, 0x6);
        assert!(voter::weights(btc_usdc_pool_address) == power, 0x7);
        assert!(voter::total_weight() == power, 0x8);
        assert!(voter::get_votes(nft_token_address, btc_usdc_pool_address) == power, 0x9);
        assert!(
            voter::get_last_voted(nft_token_address) == voter::epoch_timestamp() + 1,
            0x10
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH, location = voter
    )
    ]
    fun test_voting_clmm_vote_lenght_of_pool_and_weigh_mismatch(
        dev: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(
            dev,
            nft_token_address,
            vector[btc_usdc_pool_address],
            vector[100, 100]
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_vote_mixed_gauges(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Kill USDC/USDT gauge
        let gauge_usdc_usdt = voter::get_gauge_for_pool(usdc_usct_pool_address);
        voter::kill_gauge(dev, gauge_usdc_usdt);

        // Mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_vote = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_vote =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_before_vote = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_vote =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_vote == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_vote == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_vote == 0, 0x6);
        assert!(dev_btc_usdt_pool_votes_before_vote == 0, 0x7);
        assert!(dev_usdc_usdt_pool_votes_before_vote == 0, 0x8);
        assert!(dev_last_voted_before == 0, 0x9);

        let pool_weight_to_vote = vector[50, 50];
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        // Vote 50% to BTC/USDT, 50% to USDC/USDT (inactive gauge)
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_vote = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_after_vote =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_after_vote = voter::total_weight();
        let dev_btc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_after_vote =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_after = voter::get_last_voted(nft_token_address);

        // Check voted on any pool or not
        assert!(voted_on_pools == 1, 0x10);
        // 100% of dev veDxlyn power to btc-usdt pool (due to inactive USDC/USDT gauge)
        assert!(btc_usdt_pool_weight_after_vote == dev_current_vedxlyn_power, 0x11);
        // No votes to usdc-usdt pool
        assert!(usdc_usdt_pool_weight_after_vote == 0, 0x12);
        // Total vote for current epoch is total of dev total power
        assert!(
            current_total_weights_per_epoch_after_vote == dev_current_vedxlyn_power,
            0x12
        );
        assert!(dev_btc_usdt_pool_votes_after_vote == dev_current_vedxlyn_power, 0x13);
        assert!(dev_usdc_usdt_pool_votes_after_vote == 0, 0x14);
        assert!(
            dev_last_voted_after == voter::epoch_timestamp() + 1,
            0x15
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO, location = voter
    )
    ]
    fun test_votingV3_clmm_vote_with_zero_weight(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock for one week
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[0]);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO, location = voter
    )
    ]
    fun test_voting_clmm_vote_with_no_vedxlyn_power(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        // Whitelist the pool
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        //mint 100 DXLYN and create lock max time
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Fast forward time to ensure no veDxlyn power
        timestamp::fast_forward_seconds(MAXTIME + 1);

        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_reset_success(
        dev: &signer
    ) {
        setup_test(dev);


        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];

        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_reset =
            voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_reset =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_before_reset = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 2, 0x3);
        assert!(
            btc_usdt_pool_weight_before_reset == dev_current_vedxlyn_power / 2,
            0x4
        );
        assert!(
            usdc_usdt_pool_weight_before_reset == dev_current_vedxlyn_power / 2,
            0x5
        );
        assert!(
            current_total_weights_per_epoch_before_reset == dev_current_vedxlyn_power,
            0x6
        );
        assert!(
            dev_btc_usdt_pool_votes_before_reset == dev_current_vedxlyn_power / 2,
            0x7
        );
        assert!(
            dev_usdc_usdt_pool_votes_before_reset == dev_current_vedxlyn_power / 2,
            0x8
        );
        assert!(
            dev_last_voted_before == voter::epoch_timestamp() + 1,
            0x9
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);

        // Reset votes
        voter::reset(dev, nft_token_address);

        // Post-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_after_reset = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_after_reset =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_after_reset = voter::total_weight();
        let dev_btc_usdt_pool_votes_after_reset =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_after_reset =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_after = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x9);
        assert!(btc_usdt_pool_weight_after_reset == 0, 0x10);
        assert!(usdc_usdt_pool_weight_after_reset == 0, 0x11);
        assert!(current_total_weights_per_epoch_after_reset == 0, 0x12);
        assert!(dev_btc_usdt_pool_votes_after_reset == 0, 0x13);
        assert!(dev_usdc_usdt_pool_votes_after_reset == 0, 0x14);
        assert!(
            dev_last_voted_after == voter::epoch_timestamp() + 1,
            0x14
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTES_NOT_FOUND, location = voter)]
    fun test_voting_clmm_reset_no_votes(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_reset =
            voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_reset =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_before_reset = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_reset =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_reset == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_reset == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_reset == 0, 0x6);
        assert!(dev_btc_usdt_pool_votes_before_reset == 0, 0x7);
        assert!(dev_usdc_usdt_pool_votes_before_reset == 0, 0x8);
        assert!(dev_last_voted_before == 0, 0x9);

        // Reset votes
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::reset(dev, nft_token_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY, location = voter)]
    fun test_voting_clmm_reset_same_epoch(
        dev: &signer
    )
    {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-reset state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        // Attempt to reset in same epoch
        voter::reset(dev, nft_token_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_update_same_epoch(
        dev: &signer
    )
    {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[btc_usdc_pool_address];
        voter::create_gauges(dev, pools);

        let user_address = @0x123;
        let user = &create_account_for_test(user_address);

        // Register
        dxlyn_coin::register_and_mint(dev, user_address, get_quants(10));

        // Set unlock time
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + MAXTIME;

        // Create lock
        voting_escrow::create_lock(user, get_quants(5), unlock_time);

        // Vote 100%
        let pool_weight_to_vote = vector[100];
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(user, nft_token_address, pools, pool_weight_to_vote);

        // Vot within the same epoch
        let pre_user_balance = dxlyn_coin::balance_of(user_address);
        timestamp::fast_forward_seconds(DAY * 6);
        voter::vote(user, nft_token_address, pools, pool_weight_to_vote);

        let after_vote_penalty_balance = dxlyn_coin::balance_of(user_address);
        let expected_fee = get_edit_vote_penalty();
        assert!(pre_user_balance - expected_fee == after_vote_penalty_balance, 1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_update_same_epoch_penalty(
        dev: &signer
    )
    {
        setup_test(dev);

        let prev_vote_penalty = voter::get_edit_vote_penalty();
        voter::set_edit_vote_penalty(dev, 10 * DXLYN_DECIMAL);

        let after_change_vote_penalty = voter::get_edit_vote_penalty();
        assert!(prev_vote_penalty != after_change_vote_penalty, 1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO, location = voter)]
    fun test_voting_clmm_update_same_epoch_penalty_with_zero_penalty(dev: &signer) {
        setup_test(dev);
        voter::set_edit_vote_penalty(dev, 0);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_NOT_VOTER_ADMIN)]
    fun test_voting_clmm_update_unauthorised_same_epoch_penalty(
        dev: &signer
    )
    {
        setup_test(dev);
        let unauthorised = &create_account_for_test(@0x123);
        voter::set_edit_vote_penalty(unauthorised, 10 * DXLYN_DECIMAL);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_poke_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_poke = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_poke =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_before_poke = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 2, 0x3);
        assert!(
            btc_usdt_pool_weight_before_poke == dev_current_vedxlyn_power / 2,
            0x4
        );
        assert!(
            usdc_usdt_pool_weight_before_poke == dev_current_vedxlyn_power / 2,
            0x5
        );
        assert!(
            current_total_weights_per_epoch_before_poke == dev_current_vedxlyn_power,
            0x6
        );
        assert!(
            dev_btc_usdt_pool_votes_before_poke == dev_current_vedxlyn_power / 2,
            0x7
        );
        assert!(
            dev_usdc_usdt_pool_votes_before_poke == dev_current_vedxlyn_power / 2,
            0x8
        );
        assert!(
            dev_last_voted_before == voter::epoch_timestamp() + 1,
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
        let btc_usdt_pool_weight_after_poke = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_after_poke =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_after_poke = voter::total_weight();
        let dev_btc_usdt_pool_votes_after_poke =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_after_poke =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_after = voter::get_last_voted(nft_token_address);

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
            dev_btc_usdt_pool_votes_after_poke == new_vedxlyn_power / 2,
            0x14
        );
        assert!(
            dev_usdc_usdt_pool_votes_after_poke == new_vedxlyn_power / 2,
            0x15
        );
        assert!(
            dev_last_voted_after == voter::epoch_timestamp() + 1,
            0x16
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTES_NOT_FOUND, location = voter)]
    fun test_voting_clmm_poke_no_votes(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        let btc_usdt_pool_weight_before_poke = voter::weights(btc_usdc_pool_address);
        let usdc_usdt_pool_weight_before_poke =
            voter::weights(usdc_usct_pool_address);
        let current_total_weights_per_epoch_before_poke = voter::total_weight();
        let dev_btc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, btc_usdc_pool_address);
        let dev_usdc_usdt_pool_votes_before_poke =
            voter::get_votes(nft_token_address, usdc_usct_pool_address);
        let dev_last_voted_before = voter::get_last_voted(nft_token_address);

        assert!(voted_on_pools == 0, 0x3);
        assert!(btc_usdt_pool_weight_before_poke == 0, 0x4);
        assert!(usdc_usdt_pool_weight_before_poke == 0, 0x5);
        assert!(current_total_weights_per_epoch_before_poke == 0, 0x6);
        assert!(dev_btc_usdt_pool_votes_before_poke == 0, 0x7);
        assert!(dev_usdc_usdt_pool_votes_before_poke == 0, 0x8);
        assert!(dev_last_voted_before == 0, 0x9);

        // Poke without votes
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::poke(dev, nft_token_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_VOTE_DELAY, location = voter)]
    fun test_voting_clmm_poke_same_epoch(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Set voting delay
        voter::set_voter_delay(dev, 2 * DAY);

        // Create gauges
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint 100 DXLYN and create lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Vote 50/50
        let pool_weight_to_vote = vector[50, 50];
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        voter::vote(dev, nft_token_address, pools, pool_weight_to_vote);

        // Pre-poke state checks
        let voted_on_pools = voter::pool_vote_length(nft_token_address);
        assert!(voted_on_pools == 2, 0x3);

        // Attempt to poke in same epoch
        voter::poke(dev, nft_token_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_create_gauge_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Verify gauge creation
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);
        assert!(voter::is_gauge_for_pool(btc_usdc_pool_address), 0x2);
        assert!(voter::get_gauge_for_pool(btc_usdc_pool_address) == gauge_address, 0x3);
        assert!(voter::get_pool_for_gauge(gauge_address) == btc_usdc_pool_address, 0x4);
        assert!(voter::is_gauge_valid(gauge_address), 0x5);
        assert!(voter::is_gauge_alive(gauge_address), 0x6);
        assert!(voter::is_pool_in_pools(btc_usdc_pool_address), 0x7);
        assert!(voter::get_supply_index(gauge_address) == 0, 0x8);
        assert!(
            voter::get_external_bribe(gauge_address)
                == voter::get_external_bribe_address(btc_usdc_pool_address),
            0x9
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_create_gauges_success(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x2);

        // Create gauges for one pool
        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Verify gauge creation
        let gauge_address = gauge_clmm::get_gauge_address(btc_usdc_pool_address);
        assert!(voter::is_gauge_for_pool(btc_usdc_pool_address), 0x2);
        assert!(
            voter::get_gauge_for_pool(btc_usdc_pool_address) == gauge_address,
            0x3
        );
        assert!(
            voter::get_pool_for_gauge(gauge_address) == btc_usdc_pool_address,
            0x4
        );
        assert!(voter::is_gauge_alive(gauge_address), 0x6);
        assert!(voter::is_gauge_valid(gauge_address), 0x5);
        assert!(voter::is_pool_in_pools(btc_usdc_pool_address), 0x7);
        assert!(voter::get_supply_index(gauge_address) == 0, 0x8);
        assert!(
            voter::get_external_bribe(gauge_address)
                == voter::get_external_bribe_address(btc_usdc_pool_address),
            0x9
        );
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_OWNER, location = voter)]
    fun test_voting_clmm_create_gauge_non_owner(
        dev: &signer, alice: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        account::create_account_for_test(address_of(alice));
        voter::create_gauge(alice, btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_GAUGE_ALREADY_EXIST_FOR_POOL, location = voter
    )
    ]
    fun test_voting_clmm_create_gauge_already_exists(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_POOL_NOT_WHITELISTED, location = voter)]
    fun test_voting_clmm_create_gauge_not_whitelisted(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::create_gauge(dev, btc_usdc_pool_address);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_votingV3_clmm_get_external_bribe_address(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        let expected_bribe_address = voter::get_external_bribe_address(btc_usdc_pool_address);
        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, btc_usdc_pool_address);

        let bribe_address = voter::get_external_bribe_address(btc_usdc_pool_address);
        assert!(bribe_address == expected_bribe_address, 0x1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_length(dev: &signer) {
        setup_test(dev);

        // Initially, no pools
        assert!(voter::length() == 0, 0x1);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        assert!(voter::is_pool_whitelisted(btc_usdc_pool_address), 0x1);

        // Create gauge
        voter::create_gauge(dev, btc_usdc_pool_address);

        assert!(voter::length() == 1, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_pool_vote_length(
        dev: &signer
    ) {
        setup_test(dev);

        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);


        // No votes initially
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);

        let pools = vector[btc_usdc_pool_address, usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote for both pool
        voter::vote(
            dev,
            nft_token_address,
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        assert!(voter::pool_vote_length(nft_token_address) == 2, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_weights(
        dev: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        // No votes initially
        assert!(voter::weights(btc_usdc_pool_address) == 0, 0x1);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        assert!(
            voter::weights(btc_usdc_pool_address) == dev_current_vedxlyn_power,
            0x2
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_weights_at(
        dev: &signer
    ) {
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        let initial_epoch = voter::epoch_timestamp();

        // No votes initially
        assert!(voter::weights_at(btc_usdc_pool_address, initial_epoch) == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote in initial epoch
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        assert!(
            voter::weights_at(btc_usdc_pool_address, initial_epoch)
                == dev_current_vedxlyn_power,
            0x2
        );

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let next_epoch = voter::epoch_timestamp();

        // No votes in next epoch
        assert!(voter::weights_at(btc_usdc_pool_address, next_epoch) == 0, 0x3);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_total_weight(
        dev: &signer
    ) {
        setup_test(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        // No votes initially
        assert!(voter::total_weight() == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        assert!(voter::total_weight() == dev_current_vedxlyn_power, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_total_weight_at(
        dev: &signer
    ) {
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);


        let initial_epoch = voter::epoch_timestamp();

        // No votes initially
        assert!(voter::total_weight_at(initial_epoch) == 0, 0x1);

        // Whitelist pool and create gauge
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Mint and lock tokens
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);

        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote in initial epoch
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        assert!(voter::total_weight_at(initial_epoch) == dev_current_vedxlyn_power, 0x2);

        // Fast forward to next epoch
        timestamp::fast_forward_seconds(WEEK);

        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let next_epoch = voter::epoch_timestamp();

        // No votes in next epoch
        assert!(voter::total_weight_at(next_epoch) == 0, 0x3);
    }

    #[
    test(
        dev = @dexlyn_tokenomics,
        supra_framework = @supra_framework,
        minter = @dexlyn_tokenomics
    )
    ]
    fun test_voting_clmm_notify_reward_success(
        dev: &signer, minter: &signer
    ) {
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let minter_address = address_of(minter);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);

        // Mint and lock tokens for dev
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_current_vedxlyn_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
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

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_notify_reward_zero_weight(
        dev: &signer
    ) {
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let minter_address = address_of(dev);

        // No votes, so total weight is 0
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
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

    #[test(
        dev = @dexlyn_tokenomics, non_minter = @0x456
    )]
    #[expected_failure(abort_code = voter::ERROR_NOT_MINTER, location = voter)]
    fun test_voting_clmm_notify_reward_non_minter(
        dev: &signer, non_minter: &signer
    ) {
        setup_test(dev);

        let non_minter_address = address_of(non_minter);
        account::create_account_for_test(non_minter_address);

        // Mint DXLYN for non-minter
        dxlyn_coin::register_and_mint(dev, non_minter_address, 1000 * DXLYN_DECIMAL);

        // Attempt to notify reward as non-minter
        voter::notify_reward_amount(non_minter, 500 * DXLYN_DECIMAL);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = voter::ERROR_INSUFFICIENT_DXLYN_COIN, location = voter
    )]
    fun test_voting_clmm_notify_reward_insufficient_balance(
        dev: &signer
    ) {
        setup_test(dev);

        // Attempt to notify reward with amount > balance
        voter::notify_reward_amount(dev, INITIAL_SUPPLY * DXLYN_DECIMAL + 100);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_all_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);
        let gauge_btc_usdt = voter::get_gauge_for_pool(btc_usdc_pool_address);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(usdc_usct_pool_address);

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_usdc_usdt);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x4);
        assert!(gauge_usdc_usdt_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        timestamp::fast_forward_seconds(DAY * 2);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
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
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_usdc_usdt);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_btc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_usdc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_all_no_pools(
        dev: &signer
    ) {
        // Initialize test environment without pools
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        timestamp::fast_forward_seconds(DAY * 2);

        let dxlyn_minter = minter::get_minter_object_address();
        ();
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

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_all_killed_gauge(
        dev: &signer
    ) {
        // Initialize test environment with a pool
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);

        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_btc_usdt = voter::get_gauge_for_pool(btc_usdc_pool_address);

        // Mint and lock DXLYN tokens for voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());


        // Vote for the pool
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1);

        // Move to next epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Notify rewards to generate claimable amount
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 500 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Kill the gauge to prevent reward distribution
        voter::kill_gauge(dev, gauge_btc_usdt);
        assert!(!voter::is_gauge_alive(gauge_btc_usdt), 0x2);

        // Check gauge state before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);

        assert!(btc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x4);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x5);

        // Distribute rewards (should skip killed gauge)
        timestamp::fast_forward_seconds(DAY * 2);
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_all(dev);

        // Check gauge state after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let claimable = voter::get_claimable(gauge_btc_usdt);
        let (_, _, _, _, index, _, _) = voter::get_voter_state();

        // Verify no rewards distributed and state unchanged
        assert!(btc_usdt_pool_balance_after == 0, 0x6);
        assert!(gauge_btc_usdt_distribution_time_after == 0, 0x7);
        assert!(btc_usdt_gauge_supply_index_after == index, 0x8);
        assert!(claimable == 0, 0x9);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_all_zero_claimable(
        dev: &signer
    ) {
        // Initialize test environment with a pool
        setup_test(dev);

        // Allow checkpoint token for distribution
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward timer to allow check pointing
        timestamp::fast_forward_seconds(DAY * 2);

        // Set up DXLYN minter and voter
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        let gauge_btc_usdt = voter::get_gauge_for_pool(btc_usdc_pool_address);

        // Mint and lock DXLYN tokens for voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        // Get the token address and object
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());


        // Vote for the pool
        voter::vote(dev, nft_token_address, vector[btc_usdc_pool_address], vector[100]);
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1);

        // Check gauge state before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);
        let claimable = voter::get_claimable(gauge_btc_usdt);

        // Verify no rewards available
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x3);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x4);
        assert!(claimable == 0, 0x5);

        // Distribute rewards (should do nothing) because update period is not called
        voter::distribute_all(dev);

        // Check gauge state after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let final_claimable = voter::get_claimable(gauge_btc_usdt);

        // Verify no rewards distributed and state unchanged
        assert!(btc_usdt_pool_balance_after == 0, 0x6);
        assert!(gauge_btc_usdt_distribution_time_after == 0, 0x7);
        assert!(btc_usdt_gauge_supply_index_after == 0, 0x8);
        assert!(final_claimable == 0, 0x9);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_range_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);
        let gauge_btc_usdt = voter::get_gauge_for_pool(btc_usdc_pool_address);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(usdc_usct_pool_address);

        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        let (nft_token_address, _) = get_nft_token_address(1);
        let dev_voting_power =
            voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

        // Vote equally for both pools (50% each)
        voter::vote(
            dev,
            nft_token_address,
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_usdc_usdt);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x4);
        assert!(gauge_usdc_usdt_distribution_time_before == 0, 0x5);
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

        let expected_share_per_pool =
            (((dev_voting_power as u256) / (2 as u256)) * (expected_index as u256)
                / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_usdc_usdt);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_btc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_usdc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_START_MUST_BE_LESS_THEN_FINISH, location = voter
    )
    ]
    fun test_voting_clmm_distribute_range_start_not_less_than_finish(
        dev: &signer
    ) {
        // Initialize test environment
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        timestamp::fast_forward_seconds(DAY * 2);

        // Attempt to distribute with invalid range (start >= finish)
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);

        voter::distribute_range(dev, 2, 1);

        // Expect ERROR_START_MUST_BE_LESS_THEN_FINISH (0x19)
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_distribute_gauges_success(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);
        let gauge_btc_usdt = voter::get_gauge_for_pool(btc_usdc_pool_address);
        let gauge_usdc_usdt = voter::get_gauge_for_pool(usdc_usct_pool_address);

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_usdc_usdt);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x4);
        assert!(gauge_usdc_usdt_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        // Distribute rewards to all gauges
        timestamp::fast_forward_seconds(DAY * 2);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::distribute_gauges(dev, vector[gauge_btc_usdt, gauge_usdc_usdt]);

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

        let expected_share_per_pool =
            (((dev_voting_power as u256) / (2 as u256)) * (expected_index as u256)
                / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(btc_usdc_pool_address)
            );
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(
                gauge_clmm::get_gauge_address(usdc_usct_pool_address)
            );
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_usdc_usdt);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);
        assert!(gauge_btc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_usdc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST, location = voter)]
    fun test_voting_clmm_distribute_gauges_start_not_less_than_finish(
        dev: &signer
    ) {
        // Initialize test environment
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);

        timestamp::fast_forward_seconds(DAY * 2);

        // Attempt to distribute with invalid gauge addresses
        voter::distribute_gauges(dev, vector[@0x1, @0x2]);
    }

    // claim_emission
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_claim_emission(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);

        fee_distributor::toggle_allow_checkpoint_token(dev);

        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);
        let gauge_btc_usdt = gauge_clmm::get_gauge_address(btc_usdc_pool_address);
        let gauge_usdc_usdt = gauge_clmm::get_gauge_address(usdc_usct_pool_address);

        //Stake BTC-USDT to gauge
        let token1 =
            add_liquidity(
                btc_usdc_pool_address,
                dev,
                1
            );
        gauge_clmm::deposit(dev, gauge_btc_usdt, token1);

        //Stake USDC-USDT to gauge
        let token2 =
            add_liquidity(
                usdc_usct_pool_address,
                dev,
                2
            );
        gauge_clmm::deposit(dev, gauge_usdc_usdt, token2);

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        // let dxlyn_minter = dxlyn_coin::get_dxlyn_object_address();
        // voter::set_minter(dev, dxlyn_minter);
        // voter::update_period();

        // // Mint DXLYN for rewards and notify to update voter contract index
        // dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        // let reward_amount = 30 * DXLYN_DECIMAL;
        // voter::set_minter(dev, dev_address);
        // voter::notify_reward_amount(dev, reward_amount);

        // Check gauge states before distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(gauge_btc_usdt);
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_before) =
            gauge_clmm::get_gauge_state(gauge_usdc_usdt);

        let gauge_btc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_before =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let btc_usdt_gauge_supply_index_before = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_before =
            voter::get_supply_index(gauge_usdc_usdt);

        // Verify initial gauge states are zero
        assert!(btc_usdt_pool_balance_before == 0, 0x2);
        assert!(usdc_usdt_pool_balance_before == 0, 0x3);
        assert!(gauge_btc_usdt_distribution_time_before == 0, 0x4);
        assert!(gauge_usdc_usdt_distribution_time_before == 0, 0x5);
        assert!(btc_usdt_gauge_supply_index_before == 0, 0x6);
        assert!(usdc_usdt_gauge_supply_index_before == 0, 0x7);

        // Distribute rewards to all gauges
        timestamp::fast_forward_seconds(DAY * 2);
        voter::distribute_all(dev);

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

        let expected_share_per_pool =
            (((dev_voting_power as u256) / (2 as u256)) * (expected_ratio as u256)
                / (DXLYN_DECIMAL as u256) as u64); // 50% weight per pool

        // Check gauge states after distribution
        let (_, _, _, _, _, _, _, _, _, _, btc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(gauge_btc_usdt);
        let (_, _, _, _, _, _, _, _, _, _, usdc_usdt_pool_balance_after) =
            gauge_clmm::get_gauge_state(gauge_usdc_usdt);
        let gauge_btc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_btc_usdt);
        let gauge_usdc_usdt_distribution_time_after =
            voter::get_gauges_distribution_timestamp(gauge_usdc_usdt);
        let (_, _, _, _, index_after, _, _) = voter::get_voter_state();
        let btc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_btc_usdt);
        let usdc_usdt_gauge_supply_index_after = voter::get_supply_index(gauge_usdc_usdt);

        // Verify gauges received expected rewards and state updates
        assert!(btc_usdt_pool_balance_after == expected_share_per_pool, 0x8);
        assert!(usdc_usdt_pool_balance_after == expected_share_per_pool, 0x9);

        assert!(gauge_btc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x10);
        assert!(
            gauge_usdc_usdt_distribution_time_after == voter::epoch_timestamp(), 0x11
        );
        assert!(btc_usdt_gauge_supply_index_after == index_after, 0x12);
        assert!(usdc_usdt_gauge_supply_index_after == index_after, 0x13);

        let balance_before_claim = dxlyn_coin::balance_of(dev_address);

        // Fast forward to week end to allow claiming rewards
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + WEEK);

        let expected_claimable = gauge_clmm::earned(gauge_btc_usdt, dev_address);

        // Dev stacked lp for one week, so they can claim rewards
        voter::claim_emission(dev, vector[gauge_btc_usdt, gauge_usdc_usdt]);

        let balance_after_claim = dxlyn_coin::balance_of(dev_address);

        assert!(
            balance_after_claim == balance_before_claim + (expected_claimable * 2),
            0x14
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_claim_bribe(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        //TODO:Add USDT as a reward token to bribe mock will shif to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, btc_usdc_pool_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(
            dev,
            btc_usdc_pool_address,
            usdt_metadata,
            reward
        );

        //Stake BTC-USDT to gauge
        let token1 =
            add_liquidity(
                btc_usdc_pool_address,
                dev,
                1
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(btc_usdc_pool_address), token1
        );

        //Stake USDC-USDT to gauge
        let token2 =
            add_liquidity(
                usdc_usct_pool_address,
                dev,
                2
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(usdc_usct_pool_address), token2
        );

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        let dev_votes = voter::get_votes(nft_token_address, btc_usdc_pool_address);

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(btc_usdc_pool_address);

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
            vector[btc_usdc_pool_address],
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

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_claim_bribes_no_rewards(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);

        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        //TODO:Add USDT as a reward token to bribe mock will shif to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, btc_usdc_pool_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        //Stake BTC-USDT to gauge
        let token1 =
            add_liquidity(
                btc_usdc_pool_address,
                dev,
                1
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(btc_usdc_pool_address), token1
        );

        //Stake USDC-USDT to gauge
        let token2 =
            add_liquidity(
                usdc_usct_pool_address,
                dev,
                2
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(usdc_usct_pool_address), token2
        );

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        // // Mint DXLYN for rewards and notify to update voter contract index
        // dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        // let reward_amount = 30 * DXLYN_DECIMAL;
        // voter::set_minter(dev, dev_address);
        // voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);

        //17473536001
        //1747526400

        // 1747267200
        // 1747440000
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribes(
            dev,
            vector[btc_usdc_pool_address],
            vector[vector[usdt_metadata]]
        );

        let dev_usdt_balance_after_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(dev_usdt_balance_after_claim == dev_usdt_balance_before_claim, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH, location = voter
    )
    ]
    fun test_voting_clmm_claim_bribes_length_not_match(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);

        // Get dev address and pool addresses
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        // Claim bribes for the pool
        voter::claim_bribes(dev, vector[btc_usdc_pool_address], vector[]);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_claim_bribe_for_user(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        //TODO:Add USDT as a reward token to bribe mock will shif to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, btc_usdc_pool_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(
            dev,
            btc_usdc_pool_address,
            usdt_metadata,
            reward
        );

        //Stake BTC-USDT to gauge
        let token1 =
            add_liquidity(
                btc_usdc_pool_address,
                dev,
                1
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(btc_usdc_pool_address), token1
        );

        //Stake USDC-USDT to gauge
        let token2 =
            add_liquidity(
                usdc_usct_pool_address,
                dev,
                2
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(usdc_usct_pool_address), token2
        );

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        let dev_votes = voter::get_votes(nft_token_address, btc_usdc_pool_address);

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(btc_usdc_pool_address);

        // Mint DXLYN for rewards and notify to update voter contract index
        dxlyn_coin::register_and_mint(dev, dev_address, 1000 * DXLYN_DECIMAL);
        let reward_amount = 30 * DXLYN_DECIMAL;
        voter::set_minter(dev, dev_address);
        voter::notify_reward_amount(dev, reward_amount);

        // Fast forward to next epoch to allow bribe claiming
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes rewards for a specific address
        voter::claim_bribes_for_address(
            dev_address,
            vector[btc_usdc_pool_address],
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

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voting_clmm_claim_bribes_for_address_no_rewards(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        //TODO:Add USDT as a reward token to bribe mock will shif to create gauge itself
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(
            dev, btc_usdc_pool_address, usdt_metadata
        );

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);

        //Stake BTC-USDT to gauge
        let token1 =
            add_liquidity(
                btc_usdc_pool_address,
                dev,
                1
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(btc_usdc_pool_address), token1
        );

        //Stake USDC-USDT to gauge
        let token2 =
            add_liquidity(
                usdc_usct_pool_address,
                dev,
                2
            );
        gauge_clmm::deposit(
            dev, gauge_clmm::get_gauge_address(usdc_usct_pool_address), token2
        );

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
            vector[btc_usdc_pool_address, usdc_usct_pool_address],
            vector[50, 50]
        );
        let total_weight = voter::total_weight();
        assert!(total_weight == dev_voting_power, 0x1); // Verify total voting weight matches dev's power

        // Move to next epoch to record weights for the previous epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        ();
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
        ();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let dev_usdt_balance_before_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Claim bribes for the pool
        voter::claim_bribes_for_address(
            dev_address,
            vector[btc_usdc_pool_address],
            vector[vector[usdt_metadata]]
        );

        let dev_usdt_balance_after_claim =
            test_internal_coins::get_user_usdt_balance(dev_address);

        // Verify dev's USDT balance increased by expected reward
        assert!(dev_usdt_balance_after_claim == dev_usdt_balance_before_claim, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = voter::ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH, location = voter
    )
    ]
    fun test_voting_clmm_claim_bribes_for_address_length_not_match(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test(dev);

        // Get dev address and pool addresses
        let dev_address = address_of(dev);
        let (_, _, _, btc_usdc_pool_address) = create_pool(dev);
        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        voter::whitelist_clmm_pool(dev, btc_usdc_pool_address);

        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);
        voter::create_gauge(dev, btc_usdc_pool_address);
        voter::create_gauge(dev, usdc_usct_pool_address);

        // Claim bribes for the pool
        voter::claim_bribes_for_address(
            dev_address, vector[btc_usdc_pool_address], vector[]
        );
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_clmm_gauge_multi_epoch(dev: &signer) {
        // ===========================================
        // INITIAL SETUP - Pool and Token Creation
        // ===========================================
        setup_test(dev);

        let (_, _, _, usdc_usct_pool_address) = create_pool2(dev);
        let clmm_token = add_liquidity(usdc_usct_pool_address, dev, 1);

        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Check LP tokens are not whitelisted yet
        assert!(!voter::is_pool_whitelisted(usdc_usct_pool_address), 0x1);

        // Whitelist both pool types
        voter::whitelist_clmm_pool(dev, usdc_usct_pool_address);

        // Verify pools are now whitelisted

        assert!(voter::is_pool_whitelisted(usdc_usct_pool_address), 0x1);

        // ===========================================
        // GAUGE CREATION AND BRIBE SETUP
        // ===========================================
        // Create gauges for both pools
        let pools = vector[usdc_usct_pool_address];
        voter::create_gauges(dev, pools);

        // Get gauge addresses
        let gauge_clmm = gauge_clmm::check_and_get_gauge_address(usdc_usct_pool_address);

        // Setup bribe rewards
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);

        // Add reward tokens to bribes
        bribe::add_reward_token(
            dev, usdc_usct_pool_address, usdc_metadata
        );

        // ===========================================
        // INITIAL VOTING LOCK AND DEPOSITS
        // ===========================================
        // Create voting escrow lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        let dev_address = address_of(dev);

        let clmm_gauge = gauge_clmm::get_gauge_address(usdc_usct_pool_address);
        gauge_clmm::deposit(dev, clmm_gauge, clmm_token);

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
                usdc_usct_pool_address,
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
                dev,
                nft_token_address,
                vector[usdc_usct_pool_address],
                current_voting_weights
            );
            let total_weight = voter::total_weight();

            // ===========================================
            // VOTING VERIFICATION
            // ===========================================
            assert!(voter::pool_vote_length(nft_token_address) == 1, 0x1);
            assert!(voter::weights(usdc_usct_pool_address) == clmm_power, 0x2);
            assert!(total_weight == clmm_power, 0x3);
            assert!(voter::get_votes(nft_token_address, usdc_usct_pool_address) == clmm_power, 0x4);

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
                    dev_address,
                    address_to_object<Metadata>(usdc_metadata)
                );

            // Get total supplies for reward calculation
            let total_clmm_supply =
                bribe::total_supply(usdc_usct_pool_address);

            // Fast forward another week to enable bribe claiming
            timestamp::fast_forward_seconds(WEEK);
            voter::distribute_all(dev);

            // Claim bribes for both pools
            voter::claim_bribes(
                dev,
                vector[usdc_usct_pool_address],
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
                    dev_address,
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
            gauge_clmm::get_reward(dev, gauge_clmm);

            // Verify gauge balances after claiming
            // let (_, _, _, _, _, _, _, _, _, _, cpmm_coin_bal_after) = gauge_cpmm::get_gauge_state(gauge_cpmm);
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
        let clmm_gauge = gauge_clmm::get_gauge_address(usdc_usct_pool_address);
        assert!(
            object::owner(address_to_object<Token>(clmm_token)) == clmm_gauge,
            0x98
        );
        gauge_clmm::withdraw(dev, clmm_gauge, clmm_token);
        assert!(
            object::owner(address_to_object<Token>(clmm_token)) == dev_address,
            0x97
        );

        // print_formatted(b"========== ALL EPOCHS COMPLETED SUCCESSFULLY", 0);
        // print_formatted(b"Total epochs tested", epoch_count);
        // print_formatted(b"All withdrawals completed", 1);
    }
}
