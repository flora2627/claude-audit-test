#[test_only]
module dexlyn_tokenomics::gauge_clmm_test {

    use std::signer::address_of;
    use std::string::utf8;
    use std::vector;

    use aptos_token_objects::token;
    use aptos_token_objects::token::Token;
    use dexlyn_clmm::clmm_router::{add_fee_tier, add_liquidity_fix_value};
    use dexlyn_clmm::factory;
    use dexlyn_clmm::pool::get_pool_liquidity;
    use dexlyn_clmm::position_nft;
    use dexlyn_clmm::test_helpers;
    use dexlyn_clmm::token_factory;
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account;
    use supra_framework::account::create_signer_for_test;
    use supra_framework::genesis;
    use supra_framework::object;
    use supra_framework::object::address_to_object;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_clmm;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // One week in seconds (7 days)
    const WEEK: u64 = 7 * 86400;

    // Precision factor for reward calculations, used to prevent overflow and maintain precision
    const PRECISION: u64 = 10000;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test setup function to initialize the environment
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        // timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    // Test setup function without genesis, but with liquidity pools registered
    fun setup_test_without_genesis_with_register_lp():
    (u64, address, address, address, address) {
        let dev = &create_signer_for_test(@dexlyn_clmm);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);

        setup_test_with_genesis(dev2);

        let (token_a_name, token_b_name) = (utf8(b"Token A"), utf8(b"Token B"));
        let token_a = test_helpers::setup_fungible_assets(dev, token_a_name, utf8(b"TA"));
        let token_b = test_helpers::setup_fungible_assets(dev, token_b_name, utf8(b"TB"));

        let tick_spacing = 200;
        let init_sqrt_price = 18446744073709551616; // at 0
        factory::init_factory_module(dev);
        add_fee_tier(dev, tick_spacing, 1000);
        let pool_address =
            factory::create_pool(
                dev,
                tick_spacing,
                init_sqrt_price,
                utf8(b""),
                token_a,
                token_b
            );

        let user_balance_a_before =
            token_factory::get_token_balance(dev, address_of(dev), token_a_name);
        let user_balance_b_before =
            token_factory::get_token_balance(dev, address_of(dev), token_b_name);

        // Position 1
        add_liquidity_fix_value(
            dev,
            pool_address,
            100000,
            100000,
            false,
            18446744073709549616, // -2000
            0, // 0
            true,
            0,
        );

        let pool_liquidity = get_pool_liquidity(pool_address);
        assert!(pool_liquidity == 0, 1001); // min[0.000000, 1050883.152001]

        let user_balance_a_after =
            token_factory::get_token_balance(dev, address_of(dev), token_a_name);
        let user_balance_b_after =
            token_factory::get_token_balance(dev, address_of(dev), token_b_name);

        assert!(
            (user_balance_a_before - user_balance_a_after) == 0,
            1002
        );
        assert!(
            (user_balance_b_before - user_balance_b_after) == 100000,
            1003
        );

        // Position 2
        add_liquidity_fix_value(
            dev,
            pool_address,
            100000,
            100000,
            true,
            18446744073709550616, // -1000
            16000,
            true,
            0,
        );

        let pool_liquidity2 = get_pool_liquidity(pool_address);
        assert!(pool_liquidity2 == 181602, 1004); // min[181602.549077, 2050516.626811]

        let user_balance_a_after2 =
            token_factory::get_token_balance(dev, address_of(dev), token_a_name);
        let user_balance_b_after2 =
            token_factory::get_token_balance(dev, address_of(dev), token_b_name);

        assert!(
            (user_balance_a_after - user_balance_a_after2) == 100000,
            1005
        ); // 99999.6976491452
        assert!(
            (user_balance_b_after - user_balance_b_after2) == 8857,
            1006
        ); // 8856.402217154447

        let collection = position_nft::collection_name(tick_spacing, token_a, token_b);
        let token_name = position_nft::position_name(1, 1);
        let token_address = token::create_token_address(&pool_address, &collection, &token_name);

        // Check is valid token for pool
        assert!((position_nft::is_valid_nft(token_address, pool_address)), 123);

        assert!(
            object::owner<Token>(address_to_object<Token>(token_address))
                == address_of(dev),
            11
        );

        (tick_spacing, token_a, token_b, pool_address, token_address)
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
        timestamp::update_global_time_for_test_secs(1746057600);
        account::create_account_for_test(address_of(dev));

        // Initialize DXLYN coin (platform token)
        test_internal_coins::init_coin(dev);

        // Initialize voting escrow (tracks locked tokens for voting power)
        voting_escrow::initialize(dev);

        fee_distributor::initialize(dev);

        // Initialize voter contract
        voter::initialize(dev);

        // Set active period to align with current epoch (week boundary)
        minter::set_active_period((timestamp::now_seconds() / WEEK) * WEEK);
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test 1: Initialize gauge contract and check initial state
    #[test(dev = @dexlyn_tokenomics)]
    fun test_clmm_initialize(dev: &signer) {
        setup_test_with_genesis(dev);

        let gauge_system_owner = gauge_clmm::get_gauge_system_owner();

        let dev_address = address_of(dev);

        assert!(gauge_system_owner == dev_address, 0x1);
    }

    // Test 2: Reinitialize gauge_clmm contract (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_clmm_reinitialize(dev: &signer) {
        setup_test_with_genesis(dev);

        gauge_clmm::initialize(dev);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test 1: Create a gauge for the BTC-USDT liquidity pool
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_create_gauge_clmm(dev: &signer) {
        let (_, _, _, pool_addr, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let expected_external_bribe_address =
            voter::get_external_bribe_address(pool_addr);

        gauge_clmm::test_create_gauge(
            dev_address,
            expected_external_bribe_address,
            pool_addr
        );

        let gauge_address = gauge_clmm::get_gauge_address(pool_addr);
        // Check if the gauge was created successfully
        let (
            emergency,
            _,
            distribution,
            external_bribe,
            duration,
            period_finish,
            reward_rate,
            last_update_time,
            reward_per_token_stored,
            total_supply,
            balance
        ) = gauge_clmm::get_gauge_state(gauge_address);

        assert!(!emergency, 0x1); // Emergency flag should be false
        assert!(distribution == dev_address, 0x4);
        assert!(external_bribe == expected_external_bribe_address, 0x5);
        assert!(duration == WEEK, 0x6); // Default duration is 1 day (86400 seconds)
        assert!(period_finish == 0, 0x7); // Initial period finish should be 0
        assert!(reward_rate == 0, 0x8); // Initial reward rate should be 0
        assert!(last_update_time == 0, 0x9); // Initial last update time should be 0
        assert!(reward_per_token_stored == 0, 0x10); // Initial reward per token stored should be 0
        assert!(total_supply == 0, 0x11); // Initial total supply should be 0
        assert!(balance == 0, 0x12); // Initial balance should be 0
    }

    // Test 2: Create a gauge for the BTC-USDT liquidity pool twice (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_ALREADY_EXIST, location = gauge_clmm
    )
    ]
    fun test_clmm_create_gauge_cl_twice(dev: &signer) {
        let (_, _, _, pool_address, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let expected_external_bribe_address =
            voter::get_external_bribe_address(pool_address);

        // Create a gauge v2 for the BTC-USDT liquidity pool
        gauge_clmm::test_create_gauge(
            dev_address,
            expected_external_bribe_address,
            pool_address
        );

        // Create a gauge v2 for the BTC-USDT liquidity pool twice (should fail)
        gauge_clmm::test_create_gauge(
            dev_address,
            expected_external_bribe_address,
            pool_address
        );
    }

    // Test 1: Successfully set new distribution address
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_set_distribution_success(dev: &signer) {
        let (_, _, _, pool_address, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool_address);

        // Create gauge
        gauge_clmm::test_create_gauge(
            dev_address,
            external_bribe,
            pool_address
        );

        // Create new distribution address
        let new_distribution = @0x123456;

        // Set new distribution
        let gauge = gauge_clmm::get_gauge_address(pool_address);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);

        gauge_clmm::set_distribution(dev2, gauge, new_distribution);

        // Verify distribution address updated
        let (_, _, distribution, _, _, _, _, _, _, _, _) =
            gauge_clmm::get_gauge_state(gauge);
        assert!(distribution == new_distribution, 0x1);
    }

    // Test 2: Attempt to set distribution without creating gauge (should fail)
    #[test]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_set_distribution_non_existent_gauge() {
        let (_, _, _, pool_address, _) = setup_test_without_genesis_with_register_lp();

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);
        let gauge = gauge_clmm::get_gauge_address(pool_address);
        // Set new distribution without creating gauge (should fail)
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::set_distribution(dev2, gauge, new_distribution);
    }

    // Test 3: Non-owner attempting to set distribution (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_NOT_OWNER, location = gauge_clmm)]
    fun test_clmm_set_distribution_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        // Non-owner attempts to set distribution
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::set_distribution(non_owner, gauge, new_distribution);
    }

    // Test 4: Setting distribution to zero address (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_ZERO_ADDRESS, location = gauge_clmm)]
    fun test_clmm_set_distribution_zero_address(dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to set distribution to zero address
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::set_distribution(dev2, gauge, @0x0);
    }

    // Test 5: Setting distribution to same address (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_SAME_ADDRESS, location = gauge_clmm)]
    fun test_clmm_set_distribution_same_address(dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to set distribution to current address
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::set_distribution(dev2, gauge, dev_address);
    }

    // Test 1: Successfully activate emergency mode
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_activate_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Verify emergency mode is active
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_clmm::get_gauge_state(gauge);
        assert!(emergency, 0x1);
    }

    // Test 2: Non-owner attempting to activate emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_NOT_OWNER, location = gauge_clmm)]
    fun test_clmm_activate_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Non-owner attempts to activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::update_emergency_mode(non_owner, gauge, true);
    }

    // Test 3: Activating emergency mode when already active (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_ALREADY_IN_THIS_MODE, location = gauge_clmm
    )
    ]
    fun test_clmm_activate_emergency_mode_already_active(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to activate emergency mode again
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);
    }

    // Test 5: Activating emergency mode for non-existent gauge (should fail)
    #[test]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_activate_emergency_mode_non_existent_gauge() {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);
    }

    // Test 1: Successfully stop emergency mode
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_stop_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Stop emergency mode
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, false);

        // Verify emergency mode is deactivated
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_clmm::get_gauge_state(gauge);
        assert!(!emergency, 0x1);
    }

    // Test 2: Non-owner attempting to stop emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_NOT_OWNER, location = gauge_clmm)]
    fun test_clmm_stop_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Non-owner attempts to stop emergency mode
        gauge_clmm::update_emergency_mode(non_owner, gauge, false);
    }

    // Test 3: Stopping emergency mode when not active (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_ALREADY_IN_THIS_MODE, location = gauge_clmm
    )
    ]
    fun test_clmm_stop_emergency_mode_not_active(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to stop emergency mode without activating it
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, false);
    }

    // Test 4: Stopping emergency mode for non-existent gauge (should fail)
    #[test]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_stop_emergency_mode_non_existent_gauge() {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, false);
    }

    // Test 1: Retrieve total supply for a new gauge (should be 0)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_total_supply_zero(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve total supply
        let gauge = gauge_clmm::get_gauge_address(pool);
        let supply = gauge_clmm::total_supply(gauge);

        // Verify total supply is 0
        assert!(supply == 0, 0x1);
    }

    // Test 2: Retrieve total supply after deposit
    #[test(dev = @dexlyn_clmm, user = @0x1234)]
    fun test_clmm_total_supply_after_deposit(dev: &signer, user: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account and mint LP tokens
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Retrieve total supply
        let gauge = gauge_clmm::get_gauge_address(pool);
        let supply = gauge_clmm::total_supply(gauge);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);

        // User deposits LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Retrieve total supply
        let supply = gauge_clmm::total_supply(gauge);

        // Verify total supply matches deposited amount
        assert!(supply == liquidity, 0x2);
    }

    // Test 3: Retrieve total supply for non-existent gauge (should fail)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_total_supply_non_existent_gauge(_dev: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt to retrieve total supply for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::total_supply(gauge);
    }

    // Test 1: Retrieve balance for a new user (should be 0)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_balance_of_zero(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve balance
        let gauge = gauge_clmm::get_gauge_address(pool);
        let balance = gauge_clmm::balance_of(gauge, dev_address);

        // Verify balance is 0
        assert!(balance == 0, 0x1);
    }

    // Test 2: Retrieve balance after deposit
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_balance_of_after_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve balance
        let gauge = gauge_clmm::get_gauge_address(pool);
        let balance = gauge_clmm::balance_of(gauge, dev_address);

        // Verify balance before deposit is 0
        assert!(balance == 0, 0x1);

        // User deposits LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Retrieve balance
        let balance = gauge_clmm::balance_of(gauge, dev_address);

        // Verify balance matches deposited amount
        assert!(balance == liquidity, 0x2);
    }

    // Test 3: Retrieve balance for non-existent gauge (should fail)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_balance_of_non_existent_gauge(_dev: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt to retrieve balance for non-existent gauge
        let user_address = @0x1234;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::balance_of(gauge, user_address);
    }

    // Test 1: Last time reward applicable for a new gauge
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_last_time_reward_applicable_initial(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve last time reward applicable
        let gauge = gauge_clmm::get_gauge_address(pool);
        let last_time = gauge_clmm::last_time_reward_applicable(gauge);

        // Verify it equals 0 (since period_finish is 0)
        assert!(last_time == 0, 0x1);
    }

    // Test 2: Last time reward applicable for non-existent gauge (should fail)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_last_time_reward_applicable_non_existent_gauge(
        _dev: &signer
    ) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt to retrieve last time reward applicable for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::last_time_reward_applicable(gauge);
    }

    // Test 3: Last time reward applicable during active reward period (returns current timestamp)
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_last_time_reward_applicable_active_period(dev: &signer, minter: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Get current timestamp (within reward period)
        let current_time = timestamp::now_seconds();

        // Retrieve last time reward applicable
        let last_time = gauge_clmm::last_time_reward_applicable(gauge);

        // Verify it equals current timestamp (since current_time < period_finish)
        assert!(last_time == current_time, 0x1);
    }

    // Test 4: Last time reward applicable after reward period ends (returns period_finish)
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_last_time_reward_applicable_expired_period(
        dev: &signer
        , minter: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Get period_finish from gauge state
        let (_, _, _, _, _, period_finish, _, _, _, _, _) =
            gauge_clmm::get_gauge_state(gauge);

        // Fast-forward time past period_finish
        let future_time = period_finish + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve last time reward applicable
        let last_time = gauge_clmm::last_time_reward_applicable(gauge);

        // Verify it equals period_finish
        assert!(last_time == period_finish, 0x1);
    }

    // Test 1: Reward per token for a new gauge (should return 0)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_reward_per_token_initial(dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve reward per token
        let gauge = gauge_clmm::get_gauge_address(pool);
        let reward_per_token = gauge_clmm::reward_per_token(gauge);

        // Verify reward per token is 0 (no rewards distributed, total_supply is 0)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 2: Reward per token with active reward period but no deposits (should return stored value)
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_reward_per_token_no_deposits(dev: &signer, minter: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Retrieve reward per token
        let reward_per_token = gauge_clmm::reward_per_token(gauge);

        // Verify reward per token is 0 (total_supply is 0, so stored value is returned)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 3: Reward per token with deposits and active reward period
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_reward_per_token_with_deposits(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve reward per token
        let reward_per_token = gauge_clmm::reward_per_token(gauge);

        // Calculate expected reward per token
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // time_diff = half_week
        // expected = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        let reward_rate = ((reward_amount * PRECISION) / WEEK);
        let expected = (half_week * reward_rate * PRECISION) / (liquidity as u64);

        // Verify reward per token matches expected value
        assert!((reward_per_token as u64) == expected, 0x1);
    }

    // Test 4: Reward per token after reward period expires
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_reward_per_token_expired_period(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve reward per token
        let reward_per_token = gauge_clmm::reward_per_token(gauge);

        // Calculate expected reward per token (should stop at period_finish)
        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = (WEEK * reward_rate * PRECISION) / (liquidity as u64);

        // Verify reward per token matches expected value
        assert!((reward_per_token as u64) == expected, 0x1);
    }

    // Test 5: Reward per token for non-existent gauge (should fail)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_reward_per_token_non_existent_gauge(_dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt to retrieve reward per token for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::reward_per_token(gauge);
    }

    // Test 1: Earned rewards for a new user (should return 0)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_earned_initial(dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve earned rewards
        let gauge = gauge_clmm::get_gauge_address(pool);
        let earned = gauge_clmm::earned(gauge, dev_address);

        // Verify earned rewards are 0 (no deposits, no rewards distributed)
        assert!(earned == 0, 0x1);
    }

    // Test 2: Earned rewards with deposits and active reward period
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_earned_with_deposits(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve earned rewards
        let earned = gauge_clmm::earned(gauge, dev_address);

        // Calculate expected earned rewards
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // reward_per_token = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        // earned = balance * reward_per_token
        let reward_per_token = gauge_clmm::reward_per_token(gauge);
        let expected = (liquidity as u64) * (reward_per_token as u64) / DXLYN_DECIMAL;

        let (_, clmm_gauge_total_earned, _, _, clmm_gauge_earn, _) = voter::earned_all_gauges(
            dev_address,
            vector[],
            vector[gauge],
            vector[]
        );

        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
        assert!(clmm_gauge_total_earned == expected, 0x2);
        assert!(clmm_gauge_total_earned == earned, 0x3);
        assert!(*vector::borrow(&clmm_gauge_earn, 0) == expected, 0x4);

        let (_, clmm_gauge_total_earned, _, _, _, _, clmm_gauge_earn, _, _, _) = voter::total_claimable_rewards(
            dev_address,
            dxlyn_coin::get_dxlyn_asset_address(),
            vector[],
            vector[gauge],
            vector[],
            vector[],
            vector[]
        );

        assert!(clmm_gauge_total_earned == earned, 0x5);
        assert!(*vector::borrow(&clmm_gauge_earn, 0) == expected, 0x6);
    }

    // Test 3: Earned rewards after reward period expires
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_earned_expired_period(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve earned rewards
        let earned = gauge_clmm::earned(gauge, dev_address);

        // Calculate expected earned rewards (should stop at period_finish)
        let reward_per_token = gauge_clmm::reward_per_token(gauge);

        let expected = (liquidity as u64) * (reward_per_token as u64) / DXLYN_DECIMAL;

        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
    }

    // Test 4: Earned rewards for non-existent gauge (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_earned_non_existent_gauge(dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt to retrieve earned rewards for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        let user_address = address_of(dev);
        gauge_clmm::earned(gauge, user_address);
    }

    // Test 1: Reward for duration calculation
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_reward_for_duration(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = reward_rate * WEEK / PRECISION;
        let reward_for_duration = gauge_clmm::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == expected, 0x1);
    }

    // Test 2: Reward for duration calculation without notify (should return 0)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_reward_for_duration_without_notify(dev: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        let reward_for_duration = gauge_clmm::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == 0, 0x1);
    }

    // Test 3: Reward for duration calculation for non-existent gauge (should return 0)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_reward_for_duration_non_existent_gauge(_dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let gauge = gauge_clmm::get_gauge_address(pool);

        let _ = gauge_clmm::reward_for_duration(gauge);
    }

    // Test 1: Period finish for a new gauge (should be current time + WEEK)
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    fun test_clmm_period_finish(dev: &signer, minter: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(minter, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        let period_finish = gauge_clmm::period_finish(gauge);

        // Verify period_finish is set to current time + WEEK
        assert!(
            period_finish == timestamp::now_seconds() + WEEK,
            0x1
        );
    }

    // Test 2: Period finish for non-existent gauge (should fail)
    #[test(_dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_period_finish_non_existent_gauge(_dev: &signer) {
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let gauge = gauge_clmm::get_gauge_address(pool);
        let _ = gauge_clmm::period_finish(gauge);
    }

    // Test 1: Deposit all LP tokens into the gauge
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_deposit_all(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);
        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_clmm::get_gauge_address(pool);

        // Retrieve total supply
        let supply = gauge_clmm::total_supply(gauge);
        assert!(supply == 0, 0x1);

        let dev_state_balance_before = gauge_clmm::balance_of(gauge, dev_address);
        assert!(dev_state_balance_before == 0, 0x3);

        let token_metadata = address_to_object<Token>(token);

        gauge_clmm::assert_token_owner(dev_address, token);

        // User deposits all LP tokens
        let lp_count = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::deposit(dev, gauge, token);

        let owner = object::owner(token_metadata);
        assert!(owner == gauge, 0x3);

        // Retrieve total supply
        let supply = gauge_clmm::total_supply(gauge);
        assert!(supply == lp_count, 0x4);

        let dev_bal_after = gauge_clmm::balance_of(gauge, dev_address);
        assert!(dev_bal_after == lp_count, 0x3);
    }

    // Test 2: Deposit all in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_deposit_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to deposit all (should fail due to emergency mode)
        gauge_clmm::deposit(dev, gauge, token);
    }

    // Test 4: Deposit all with non-existent gauge (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_deposit_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge for BTC/USDT pool
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        gauge_clmm::deposit(dev, @123, token);
    }

    // Test 1: Deposit LP tokens into the gauge
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_clmm::get_gauge_address(pool);

        // Retrieve total supply
        let supply = gauge_clmm::total_supply(gauge);
        let dev_state_balance_before = gauge_clmm::balance_of(gauge, dev_address);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);
        assert!(dev_state_balance_before == 0, 0x3);

        // Assume user deposits all LP tokens
        let lp_balance = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::assert_token_owner(dev_address, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Retrieve total supply
        let supply = gauge_clmm::total_supply(gauge);
        let dev_state_balance_after = gauge_clmm::balance_of(gauge, dev_address);

        // Verify total supply matches deposited amount
        assert!(supply == lp_balance, 0x4);
        // Verify gauge balance matches LP balance of dev before deposit
        assert!(dev_state_balance_after == lp_balance, 0x6);
        gauge_clmm::assert_token_owner(gauge, token);
    }

    // Test 2: Deposit in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_deposit_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to deposit (should fail due to emergency mode)
        gauge_clmm::deposit(dev, gauge, token);
    }

    // Test 4: Deposit with non-existent gauge (should fail)
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_deposit_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge for BTC/USDT pool
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to deposit with wrong LP token type (should fail)
        gauge_clmm::deposit(dev, @123, token);
    }

    // Test 1: Successful withdrawal of all LP tokens
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_withdraw_all_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::assert_token_owner(dev_address, token);
        let lp_count = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::assert_token_owner(dev_address, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Retrieve state before withdrawal
        let supply_before = gauge_clmm::total_supply(gauge);
        let dev_balance_before = gauge_clmm::balance_of(gauge, dev_address);
        // Verify initial state
        assert!(supply_before == lp_count, 0x1);
        assert!(dev_balance_before == lp_count, 0x2);
        gauge_clmm::assert_token_owner(gauge, token);

        // Withdraw all LP tokens
        gauge_clmm::withdraw(dev, gauge, token);

        // Retrieve state after withdrawal
        let supply_after = gauge_clmm::total_supply(gauge);
        let dev_balance_after = gauge_clmm::balance_of(gauge, dev_address);
        // Verify total supply is 0
        assert!(supply_after == 0, 0x4);
        // Verify user balance in gauge is 0
        assert!(dev_balance_after == 0, 0x5);
        gauge_clmm::assert_token_owner(dev_address, token);
    }

    // Test 2: Withdraw all in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_withdraw_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to withdraw all (should fail due to emergency mode)
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::withdraw(dev, gauge, token);
    }

    // Test 3: Withdraw all with zero balance
    #[test(dev = @dexlyn_clmm, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER, location = gauge_clmm
    )
    ]
    fun test_clmm_withdraw_fund_by_dev(dev: &signer, user: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw without deposit (should fail)
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);
        gauge_clmm::withdraw(user, gauge, token);
    }

    // Test 4: Withdraw all from non-existent gauge
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_withdraw_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        // Attempt to withdraw all from non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::withdraw(dev, gauge, token);
    }

    // Test 1: Successful withdrawal of partial LP tokens
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        let gauge = gauge_clmm::get_gauge_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        gauge_clmm::assert_token_owner(dev_address, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Retrieve state before withdrawal
        let lp_count = gauge_clmm::get_liquidity(pool, token);
        let supply_before = gauge_clmm::total_supply(gauge);
        let dev_balance_before = gauge_clmm::balance_of(gauge, dev_address);

        // Verify initial state
        assert!(supply_before == lp_count, 0x1);
        assert!(dev_balance_before == lp_count, 0x2);
        gauge_clmm::assert_token_owner(gauge, token);

        // Withdraw partial LP tokens
        gauge_clmm::withdraw(dev, gauge, token);

        // Retrieve state after withdrawal
        let supply_after = gauge_clmm::total_supply(gauge);
        let dev_balance_after = gauge_clmm::balance_of(gauge, dev_address);
        // Verify total supply decreased by withdrawn amount
        assert!(supply_after == 0, 0x4);
        // Verify user balance in gauge decreased by withdrawn amount
        assert!(dev_balance_after == 0, 0x5);
        gauge_clmm::assert_token_owner(dev_address, token);
    }

    // Test 2: Withdraw in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_withdraw_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);

        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to withdraw (should fail due to emergency mode)
        gauge_clmm::withdraw(dev, gauge, token);
    }

    // Test 3: Withdraw with zero amount
    #[test(dev = @dexlyn_clmm)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER, location = gauge_clmm
    )
    ]
    fun test_clmm_unauthorized_withdraw(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt withdraw without deposit
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        gauge_clmm::withdraw(&create_signer_for_test(@0x123), gauge, token);
    }

    // Test 4: Withdraw with insufficient balance
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_withdraw_balance(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_clmm::get_gauge_address(pool);

        gauge_clmm::deposit(dev, gauge, token);
        gauge_clmm::withdraw(dev, gauge, token);
    }

    // Test 5: Withdraw with invalid LP token
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_withdraw_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        // Attempt to withdraw with wrong LP token type (should fail)
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::withdraw(dev, gauge, token);
    }

    // Test 1: Successful emergency withdrawal
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_emergency_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        let gauge = gauge_clmm::get_gauge_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        gauge_clmm::deposit(dev, gauge, token);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_clmm::total_supply(gauge);
        let dev_balance_before = gauge_clmm::balance_of(gauge, dev_address);

        // Verify initial state
        assert!(supply_before == liquidity, 0x1);
        assert!(dev_balance_before == liquidity, 0x2);

        // Perform emergency withdrawal
        gauge_clmm::emergency_withdraw(dev, gauge, token);

        // Retrieve state after withdrawal
        let supply_after = gauge_clmm::total_supply(gauge);
        let dev_balance_after = gauge_clmm::balance_of(gauge, dev_address);

        // Verify total supply is 0
        assert!(supply_after == 0, 0x4);
        // Verify user balance in gauge is 0
        assert!(dev_balance_after == 0, 0x5);
    }

    // Test 2: Emergency withdrawal in non-emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_NOT_IN_EMERGENCY_MODE, location = gauge_clmm
    )
    ]
    fun test_clmm_emergency_withdraw_non_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Attempt to withdraw without emergency mode (should fail)
        gauge_clmm::emergency_withdraw(dev, gauge, token);
    }

    #[test(dev = @dexlyn_clmm, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER, location = gauge_clmm
    )
    ]
    fun test_clmm_unauthorized_emergency_withdraw(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);


        gauge_clmm::deposit(dev, gauge, token);

        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        let user_address = address_of(user);
        account::create_account_for_test(user_address);
        gauge_clmm::emergency_withdraw(user, gauge, token);
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_emergency_withdraw_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        // Attempt to withdraw from non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::emergency_withdraw(dev, gauge, token);
    }

    // Test 1: Successful partial emergency withdrawal
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_emergency_withdraw_amount_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_clmm::total_supply(gauge);
        let dev_balance_before = gauge_clmm::balance_of(gauge, dev_address);

        // Verify initial state
        assert!(supply_before == liquidity, 0x1);
        assert!(dev_balance_before == liquidity, 0x2);
    }

    // Test 2: Emergency withdrawal in non-emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_NOT_IN_EMERGENCY_MODE)]
    fun test_clmm_emergency_withdraw_amount_non_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);
        // Attempt to withdraw without emergency mode
        gauge_clmm::emergency_withdraw(dev, gauge, token);
    }

    // Test 3: Emergency withdrawal with insufficient balance
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure]
    fun test_clmm_emergency_withdraw_amount_insufficient_balance(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to withdraw more than balance
        gauge_clmm::emergency_withdraw(dev, gauge, token);
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST)]
    fun test_clmm_emergency_withdraw_amount_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        // Attempt to withdraw from non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::emergency_withdraw(dev, gauge, token);
    }

    // Test 1: Successful withdrawal and reward harvest
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_withdraw_all_and_harvest_success(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        let gauge = gauge_clmm::get_gauge_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let liquidity = gauge_clmm::get_liquidity(pool, token);

        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before withdrawal
        let supply_before = gauge_clmm::total_supply(gauge);
        let dev_balance_before = gauge_clmm::balance_of(gauge, dev_address);
        let reward_balance_before = dxlyn_coin::balance_of(dev_address);
        let earned_before = gauge_clmm::earned(gauge, dev_address);

        // Verify initial state
        assert!(supply_before == liquidity, 0x1);
        assert!(dev_balance_before == liquidity, 0x2);
        assert!(earned_before > 0, 0x4);

        // Perform withdraw_all_and_harvest
        gauge_clmm::withdraw_all_and_harvest(dev, gauge, token);

        // Retrieve state after withdrawal
        let supply_after = gauge_clmm::total_supply(gauge);
        let dev_balance_after = gauge_clmm::balance_of(gauge, dev_address);
        let reward_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify total supply is 0
        assert!(supply_after == 0, 0x5);
        // Verify user balance in gauge is 0
        assert!(dev_balance_after == 0, 0x6);
        assert!(
            reward_balance_after >= reward_balance_before + earned_before,
            0x9
        );
    }

    // Test 2: Withdraw and harvest in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_withdraw_all_and_harvest_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Attempt to withdraw and harvest
        gauge_clmm::withdraw_all_and_harvest(dev, gauge, token);
    }

    // Test 3: Withdraw and harvest with zero balance
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER, location = gauge_clmm
    )
    ]
    fun test_clmm_withdraw_all_and_harvest_zero_balance(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw and harvest with zero balance
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::withdraw_all_and_harvest(user, gauge, token);
        gauge_clmm::withdraw_all_and_harvest(dev, gauge, token);
    }

    // Test 4: Withdraw and harvest from non-existent gauge
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_withdraw_all_and_harvest_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();

        // Attempt to withdraw and harvest from non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::withdraw_all_and_harvest(dev, gauge, token);
    }

    // Test 1: Successful reward distribution
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_get_reward_distribution_success(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge with dev as distribution
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Transfer LP tokens to user and deposit
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before distribution
        let earned_before = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward distribution
        gauge_clmm::get_reward_distribution(dev, dev_address, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 2: Unauthorized distribution account
    #[test(dev = @dexlyn_tokenomics, user = @0x1234, unauthorized = @0x5678)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_NOT_DISTRIBUTION, location = gauge_clmm
    )]
    fun test_clmm_get_reward_distribution_unauthorized(
        dev: &signer, user: &signer, unauthorized: &signer
    ) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(user_address);
        account::create_account_for_test(unauthorized_address);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge with dev as distribution
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt distribution with unauthorized account
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::get_reward_distribution(unauthorized, user_address, gauge);
    }

    // Test 3: Distribution with zero rewards
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    fun test_clmm_get_reward_distribution_zero_rewards(
        dev: &signer, user: &signer
    ) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // No deposits or rewards for user
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(user_address);
        let gauge = gauge_clmm::get_gauge_address(pool);
        let earned_before = gauge_clmm::earned(gauge, user_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward distribution
        gauge_clmm::get_reward_distribution(dev, user_address, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_clmm::earned(gauge, user_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(user_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 4: Distribution for non-existent gauge
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_get_reward_distribution_non_existent_gauge(
        dev: &signer, user: &signer
    ) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt distribution for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::get_reward_distribution(dev, user_address, gauge);
    }

    // Test 1: Successful reward claim
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_get_reward_success(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before claim
        let earned_before = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_clmm::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 2: Claim with zero rewards
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_get_reward_zero_rewards(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // No deposits or rewards
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);
        let gauge = gauge_clmm::get_gauge_address(pool);
        let earned_before = gauge_clmm::earned(gauge, dev_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward claim
        gauge_clmm::deposit(dev, gauge, token);
        gauge_clmm::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 3: Claim for non-existent gauge
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_get_reward_non_existent_gauge(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Attempt claim for non-existent gauge
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::get_reward(dev, gauge);
    }

    // Test 4: Claim after withdrawal
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_get_reward_after_withdrawal(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Withdraw all LP tokens
        gauge_clmm::withdraw(dev, gauge, token);

        // Retrieve state before claim
        let earned_before = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify rewards exist
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_clmm::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 1: Successful reward notification (new period)
    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_notify_reward_amount_success_new_period(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);

        // Fast-forward to ensure period is finished
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + WEEK + 1);

        // Retrieve state before notification
        let (_, _, _, _, _, _, _, _, _, _, gauge_dxlyn_balance_before) =
            gauge_clmm::get_gauge_state(gauge);
        let dev_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Notify reward amount
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Retrieve state after notification
        let dev_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);
        let (
            _,
            _,
            _,
            _,
            duration,
            period_finish,
            reward_rate,
            last_update_time,
            _,
            _,
            gauge_dxlyn_balance_after
        ) = gauge_clmm::get_gauge_state(gauge);
        let expected_reward_rate = (reward_amount * PRECISION) / duration;

        // Verify state
        assert!(
            gauge_dxlyn_balance_after == gauge_dxlyn_balance_before + reward_amount,
            0x1
        );
        assert!(
            dev_dxlyn_balance_after == dev_dxlyn_balance_before - reward_amount,
            0x2
        );
        assert!(reward_rate == (expected_reward_rate as u256), 0x3);
        assert!(last_update_time == timestamp::now_seconds(), 0x4);
        assert!(
            period_finish == timestamp::now_seconds() + duration,
            0x5
        );
    }

    // Test 2: Unauthorized distribution account
    #[test(dev = @dexlyn_tokenomics, unauthorized = @0x5678)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_NOT_DISTRIBUTION, location = gauge_clmm
    )]
    fun test_clmm_notify_reward_amount_unauthorized(
        dev: &signer, unauthorized: &signer
    ) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(unauthorized_address);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup DXLYN tokens for unauthorized account
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, unauthorized_address, reward_amount);

        // Attempt notification with unauthorized account
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::notify_reward_amount(unauthorized, gauge, reward_amount);
    }

    // Test 3: Notification in emergency mode
    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_IN_EMERGENCY_MODE, location = gauge_clmm
    )]
    fun test_clmm_notify_reward_amount_emergency_mode(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_clmm::get_gauge_address(pool);
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        gauge_clmm::update_emergency_mode(dev2, gauge, true);

        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);

        // Attempt notification in emergency mode
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);
    }

    // Test 4: Notification for non-existent gauge
    #[test(dev = @dexlyn_clmm, minter = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_clmm::ERROR_GAUGE_NOT_EXIST, location = gauge_clmm
    )]
    fun test_clmm_notify_reward_amount_non_existent_gauge(dev: &signer, minter: &signer) {
        // Setup environment
        let (_, _, _, pool, _) = setup_test_without_genesis_with_register_lp();

        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        dxlyn_coin::register_and_mint(minter, address_of(dev), reward_amount);

        // Attempt notification for non-existent gauge
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);
    }

    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_success_flow(dev: &signer) {
        // Setup environment
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        let dev2 = &create_signer_for_test(@dexlyn_tokenomics);
        dxlyn_coin::register_and_mint(dev2, dev_address, reward_amount);
        gauge_clmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Withdraw all LP tokens
        gauge_clmm::withdraw(dev, gauge, token);

        // Retrieve state before claim
        let earned_before = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify rewards exist
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_clmm::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_clmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);

        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_deposit_success(dev: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);
    }

    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER)]
    fun test_clmm_unauthorized_deposit(dev: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);

        let hacker = &create_signer_for_test(@0x123);
        gauge_clmm::deposit(hacker, gauge, token);
    }

    #[test(dev = @dexlyn_clmm)]
    fun test_clmm_withdraw_successful(dev: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);
        gauge_clmm::deposit(dev, gauge, token);
        gauge_clmm::withdraw(dev, gauge, token);
    }

    #[test(dev = @dexlyn_clmm)]
    #[expected_failure(abort_code = gauge_clmm::ERROR_INVALID_TOKEN_OWNER)]
    fun test_clmm_unauthorized_withdrawn(dev: &signer) {
        let (_, _, _, pool, token) = setup_test_without_genesis_with_register_lp();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_clmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        // let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_clmm::get_gauge_address(pool);

        let hacker = &create_signer_for_test(@0x123);
        gauge_clmm::deposit(dev, gauge, token);
        gauge_clmm::withdraw(hacker, gauge, token);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_clmm_low_liquidity_high_reward_senario(dev: &signer) {
        let lp_owner = &create_signer_for_test(@dexlyn_clmm);
        let lp_owner_address = address_of(lp_owner);
        setup_test_with_genesis(dev);

        let (token_a_name, token_b_name) = (utf8(b"Token A"), utf8(b"Token B"));
        let token_a = test_helpers::setup_fungible_assets(lp_owner, token_a_name, utf8(b"TA"));
        let token_b = test_helpers::setup_fungible_assets(lp_owner, token_b_name, utf8(b"TB"));

        let tick_spacing = 200;
        let init_sqrt_price = 18446744073709551616; // at 0
        factory::init_factory_module(lp_owner);
        add_fee_tier(lp_owner, tick_spacing, 1000);
        let pool_address =
            factory::create_pool(
                lp_owner,
                tick_spacing,
                init_sqrt_price,
                utf8(b""),
                token_a,
                token_b
            );

        // Position 1
        add_liquidity_fix_value(
            lp_owner,
            pool_address,
            1,
            1,
            false,
            18446744073709549616, // -2000
            0, // 0
            true,
            0,
        );

        let collection = position_nft::collection_name(tick_spacing, token_a, token_b);
        let token_name = position_nft::position_name(1, 1);
        let token_address =
            token::create_token_address(&pool_address, &collection, &token_name);

        let liquidity = gauge_clmm::get_liquidity(pool_address, token_address);

        let external_bribe = voter::get_external_bribe_address(pool_address);

        // Create gauge
        gauge_clmm::test_create_gauge(lp_owner_address, external_bribe, pool_address);

        let gauge_address = gauge_clmm::get_gauge_address(pool_address);

        // Deposit LP tokens
        gauge_clmm::deposit(lp_owner, gauge_address, token_address);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 1000000 * DXLYN_DECIMAL;
            dxlyn_coin::register_and_mint(dev, lp_owner_address, reward_amount);
            gauge_clmm::notify_reward_amount(lp_owner, gauge_address, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_clmm::earned(gauge_address, lp_owner_address);

        // Calculate expected earned rewards
        let reward_per_token = gauge_clmm::reward_per_token(gauge_address);
        let expected = (liquidity as u256) * (reward_per_token) / (DXLYN_DECIMAL as u256);

        // Verify earned rewards match expected value
        assert!(earned == (expected as u64), 0x1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_clmm_high_liquidity_low_reward_senario(dev: &signer) {
        let lp_owner = &create_signer_for_test(@dexlyn_clmm);
        let lp_owner_address = address_of(lp_owner);
        setup_test_with_genesis(dev);

        let (token_a_name, token_b_name) = (utf8(b"Token A"), utf8(b"Token B"));
        let token_a = test_helpers::setup_fungible_assets(lp_owner, token_a_name, utf8(b"TA"));
        let token_b = test_helpers::setup_fungible_assets(lp_owner, token_b_name, utf8(b"TB"));

        let tick_spacing = 200;
        let init_sqrt_price = 18446744073709551616; // at 0
        factory::init_factory_module(lp_owner);
        add_fee_tier(lp_owner, tick_spacing, 1000);
        let pool_address =
            factory::create_pool(
                lp_owner,
                tick_spacing,
                init_sqrt_price,
                utf8(b""),
                token_a,
                token_b
            );

        // Position 1
        add_liquidity_fix_value(
            lp_owner,
            pool_address,
            1000000000 * DXLYN_DECIMAL,
            1000000000 * DXLYN_DECIMAL,
            false,
            18446744073709549616, // -2000
            0, // 0
            true,
            0,
        );

        let collection = position_nft::collection_name(tick_spacing, token_a, token_b);
        let token_name = position_nft::position_name(1, 1);
        let token_address =
            token::create_token_address(&pool_address, &collection, &token_name);

        let external_bribe = voter::get_external_bribe_address(pool_address);

        // Create gauge
        gauge_clmm::test_create_gauge(lp_owner_address, external_bribe, pool_address);
        let gauge_address = gauge_clmm::get_gauge_address(pool_address);
        // Deposit LP tokens
        gauge_clmm::deposit(lp_owner, gauge_address, token_address);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 10000;
            dxlyn_coin::register_and_mint(dev, lp_owner_address, reward_amount);
            gauge_clmm::notify_reward_amount(lp_owner, gauge_address, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_clmm::earned(gauge_address, lp_owner_address);

        // Verify earned rewards is 0
        assert!(earned == 0, 0x1);
    }
}
