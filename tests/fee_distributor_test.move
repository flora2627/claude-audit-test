#[test_only]
module dexlyn_tokenomics::fee_distribution_test {

    use std::signer::address_of;
    use std::vector;

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account::{Self, create_signer_for_test};
    use supra_framework::block;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::object;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::test_nft;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test;

    // const dev:address =  @dexlyn_tokenomics;
    const SC_ADMIN: address = @dexlyn_tokenomics;
    const DAY: u64 = 86400;
    const INITIAL_SUPPLY: u64 = 100_000_000;
    // all future times are rounded by week
    const WEEK: u64 = 604800;
    // 4 years
    const MAXTIME: u64 = 126144000;
    const MULTIPLIER: u64 = 1000000000000;
    const DXLYN_DECIMAL: u64 = 100000000;
    const TOKEN_CHECKPOINT_DEADLINE: u64 = 86400;
    // Scaling factor (10^4) for scale amount
    const AMOUNT_SCALE: u64 = 10000;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup();
        //set current time
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    #[test_only]
    fun setup_test(dev: &signer) {
        account::create_account_for_test(address_of(dev));

        block::update_block_number(10);

        //initialize DXLYN coin
        test_internal_coins::init_coin(dev);

        voting_escrow::initialize(dev);

        fee_distributor::initialize(dev);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test(dev = @dexlyn_tokenomics)]
    fun test_initialize(dev: &signer) {
        setup_test_with_genesis(dev);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_reinitialize(dev: &signer) {
        setup_test_with_genesis(dev);

        let supra_signer = create_signer_for_test(@0x1);
        coin::create_coin_conversion_map(&supra_signer);

        //reinitialize the twice
        fee_distributor::initialize(dev);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    //commit_admin test cases start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_commit_admin(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let dev_address = address_of(dev);
        let alice_address = address_of(alice);

        //change future owner from dev to alice
        fee_distributor::commit_admin(dev, alice_address);

        let (_, _, _, _, _, _, admin, future_admin, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(admin == dev_address, 0x1);
        assert!(future_admin == alice_address, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_commit_admin_with_non_admin_account(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        //change future owner from dev to alice
        fee_distributor::commit_admin(alice, alice_address);
    }
    //commit_admin test cases end

    // apply_admin test cases start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_apply_admin(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        // Create account for Alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        // Set future_admin to Alice
        fee_distributor::commit_admin(dev, alice_address);

        // Apply ownership transfer
        fee_distributor::apply_admin(dev);

        // Verify state
        let (_, _, _, _, _, _, admin, future_admin, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(admin == alice_address, 0x3); // Admin should be Alice
        assert!(future_admin == alice_address, 0x4); // Future admin remains Alice (or @0x0 if reset)
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_apply_admin_with_non_admin_account(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);

        // Create account for Alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        // Set future_admin to Alice
        fee_distributor::commit_admin(dev, alice_address);

        // Try to apply ownership transfer as non-admin (Alice)
        fee_distributor::apply_admin(alice);
    }

    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = fee_distributor::ERROR_ZERO_ADDRESS, location = fee_distributor)]
    fun test_apply_admin_with_no_future_admin(dev: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        // Try to apply ownership transfer without setting future_admin
        fee_distributor::apply_admin(dev);
    }
    // apply_admin test cases end

    //checkpoint_token test case start
    #[test(dev = @dexlyn_tokenomics)]
    fun test_checkpoint_token_before_distribute_token(dev: &signer) {
        setup_test_with_genesis(dev);

        let (
            _,
            _,
            last_token_time,
            coin_balance,
            total_received,
            token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();

        let start_time = timestamp::now_seconds() / WEEK * WEEK;
        let token_per_week = fee_distributor::get_tokens_per_week(start_time);

        assert!(last_token_time == start_time, 0x5);
        assert!(coin_balance == 0, 0x6);
        assert!(total_received == 0, 0x7);
        assert!(token_last_balance == 0, 0x8);
        assert!(token_per_week == 0, 0x9);

        //fast forward time by one week
        timestamp::fast_forward_seconds(WEEK);

        //check checkpoint token for first time by admin without sending any token to for distribution
        fee_distributor::checkpoint_token(dev);

        let (
            _,
            _,
            last_token_time,
            coin_balance,
            total_received,
            token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();

        let token_per_week_after_checkpoint =
            fee_distributor::get_tokens_per_week(timestamp::now_seconds());

        assert!(last_token_time == timestamp::now_seconds(), 0x10);
        assert!(coin_balance == 0, 0x11);
        assert!(total_received == 0, 0x12);
        assert!(token_last_balance == 0, 0x13);
        assert!(token_per_week_after_checkpoint == 0, 0x14);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_checkpoint_token_after_distribute_token(dev: &signer) {
        setup_test_with_genesis(dev);

        let (_, _, last_token_time, coin_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        let start_time = timestamp::now_seconds() / WEEK * WEEK;
        let token_per_week = fee_distributor::get_tokens_per_week(start_time);

        assert!(last_token_time == start_time, 0x5);
        assert!(coin_balance == 0, 0x6);
        assert!(token_last_balance == 0, 0x7);
        assert!(token_per_week == 0, 0x8);

        //mint DXLYN token
        let amount = 10 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), amount);

        //distribute DXLYN token without checkpoint token
        fee_distributor::burn(dev, amount);

        //check checkpoint token for first time by admin after sending token for distribution ( all go to same week)
        fee_distributor::checkpoint_token(dev);

        let (_, _, last_token_time, coin_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        let token_per_week_after_checkpoint =
            fee_distributor::get_tokens_per_week(start_time);

        assert!(last_token_time == timestamp::now_seconds(), 0x9);
        assert!(coin_balance == amount, 0x10);
        assert!(token_last_balance == amount, 0x11);
        assert!(token_per_week_after_checkpoint == amount, 0x12);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_checkpoint_token_proportional_distribution(dev: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let start_time = timestamp::now_seconds() / WEEK * WEEK;

        // Mint and distribute tokens
        let amount = 10 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), amount);
        fee_distributor::burn(dev, amount);

        // Fast forward by one and a half weeks
        let one_and_half_week = WEEK + (WEEK / 2);
        timestamp::fast_forward_seconds(one_and_half_week);

        // Call checkpoint_token
        fee_distributor::checkpoint_token(dev);

        // Verify state
        let next_week = start_time + WEEK;
        let (_, _, last_token_time, coin_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        let token_per_week_start = fee_distributor::get_tokens_per_week(start_time);
        let token_per_week_next = fee_distributor::get_tokens_per_week(next_week);

        assert!(
            last_token_time == start_time + one_and_half_week,
            0x13
        ); // Updated to current time
        assert!(coin_balance == amount, 0x14); // Coin balance unchanged
        assert!(token_last_balance == amount, 0x15); // Matches coin balance
        assert!(
            token_per_week_start == amount * WEEK / one_and_half_week,
            0x16
        ); // Proportional to time in start week
        assert!(
            token_per_week_next
                == amount * (one_and_half_week - WEEK) / one_and_half_week,
            0x17
        ); // Proportional to time in next
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_checkpoint_token_non_admin_with_permission(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        // Mint and distribute tokens
        let amount = 10 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), amount);
        fee_distributor::burn(dev, amount);

        // Enable checkpoint for non-admins
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward past TOKEN_CHECKPOINT_DEADLINE (86400 seconds)
        timestamp::fast_forward_seconds(TOKEN_CHECKPOINT_DEADLINE + 1);

        // Non-admin (Alice) calls checkpoint_token
        fee_distributor::checkpoint_token(alice);

        // Verify state
        let start_time = 1746057600; // From setup (timestamp::now_seconds() / WEEK * WEEK)
        let (_, _, last_token_time, coin_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        let token_per_week = fee_distributor::get_tokens_per_week(start_time);

        assert!(last_token_time == timestamp::now_seconds(), 0x18); // Updated to current time
        assert!(coin_balance == amount, 0x19); // Coin balance unchanged
        assert!(token_last_balance == amount, 0x20); // Matches coin balance
        assert!(token_per_week == amount, 0x21); // All tokens allocated to start_time week
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ALLOWED, location = fee_distributor)]
    // ERROR_NOT_ALLOWED
    fun test_checkpoint_token_non_admin_no_permission(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        // Non-admin (Alice) tries to call checkpoint_token
        fee_distributor::checkpoint_token(alice);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_checkpoint_token_large_time_gap(dev: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        // Mint and distribute tokens
        let amount = 10 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, address_of(dev), amount);
        fee_distributor::burn(dev, amount);

        // Fast forward by 5 weeks
        let five_weeks = 5 * WEEK;
        timestamp::fast_forward_seconds(five_weeks);

        // Call checkpoint_token
        fee_distributor::checkpoint_token(dev);

        // Verify state
        let start_time = 1746057600;
        let (_, _, last_token_time, coin_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(last_token_time == 1746057600 + five_weeks, 0x24); // Updated to current time
        assert!(coin_balance == amount, 0x25); // Coin balance unchanged
        assert!(token_last_balance == amount, 0x26); // Matches coin balance

        let token_for_week1 = fee_distributor::get_tokens_per_week(start_time);
        let token_for_week2 = fee_distributor::get_tokens_per_week(start_time + WEEK);
        let token_for_week3 = fee_distributor::get_tokens_per_week(start_time
            + (WEEK * 2));
        let token_for_week4 = fee_distributor::get_tokens_per_week(start_time
            + (WEEK * 3));
        let token_for_week5 = fee_distributor::get_tokens_per_week(start_time
            + (WEEK * 4));

        assert!(token_for_week1 == amount / 5, 0x27); // Tokens for week 1
        assert!(token_for_week2 == amount / 5, 0x28); // Tokens for week 2
        assert!(token_for_week3 == amount / 5, 0x29); // Tokens for week 3
        assert!(token_for_week4 == amount / 5, 0x30); // Tokens for week 4
        assert!(token_for_week5 == amount / 5, 0x31); // Tokens for week 5
    }
    //checkpoint_token test case end

    // checkpoint_total_supply test cases start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_checkpoint_total_supply(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (5 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + (WEEK * 5); // 5 week

        let current_ve_supply = fee_distributor::get_ve_supply_at(
            current_time / WEEK * WEEK
        );
        assert!(current_ve_supply == 0, 0x34);

        // Create lock which will mint nft with id 1
        voting_escrow::create_lock(alice, value, unlock_time);

        //check total supply for current week
        fee_distributor::checkpoint_total_supply();

        let current_ve_supply = fee_distributor::get_ve_supply_at(
            current_time / WEEK * WEEK
        );
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(
            current_ve_supply
                == (value * AMOUNT_SCALE / MAXTIME)
                * (unlock_time - timestamp::now_seconds()),
            0x35
        );
        assert!(
            time_cursor == timestamp::now_seconds() + WEEK / WEEK * WEEK,
            0x36
        );

        //fast forward time
        timestamp::fast_forward_seconds(WEEK);

        //check total supply for next week
        fee_distributor::checkpoint_total_supply();

        let ve_supply_after_week =
            fee_distributor::get_ve_supply_at(timestamp::now_seconds() / WEEK * WEEK);
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(
            ve_supply_after_week
                == (value * AMOUNT_SCALE / MAXTIME)
                * (unlock_time - timestamp::now_seconds()),
            0x37
        );
        assert!(
            time_cursor == timestamp::now_seconds() + WEEK / WEEK * WEEK,
            0x38
        );
    }

    #[test(
        dev = @dexlyn_tokenomics, alice = @0x123, bob = @0x456, charlie = @0x789
    )]
    fun test_checkpoint_total_supply_multi_users(
        dev: &signer,
        alice: &signer,
        bob: &signer,
        charlie: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        let bob_address = address_of(bob);
        let charlie_address = address_of(charlie);
        account::create_account_for_test(alice_address);
        account::create_account_for_test(bob_address);
        account::create_account_for_test(charlie_address);

        // Register and mint DXLYN to accounts
        let alice_value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        let bob_value = 2000 * DXLYN_DECIMAL; // 2000 DXLYN
        let charlie_value = 500 * DXLYN_DECIMAL; // 500 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, alice_value);
        dxlyn_coin::register_and_mint(dev, bob_address, bob_value);
        dxlyn_coin::register_and_mint(dev, charlie_address, charlie_value);

        // Set timestamps
        let current_time = timestamp::now_seconds(); // e.g., 1000
        let max_lock_time = (current_time + MAXTIME) / WEEK * WEEK; // 4 years (rounded down to nearest week not exact 4 years)
        let short_lock_time = current_time + (WEEK * 2); // 2 weeks

        // Create locks
        voting_escrow::create_lock(alice, alice_value, max_lock_time); // Max lock: 1000 DXLYN
        voting_escrow::create_lock(bob, bob_value, max_lock_time); // Max lock: 2000 DXLYN
        voting_escrow::create_lock(charlie, charlie_value, short_lock_time); // Short lock: 500 DXLYN for 2 weeks

        // Checkpoint total supply for current week
        fee_distributor::checkpoint_total_supply();

        let week_start = current_time / WEEK * WEEK;
        let current_ve_supply = fee_distributor::get_ve_supply_at(week_start);
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // Calculate expected voting power (in DXLYN, since ve_supply is divided by MULTIPLIER)
        let expected_ve_supply =
            (((alice_value * AMOUNT_SCALE / MAXTIME)
                * (max_lock_time - timestamp::now_seconds())) + (
                (bob_value * AMOUNT_SCALE / MAXTIME)
                    * (max_lock_time - timestamp::now_seconds())
            ) + ((charlie_value * AMOUNT_SCALE / MAXTIME)
                * (short_lock_time - timestamp::now_seconds())));

        assert!(current_ve_supply == expected_ve_supply, 0x38);
        assert!(time_cursor == week_start + WEEK, 0x39);

        // Fast forward 1 week (Charlie's lock still active)
        timestamp::fast_forward_seconds(WEEK);
        fee_distributor::checkpoint_total_supply();

        let next_week = timestamp::now_seconds() / WEEK * WEEK;
        let ve_supply_week1 = fee_distributor::get_ve_supply_at(next_week);
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // Charlie's lock is still active (1 week left)
        // Voting power decreases slightly due to slope
        let expected_ve_supply_week1 =
            (((alice_value * AMOUNT_SCALE / MAXTIME)
                * (max_lock_time - timestamp::now_seconds())) + (
                (bob_value * AMOUNT_SCALE / MAXTIME)
                    * (max_lock_time - timestamp::now_seconds())
            ) + ((charlie_value * AMOUNT_SCALE / MAXTIME)
                * (short_lock_time - timestamp::now_seconds())));

        assert!(ve_supply_week1 == expected_ve_supply_week1, 0x40);
        assert!(time_cursor == next_week + WEEK, 0x41);

        // Fast forward 2 weeks (Charlie's lock expires)
        timestamp::fast_forward_seconds(WEEK * 2);
        fee_distributor::checkpoint_total_supply();

        let week3 = timestamp::now_seconds() / WEEK * WEEK;
        let ve_supply_week3 = fee_distributor::get_ve_supply_at(week3);
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // Charlie's lock has expired (voting power = 0)
        let expected_ve_supply_week3 =
            (((alice_value * AMOUNT_SCALE / MAXTIME)
                * (max_lock_time - timestamp::now_seconds())) + (
                (bob_value * AMOUNT_SCALE / MAXTIME)
                    * (max_lock_time - timestamp::now_seconds())
            ));

        assert!(ve_supply_week3 == expected_ve_supply_week3, 0x42);
        assert!(time_cursor == week3 + WEEK, 0x43);

        let last_time_cursor = time_cursor;

        // Fast forward far into the future (all locks expired)
        timestamp::fast_forward_seconds(MAXTIME);
        fee_distributor::checkpoint_total_supply();

        let future_week = timestamp::now_seconds() / WEEK * WEEK;
        let ve_supply_future = fee_distributor::get_ve_supply_at(future_week);
        let (_, time_cursor, _, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // All locks expired, ve_supply should be 0
        assert!(ve_supply_future == 0, 0x44);
        assert!(
            time_cursor == last_time_cursor + (WEEK * 20),
            0x45
        ); // in one check point supply call we can only process 20 weeks
    }
    // checkpoint_total_supply test cases end

    //toggle_allow_checkpoint_token test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_toggle_allow_checkpoint_token_to_true(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Verify initial state
        let (_, _, _, _, _, _, _, _, can_checkpoint_token, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(!can_checkpoint_token, 0x86); // Initially false

        // Admin toggles to true
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Verify state after toggle
        let (_, _, _, _, _, _, _, _, new_can_checkpoint_token, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(new_can_checkpoint_token, 0x87); // Toggled to true
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_toggle_allow_checkpoint_token_to_false(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Set can_checkpoint_token to true first
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Verify state before second toggle
        let (_, _, _, _, _, _, _, _, can_checkpoint_token, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(can_checkpoint_token, 0x88); // Set to true

        // Admin toggles to false
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Verify state after toggle
        let (_, _, _, _, _, _, _, _, new_can_checkpoint_token, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(!new_can_checkpoint_token, 0x89); // Toggled back to false
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_toggle_allow_checkpoint_token_non_admin(
        dev: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Non-admin attempts to toggle
        fee_distributor::toggle_allow_checkpoint_token(alice); // Should fail with ERROR_NOT_ADMIN
    }
    //toggle_allow_checkpoint_token test case end

    //kill_me test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_kill_me_with_tokens(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        let emergency_address = address_of(dev);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let mint_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, mint_amount);

        // Burn 100 DXLYN to fee_distributor
        fee_distributor::burn(alice, mint_amount);

        // Verify initial state
        let (_, _, _, coins_balance, _, _, _, _, _, _, is_killed) =
            fee_distributor::get_fee_distributor_state();
        assert!(coins_balance == mint_amount, 0x90); // Coins in fee_distributor
        assert!(!is_killed, 0xA1); // Not killed initially

        let emergency_address_balance = dxlyn_coin::balance_of(emergency_address);
        assert!(emergency_address_balance == 0, 0x91); // Emergency address has no coins

        // Admin calls kill_me
        fee_distributor::kill_me(dev);

        // Verify state after kill
        let (_, _, _, new_coins_balance, _, _, _, _, _, _, new_is_killed) =
            fee_distributor::get_fee_distributor_state();
        assert!(new_is_killed, 0x92); // Contract is killed
        assert!(new_coins_balance == 0, 0x93); // All coins extracted
        assert!(
            dxlyn_coin::balance_of(emergency_address) == mint_amount,
            0x94
        ); // Coins transferred to emergency_return
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_kill_me_no_tokens(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);
        let alice_address = address_of(alice);
        let emergency_address = address_of(dev);
        account::create_account_for_test(alice_address);

        // Verify initial state
        let (_, _, _, coins_balance, _, _, _, _, _, _, is_killed) =
            fee_distributor::get_fee_distributor_state();
        assert!(coins_balance == 0, 0x95); // No coins initially
        assert!(!is_killed, 0x96); // Not killed initially
        assert!(
            dxlyn_coin::balance_of(emergency_address) == 0,
            0x97
        ); // Emergency address has no coins

        // Admin calls kill_me
        fee_distributor::kill_me(dev);

        // Verify state after kill
        let (_, _, _, new_coins_balance, _, _, _, _, _, _, new_is_killed) =
            fee_distributor::get_fee_distributor_state();
        assert!(new_is_killed, 0x98); // Contract is killed
        assert!(new_coins_balance == 0, 0x99); // Still no coins
        assert!(
            dxlyn_coin::balance_of(emergency_address) == 0,
            0x100
        ); // No coins transferred
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_kill_me_non_admin(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Non-admin attempts to call kill_me
        fee_distributor::kill_me(alice); // Should fail with ERROR_NOT_ADMIN
    }
    //kill_me test case end

    //recover_balance test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_recover_balance_fa_non_dxlyn(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        let dev_address = address_of(dev);
        account::create_account_for_test(alice_address);

        // Simulate USDT (non-DXLYN) minting and deposit to resource account
        let fee_dis_address = fee_distributor::get_fee_distributor_address();
        test_internal_coins::init_usdt_coin(dev);
        let coin_amount = 100 * DXLYN_DECIMAL; // 100 USDT
        test_internal_coins::register_and_mint_usdt(dev, fee_dis_address, coin_amount); // mint usdt to resource account

        // Verify initial balances
        assert!(
            test_internal_coins::get_user_usdt_balance(fee_dis_address) == coin_amount,
            0x101
        ); // Resource account has USDT
        assert!(test_internal_coins::get_user_usdt_balance(dev_address) == 0, 0x102); // Dev has no USDT initially

        // Admin calls recover_balance_fa
        fee_distributor::recover_balance_fa(dev, test_internal_coins::get_usdt_metadata(dev));

        // Verify balances after recovery
        assert!(test_internal_coins::get_user_usdt_balance(fee_dis_address) == 0, 0x103); // Resource account emptied
        // Coins transferred to emergency_return (dev)
        assert!(
            test_internal_coins::get_user_usdt_balance(dev_address) == coin_amount,
            0x104
        );
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_recover_balance_fa_zero(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        let dev_address = address_of(dev);
        account::create_account_for_test(alice_address);

        let fee_dis_address = fee_distributor::get_fee_distributor_address();
        test_internal_coins::init_usdt_coin(dev); //init USDT coin

        // Verify initial balances
        assert!(dxlyn_coin::balance_of(fee_dis_address) == 0, 0x105); // Resource account has no USDT
        assert!(dxlyn_coin::balance_of(dev_address) == 0, 0x106); // Dev has no USDT

        // Admin calls recover_balance_fa
        fee_distributor::recover_balance_fa(dev, test_internal_coins::get_usdt_metadata(dev));

        // Verify balances after recovery
        assert!(dxlyn_coin::balance_of(fee_dis_address) == 0, 0x107); // Resource account still empty
        assert!(dxlyn_coin::balance_of(dev_address) == 0, 0x108); // No coins transferred
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_recover_balance_fa_non_admin(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        test_internal_coins::init_usdt_coin(dev); //init USDT coin

        // Non-admin calls recover_balance_fa
        fee_distributor::recover_balance_fa(
            alice,
            test_internal_coins::get_usdt_metadata(dev)
        ); // Should fail with ERROR_NOT_ADMIN
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(
        abort_code = fee_distributor::ERROR_CAN_NOT_RECOVER_DXLYN,
        location = fee_distributor
    )]
    fun test_recover_balance_fa_dxlyn(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let dxlyn_address = object::object_address(&metadata);

        // Admin attempts to recover DXLYN
        fee_distributor::recover_balance_fa(
            dev,
            dxlyn_address
        ); // Should fail with ERROR_CAN_NOT_RECOVER_DXLYN
    }
    //recover_balance test case end

    //change_emergency_return test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_change_emergency_return(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        //change emergency return from dev to alice
        fee_distributor::change_emergency_return(dev, alice_address);

        let (_, _, _, _, _, _, _, _, _, _new_emergency_return, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(_new_emergency_return == alice_address, 0x109);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_NOT_ADMIN, location = fee_distributor)]
    fun test_change_emergency_return_wrong_admin(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let _alice_address = address_of(alice);

        //change emergency return from dev to alice using wrong admin
        fee_distributor::change_emergency_return(alice, _alice_address);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_ZERO_ADDRESS, location = fee_distributor)]
    fun test_change_emergency_return_zero_address(
        dev: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        //change emergency return from dev to zero address
        fee_distributor::change_emergency_return(dev, @0x0);
    }
    //change_emergency_return test case end

    //claim test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_claim(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let lock_amount = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, lock_amount);

        // Create a lock for Alice (2 weeks)
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + (2 * WEEK); // 2 weeks
        voting_escrow::create_lock(alice, lock_amount, unlock_time);

        let (token_address, _) = voting_escrow_test::get_nft_token_address(1);

        // Burn DXLYN to fee_distributor (100 DXLYN)
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, burn_amount);
        fee_distributor::burn(alice, burn_amount);

        // Verify initial state after burn
        let (_, _, last_token_time, coins_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(coins_balance == burn_amount, 0x46); // Coins added
        assert!(token_last_balance == 0, 0x47); // No checkpoint_token_internal called
        assert!(
            last_token_time == current_time / WEEK * WEEK,
            0x48
        ); // From init_module

        // Fast forward time by 1 week
        timestamp::fast_forward_seconds(WEEK);

        // Checkpoint token to distribute tokens
        fee_distributor::checkpoint_token(dev);

        // Checkpoint total supply to update ve_supply
        fee_distributor::checkpoint_total_supply();

        // Verify tokens_per_week for the previous week
        let week_start = current_time / WEEK * WEEK;
        let tokens_per_week = fee_distributor::get_tokens_per_week(week_start);
        let expected_tokens = burn_amount; // Full week allocation
        assert!(tokens_per_week == expected_tokens, 0x49);

        // Get balance before claim
        let balance_before_claim = dxlyn_coin::balance_of(alice_address);

        // Verify initial nft token state
        let token_epoch = fee_distributor::get_user_epoch(token_address);
        let token_time_cursor = fee_distributor::get_user_time_cursor_of(token_address);

        assert!(token_epoch == 0, 0x50);
        assert!(token_time_cursor == 0, 0x51);

        let remaining_claim_calls = fee_distributor::get_remaining_claim_calls(token_address);
        assert!(remaining_claim_calls == 1, 0x522);

        // Claim dxlyn token for NFT token
        fee_distributor::claim(alice, token_address);

        // Verify balance after claim
        let balance_after_claim = dxlyn_coin::balance_of(alice_address);
        let token_balance_of_previous_week =
            fee_distributor::ve_for_at(token_address, week_start); // In 10^12 units
        let ve_supply = fee_distributor::get_ve_supply_at(week_start); // In 10^12 units
        let expected_claim: u256 =
            (token_balance_of_previous_week as u256) * (tokens_per_week as u256)
                / (ve_supply as u256); // converted into u256 for handle overflow issue

        assert!(
            balance_after_claim == balance_before_claim + (expected_claim as u64),
            0x52
        );

        // Verify state after claim
        let (
            _,
            _,
            current_last_token_time,
            current_coins_balance,
            _,
            current_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        let new_token_epoch = fee_distributor::get_user_epoch(token_address);
        let new_token_time_cursor = fee_distributor::get_user_time_cursor_of(token_address);

        assert!(new_token_epoch == 1, 0x53);
        assert!(new_token_time_cursor == current_time + WEEK, 0x54);
        assert!(
            current_coins_balance == coins_balance - (expected_claim as u64),
            0x55
        );
        assert!(
            current_last_token_time == current_time + WEEK,
            0x56
        );
        assert!(
            current_token_last_balance == coins_balance - (expected_claim as u64),
            0x57
        );
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_claim_no_voting_power(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        // Created collection and token and transfer to alice for testing
        let test_token_address = test_nft::test_create_and_transfer(dev, alice, b"NFT Collection", b"Token1");

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice for burn
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, burn_amount);

        // Burn DXLYN to fee_distributor (100 DXLYN) without creating a lock
        fee_distributor::burn(alice, burn_amount);

        // Verify initial state after burn
        let (_, _, last_token_time, coins_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(coins_balance == burn_amount, 0x60); // Coins added to fee_distributor
        assert!(token_last_balance == 0, 0x61); // No checkpoint_token_internal called during burn
        assert!(
            last_token_time == timestamp::now_seconds() / WEEK * WEEK,
            0x62
        ); // last_token_time set in init_module

        // Enable checkpoint_token
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward time by 1 week + TOKEN_CHECKPOINT_DEADLINE
        let claim_time = timestamp::now_seconds() + WEEK + TOKEN_CHECKPOINT_DEADLINE;
        timestamp::fast_forward_seconds(WEEK + TOKEN_CHECKPOINT_DEADLINE);

        // Checkpoint token to distribute tokens
        fee_distributor::checkpoint_token(dev);

        // Checkpoint total supply (no effect since no locks)
        fee_distributor::checkpoint_total_supply();

        // Verify tokens_per_week for the previous week
        let week_start = timestamp::now_seconds() / WEEK * WEEK - WEEK;
        let tokens_per_week = fee_distributor::get_tokens_per_week(week_start);

        let since_last = timestamp::now_seconds() - last_token_time;
        let expected_tokens = (burn_amount * WEEK) / since_last; // Tokens allocated for the week

        assert!(tokens_per_week == expected_tokens, 0x63); // Tokens distributed despite no locks

        // Verify initial nft token state
        let token_epoch = fee_distributor::get_user_epoch(alice_address);
        let token_time_cursor = fee_distributor::get_user_time_cursor_of(alice_address);
        assert!(token_epoch == 0, 0x64); // Token has no claim epoch
        assert!(token_time_cursor == 0, 0x65); // Token has no time cursor

        // Get balance before claim
        let balance_before_claim = dxlyn_coin::balance_of(alice_address);

        // Call claim
        fee_distributor::claim(alice, test_token_address);

        // Verify balance after claim
        let balance_after_claim = dxlyn_coin::balance_of(alice_address);
        assert!(balance_after_claim == balance_before_claim, 0x66); // No coins claimed due to no voting power

        // Verify state after claim
        let (
            _,
            _,
            current_last_token_time,
            current_coins_balance,
            _,
            current_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        let new_token_epoch = fee_distributor::get_user_epoch(alice_address);
        let new_token_time_cursor = fee_distributor::get_user_time_cursor_of(alice_address);

        assert!(new_token_epoch == 0, 0x67); // Token epoch unchanged
        assert!(new_token_time_cursor == 0, 0x68); // Token time cursor unchanged
        assert!(current_coins_balance == coins_balance, 0x69); // No coins claimed
        assert!(current_token_last_balance == coins_balance, 0x70);
        assert!(current_last_token_time == claim_time, 0x71);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(
        abort_code = fee_distributor::ERROR_CONTRACT_KILLED,
        location = fee_distributor
    )]
    fun test_claim_when_contract_kill(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        //kill the contract
        fee_distributor::kill_me(dev);

        let alice_address = address_of(alice);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (5 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + (WEEK * 5); // 5 week

        // Create lock which will mint nft with id 1
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = voting_escrow_test::get_nft_token_address(1);

        // Trying to claim DXLYN token for NFT token when contract is killed
        fee_distributor::claim(alice, token_address);
    }
    //claim test case end

    //claim_many test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_claim_many(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice and Bob
        let alice_lock_amount = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        let alice_2nd_lock_amount = 500 * DXLYN_DECIMAL; // 500 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, alice_lock_amount);
        dxlyn_coin::register_and_mint(dev, alice_address, alice_2nd_lock_amount);

        // Create locks: Alice (2 weeks), Bob (1 week)
        let current_time = timestamp::now_seconds();
        let alice_unlock_time = current_time + (2 * WEEK); // 2 weeks
        let alice_2nd_unlock_time = current_time + WEEK; // 1 week
        voting_escrow::create_lock(alice, alice_lock_amount, alice_unlock_time);
        voting_escrow::create_lock(alice, alice_2nd_lock_amount, alice_2nd_unlock_time);

        let (token1_address, _) = voting_escrow_test::get_nft_token_address(1);
        let (token2_address, _) = voting_escrow_test::get_nft_token_address(2);


        // Burn DXLYN to fee_distributor (100 DXLYN)
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, burn_amount);
        fee_distributor::burn(alice, burn_amount);

        // Verify initial state after burn
        let (_, _, last_token_time, coins_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();
        assert!(coins_balance == burn_amount, 0x60); // Coins added to fee_distributor
        assert!(token_last_balance == 0, 0x61); // No checkpoint_token_internal called during burn
        assert!(
            last_token_time == current_time / WEEK * WEEK,
            0x62
        ); // last_token_time set in init_module

        // Enable checkpoint_token to allow claim to update token distribution
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward time by 1 week + TOKEN_CHECKPOINT_DEADLINE
        let claim_time = current_time + WEEK + TOKEN_CHECKPOINT_DEADLINE;
        timestamp::fast_forward_seconds(WEEK + TOKEN_CHECKPOINT_DEADLINE);

        // Checkpoint token to distribute tokens
        fee_distributor::checkpoint_token(dev);

        // Checkpoint total supply to update ve_supply
        fee_distributor::checkpoint_total_supply();

        // Calculate expected tokens_per_week
        let week_start = current_time / WEEK * WEEK;
        let since_last = claim_time - last_token_time;
        let expected_tokens = (burn_amount * WEEK) / since_last; // Tokens allocated for the week
        let tokens_per_week = fee_distributor::get_tokens_per_week(week_start);
        assert!(tokens_per_week == expected_tokens, 0x63); // Verify tokens_per_week matches expected

        // Verify initial nft token states
        let token1_epoch = fee_distributor::get_user_epoch(token1_address);
        let token1_cursor = fee_distributor::get_user_time_cursor_of(token1_address);
        let token2_epoch = fee_distributor::get_user_epoch(token2_address);
        let token2_cursor = fee_distributor::get_user_time_cursor_of(token2_address);
        assert!(token1_epoch == 0, 0x64); // NFT token 1 has no claim epoch before claim
        assert!(token1_cursor == 0, 0x65); // NFT token 1 has no time cursor before claim
        assert!(token2_epoch == 0, 0x66); // NFT token 2 has no claim epoch before claim
        assert!(token2_cursor == 0, 0x67); // NFT token 2 has no time cursor before claim

        // Get balances before claim
        let alice_balance_before = dxlyn_coin::balance_of(alice_address);

        let tokens = vector::empty<address>();
        vector::push_back(&mut tokens, token1_address);
        vector::push_back(&mut tokens, token2_address);

        // Claim DXLYN tokens for both NFT tokens
        fee_distributor::claim_many(alice, tokens);

        // Verify balances after claim
        let alice_balance_after = dxlyn_coin::balance_of(alice_address);
        let token1_balance_of = fee_distributor::ve_for_at(token1_address, week_start); // In 10^12 units
        let token2_balance_of = fee_distributor::ve_for_at(token2_address, week_start); // In 10^12 units
        let ve_supply = fee_distributor::get_ve_supply_at(week_start); // In 10^12 units
        let token1_expected_claim: u256 =
            (token1_balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256); // Converted to u256 to handle overflow
        let token2_expected_claim: u256 =
            (token2_balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256); // Converted to u256 to handle overflow

        assert!(
            alice_balance_after == alice_balance_before + (token1_expected_claim as u64) + (token2_expected_claim as u64),
            0x68
        ); // Alice balance increased by claimed amount

        // Verify state after claim
        let (
            _,
            _,
            current_last_token_time,
            current_coins_balance,
            _,
            current_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        let token1_new_epoch = fee_distributor::get_user_epoch(token1_address);
        let token1_new_cursor = fee_distributor::get_user_time_cursor_of(token1_address);
        let token2_new_epoch = fee_distributor::get_user_epoch(token2_address);
        let token2_new_cursor = fee_distributor::get_user_time_cursor_of(token2_address);

        assert!(token1_new_epoch == 1, 0x70); // token 1 epoch advanced after claim
        assert!(token1_new_cursor == week_start + WEEK, 0x71); // token 1 time cursor advanced to next week
        assert!(token2_new_epoch == 1, 0x72); // token 2 epoch advanced after claim
        assert!(token2_new_cursor == week_start + WEEK, 0x73); // token 2 time cursor advanced to next week
        assert!(
            current_coins_balance
                == coins_balance - (token1_expected_claim as u64)
                - (token2_expected_claim as u64),
            0x74
        ); // Coins reduced by total claimed amount
        assert!(
            current_token_last_balance
                == coins_balance - (token1_expected_claim as u64)
                - (token2_expected_claim as u64),
            0x75
        ); // token_last_balance reflects remaining coins
        assert!(current_last_token_time == claim_time, 0x76); // last_token_time updated by checkpoint_token_internal
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = fee_distributor::ERROR_CONTRACT_KILLED, location = fee_distributor)]
    fun test_claim_many_when_contract_kill(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        //kill the contract
        fee_distributor::kill_me(dev);

        let receivers = vector::empty<address>();
        vector::push_back(&mut receivers, @0x123);
        vector::push_back(&mut receivers, @0x1234);

        // Call claim many
        fee_distributor::claim_many(alice, receivers);
    }
    //claim_many test case end

    //burn test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_burn_no_checkpoint(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let mint_amount = 200 * DXLYN_DECIMAL; // 200 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, mint_amount);

        // Get initial state
        let current_time = timestamp::now_seconds();
        let week_start = current_time / WEEK * WEEK;
        let (_, _, last_token_time, coins_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        assert!(coins_balance == 0, 0x70); // No coins initially
        assert!(token_last_balance == 0, 0x71); // No tokens distributed
        assert!(last_token_time == week_start, 0x72); // last_token_time set in init_module

        // Burn 100 DXLYN with can_checkpoint_token = false
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        fee_distributor::burn(alice, burn_amount);

        // Verify state after burn
        let (
            _,
            _,
            new_last_token_time,
            new_coins_balance,
            _,
            new_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        assert!(new_coins_balance == burn_amount, 0x73); // Coins added to fee_distributor
        assert!(new_token_last_balance == 0, 0x74); // No checkpoint_token_internal called
        assert!(new_last_token_time == week_start, 0x75); // last_token_time unchanged
        assert!(
            dxlyn_coin::balance_of(alice_address) == (mint_amount - burn_amount),
            0x76
        ); // Alice balance reduced
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_burn_positive_with_checkpoint(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let mint_amount = 200 * DXLYN_DECIMAL; // 200 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, mint_amount);

        // Burn 100 DXLYN to set initial coins
        let burn_amount_1 = 100 * DXLYN_DECIMAL; // 100 DXLYN
        fee_distributor::burn(alice, burn_amount_1);

        // Enable can_checkpoint_token and advance time
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let current_time = timestamp::now_seconds();
        let week_start = current_time / WEEK * WEEK;
        let burn_time = current_time + WEEK + TOKEN_CHECKPOINT_DEADLINE;
        timestamp::fast_forward_seconds(WEEK + TOKEN_CHECKPOINT_DEADLINE);

        // Burn 50 DXLYN
        let burn_amount_2 = 50 * DXLYN_DECIMAL; // 50 DXLYN
        fee_distributor::burn(alice, burn_amount_2);

        // Verify state after burn
        let (
            _,
            _,
            checkpoint_last_token_time,
            checkpoint_coins_balance,
            _,
            checkpoint_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        let tokens_per_week1 = fee_distributor::get_tokens_per_week(week_start);
        let since_last = burn_time - week_start;
        let expected_tokens_week_1 = ((burn_amount_1 + burn_amount_2) * WEEK) / since_last;

        assert!(
            checkpoint_coins_balance == (burn_amount_1 + burn_amount_2),
            0x77
        ); // Both burns added
        assert!(
            checkpoint_token_last_balance == (burn_amount_1 + burn_amount_2),
            0x78
        );
        assert!(checkpoint_last_token_time == burn_time, 0x79); // last_token_time updated by checkpoint_token_internal
        assert!(tokens_per_week1 == expected_tokens_week_1, 0x80); // tokens_per_week set for first burn
        assert!(
            dxlyn_coin::balance_of(alice_address)
                == (mint_amount - burn_amount_1 - burn_amount_2),
            0x81
        ); // Alice balance reduced
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_burn_zero(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let mint_amount = 200 * DXLYN_DECIMAL; // 200 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, mint_amount);

        // Burn 100 DXLYN to set initial coins
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        fee_distributor::burn(alice, burn_amount);

        // Get state before zero burn
        let (_, _, last_token_time, coins_balance, _, token_last_balance, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // Burn 0 DXLYN
        fee_distributor::burn(alice, 0);

        // Verify state after zero burn
        let (
            _,
            _,
            zero_burn_last_token_time,
            zero_burn_coins_balance,
            _,
            zero_burn_token_last_balance,
            _,
            _,
            _,
            _,
            _
        ) = fee_distributor::get_fee_distributor_state();
        assert!(zero_burn_coins_balance == coins_balance, 0x82); // No coins added
        assert!(zero_burn_token_last_balance == token_last_balance, 0x83); // No checkpoint_token_internal called
        assert!(zero_burn_last_token_time == last_token_time, 0x84); // last_token_time unchanged
        assert!(
            dxlyn_coin::balance_of(alice_address) == (mint_amount - burn_amount),
            0x85
        ); // Alice balance unchanged
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(
        abort_code = fee_distributor::ERROR_CONTRACT_KILLED,
        location = fee_distributor
    )]
    fun test_burn_killed_contract(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let mint_amount = 200 * DXLYN_DECIMAL; // 200 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, mint_amount);

        // Kill the contract
        fee_distributor::kill_me(dev);

        // Attempt to burn 10 DXLYN
        let burn_amount = 10; // 10 DXLYN
        fee_distributor::burn(alice, burn_amount); // Should fail with ERROR_CONTRACT_KILLED
    }
    //burn test case end


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       VIEW FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // ve_for_at test cases start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_ve_for_at(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (5 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + (WEEK * 5); // 5 week

        // Create lock which will mint nft with id 1
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = voting_escrow_test::get_nft_token_address(1);

        let ve_current_time =
            fee_distributor::ve_for_at(
                token_address,
                timestamp::now_seconds() / WEEK * WEEK
            );

        assert!(
            ve_current_time
                == (value * AMOUNT_SCALE / MAXTIME)
                * (unlock_time - timestamp::now_seconds()),
            0x32
        );

        //fast forward time
        timestamp::fast_forward_seconds(WEEK);

        let ve_after_week =
            fee_distributor::ve_for_at(
                token_address,
                timestamp::now_seconds() / WEEK * WEEK
            );

        assert!(
            ve_after_week
                == (value * AMOUNT_SCALE / MAXTIME)
                * (unlock_time - timestamp::now_seconds()),
            0x33
        );
    }
    // ve_for_at test cases end

    //claimable and claimable_many test case start
    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    fun test_claimable_and_claimable_many(dev: &signer, alice: &signer) {
        // Setup
        setup_test_with_genesis(dev);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice and Bob
        let alice_lock_amount = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        let alice_2nd_lock_amount = 500 * DXLYN_DECIMAL; // 500 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, alice_lock_amount);
        dxlyn_coin::register_and_mint(dev, alice_address, alice_2nd_lock_amount);

        // Create locks: Alice (2 weeks), Bob (1 week)
        let current_time = timestamp::now_seconds();
        let alice_unlock_time = current_time + (2 * WEEK); // 2 weeks
        let alice_2nd_unlock_time = current_time + WEEK; // 1 week
        voting_escrow::create_lock(alice, alice_lock_amount, alice_unlock_time);
        voting_escrow::create_lock(alice, alice_2nd_lock_amount, alice_2nd_unlock_time);

        let (token1_address, _) = voting_escrow_test::get_nft_token_address(1);
        let (token2_address, _) = voting_escrow_test::get_nft_token_address(2);


        // Burn DXLYN to fee_distributor (100 DXLYN)
        let burn_amount = 100 * DXLYN_DECIMAL; // 100 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, burn_amount);
        fee_distributor::burn(alice, burn_amount);

        // Verify initial state after burn
        let (_, _, last_token_time, _, _, _, _, _, _, _, _) =
            fee_distributor::get_fee_distributor_state();

        // Enable checkpoint_token to allow claim to update token distribution
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Fast forward time by 1 week + TOKEN_CHECKPOINT_DEADLINE
        let claim_time = current_time + WEEK + TOKEN_CHECKPOINT_DEADLINE;
        timestamp::fast_forward_seconds(WEEK + TOKEN_CHECKPOINT_DEADLINE);

        // Checkpoint token to distribute tokens
        fee_distributor::checkpoint_token(dev);

        // Checkpoint total supply to update ve_supply
        fee_distributor::checkpoint_total_supply();

        // Calculate expected tokens_per_week
        let week_start = current_time / WEEK * WEEK;
        let since_last = claim_time - last_token_time;
        let expected_tokens = (burn_amount * WEEK) / since_last; // Tokens allocated for the week
        let tokens_per_week = fee_distributor::get_tokens_per_week(week_start);
        assert!(tokens_per_week == expected_tokens, 0x63); // Verify tokens_per_week matches expected


        // Get balances before claim
        let alice_balance_before = dxlyn_coin::balance_of(alice_address);

        let tokens = vector::empty<address>();
        vector::push_back(&mut tokens, token1_address);
        vector::push_back(&mut tokens, token2_address);

        let (token1_claimable_amount_before, _) = fee_distributor::claimable(token1_address);
        let (token2_claimable_amount_before, _) = fee_distributor::claimable(token2_address);


        let (_, claims) = fee_distributor::claimable_many(tokens);
        let (_, _, _, totoal_claimbale, _, _, _, _, _, _) = voter::total_claimable_rewards(
            alice_address,
            dxlyn_coin::get_dxlyn_asset_address(),
            vector[],
            vector[],
            vector[],
            tokens,
            vector[]
        );

        let token1_claim = vector::borrow(&claims, 0);
        let token2_claim = vector::borrow(&claims, 1);
        let (_, _, token1_claimable) = fee_distributor::convert_weekly_claim(
            vector::borrow(token1_claim, 0)
        );
        let (_, _, token2_claimable) = fee_distributor::convert_weekly_claim(
            vector::borrow(token2_claim, 0)
        );
        let token1_and_token2_claimable_amount_before = token1_claimable + token2_claimable;


        // Claim DXLYN tokens for both NFT tokens
        fee_distributor::claim_many(alice, tokens);

        // Verify balances after claim
        let alice_balance_after = dxlyn_coin::balance_of(alice_address);
        let token1_balance_of = fee_distributor::ve_for_at(token1_address, week_start); // In 10^12 units
        let token2_balance_of = fee_distributor::ve_for_at(token2_address, week_start); // In 10^12 units
        let ve_supply = fee_distributor::get_ve_supply_at(week_start); // In 10^12 units
        let token1_expected_claim: u256 =
            (token1_balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256); // Converted to u256 to handle overflow
        let token2_expected_claim: u256 =
            (token2_balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256); // Converted to u256 to handle overflow

        assert!(token1_claimable_amount_before == (token1_expected_claim as u64), 0x1);
        assert!(token2_claimable_amount_before == (token2_expected_claim as u64), 0x2);

        assert!(token1_claimable == (token1_expected_claim as u64), 0x3);

        assert!(token2_claimable == (token2_expected_claim as u64), 0x4);

        assert!(
            alice_balance_after == alice_balance_before + token1_and_token2_claimable_amount_before,
            0x5
        ); // Alice balance increased by claimed amount
        assert!(token1_and_token2_claimable_amount_before == totoal_claimbale, 0x6);
    }
    //claimable and claimable_many test case end
}
