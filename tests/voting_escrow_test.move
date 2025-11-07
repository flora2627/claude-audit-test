#[test_only]
module dexlyn_tokenomics::voting_escrow_test {

    use std::signer::address_of;
    use std::string;
    use std::string::String;
    use aptos_std::string_utils;

    use aptos_token_objects::token;
    use aptos_token_objects::token::Token;
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account::{Self, create_signer_for_test};
    use supra_framework::block;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::object::{Self, Object};
    use supra_framework::timestamp;

    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::test_nft;
    use dexlyn_tokenomics::voting_escrow::{Self, get_voting_escrow_address};

    // const dev:address =  @dexlyn_tokenomics;
    const SC_ADMIN: address = @dexlyn_tokenomics;
    // all future times are rounded by week
    const WEEK: u64 = 604800;
    // 4 years
    const MAXTIME: u64 = 126144000;
    //10^12
    const MULTIPLIER: u64 = 1000000000000;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // Scaling factor (10^4) for scale amount
    const AMOUNT_SCALE: u64 = 10000;

    const COLLECTION_NAME: vector<u8> = b"DEXLYN_COLLECTION";

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                          HELPER FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    fun get_token_name(token_id: u64): String {
        string_utils::format1(&b"veDXLYN position #{}", token_id)
    }

    #[test_only]
    public fun get_nft_token_address(token_id: u64): (address, Object<Token>) {
        let creator = get_voting_escrow_address();
        let token_name = &get_token_name(token_id);
        let collection_name = &string::utf8(COLLECTION_NAME);
        let token_address = token::create_token_address(&creator, collection_name, token_name);
        let token_object = object::address_to_object<Token>(token_address);
        (token_address, token_object)
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    fun setup_test_with_genesis(dev: &signer, _supra_framework: &signer) {
        genesis::setup();
        //set current time
        timestamp::update_global_time_for_test_secs(1000);
        setup_test(dev);
    }

    #[test_only]
    fun setup_test(dev: &signer) {
        account::create_account_for_test(address_of(dev));

        block::update_block_number(10);

        //initialize DXLYN coin
        test_internal_coins::init_coin(dev);

        voting_escrow::initialize(dev);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_initialize(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework= @supra_framework)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_reinitialize(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);

        let supra_signer = create_signer_for_test(@0x1);
        coin::create_coin_conversion_map(&supra_signer);

        //initialize twice
        voting_escrow::initialize(dev);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // set_voter test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_set_voter(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);

        let (_, _, _, _, _, current_voter) = voting_escrow::get_voting_escrow_state();

        assert!(current_voter == address_of(dev), 0x1);

        let new_voter = address_of(alice);

        voting_escrow::set_voter(dev, new_voter);

        let (_, _, _, _, _, current_voter) = voting_escrow::get_voting_escrow_state();

        assert!(current_voter == new_voter, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_ADMIN, location = voting_escrow)]
    fun test_set_voter_with_non_admin(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(alice));

        let (_, _, _, _, _, _) = voting_escrow::get_voting_escrow_state();
        let new_voter = address_of(alice);

        //trying to set voter from non admin account
        voting_escrow::set_voter(alice, new_voter);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = voting_escrow::ERROR_ZERO_ADDRESS, location = voting_escrow)]
    fun test_set_voter_zero_address(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);

        let (_, _, _, _, _, _) = voting_escrow::get_voting_escrow_state();

        voting_escrow::set_voter(dev, @0x0);
    }
    // set_voter test cases end

    //commit_transfer_ownership test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_commit_transfer_ownership(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let dev_address = address_of(dev);
        let alice_address = address_of(alice);

        //change future owner from dev to alice
        voting_escrow::commit_transfer_ownership(dev, alice_address);

        let (_, _, admin, future_admin, _, _) = voting_escrow::get_voting_escrow_state();

        assert!(admin == dev_address, 0x1);
        assert!(future_admin == alice_address, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_ADMIN, location = voting_escrow)]
    fun test_commit_transfer_ownership_with_non_admin_account(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);

        //create account for alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        //change future owner from dev to alice
        voting_escrow::commit_transfer_ownership(alice, alice_address);
    }
    //commit_transfer_ownership test cases end

    // apply_transfer_ownership test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_apply_transfer_ownership(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        // Create account for Alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        // Set future_admin to Alice
        voting_escrow::commit_transfer_ownership(dev, alice_address);

        // Apply ownership transfer
        voting_escrow::apply_transfer_ownership(dev);

        // Verify state
        let (_, _, admin, future_admin, _, _) = voting_escrow::get_voting_escrow_state();
        assert!(admin == alice_address, 0x1); // Admin should be Alice
        assert!(future_admin == alice_address, 0x2); // Future admin remains Alice (or @0x0 if reset)
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_ADMIN, location = voting_escrow)]
    fun test_apply_transfer_ownership_with_non_admin_account(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        // Create account for Alice
        account::create_account_for_test(address_of(alice));

        let alice_address = address_of(alice);

        // Set future_admin to Alice
        voting_escrow::commit_transfer_ownership(dev, alice_address);

        // Try to apply ownership transfer as non-admin (Alice)
        voting_escrow::apply_transfer_ownership(alice);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = voting_escrow::ERROR_ADMIN_NOT_SET, location = voting_escrow)]
    fun test_apply_transfer_ownership_with_no_future_admin(
        dev: &signer, supra_framework: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        // Try to apply ownership transfer without setting future_admin
        voting_escrow::apply_transfer_ownership(dev);
    }
    // apply_transfer_ownership test cases end

    // create_lock test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_create_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 2000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        let balance_before = dxlyn_coin::balance_of(alice_address);

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        // Get the token address and object
        let (token_address, token_object) = get_nft_token_address(1);

        // Check if the token was created and owned by Alice
        assert!(object::is_owner(token_object, alice_address), 0x1);

        let balance_after = dxlyn_coin::balance_of(alice_address);

        assert!(balance_after == balance_before - value, 0x2);

        // Verify state
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x3); // Supply updated
        assert!(coins_value == value, 0x4); // Coins deposited
        assert!(lock_amount == value, 0x5); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x6); // Rounded to week
        assert!(user_epoch == 1, 0x7);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x9); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x10
        ); // Check total veDxlyn power at specific time
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO, location = voting_escrow)]
    fun test_create_lock_with_zero_value(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register Alice for DXLYN (no mint needed)
        dxlyn_coin::register_and_mint(dev, alice_address, 0);

        // Try to create lock with value = 0
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, 0, unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_create_multiple_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);


        for (i in 0..10) {
            // Register and mint DXLYN for Alice
            let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
            dxlyn_coin::register_and_mint(dev, alice_address, value);

            // Create lock
            let current_time = timestamp::now_seconds(); // 1000
            let unlock_time = current_time + WEEK; // 605,800
            voting_escrow::create_lock(alice, value, unlock_time);

            let (_, token_object) = get_nft_token_address(1);

            // Check if the token was created and owned by Alice
            assert!(object::is_owner(token_object, alice_address), 0x1);
        }
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INVALID_UNLOCK_TIME, location = voting_escrow)]
    fun test_create_lock_with_past_unlock_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Try to create lock with past unlock time
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time - 100; // 1000 - 100 = 9900
        voting_escrow::create_lock(alice, value, unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS, location = voting_escrow)]
    fun test_create_lock_with_too_far_unlock_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Try to create lock with unlock time > MAXTIME
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + MAXTIME + WEEK; // 1000 + 126,144,000 + 604,800
        voting_escrow::create_lock(alice, value, unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INSUFFICIENT_DXLYN_COIN, location = voting_escrow)]
    fun test_create_lock_with_insufficient_balance(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register Alice for DXLYN but don't mint
        dxlyn_coin::register_and_mint(dev, alice_address, 0);

        // Try to create lock with insufficient balance
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);
    }
    // create_lock test cases end


    // create_lock_for test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123, bob = @0x121)]
    fun test_create_lock_for(
        dev: &signer, supra_framework: &signer, alice: &signer, bob: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        let bob_address = address_of(bob);
        account::create_account_for_test(alice_address);
        account::create_account_for_test(bob_address);

        //register and mint DXLYN to alice account
        let value = 2000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        let balance_before = dxlyn_coin::balance_of(alice_address);

        // Create lock
        voting_escrow::create_lock_for(alice, value, unlock_time, bob_address);

        // Get the token address and object
        let (token_address, token_object) = get_nft_token_address(1);

        // Check if the token was created and owned by Bob
        assert!(object::is_owner(token_object, bob_address), 0x1);

        let balance_after = dxlyn_coin::balance_of(alice_address);

        assert!(balance_after == balance_before - value, 0x2);

        // Verify state
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x3); // Supply updated
        assert!(coins_value == value, 0x4); // Coins deposited
        assert!(lock_amount == value, 0x5); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x6); // Rounded to week
        assert!(user_epoch == 1, 0x7);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x9); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x10
        ); // Check total veDxlyn power at specific time
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO, location = voting_escrow)]
    fun test_create_lock_for_with_zero_value(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register Alice for DXLYN (no mint needed)
        dxlyn_coin::register_and_mint(dev, alice_address, 0);

        // Try to create lock with value = 0
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock_for(alice, 0, unlock_time, alice_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123, bob = @0x121)]
    fun test_create_multiple_lock_for(
        dev: &signer, supra_framework: &signer, alice: &signer, bob: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        let bob_address = address_of(bob);
        account::create_account_for_test(alice_address);
        account::create_account_for_test(bob_address);

        for (i in 0..10) {
            // Register and mint DXLYN for Alice
            let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
            dxlyn_coin::register_and_mint(dev, alice_address, value);

            // Create lock
            let current_time = timestamp::now_seconds(); // 1000
            let unlock_time = current_time + WEEK; // 605,800
            voting_escrow::create_lock_for(alice, value, unlock_time, bob_address);

            let (_, token_object) = get_nft_token_address(1);

            // Check if the token was created and owned by Bob
            assert!(object::is_owner(token_object, bob_address), 0x1);
        }
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INVALID_UNLOCK_TIME, location = voting_escrow)]
    fun test_create_lock_for_with_past_unlock_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Try to create lock with past unlock time
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time - 100; // 1000 - 100 = 9900
        voting_escrow::create_lock_for(alice, value, unlock_time, alice_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS, location = voting_escrow)]
    fun test_create_lock_for_with_too_far_unlock_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Try to create lock with unlock time > MAXTIME
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + MAXTIME + WEEK; // 1000 + 126,144,000 + 604,800
        voting_escrow::create_lock_for(alice, value, unlock_time, alice_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INSUFFICIENT_DXLYN_COIN, location = voting_escrow)]
    fun test_create_lock_for_with_insufficient_balance(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register Alice for DXLYN but don't mint
        dxlyn_coin::register_and_mint(dev, alice_address, 0);

        // Try to create lock with insufficient balance
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock_for(alice, value, unlock_time, alice_address);
    }
    // create_lock_for test cases end

    // increase_amount test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_increase_amount(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify state before increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x1); // Supply updated
        assert!(coins_value == value, 0x2); // Coins deposited
        assert!(lock_amount == value, 0x3); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x4); // Rounded to week
        assert!(user_epoch == 1, 0x5);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x6
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x7); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check total veDxlyn power at specific time

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        //increment lock amount by 1000 DXLYN token
        voting_escrow::increase_amount(alice, token_address, value);

        // Verify state after increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        let total_locked = value + value;
        assert!(supply == total_locked, 0x9); // Supply updated
        assert!(coins_value == total_locked, 0x10); // Coins deposited
        assert!(lock_amount == total_locked, 0x11); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x12); // Rounded to week
        assert!(user_epoch == 2, 0x13);
        assert!(
            bias == (total_locked * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x14
        ); // Check veDxlyn power
        assert!(
            slope == (total_locked * AMOUNT_SCALE) / MAXTIME,
            0x15
        ); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (total_locked * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x16
        ); // Check total veDxlyn power at specific time
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO, location = voting_escrow)]
    fun test_increase_amount_with_zero_value(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to increase amount with value = 0
        voting_escrow::increase_amount(alice, token_address, 0);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NO_EXISTING_LOCK_FOUND, location = voting_escrow)]
    fun test_increase_amount_with_no_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Fake token address for testing
        let token = test_nft::test_create_and_transfer(dev, alice, b"NFT Collection", b"Token1");

        // Try to increase amount without a lock
        voting_escrow::increase_amount(alice, token, value);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_LOCK_IS_EXPIRED, location = voting_escrow)]
    fun test_increase_amount_with_expired_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock with short duration
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Fast-forward time to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000); // current_time = 606,800

        // Try to increase amount on expired lock
        voting_escrow::increase_amount(alice, token_address, value);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INSUFFICIENT_DXLYN_COIN, location = voting_escrow)]
    fun test_increase_amount_with_insufficient_balance(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to increase amount without minting more DXLYN
        let increase_value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN (exceeds balance after lock)
        voting_escrow::increase_amount(alice, token_address, increase_value);
    }
    // increase_amount test cases end

    // increase_unlock_time test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_increase_unlock_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify state before increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x1); // Supply updated
        assert!(coins_value == value, 0x2); // Coins deposited
        assert!(lock_amount == value, 0x3); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x4); // Rounded to week
        assert!(user_epoch == 1, 0x5);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x6
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x7); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check total veDxlyn power at specific time

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        //increment unlock time
        let new_unlock_time = unlock_time + WEEK;
        voting_escrow::increase_unlock_time(alice, token_address, new_unlock_time);

        // Verify state after increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x9); // Supply updated
        assert!(coins_value == value, 0x10); // Coins deposited
        assert!(lock_amount == value, 0x11); // Lock amount
        assert!(lock_end == (new_unlock_time / WEEK) * WEEK, 0x12); // Rounded to week
        assert!(user_epoch == 2, 0x13);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x14
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x15); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x16
        ); // Check total veDxlyn power at specific time
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NO_EXISTING_LOCK_FOUND, location = voting_escrow)]
    fun test_increase_unlock_time_with_no_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register Alice for DXLYN (no mint needed)
        dxlyn_coin::register_and_mint(dev, alice_address, 0);

        // Try to increase unlock time without a lock
        let current_time = timestamp::now_seconds(); // 1000
        let new_unlock_time = current_time + WEEK; // 605,800

        let token = test_nft::test_create_and_transfer(dev, alice, b"NFT Collection", b"Token1");

        voting_escrow::increase_unlock_time(alice, token, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_LOCK_IS_EXPIRED, location = voting_escrow)]
    fun test_increase_unlock_time_with_expired_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Fast-forward time to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000); // current_time = 606,800

        // Try to increase unlock time on expired lock
        let new_unlock_time = current_time + 2 * WEEK; // 606,800 + 604,800
        voting_escrow::increase_unlock_time(alice, token_address, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_CAN_ONLY_INCREASE_LOCK_DURATION, location = voting_escrow)]
    fun test_increase_unlock_time_with_same_or_earlier_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to increase unlock time to same or earlier time
        let new_unlock_time = unlock_time; // Same as current lock_end
        voting_escrow::increase_unlock_time(alice, token_address, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS, location = voting_escrow)]
    fun test_increase_unlock_time_with_too_far_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to increase unlock time beyond MAXTIME
        let new_unlock_time = current_time + MAXTIME + WEEK; // 1000 + 126,144,000 + 604,800
        voting_escrow::increase_unlock_time(alice, token_address, new_unlock_time);
    }
    // increase_unlock_time test cases end

    // merge two locks test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_merge_two_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create first lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, from_token_object) = get_nft_token_address(1);
        let (from_lock_amount, _) = voting_escrow::get_token_lock(from_token_address);

        // Check if the token was created and owned by Alice
        assert!(object::is_owner(from_token_object, alice_address), 0x1);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create second lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (to_token_address, to_token_object) = get_nft_token_address(2);
        let (to_lock_amount, to_lock_end) = voting_escrow::get_token_lock(to_token_address);


        // Check if the token was created and owned by Alice
        assert!(object::is_owner(to_token_object, alice_address), 0x1);

        let user_epoch_before = voting_escrow::get_token_epoch(to_token_address);

        // Merge the two locks
        voting_escrow::merge(alice, from_token_address, to_token_address);

        // Verify state after merge
        let (_, supply_after, _, _, coins_value_after, _) = voting_escrow::get_voting_escrow_state();
        let (to_lock_amount_after, to_lock_end_after) = voting_escrow::get_token_lock(to_token_address);
        let (from_lock_amount_after, from_lock_end_after) = voting_escrow::get_token_lock(from_token_address);
        let user_epoch_after = voting_escrow::get_token_epoch(to_token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(to_token_address, user_epoch_after);

        assert!(supply_after == value * 2, 0x1);
        assert!(coins_value_after == value * 2, 0x1);
        assert!(to_lock_amount_after == from_lock_amount + to_lock_amount, 0x1);
        assert!(to_lock_end_after == to_lock_end, 0x5);
        assert!(from_lock_amount_after == 0, 0x1);
        assert!(from_lock_end_after == 0, 0x5);
        assert!(user_epoch_after == user_epoch_before + 1, 0x2);
        assert!(
            bias == ((value * 2) * AMOUNT_SCALE / MAXTIME) * (to_lock_end - current_time),
            0x8
        ); // Check veDxlyn power
        assert!(slope == ((value * 2) * AMOUNT_SCALE) / MAXTIME, 0x9); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == ((value * 2) * AMOUNT_SCALE / MAXTIME) * (to_lock_end - current_time),
            0x10
        ); // Check total veDxlyn power at specific time

        // Check token burned or not
        assert!(!object::object_exists<Token>(from_token_address), 0x10);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN,
        location= voting_escrow
    )]
    fun test_merge_before_removing_vote_from_gauge(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value / 2, unlock_time);
        voting_escrow::create_lock(alice, value / 2, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);
        let (to_token_address, _) = get_nft_token_address(2);

        // Mimic voting for the from_token_address
        voting_escrow::voting(dev, from_token_address);

        // Try to merge without removing vote from gauge
        voting_escrow::merge(alice, from_token_address, to_token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME,
        location= voting_escrow
    )]
    fun test_merge_with_same_token(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        // Try to merge the same token
        voting_escrow::merge(dev, from_token_address, from_token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_NFT_OWNER,
        location= voting_escrow
    )]
    fun test_merge_with_unowned_token(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value * 2);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        // Create first lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        // Create second lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (to_token_address, _) = get_nft_token_address(2);

        // Try to merge from_token_address to to_token_address for which Alice is not the owner
        voting_escrow::merge(dev, from_token_address, to_token_address);
    }
    // end of merge two locks test case

    // split two locks test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_split(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        // Amount of percentage to split
        let percentage_split: vector<u64> = vector[50, 50];
        // Slipt nft in two parts
        voting_escrow::split(alice, percentage_split, from_token_address);

        let (second_token_address, second_token_object) = get_nft_token_address(2);
        let (third_token_address, third_token_object) = get_nft_token_address(3);

        // Verify state after split
        let (_, supply_after, _, _, coins_value_after, _) = voting_escrow::get_voting_escrow_state();
        let (second_lock_amount, second_lock_end) = voting_escrow::get_token_lock(second_token_address);
        let (third_lock_amount, third_lock_end) = voting_escrow::get_token_lock(third_token_address);
        let second_user_epoch = voting_escrow::get_token_epoch(second_token_address);
        let third_user_epoch = voting_escrow::get_token_epoch(third_token_address);
        let (second_bias, second_slope, _, _) =
            voting_escrow::get_token_point_history(second_token_address, second_user_epoch);
        let (third_bias, third_slope, _, _) =
            voting_escrow::get_token_point_history(third_token_address, third_user_epoch);


        assert!(supply_after == value, 0x1);
        assert!(coins_value_after == value, 0x2);

        // Check if the token was created and owned by Alice
        assert!(object::is_owner(second_token_object, alice_address), 0x1);
        // Check if the token was created and owned by Alice
        assert!(object::is_owner(third_token_object, alice_address), 0x1);

        assert!(second_lock_amount == value / 2, 0x1);
        assert!(second_lock_end == (unlock_time / WEEK * WEEK), 0x1);

        assert!(third_lock_amount == value / 2, 0x1);
        assert!(third_lock_end == (unlock_time / WEEK * WEEK), 0x1);


        assert!(second_user_epoch == 1, 0x2);
        assert!(third_user_epoch == 1, 0x2);

        let expected_bias = ((value / 2) * AMOUNT_SCALE / MAXTIME) * (second_lock_end - current_time);
        let expected_slop = ((value / 2) * AMOUNT_SCALE) / MAXTIME;
        assert!(
            second_bias == expected_bias,
            0x8
        ); // Check veDxlyn power
        assert!(second_slope == expected_slop, 0x9); // Check the slope

        assert!(
            third_bias == expected_bias,
            0x8
        ); // Check veDxlyn power
        assert!(third_slope == expected_slop, 0x9); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);

        assert!(
            total_supply_at_specific_time
                == expected_bias * 2,
            0x10
        ); // Check total veDxlyn power at specific time

        // Check token burned or not
        assert!(!object::object_exists<Token>(from_token_address), 0x10);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST,
        location= voting_escrow
    )]
    fun test_split_before_removing_vote_from_gauge(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);
        // Mimic voted for from_token_address
        voting_escrow::voting(dev, from_token_address);

        // Amount of percentage to split
        let percentage_split: vector<u64> = vector[50, 50];

        // Trying to split before removing vote from gauge (should fail)
        voting_escrow::split(alice, percentage_split, from_token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NO_EXISTING_LOCK_FOUND,
        location= voting_escrow
    )]
    fun test_split_without_creating_lock(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);

        let percentage_split: vector<u64> = vector[50, 50];

        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        // Trying to split without creating a lock (should fail)
        voting_escrow::split(dev, percentage_split, token);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_NFT_OWNER,
        location= voting_escrow
    )]
    fun test_split_for_unowned_token(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        let percentage_split: vector<u64> = vector[50, 50];

        // Trying to split for a token that Dev does not own (should fail)
        voting_escrow::split(dev, percentage_split, from_token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_INVALID_WEIGHT,
        location= voting_escrow
    )]
    fun test_split_with_zero_split_weight(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        // Amount of percentage to split
        let percentage_split: vector<u64> = vector[50, 0];
        // Slipt nft in two parts
        voting_escrow::split(alice, percentage_split, from_token_address);
    }

    // end of split two locks test case

    // withdraw test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_withdraw(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN to Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify state before withdraw
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end_actual) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x1);
        assert!(coins_value == value, 0x2);
        assert!(lock_amount == value, 0x3);
        assert!(lock_end_actual == lock_end, 0x4);
        assert!(user_epoch == 1, 0x5);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x6
        );
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x7);
        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        );

        // Fast-forward time to after lock expiration
        let post_withdraw_time = WEEK * 2; // 1,209,600
        timestamp::fast_forward_seconds(post_withdraw_time);

        // Withdraw
        voting_escrow::withdraw(alice, token_address);

        // Verify state after withdraw
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end_actual) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        let total_locked = 0;
        assert!(supply == total_locked, 0x9);
        assert!(coins_value == total_locked, 0x10);
        assert!(lock_amount == total_locked, 0x11);
        assert!(lock_end_actual == 0, 0x12);
        assert!(user_epoch == 2, 0x13);
        assert!(bias == 0, 0x14);
        assert!(slope == 0, 0x15);

        // Verify total supply at post-withdraw time
        let total_supply_at_specific_time =
            voting_escrow::total_supply(post_withdraw_time);
        assert!(total_supply_at_specific_time == 0, 0x16);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST, location = voting_escrow)]
    fun test_withdraw_before_remove_vote_from_gauge(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        //mimic voting in gauge
        voting_escrow::voting(dev, token_address);

        voting_escrow::withdraw(alice, token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_LOCK_NOT_EXPIRED, location = voting_escrow)]
    fun test_withdraw_before_lock_expiration(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to withdraw before lock expiration
        timestamp::fast_forward_seconds(WEEK / 2); // current_time = 303,400
        voting_escrow::withdraw(alice, token_address);
    }

    #[test(
        dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123, bob = @0x121
    )]
    fun test_total_supply_multiple_users(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer,
        bob: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);
        let bob_address = address_of(bob);
        account::create_account_for_test(bob_address);

        // Register and mint DXLYN for Alice and Bob
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        dxlyn_coin::register_and_mint(dev, bob_address, value);

        // Create locks
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        voting_escrow::create_lock(alice, value, unlock_time); // alice lock for one week
        voting_escrow::create_lock(bob, value, unlock_time + WEEK); // bob lock for two week

        let (token_address1, _) = get_nft_token_address(1);
        let (token_address2, _) = get_nft_token_address(2);


        // Fast-forward time to one week
        let query_time = lock_end; // 604,800
        timestamp::fast_forward_seconds(lock_end); // 604,800

        // Withdraw Alice's lock
        voting_escrow::withdraw(alice, token_address1);

        // Verify total supply (only Bob's lock remains)
        let expected_slope = (value * AMOUNT_SCALE) / MAXTIME; // 792
        let expected_bias = expected_slope * (lock_end - current_time); // 792 * (604,800 - 0) = 478209600
        let total_supply_at_specific_time = voting_escrow::total_supply(query_time);
        assert!(total_supply_at_specific_time == expected_bias, 0x1);

        // Verify state
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        assert!(supply == value, 0x2); // Bob's lock
        assert!(coins_value == value, 0x3);
        let (alice_lock_amount, alice_lock_end) =
            voting_escrow::get_token_lock(token_address1);
        assert!(alice_lock_amount == 0, 0x4);
        assert!(alice_lock_end == 0, 0x5);

        let (bob_lock_amount, bob_lock_end) = voting_escrow::get_token_lock(token_address2);
        assert!(bob_lock_amount == value, 0x6);
        assert!(bob_lock_end == lock_end + WEEK, 0x7);
    }

    // withdraw test cases end

    // transfer NFT test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_transfer_nft(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (_, token_object) = get_nft_token_address(1);

        // Transfer nft from alice to dev
        object::transfer<Token>(alice, token_object, address_of(dev));
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = 327683,
        location= object
    )]
    fun test_transfer_nft_without_remove_vote_from_gauge(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, token_object) = get_nft_token_address(1);

        // Mimic nft as a voted
        voting_escrow::voting(dev, token_address);

        // Try to transfer nft from alice to dev
        object::transfer<Token>(alice, token_object, address_of(dev));
    }
    // transfer NFT test cases end

    // Test case for create_relock
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_create_relock(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, token_object) = get_nft_token_address(1);

        // Verify initial lock
        assert!(object::is_owner(token_object, alice_address), 0x1);
        let (lock_amount, lock_end_actual) = voting_escrow::get_token_lock(token_address);
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        assert!(lock_amount == value, 0x2);
        assert!(lock_end_actual == lock_end, 0x3);
        assert!(supply == value, 0x4);
        assert!(coins_value == value, 0x5);

        // Fast-forward to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000); // current_time = 606,800
        let new_current_time = timestamp::now_seconds();

        // Perform create_relock
        let new_unlock_time = new_current_time + 2 * WEEK; // 1,211,600
        let new_lock_end = (new_unlock_time / WEEK) * WEEK; // 1,209,600
        voting_escrow::create_relock(alice, token_address, new_unlock_time);

        // Verify new lock (new NFT created, old NFT burned)
        let (new_token_address, new_token_object) = get_nft_token_address(2);
        assert!(object::is_owner(new_token_object, alice_address), 0x6);
        assert!(!object::object_exists<Token>(token_address), 0x7); // Old token burned

        // Verify new lock state
        let (new_lock_amount, new_lock_end_actual) = voting_escrow::get_token_lock(new_token_address);
        let (_, new_supply, _, _, new_coins_value, _) = voting_escrow::get_voting_escrow_state();
        let user_epoch = voting_escrow::get_token_epoch(new_token_address);
        let (bias, slope, _, _) = voting_escrow::get_token_point_history(new_token_address, user_epoch);

        assert!(new_lock_amount == value, 0x8);
        assert!(new_lock_end_actual == new_lock_end, 0x9);
        assert!(new_supply == value, 0x10);
        assert!(new_coins_value == value, 0x11);
        assert!(user_epoch == 1, 0x12);
        assert!(bias == (value * AMOUNT_SCALE / MAXTIME) * (new_lock_end - new_current_time), 0x13);
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x14);

        // Verify total supply
        let total_supply_at_specific_time = voting_escrow::total_supply(new_current_time);
        assert!(
            total_supply_at_specific_time == (value * AMOUNT_SCALE / MAXTIME) * (new_lock_end - new_current_time),
            0x15
        );
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_LOCK_NOT_EXPIRED, location = dexlyn_tokenomics::voting_escrow)]
    fun test_create_relock_non_expired_lock(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try create_relock before lock expiration
        let new_unlock_time = current_time + 2 * WEEK; // 1,210,600
        voting_escrow::create_relock(alice, token_address, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(
        abort_code = dexlyn_tokenomics::voting_escrow::ERROR_NOT_NFT_OWNER,
        location = dexlyn_tokenomics::voting_escrow
    )]
    fun test_create_relock_while_not_owner(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Create fake NFT
        let fake_token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        // Try create_relock with non-existent lock
        let current_time = timestamp::now_seconds();
        let new_unlock_time = current_time + WEEK;
        voting_escrow::create_relock(alice, fake_token, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(
        abort_code = dexlyn_tokenomics::voting_escrow::ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST,
        location = dexlyn_tokenomics::voting_escrow
    )]
    fun test_create_relock_before_removing_vote(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, token_object) = get_nft_token_address(1);

        // Verify initial lock
        assert!(object::is_owner(token_object, alice_address), 0x1);
        let (lock_amount, lock_end_actual) = voting_escrow::get_token_lock(token_address);
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        assert!(lock_amount == value, 0x2);
        assert!(lock_end_actual == lock_end, 0x3);
        assert!(supply == value, 0x4);
        assert!(coins_value == value, 0x5);

        // Fast-forward to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000); // current_time = 606,800
        let new_current_time = timestamp::now_seconds();

        // Mimic voted for token_address
        voting_escrow::voting(dev, token_address);

        // Perform create_relock
        let new_unlock_time = new_current_time + 2 * WEEK; // 1,211,600
        voting_escrow::create_relock(alice, token_address, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(
        abort_code = dexlyn_tokenomics::voting_escrow::ERROR_INVALID_UNLOCK_TIME,
        location = dexlyn_tokenomics::voting_escrow
    )]
    fun test_create_relock_invalid_unlock_time(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Fast-forward to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000);

        // Try create_relock with past unlock time
        let new_unlock_time = current_time; // Past time
        voting_escrow::create_relock(alice, token_address, new_unlock_time);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(
        abort_code = dexlyn_tokenomics::voting_escrow::ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS,
        location = dexlyn_tokenomics::voting_escrow
    )]
    fun test_create_relock_too_far_unlock_time(
        dev: &signer,
        supra_framework: &signer,
        alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create initial lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Fast-forward to expire the lock
        timestamp::fast_forward_seconds(WEEK + 1000);

        // Try create_relock with unlock time > MAXTIME
        let new_unlock_time = timestamp::now_seconds() + MAXTIME + WEEK;
        voting_escrow::create_relock(alice, token_address, new_unlock_time);
    }
    // End of test case for create_relock

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       VIEW FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // user_point_history_ts test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_user_point_history_ts(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify user_point_history__ts after lock creation
        let user_epoch = voting_escrow::get_token_epoch(token_address); // Should be 1
        assert!(user_epoch == 1, 0x1);
        let ts_create = voting_escrow::user_point_history_ts(token_address, user_epoch);
        assert!(ts_create == current_time, 0x2);
    }
    // user_point_history_ts test case end

    // locked_end test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_locked_end(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create lock (triggers check_point_internal)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify locke end after lock
        let token_lock_end = voting_escrow::locked_end(token_address);
        assert!(token_lock_end == lock_end, 0x1)
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_locked_end_with_no_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Verify locke end after lock
        let alice_lock_end = voting_escrow::locked_end(@0x0);
        assert!(alice_lock_end == 0, 0x1);
    }
    // locked_end test case end

    // locked_amount test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_locked_amount(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify locke amount after lock
        let token_lock_amount = voting_escrow::locked_amount(token_address);
        assert!(token_lock_amount == value, 0x1)
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_locked_amount_with_no_lock(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Verify locke amount after lock
        let token_lock_amount = voting_escrow::locked_amount(@0x0);
        assert!(token_lock_amount == 0, 0x1);
    }
    // locked_amount test case end

    // find_block_epoch test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_find_block_epoch(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        let initial_time = 1000; // Current time in seconds
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Verify initial state (epoch = 0, point_history[0] at blk = 10)
        let (epoch_initial, _, _, _, _, _) = voting_escrow::get_voting_escrow_state();
        assert!(epoch_initial == 0, 0x1);
        let (bias, slope, ts, blk) = voting_escrow::get_point_history(0);
        assert!(bias == 0, 0x2);
        assert!(slope == 0, 0x3);
        assert!(ts == initial_time, 0x4);
        assert!(blk == 10, 0x5);

        // Test find_block_epoch: initial state
        assert!(voting_escrow::find_block_epoch(10, 0) == 0, 0x6); // Exact match
        assert!(voting_escrow::find_block_epoch(5, 0) == 0, 0x7); // Before first block
        assert!(voting_escrow::find_block_epoch(15, 0) == 0, 0x8); // After block
        assert!(voting_escrow::find_block_epoch(15, 1) == 1, 0x9); // Beyond max_epoch

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = initial_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify after lock
        let (epoch, _, _, _, _, _) = voting_escrow::get_voting_escrow_state();
        assert!(epoch == 1, 0x10);
        let (bias, _, ts, blk) = voting_escrow::get_point_history(1);
        let expected_bias = (value * AMOUNT_SCALE / MAXTIME) * (lock_end - initial_time);
        assert!(bias == expected_bias, 0x11);
        assert!(ts == initial_time, 0x12);
        assert!(blk == 10, 0x13);

        // Test find_block_epoch: after lock
        assert!(voting_escrow::find_block_epoch(10, 1) == 1, 0x14); // Latest epoch
        assert!(voting_escrow::find_block_epoch(10, 0) == 0, 0x15); // Limited by max_epoch
        assert!(voting_escrow::find_block_epoch(5, 1) == 0, 0x16); // Before first block
        assert!(voting_escrow::find_block_epoch(15, 1) == 1, 0x17); // After latest block
        assert!(voting_escrow::find_block_epoch(1000, 1) == 1, 0x18); // Far future block

        // Fast-forward to withdrawal (epoch = 2, new block = 11)
        let withdraw_time = lock_end;
        timestamp::update_global_time_for_test_secs(withdraw_time);
        block::update_block_number(11);
        voting_escrow::withdraw(alice, token_address);

        // Verify after withdrawal
        let (epoch_after, _, _, _, _, _) = voting_escrow::get_voting_escrow_state();
        assert!(epoch_after == 2, 0x19);
        let (bias, slope, ts, blk) = voting_escrow::get_point_history(2);
        assert!(bias == 0, 0x20);
        assert!(slope == 0, 0x21);
        assert!(ts == withdraw_time, 0x22);
        assert!(blk == 11, 0x23);

        // Test find_block_epoch: after withdrawal
        assert!(voting_escrow::find_block_epoch(11, 2) == 2, 0x24); // Exact match
        assert!(voting_escrow::find_block_epoch(10, 1) == 1, 0x25); // Previous epoch
        assert!(voting_escrow::find_block_epoch(5, 2) == 0, 0x26); // Before first block
        assert!(voting_escrow::find_block_epoch(15, 2) == 2, 0x27); // After latest block
    }
    // find_block_epoch test case end

    // checkpoint_with_block_update test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_checkpoint_with_block_update(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        block::update_block_number(10);
        // Create lock (triggers check_point_internal)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800
        let block_number = block::get_current_block_height(); // 10
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify checkpoint after lock creation
        let user_epoch = voting_escrow::get_token_epoch(token_address); // 1
        assert!(user_epoch == 1, 0x55);
        let (user_bias, user_slope, user_ts, user_blk) =
            voting_escrow::get_token_point_history(token_address, user_epoch);
        let slope = (value * AMOUNT_SCALE) / MAXTIME; // 792
        let expected_bias = slope * (lock_end - current_time); // 792 * 603,800
        assert!(user_bias == expected_bias, 0x1);
        assert!(user_slope == slope, 0x2);
        assert!(user_ts == current_time, 0x3);
        assert!(user_blk == block_number, 0x4);

        let (epoch, supply, _, _, coins_value, _) =
            voting_escrow::get_voting_escrow_state();
        assert!(epoch == 1, 0x5);
        let (global_bias, global_slope, global_ts, global_blk) =
            voting_escrow::get_point_history(epoch);
        assert!(global_bias == expected_bias, 0x6);
        assert!(global_slope == slope, 0x7);
        assert!(global_ts == current_time, 0x8);
        assert!(global_blk == block_number, 0x9);
        assert!(supply == value, 0x10);
        assert!(coins_value == value, 0x11);

        // Fast-forward to after lock expiration and update block number
        let withdraw_time = lock_end;
        timestamp::update_global_time_for_test_secs(withdraw_time);
        block::update_block_number(11); // Update block number for withdrawal

        // Withdraw (triggers check_point_internal)
        voting_escrow::withdraw(alice, token_address);

        // Verify checkpoint after withdrawal
        let user_epoch_after = voting_escrow::get_token_epoch(token_address); // 2
        assert!(user_epoch_after == 2, 0x12);
        let (user_bias_after, user_slope_after, user_ts_after, user_blk_after) =
            voting_escrow::get_token_point_history(token_address, user_epoch_after);
        assert!(user_bias_after == 0, 0x13);
        assert!(user_slope_after == 0, 0x14);
        assert!(user_ts_after == withdraw_time, 0x15);
        assert!(user_blk_after == 11, 0x16);

        let (epoch_after, supply_after, _, _, coins_value_after, _) =
            voting_escrow::get_voting_escrow_state();
        assert!(epoch_after == 2, 0x17);
        let (global_bias_after, global_slope_after, global_ts_after, global_blk_after) =
            voting_escrow::get_point_history(epoch_after);
        assert!(global_bias_after == 0, 0x18);
        assert!(global_slope_after == 0, 0x19);
        assert!(global_ts_after == withdraw_time, 0x20);
        assert!(global_blk_after == 11, 0x21);
        assert!(supply_after == 0, 0x22);
        assert!(coins_value_after == 0, 0x23);

        // Verify total_supply
        assert!(voting_escrow::total_supply(withdraw_time) == 0, 0x24);
        let (lock_amount, lock_end_actual) = voting_escrow::get_token_lock(token_address);
        assert!(lock_amount == 0, 0x25);
        assert!(lock_end_actual == 0, 0x26);
    }
    // checkpoint_with_block_update test case end

    // balance_of test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_balance_of(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800

        let before_balance = voting_escrow::balance_of(alice_address, current_time); // veDxlyn balance before lock

        assert!(before_balance == 0, 0x1);

        voting_escrow::create_lock(alice, value, unlock_time); // lock

        let (token_address, _) = get_nft_token_address(1);

        let current_balance = voting_escrow::balance_of(token_address, current_time); //current veDxlyn balance

        assert!(
            current_balance == (value * AMOUNT_SCALE / MAXTIME) * (lock_end
                - current_time),
            0x2
        );

        //fast forward after one week
        timestamp::fast_forward_seconds(current_time + WEEK);
        let current_time = timestamp::now_seconds();

        let after_balance = voting_escrow::balance_of(token_address, current_time); //veDxlyn balance after one week

        assert!(after_balance == 0, 0x3);
    }
    // balance_of test case end

    // balance_of_at test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_balance_of_at(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800

        let before_balance = voting_escrow::balance_of_at(alice_address, 10); // veDxlyn balance before lock at block 10

        assert!(before_balance == 0, 0x1);

        //update block number
        block::update_block_number(11);

        voting_escrow::create_lock(alice, value, unlock_time); // lock

        let (token_address, _) = get_nft_token_address(1);

        let current_balance = voting_escrow::balance_of_at(token_address, 11); //current veDxlyn balance at block 11
        assert!(
            current_balance == (value * AMOUNT_SCALE / MAXTIME) * (lock_end
                - current_time),
            0x2
        );

        //fast forward after one week and update block
        timestamp::fast_forward_seconds(current_time + WEEK);
        block::update_block_number(12);

        let after_balance = voting_escrow::balance_of_at(
            token_address,
            12
        ); //veDxlyn balance after one week at block 12

        assert!(after_balance == 0, 0x3);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_BLOCK_NUMBER_EXCEEDED, location = voting_escrow)]
    fun test_balance_of_at_with_wrong_block_number(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        voting_escrow::balance_of_at(alice_address, 15);
    }
    // balance_of_at test case end

    // total_supply test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_total_supply(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800

        let before_balance = voting_escrow::total_supply(current_time); //total veDxlyn supply before lock

        assert!(before_balance == 0, 0x1);

        voting_escrow::create_lock(alice, value, unlock_time); // lock

        let current_balance = voting_escrow::total_supply(current_time); //total veDxlyn supply after lock
        assert!(
            current_balance == (value * AMOUNT_SCALE / MAXTIME) * (lock_end
                - current_time),
            0x2
        );

        //fast forward after one week and update block
        timestamp::fast_forward_seconds(current_time + WEEK);
        let current_time = timestamp::now_seconds();

        let after_balance = voting_escrow::total_supply(current_time + WEEK); //total veDxlyn supply after week

        assert!(after_balance == 0, 0x3);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_total_supply_at(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK; // 605,800
        let lock_end = (unlock_time / WEEK) * WEEK; // 604,800

        let before_balance = voting_escrow::total_supply_at(10); //total veDxlyn supply before lock at block 10

        assert!(before_balance == 0, 0x1);

        //update block number
        block::update_block_number(11);

        voting_escrow::create_lock(alice, value, unlock_time); // lock

        let current_balance = voting_escrow::total_supply_at(11); //total veDxlyn supply at block 11
        assert!(
            current_balance == (value * AMOUNT_SCALE / MAXTIME) * (lock_end
                - current_time),
            0x2
        );

        //fast forward after one week and update block
        timestamp::fast_forward_seconds(current_time + WEEK);
        block::update_block_number(12);

        let after_balance = voting_escrow::total_supply_at(12); //total veDxlyn supply at block 12

        assert!(after_balance == 0, 0x3);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_BLOCK_NUMBER_EXCEEDED, location = voting_escrow)]
    fun test_total_supply_at_with_wrong_block_number(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        voting_escrow::total_supply_at(15); //total veDxlyn supply before lock at block 15
    }
    // total_supply_at test case end

    // balance_after_merge test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_balance_after_merge(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create first lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, from_token_object) = get_nft_token_address(1);

        // Check if the token was created and owned by Alice
        assert!(object::is_owner(from_token_object, alice_address), 0x1);

        // Register and mint DXLYN for Alice
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Create second lock
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (to_token_address, to_token_object) = get_nft_token_address(2);
        let (_, to_lock_end) = voting_escrow::get_token_lock(to_token_address);


        // Check if the token was created and owned by Alice
        assert!(object::is_owner(to_token_object, alice_address), 0x2);

        let (balance_after_merge, incresed_by) = voting_escrow::balance_after_merge(
            from_token_address,
            to_token_address
        );

        let from_token_balance = voting_escrow::balance_of(to_token_address, timestamp::now_seconds());

        assert!(incresed_by == from_token_balance, 0x3);

        // Merge the two locks
        voting_escrow::merge(alice, from_token_address, to_token_address);

        let balance_of_to_token_after_merge = voting_escrow::balance_of(to_token_address, timestamp::now_seconds());

        // Verify state after merge
        let user_epoch_after = voting_escrow::get_token_epoch(to_token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(to_token_address, user_epoch_after);

        assert!(
            bias == ((value * 2) * AMOUNT_SCALE / MAXTIME) * (to_lock_end - current_time),
            0x4
        ); // Check veDxlyn power
        assert!(slope == ((value * 2) * AMOUNT_SCALE) / MAXTIME, 0x5); // Check the slope

        assert!(bias == balance_after_merge, 0x6);
        assert!(balance_after_merge == balance_of_to_token_after_merge, 0x7);
        assert!(bias == balance_of_to_token_after_merge, 0x7)
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME,
        location= voting_escrow
    )]
    fun test_balance_after_merge_with_same_token(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (from_token_address, _) = get_nft_token_address(1);

        // Try to merge the same token
        voting_escrow::balance_after_merge(from_token_address, from_token_address);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST,
        location= voting_escrow
    )]
    fun test_balance_after_merge_when_token_not_exist(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let fake_token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let fake_token2 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection1", b"Token2");

        // Try to merge the same token
        voting_escrow::balance_after_merge(fake_token1, fake_token2);
    }
    // balance_after_merge test case end

    // balance_after_extend_time test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_balance_after_extend_time(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify state before increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x1); // Supply updated
        assert!(coins_value == value, 0x2); // Coins deposited
        assert!(lock_amount == value, 0x3); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x4); // Rounded to week
        assert!(user_epoch == 1, 0x5);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x6
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x7); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check total veDxlyn power at specific time

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        let balance_after_extend_time = voting_escrow::balance_after_extend_time(token_address, WEEK);

        //increment unlock time
        let new_unlock_time = unlock_time + WEEK;
        voting_escrow::increase_unlock_time(alice, token_address, new_unlock_time);

        // Verify state after increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        let balance_of_after_extend_time = voting_escrow::balance_of(token_address, timestamp::now_seconds());

        assert!(supply == value, 0x9); // Supply updated
        assert!(coins_value == value, 0x10); // Coins deposited
        assert!(lock_amount == value, 0x11); // Lock amount
        assert!(lock_end == (new_unlock_time / WEEK) * WEEK, 0x12); // Rounded to week
        assert!(user_epoch == 2, 0x13);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x14
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x15); // Check the slope

        assert!(bias == balance_after_extend_time, 0x16); // Check balance after extend time

        assert!(balance_of_after_extend_time == balance_after_extend_time, 0x17); // Check balance of after extend time
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NO_EXISTING_LOCK_FOUND, location= voting_escrow)]
    fun test_balance_after_extend_time_when_no_existing_lock_found(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let fake_token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        // Try to extend time with fake token
        voting_escrow::balance_after_extend_time(fake_token1, WEEK);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS, location= voting_escrow)]
    fun test_balance_after_extend_time_when_lock_is_more_than_4_years(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + MAXTIME;
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to merge the same token
        voting_escrow::balance_after_extend_time(token_address, WEEK);
    }
    // balance_after_extend_time test case end

    // balance_after_increase_amount test case start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_balance_after_increase_amount(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        // Setup
        setup_test_with_genesis(dev, supra_framework);

        let alice_address = address_of(alice);
        account::create_account_for_test(alice_address);

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        // Set unlock time (1 week from now)
        let current_time = timestamp::now_seconds(); // 1000
        let unlock_time = current_time + WEEK; // 1 week

        // Create lock
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Verify state before increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);

        assert!(supply == value, 0x1); // Supply updated
        assert!(coins_value == value, 0x2); // Coins deposited
        assert!(lock_amount == value, 0x3); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x4); // Rounded to week
        assert!(user_epoch == 1, 0x5);
        assert!(
            bias == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x6
        ); // Check veDxlyn power
        assert!(slope == (value * AMOUNT_SCALE) / MAXTIME, 0x7); // Check the slope

        let total_supply_at_specific_time = voting_escrow::total_supply(current_time);
        assert!(
            total_supply_at_specific_time
                == (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x8
        ); // Check total veDxlyn power at specific time

        //register and mint DXLYN to alice account
        let value = 1000 * DXLYN_DECIMAL; // 1000 DXLYN
        dxlyn_coin::register_and_mint(dev, alice_address, value);

        let balance_after_increase_amount = voting_escrow::balance_after_increase_amount(token_address, value);

        //increment lock amount by 1000 DXLYN token
        voting_escrow::increase_amount(alice, token_address, value);

        // Verify state after increment amount
        let (_, supply, _, _, coins_value, _) = voting_escrow::get_voting_escrow_state();
        let (lock_amount, lock_end) = voting_escrow::get_token_lock(token_address);
        let user_epoch = voting_escrow::get_token_epoch(token_address);
        let (bias, slope, _, _) =
            voting_escrow::get_token_point_history(token_address, user_epoch);
        let balance_of_after_increase_amount = voting_escrow::balance_of(token_address, timestamp::now_seconds());

        let total_locked = value + value;
        assert!(supply == total_locked, 0x9); // Supply updated
        assert!(coins_value == total_locked, 0x10); // Coins deposited
        assert!(lock_amount == total_locked, 0x11); // Lock amount
        assert!(lock_end == (unlock_time / WEEK) * WEEK, 0x12); // Rounded to week
        assert!(user_epoch == 2, 0x13);
        assert!(
            bias == (total_locked * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time),
            0x14
        ); // Check veDxlyn power
        assert!(
            slope == (total_locked * AMOUNT_SCALE) / MAXTIME,
            0x15
        ); // Check the slope

        // Check balance after increase amount
        assert!(bias == balance_after_increase_amount, 0x16);
        assert!(bias == balance_of_after_increase_amount, 0x17);
        assert!(balance_of_after_increase_amount == balance_after_increase_amount, 0x18);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NO_EXISTING_LOCK_FOUND, location= voting_escrow)]
    fun test_balance_after_increase_amount_when_no_existing_lock_found(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let fake_token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        // Try to increase amount with fake token
        voting_escrow::balance_after_increase_amount(fake_token1, 10);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO, location= voting_escrow)]
    fun test_balance_after_increase_amount_when_value_is_zero(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        // Try to increase amount with zero value
        voting_escrow::balance_after_increase_amount(token_address, 0);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_LOCK_IS_EXPIRED, location= voting_escrow)]
    fun test_balance_after_increase_amount_when_lock_is_expired(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        timestamp::fast_forward_seconds(WEEK * 2);

        // Try to increase amount when lock is expired
        voting_escrow::balance_after_increase_amount(token_address, 10);
    }
    // balance_after_increase_amount test case end


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       FRIEND FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // voting test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_voting(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        assert!(voting_escrow::is_voted(token_address) == false, 0x1);

        voting_escrow::voting(dev, token_address);

        assert!(voting_escrow::is_voted(token_address), 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_VOTER, location = voting_escrow)]
    fun test_voting_non_voter(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        voting_escrow::voting(alice, alice_address);
    }
    // voting test cases end

    // abstain test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_abstain(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Mint DXLYN and create lock (epoch = 1, same block = 10)
        let value = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK; // 605,800
        voting_escrow::create_lock(alice, value, unlock_time);

        let (token_address, _) = get_nft_token_address(1);

        voting_escrow::voting(dev, token_address);

        assert!(voting_escrow::is_voted(token_address), 0x1);

        voting_escrow::abstain(dev, token_address);

        assert!(voting_escrow::is_voted(token_address) == false, 0x2);
    }

    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    #[expected_failure(abort_code = voting_escrow::ERROR_NOT_VOTER, location = voting_escrow)]
    fun test_abstain_non_voter(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        voting_escrow::abstain(alice, alice_address);
    }
    // abstain test cases end

    // -------------------------------------------------------------------------
    // FINDING #8: Integer Truncation in Split - Proof of Concept Tests
    // -------------------------------------------------------------------------

    /// PoC Test 1: Demonstrates partial loss - splitting odd number of base units
    /// Expected: User locks amount that cannot divide evenly, loses 1 base unit due to truncation
    /// Calculation: floor(500000001*1/2) + floor(500000001*1/2) = 250000000 + 250000000 = 500000000, loss = 1
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_split_integer_truncation_loss_5_tokens(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Lock 5 DXLYN + 1 base unit (cannot divide evenly by 2)
        let value = 5 * DXLYN_DECIMAL + 1;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK;
        voting_escrow::create_lock(alice, value, unlock_time);

        // Verify initial state
        let (_, supply_before, _, _, coins_value_before, _) = voting_escrow::get_voting_escrow_state();
        assert!(supply_before == value, 0x1);
        assert!(coins_value_before == value, 0x2);

        // Split with equal weights [1, 1]
        let (from_token_address, _) = get_nft_token_address(1);
        let split_weights: vector<u64> = vector[1, 1];
        voting_escrow::split(alice, split_weights, from_token_address);

        // Get the two new NFT tokens
        let (second_token_address, _) = get_nft_token_address(2);
        let (third_token_address, _) = get_nft_token_address(3);

        // Check locked amounts
        let (second_lock_amount, _) = voting_escrow::get_token_lock(second_token_address);
        let (third_lock_amount, _) = voting_escrow::get_token_lock(third_token_address);

        // Each should get floor((5*10^8 + 1) * 1 / 2) = floor(250000000.5) = 250000000
        assert!(second_lock_amount == 250000000, 0x3);
        assert!(third_lock_amount == 250000000, 0x4);

        // Critical assertion: supply should be 500000001, but is actually 500000000
        let (_, supply_after, _, _, coins_value_after, _) = voting_escrow::get_voting_escrow_state();
        let total_locked = second_lock_amount + third_lock_amount;

        // BUG DEMONSTRATION: Total locked < Original value
        // 1 base unit is permanently lost!
        assert!(total_locked == 500000000, 0x5); // Only 500000000 returned
        assert!(supply_after == 500000000, 0x6); // Supply is 500000000, not 500000001!
        assert!(coins_value_after == value, 0x7); // But contract still holds 500000001

        // The invariant is broken: supply (500000000) != coins_value (500000001)
        // 1 base unit is stuck in the contract forever
        assert!(supply_after != coins_value_after, 0x8);
        assert!(coins_value_after - supply_after == 1, 0x9); // Lost 1 base unit
    }

    /// PoC Test 2: Demonstrates total loss - splitting 1 base unit with equal weights [1,1]
    /// Expected: User locks 1 base unit, splits into 2 NFTs, but ENTIRE amount is lost
    /// Calculation: floor(1*1/2) + floor(1*1/2) = 0 + 0 = 0, loss = 1 (100% loss!)
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_split_integer_truncation_total_loss(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Lock exactly 1 base unit (smallest possible amount)
        let value = 1;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK;
        voting_escrow::create_lock(alice, value, unlock_time);

        // Verify initial state
        let (_, supply_before, _, _, coins_value_before, _) = voting_escrow::get_voting_escrow_state();
        assert!(supply_before == value, 0x1);
        assert!(coins_value_before == value, 0x2);

        // Split with equal weights [1, 1]
        let (from_token_address, _) = get_nft_token_address(1);
        let split_weights: vector<u64> = vector[1, 1];
        voting_escrow::split(alice, split_weights, from_token_address);

        // Get the two new NFT tokens
        let (second_token_address, _) = get_nft_token_address(2);
        let (third_token_address, _) = get_nft_token_address(3);

        // Check locked amounts: each should be floor(1*1/2) = 0
        let (second_lock_amount, _) = voting_escrow::get_token_lock(second_token_address);
        let (third_lock_amount, _) = voting_escrow::get_token_lock(third_token_address);

        // CATASTROPHIC BUG: Both NFTs have 0 locked amount!
        assert!(second_lock_amount == 0, 0x3);
        assert!(third_lock_amount == 0, 0x4);

        // Critical assertion: supply is now 0, but contract still holds 1 base unit
        let (_, supply_after, _, _, coins_value_after, _) = voting_escrow::get_voting_escrow_state();
        let total_locked = second_lock_amount + third_lock_amount;

        // BUG DEMONSTRATION: 100% loss!
        assert!(total_locked == 0, 0x5); // Nothing returned!
        assert!(supply_after == 0, 0x6); // Supply is 0!
        assert!(coins_value_after == value, 0x7); // But contract still holds 1 base unit

        // The entire 1 base unit is permanently stuck in the contract
        // User cannot withdraw from either NFT since both have 0 locked amount
        assert!(supply_after == 0, 0x8);
        assert!(coins_value_after == 1, 0x9);
    }

    /// PoC Test 3: Demonstrates uneven split causing loss with realistic amounts
    /// Splitting 10 base units with weights [3,3,3] where sum=9
    /// Calculation: floor(10*3/9) + floor(10*3/9) + floor(10*3/9) = 3 + 3 + 3 = 9, loss = 1
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
    fun test_split_integer_truncation_uneven_weights(
        dev: &signer, supra_framework: &signer, alice: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let alice_address = address_of(alice);

        // Lock exactly 10 base units
        let value = 10;
        dxlyn_coin::register_and_mint(dev, alice_address, value);
        let unlock_time = timestamp::now_seconds() + WEEK;
        voting_escrow::create_lock(alice, value, unlock_time);

        // Verify initial state
        let (_, supply_before, _, _, coins_value_before, _) = voting_escrow::get_voting_escrow_state();
        assert!(supply_before == value, 0x1);
        assert!(coins_value_before == value, 0x2);

        // Split with weights [3, 3, 3] (total weight = 9)
        let (from_token_address, _) = get_nft_token_address(1);
        let split_weights: vector<u64> = vector[3, 3, 3];
        voting_escrow::split(alice, split_weights, from_token_address);

        // Get the three new NFT tokens
        let (second_token_address, _) = get_nft_token_address(2);
        let (third_token_address, _) = get_nft_token_address(3);
        let (fourth_token_address, _) = get_nft_token_address(4);

        // Check locked amounts: each should be floor(10*3/9) = floor(3.333...) = 3
        let (second_lock_amount, _) = voting_escrow::get_token_lock(second_token_address);
        let (third_lock_amount, _) = voting_escrow::get_token_lock(third_token_address);
        let (fourth_lock_amount, _) = voting_escrow::get_token_lock(fourth_token_address);

        // Each NFT gets 3 base units
        assert!(second_lock_amount == 3, 0x3);
        assert!(third_lock_amount == 3, 0x4);
        assert!(fourth_lock_amount == 3, 0x5);

        // BUG: Total locked = 9, but original was 10
        let (_, supply_after, _, _, coins_value_after, _) = voting_escrow::get_voting_escrow_state();
        let total_locked = second_lock_amount + third_lock_amount + fourth_lock_amount;

        assert!(total_locked == 9, 0x6); // Only 9 returned
        assert!(supply_after == 9, 0x7); // Supply is 9, not 10!
        assert!(coins_value_after == value, 0x8); // Contract still holds 10

        // Lost 1 base unit due to truncation
        assert!(coins_value_after - supply_after == 1, 0x9);
    }
    // Finding #8 PoC tests end
}
