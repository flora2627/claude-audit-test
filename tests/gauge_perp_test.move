#[test_only]
module dexlyn_tokenomics::gauge_perp_test {

    use std::signer::address_of;
    use std::string::utf8;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_perp::house_lp::DXLP;
    use dexlyn_perp::voter_perp_test::{create_dexlyn_perp_signer, TestAssetT, TestAssetT2};
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_perp;
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

    fun get_dxlp_balance(user: address): u64 {
        coin::balance<DXLP<TestAssetT>>(user)
    }

    fun min_dxlp_coin(dexlyn_perp_signer: &signer, to: address, amount: u64) {
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT>>(dexlyn_perp_signer, to, amount);
    }

    fun get_dxlp_address(): address {
        gauge_perp::get_dxlp_coin_address<TestAssetT>()
    }


    // Test setup function to initialize the environment
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        test_internal_coins::supra_coin_initialize_for_test_without_aggregator_factory();
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    fun set_up_coins(dev: &signer) {
        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        test_internal_coins::init_legacy_coin<DXLP<TestAssetT>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT"), utf8(b"DXLP_TAT"), 8, true
        );
        min_dxlp_coin(dexlyn_perp_signer, address_of(dev), 1000000000000)
    }

    fun setup_test(dev: &signer) {
        // Create developer account
        account::create_account_for_test(address_of(dev));

        // Initialize DXLYN coin (platform token)
        test_internal_coins::init_coin(dev);

        // Initialize DXLP coin (stack token)
        set_up_coins(dev);

        // Initialize USDC coin (reward token)
        test_internal_coins::init_usdc_coin(dev);

        // Initialize voting escrow (tracks locked tokens for voting power)
        voting_escrow::initialize(dev);

        // Initialize voter contract
        voter::initialize(dev);

        fee_distributor::initialize(dev);

        // Set active period to align with current epoch (week boundary)
        minter::set_active_period((timestamp::now_seconds() / WEEK) * WEEK);
    }


    // Test 1: Initialize gauge contract and check initial state
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_initialize(dev: &signer) {
        setup_test_with_genesis(dev);

        let gauge_system_owner = gauge_perp::get_gauge_system_owner();
        let dev_address = address_of(dev);

        assert!(gauge_system_owner == dev_address, 0x1);
    }

    // Test 2: Reinitialize gaugev2 contract (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun gauge_perp_test_reinitialize(dev: &signer) {
        setup_test_with_genesis(dev);

        gauge_perp::initialize(dev);
    }

    // Test 1: Create a gauge for the BTC-USDT liquidity pool
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_create_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let expected_external_bribe_address = voter::get_external_bribe_address(dxlp_address);

        // Create a gauge v2 for the BTC-USDT liquidity pool
        gauge_perp::test_create_gauge(
            dev_address,
            expected_external_bribe_address,
            dxlp_address,
        );

        let gauge = gauge_perp::get_gauge_address(dxlp_address);

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
        ) = gauge_perp::get_gauge_state(gauge);

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
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_ALREADY_EXIST,
    )
    ]
    fun gauge_perp_test_create_gauge_twice(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let expected_external_bribe_address = voter::get_external_bribe_address(dxlp_address);

        // Create a gauge v2 for the BTC-USDT liquidity pool
        gauge_perp::test_create_gauge(
            dxlp_address,
            dev_address,
            expected_external_bribe_address,
        );

        // Create a gauge v2 for the BTC-USDT liquidity pool twice (should fail)
        gauge_perp::test_create_gauge(
            dxlp_address,
            dev_address,
            expected_external_bribe_address,
        );
    }

    // Test 1: Successfully set new distribution address
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_set_distribution_success(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Set new distribution
        gauge_perp::set_distribution(dev, gauge, new_distribution);

        // Verify distribution address updated
        let (_, _, distribution, _, _, _, _, _, _, _, _) =
            gauge_perp::get_gauge_state(gauge);
        assert!(distribution == new_distribution, 0x1);
    }

    // Test 2: Attempt to set distribution without creating gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_set_distribution_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();

        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        // Set new distribution without creating gauge (should fail)
        gauge_perp::set_distribution(dev, gauge, new_distribution);
    }

    // Test 3: Non-owner attempting to set distribution (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_perp::ERROR_NOT_OWNER, )]
    fun gauge_perp_test_set_distribution_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        // Non-owner attempts to set distribution
        gauge_perp::set_distribution(non_owner, gauge, new_distribution);
    }

    // Test 4: Setting distribution to zero address (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_ZERO_ADDRESS, )]
    fun gauge_perp_test_set_distribution_zero_address(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Attempt to set distribution to zero address
        gauge_perp::set_distribution(dev, gauge, @0x0);
    }

    // Test 5: Setting distribution to same address (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_SAME_ADDRESS, )]
    fun gauge_perp_test_set_distribution_same_address(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Attempt to set distribution to current address
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::set_distribution(dev, gauge, dev_address);
    }

    // Test 1: Successfully activate emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_activate_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Verify emergency mode is active
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_perp::get_gauge_state(gauge);
        assert!(emergency, 0x1);
    }

    // Test 2: Non-owner attempting to activate emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_perp::ERROR_NOT_OWNER, )]
    fun gauge_perp_test_activate_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Non-owner attempts to activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(non_owner, gauge, true);
    }

    // Test 3: Activating emergency mode when already active (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_ALREADY_IN_THIS_MODE,
    )
    ]
    fun gauge_perp_test_activate_emergency_mode_already_active(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to activate emergency mode again
        gauge_perp::update_emergency_mode(dev, gauge, true);
    }

    // Test 5: Activating emergency mode for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_activate_emergency_mode_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        // Attempt to activate emergency mode for non-existent gauge
        gauge_perp::update_emergency_mode(dev, @0x9999, true);
    }

    // Test 1: Successfully stop emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_stop_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Activate emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Stop emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, false);

        // Verify emergency mode is deactivated
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_perp::get_gauge_state(gauge);
        assert!(!emergency, 0x1);
    }

    // Test 2: Non-owner attempting to stop emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_perp::ERROR_NOT_OWNER, )]
    fun gauge_perp_test_stop_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Non-owner attempts to stop emergency mode
        gauge_perp::update_emergency_mode(non_owner, gauge, false);
    }

    // Test 3: Stopping emergency mode when not active (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_ALREADY_IN_THIS_MODE,
    )
    ]
    fun gauge_perp_test_stop_emergency_mode_not_active(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Attempt to stop emergency mode without activating it
        gauge_perp::update_emergency_mode(dev, gauge, false);
    }

    // Test 4: Stopping emergency mode for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_stop_emergency_mode_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to stop emergency mode for non-existent gauge
        gauge_perp::update_emergency_mode(dev, @0x9999, false);
    }

    // Test 1: Retrieve total supply for a new gauge (should be 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_total_supply_zero(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Retrieve total supply
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let supply = gauge_perp::total_supply(gauge);

        // Verify total supply is 0
        assert!(supply == 0, 0x1);
    }

    // Test 2: Retrieve total supply after deposit
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    fun gauge_perp_test_total_supply_after_deposit(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup user account and mint LP tokens
        let user_address = address_of(user);
        account::create_account_for_test(user_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);
        let lp_balance_before = get_dxlp_balance(dev_address);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);

        // User deposits LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);
        let lp_balance_after = get_dxlp_balance(dev_address);

        // Verify total supply matches deposited amount
        assert!(supply == deposit_amount, 0x2);
        assert!(
            lp_balance_after == lp_balance_before - deposit_amount,
            0x3
        ); // Verify LP balance decreased by deposit amount
    }

    // Test 3: Retrieve total supply for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_total_supply_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve total supply for non-existent gauge
        gauge_perp::total_supply(@0x9999);
    }

    // Test 1: Retrieve balance for a new user (should be 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_balance_of_zero(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Retrieve balance
        let balance = gauge_perp::balance_of(gauge, dev_address);

        // Verify balance is 0
        assert!(balance == 0, 0x1);
    }

    // Test 2: Retrieve balance after deposit
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_balance_of_after_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Retrieve balance
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let balance = gauge_perp::balance_of(gauge, dev_address);

        // Verify balance before deposit is 0
        assert!(balance == 0, 0x1);

        // User deposits LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Retrieve balance
        let balance = gauge_perp::balance_of(gauge, dev_address);

        // Verify balance matches deposited amount
        assert!(balance == deposit_amount, 0x2);
    }

    // Test 3: Retrieve balance for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_balance_of_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve balance for non-existent gauge
        let user_address = @0x1234;
        let gauge = gauge_perp::get_gauge_address(@0x1234);
        gauge_perp::balance_of(gauge, user_address);
    }

    // Test 1: Last time reward applicable for a new gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_last_time_reward_applicable_initial(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Retrieve last time reward applicable
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let last_time = gauge_perp::last_time_reward_applicable(gauge);

        // Verify it equals 0 (since period_finish is 0)
        assert!(last_time == 0, 0x1);
    }

    // Test 2: Last time reward applicable for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_last_time_reward_applicable_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve last time reward applicable for non-existent gauge
        gauge_perp::last_time_reward_applicable(@0x9999);
    }

    // Test 3: Last time reward applicable during active reward period (returns current timestamp)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_last_time_reward_applicable_active_period(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup reward distribution
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Get current timestamp (within reward period)
        let current_time = timestamp::now_seconds();

        // Retrieve last time reward applicable
        let last_time = gauge_perp::last_time_reward_applicable(gauge);

        // Verify it equals current timestamp (since current_time < period_finish)
        assert!(last_time == current_time, 0x1);
    }

    // Test 4: Last time reward applicable after reward period ends (returns period_finish)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_last_time_reward_applicable_expired_period(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup reward distribution
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Get period_finish from gauge state
        let (_, _, _, _, _, period_finish, _, _, _, _, _) =
            gauge_perp::get_gauge_state(gauge);

        // Fast-forward time past period_finish
        let future_time = period_finish + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve last time reward applicable
        let last_time = gauge_perp::last_time_reward_applicable(gauge);

        // Verify it equals period_finish
        assert!(last_time == period_finish, 0x1);
    }

    // Test 1: Reward per token for a new gauge (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_per_token_initial(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Retrieve reward per token
        let reward_per_token = gauge_perp::reward_per_token(gauge);

        // Verify reward per token is 0 (no rewards distributed, total_supply is 0)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 2: Reward per token with active reward period but no deposits (should return stored value)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_per_token_no_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup reward distribution
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Retrieve reward per token
        let reward_per_token = gauge_perp::reward_per_token(gauge);

        // Verify reward per token is 0 (total_supply is 0, so stored value is returned)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 3: Reward per token with deposits and active reward period
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_per_token_with_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve reward per token
        let reward_per_token = gauge_perp::reward_per_token(gauge);

        // Calculate expected reward per token
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // time_diff = half_week
        // expected = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = (((half_week * reward_rate * PRECISION) / deposit_amount) as u256);

        // Verify reward per token matches expected value
        assert!(reward_per_token == expected, 0x1);
    }

    // Test 4: Reward per token after reward period expires
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_per_token_expired_period(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve reward per token
        let reward_per_token = gauge_perp::reward_per_token(gauge);

        // Calculate expected reward per token (should stop at period_finish)
        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = (((WEEK * reward_rate * PRECISION) / deposit_amount) as u256);

        // Verify reward per token matches expected value
        assert!(reward_per_token == expected, 0x1);
    }

    // Test 5: Reward per token for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_reward_per_token_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);

        // Attempt to retrieve reward per token for non-existent gauge
        gauge_perp::reward_per_token(@0x9999);
    }

    // Test 1: Earned rewards for a new user (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_earned_initial(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Retrieve earned rewards
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let earned = gauge_perp::earned(gauge, dev_address);

        // Verify earned rewards are 0 (no deposits, no rewards distributed)
        assert!(earned == 0, 0x1);
    }

    // Test 2: Earned rewards with deposits and active reward period
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_earned_with_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve earned rewards
        let earned = (gauge_perp::earned(gauge, dev_address) as u256);

        // Calculate expected earned rewards
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // reward_per_token = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        // earned = balance * reward_per_token
        let reward_per_token = gauge_perp::reward_per_token(gauge);
        let expected = (deposit_amount as u256) * reward_per_token / (DXLYN_DECIMAL as u256);

        let (_, _, perp_gauge_total_earned, _, _, perp_gauge_earn) = voter::earned_all_gauges(
            dev_address,
            vector[],
            vector[],
            vector[gauge]
        );

        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
        assert!((perp_gauge_total_earned as u256) == expected, 0x2);
        assert!((perp_gauge_total_earned as u256) == earned, 0x3);
        assert!((*vector::borrow(&perp_gauge_earn, 0) as u256) == expected, 0x4);


        let (_, _, perp_gauge_total_earned, _, _, _, _, perp_gauge_earn, _, _) = voter::total_claimable_rewards(
            dev_address,
            dxlyn_coin::get_dxlyn_asset_address(),
            vector[],
            vector[],
            vector[gauge],
            vector[],
            vector[]
        );

        assert!((perp_gauge_total_earned as u256) == earned, 0x5);
        assert!((*vector::borrow(&perp_gauge_earn, 0) as u256) == expected, 0x6);
    }

    // Test 3: Earned rewards after reward period expires
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_earned_expired_period(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve earned rewards

        let earned = (gauge_perp::earned(gauge, dev_address) as u256);

        // Calculate expected earned rewards (should stop at period_finish)
        let reward_per_token = gauge_perp::reward_per_token(gauge);

        let expected = (deposit_amount as u256) * reward_per_token / (DXLYN_DECIMAL as u256);

        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
    }

    // Test 4: Earned rewards for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_earned_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);

        // Attempt to retrieve earned rewards for non-existent gauge
        let user_address = address_of(dev);
        gauge_perp::earned(@0x9999, user_address);
    }

    // Test 1: Reward for duration calculation
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_for_duration(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = reward_rate * WEEK / PRECISION;
        let reward_for_duration = gauge_perp::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == expected, 0x1);
    }

    // Test 2: Reward for duration calculation without notify (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_reward_for_duration_without_notify(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        let reward_for_duration = gauge_perp::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == 0, 0x1);
    }

    // Test 3: Reward for duration calculation for non-existent gauge (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_reward_for_duration_non_existent_gauge(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let _ = gauge_perp::reward_for_duration(gauge);
    }

    // Test 1: Period finish for a new gauge (should be current time + WEEK)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_period_finish(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        let period_finish = gauge_perp::period_finish(gauge);

        // Verify period_finish is set to current time + WEEK
        assert!(
            period_finish == timestamp::now_seconds() + WEEK,
            0x1
        );
    }

    // Test 2: Period finish for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_period_finish_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let _ = gauge_perp::period_finish(gauge);
    }

    // Test 1: Deposit all LP tokens into the gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_deposit_all(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);


        let dev_state_balace_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);
        assert!(gauge_lp_balance_before == 0, 0x2);
        assert!(dev_state_balace_before == 0, 0x3);

        // User deposits all LP tokens
        let total_bal = coin::balance<DXLP<TestAssetT>>(dev_address);
        gauge_perp::deposit<TestAssetT>(dev, total_bal);

        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);
        let dev_state_balace_after = gauge_perp::balance_of(gauge, dev_address);

        // Verify total supply matches deposited amount
        assert!(supply == lp_balance_before, 0x4);

        // Verify LP balance is 0 after deposit all lp tokens
        assert!(lp_balance_after == 0, 0x5);

        // Verify gague balance matches LP balance of dev before deposit
        assert!(gauge_lp_balance_after == lp_balance_before, 0x6);

        // Verify dev state balance matches LP balance of dev before deposit
        assert!(dev_state_balace_after == lp_balance_before, 0x7);
    }

    // Test 2: Deposit all in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_deposit_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to deposit all (should fail due to emergency mode)
        gauge_perp::deposit<TestAssetT>(dev, 0);
    }

    // Test 3: Deposit all with zero amount (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_INSUFFICIENT_BALANCE,
    )
    ]
    fun gauge_perp_test_deposit_all_zero_amount(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit all with zero amount (should fail)
        gauge_perp::deposit<TestAssetT>(user, 10);
    }

    // Test 4: Deposit all with non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_deposit_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dev_address);

        // Create gauge for BTC/USDT pool
        gauge_perp::test_create_gauge(dev_address, external_bribe, dev_address);

        // Attempt to deposit all with wrong LP token type (should fail)
        gauge_perp::deposit<TestAssetT>(dev, 0);
    }

    // Test 1: Deposit LP tokens into the gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);


        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);
        let dev_state_balace_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);
        assert!(gauge_lp_balance_before == 0, 0x2);
        assert!(dev_state_balace_before == 0, 0x3);

        // Assume user deposits all LP tokens
        let amount_to_deposit = lp_balance_before;
        gauge_perp::deposit<TestAssetT>(dev, amount_to_deposit);

        // Retrieve total supply
        let supply = gauge_perp::total_supply(gauge);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);
        let dev_state_balace_after = gauge_perp::balance_of(gauge, dev_address);

        // Verify total supply matches deposited amount
        assert!(supply == lp_balance_before, 0x4);

        // Verify LP balance is 0 after deposit all lp tokens
        assert!(lp_balance_after == 0, 0x5);

        // Verify gague balance matches LP balance of dev before deposit
        assert!(gauge_lp_balance_after == amount_to_deposit, 0x6);

        // Verify dev state balance matches LP balance of dev before deposit
        assert!(dev_state_balace_after == amount_to_deposit, 0x7);
    }

    // Test 2: Deposit in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_deposit_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to deposit (should fail due to emergency mode)
        gauge_perp::deposit<TestAssetT>(dev, 0);
    }

    // Test 3: Deposit with zero amount (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
    )
    ]
    fun gauge_perp_test_deposit_zero_amount(dev: &signer, user: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit with zero amount (should fail)
        gauge_perp::deposit<TestAssetT>(user, 0);
    }

    // Test 4: Deposit with non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_deposit_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dev_address);

        // Create gauge for BTC/USDT pool
        gauge_perp::test_create_gauge(dev_address, external_bribe, dev_address);

        // Attempt to deposit with wrong LP token type (should fail)
        gauge_perp::deposit<TestAssetT>(dev, 1 * DXLYN_DECIMAL);
    }

    // Test 5: Deposit with insufficient LP tokens (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[expected_failure(abort_code = gauge_perp::ERROR_INSUFFICIENT_BALANCE)]
    fun gauge_perp_test_deposit_insufficient_lp_tokens(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit with zero amount (should fail)
        gauge_perp::deposit<TestAssetT>(user, 100 * DXLYN_DECIMAL);
    }

    // Test 1: Successful withdrawal of all LP tokens
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_withdraw_all_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 10 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Retrieve state before withdrawal
        let supply_before = gauge_perp::total_supply(gauge);
        let lp_owner_balance_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw all LP tokens
        let total_bal = gauge_perp::balance_of(gauge, dev_address);
        gauge_perp::withdraw<TestAssetT>(dev, total_bal);

        // Retrieve state after withdrawal
        let supply_after = gauge_perp::total_supply(gauge);
        let dev_balance_after = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);

        // Verify total supply is 0
        assert!(supply_after == 0, 0x4);
        // Verify user balance in gauge is 0
        assert!(dev_balance_after == 0, 0x5);
        // Verify user LP balance is restored
        assert!(
            lp_balance_after == lp_balance_before + deposit_amount,
            0x6
        );
        // Verify gauge LP balance is 0
        assert!(gauge_lp_balance_after == 0, 0x7);
    }

    // Test 2: Withdraw all in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_withdraw_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw all (should fail due to emergency mode)
        gauge_perp::withdraw<TestAssetT>(dev, 0);
    }

    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(abort_code = gauge_perp::ERROR_INSUFFICIENT_BALANCE)]
    fun gauge_perp_test_unauthorized_withdraw(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw all with zero balance (should fail)
        gauge_perp::withdraw<TestAssetT>(user, 10);
    }

    // Test 4: Withdraw all from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_withdraw_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        // Attempt to withdraw all from non-existent gauge
        gauge_perp::withdraw<TestAssetT>(dev, 0);
    }

    // Test 1: Successful withdrawal of partial LP tokens
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Retrieve state before withdrawal
        let supply_before = gauge_perp::total_supply(gauge);
        let balance_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw partial LP tokens
        let withdraw_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::withdraw<TestAssetT>(dev, withdraw_amount);

        // Retrieve state after withdrawal
        let supply_after = gauge_perp::total_supply(gauge);
        let dev_balance_after = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);

        // Verify total supply decreased by withdrawn amount
        assert!(
            supply_after == deposit_amount - withdraw_amount,
            0x4
        );
        // Verify user balance in gauge decreased by withdrawn amount
        assert!(
            dev_balance_after == deposit_amount - withdraw_amount,
            0x5
        );
        // Verify user LP balance increased by withdrawn amount
        assert!(
            lp_balance_after == lp_balance_before + withdraw_amount,
            0x6
        );
        // Verify gauge LP balance decreased by withdrawn amount
        assert!(
            gauge_lp_balance_after == deposit_amount - withdraw_amount,
            0x7
        );
    }

    // Test 2: Withdraw in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_withdraw_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw (should fail due to emergency mode)
        gauge_perp::withdraw<TestAssetT>(dev, deposit_amount);
    }

    // Test 3: Withdraw with zero amount
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
    )
    ]
    fun gauge_perp_test_withdraw_zero_amount(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);
        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Attempt to withdraw zero amount (should fail)
        gauge_perp::withdraw<TestAssetT>(dev, 0);
    }

    // Test 4: Withdraw with insufficient balance
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_INSUFFICIENT_BALANCE,
    )
    ]
    fun gauge_perp_test_withdraw_insufficient_balance(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Attempt to withdraw more than deposited
        let withdraw_amount = 100 * DXLYN_DECIMAL;
        gauge_perp::withdraw<TestAssetT>(dev, withdraw_amount);
    }

    // Test 5: Withdraw with invalid LP token
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST)]
    fun gauge_perp_test_withdraw_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        // Attempt to withdraw with wrong LP token type (should fail)
        gauge_perp::withdraw<TestAssetT>(dev, 1 * DXLYN_DECIMAL);
    }

    // Test 1: Successful emergency withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_emergency_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_perp::total_supply(gauge);
        let owner_balance_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Perform emergency withdrawal
        let total_bal = gauge_perp::balance_of(gauge, dev_address);
        gauge_perp::emergency_withdraw_amount<TestAssetT>(dev, total_bal);

        // Retrieve state after withdrawal
        let supply_after = gauge_perp::total_supply(gauge);
        let owner_balance_after = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);

        // Verify total supply is 0
        assert!(supply_after == 0, 0x4);
        // Verify user balance in gauge is 0
        assert!(owner_balance_after == 0, 0x5);
        // Verify user LP balance is restored
        assert!(
            lp_balance_after == lp_balance_before + deposit_amount,
            0x6
        );
        // Verify gauge LP balance is 0
        assert!(gauge_lp_balance_after == 0, 0x7);
    }

    // Test 2: Emergency withdrawal in non-emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_NOT_IN_EMERGENCY_MODE,
    )
    ]
    fun gauge_perp_test_emergency_withdraw_non_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Attempt to withdraw without emergency mode (should fail)
        gauge_perp::emergency_withdraw_amount<TestAssetT>(dev, 10);
    }

    // Test 3: Emergency withdrawal with zero balance
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_perp::ERROR_INSUFFICIENT_BALANCE,
    )
    ]
    fun gauge_perp_test_emergency_withdraw_zero_balance(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw with zero balance (should fail)
        gauge_perp::emergency_withdraw_amount<TestAssetT>(user, 10);
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_emergency_withdraw_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);


        // Attempt to withdraw from non-existent gauge
        gauge_perp::emergency_withdraw_amount<TestAssetT>(dev, 10);
    }

    // Test 1: Successful partial emergency withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_emergency_withdraw_amount_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_perp::total_supply(gauge);

        let lp_owner_balance_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw partial amount
        let withdraw_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::emergency_withdraw_amount<TestAssetT>(
            dev, withdraw_amount
        );

        // Retrieve state after withdrawal
        let supply_after = gauge_perp::total_supply(gauge);
        let lp_owner_balance_after = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);

        // Verify total supply decreased
        assert!(
            supply_after == deposit_amount - withdraw_amount,
            0x4
        );
        // Verify user balance decreased
        assert!(
            lp_owner_balance_after == deposit_amount - withdraw_amount,
            0x5
        );
        // Verify user LP balance increased
        assert!(
            lp_balance_after == lp_balance_before + withdraw_amount,
            0x6
        );
        // Verify gauge LP balance decreased
        assert!(
            gauge_lp_balance_after == deposit_amount - withdraw_amount,
            0x7
        );
    }

    // Test 2: Emergency withdrawal in non-emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_NOT_IN_EMERGENCY_MODE)]
    fun gauge_perp_test_emergency_withdraw_amount_non_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Attempt to withdraw without emergency mode
        gauge_perp::emergency_withdraw_amount<TestAssetT>(
            dev, deposit_amount
        );
    }

    // Test 3: Emergency withdrawal with insufficient balance
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure]
    fun gauge_perp_test_emergency_withdraw_amount_insufficient_balance(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw more than balance
        let withdraw_amount = 100 * DXLYN_DECIMAL;
        gauge_perp::emergency_withdraw_amount<TestAssetT>(
            dev, withdraw_amount
        );
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST)]
    fun gauge_perp_test_emergency_withdraw_amount_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        // Attempt to withdraw from non-existent gauge
        gauge_perp::emergency_withdraw_amount<TestAssetT>(dev, 50 * DXLYN_DECIMAL);
    }

    // Test 1: Successful withdrawal and reward harvest
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_withdraw_all_and_harvest_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before withdrawal


        let supply_before = gauge_perp::total_supply(gauge);
        let lp_owner_balance_before = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_before = get_dxlp_balance(dev_address);
        let gauge_lp_balance_before = get_dxlp_balance(gauge);
        let reward_balance_before = dxlyn_coin::balance_of(dev_address);
        let earned_before = gauge_perp::earned(gauge, dev_address);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);
        assert!(earned_before > 0, 0x4);

        // Perform withdraw_all_and_harvest
        let total_bal = gauge_perp::balance_of(gauge, dev_address);
        gauge_perp::withdraw<TestAssetT>(dev, total_bal);
        gauge_perp::get_reward(dev, gauge);

        // Retrieve state after withdrawal
        let supply_after = gauge_perp::total_supply(gauge);

        let dev_balance_after = gauge_perp::balance_of(gauge, dev_address);
        let lp_balance_after = get_dxlp_balance(dev_address);
        let gauge_lp_balance_after = get_dxlp_balance(gauge);
        let reward_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify total supply is 0
        assert!(supply_after == 0, 0x5);
        // Verify user balance in gauge is 0
        assert!(dev_balance_after == 0, 0x6);
        // Verify user LP balance is restored
        assert!(
            lp_balance_after == lp_balance_before + deposit_amount,
            0x7
        );
        // Verify gauge LP balance is 0
        assert!(gauge_lp_balance_after == 0, 0x8);
        // Verify rewards were claimed
        assert!(
            reward_balance_after >= reward_balance_before + earned_before,
            0x9
        );
    }

    // Test 2: Withdraw and harvest in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_withdraw_all_and_harvest_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Activate emergency mode
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw and harvest
        gauge_perp::withdraw<TestAssetT>(dev, 10);
        gauge_perp::get_reward(dev, gauge);
    }

    // Test 4: Withdraw and harvest from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_withdraw_all_and_harvest_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        // Attempt to withdraw and harvest from non-existent gauge
        gauge_perp::get_reward(dev, @0x123);
    }

    // Test 1: Successful reward distribution
    #[test(dev = @dexlyn_tokenomics, )]
    fun gauge_perp_test_get_reward_distribution_success(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let dev_addressess = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge with dev as distribution
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Transfer LP tokens to user and deposit
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before distribution
        let earned_before = gauge_perp::earned(gauge, dev_addressess);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_addressess);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward distribution
        gauge_perp::get_reward_distribution(dev, dev_addressess, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_perp::earned(gauge, dev_addressess);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_addressess);

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
        abort_code = gauge_perp::ERROR_NOT_DISTRIBUTION,
    )]
    fun gauge_perp_test_get_reward_distribution_unauthorized(
        dev: &signer, user: &signer, unauthorized: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(user_address);
        account::create_account_for_test(unauthorized_address);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge with dev as distribution
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Attempt distribution with unauthorized account
        gauge_perp::get_reward_distribution(unauthorized, user_address, gauge);
    }

    // Test 3: Distribution with zero rewards
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    fun gauge_perp_test_get_reward_distribution_zero_rewards(
        dev: &signer, user: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        account::create_account_for_test(user_address);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // No deposits or rewards for user
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(user_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        let earned_before = gauge_perp::earned(gauge, user_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward distribution
        gauge_perp::get_reward_distribution(dev, user_address, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_perp::earned(gauge, user_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(user_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 4: Distribution for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_get_reward_distribution_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Attempt distribution for non-existent gauge
        gauge_perp::get_reward_distribution(dev, address_of(dev), gauge);
    }

    // Test 1: Successful reward claim
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_get_reward_success(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();

        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before claim
        let earned_before = gauge_perp::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_perp::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_perp::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 2: Claim with zero rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_get_reward_zero_rewards(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // No deposits or rewards
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);
        let earned_before = gauge_perp::earned(gauge, dev_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward claim
        gauge_perp::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_perp::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 3: Claim for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_get_reward_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Attempt claim for non-existent gauge
        gauge_perp::get_reward(dev, gauge);
    }

    // Test 4: Claim after withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_get_reward_after_withdrawal(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_perp::deposit<TestAssetT>(dev, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Withdraw all LP tokens
        let total_bal = gauge_perp::balance_of(gauge, dev_address);
        gauge_perp::withdraw<TestAssetT>(dev, total_bal);

        // Retrieve state before claim

        let earned_before = gauge_perp::earned(gauge, dev_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Verify rewards exist
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_perp::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_perp::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 1: Successful reward notification (new period)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_notify_reward_amount_success_new_period(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);

        // Fast-forward to ensure period is finished
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + WEEK + 1);

        // Retrieve state before notification
        let (_, _, _, _, _, _, _, _, _, _, gauge_dxlyn_balance_before) =
            gauge_perp::get_gauge_state(gauge);
        let dev_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Notify reward amount
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);

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
        ) = gauge_perp::get_gauge_state(gauge);
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
        abort_code = gauge_perp::ERROR_NOT_DISTRIBUTION,
    )]
    fun gauge_perp_test_notify_reward_amount_unauthorized(
        dev: &signer, unauthorized: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(unauthorized_address);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Setup DXLYN tokens for unauthorized account
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, unauthorized_address, reward_amount);

        // Attempt notification with unauthorized account
        gauge_perp::notify_reward_amount(unauthorized, gauge, reward_amount);
    }

    // Test 3: Notification in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_perp_test_notify_reward_amount_emergency_mode(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let dxlp_address = get_dxlp_address();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);

        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Activate emergency mode
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        gauge_perp::update_emergency_mode(dev, gauge, true);

        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);

        // Attempt notification in emergency mode
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);
    }

    // Test 4: Notification for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_perp::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_perp_test_notify_reward_amount_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dxlp_address = get_dxlp_address();
        let gauge = gauge_perp::get_gauge_address(dxlp_address);
        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), reward_amount);

        // Attempt notification for non-existent gauge
        gauge_perp::notify_reward_amount(dev, gauge, reward_amount);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_low_liquidity_high_reward_senario(dev: &signer) {
        setup_test_with_genesis(dev);

        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        let dev_address = address_of(dev);
        // Deposit LP tokens
        let deposit_amount = 1 ;

        test_internal_coins::init_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT2"), utf8(b"DXLP_TAT2"), 8, true
        );
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer,
            dev_address,
            deposit_amount
        );


        let dxlp_address = gauge_perp::get_dxlp_coin_address<TestAssetT2>();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);


        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);
        gauge_perp::deposit<TestAssetT2>(dev, deposit_amount);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 1000000 * DXLYN_DECIMAL;
            dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
            gauge_perp::notify_reward_amount(dev, gauge, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_perp::earned(gauge, dev_address);

        // Calculate expected earned rewards
        let reward_per_token = gauge_perp::reward_per_token(gauge);
        let expected = (deposit_amount as u256) * (reward_per_token) / (DXLYN_DECIMAL as u256);

        // Verify earned rewards match expected value
        assert!(earned == (expected as u64), 0x1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_perp_test_high_liquidity_low_reward_senario(dev: &signer) {
        setup_test_with_genesis(dev);

        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        let dev_address = address_of(dev);
        // Deposit LP tokens
        let deposit_amount = 999999999999 * 1000000;

        test_internal_coins::init_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT2"), utf8(b"DXLP_TAT2"), 8, true
        );
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT2>>(
            dexlyn_perp_signer,
            dev_address,
            deposit_amount
        );

        let dxlp_address = gauge_perp::get_dxlp_coin_address<TestAssetT2>();
        let external_bribe = voter::get_external_bribe_address(dxlp_address);


        // Create gauge
        gauge_perp::test_create_gauge(dev_address, external_bribe, dxlp_address);

        // Deposit LP tokens
        gauge_perp::deposit<TestAssetT2>(dev, deposit_amount);
        let gauge = gauge_perp::get_gauge_address(dxlp_address);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 10000;
            dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
            gauge_perp::notify_reward_amount(dev, gauge, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_perp::earned(gauge, dev_address);

        // Verify earned rewards is 0
        assert!(earned == 0, 0x1);
    }
}
