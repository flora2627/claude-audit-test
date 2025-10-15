// This module contains tests for the `bribe` module in the `dexlyn_tokenomics` system, which manages incentives for voters
// using LP tokens and rewards (e.g., USDT). The tests verify bribe creation, deposits, withdrawals, reward distribution,
// and administrative actions like setting owners/voters. These tests ensure the bribe system works as expected, handles
// edge cases, and prevents unauthorized actions.
#[test_only]
module dexlyn_tokenomics::bribe_test {
    use std::signer::address_of;

    use supra_framework::account::{Self, create_signer_for_test};
    use supra_framework::block;
    use supra_framework::fungible_asset;
    use supra_framework::genesis;
    use supra_framework::object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::bribe;
    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::test_nft;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;

    // Constants used across tests
    // Developer address for test setup
    const SC_ADMIN: address = @dexlyn_tokenomics;
    // One week in seconds (7 days)
    const WEEK: u64 = 604800;
    // One day in seconds
    const DAY: u64 = 86400;
    // 4 years in seconds (max lock time)
    const MAXTIME: u64 = 126144000;
    // Scaling factor for reward calculations
    const MULTIPLIER: u64 = 100000000;

    // 1 DXLYN_DECIMAL in smallest unit
    const DXLYN_DECIMAL: u64 = 100000000;

    const POOL_ADDRESS: address = @0x007;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Initializes the test environment with genesis setup and a specific timestamp
    // This sets up the blockchain state, including accounts and coins, to mimic a real deployment
    #[test_only]
    fun setup_test_with_genesis(dev: &signer, _supra_framework: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    // Sets up common test state: accounts, block number, voting escrow, bribe system, and DXLYN/USDT coins
    // This prepares the environment for each test, ensuring a clean state with initialized contracts
    #[test_only]
    fun setup_test(dev: &signer) {
        // Create developer account
        account::create_account_for_test(address_of(dev));

        // Set block number to 10 for test consistency
        block::update_block_number(10);

        // Initialize DXLYN coin (platform token)
        test_internal_coins::init_coin(dev);

        // Initialize USDT coin (reward token)
        test_internal_coins::init_usdt_coin(dev);

        // Initialize USDC coin (reward token)
        test_internal_coins::init_usdc_coin(dev);

        // Initialize voting escrow (tracks locked tokens for voting power)
        voting_escrow::initialize(dev);

        // Initialize fee distributor
        fee_distributor::initialize(dev);

        let voter_addr = voter::get_voter_address();
        let voter_signer = &create_signer_for_test(voter_addr);
        voter::initialize(dev);
        bribe::set_bribe_sys_owner(voter_signer, @dexlyn_tokenomics);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Tests successful initialization of the bribe system
    // Verifies that the bribe system can be set up without errors
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_initialize(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        // No assertions needed; successful execution confirms initialization
    }

    // Tests that reinitializing the bribe system fails
    // Ensures the system prevents duplicate initialization to avoid overwriting state
    #[test(dev = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_reinitialize(dev: &signer) {
        genesis::setup();
        bribe::test_initialize(dev); // First initialization
        bribe::test_initialize(dev); // Second attempt should fail (abort code 524289)
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // set_voter test cases start
    // Verifies changing the voter address for a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_set_voter(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        let new_voter = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);

        let (_, _, initial_voter) = bribe::get_bribe_state(POOL_ADDRESS);
        assert!(initial_voter == voter_address, 0x70); // Initial voter is dev

        // Change voter to Bob
        bribe::set_voter(dev, POOL_ADDRESS, new_voter);
        let (_, _, updated_voter) = bribe::get_bribe_state(POOL_ADDRESS);
        assert!(updated_voter == new_voter, 0x71); // Voter updated to Bob
    }

    // Tests that only the owner can set a new voter
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_set_voter_non_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        let new_voter = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        bribe::set_voter(bob, POOL_ADDRESS, new_voter); // Should fail: bob is not owner
    }

    // Tests that setting voter to zero address fails
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_ADDRESS, location = bribe)]
    fun test_set_voter_zero_address(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        bribe::set_voter(dev, POOL_ADDRESS, @0x0); // Should fail: invalid address
    }

    // Tests that setting voter fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_set_voter_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let new_voter = address_of(dev);
        bribe::set_voter(dev, POOL_ADDRESS, new_voter); // Should fail
    }
    // set_voter test cases end

    // set_owner test cases start
    // Verifies changing the owner address for a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_set_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        let new_owner = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);

        let (_, initial_owner, _) = bribe::get_bribe_state(POOL_ADDRESS);
        assert!(initial_owner == address_of(dev), 0x80); // Initial owner is dev

        // Change owner to Bob
        bribe::set_owner(dev, POOL_ADDRESS, new_owner);
        let (_, updated_owner, _) = bribe::get_bribe_state(POOL_ADDRESS);
        assert!(updated_owner == new_owner, 0x81); // Owner updated to Bob
    }

    // Tests that only the current owner can set a new owner
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_set_owner_non_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        let new_owner = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        bribe::set_owner(bob, POOL_ADDRESS, new_owner); // Should fail: bob is not owner
    }

    // Tests that setting owner to zero address fails
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_ADDRESS, location = bribe)]
    fun test_set_owner_zero_address(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        bribe::set_owner(dev, POOL_ADDRESS, @0x0); // Should fail: invalid address
    }

    // Tests that setting owner fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_set_owner_bribe_not_found(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let new_owner = address_of(dev);
        bribe::set_owner(dev, POOL_ADDRESS, new_owner); // Should fail
    }
    // set_owner test cases end

    // recover_and_update_data test cases start
    // Verifies recovering excess rewards and updating reward data
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_recover_and_update_data(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let balance_before = primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(balance_before == reward, 0x50); // Pool has 10 DXLYN_DECIMAL

        let next_epoch = minter::active_period() + WEEK;
        let reward_per_token_before =
            bribe::reward_per_token(POOL_ADDRESS, next_epoch, usdt_metadata);
        assert!(reward_per_token_before == reward, 0x51); // Reward per token is 10 DXLYN_DECIMAL

        // Recover 5 coins from pool
        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::recover_and_update_data(dev, POOL_ADDRESS, usdt_metadata, recover_amount);

        let balance_after = primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(balance_after == reward - recover_amount, 0x52); // Pool has 5 DXLYN_DECIMAL left

        let owner_balance = primary_fungible_store::balance(address_of(dev), usdt_asset);
        assert!(
            owner_balance == mint_amount - reward + recover_amount,
            0x53
        ); // Owner gets recovered 5 coins

        let reward_per_token_after =
            bribe::reward_per_token(POOL_ADDRESS, next_epoch, usdt_metadata);
        assert!(
            reward_per_token_after == reward - recover_amount,
            0x54
        ); // Reward per token updated to 5 coins
    }

    // Tests that only the owner can recover rewards
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_recover_and_update_data_non_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::recover_and_update_data(
            bob,
            POOL_ADDRESS,
            usdt_metadata,
            recover_amount
        ); // Should fail: bob is not owner
    }

    // Tests that recovering more than available rewards fails
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_AMOUNT, location = bribe)]
    fun test_recover_and_update_data_excessive_amount(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let excessive_amount = 100 * DXLYN_DECIMAL;
        bribe::recover_and_update_data(
            dev,
            POOL_ADDRESS,
            usdt_metadata,
            excessive_amount
        ); // Should fail: too much
    }


    // Tests that recovering rewards fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_recover_and_update_data_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::recover_and_update_data(dev, POOL_ADDRESS, usdt_metadata, recover_amount); // Should fail
    }
    // recover_and_update_data test cases end

    // emergency_recover test cases start
    // Verifies emergency recovery of rewards without updating reward data
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_emergency_recover(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let balance_before = primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(balance_before == reward, 0x60);

        let next_epoch = minter::active_period() + WEEK;
        let reward_per_token_before =
            bribe::reward_per_token(POOL_ADDRESS, next_epoch, usdt_metadata);
        assert!(reward_per_token_before == reward, 0x61);

        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::emergency_recover(dev, POOL_ADDRESS, usdt_metadata, recover_amount);

        let balance_after = primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(balance_after == reward - recover_amount, 0x62); // Pool has 5 DXLYN_DECIMAL left

        let owner_balance = primary_fungible_store::balance(address_of(dev), usdt_asset);
        assert!(
            owner_balance == mint_amount - reward + recover_amount,
            0x63
        ); // Owner gets recovered amount

        let reward_per_token_after =
            bribe::reward_per_token(POOL_ADDRESS, next_epoch, usdt_metadata);
        assert!(reward_per_token_after == reward, 0x64); // Reward per token unchanged
    }

    // Tests that only the owner can perform emergency recovery
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_emergency_recover_non_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::emergency_recover(bob, POOL_ADDRESS, usdt_metadata, recover_amount); // Should fail: bob is not owner
    }

    // Tests that emergency recovering more than available rewards fails
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_AMOUNT, location = bribe)]
    fun test_emergency_recover_excessive_amount(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let mint_amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), mint_amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let excessive_amount = 100 * DXLYN_DECIMAL;
        bribe::emergency_recover(
            dev,
            POOL_ADDRESS,
            usdt_metadata,
            excessive_amount
        ); // Should fail
    }

    // Tests that emergency recovery fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_emergency_recover_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let recover_amount = 5 * DXLYN_DECIMAL;
        bribe::emergency_recover(dev, POOL_ADDRESS, usdt_metadata, recover_amount); // Should fail
    }
    // emergency_recover test cases end

    // add_reward_tokens test cases start
    // Verifies adding new reward tokens to a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_add_rewards_tokens(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);

        let tokens = vector[usdt_metadata, usdc_metadata];
        bribe::add_reward_tokens(dev, POOL_ADDRESS, tokens);

        // Verify USDT is added and listed
        let (is_added, is_contain_in_list) =
            bribe::get_token_data(POOL_ADDRESS, usdt_metadata);
        assert!(is_added, 0x48); // USDT marked as valid reward token
        assert!(is_contain_in_list, 0x49); // USDT in reward token list

        // Verify USDC is added and listed
        let (is_added, is_contain_in_list) =
            bribe::get_token_data(POOL_ADDRESS, usdc_metadata);
        assert!(is_added, 0x48); // USDC marked as valid reward token
        assert!(is_contain_in_list, 0x49); // USDC in reward token list
    }

    // Tests that adding reward token fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_add_reward_tokens_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);

        let tokens = vector[usdt_metadata, usdc_metadata];
        bribe::add_reward_tokens(dev, POOL_ADDRESS, tokens); // Should fail
    }

    // Tests that only the owner can add reward tokens
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_add_reward_tokens_with_non_owner_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);

        let tokens = vector[usdt_metadata, usdc_metadata];
        bribe::add_reward_tokens(bob, POOL_ADDRESS, tokens); // Should fail: bob is not owner
    }
    // add_reward_tokens test cases end

    // add_reward_token test cases start
    // Verifies adding new reward tokens to a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_add_reward_token(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        // Verify USDT is added and listed
        let (is_added, is_contain_in_list) =
            bribe::get_token_data(POOL_ADDRESS, usdt_metadata);
        assert!(is_added, 0x48); // USDT marked as valid reward token
        assert!(is_contain_in_list, 0x49); // USDT in reward token list
    }

    // Tests that adding reward token fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_add_reward_token_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata); // Should fail
    }

    // Tests that only the owner can add reward tokens
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_add_reward_token_with_non_owner_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(bob, POOL_ADDRESS, usdt_metadata); // Should fail: bob is not owner
    }
    // add_reward_token test cases end

    // create_bribe test cases start
    // Verifies the creation of bribe pools for specific LP tokens
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_create_bribe(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        // Create a bribe pool for POOL_ADDRESS with dev as voter
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        // Get bribe state (timestamp, owner, voter)
        let (first_timestamp, owner, voter) = bribe::get_bribe_state(POOL_ADDRESS);
        // Verify initial state
        assert!(first_timestamp == 0, 0x1); // No rewards yet, so timestamp is 0
        assert!(owner == address_of(dev), 0x2); // Dev is the owner
        assert!(voter == address_of(dev), 0x3); // Dev is the voter
    }

    // Tests that only the owner can create a bribe
    // Ensures unauthorized accounts (e.g., bob) cannot create bribe pools
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x222)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_OWNER, location = bribe)]
    fun test_create_bribe_with_non_owner_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        // Bob tries to create a bribe (should fail with abort code 0x1: not owner)
        bribe::create_bribe(bob, voter_address, POOL_ADDRESS, @0x001);
    }

    // Tests that creating a bribe for the same LP token twice fails
    // Prevents duplicate bribe pools for the same token, avoiding conflicts
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_ALREADY_EXISTS, location = bribe)]
    fun test_create_bribe_for_same_lptoken(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        // Second attempt for same LPToken should fail (abort code 0x2: already exists)
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
    }
    // create_bribe test cases end

    // deposit test cases start
    // Verifies depositing LP tokens into a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_deposit(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        account::create_account_for_test(address_of(bob));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let total_supply_before = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_before == 0, 0x31); // No deposits yet

        let balance_before = bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(balance_before == 0, 0x32); // Dev has no balance

        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_dev);
        let balance_after = bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(balance_after == deposit_vote_dev, 0x33); // Dev balance updated

        // Deposit again to test cumulative deposits
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_dev);
        let balance_after_second_deposit =
            bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(
            balance_after_second_deposit == deposit_vote_dev * 2,
            0x34
        ); // Balance is 2 coins

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let total_supply_after = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_after == deposit_vote_dev * 2, 0x35); // Total supply reflects deposits
    }

    // Tests that depositing fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_deposit_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_dev); // Should fail
    }

    // Tests that depositing zero tokens fails
    // Ensures the system rejects invalid deposits
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_AMOUNT, location = bribe)]
    fun test_deposit_zero_vote(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let deposit_vote_dev = 0;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_dev); // Should fail: zero deposit
    }

    // Tests that only the voter can deposit
    // Prevents unauthorized accounts from depositing
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_VOTER, location = bribe)]
    fun test_deposit_using_non_voter_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(bob, POOL_ADDRESS, token, deposit_vote_dev); // Should fail: bob is not voter
    }
    // deposit test cases end

    // withdraw test cases start
    // Verifies withdrawing votes from a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_withdraw(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        account::create_account_for_test(address_of(bob));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let total_supply_before = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_before == 0, 0x31);

        let balance_before = bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(balance_before == 0, 0x32);

        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_dev);
        let balance_after = bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(balance_after == deposit_vote_dev, 0x33); // Balance after deposit

        // Withdraw all deposited tokens
        bribe::withdraw(dev, POOL_ADDRESS, token, deposit_vote_dev);
        let balance_after_withdraw = bribe::balance_of_owner(POOL_ADDRESS, dev_address);
        assert!(balance_after_withdraw == 0, 0x33); // Balance reset to zero

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let total_supply_after = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_after == 0, 0x35); // Total supply reset
    }

    // Tests that withdrawing fails if bribe doesn't exist
    // Ensures the system rejects withdrawals for non-existent pools
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_AMOUNT, location = bribe)]
    fun test_withdraw_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let withdraw_vote_dev = 0;
        bribe::withdraw(
            dev,
            POOL_ADDRESS,
            token,
            withdraw_vote_dev
        ); // Should fail: bribe not created
    }

    // Tests that withdrawing zero tokens fails
    // Prevents invalid withdrawal attempts
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INVALID_AMOUNT, location = bribe)]
    fun test_withdraw_zero_vote(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);

        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let withdraw_vote_dev = 0;
        bribe::withdraw(
            dev,
            POOL_ADDRESS,
            token,
            withdraw_vote_dev
        ); // Should fail: zero withdrawal
    }

    // Tests that only the voter can withdraw
    // Ensures unauthorized accounts cannot withdraw
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_VOTER, location = bribe)]
    fun test_withdraw_using_non_voter_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let withdraw_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::withdraw(
            bob,
            POOL_ADDRESS,
            token,
            withdraw_vote_dev
        ); // Should fail: bob is not voter
    }
    // withdraw test cases end

    // get_reward test cases start
    // Verifies claiming earned rewards by users
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_get_reward(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, bob, b"NFT Collection", b"Token1");
        account::create_account_for_test(address_of(bob));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let voter_address = address_of(dev);
        let bob_address = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        //Add USDT as a reward token
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        //Add USDC as a reward token
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdc_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);
        test_internal_coins::register_and_mint_usdc(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdc_metadata, reward);

        let deposit_vote_bob = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        voter::update_period();

        let total_supply = bribe::total_supply(POOL_ADDRESS);
        timestamp::fast_forward_seconds(WEEK);

        voter::update_period();

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let bribe_balance_before =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(bribe_balance_before == reward, 0x36); // Bribe pool holds full reward

        let usdc_asset =
            object::address_to_object<fungible_asset::Metadata>(usdc_metadata);
        let bribe_balance_before =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        assert!(bribe_balance_before == reward, 0x362); // Bribe pool holds full reward

        let bob_usdt_balance_before =
            primary_fungible_store::balance(bob_address, usdt_asset);
        assert!(bob_usdt_balance_before == 0, 0x37); // Bob has no USDT initially

        let bob_usdc_balance_before =
            primary_fungible_store::balance(bob_address, usdc_asset);
        assert!(bob_usdc_balance_before == 0, 0x372); // Bob has no USDC initially

        let reward_tokens = vector[usdt_metadata, usdc_metadata];

        let remaining_claim_calls_usdt_metadata = bribe::get_remaining_bribe_claim_calls(
            POOL_ADDRESS,
            token,
            usdt_metadata
        );
        let remaining_claim_calls_usdc_metadata = bribe::get_remaining_bribe_claim_calls(
            POOL_ADDRESS,
            token,
            usdc_metadata
        );
        assert!(remaining_claim_calls_usdt_metadata == 1, 0x38a);
        assert!(remaining_claim_calls_usdc_metadata == 1, 0x39a);

        // Bob claims his reward
        bribe::get_reward(bob, POOL_ADDRESS, reward_tokens);

        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        //Check bribe USDT balance after bob claim
        let bribe_usdt_balance_after =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(
            bribe_usdt_balance_after == reward - expected_bob_reward,
            0x38
        ); // Reward deducted from pool

        //Check bribe USDC balance after bob claim
        let bribe_usdc_balance_after =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        assert!(
            bribe_usdc_balance_after == reward - expected_bob_reward,
            0x382
        ); // Reward deducted from pool

        //Check bob USDT balance after bob claim
        let bob_usdt_balance_after =
            primary_fungible_store::balance(bob_address, usdt_asset);
        assert!(bob_usdt_balance_after == expected_bob_reward, 0x39); // Bob receives his reward

        //Check bob USDC balance after bob claim
        let bob_usdc_balance_after =
            primary_fungible_store::balance(bob_address, usdc_asset);
        assert!(bob_usdc_balance_after == expected_bob_reward, 0x392); // Bob receives his reward
    }

    // Tests that claiming rewards fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_get_reward_before_create_bribe(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let reward_tokens = vector[usdt_metadata];

        bribe::get_reward(bob, POOL_ADDRESS, reward_tokens); // Should fail
    }
    // get_reward test cases end


    // get_reward_for_token_owner test cases start
    // Verifies claiming earned rewards by users
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_get_reward_for_token_owner(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, bob, b"NFT Collection", b"Token1");
        account::create_account_for_test(address_of(bob));
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let voter_address = address_of(dev);
        let bob_address = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        //Add USDT as a reward token
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        //Add USDC as a reward token
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdc_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);
        test_internal_coins::register_and_mint_usdc(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdc_metadata, reward);

        let deposit_vote_bob = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        voter::update_period();

        let total_supply = bribe::total_supply(POOL_ADDRESS);
        timestamp::fast_forward_seconds(WEEK);

        voter::update_period();

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let bribe_balance_before =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(bribe_balance_before == reward, 0x36); // Bribe pool holds full reward

        let usdc_asset =
            object::address_to_object<fungible_asset::Metadata>(usdc_metadata);
        let bribe_balance_before =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        assert!(bribe_balance_before == reward, 0x362); // Bribe pool holds full reward

        let bob_usdt_balance_before =
            primary_fungible_store::balance(bob_address, usdt_asset);
        assert!(bob_usdt_balance_before == 0, 0x37); // Bob has no USDT initially

        let bob_usdc_balance_before =
            primary_fungible_store::balance(bob_address, usdc_asset);
        assert!(bob_usdc_balance_before == 0, 0x372); // Bob has no USDC initially

        let reward_tokens = vector[usdt_metadata, usdc_metadata];

        // Bob claims his reward for the specific token
        bribe::get_reward_for_token_owner(bob, POOL_ADDRESS, token, reward_tokens);

        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        //Check bribe USDT balance after bob claim
        let bribe_usdt_balance_after =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(
            bribe_usdt_balance_after == reward - expected_bob_reward,
            0x38
        ); // Reward deducted from pool

        //Check bribe USDC balance after bob claim
        let bribe_usdc_balance_after =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        assert!(
            bribe_usdc_balance_after == reward - expected_bob_reward,
            0x382
        ); // Reward deducted from pool

        //Check bob USDT balance after bob claim
        let bob_usdt_balance_after =
            primary_fungible_store::balance(bob_address, usdt_asset);
        assert!(bob_usdt_balance_after == expected_bob_reward, 0x39); // Bob receives his reward

        //Check bob USDC balance after bob claim
        let bob_usdc_balance_after =
            primary_fungible_store::balance(bob_address, usdc_asset);
        assert!(bob_usdc_balance_after == expected_bob_reward, 0x392); // Bob receives his reward
    }

    // Tests that claiming rewards fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_get_reward_for_token_owner_before_create_bribe(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let reward_tokens = vector[usdt_metadata];
        let token = test_nft::test_create_and_transfer(dev, bob, b"NFT Collection", b"Token1");

        bribe::get_reward_for_token_owner(bob, POOL_ADDRESS, token, reward_tokens); // Should fail
    }
    // get_reward_for_token_owner test cases end

    // get_reward_for_address test cases start
    // Verifies claiming rewards on behalf of another user (by the voter)
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_get_reward_for_address(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, bob, b"NFT Collection", b"Token1");
        fee_distributor::toggle_allow_checkpoint_token(dev);
        account::create_account_for_test(address_of(bob));
        let voter_address = address_of(dev);
        let bob_address = address_of(bob);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        //Add USDT as a reward token
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        //Add USDC as a reward token
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdc_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);
        test_internal_coins::register_and_mint_usdc(dev, address_of(dev), amount);

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward); //notify USDT
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdc_metadata, reward); //notify USDC

        let deposit_vote_bob = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        let total_supply = bribe::total_supply(POOL_ADDRESS);
        timestamp::fast_forward_seconds(WEEK + DAY);
        voter::update_period();

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let bribe_usdt_balance_before =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        //Check bribe USDT balance before claim
        assert!(bribe_usdt_balance_before == reward, 0x40);

        let usdc_asset =
            object::address_to_object<fungible_asset::Metadata>(usdc_metadata);
        let bribe_usdc_balance_before =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        //Check bribe USDC balance before claim
        assert!(bribe_usdc_balance_before == reward, 0x402);

        let bob_usdt_balance_before =
            primary_fungible_store::balance(bob_address, usdt_asset);
        //Check bob USDT balance before claim
        assert!(bob_usdt_balance_before == 0, 0x41);

        let bob_usdc_balance_before =
            primary_fungible_store::balance(bob_address, usdt_asset);
        //Check bob USDC balance before claim
        assert!(bob_usdc_balance_before == 0, 0x41);

        let reward_tokens = vector[usdt_metadata, usdc_metadata];

        // Dev (voter) claims reward for Bob
        bribe::get_reward_for_address(dev, POOL_ADDRESS, bob_address, reward_tokens);

        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        let bribe_usdt_balance_after =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        //Check bribe USDT balance after claim
        assert!(
            bribe_usdt_balance_after == reward - expected_bob_reward,
            0x42
        );

        let bribe_usdc_balance_after =
            primary_fungible_store::balance(bribe_address, usdc_asset);
        //Check bribe USDC balance after claim
        assert!(
            bribe_usdc_balance_after == reward - expected_bob_reward,
            0x422
        );

        let bob_usdt_balance_after =
            primary_fungible_store::balance(bob_address, usdt_asset);
        //Check bob USDT balance after claim
        assert!(bob_usdt_balance_after == expected_bob_reward, 0x43);

        let bob_usdc_balance_after =
            primary_fungible_store::balance(bob_address, usdc_asset);
        //Check bob USDC balance after claim
        assert!(bob_usdc_balance_after == expected_bob_reward, 0x432);
    }

    // Tests that claiming rewards for another user fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_get_reward_for_address_before_create_bribe(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        timestamp::fast_forward_seconds(DAY * 2);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let reward_tokens = vector[usdt_metadata];
        bribe::get_reward_for_address(
            dev,
            POOL_ADDRESS,
            address_of(bob),
            reward_tokens
        ); // Should fail
    }

    // Tests that only the voter can claim rewards for another user
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    #[expected_failure(abort_code = bribe::ERROR_NOT_VOTER, location = bribe)]
    fun test_get_reward_for_address_using_non_voter_account(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let reward_tokens = vector[usdt_metadata];
        bribe::get_reward_for_address(
            bob,
            POOL_ADDRESS,
            address_of(bob),
            reward_tokens
        ); // Should fail: bob is not voter
    }
    // get_reward_for_address test cases end

    // notify_reward_amount test cases start
    // Verifies adding rewards to a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_notify_reward_amount(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let owner_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, owner_address, amount);

        let bribe_address = bribe::check_and_get_bribe_address(POOL_ADDRESS);
        let usdt_asset =
            object::address_to_object<fungible_asset::Metadata>(usdt_metadata);
        let bribe_balance_before =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(bribe_balance_before == 0, 0x44); // No rewards in pool

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        // Verify reward is scheduled for next epoch
        let (first_bribe_timestamp, _, _) = bribe::get_bribe_state(POOL_ADDRESS);
        assert!(
            first_bribe_timestamp == minter::active_period() + WEEK,
            0x45
        );

        let bribe_balance_after =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(bribe_balance_after == reward, 0x45); // Reward added to pool

        // Add another reward to test cumulative rewards
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        let bribe_balance_after_second =
            primary_fungible_store::balance(bribe_address, usdt_asset);
        assert!(bribe_balance_after_second == reward * 2, 0x46); // Total 20 DXLYN_DECIMAL

        let total_reward_for_next_week =
            bribe::reward_per_token(
                POOL_ADDRESS,
                minter::active_period() + WEEK,
                usdt_metadata
            );
        assert!(total_reward_for_next_week == reward * 2, 0x47); // Total reward for next epoch
    }

    // Tests that notifying rewards fails if reward token isn't added
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_TOKEN_NOT_VERIFIED, location = bribe)]
    fun test_notify_reward_amount_without_add_reward_token(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward); // Should fail: USDT not added
    }

    // Tests that notifying rewards fails if insufficient balance
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE, location = bribe)]
    fun test_notify_reward_amount_with_insufficient(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, address_of(dev), amount);
        let reward = 1000 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward); // Should fail: insufficient USDT
    }
    // notify_reward_amount test cases end

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       VIEW FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // get_epoch_start test cases start
    // Tests calculation of current epoch start time
    // Verifies that the bribe system correctly identifies the start of the current week
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_get_epoch_start(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let start = bribe::get_epoch_start();
        // Epoch start should match current timestamp (aligned to week boundary)
        assert!(start == timestamp::now_seconds(), 0x4);
    }
    // get_epoch_start test cases start

    // get_next_epoch_start test cases start
    // Tests calculation of next epoch start time
    // Ensures the system can predict the start of the next week for reward scheduling
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_get_next_epoch_start(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let next_start = bribe::get_next_epoch_start();
        // Next epoch starts one week after current timestamp
        assert!(
            next_start == timestamp::now_seconds() + WEEK,
            0x5
        );
    }
    // get_next_epoch_start test cases end

    // rewards_list_length test cases start
    // Checks the tracking of reward tokens (e.g., USDT) for a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_rewards_list_length(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        // Check initial number of reward tokens
        let reward_length_before = bribe::rewards_list_length(POOL_ADDRESS);
        assert!(reward_length_before == 0, 0x6); // No reward tokens added yet

        // Add USDT as a reward token
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);
        let reward_length_after = bribe::rewards_list_length(POOL_ADDRESS);
        assert!(reward_length_after == 1, 0x7); // One reward token (USDT) added
    }

    // Tests that checking reward list length fails if bribe doesn't exist
    // Ensures the system rejects queries for non-existent bribe pools
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_rewards_list_length_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        // Query reward list length for non-existent bribe (should fail with abort code 0x3)
        bribe::rewards_list_length(POOL_ADDRESS);
    }
    // rewards_list_length test cases end

    // total_supply test cases start
    // Verifies the total amount of LP tokens deposited in a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_total_supply(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let total_supply_before = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_before == 0, 0x8); // No deposits yet

        // Deposit 1 unit of votes
        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        // Advance time by one week and update epoch
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let total_supply_after = bribe::total_supply(POOL_ADDRESS);
        assert!(total_supply_after == 1, 0x9); // Reflects the deposit after epoch update
    }

    // Tests that querying total supply fails if bribe doesn't exist
    // Prevents access to non-existent bribe pools
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_total_supply_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        bribe::total_supply(POOL_ADDRESS); // Should fail: bribe not created
    }
    // total_supply test cases end

    // total_supply_at test cases start
    // Checks the total supply at a specific future timestamp
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_total_supply_at(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        let voter_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        // Query supply at next epoch
        let total_supply_before =
            bribe::total_supply_at(POOL_ADDRESS, timestamp::now_seconds() + WEEK);
        assert!(total_supply_before == 0, 0x10); // No deposits yet

        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        let total_supply_after =
            bribe::total_supply_at(POOL_ADDRESS, timestamp::now_seconds() + WEEK);
        assert!(total_supply_after == 1, 0x11); // Reflects deposit at future timestamp
    }

    // Tests that querying total supply at a future timestamp fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_total_supply_at_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        bribe::total_supply_at(POOL_ADDRESS, timestamp::now_seconds() + WEEK); // Should fail: bribe not created
    }
    // total_supply_at test cases end

    // balance_of test cases start
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_balance_of(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);

        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let balance_before = bribe::balance_of(POOL_ADDRESS, token);
        assert!(balance_before == 0, 0x12); // No deposits yet

        // Only voter can deposit votes
        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        let balance_after = bribe::balance_of(POOL_ADDRESS, token);
        assert!(balance_after == 1, 0x13); // Reflects the deposit
    }

    // Tests that querying token owner balance fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_balance_of_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::balance_of(POOL_ADDRESS, token); // Should fail: bribe not created
    }
    // balance_of test cases end

    // balance_of_at test cases start
    // Checks the token owner's balance at a specific future timestamp
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_balance_of_at(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let balance_before =
            bribe::balance_of_at(
                POOL_ADDRESS, token, timestamp::now_seconds() + WEEK
            );
        assert!(balance_before == 0, 0x14); // No deposits at future timestamp

        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        let balance_after =
            bribe::balance_of_at(
                POOL_ADDRESS, token, timestamp::now_seconds() + WEEK
            );
        assert!(balance_after == 1, 0x15); // Reflects deposit at future timestamp
    }

    // Tests that querying token owner balance at a future timestamp fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_balance_of_at_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::balance_of_at(
            POOL_ADDRESS, token, timestamp::now_seconds() + WEEK
        ); // Should fail
    }
    // balance_of_at test cases end

    // balance_of_owner test cases start
    // Verifies the LP token balance of a specific user in a bribe pool
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_balance_of_owner(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);

        let voter_address = address_of(dev);
        let owner_address = address_of(dev);

        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let balance_before = bribe::balance_of_owner(POOL_ADDRESS, owner_address);
        assert!(balance_before == 0, 0x12); // No deposits yet

        // Only voter can deposit votes
        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        let balance_after = bribe::balance_of_owner(POOL_ADDRESS, owner_address);
        assert!(balance_after == 1, 0x13); // Reflects the deposit
    }

    // Tests that querying owner balance fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_balance_of_owner_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let owner_address = address_of(dev);
        bribe::balance_of_owner(POOL_ADDRESS, owner_address); // Should fail: bribe not created
    }
    // balance_of_owner test cases end


    // balance_of_owner_at test cases start
    // Checks the owner's balance at a specific future timestamp
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_balance_of_owner_at(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let owner_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let balance_before =
            bribe::balance_of_owner_at(
                POOL_ADDRESS, owner_address, timestamp::now_seconds() + WEEK
            );
        assert!(balance_before == 0, 0x14); // No deposits at future timestamp

        bribe::deposit(dev, POOL_ADDRESS, token, 1);
        let balance_after =
            bribe::balance_of_owner_at(
                POOL_ADDRESS, owner_address, timestamp::now_seconds() + WEEK
            );
        assert!(balance_after == 1, 0x15); // Reflects deposit at future timestamp
    }

    // Tests that querying owner balance at a future timestamp fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_balance_of_owner_at_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let owner_address = address_of(dev);
        bribe::balance_of_owner_at(
            POOL_ADDRESS, owner_address, timestamp::now_seconds() + WEEK
        ); // Should fail
    }
    // balance_of_owner_at test cases end

    // earned_from_token test cases start
    // Verifies how much rewards (e.g., USDT) are earned by token owner based on their deposits
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_earned_from_token(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let voter_address = address_of(dev);
        let owner_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        // Mint 100 coins worth of USDT for dev
        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, owner_address, amount);
        // Add 10 coins as reward
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        // Deposit 1 coins worth of votes
        bribe::deposit(dev, POOL_ADDRESS, token, 1 * DXLYN_DECIMAL);

        // Advance time by two weeks to allow reward accrual
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        // Check earned rewards
        let (total_earned_reward, _) = bribe::earned_from_token(POOL_ADDRESS, token, usdt_metadata);

        assert!(total_earned_reward == reward, 0x16); // Dev earns full reward (only depositor)
    }

    // Tests reward distribution with multiple depositors
    // Verifies that rewards are split proportionally based on deposit amounts
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_earned_from_token_multiple_deposit(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let token2 = test_nft::test_create_and_transfer(dev, bob, b"2 NFT Collection", b"Token2");
        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        let bob_address = address_of(bob);
        // Create Bob's account
        account::create_account_for_test(bob_address);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        // Dev deposits 1 coins, Bob deposits 2 coins (1:2 ratio)
        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token1, deposit_vote_dev);
        let deposit_vote_bob = 2 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token2, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);

        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        voter::update_period();
        let total_supply = bribe::total_supply(POOL_ADDRESS);
        assert!(
            total_supply == deposit_vote_dev + deposit_vote_bob,
            0x17
        ); // Total supply is 3 coins

        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        let (dev_total_earned_reward, _) = bribe::earned_from_token(
            POOL_ADDRESS,
            token1,
            usdt_metadata
        );

        let (bob_total_earned_reward, _) = bribe::earned_from_token(
            POOL_ADDRESS,
            token2,
            usdt_metadata
        );


        // Calculate rewards: reward_per_token = (reward * MULTIPLIER) / total_supply
        // Dev gets 1/3 of reward, Bob gets 2/3
        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_dev_reward = (deposit_vote_dev * reward_per_token) / MULTIPLIER;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        assert!(dev_total_earned_reward == expected_dev_reward, 0x18); // Dev gets ~3.33 DXLYN_DECIMAL
        assert!(bob_total_earned_reward == expected_bob_reward, 0x19); // Bob gets ~6.67 DXLYN_DECIMAL
    }

    // Tests that checking earned rewards fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_earned_from_token_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::earned_from_token(POOL_ADDRESS, token1, usdt_metadata); // Should fail: bribe not created
    }
    // earned_from_token test cases end

    // earned test cases start
    // Verifies how rewards (e.g., USDT) are earned by users based on their deposits
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_earned(dev: &signer, supra_framework: &signer) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let voter_address = address_of(dev);
        let owner_address = address_of(dev);
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        // Mint 100 coins worth of USDT for dev
        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, owner_address, amount);
        // Add 10 coins as reward
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        // Deposit 1 coins worth of votes
        bribe::deposit(dev, POOL_ADDRESS, token, 1 * DXLYN_DECIMAL);

        // Advance time by two weeks to allow reward accrual
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        // Check earned rewards
        let (total_earned_reward, _) = bribe::earned(POOL_ADDRESS, owner_address, usdt_metadata);

        assert!(total_earned_reward == reward, 0x16); // Dev earns full reward (only depositor)

        let (_, _, _, _, bribe_earned, _, _, _, _, _) = voter::total_claimable_rewards(
            owner_address,
            usdt_metadata,
            vector[],
            vector[],
            vector[],
            vector[],
            vector[POOL_ADDRESS]
        );

        assert!(bribe_earned == reward, 0x6);
    }

    // Tests reward distribution with multiple depositors
    // Verifies that rewards are split proportionally based on deposit amounts
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_earned_multiple_deposit(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let token2 = test_nft::test_create_and_transfer(dev, bob, b"2 NFT Collection", b"Token2");
        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        let bob_address = address_of(bob);
        // Create Bob's account
        account::create_account_for_test(bob_address);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        // Dev deposits 1 coins, Bob deposits 2 coins (1:2 ratio)
        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token1, deposit_vote_dev);
        let deposit_vote_bob = 2 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token2, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);

        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        voter::update_period();
        let total_supply = bribe::total_supply(POOL_ADDRESS);
        assert!(
            total_supply == deposit_vote_dev + deposit_vote_bob,
            0x17
        ); // Total supply is 3 coins

        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        let (dev_total_earned_reward, _) = bribe::earned(POOL_ADDRESS, dev_address, usdt_metadata);

        let (bob_total_earned_reward, _) = bribe::earned(POOL_ADDRESS, bob_address, usdt_metadata);

        // Calculate rewards: reward_per_token = (reward * MULTIPLIER) / total_supply
        // Dev gets 1/3 of reward, Bob gets 2/3
        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_dev_reward = (deposit_vote_dev * reward_per_token) / MULTIPLIER;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        assert!(dev_total_earned_reward == expected_dev_reward, 0x18); // Dev gets ~3.33 DXLYN_DECIMAL
        assert!(bob_total_earned_reward == expected_bob_reward, 0x19); // Bob gets ~6.67 DXLYN_DECIMAL
    }

    // Tests that checking earned rewards fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_earned_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let owner_address = address_of(dev);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::earned(POOL_ADDRESS, owner_address, usdt_metadata); // Should fail: bribe not created
    }
    // earned test cases end

    // earned_with_timestamp test cases start
    // Verifies earned rewards and the timestamp of the last reward update
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    fun test_earned_with_timestamp(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        fee_distributor::toggle_allow_checkpoint_token(dev);
        let voter_address = address_of(dev);
        let owner_address = address_of(dev);
        let token = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, owner_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        bribe::deposit(dev, POOL_ADDRESS, token, 1 * DXLYN_DECIMAL);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        let (earned_reward, last_reward_time) =
            bribe::earned_with_timestamp(POOL_ADDRESS, owner_address, usdt_metadata);
        assert!(earned_reward == reward, 0x20); // Full reward earned (sole depositor)
        // Last reward time is aligned to the current epoch (week boundary)
        assert!(
            last_reward_time == timestamp::now_seconds() / WEEK * WEEK,
            0x21
        );
    }

    // Tests reward distribution and timestamps with multiple depositors
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_earned_with_timestamp_multiple_deposit(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        let bob_address = address_of(bob);

        let token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let token2 = test_nft::test_create_and_transfer(dev, bob, b"2 NFT Collection", b"Token2");

        account::create_account_for_test(bob_address);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);
        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);

        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token1, deposit_vote_dev);
        let deposit_vote_bob = 2 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token2, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let total_supply = bribe::total_supply(POOL_ADDRESS);
        assert!(
            total_supply == deposit_vote_dev + deposit_vote_bob,
            0x22
        ); // Total supply is 3 coins

        timestamp::fast_forward_seconds(WEEK);
        voter::update_period();

        let (dev_earned_reward, dev_last_timestamp) =
            bribe::earned_with_timestamp(POOL_ADDRESS, dev_address, usdt_metadata);
        let (bob_earned_reward, bob_last_timestamp) =
            bribe::earned_with_timestamp(POOL_ADDRESS, bob_address, usdt_metadata);

        let reward_per_token = (reward * MULTIPLIER) / total_supply;
        let expected_dev_reward = (deposit_vote_dev * reward_per_token) / MULTIPLIER;
        let expected_bob_reward = (deposit_vote_bob * reward_per_token) / MULTIPLIER;

        assert!(dev_earned_reward == expected_dev_reward, 0x23); // Dev earns 1/3 of reward
        assert!(bob_earned_reward == expected_bob_reward, 0x24); // Bob earns 2/3 of reward
        assert!(
            dev_last_timestamp == timestamp::now_seconds() / WEEK * WEEK,
            0x25
        ); // Dev timestamp updated
        assert!(
            bob_last_timestamp == timestamp::now_seconds() / WEEK * WEEK,
            0x26
        ); // Bob timestamp updated
    }

    // Tests that checking earned rewards with timestamp fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_earned_with_timestamp_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let owner_address = address_of(dev);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::earned_with_timestamp(POOL_ADDRESS, owner_address, usdt_metadata); // Should fail
    }
    // earned_with_timestamp test cases end

    // reward_per_token test cases start
    // Verifies the reward per token calculation, which determines how rewards are distributed
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, bob = @0x122)]
    fun test_reward_per_token(
        dev: &signer, supra_framework: &signer, bob: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let token1 = test_nft::test_create_and_transfer(dev, dev, b"NFT Collection", b"Token1");
        let token2 = test_nft::test_create_and_transfer(dev, dev, b"2 NFT Collection", b"Token2");

        let voter_address = address_of(dev);
        let dev_address = address_of(dev);
        let bob_address = address_of(bob);
        account::create_account_for_test(bob_address);

        fee_distributor::toggle_allow_checkpoint_token(dev);

        bribe::create_bribe(dev, voter_address, POOL_ADDRESS, @0x001);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::add_reward_token(dev, POOL_ADDRESS, usdt_metadata);

        let amount = 100 * DXLYN_DECIMAL;
        test_internal_coins::register_and_mint_usdt(dev, dev_address, amount);

        // Check reward per token before any rewards are notified
        let reward_per_token_before_notify =
            bribe::reward_per_token(
                POOL_ADDRESS,
                minter::active_period() + WEEK,
                usdt_metadata
            );
        assert!(reward_per_token_before_notify == 0, 0x27); // No rewards yet

        let reward = 10 * DXLYN_DECIMAL;
        bribe::notify_reward_amount(dev, POOL_ADDRESS, usdt_metadata, reward);
        // Check reward per token before deposits
        let reward_per_token_before_deposit =
            bribe::reward_per_token(
                POOL_ADDRESS,
                minter::active_period() + WEEK,
                usdt_metadata
            );
        assert!(reward_per_token_before_deposit == reward, 0x28); // Full reward (no depositors)

        let deposit_vote_dev = 1 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token1, deposit_vote_dev);
        let deposit_vote_bob = 2 * DXLYN_DECIMAL;
        bribe::deposit(dev, POOL_ADDRESS, token2, deposit_vote_bob);

        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();
        let total_supply = bribe::total_supply(POOL_ADDRESS);
        assert!(
            total_supply == deposit_vote_dev + deposit_vote_bob,
            0x29
        ); // Total supply is 3 coins

        // Calculate expected reward per token: (reward * MULTIPLIER) / total_supply
        let expected_reward_per_token = (reward * MULTIPLIER) / total_supply;
        let actual_reward_per_token =
            bribe::reward_per_token(
                POOL_ADDRESS, minter::active_period(), usdt_metadata
            );
        assert!(expected_reward_per_token == actual_reward_per_token, 0x30); // Reward split among depositors
    }

    // Tests that checking reward per token fails if bribe doesn't exist
    #[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework)]
    #[expected_failure(abort_code = bribe::ERROR_BRIBE_NOT_EXIST, location = bribe)]
    fun test_reward_per_token_before_create_bribe(
        dev: &signer, supra_framework: &signer
    ) {
        setup_test_with_genesis(dev, supra_framework);
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        bribe::reward_per_token(POOL_ADDRESS, minter::active_period(), usdt_metadata); // Should fail
    }
    // reward_per_token test cases end
}
