#[test_only]
module dexlyn_coin::dxlyn_coin_test {
    use std::signer::address_of;
    use std::string;

    use supra_framework::account::Self;
    use supra_framework::coin;
    use supra_framework::fungible_asset;
    use supra_framework::genesis;
    use supra_framework::object::{Self, object_address};
    use supra_framework::primary_fungible_store;
    use supra_framework::supra_account;
    use supra_framework::timestamp;

    use dexlyn_coin::dxlyn_coin::{Self, DXLYN, get_dxlyn_asset_metadata, get_dxlyn_info};

    // Constants
    const SC_ADMIN: address = @dexlyn_coin;
    const DXLYN_DECIMAL: u64 = 100000000;

    /// DXLYN Initial supply
    const INITIAL_SUPPLY: u64 = 10000000000000000; // 100 Million with 10^8 decimal

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(1000);
        setup_test(dev);
    }

    #[test_only]
    fun setup_test(dev: &signer) {
        account::create_account_for_test(address_of(dev));
        dxlyn_coin::init_coin(dev);
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test initialization
    #[test(dev = @dexlyn_coin)]
    fun test_initialize(dev: &signer) {
        setup_test_with_genesis(dev);

        let (owner, minter, future_owner, future_minter, paused) = get_dxlyn_info();
        assert!(owner == @dexlyn_coin_owner, 0x1);
        assert!(minter == @dexlyn_coin_minter, 0x2);
        assert!(future_owner == @0x0, 0x3);
        assert!(future_minter == @0x0, 0x4);

        assert!(coin::name<DXLYN>() == string::utf8(b"DXLYN"), 0x5);
        assert!(coin::symbol<DXLYN>() == string::utf8(b"DXLYN"), 0x6);
        assert!(coin::decimals<DXLYN>() == 8, 0x7);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        assert!(fungible_asset::name(metadata) == string::utf8(b"DXLYN"), 0x8);
        assert!(fungible_asset::symbol(metadata) == string::utf8(b"DXLYN"), 0x9);
        assert!(fungible_asset::decimals(metadata) == 8, 0x10);
        assert!(!paused, 0x11);
    }

    #[test(dev = @dexlyn_coin)]
    #[expected_failure(abort_code = 524289, location = supra_framework::object)]
    fun test_reinitialize(dev: &signer) {
        setup_test_with_genesis(dev);
        dxlyn_coin::init_coin(dev); // Should fail due to object already existing
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test commit_transfer_ownership
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_commit_transfer_ownership(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        dxlyn_coin::commit_transfer_ownership(dev, alice_addr);

        let (owner, minter, future_owner, future_minter, _) = get_dxlyn_info();
        assert!(owner == @dexlyn_coin_owner, 0x1);
        assert!(minter == @dexlyn_coin_minter, 0x2);
        assert!(future_owner == alice_addr, 0x3);
        assert!(future_minter == @0x0, 0x4);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_commit_transfer_ownership_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        dxlyn_coin::commit_transfer_ownership(alice, address_of(alice));
    }

    // Test apply_transfer_ownership
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_apply_transfer_ownership(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        dxlyn_coin::commit_transfer_ownership(dev, alice_addr);
        dxlyn_coin::apply_transfer_ownership(dev);

        let (owner, minter, future_owner, future_minter, _) = get_dxlyn_info();
        assert!(owner == alice_addr, 0x1);
        assert!(minter == @dexlyn_coin_minter, 0x2);
        assert!(future_owner == alice_addr, 0x3); // Assuming future_owner not reset
        assert!(future_minter == @0x0, 0x4);
    }

    #[test(dev = @dexlyn_coin)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_FUTURE_OWNER_NOT_SET, location = dxlyn_coin)]
    fun test_apply_transfer_ownership_no_future_owner(dev: &signer) {
        setup_test_with_genesis(dev);
        dxlyn_coin::apply_transfer_ownership(dev);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_apply_transfer_ownership_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::commit_transfer_ownership(dev, address_of(alice));
        dxlyn_coin::apply_transfer_ownership(alice);
    }

    // Test commit_transfer_minter
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_commit_transfer_minter(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        dxlyn_coin::commit_transfer_minter(dev, alice_addr);

        let (owner, minter, future_owner, future_minter, _) = get_dxlyn_info();
        assert!(owner == @dexlyn_coin_owner, 0x1);
        assert!(minter == @dexlyn_coin_minter, 0x2);
        assert!(future_owner == @0x0, 0x3);
        assert!(future_minter == alice_addr, 0x4);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_commit_transfer_minter_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::commit_transfer_minter(alice, address_of(alice));
    }

    // Test apply_transfer_minter
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_apply_transfer_minter(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        dxlyn_coin::commit_transfer_minter(dev, alice_addr);
        dxlyn_coin::apply_transfer_minter(dev);

        let (owner, minter, future_owner, future_minter, _) = get_dxlyn_info();
        assert!(owner == @dexlyn_coin_owner, 0x1);
        assert!(minter == alice_addr, 0x2);
        assert!(future_owner == @0x0, 0x3);
        assert!(future_minter == alice_addr, 0x4); // Assuming future_minter not reset
    }

    #[test(dev = @dexlyn_coin)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_FUTURE_MINTER_NOT_SET, location = dxlyn_coin)]
    fun test_apply_transfer_minter_no_future_minter(dev: &signer) {
        setup_test_with_genesis(dev);
        dxlyn_coin::apply_transfer_minter(dev);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_apply_transfer_minter_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::commit_transfer_minter(dev, address_of(alice));
        dxlyn_coin::apply_transfer_minter(alice);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_pause(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        let (_, _, _, _, paused) = get_dxlyn_info();

        assert!(!paused, 0x1);
        // Pause the minting
        dxlyn_coin::pause(dev);

        let (_, _, _, _, paused) = get_dxlyn_info();

        assert!(paused, 0x1);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_ALREADY_PAUSED, location = dxlyn_coin)]
    fun test_pause_when_already_paused(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        dxlyn_coin::pause(dev);

        let (_, _, _, _, paused) = get_dxlyn_info();

        assert!(paused, 0x1);
        // Pause the minting
        dxlyn_coin::pause(dev);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_pause_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        // Try to pause with non-owner
        dxlyn_coin::pause(alice);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_unpause(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        // Pause the minting
        dxlyn_coin::pause(dev);

        let (_, _, _, _, paused) = get_dxlyn_info();
        assert!(paused, 0x1);

        // Unpause the minting
        dxlyn_coin::unpause(dev);

        let (_, _, _, _, paused) = get_dxlyn_info();

        assert!(!paused, 0x1);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_PAUSED, location = dxlyn_coin)]
    fun test_unpause_when_not_paused(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let (_, _, _, _, paused) = get_dxlyn_info();

        assert!(!paused, 0x1);
        // Try to unpause when not paused
        dxlyn_coin::unpause(dev);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_unpause_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        // Pause the minting
        dxlyn_coin::pause(dev);

        // Try to unpause with non-owner
        dxlyn_coin::unpause(alice);
    }

    // Test mint
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_mint(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);

        let balance = dxlyn_coin::balance_of(alice_addr);
        assert!(balance == amount, 0x1);
        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(total_supply == amount + INITIAL_SUPPLY, 0x2);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123, bob = @0x124)]
    fun test_mint_by_minter(dev: &signer, alice: &signer, bob: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        account::create_account_for_test(address_of(bob));

        let bob_addr = address_of(bob);
        dxlyn_coin::commit_transfer_minter(dev, bob_addr);
        dxlyn_coin::apply_transfer_minter(dev);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(bob, address_of(alice), amount);

        let balance = dxlyn_coin::balance_of(address_of(alice));
        assert!(balance == amount, 0x1);
        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(total_supply == amount + INITIAL_SUPPLY, 0x2);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_PAUSED, location = dxlyn_coin)]
    fun test_mint_when_paused(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        // Pause
        dxlyn_coin::pause(dev);

        dxlyn_coin::mint(alice, address_of(alice), 1000 * DXLYN_DECIMAL);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_mint_non_owner_non_minter(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::mint(alice, address_of(alice), 1000 * DXLYN_DECIMAL);
    }

    // Test transfer
    #[test(dev = @dexlyn_coin, alice = @0x123, bob = @0x124)]
    fun test_transfer(dev: &signer, alice: &signer, bob: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        account::create_account_for_test(address_of(bob));

        let alice_addr = address_of(alice);
        let bob_addr = address_of(bob);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        dxlyn_coin::transfer(alice, bob_addr, amount / 2);

        assert!(dxlyn_coin::balance_of(alice_addr) == amount / 2, 0x1);
        assert!(dxlyn_coin::balance_of(bob_addr) == amount / 2, 0x2);
        assert!((dxlyn_coin::total_supply() as u64) == amount + INITIAL_SUPPLY, 0x3);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_INSUFFICIENT_BALANCE, location = dxlyn_coin)]
    fun test_transfer_insufficient_balance(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::transfer(alice, @0x124, 1000 * DXLYN_DECIMAL);
    }

    // Test burn_from
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_burn_from(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        let balance_before = dxlyn_coin::balance_of(alice_addr);
        dxlyn_coin::burn_from(dev, alice_addr, amount / 2);

        let balance_after = dxlyn_coin::balance_of(alice_addr);
        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(balance_after == balance_before - amount / 2, 0x1);
        assert!(total_supply == (amount / 2) + INITIAL_SUPPLY, 0x2);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_burn_from_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::mint(dev, address_of(alice), 1000 * DXLYN_DECIMAL);
        dxlyn_coin::burn_from(alice, address_of(alice), 500 * DXLYN_DECIMAL);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = 65542, location = coin)]
    fun test_burn_from_insufficient_balance(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::burn_from(dev, address_of(alice), 1000 * DXLYN_DECIMAL);
    }

    // Test freeze_token
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_freeze_token(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);

        dxlyn_coin::freeze_token(dev, alice_addr);

        assert!(primary_fungible_store::is_frozen(alice_addr, get_dxlyn_asset_metadata()), 0x1);
    }

    // Test freeze_token from legacy coin store
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_freeze_token_from_legacycoin_store(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let dev_addr = address_of(dev);
        let alice_addr = address_of(alice);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, dev_addr, amount);

        let coins = coin::withdraw<DXLYN>(dev, amount);
        supra_account::deposit_coins(alice_addr, coins);

        // Freeze legacy coin store
        dxlyn_coin::freeze_token(dev, alice_addr);

        assert!(coin::is_coin_store_frozen<DXLYN>(alice_addr), 0x1);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_freeze_token_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        dxlyn_coin::freeze_token(alice, address_of(alice));
    }

    // Test unfreeze_token
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_unfreeze_token(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);

        dxlyn_coin::freeze_token(dev, alice_addr);
        dxlyn_coin::unfreeze_token(dev, alice_addr);

        assert!(!primary_fungible_store::is_frozen(alice_addr, get_dxlyn_asset_metadata()), 0x1);
    }

    // Test freeze_token from legacy coin store
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_unfreeze_token_from_legacycoin_store(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let dev_addr = address_of(dev);
        let alice_addr = address_of(alice);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, dev_addr, amount);

        let coins = coin::withdraw<DXLYN>(dev, amount);
        supra_account::deposit_coins(alice_addr, coins);

        // Freeze legacy coin store
        dxlyn_coin::freeze_token(dev, alice_addr);
        assert!(coin::is_coin_store_frozen<DXLYN>(alice_addr), 0x1);

        // Unfreeze legacy coin store
        dxlyn_coin::unfreeze_token(dev, alice_addr);
        assert!(!coin::is_coin_store_frozen<DXLYN>(alice_addr), 0x2);
    }

    #[test(dev = @dexlyn_coin, alice = @0x123)]
    #[expected_failure(abort_code = dxlyn_coin::ERROR_NOT_OWNER, location = dxlyn_coin)]
    fun test_unfreeze_token_non_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        let alice_addr = address_of(alice);

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);

        dxlyn_coin::freeze_token(dev, address_of(alice));
        dxlyn_coin::unfreeze_token(alice, address_of(alice));
    }

    // Test freeze and transfer interaction
    #[test(dev = @dexlyn_coin, alice = @0x123, bob = @0x124)]
    #[expected_failure(abort_code = 327683, location = fungible_asset)]
    fun test_transfer_frozen_account(dev: &signer, alice: &signer, bob: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        account::create_account_for_test(address_of(bob));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        dxlyn_coin::freeze_token(dev, alice_addr);
        dxlyn_coin::transfer(alice, address_of(bob), amount / 2);
    }

    // Test zero amount mint
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_mint_zero_amount(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        dxlyn_coin::mint(dev, address_of(alice), 0);
        let balance = dxlyn_coin::balance_of(address_of(alice));
        let total_supply = dxlyn_coin::total_supply();
        assert!(balance == 0, 0x1);
        assert!(total_supply == (INITIAL_SUPPLY as u128), 0x2);
    }

    // Test burn_from with zero amount
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_burn_from_zero_amount(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        dxlyn_coin::mint(dev, address_of(alice), 1000 * DXLYN_DECIMAL);
        let balance_before = dxlyn_coin::balance_of(address_of(alice));
        dxlyn_coin::burn_from(dev, address_of(alice), 0);

        let balance_after = dxlyn_coin::balance_of(address_of(alice));
        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(balance_after == balance_before, 0x1);
        assert!(total_supply == balance_before + INITIAL_SUPPLY, 0x2);
    }

    // Test multiple mints to same account
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_multiple_mints(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        dxlyn_coin::mint(dev, alice_addr, amount);

        let balance = dxlyn_coin::balance_of(alice_addr);
        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(balance == 2 * amount, 0x1);
        assert!(total_supply == (2 * amount) + INITIAL_SUPPLY, 0x2);
    }

    // Test burn_from on frozen account
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_burn_from_frozen_account(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        dxlyn_coin::freeze_token(dev, alice_addr);

        let balance_before = dxlyn_coin::balance_of(alice_addr);

        dxlyn_coin::burn_from(dev, alice_addr, amount / 2);

        let balance_after = dxlyn_coin::balance_of(alice_addr);

        assert!(balance_after == balance_before - amount / 2, 0x1);
    }

    // Test coin to fungible asset consistency
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_coin_to_fa_consistency(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, address_of(alice), amount);
        let fa_balance = dxlyn_coin::balance_of(address_of(alice));
        let coin_balance = coin::balance<DXLYN>(address_of(alice));
        assert!(fa_balance == coin_balance, 0x1);
        assert!(fa_balance == amount, 0x2);
    }

    // Test multiple transfers to multiple accounts
    #[test(dev = @dexlyn_coin, alice = @0x123, bob = @0x124, charlie = @0x125)]
    fun test_multiple_transfers(
        dev: &signer,
        alice: &signer,
        bob: &signer,
        charlie: &signer
    ) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        account::create_account_for_test(address_of(bob));
        account::create_account_for_test(address_of(charlie));

        let alice_addr = address_of(alice);
        let bob_addr = address_of(bob);
        let charlie_addr = address_of(charlie);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);
        dxlyn_coin::transfer(alice, bob_addr, amount / 4);
        dxlyn_coin::transfer(alice, charlie_addr, amount / 4);

        assert!(dxlyn_coin::balance_of(alice_addr) == amount / 2, 0x1);
        assert!(dxlyn_coin::balance_of(bob_addr) == amount / 4, 0x2);
        assert!(dxlyn_coin::balance_of(charlie_addr) == amount / 4, 0x3);
        assert!((dxlyn_coin::total_supply() as u64) == amount + INITIAL_SUPPLY, 0x4);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       VIEW FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // Test view functions
    #[test(dev = @dexlyn_coin, alice = @0x123)]
    fun test_view_functions(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));

        let alice_addr = address_of(alice);
        let amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::mint(dev, alice_addr, amount);

        let object_addr = dxlyn_coin::get_dxlyn_object_address();
        assert!(object_addr == object::create_object_address(&SC_ADMIN, b"DXLYN"), 0x1);

        let metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        assert!(fungible_asset::name(metadata) == string::utf8(b"DXLYN"), 0x2);
        assert!(fungible_asset::symbol(metadata) == string::utf8(b"DXLYN"), 0x3);
        assert!(fungible_asset::decimals(metadata) == 8, 0x4);

        let balance = dxlyn_coin::balance_of(alice_addr);
        assert!(balance == amount, 0x5);

        let total_supply = (dxlyn_coin::total_supply() as u64);
        assert!(total_supply == amount + INITIAL_SUPPLY, 0x6);
    }

    #[test(dev = @dexlyn_coin)]
    fun test_get_dxlyn_asset_address(dev: &signer) {
        setup_test_with_genesis(dev);

        let asset_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let asset_address = dxlyn_coin::get_dxlyn_asset_address();

        assert!(object_address(&asset_metadata) == asset_address, 0x1);
    }

    #[test]
    #[expected_failure(abort_code = 262145, location = std::option)]
    fun test_get_dxlyn_asset_address_w() {
        dxlyn_coin::get_dxlyn_asset_address();
    }
}