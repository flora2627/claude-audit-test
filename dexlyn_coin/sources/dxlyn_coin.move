module dexlyn_coin::dxlyn_coin {
    use std::option;
    use std::signer::address_of;
    use std::string;

    use supra_framework::coin::{Self, BurnCapability, FreezeCapability, MintCapability};
    use supra_framework::event;
    use supra_framework::fungible_asset::{Self, Metadata};
    use supra_framework::object::{Self, ExtendRef, Object};
    use supra_framework::primary_fungible_store;
    use supra_framework::supra_account;

    #[test_only]
    use supra_framework::account::create_signer_for_test;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator address of the DXLYN object account
    const SC_ADMIN: address = @dexlyn_coin;

    /// The seed used to create the DXLYN object account
    const DXLYN_OBJECT_ACCOUNT_SEED: vector<u8> = b"DXLYN";

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Caller is not the owner of the dxlyn system
    const ERROR_NOT_OWNER: u64 = 101;

    /// User has insufficient DXLYN balance
    const ERROR_INSUFFICIENT_BALANCE: u64 = 102;

    /// Apply transfer ownership without setting future owner
    const ERROR_FUTURE_OWNER_NOT_SET: u64 = 103;

    /// Apply transfer minter without setting future minter
    const ERROR_FUTURE_MINTER_NOT_SET: u64 = 104;

    /// Try to pause the contract when it is already paused
    const ERROR_ALREADY_PAUSED: u64 = 105;

    /// Try to unpause the contract when it is not paused
    const ERROR_NOT_PAUSED: u64 = 106;

    /// Try to mint when the contract is paused
    const ERROR_PAUSED: u64 = 107;

    /// DXLYN Initial supply
    const INITIAL_SUPPLY: u64 = 10000000000000000; // 100 Million with 10^8 decimal

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Represents the commitment to transfer ownership of the DXLYN contract
    struct CommitOwnershipEvent has drop, store {
        owner: address,
        future_owner: address
    }

    #[event]
    /// Represents the application of ownership transfer in the DXLYN contract
    struct ApplyOwnershipEvent has drop, store {
        owner: address,
        new_owner: address
    }

    #[event]
    /// Represents the commitment to transfer minter of the DXLYN contract
    struct CommitMinterEvent has drop, store {
        owner: address,
        future_minter: address
    }

    #[event]
    /// Represents the application of minter transfer in the DXLYN contract
    struct ApplyMinterEvent has drop, store {
        minter: address,
        new_minter: address
    }

    #[event]
    /// Pauses the DXLYN contract
    struct PauseEvent has drop, store {}

    #[event]
    /// Unpauses the DXLYN contract
    struct UnPauseEvent has drop, store {}

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// DxlynInfo holds the information about the dxlyn token
    struct DxlynInfo has key {
        extend_ref: ExtendRef,
        owner: address,
        future_owner: address,
        minter: address,
        future_minter: address,
        paused: bool
    }

    /// DXLYN legacy coin
    struct DXLYN {}

    /// Store legacy coin capabilities
    struct CoinCaps has key {
        mint_cap: MintCapability<DXLYN>,
        burn_cap: BurnCapability<DXLYN>,
        freeze_cap: FreezeCapability<DXLYN>,
    }

    /// Token Generation Event
    struct InitialSupply has key {
        /// Ecosystem Grant 10%
        ecosystem_grant: coin::Coin<DXLYN>,
        /// Protocol Airdrop 20%
        protocol_airdrop: coin::Coin<DXLYN>,
        /// Private Round 2.5%
        private_round: coin::Coin<DXLYN>,
        /// Genesis Liquidity 2.5%
        genesis_liquidity: coin::Coin<DXLYN>,
        /// Team 15%
        team: coin::Coin<DXLYN>,
        /// Foundation 20%
        foundation: coin::Coin<DXLYN>,
        /// Community Airdrop 30%
        community_airdrop: coin::Coin<DXLYN>,
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initialize module - as initialize dxlyn token
    fun init_module(token_admin: &signer) {
        let constructor_ref = &object::create_named_object(token_admin, DXLYN_OBJECT_ACCOUNT_SEED);

        let dxlyn_obj_signer = object::generate_signer(constructor_ref);

        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<DXLYN>(
            token_admin,
            string::utf8(b"DXLYN"),
            string::utf8(b"DXLYN"),
            8,
            true
        );

        // Migrate the coin store
        coin::migrate_to_fungible_store<DXLYN>(&dxlyn_obj_signer);

        // Mint [INITIAL_SUPPLY]
        let initial_supply = coin::mint<DXLYN>(INITIAL_SUPPLY, &mint_cap);

        let ecosystem_grant = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 10 / 100); // 10%
        let protocol_airdrop = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 20 / 100); // 20%
        let private_round = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 250 / 10000); // 2.5%
        let genesis_liquidity = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 250 / 10000); // 2.5%
        let team = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 15 / 100); // 15%
        let foundation = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 20 / 100); // 20%
        let community_airdrop = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 30 / 100); // 30%

        // The CoinStore cannot be dropped directly; it must be deposited into the Dexlyn object.
        coin::deposit(address_of(&dxlyn_obj_signer), initial_supply);
        move_to(&dxlyn_obj_signer, InitialSupply {
            ecosystem_grant, protocol_airdrop, private_round, genesis_liquidity, team, foundation, community_airdrop
        });

        move_to(&dxlyn_obj_signer, CoinCaps { burn_cap, freeze_cap, mint_cap });
        move_to(
            &dxlyn_obj_signer,
            DxlynInfo {
                extend_ref: object::generate_extend_ref(constructor_ref),
                owner: @dexlyn_coin_owner,
                future_owner: @0x0,
                minter: @dexlyn_coin_minter,
                future_minter: @0x0,
                paused: false
            }
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Commit transfer ownership of dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    /// * `future_owner`: The address of the future owner to whom ownership will be transferred.
    ///
    /// # Dev
    /// * This function can only be called by the current owner of the dxlyn token.
    public entry fun commit_transfer_ownership(
        owner: &signer, future_owner: address
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        let owner = address_of(owner);
        assert!(owner == dxlyn_info.owner, ERROR_NOT_OWNER);

        dxlyn_info.future_owner = future_owner;

        event::emit(CommitOwnershipEvent { owner, future_owner })
    }

    /// Apply transfer ownership of dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    ///
    /// # Dev
    /// * This function can only be called after `commit_transfer_ownership` has been called
    public entry fun apply_transfer_ownership(
        owner: &signer
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        let owner = address_of(owner);
        assert!(owner == dxlyn_info.owner, ERROR_NOT_OWNER);
        assert!(dxlyn_info.future_owner != @0x0, ERROR_FUTURE_OWNER_NOT_SET);

        dxlyn_info.owner = dxlyn_info.future_owner;

        event::emit(ApplyOwnershipEvent { owner, new_owner: dxlyn_info.owner })
    }

    /// Commit transfer minter of dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    /// * `future_minter`: The address of the future minter to whom minting rights will be transferred.
    ///
    /// # Dev
    /// * This function can only be called by the current owner of the dxlyn token.
    public entry fun commit_transfer_minter(
        owner: &signer, future_minter: address
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        let owner = address_of(owner);
        assert!(owner == dxlyn_info.owner, ERROR_NOT_OWNER);

        dxlyn_info.future_minter = future_minter;

        event::emit(CommitMinterEvent { owner, future_minter });
    }

    /// Apply transfer minter of dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    ///
    /// # Dev
    /// * This function can only be called after `commit_transfer_minter` has been called
    public entry fun apply_transfer_minter(
        owner: &signer
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);
        assert!(dxlyn_info.future_minter != @0x0, ERROR_FUTURE_MINTER_NOT_SET);

        event::emit(ApplyMinterEvent { minter: dxlyn_info.minter, new_minter: dxlyn_info.future_minter });

        dxlyn_info.minter = dxlyn_info.future_minter;
    }

    /// Pause dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    ///
    /// # Dev
    /// * This function can only be called by the current owner of the dxlyn token.
    public entry fun pause(
        owner: &signer
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        assert!(!dxlyn_info.paused, ERROR_ALREADY_PAUSED);
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);

        dxlyn_info.paused = true;

        event::emit(PauseEvent {});
    }

    /// Unpause dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner of the dxlyn token.
    ///
    /// # Dev
    /// * This function can only be called by the current owner of the dxlyn token.
    public entry fun unpause(
        owner: &signer
    ) acquires DxlynInfo {
        let dxlyn_info = borrow_global_mut<DxlynInfo>(get_dxlyn_object_address());
        assert!(dxlyn_info.paused, ERROR_NOT_PAUSED);
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);

        dxlyn_info.paused = false;

        event::emit(UnPauseEvent {});
    }

    /// Mint dxlyn token
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner or minter of the dxlyn token.
    /// * `to`: The address to which the minted tokens will be sent.
    /// * `amount`: The amount of dxlyn tokens to mint.
    public entry fun mint(
        owner: &signer, to: address, amount: u64
    ) acquires CoinCaps, DxlynInfo {
        let object_add = get_dxlyn_object_address();

        let dxlyn_info = borrow_global<DxlynInfo>(object_add);

        assert!(!dxlyn_info.paused, ERROR_PAUSED);

        let owner_address = address_of(owner);
        assert!(owner_address == dxlyn_info.owner || owner_address == dxlyn_info.minter, ERROR_NOT_OWNER);

        let mint_cap = &borrow_global<CoinCaps>(object_add).mint_cap;
        let (mint_ref, mint_ref_receipt) = coin::get_paired_mint_ref(mint_cap);

        // mint dxlyn token
        primary_fungible_store::deposit(to, fungible_asset::mint(&mint_ref, amount));

        coin::return_paired_mint_ref(mint_ref, mint_ref_receipt);
    }

    /// Mint dxlyn token for community
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, representing the current owner or minter of the dxlyn token.
    /// * `to`: The address to which the minted tokens will be sent.
    /// * `amount`: The amount of dxlyn tokens to mint.
    public entry fun mint_to_community(
        owner: &signer, to: address, amount: u64
    ) acquires InitialSupply, DxlynInfo {
        let object_add = get_dxlyn_object_address();

        let dxlyn_info = borrow_global<DxlynInfo>(object_add);

        assert!(!dxlyn_info.paused, ERROR_PAUSED);

        let owner_address = address_of(owner);
        assert!(owner_address == dxlyn_info.owner || owner_address == dxlyn_info.minter, ERROR_NOT_OWNER);

        let initial_supply = borrow_global_mut<InitialSupply>(object_add);

        let transfer_coin = coin::extract(&mut initial_supply.community_airdrop, amount);
        let fa_coin = coin::coin_to_fungible_asset(transfer_coin);

        primary_fungible_store::deposit(to, fa_coin);
    }

    /// Transfer dxlyn token
    ///
    /// # Arguments
    /// * `account`: The signer of the transaction, representing the account from which the tokens will be transferred.
    /// * `to`: The address to which the tokens will be transferred.
    /// * `amount`: The amount of dxlyn tokens to transfer.
    public entry fun transfer(account: &signer, to: address, amount: u64) {
        assert!(balance_of(address_of(account)) >= amount, ERROR_INSUFFICIENT_BALANCE);
        supra_account::transfer_coins<DXLYN>(account, to, amount);
    }

    /// Burn dxlyn token from
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, the owner of the system.
    /// * `from`: The address from which the tokens will be burned.
    /// * `amount`: The amount of dxlyn tokens to burn.
    public entry fun burn_from(owner: &signer, from: address, amount: u64) acquires DxlynInfo, CoinCaps {
        let object_add = get_dxlyn_object_address();

        let dxlyn_info = borrow_global<DxlynInfo>(object_add);
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);

        let burn_cap = &borrow_global<CoinCaps>(object_add).burn_cap;
        // burn dxlyn token
        coin::burn_from<DXLYN>(from, amount, burn_cap);
    }

    /// Freeze dxlyn token to user account
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, the owner of the system.
    /// * `user`: The address to which the tokens will be freezed.
    public entry fun freeze_token(owner: &signer, user: address) acquires DxlynInfo, CoinCaps {
        let object_add = get_dxlyn_object_address();

        let dxlyn_info = borrow_global<DxlynInfo>(object_add);
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);

        let freeze_cap = &borrow_global<CoinCaps>(object_add).freeze_cap;

        if (coin::is_account_registered<DXLYN>(user)) {
            coin::freeze_coin_store<DXLYN>(user, freeze_cap);
        }else {
            let (transfer_ref, transfer_ref_receipt) = coin::get_paired_transfer_ref(freeze_cap);

            primary_fungible_store::set_frozen_flag(&transfer_ref, user, true);

            coin::return_paired_transfer_ref(transfer_ref, transfer_ref_receipt);
        }
    }

    /// Unfreeze dxlyn token from user account
    ///
    /// # Arguments
    /// * `owner`: The signer of the transaction, the owner of the system.
    /// * `user`: The address to which the tokens will be transferred.
    public entry fun unfreeze_token(owner: &signer, user: address) acquires DxlynInfo, CoinCaps {
        let object_add = get_dxlyn_object_address();

        let dxlyn_info = borrow_global<DxlynInfo>(object_add);
        assert!(address_of(owner) == dxlyn_info.owner, ERROR_NOT_OWNER);

        let freeze_cap = &borrow_global<CoinCaps>(object_add).freeze_cap;

        if (coin::is_account_registered<DXLYN>(user)) {
            coin::unfreeze_coin_store<DXLYN>(user, freeze_cap);
        }else {
            let (transfer_ref, transfer_ref_receipt) = coin::get_paired_transfer_ref(freeze_cap);

            primary_fungible_store::set_frozen_flag(&transfer_ref, user, false);

            coin::return_paired_transfer_ref(transfer_ref, transfer_ref_receipt);
        }
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get the dxlyn coin balance of a user
    ///
    /// # Arguments
    /// * `user_addr`: The address of the user whose dxlyn balance is to be retrieved.
    ///
    /// # Returns
    /// * The balance of dxlyn tokens held by the user.
    public fun balance_of(user_addr: address): u64 {
        coin::balance<DXLYN>(user_addr)
    }

    #[view]
    /// Get the dxlyn coin supply
    ///
    /// # Returns
    /// * The total supply of dxlyn tokens.
    public fun total_supply(): u128 {
        *option::borrow(&coin::supply<DXLYN>())
    }

    #[view]
    /// Get dxlyn asset metadata
    ///
    /// # Returns
    /// * The metadata of the dxlyn asset.
    public fun get_dxlyn_asset_metadata(): Object<Metadata> {
        *option::borrow(&coin::paired_metadata<DXLYN>())
    }

    #[view]
    /// Get dxlyn asset address
    ///
    /// # Returns
    /// * The address of the dxlyn asset.
    public fun get_dxlyn_asset_address(): address {
        object::object_address(option::borrow(&coin::paired_metadata<DXLYN>()))
    }

    #[view]
    /// Get dxlyn object address
    ///
    /// # Returns
    /// * The address of the dxlyn object.
    public fun get_dxlyn_object_address(): address {
        object::create_object_address(&SC_ADMIN, DXLYN_OBJECT_ACCOUNT_SEED)
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    public fun init_coin(signer: &signer) {
        let supra_signer = create_signer_for_test(@0x1);
        coin::create_coin_conversion_map(&supra_signer);
        init_module(signer);
    }


    #[test_only]
    public fun register_and_mint(
        account: &signer, to: address, amount: u64
    ) acquires CoinCaps, DxlynInfo {
        mint(account, to, amount)
    }

    #[test_only]
    public fun get_dxlyn_info(): (address, address, address, address, bool) acquires DxlynInfo {
        let object_addr = get_dxlyn_object_address();
        let dxlyn_info = borrow_global<DxlynInfo>(object_addr);
        (dxlyn_info.owner, dxlyn_info.minter, dxlyn_info.future_owner, dxlyn_info.future_minter, dxlyn_info.paused)
    }
}