#[test_only]
module dexlyn_tokenomics::gauge_cpmm_test {

    use std::signer::address_of;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{BTC, USDC, USDT};

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voter_cpmm_test;
    use dexlyn_tokenomics::voting_escrow;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // One week in seconds (7 days)
    const WEEK: u64 = 7 * 86400;

    // Precision factor for reward calculations, used to prevent overflow and maintain precision
    const PRECISION: u64 = 10000;

    fun get_liquidity_balance<LpCoin>(user: address): u64 {
        coin::balance<LpCoin>(user)
    }

    // Test setup function to initialize the environment
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
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

        fee_distributor::initialize(dev);

        // Initialize voter contract
        voter::initialize(dev);

        // Set active period to align with current epoch (week boundary)
        minter::set_active_period((timestamp::now_seconds() / WEEK) * WEEK);
    }

    /// (coin_owner, lp_owner, btc_usdt_pool, btc_usdt_pool_lp, usdc_usdt_pool, usdc_usdt_pool_lp)
    fun set_cpmm_pools(): (signer, signer, address, address) {
        let (coin_owner, lp_owner) = voter_cpmm_test::setup_coins_and_lp_owner();
        let (btc_usdt_pool) = voter_cpmm_test::btc_usdt_pool(&coin_owner, &lp_owner);
        let (usdc_usdt_pool) = voter_cpmm_test::usdc_usdt_pool(&coin_owner, &lp_owner);

        (coin_owner, lp_owner, btc_usdt_pool, usdc_usdt_pool)
    }

    // Test 1: Initialize gauge contract and check initial state
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_initialize(dev: &signer) {
        setup_test_with_genesis(dev);

        let gauge_system_owner = gauge_cpmm::get_gauge_system_owner();

        let dev_address = address_of(dev);

        assert!(gauge_system_owner == dev_address, 0x1);
    }

    // Test 2: Reinitialize gaugev2 contract (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun gauge_cpmm_test_reinitialize(dev: &signer) {
        setup_test_with_genesis(dev);

        gauge_cpmm::initialize(dev);
    }

    // Test 1: Create a gauge for the BTC-USDT liquidity pool
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_create_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, btc_usdt_pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let expected_external_bribe_address = voter::get_external_bribe_address(btc_usdt_pool);

        // Create a gauge v2 for the BTC-USDT liquidity pool
        gauge_cpmm::test_create_gauge(
            dev_address,
            expected_external_bribe_address,
            btc_usdt_pool,
        );

        let gauge = gauge_cpmm::get_gauge_address(btc_usdt_pool);

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
        ) = gauge_cpmm::get_gauge_state(gauge);

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
        abort_code = gauge_cpmm::ERROR_GAUGE_ALREADY_EXIST,
    )
    ]
    fun gauge_cpmm_test_create_gauge_twice(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let expected_external_bribe_address = voter::get_external_bribe_address(pool);

        // Create a gauge v2 for the BTC-USDT liquidity pool
        gauge_cpmm::test_create_gauge(
            pool,
            dev_address,
            expected_external_bribe_address,
        );

        // Create a gauge v2 for the BTC-USDT liquidity pool twice (should fail)
        gauge_cpmm::test_create_gauge(
            pool,
            dev_address,
            expected_external_bribe_address,
        );
    }

    // Test 1: Successfully set new distribution address
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_set_distribution_success(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);

        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Set new distribution
        gauge_cpmm::set_distribution(dev, gauge, new_distribution);

        // Verify distribution address updated
        let (_, _, distribution, _, _, _, _, _, _, _, _) =
            gauge_cpmm::get_gauge_state(gauge);
        assert!(distribution == new_distribution, 0x1);
    }

    // Test 2: Attempt to set distribution without creating gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_set_distribution_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();

        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        // Set new distribution without creating gauge (should fail)
        gauge_cpmm::set_distribution(dev, gauge, new_distribution);
    }

    // Test 3: Non-owner attempting to set distribution (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_NOT_OWNER, )]
    fun gauge_cpmm_test_set_distribution_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Create new distribution address
        let new_distribution = @0x123456;
        account::create_account_for_test(new_distribution);

        // Non-owner attempts to set distribution
        gauge_cpmm::set_distribution(non_owner, gauge, new_distribution);
    }

    // Test 4: Setting distribution to zero address (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_ZERO_ADDRESS, )]
    fun gauge_cpmm_test_set_distribution_zero_address(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Attempt to set distribution to zero address
        gauge_cpmm::set_distribution(dev, gauge, @0x0);
    }

    // Test 5: Setting distribution to same address (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_SAME_ADDRESS, )]
    fun gauge_cpmm_test_set_distribution_same_address(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to set distribution to current address
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::set_distribution(dev, gauge, dev_address);
    }

    // Test 1: Successfully activate emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_activate_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Verify emergency mode is active
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_cpmm::get_gauge_state(gauge);
        assert!(emergency, 0x1);
    }

    // Test 2: Non-owner attempting to activate emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_NOT_OWNER, )]
    fun gauge_cpmm_test_activate_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Non-owner attempts to activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(non_owner, gauge, true);
    }

    // Test 3: Activating emergency mode when already active (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_ALREADY_IN_THIS_MODE,
    )
    ]
    fun gauge_cpmm_test_activate_emergency_mode_already_active(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let dev_address = address_of(dev);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to activate emergency mode again
        gauge_cpmm::update_emergency_mode(dev, gauge, true);
    }

    // Test 5: Activating emergency mode for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_activate_emergency_mode_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        // Attempt to activate emergency mode for non-existent gauge
        gauge_cpmm::update_emergency_mode(dev, @0x9999, true);
    }

    // Test 1: Successfully stop emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_stop_emergency_mode_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Activate emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Stop emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, false);

        // Verify emergency mode is deactivated
        let (emergency, _, _, _, _, _, _, _, _, _, _) =
            gauge_cpmm::get_gauge_state(gauge);
        assert!(!emergency, 0x1);
    }

    // Test 2: Non-owner attempting to stop emergency mode (should fail)
    #[test(dev = @dexlyn_tokenomics, non_owner = @0x7890)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_NOT_OWNER, )]
    fun gauge_cpmm_test_stop_emergency_mode_non_owner(
        dev: &signer, non_owner: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Non-owner attempts to stop emergency mode
        gauge_cpmm::update_emergency_mode(non_owner, gauge, false);
    }

    // Test 3: Stopping emergency mode when not active (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_ALREADY_IN_THIS_MODE,
    )
    ]
    fun gauge_cpmm_test_stop_emergency_mode_not_active(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Attempt to stop emergency mode without activating it
        gauge_cpmm::update_emergency_mode(dev, gauge, false);
    }

    // Test 4: Stopping emergency mode for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_stop_emergency_mode_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to stop emergency mode for non-existent gauge
        gauge_cpmm::update_emergency_mode(dev, @0x9999, false);
    }

    // Test 1: Retrieve total supply for a new gauge (should be 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_total_supply_zero(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve total supply
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let supply = gauge_cpmm::total_supply(gauge);

        // Verify total supply is 0
        assert!(supply == 0, 0x1);
    }

    // Test 2: Retrieve total supply after deposit
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    fun gauge_cpmm_test_total_supply_after_deposit(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, btc_usdt_pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(btc_usdt_pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, btc_usdt_pool);

        // Setup user account and mint LP tokens
        let user_address = address_of(user);
        account::create_account_for_test(user_address);
        let gauge = gauge_cpmm::get_gauge_address(btc_usdt_pool);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);

        // User deposits LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);

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
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_total_supply_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve total supply for non-existent gauge
        gauge_cpmm::total_supply(@0x9999);
    }

    // Test 1: Retrieve balance for a new user (should be 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_balance_of_zero(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Retrieve balance
        let balance = gauge_cpmm::balance_of(gauge, dev_address);

        // Verify balance is 0
        assert!(balance == 0, 0x1);
    }

    // Test 2: Retrieve balance after deposit
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_balance_of_after_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve balance
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let lp_owner_addr = address_of(&lp_owner);
        let balance = gauge_cpmm::balance_of(gauge, lp_owner_addr);

        // Verify balance before deposit is 0
        assert!(balance == 0, 0x1);

        // User deposits LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Retrieve balance
        let balance = gauge_cpmm::balance_of(gauge, lp_owner_addr);

        // Verify balance matches deposited amount
        assert!(balance == deposit_amount, 0x2);
    }

    // Test 3: Retrieve balance for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_balance_of_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve balance for non-existent gauge
        let user_address = @0x1234;
        let gauge = gauge_cpmm::get_gauge_address(@0x1234);
        gauge_cpmm::balance_of(gauge, user_address);
    }

    // Test 1: Last time reward applicable for a new gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_last_time_reward_applicable_initial(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve last time reward applicable
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let last_time = gauge_cpmm::last_time_reward_applicable(gauge);

        // Verify it equals 0 (since period_finish is 0)
        assert!(last_time == 0, 0x1);
    }

    // Test 2: Last time reward applicable for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_last_time_reward_applicable_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        // Attempt to retrieve last time reward applicable for non-existent gauge
        gauge_cpmm::last_time_reward_applicable(@0x9999);
    }

    // Test 3: Last time reward applicable during active reward period (returns current timestamp)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_last_time_reward_applicable_active_period(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Get current timestamp (within reward period)
        let current_time = timestamp::now_seconds();

        // Retrieve last time reward applicable
        let last_time = gauge_cpmm::last_time_reward_applicable(gauge);

        // Verify it equals current timestamp (since current_time < period_finish)
        assert!(last_time == current_time, 0x1);
    }

    // Test 4: Last time reward applicable after reward period ends (returns period_finish)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_last_time_reward_applicable_expired_period(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Get period_finish from gauge state
        let (_, _, _, _, _, period_finish, _, _, _, _, _) =
            gauge_cpmm::get_gauge_state(gauge);

        // Fast-forward time past period_finish
        let future_time = period_finish + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve last time reward applicable
        let last_time = gauge_cpmm::last_time_reward_applicable(gauge);

        // Verify it equals period_finish
        assert!(last_time == period_finish, 0x1);
    }

    // Test 1: Reward per token for a new gauge (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_per_token_initial(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Retrieve reward per token
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);

        // Verify reward per token is 0 (no rewards distributed, total_supply is 0)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 2: Reward per token with active reward period but no deposits (should return stored value)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_per_token_no_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup reward distribution
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Retrieve reward per token
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);

        // Verify reward per token is 0 (total_supply is 0, so stored value is returned)
        assert!(reward_per_token == 0, 0x1);
    }

    // Test 3: Reward per token with deposits and active reward period
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_per_token_with_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve reward per token
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);

        // Calculate expected reward per token
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // time_diff = half_week
        // expected = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = (half_week * reward_rate * PRECISION) / deposit_amount;

        // Verify reward per token matches expected value
        assert!((reward_per_token as u64) == expected, 0x1);
    }

    // Test 4: Reward per token after reward period expires
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_per_token_expired_period(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve reward per token
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);

        // Calculate expected reward per token (should stop at period_finish)
        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = (WEEK * reward_rate * PRECISION) / deposit_amount;

        // Verify reward per token matches expected value
        assert!((reward_per_token as u64) == expected, 0x1);
    }

    // Test 5: Reward per token for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_reward_per_token_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);

        // Attempt to retrieve reward per token for non-existent gauge
        gauge_cpmm::reward_per_token(@0x9999);
    }

    // Test 1: Earned rewards for a new user (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_earned_initial(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Retrieve earned rewards
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let earned = gauge_cpmm::earned(gauge, dev_address);

        // Verify earned rewards are 0 (no deposits, no rewards distributed)
        assert!(earned == 0, 0x1);
    }

    // Test 2: Earned rewards with deposits and active reward period
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_earned_with_deposits(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve earned rewards
        let earned = gauge_cpmm::earned(gauge, lp_owner_addr);

        // Calculate expected earned rewards
        // reward_rate = reward_amount / duration = (1000 * 10^8) / (7 * 86400)
        // reward_per_token = (time_diff * reward_rate * DXLYN_DECIMAL) / total_supply
        // earned = balance * reward_per_token
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);
        let expected = deposit_amount * (reward_per_token as u64) / DXLYN_DECIMAL;
        let (cpmm_gauge_total_earned, _, _, cpmm_gauge_earn, _, _) = voter::earned_all_gauges(
            lp_owner_addr,
            vector[gauge],
            vector[],
            vector[]
        );
        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
        assert!(cpmm_gauge_total_earned == expected, 0x2);
        assert!(cpmm_gauge_total_earned == earned, 0x3);
        assert!(*vector::borrow(&cpmm_gauge_earn, 0) == expected, 0x4);

        let (cpmm_gauge_total_earned, _, _, _, _, cpmm_gauge_earn, _, _, _, _) = voter::total_claimable_rewards(
            lp_owner_addr,
            dxlyn_coin::get_dxlyn_asset_address(),
            vector[gauge],
            vector[],
            vector[],
            vector[],
            vector[]
        );

        assert!(cpmm_gauge_total_earned == earned, 0x5);
        assert!(*vector::borrow(&cpmm_gauge_earn, 0) == expected, 0x6);
    }

    // Test 3: Earned rewards after reward period expires
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_earned_expired_period(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time past period_finish
        let future_time = timestamp::now_seconds() + WEEK + 86400; // 1 day after period_finish
        timestamp::update_global_time_for_test_secs(future_time);

        // Retrieve earned rewards
        let lp_owner_addr = address_of(&lp_owner);
        let earned = gauge_cpmm::earned(gauge, lp_owner_addr);

        // Calculate expected earned rewards (should stop at period_finish)
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);

        let expected = deposit_amount * (reward_per_token as u64) / DXLYN_DECIMAL;

        // Verify earned rewards match expected value
        assert!(earned == expected, 0x1);
    }

    // Test 4: Earned rewards for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_earned_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);

        // Attempt to retrieve earned rewards for non-existent gauge
        let user_address = address_of(dev);
        gauge_cpmm::earned(@0x9999, user_address);
    }

    // Test 1: Reward for duration calculation
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_for_duration(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        let reward_rate = (reward_amount * PRECISION) / WEEK;
        let expected = reward_rate * WEEK / PRECISION;
        let reward_for_duration = gauge_cpmm::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == expected, 0x1);
    }

    // Test 2: Reward for duration calculation without notify (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_reward_for_duration_without_notify(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        let reward_for_duration = gauge_cpmm::reward_for_duration(gauge);

        // Verify reward for duration matches expected value
        assert!(reward_for_duration == 0, 0x1);
    }

    // Test 3: Reward for duration calculation for non-existent gauge (should return 0)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_reward_for_duration_non_existent_gauge(
        dev: &signer
    ) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let _ = gauge_cpmm::reward_for_duration(gauge);
    }

    // Test 1: Period finish for a new gauge (should be current time + WEEK)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_period_finish(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        let period_finish = gauge_cpmm::period_finish(gauge);

        // Verify period_finish is set to current time + WEEK
        assert!(
            period_finish == timestamp::now_seconds() + WEEK,
            0x1
        );
    }

    // Test 2: Period finish for non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_period_finish_non_existent_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let _ = gauge_cpmm::period_finish(gauge);
    }

    // Test 1: Deposit all LP tokens into the gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_deposit_all(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let lp_owner_addr = address_of(&lp_owner);

        let dev_state_balace_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);
        assert!(gauge_lp_balance_before == 0, 0x2);
        assert!(dev_state_balace_before == 0, 0x3);

        // User deposits all LP tokens
        let total_bal = coin::balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);
        let dev_state_balace_after = gauge_cpmm::balance_of(gauge, lp_owner_addr);

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
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_deposit_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to deposit all (should fail due to emergency mode)
        let total_bal = gauge_cpmm::balance_of(gauge, dev_address);
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);
    }

    // Test 3: Deposit all with zero amount (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
    )
    ]
    fun gauge_cpmm_test_deposit_all_zero_amount(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit all with zero amount (should fail)
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(user, 0);
    }

    // Test 4: Deposit all with non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_deposit_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge for BTC/USDT pool
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to deposit all with wrong LP token type (should fail)
        gauge_cpmm::deposit<USDC, USDT, Uncorrelated>(dev, 10);
    }

    // Test 1: Deposit LP tokens into the gauge
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_deposit(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);
        let lp_owner_addr = address_of(&lp_owner);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let dev_state_balace_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify total supply before deposit is 0
        assert!(supply == 0, 0x1);
        assert!(gauge_lp_balance_before == 0, 0x2);
        assert!(dev_state_balace_before == 0, 0x3);

        // Assume user deposits all LP tokens
        let amount_to_deposit = lp_balance_before;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, amount_to_deposit);

        // Retrieve total supply
        let supply = gauge_cpmm::total_supply(gauge);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);
        let dev_state_balace_after = gauge_cpmm::balance_of(gauge, lp_owner_addr);

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
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_deposit_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to deposit (should fail due to emergency mode)
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(dev, 0);
    }

    // Test 3: Deposit with zero amount (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
    )
    ]
    fun gauge_cpmm_test_deposit_zero_amount(dev: &signer, user: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit with zero amount (should fail)
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(user, 0);
    }

    // Test 4: Deposit with non-existent gauge (should fail)
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_deposit_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge for BTC/USDT pool
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to deposit with wrong LP token type (should fail)
        gauge_cpmm::deposit<USDC, USDT, Uncorrelated>(dev, 1 * DXLYN_DECIMAL);
    }

    // Test 5: Deposit with insufficient LP tokens (should fail)
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_INSUFFICIENT_BALANCE)]
    fun gauge_cpmm_test_deposit_insufficient_lp_tokens(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account and mint LP tokens (assume user has some LP tokens)
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to deposit with zero amount (should fail)
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(user, 100 * DXLYN_DECIMAL);
    }

    // Test 1: Successful withdrawal of all LP tokens
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_withdraw_all_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 10 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Retrieve state before withdrawal
        let supply_before = gauge_cpmm::total_supply(gauge);
        let lp_owner_balance_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw all LP tokens
        let total_bal = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);

        // Retrieve state after withdrawal
        let supply_after = gauge_cpmm::total_supply(gauge);
        let dev_balance_after = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

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
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_withdraw_all_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw all (should fail due to emergency mode)
        let total_bal = gauge_cpmm::balance_of(gauge, address_of(&lp_owner));
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);
    }

    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(abort_code = gauge_cpmm::ERROR_INSUFFICIENT_BALANCE)]
    fun gauge_cpmm_test_unauthorized_withdraw(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw all with zero balance (should fail)
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(user, 10);
    }

    // Test 4: Withdraw all from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_withdraw_all_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let (_, _, _, _) = set_cpmm_pools();
        // Attempt to withdraw all from non-existent gauge
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(dev, 0);
    }

    // Test 1: Successful withdrawal of partial LP tokens
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, lp_signer, pool, _) = set_cpmm_pools();
        let lp_signer_addr = address_of(&lp_signer);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_signer, deposit_amount);

        // Retrieve state before withdrawal
        let supply_before = gauge_cpmm::total_supply(gauge);
        let balance_before = gauge_cpmm::balance_of(gauge, lp_signer_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_signer_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw partial LP tokens
        let withdraw_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_signer, withdraw_amount);

        // Retrieve state after withdrawal
        let supply_after = gauge_cpmm::total_supply(gauge);
        let dev_balance_after = gauge_cpmm::balance_of(gauge, lp_signer_addr);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_signer_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

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
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_withdraw_emergency_mode(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw (should fail due to emergency mode)
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);
    }

    // Test 3: Withdraw with zero amount
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
    )
    ]
    fun gauge_cpmm_test_withdraw_zero_amount(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);
        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Attempt to withdraw zero amount (should fail)
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(dev, 0);
    }

    // Test 4: Withdraw with insufficient balance
    #[test(dev = @dexlyn_tokenomics)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_INSUFFICIENT_BALANCE,
    )
    ]
    fun gauge_cpmm_test_withdraw_insufficient_balance(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Attempt to withdraw more than deposited
        let withdraw_amount = 100 * DXLYN_DECIMAL;
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, withdraw_amount);
    }

    // Test 5: Withdraw with invalid LP token
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST)]
    fun gauge_cpmm_test_withdraw_non_existent_gauge(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, _, _) = set_cpmm_pools();

        // Attempt to withdraw with wrong LP token type (should fail)
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(dev, 1 * DXLYN_DECIMAL);
    }

    // Test 1: Successful emergency withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_emergency_withdraw_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Activate emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_cpmm::total_supply(gauge);
        let owner_balance_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Perform emergency withdrawal
        let total_bal = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);

        // Retrieve state after withdrawal
        let supply_after = gauge_cpmm::total_supply(gauge);
        let owner_balance_after = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

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
        abort_code = gauge_cpmm::ERROR_NOT_IN_EMERGENCY_MODE,
    )
    ]
    fun gauge_cpmm_test_emergency_withdraw_non_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Attempt to withdraw without emergency mode (should fail)
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(&lp_owner, 10);
    }

    // Test 3: Emergency withdrawal with zero balance
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    #[
    expected_failure(
        abort_code = gauge_cpmm::ERROR_INSUFFICIENT_BALANCE,
    )
    ]
    fun gauge_cpmm_test_emergency_withdraw_zero_balance(
        dev: &signer, user: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Setup user account with no deposits
        let user_address = address_of(user);
        account::create_account_for_test(user_address);

        // Attempt to withdraw with zero balance (should fail)
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(user, 10);
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_emergency_withdraw_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, _, _) = set_cpmm_pools();


        // Attempt to withdraw from non-existent gauge
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(dev, 10);
    }

    // Test 1: Successful partial emergency withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_emergency_withdraw_amount_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Activate emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Retrieve state before withdrawal
        let supply_before = gauge_cpmm::total_supply(gauge);
        let lp_owner_addr = address_of(&lp_owner);
        let lp_owner_balance_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);

        // Withdraw partial amount
        let withdraw_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(
            &lp_owner, withdraw_amount
        );

        // Retrieve state after withdrawal
        let supply_after = gauge_cpmm::total_supply(gauge);
        let lp_owner_balance_after = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);

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
    #[expected_failure(abort_code = gauge_cpmm::ERROR_NOT_IN_EMERGENCY_MODE)]
    fun gauge_cpmm_test_emergency_withdraw_amount_non_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Attempt to withdraw without emergency mode
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(
            &lp_owner, deposit_amount
        );
    }

    // Test 3: Emergency withdrawal with insufficient balance
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure]
    fun gauge_cpmm_test_emergency_withdraw_amount_insufficient_balance(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(dev, deposit_amount);

        // Activate emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw more than balance
        let withdraw_amount = 100 * DXLYN_DECIMAL;
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(
            dev, withdraw_amount
        );
    }

    // Test 4: Emergency withdrawal from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST)]
    fun gauge_cpmm_test_emergency_withdraw_amount_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, _, _) = set_cpmm_pools();

        // Attempt to withdraw from non-existent gauge
        gauge_cpmm::emergency_withdraw_amount<BTC, USDT, Uncorrelated>(dev, 50 * DXLYN_DECIMAL);
    }

    // Test 1: Successful withdrawal and reward harvest
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_withdraw_all_and_harvest_success(dev: &signer) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time by half a week to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before withdrawal
        let lp_owner_addr = address_of(&lp_owner);

        let supply_before = gauge_cpmm::total_supply(gauge);
        let lp_owner_balance_before = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        let lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_before = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);
        let reward_balance_before = dxlyn_coin::balance_of(lp_owner_addr);
        let earned_before = gauge_cpmm::earned(gauge, lp_owner_addr);

        // Verify initial state
        assert!(supply_before == deposit_amount, 0x1);
        assert!(lp_owner_balance_before == deposit_amount, 0x2);
        assert!(gauge_lp_balance_before == deposit_amount, 0x3);
        assert!(earned_before > 0, 0x4);

        // Perform withdraw_all_and_harvest
        let total_bal = gauge_cpmm::balance_of(gauge, lp_owner_addr);
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);
        gauge_cpmm::get_reward(&lp_owner, gauge);

        // Retrieve state after withdrawal
        let supply_after = gauge_cpmm::total_supply(gauge);

        let dev_balance_after = gauge_cpmm::balance_of(gauge, dev_address);
        let lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(lp_owner_addr);
        let gauge_lp_balance_after = get_liquidity_balance<LP<BTC, USDT, Uncorrelated>>(gauge);
        let reward_balance_after = dxlyn_coin::balance_of(lp_owner_addr);

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
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_harvest_emergency_mode(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Activate emergency mode
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Attempt to withdraw and harvest
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);
        gauge_cpmm::get_reward(&lp_owner, gauge);
    }

    // Test 4: Withdraw and harvest from non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_harvest_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment with liquidity pool
        setup_test_with_genesis(dev);
        let (_, _, _, _) = set_cpmm_pools();

        // Attempt to withdraw and harvest from non-existent gauge
        gauge_cpmm::get_reward(dev, @0x123);
    }

    // Test 1: Successful reward distribution
    #[test(dev = @dexlyn_tokenomics, )]
    fun gauge_cpmm_test_get_reward_distribution_success(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_address = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge with dev as distribution
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Transfer LP tokens to user and deposit
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before distribution
        let earned_before = gauge_cpmm::earned(gauge, lp_owner_address);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(lp_owner_address);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward distribution
        gauge_cpmm::get_reward_distribution(dev, lp_owner_address, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_cpmm::earned(gauge, lp_owner_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(lp_owner_address);

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
        abort_code = gauge_cpmm::ERROR_NOT_DISTRIBUTION,
    )]
    fun gauge_cpmm_test_get_reward_distribution_unauthorized(
        dev: &signer, user: &signer, unauthorized: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(user_address);
        account::create_account_for_test(unauthorized_address);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge with dev as distribution
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Attempt distribution with unauthorized account
        gauge_cpmm::get_reward_distribution(unauthorized, user_address, gauge);
    }

    // Test 3: Distribution with zero rewards
    #[test(dev = @dexlyn_tokenomics, user = @0x1234)]
    fun gauge_cpmm_test_get_reward_distribution_zero_rewards(
        dev: &signer, user: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let user_address = address_of(user);
        account::create_account_for_test(user_address);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // No deposits or rewards for user
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(user_address);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        let earned_before = gauge_cpmm::earned(gauge, user_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward distribution
        gauge_cpmm::get_reward_distribution(dev, user_address, gauge);

        // Retrieve state after distribution
        let earned_after = gauge_cpmm::earned(gauge, user_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(user_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 4: Distribution for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_get_reward_distribution_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Attempt distribution for non-existent gauge
        gauge_cpmm::get_reward_distribution(dev, address_of(&lp_owner), gauge);
    }

    // Test 1: Successful reward claim
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_get_reward_success(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time to accrue rewards
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Retrieve state before claim
        let earned_before = gauge_cpmm::earned(gauge, lp_owner_addr);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(lp_owner_addr);

        // Verify initial state
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_cpmm::get_reward(&lp_owner, gauge);

        // Retrieve state after claim
        let earned_after = gauge_cpmm::earned(gauge, lp_owner_addr);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(lp_owner_addr);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 2: Claim with zero rewards
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_get_reward_zero_rewards(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // No deposits or rewards
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);
        let earned_before = gauge_cpmm::earned(gauge, dev_address);

        // Verify initial state
        assert!(earned_before == 0, 0x1);

        // Perform reward claim
        gauge_cpmm::get_reward(dev, gauge);

        // Retrieve state after claim
        let earned_after = gauge_cpmm::earned(gauge, dev_address);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(dev_address);

        // Verify no changes
        assert!(earned_after == 0, 0x2);
        assert!(user_dxlyn_balance_after == user_dxlyn_balance_before, 0x3);
    }

    // Test 3: Claim for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_get_reward_non_existent_gauge(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Attempt claim for non-existent gauge
        gauge_cpmm::get_reward(dev, gauge);
    }

    // Test 4: Claim after withdrawal
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_get_reward_after_withdrawal(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Deposit LP tokens
        let deposit_amount = 50 * DXLYN_DECIMAL;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);

        // Setup reward distribution
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

        // Fast-forward time
        let half_week = WEEK / 2;
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds()
            + half_week);

        // Withdraw all LP tokens
        let total_bal = gauge_cpmm::balance_of(gauge, address_of(&lp_owner));
        gauge_cpmm::withdraw<BTC, USDT, Uncorrelated>(&lp_owner, total_bal);

        // Retrieve state before claim
        let lp_owner_addr = address_of(&lp_owner);
        let earned_before = gauge_cpmm::earned(gauge, lp_owner_addr);
        let user_dxlyn_balance_before = dxlyn_coin::balance_of(lp_owner_addr);

        // Verify rewards exist
        assert!(earned_before > 0, 0x1);

        // Perform reward claim
        gauge_cpmm::get_reward(&lp_owner, gauge);

        // Retrieve state after claim
        let earned_after = gauge_cpmm::earned(gauge, lp_owner_addr);
        let user_dxlyn_balance_after = dxlyn_coin::balance_of(lp_owner_addr);

        // Verify rewards claimed
        assert!(earned_after == 0, 0x2);
        assert!(
            user_dxlyn_balance_after == user_dxlyn_balance_before + earned_before,
            0x3
        );
    }

    // Test 1: Successful reward notification (new period)
    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_notify_reward_amount_success_new_period(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);

        // Fast-forward to ensure period is finished
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + WEEK + 1);

        // Retrieve state before notification
        let (_, _, _, _, _, _, _, _, _, _, gauge_dxlyn_balance_before) =
            gauge_cpmm::get_gauge_state(gauge);
        let dev_dxlyn_balance_before = dxlyn_coin::balance_of(dev_address);

        // Notify reward amount
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);

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
        ) = gauge_cpmm::get_gauge_state(gauge);
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
        abort_code = gauge_cpmm::ERROR_NOT_DISTRIBUTION,
    )]
    fun gauge_cpmm_test_notify_reward_amount_unauthorized(
        dev: &signer, unauthorized: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let unauthorized_address = address_of(unauthorized);
        account::create_account_for_test(unauthorized_address);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Setup DXLYN tokens for unauthorized account
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, unauthorized_address, reward_amount);

        // Attempt notification with unauthorized account
        gauge_cpmm::notify_reward_amount(unauthorized, gauge, reward_amount);
    }

    // Test 3: Notification in emergency mode
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_IN_EMERGENCY_MODE,
    )]
    fun gauge_cpmm_test_notify_reward_amount_emergency_mode(dev: &signer) {
        // Setup environment
        setup_test_with_genesis(dev);
        let dev_address = address_of(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Activate emergency mode
        let gauge = gauge_cpmm::get_gauge_address(pool);
        gauge_cpmm::update_emergency_mode(dev, gauge, true);

        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);

        // Attempt notification in emergency mode
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);
    }

    // Test 4: Notification for non-existent gauge
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(
        abort_code = gauge_cpmm::ERROR_GAUGE_NOT_EXIST,
    )]
    fun gauge_cpmm_test_notify_reward_amount_non_existent_gauge(
        dev: &signer
    ) {
        // Setup environment
        setup_test_with_genesis(dev);
        let (_, _, pool, _) = set_cpmm_pools();
        let gauge = gauge_cpmm::get_gauge_address(pool);
        // Setup DXLYN tokens
        let reward_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), reward_amount);

        // Attempt notification for non-existent gauge
        gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_low_liquidity_high_reward_senario(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 1 ;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 1000000 * DXLYN_DECIMAL;
            dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
            gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_cpmm::earned(gauge, lp_owner_addr);

        // Calculate expected earned rewards
        let reward_per_token = gauge_cpmm::reward_per_token(gauge);
        let expected = (deposit_amount as u256) * (reward_per_token) / (DXLYN_DECIMAL as u256);

        // Verify earned rewards match expected value
        assert!(earned == (expected as u64), 0x1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun gauge_cpmm_test_high_liquidity_low_reward_senario(dev: &signer) {
        setup_test_with_genesis(dev);

        let dev_address = address_of(dev);
        let (_, lp_owner, pool, _) = set_cpmm_pools();
        let lp_owner_addr = address_of(&lp_owner);
        let external_bribe = voter::get_external_bribe_address(pool);

        // Create gauge
        gauge_cpmm::test_create_gauge(dev_address, external_bribe, pool);

        // Deposit LP tokens
        let deposit_amount = 999999999999 * 1000000;
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&lp_owner, deposit_amount);
        let gauge = gauge_cpmm::get_gauge_address(pool);

        // reward added for 1000 weeks without any withdrawal
        let week = 1000;
        for (i in 0..week) {
            // Setup reward distribution
            let reward_amount = 10000;
            dxlyn_coin::register_and_mint(dev, dev_address, reward_amount);
            gauge_cpmm::notify_reward_amount(dev, gauge, reward_amount);
            timestamp::fast_forward_seconds(WEEK);
        };

        // Retrieve earned rewards
        let earned = gauge_cpmm::earned(gauge, lp_owner_addr);

        // Verify earned rewards is 0
        assert!(earned == 0, 0x1);
    }
}
