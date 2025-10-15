module dexlyn_tokenomics::voting_escrow {

    use std::option;
    use std::signer::address_of;
    use std::string::{Self, String};
    use std::vector;
    use aptos_std::string_utils;
    use aptos_std::table::{Self, Table};

    use aptos_token_objects::collection::{Self, Collection, MutatorRef};
    use aptos_token_objects::token::{Self, BurnRef, Token};
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::block;
    use supra_framework::event;
    use supra_framework::object::{Self, ExtendRef, TransferRef};
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::base64;
    use dexlyn_tokenomics::i64::{Self, max, subtract_or_zero};

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator address for the VotingEscrow contract object account.
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// Seeds for creating unique object addresses for the voting escrow
    const VOTING_ESCROW_SEED: vector<u8> = b"VOTING_ESCROW";

    /// Represents merging two locks into one
    const MERGE_TYPE: u8 = 1;

    /// Represents splitting a lock into two or more separate locks
    const SPLIT_TYPE: u8 = 2;

    /// One week in seconds (7 days), used to round lock times
    const WEEK: u64 = 604800;

    /// Maximum lock duration of 4 years in seconds
    const MAXTIME: u64 = 126144000;

    /// Scaling factor (10^12) for precision in calculations
    const MULTIPLIER: u64 = 1000000000000;

    /// Scaling factor (10^4) for scale amount
    const AMOUNT_SCALE: u64 = 10000;

    /// For iterations of epochs
    const ONE_TWENTY_EIGHT_EPOCHS: u64 = 128;

    /// For iterations of weeks
    const TWO_FIFTY_FIVE_WEEKS: u64 = 255;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                NFT DETAILS CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    const COLLECTION_NAME: vector<u8> = b"DEXLYN_COLLECTION";
    const COLLECTION_DESCRIPTION: vector<u8> = b"Dexlyn NFT collection for voting escrow contract";
    const COLLECTION_URL: vector<u8> = b"https://dexlyn.com/_next/image?url=%2Fimages%2Fdexlyn-tokenomics.webp&w=1920&q=75";


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Value must be greater than zero for the operation
    const ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO: u64 = 101;

    /// Unlock time must be in the future
    const ERROR_INVALID_UNLOCK_TIME: u64 = 102;

    /// Unlock time must be no more than 4 years
    const ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS: u64 = 103;

    /// User must have sufficient DXLYN tokens for the operation
    const ERROR_INSUFFICIENT_DXLYN_COIN: u64 = 104;

    /// Caller must be the admin to perform the operation
    const ERROR_NOT_ADMIN: u64 = 105;

    /// Future admin must be set to apply ownership transfer
    const ERROR_ADMIN_NOT_SET: u64 = 106;

    /// No existing lock found for the NFT token
    const ERROR_NO_EXISTING_LOCK_FOUND: u64 = 107;

    /// Lock has expired for the NFT token
    const ERROR_LOCK_IS_EXPIRED: u64 = 108;

    /// Unlock time can only be increased, not decreased (must be greater than current lock end)
    const ERROR_CAN_ONLY_INCREASE_LOCK_DURATION: u64 = 109;

    /// Lock must be expired before withdrawal
    const ERROR_LOCK_NOT_EXPIRED: u64 = 110;

    /// Block number exceeds the current block height
    const ERROR_BLOCK_NUMBER_EXCEEDED: u64 = 111;

    /// Address cannot be the zero address
    const ERROR_ZERO_ADDRESS: u64 = 112;

    /// Caller must be a voter to perform the operation
    const ERROR_NOT_VOTER: u64 = 113;

    /// Remove vote for the NFT token from the gauge before performing this action
    const ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST: u64 = 114;

    /// Caller must be the owner of the NFT token
    const ERROR_NOT_NFT_OWNER: u64 = 115;

    /// Remove vote for the from_token from the gauge before merging
    const ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN: u64 = 116;

    /// Token addresses must be different for merging
    const ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME: u64 = 117;

    /// Either from_token or to_token does not exist (token not issued by the contract)
    const ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST: u64 = 118;

    /// Invalid weight value in the split weights vector (must be greater than zero)
    const ERROR_INVALID_WEIGHT: u64 = 119;


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Represents the commitment to transfer ownership of the VotingEscrow contract
    struct CommitOwnershipEvent has drop, store {
        admin: address
    }

    #[event]
    /// Represents the application of ownership transfer in the VotingEscrow contract
    struct ApplyOwnershipEvent has drop, store {
        admin: address
    }

    #[event]
    /// Represents a create lock action in the VotingEscrow contract
    struct CreateLockEvent has drop, store {
        provider: address,
        to: address,
        token: address,
        value: u64,
        locktime: u64,
        ts: u64,
        nft_name: String
    }

    #[event]
    /// Represents a increase lock amount action in the VotingEscrow contract
    struct IncreaseAmountEvent has drop, store {
        provider: address,
        token: address,
        value: u64,
        locktime: u64,
        ts: u64,
        nft_name: String
    }

    #[event]
    /// Represents a increase lock time action in the VotingEscrow contract
    struct ExtendLockupEvent has drop, store {
        provider: address,
        token: address,
        value: u64,
        locktime: u64,
        ts: u64,
        nft_name: String
    }

    #[event]
    /// Represents a merge lock action in the VotingEscrow contract
    struct MergeLockEvent has drop, store {
        provider: address,
        token: address,
        value: u64,
        locktime: u64,
        ts: u64,
        nft_name: String,
        burned_token: address
    }

    #[event]
    /// Represents a split lock action in the VotingEscrow contract
    struct SplitLockEvent has drop, store {
        provider: address,
        token: address,
        value: u64,
        locktime: u64,
        ts: u64,
        nft_name: String,
        burned_token: address
    }

    #[event]
    /// Represents a withdrawal action in the VotingEscrow contract
    struct WithdrawEvent has drop, store {
        provider: address,
        token: address,
        value: u64,
        ts: u64
    }

    #[event]
    /// Represents a supply change in the VotingEscrow contract
    struct SupplyEvent has drop, store {
        prev_supply: u64,
        supply: u64
    }

    #[event]
    /// Represents a change in the voter address in the VotingEscrow contract
    struct ChangeVoterEvent has drop, store {
        old_voter: address,
        new_voter: address
    }

    #[event]
    /// Represents burn action in the VotingEscrow contract
    struct BurnNFTEvent has drop, store {
        token: address,
        ts: u64
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Use to store voting power and decay rate at a specific point in time
    /// For track users and global voting power
    struct Point has store, drop, copy {
        // Scaled voting power
        bias: u64,
        // Scaled decay rate
        slope: u64,
        // Timestamp (seconds)
        ts: u64,
        // block number
        blk: u64
    }

    /// User locked balance and lock end time
    struct LockedBalance has store, drop, copy {
        amount: u64,
        end: u64
    }

    /// Represents a change in slope at a specific timestamp, used for tracking voting power decay
    struct SlopeChange has store, drop, copy {
        // Scaled absolute slope value
        slope: u64,
        // True for subtract (negative), false for add (positive)
        is_negative: bool
    }

    /// Store voting escrow state and user data
    struct VotingEscrow has key {
        // token -> locked balance
        locked: Table<address, LockedBalance>,
        // epoch -> point
        point_history: Table<u64, Point>,
        // token -> epoch -> Point
        user_point_history: Table<address, Table<u64, Point>>,
        // token -> epoch
        user_point_epoch: Table<address, u64>,
        // timestamp -> slope change with direction
        slope_changes: Table<u64, SlopeChange>,
        epoch: u64,
        supply: u64,
        admin: address,
        future_admin: address,
        extended_ref: ExtendRef,
        voter: address,
        //mapping for track user voted on not on any gauge
        voted: Table<address, bool>,
        // NFT collection extend reference
        collection_extend_ref: ExtendRef,
        // Mutator reference for the NFT collection
        mutator_ref: MutatorRef,
        token_id: u64
    }

    /// Represents a reference to a token, used for burning and transferring tokens
    struct TokenRef has key {
        burn_ref: BurnRef,
        transfer_ref: TransferRef,
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                           CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initializes the VotingEscrow contract
    ///
    /// # Arguments
    /// * `sender` - The signer creating the VotingEscrow contract
    fun init_module(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, VOTING_ESCROW_SEED);

        let initial_point_history = table::new<u64, Point>();
        table::add(
            &mut initial_point_history,
            0,
            Point {
                bias: 0,
                slope: 0,
                ts: timestamp::now_seconds(),
                blk: block::get_current_block_height()
            }
        );

        let ve_signer = object::generate_signer(&constructor_ref);
        // Created NFT collection for the VotingEscrow contract
        let collection_constructor_ref = collection::create_unlimited_collection(&ve_signer,
            string::utf8(COLLECTION_DESCRIPTION),
            string::utf8(COLLECTION_NAME),
            option::none(),
            string::utf8(COLLECTION_URL)
        );

        move_to<VotingEscrow>(
            &ve_signer,
            VotingEscrow {
                locked: table::new<address, LockedBalance>(),
                point_history: initial_point_history,
                user_point_history: table::new<address, Table<u64, Point>>(),
                user_point_epoch: table::new<address, u64>(),
                slope_changes: table::new<u64, SlopeChange>(),
                epoch: 0,
                supply: 0,
                admin: @voting_escrow_admin,
                future_admin: @0x0,
                extended_ref: object::generate_extend_ref(&constructor_ref),
                voter: @voting_escrow_voter,
                voted: table::new<address, bool>(),
                collection_extend_ref: object::generate_extend_ref(&collection_constructor_ref),
                mutator_ref: collection::generate_mutator_ref(&collection_constructor_ref),
                token_id: 0
            }
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Set a new voter address for the VotingEscrow contract.
    ///
    /// # Arguments
    /// * `admin` - The signer.
    /// * `new_voter` - The new voter address to set.
    public entry fun set_voter(admin: &signer, new_voter: address) acquires VotingEscrow {
        assert!(new_voter != @0x0, ERROR_ZERO_ADDRESS);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        assert!(address_of(admin) == voting_escrow.admin, ERROR_NOT_ADMIN);

        event::emit(ChangeVoterEvent { old_voter: voting_escrow.voter, new_voter });

        voting_escrow.voter = new_voter;
    }

    /// Transfers ownership of the VotingEscrow contract to `new_admin`.
    ///
    /// # Arguments
    /// * `admin` - The current admin signer.
    /// * `new_admin` - The address to transfer ownership to.
    public entry fun commit_transfer_ownership(admin: &signer, new_admin: address) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        assert!(address_of(admin) == voting_escrow.admin, ERROR_NOT_ADMIN);
        voting_escrow.future_admin = new_admin;

        event::emit(CommitOwnershipEvent { admin: new_admin });
    }

    /// Transfers the ownership of the VotingEscrow to the future admin if the caller is the current admin.
    ///
    /// # Arguments
    /// * `admin` - The signer.
    public entry fun apply_transfer_ownership(admin: &signer) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        assert!(address_of(admin) == voting_escrow.admin, ERROR_NOT_ADMIN);
        assert!(voting_escrow.future_admin != @0x0, ERROR_ADMIN_NOT_SET);
        voting_escrow.admin = voting_escrow.future_admin;

        event::emit(ApplyOwnershipEvent { admin: voting_escrow.future_admin });
    }

    /// Record global data to checkpoint
    public entry fun checkpoint() acquires VotingEscrow {
        //notice Record global data to checkpoint
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        let empty_lock = LockedBalance { amount: 0, end: 0 };
        check_point_internal(voting_escrow, @0x0, &empty_lock, &empty_lock);
    }

    /// Deposit `value` tokens for `user` and lock until `unlock_time`.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `value` - Amount to deposit.
    /// * `unlock_time` - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).
    public entry fun create_lock(
        user: &signer, value: u64, unlock_time: u64
    ) acquires VotingEscrow {
        create_lock_internal(user, value, unlock_time, address_of(user));
    }

    /// Deposit `value` tokens for `to` and lock until `unlock_time`.
    ///
    /// # Arguments
    /// * `caller` - The signer.
    /// * `value` - Amount to deposit.
    /// * `unlock_time` - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).
    /// * `to` - Address of the user to receive the NFT token.
    public entry fun create_lock_for(
        caller: &signer, value: u64, unlock_time: u64, to: address
    ) acquires VotingEscrow {
        create_lock_internal(caller, value, unlock_time, to);
    }

    /// Deposit `value` additional tokens for `NFT token` without modifying the unlock time.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `token` - Address of the NFT token.
    /// * `value` - Amount of tokens to deposit and add to the lock.
    public entry fun increase_amount(user: &signer, token: address, value: u64) acquires VotingEscrow {
        assert!(value > 0, ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO);

        let user_address = address_of(user);

        // Check if the user is the owner of the token
        assert_if_not_owner(user_address, token);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        let locked =
            *table::borrow_with_default(
                &voting_escrow.locked,
                token,
                &LockedBalance { amount: 0, end: 0 }
            );

        assert!(locked.amount > 0, ERROR_NO_EXISTING_LOCK_FOUND);
        let current_time = timestamp::now_seconds();
        assert!(locked.end > current_time, ERROR_LOCK_IS_EXPIRED);

        let lock_end = deposit_for_internal(voting_escrow, user, token, value, 0, 0);

        event::emit(IncreaseAmountEvent {
            provider: user_address,
            token,
            value,
            locktime: lock_end,
            ts: current_time,
            nft_name: token::name(object::address_to_object<Token>(token))
        });
    }

    /// Extends the unlock time for the NFT token to the specified `unlock_time`.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `token` - Address of the NFT token.
    /// * `unlock_time` - New epoch time for unlocking (current time + lock period)
    public entry fun increase_unlock_time(user: &signer, token: address, unlock_time: u64) acquires VotingEscrow {
        let unlock_time_internal = (unlock_time / WEEK) * WEEK; //Unlock time is rounded down to weeks

        let current_time = timestamp::now_seconds();
        assert!(unlock_time_internal <= current_time + MAXTIME, ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS);

        let user_address = address_of(user);

        // Check if the user is the owner of the token
        assert_if_not_owner(user_address, token);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);
        let locked =
            *table::borrow_with_default(
                &voting_escrow.locked,
                token,
                &LockedBalance { amount: 0, end: 0 }
            );

        assert!(locked.amount > 0, ERROR_NO_EXISTING_LOCK_FOUND);
        assert!(locked.end > current_time, ERROR_LOCK_IS_EXPIRED);
        assert!(unlock_time_internal > locked.end, ERROR_CAN_ONLY_INCREASE_LOCK_DURATION);

        let lock_end = deposit_for_internal(
            voting_escrow,
            user,
            token,
            0,
            unlock_time_internal,
            0
        );

        event::emit(ExtendLockupEvent {
            provider: user_address,
            token,
            value: 0,
            locktime: lock_end,
            ts: current_time,
            nft_name: token::name(object::address_to_object<Token>(token))
        });
    }

    /// Merge `from_token` into `to_token` for the user.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `from_token` - Address of the NFT token to merge from.
    /// * `to_token` - Address of the NFT token to merge into.
    ///
    /// # Dev
    /// Before merging the dxlyn token user must remove the vote from the gauge.
    public entry fun merge(user: &signer, from_token: address, to_token: address) acquires VotingEscrow, TokenRef {
        assert!(from_token != to_token, ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME);

        let user_address = address_of(user);

        // Check if the user is the owner of both tokens
        assert_if_not_owner(user_address, from_token);
        assert_if_not_owner(user_address, to_token);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        // Check is token voted or not before merge the position
        assert!(
            !*table::borrow_with_default(&voting_escrow.voted, from_token, &false),
            ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN
        );

        assert!(
            table::contains(&voting_escrow.locked, from_token) && table::contains(&voting_escrow.locked, to_token),
            ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST
        );

        let locked0 = *table::borrow_mut(&mut voting_escrow.locked, from_token);

        let locked1 = *table::borrow_mut(&mut voting_escrow.locked, to_token);

        let value0 = locked0.amount;
        // Find the maximum end time of the two tokens
        let end = max(locked0.end, locked1.end);

        // Make from_token locked balance zero
        table::upsert(&mut voting_escrow.locked, from_token, LockedBalance { amount: 0, end: 0 });

        // Perform checkpoint for from_token
        check_point_internal(voting_escrow, from_token, &locked0, &LockedBalance { amount: 0, end: 0 });

        // Reduce the supply so when it's add supply remains the same
        voting_escrow.supply = voting_escrow.supply - value0;

        // Burn the from_token NFT
        burn_nft(from_token);

        // Deposit the merged amount into to_token
        let lock_end = deposit_for_internal(voting_escrow, user, to_token, value0, end, MERGE_TYPE);

        event::emit(MergeLockEvent {
            provider: user_address,
            token: to_token,
            value: value0,
            locktime: lock_end,
            ts: timestamp::now_seconds(),
            nft_name: token::name(object::address_to_object<Token>(to_token)),
            burned_token: from_token
        });
    }

    /// Split the locked amount of `token` into multiple parts.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `amount` - Vector of amounts % to split the locked balance into.
    /// * `token` - Address of the NFT token to split.
    public entry fun split(user: &signer, split_weights: vector<u64>, token: address) acquires VotingEscrow, TokenRef {
        let user_address = address_of(user);

        // Check if the user is the owner of the token
        assert_if_not_owner(user_address, token);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        // Check is token voted or not before split the position
        assert!(!*table::borrow_with_default(&voting_escrow.voted, token, &false), ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST);

        let default_locked = LockedBalance { amount: 0, end: 0 };

        let locked = *table::borrow_mut_with_default(&mut voting_escrow.locked, token, default_locked);

        let end = locked.end;
        let value = locked.amount;

        assert!(value > 0, ERROR_NO_EXISTING_LOCK_FOUND);

        let current_time = timestamp::now_seconds();

        assert!(end > current_time, ERROR_INVALID_UNLOCK_TIME);
        assert!(end <= current_time + MAXTIME, ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS);

        // reset supply, deposit_for_internal increase it
        voting_escrow.supply = voting_escrow.supply - value;

        let total_weight = 0;

        vector::for_each(split_weights, |weight| {
            assert!(weight > 0, ERROR_INVALID_WEIGHT);
            total_weight = total_weight + weight;
        });

        // remove old data
        table::upsert(&mut voting_escrow.locked, token, default_locked);

        // Perform checkpoint for token
        check_point_internal(voting_escrow, token, &locked, &default_locked);

        // Burn the NFT token
        burn_nft(token);

        // added _ because of compiler warning
        let _value_internal = 0;

        vector::for_each(split_weights, |weight| {
            _value_internal = value * weight / total_weight;

            let (minted_token_address, token_name) = mint_nft(voting_escrow, user_address, end, _value_internal);

            // Deposit the split amount into the new NFT token
            let lock_end = deposit_for_internal(
                voting_escrow,
                user,
                minted_token_address,
                _value_internal,
                end,
                SPLIT_TYPE
            );

            event::emit(SplitLockEvent {
                provider: user_address,
                token: minted_token_address,
                value: _value_internal,
                locktime: lock_end,
                ts: timestamp::now_seconds(),
                nft_name: token_name,
                burned_token: token
            });
        });
    }

    /// Withdraw all tokens for `NFT token`
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `token` - Address of the NFT token.
    ///
    /// # Dev
    /// Before withdrawing the dxlyn token user must remove the vote from the gauge.
    public entry fun withdraw(user: &signer, token: address) acquires VotingEscrow, TokenRef {
        let user_address = address_of(user);

        // Check if the user is the owner of the token
        assert_if_not_owner(user_address, token);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        // Check is token voted or not before withdraw the dxlyn token
        assert!(!*table::borrow_with_default(&voting_escrow.voted, token, &false), ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST);

        let locked =
            *table::borrow_mut_with_default(
                &mut voting_escrow.locked,
                token,
                LockedBalance { amount: 0, end: 0 }
            );
        let current_time = timestamp::now_seconds();
        assert!(current_time >= locked.end, ERROR_LOCK_NOT_EXPIRED);

        let value = locked.amount;
        let old_locked = locked;
        locked.end = 0;
        locked.amount = 0;
        table::upsert(&mut voting_escrow.locked, token, locked);
        let supply_before = voting_escrow.supply;
        voting_escrow.supply = subtract_or_zero(supply_before, value);

        // old_locked can have either expired <= timestamp or zero end
        // Locked has only 0 end
        // Both can have >= 0 amount
        check_point_internal(
            voting_escrow,
            token,
            &old_locked,
            &locked
        );

        // Transfer DXLYN token from voting escrow object account to users account
        primary_fungible_store::transfer(
            // ve_signer
            &object::generate_signer_for_extending(&voting_escrow.extended_ref),
            dxlyn_coin::get_dxlyn_asset_metadata(),
            user_address,
            value
        );

        // Burn the NFT token
        burn_nft(token);

        event::emit(
            WithdrawEvent {
                provider: user_address,
                token,
                value,
                ts: current_time
            }
        );
        event::emit(
            SupplyEvent { prev_supply: supply_before, supply: voting_escrow.supply }
        );
    }

    /// Withdraw all tokens for `token` and create a new lock with `unlock_time`.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `token` - Address of the NFT token.
    /// * `unlock_time` - New epoch time for unlocking (current time + lock period)
    public fun create_relock(user: &signer, token: address, unlock_time: u64) acquires VotingEscrow, TokenRef {
        let value = locked_amount(token);
        withdraw(user, token);
        create_lock_internal(user, value, unlock_time, address_of(user));
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get the address of the VotingEscrow contract
    public fun get_voting_escrow_address(): address {
        object::create_object_address(&SC_ADMIN, VOTING_ESCROW_SEED)
    }

    #[view]
    /// Get the most recently recorded rate of voting power decrease for `token`.
    ///
    /// # Arguments
    /// * `token` - Address of the token.
    ///
    /// # Returns
    /// Value of the slope.
    public fun get_last_user_slope(token: address): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        // Check if the point history and user point epoch is found
        if (table::contains(&voting_escrow.user_point_history, token) && table::contains(
            &voting_escrow.user_point_epoch,
            token
        )) {
            let user_point = table::borrow(&voting_escrow.user_point_history, token);
            let user_epoch = table::borrow(&voting_escrow.user_point_epoch, token);

            // Check if the user point is found
            if (!table::contains(user_point, *user_epoch)) {
                return 0
            };
            table::borrow(user_point, *user_epoch).slope
        } else { 0 }
    }

    #[view]
    /// Get the timestamp for checkpoint `epoch` for `token`.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `epoch` - User epoch number.
    ///
    /// # Returns
    /// Epoch time of the checkpoint.
    public fun user_point_history_ts(token: address, epoch: u64): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        // Check if the point history is found
        if (table::contains(&voting_escrow.user_point_history, token)) {
            let user_point = table::borrow(&voting_escrow.user_point_history, token);
            // Check if the user point is found
            if (!table::contains(user_point, epoch)) {
                return 0
            };
            table::borrow(user_point, epoch).ts
        } else { 0 }
    }

    #[view]
    /// Get the timestamp when the lock for the given `token` finishes.
    ///
    /// # Arguments
    /// * `token` - token address.
    ///
    /// # Returns
    /// Epoch time of the lock end.
    public fun locked_end(token: address): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        if (!table::contains(&voting_escrow.locked, token)) {
            return 0
        };
        table::borrow(&voting_escrow.locked, token).end
    }

    #[view]
    /// Get the locked amount (DXLYN locked).
    ///
    /// # Arguments
    /// * `token` - token address.
    ///
    /// # Returns
    /// Locked dxlyn amount.
    public fun locked_amount(token: address): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        if (!table::contains(&voting_escrow.locked, token)) {
            return 0
        };
        table::borrow(&voting_escrow.locked, token).amount
    }

    #[view]
    /// Binary search to estimate timestamp for a given block number.
    ///
    /// # Parameters
    /// - `block`: Block number to find.
    /// - `max_epoch`: Maximum epoch to search up to.
    ///
    /// # Returns
    /// Approximate epoch for the given block.
    public fun find_block_epoch(block: u64, max_epoch: u64): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let min = 0;
        let max = max_epoch;
        let default_point = &Point { blk: 0, ts: 0, bias: 0, slope: 0 };

        //Binary search
        for (i in 0..ONE_TWENTY_EIGHT_EPOCHS) {
            if (min >= max) { break };
            let mid = (min + max + 1) / 2;
            let blk = table::borrow_with_default(&voting_escrow.point_history, mid, default_point).blk;
            if (blk <= block) {
                min = mid;
            } else {
                max = mid - 1;
            };
        };

        min
    }

    #[view]
    /// Get the current voting power for a NFT token.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `t` - Epoch time to return voting power at.
    ///
    /// # Returns
    /// User voting power in 10^12 units.
    public fun balance_of(token: address, t: u64): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let epoch = *table::borrow_with_default(&voting_escrow.user_point_epoch, token, &0);
        if (epoch == 0) {
            return 0 // No lock, no voting power
        } else {
            // Check is user point history exists
            if (table::contains(&voting_escrow.user_point_history, token)) {
                let user_history = table::borrow(&voting_escrow.user_point_history, token);
                let last_point =
                    *table::borrow_with_default(
                        user_history,
                        epoch,
                        &Point { bias: 0, slope: 0, ts: 0, blk: 0 }
                    );

                // Prevent underflow and ensure non-negative
                // It will return bias
                subtract_or_zero(last_point.bias, last_point.slope * subtract_or_zero(t, last_point.ts))
            } else { 0 }
        }
    }

    #[view]
    /// Measure voting power of `NFT token` at block height `block`.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `block` - Block to calculate the voting power at.
    ///
    /// # Returns
    /// Voting power in 10^12 units.
    public fun balance_of_at(token: address, block: u64): u64 acquires VotingEscrow {
        let current_blk_height = block::get_current_block_height();
        assert!(block <= current_blk_height, ERROR_BLOCK_NUMBER_EXCEEDED);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let min = 0;
        let max = *table::borrow_with_default(&voting_escrow.user_point_epoch, token, &0);
        let default_point = &Point { blk: 0, ts: 0, bias: 0, slope: 0 };
        //Binary search
        for (i in 0..ONE_TWENTY_EIGHT_EPOCHS) {
            if (min >= max) { break };
            let mid = (min + max + 1) / 2;
            let blk = table::borrow_with_default(&voting_escrow.point_history, mid, default_point).blk;
            if (blk <= block) {
                min = mid;
            } else {
                max = mid - 1;
            };
        };

        // Check is user point history exists
        if (table::contains(&voting_escrow.user_point_history, token)) {
            let point_history = table::borrow(&voting_escrow.user_point_history, token);
            let upoint = *table::borrow_with_default(point_history, min, default_point);
            let max_epoch = voting_escrow.epoch;
            let epoch = find_block_epoch(block, max_epoch);
            let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
            let point_0 = table::borrow_with_default(&voting_escrow.point_history, epoch, default_point);

            let (d_block, d_t) = if (epoch < max_epoch) {
                let point_1 = table::borrow_with_default(&voting_escrow.point_history, epoch + 1, default_point);
                (subtract_or_zero(point_1.blk, point_0.blk), subtract_or_zero(point_1.ts, point_0.ts))
            } else {
                (subtract_or_zero(current_blk_height, point_0.blk), subtract_or_zero(
                    timestamp::now_seconds(),
                    point_0.ts
                ))
            };
            let block_time = point_0.ts;
            if (d_block > 0) {
                block_time = block_time + (d_t * subtract_or_zero(block, point_0.blk) / d_block);
            };

            upoint.bias = subtract_or_zero(upoint.bias, upoint.slope * subtract_or_zero(block_time, upoint.ts));
            upoint.bias
        } else { 0 }
    }

    #[view]
    /// Calculate total voting power at some point in the past.
    ///
    /// # Arguments
    /// * `point` - The point (bias/slope/ts/blk) to start search from.
    /// * `t` - Time to calculate the total voting power at.
    ///
    /// # Returns
    /// Total voting power at that time in 10^12 units.
    public fun supply_at(
        point_bias: u64,
        point_slope: u64,
        point_ts: u64,
        point_blk: u64,
        t: u64
    ): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let last_point = Point { bias: point_bias, slope: point_slope, ts: point_ts, blk: point_blk };
        let week = WEEK;
        let t_i = (last_point.ts / week) * week;
        let default_slope_change = SlopeChange { slope: 0, is_negative: false };
        for (i in 0..TWO_FIFTY_FIVE_WEEKS) {
            t_i = t_i + week;
            let d_slope = default_slope_change;
            if (t_i > t) {
                t_i = t;
            } else {
                d_slope = *table::borrow_with_default(&voting_escrow.slope_changes, t_i, &default_slope_change);
            };
            last_point.bias = subtract_or_zero(
                last_point.bias,
                last_point.slope * subtract_or_zero(t_i, last_point.ts)
            );
            if (t_i == t) { break };

            //manual handel if slope is negative
            last_point.slope = i64::safe_subtract_or_add(last_point.slope, d_slope.slope, d_slope.is_negative);
            last_point.ts = t_i;
        };

        last_point.bias
    }

    #[view]
    /// Calculate total voting power.
    ///
    /// # Returns
    /// Total voting power in 10^12 units.
    public fun total_supply(t: u64): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let epoch = voting_escrow.epoch;

        if (!table::contains(&voting_escrow.point_history, epoch)) {
            return 0
        };
        let last_point = table::borrow(&voting_escrow.point_history, epoch);
        supply_at(
            last_point.bias,
            last_point.slope,
            last_point.ts,
            last_point.blk,
            t
        )
    }

    #[view]
    /// Calculate total voting power at some point in the past.
    ///
    /// # Arguments
    /// * `block` - Block to calculate the total voting power at.
    ///
    /// # Returns
    /// Total voting power at `block` in 10^12 units.
    public fun total_supply_at(block: u64): u64 acquires VotingEscrow {
        assert!(block <= block::get_current_block_height(), ERROR_BLOCK_NUMBER_EXCEEDED);
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let epoch = voting_escrow.epoch;
        let target_epoch = find_block_epoch(block, epoch);
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        let point =
            *table::borrow_with_default(
                &voting_escrow.point_history,
                target_epoch,
                &Point { blk: 0, ts: 0, bias: 0, slope: 0 }
            );
        let dt: u64 = 0;
        if (target_epoch < epoch) {
            let point_next =
                *table::borrow_with_default(
                    &voting_escrow.point_history,
                    target_epoch + 1,
                    &Point { blk: 0, ts: 0, bias: 0, slope: 0 }
                );
            if (point.blk != point_next.blk) {
                dt = (block - point.blk) * (point_next.ts - point.ts) / (point_next.blk - point.blk);
            };
        } else {
            if (point.blk != block::get_current_block_height()) {
                dt = (block - point.blk) * (timestamp::now_seconds() - point.ts) / (block::get_current_block_height(
                ) - point.blk);
            };
        };

        supply_at(
            point.bias,
            point.slope,
            point.ts,
            point.blk,
            point.ts + dt
        )
    }

    #[view]
    /// Returns the current epoch.
    ///
    /// # Returns
    /// The current epoch.
    public fun epoch(): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        voting_escrow.epoch
    }

    #[view]
    /// Returns the current point history for the given epoch.
    ///
    /// # Arguments
    /// * `epoch` - Epoch to get the point history for.
    ///
    /// # Returns
    /// Tuple containing (bias, slope, block, timestamp).
    ///
    /// # Dev
    /// If the point history is not found, returns (0, 0, 0, 0).
    public fun point_history(epoch: u64): (u64, u64, u64, u64) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let point =
            *table::borrow_with_default(
                &voting_escrow.point_history,
                epoch,
                &Point { ts: 0, bias: 0, slope: 0, blk: 0 }
            );
        (point.bias, point.slope, point.blk, point.ts)
    }

    #[view]
    /// Returns the current token point history.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `epoch` - Epoch to get the point history for.
    ///
    /// # Returns
    /// User's point history (bias, slope, block, timestamp).
    ///
    /// # Dev
    /// If the token has no point history, returns (0, 0, 0, 0).
    public fun user_point_history(
        token: address, epoch: u64
    ): (u64, u64, u64, u64) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        // Check if the token has point history
        if (table::contains(&voting_escrow.user_point_history, token)) {
            let point =
                table::borrow_with_default(
                    table::borrow(&voting_escrow.user_point_history, token),
                    epoch,
                    &Point { bias: 0, slope: 0, ts: 0, blk: 0 }
                );
            (point.bias, point.slope, point.blk, point.ts)
        } else {
            (0, 0, 0, 0)
        }
    }

    #[view]
    /// Returns the current NFT token epoch.
    ///
    /// # Arguments
    /// * `token` - token address.
    ///
    /// # Returns
    /// NFT token epoch. If the token has no epoch, returns 0.
    public fun user_point_epoch(token: address): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        *table::borrow_with_default(&voting_escrow.user_point_epoch, token, &0)
    }

    #[view]
    /// Returns the balance(voting power) after merge.
    ///
    /// # Arguments
    /// * `from_token` - token address.
    /// * `to_token` - token address.
    ///
    /// # Returns
    /// Tuple containing (new_power, from_token_power).
    public fun balance_after_merge(
        from_token: address,
        to_token: address
    ): (u64, u64) acquires VotingEscrow {
        assert!(from_token != to_token, ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        assert!(
            table::contains(&voting_escrow.locked, from_token) && table::contains(&voting_escrow.locked, to_token),
            ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST
        );

        let locked0 = *table::borrow(
            &voting_escrow.locked,
            from_token
        );

        let locked1 = *table::borrow(
            &voting_escrow.locked,
            to_token,
        );

        let value = locked0.amount + locked1.amount;

        // Find the maximum end time of the two tokens
        let lock_end = max(locked0.end, locked1.end);

        let current_time = timestamp::now_seconds();
        // as we are adding the amount of from_token to to_token, so we need to calculate the power increase by max lock time
        let incresed_power_by = (locked0.amount * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time);
        let new_power = (value * AMOUNT_SCALE / MAXTIME) * (lock_end - current_time);

        (new_power, incresed_power_by)
    }

    #[view]
    /// Returns the balance(voting power) after extend time.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `time_to_extend` - time to extend. ( if want to extend lock by one week, pass 604800 )
    ///
    /// # Returns
    /// New balance(voting power).
    public fun balance_after_extend_time(
        token: address,
        time_to_extend: u64
    ): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        assert!(table::contains(&voting_escrow.locked, token), ERROR_NO_EXISTING_LOCK_FOUND);

        let locked = *table::borrow(
            &voting_escrow.locked,
            token
        );

        let unlock_time_internal = ((locked.end + time_to_extend) / WEEK) * WEEK; //Unlock time is rounded down to weeks

        let current_time = timestamp::now_seconds();
        assert!(unlock_time_internal <= current_time + MAXTIME, ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS);

        (locked.amount * AMOUNT_SCALE / MAXTIME) * (unlock_time_internal - current_time)
    }

    #[view]
    /// Returns the balance(voting power) after increase amount.
    ///
    /// # Arguments
    /// * `token` - token address.
    /// * `amount_to_increase` - amount to increase.
    ///
    /// # Returns
    /// New balance(voting power).
    public fun balance_after_increase_amount(
        token: address,
        amount_to_increase: u64
    ): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        assert!(table::contains(&voting_escrow.locked, token), ERROR_NO_EXISTING_LOCK_FOUND);

        let locked = *table::borrow(
            &voting_escrow.locked,
            token
        );

        assert!(amount_to_increase > 0, ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO);

        let current_time = timestamp::now_seconds();
        assert!(locked.end > current_time, ERROR_LOCK_IS_EXPIRED);

        ((locked.amount + amount_to_increase) * AMOUNT_SCALE / MAXTIME) * (locked.end - current_time)
    }

    #[view]
    /// Returns the current token id.
    ///
    /// # Returns
    /// Current token id
    public fun get_current_token_id(): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        borrow_global<VotingEscrow>(voting_escrow_address).token_id
    }

    #[view]
    /// Check sender is voter or not
    ///
    /// # Arguments
    /// * `voter` - The address of the sender.
    public fun is_voter(voter: address): bool acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        voter == voting_escrow.voter
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                              INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Set token as voted in gauge.
    ///
    /// # Arguments
    /// * `voter` - The signer.
    /// * `token` - Address of the token to set voting status for.
    public fun voting(voter: &signer, token: address) acquires VotingEscrow, TokenRef {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        assert!(address_of(voter) == voting_escrow.voter, ERROR_NOT_VOTER);

        // Disable transfer of token
        toggle_transfer(token);

        table::upsert(&mut voting_escrow.voted, token, true);
    }

    /// Set token as abstained for gauge.
    ///
    /// # Arguments
    /// * `voter` - The signer.
    /// * `token` - Address of the token to set abstention status for.
    public fun abstain(voter: &signer, token: address) acquires VotingEscrow, TokenRef {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        assert!(address_of(voter) == voting_escrow.voter, ERROR_NOT_VOTER);

        // Enable transfer of token
        toggle_transfer(token);

        table::upsert(&mut voting_escrow.voted, token, false);
    }


    /// Deposit `value` tokens for `to` and lock until `unlock_time`.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `value` - Amount to deposit.
    /// * `unlock_time` - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).
    /// * `to` - Address of the user to receive the NFT token.
    fun create_lock_internal(
        user: &signer, value: u64, unlock_time: u64, to: address
    ) acquires VotingEscrow {
        assert!(value > 0, ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO);

        let unlock_time_internal = (unlock_time / WEEK) * WEEK;
        let current_time = timestamp::now_seconds();

        assert!(unlock_time_internal > current_time, ERROR_INVALID_UNLOCK_TIME);
        assert!(unlock_time_internal <= current_time + MAXTIME, ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS);

        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global_mut<VotingEscrow>(voting_escrow_address);

        // Mint NFT for the to address
        let (minted_token_address, token_name) = mint_nft(voting_escrow, to, unlock_time_internal, value);

        let lock_end = deposit_for_internal(
            voting_escrow,
            user,
            minted_token_address,
            value,
            unlock_time_internal,
            0
        );

        event::emit(CreateLockEvent {
            provider: address_of(user),
            to,
            token: minted_token_address,
            value,
            locktime: lock_end,
            ts: timestamp::now_seconds(),
            nft_name: token_name
        });
    }

    /// Assert if the sender is not the owner of the token.
    ///
    /// # Arguments
    /// * `sender` - The address of the sender.
    /// * `token` - The address of the token to check ownership for.
    public fun assert_if_not_owner(sender: address, token: address) {
        let token_object = object::address_to_object<Token>(token);
        assert!(object::is_owner(token_object, sender), ERROR_NOT_NFT_OWNER);
    }


    /// Record global and per-user data to checkpoint.
    ///
    /// # Parameters
    /// - `voting_escrow`: The mutable voting escrow resource.
    /// - `token`: token address. No user checkpoint if `0x0`.
    /// - `old_locked`: Previous locked amount / end lock time for the token.
    /// - `new_locked`: New locked amount / end lock time for the token.
    fun check_point_internal(
        voting_escrow: &mut VotingEscrow,
        token: address,
        old_locked: &LockedBalance,
        new_locked: &LockedBalance
    ) {
        let u_old: Point = Point { bias: 0, slope: 0, blk: 0, ts: 0 };
        let u_new: Point = Point { bias: 0, slope: 0, blk: 0, ts: 0 };
        let old_dslope: SlopeChange = SlopeChange { slope: 0, is_negative: false };
        let new_dslope: SlopeChange = SlopeChange { slope: 0, is_negative: false };
        let epoch = voting_escrow.epoch;
        let current_time = timestamp::now_seconds();
        let current_blk_height = block::get_current_block_height();

        if (token != @0x0) {
            // Calculate slopes and biases
            // Kept at zero when they have to
            if (old_locked.end > current_time && old_locked.amount > 0) {
                //scaled amount for handel precision loss
                u_old.slope = (old_locked.amount * AMOUNT_SCALE) / MAXTIME;
                u_old.bias = u_old.slope * (old_locked.end - current_time);
            };

            if (new_locked.end > current_time && new_locked.amount > 0) {
                //scaled amount for handel precision loss
                u_new.slope = (new_locked.amount * AMOUNT_SCALE) / MAXTIME;
                u_new.bias = u_new.slope * (new_locked.end - current_time);
            };

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            old_dslope =
                *table::borrow_with_default(
                    &voting_escrow.slope_changes,
                    old_locked.end,
                    &SlopeChange { slope: 0, is_negative: false }
                );
            if (new_locked.end > 0) {
                if (new_locked.end == old_locked.end) {
                    new_dslope = copy old_dslope;
                } else {
                    new_dslope =
                        *table::borrow_with_default(
                            &voting_escrow.slope_changes,
                            new_locked.end,
                            &SlopeChange { slope: 0, is_negative: false }
                        );
                }
            };
        };

        let last_point: Point = Point { bias: 0, slope: 0, blk: current_blk_height, ts: current_time };
        if (epoch > 0) {
            last_point =
                *table::borrow_with_default(
                    &voting_escrow.point_history,
                    epoch,
                    &Point { bias: 0, slope: 0, blk: 0, ts: 0 }
                );
        };
        let last_checkpoint: u64 = last_point.ts;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        let initial_last_point: Point = copy last_point;
        let block_slope: u64 = 0;

        let multiplier: u64 = MULTIPLIER;
        if (current_time > last_point.ts) {
            block_slope = multiplier * (current_blk_height - last_point.blk) / (current_time - last_point.ts);
        };
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        let week = WEEK;

        // Go over weeks to fill history and calculate what the current point is
        let t_i = (last_checkpoint / week) * week;
        for (i in 0..TWO_FIFTY_FIVE_WEEKS) {
            // Hopefully it won't happen that this won't get used in 5 years!
            // If it does, users will be able to withdraw but vote weight will be broken
            t_i = t_i + week;
            let d_slope: SlopeChange = SlopeChange { slope: 0, is_negative: false };
            if (t_i > current_time) {
                t_i = current_time;
            } else {
                d_slope =
                    *table::borrow_with_default(
                        &voting_escrow.slope_changes,
                        t_i,
                        &SlopeChange { slope: 0, is_negative: false }
                    );
            };

            //decay voting power for week
            last_point.bias = i64::subtract_or_zero(
                last_point.bias,
                last_point.slope * (t_i - last_checkpoint)
            );

            //decay slope rate for week
            last_point.slope = i64::safe_subtract_or_add(
                last_point.slope, d_slope.slope, d_slope.is_negative
            );

            last_checkpoint = t_i;
            last_point.ts = t_i;
            last_point.blk = initial_last_point.blk + block_slope * (t_i - initial_last_point.ts) / multiplier;
            epoch = epoch + 1;

            if (t_i == current_time) {
                last_point.blk = current_blk_height;
                break
            } else {
                table::upsert(&mut voting_escrow.point_history, epoch, last_point);
            }
        };

        voting_escrow.epoch = epoch;
        // Now point_history is filled until t=now

        if (token != @0x0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            // for handle slope changes incase negative
            let (slope_diff, slope_diff_is_negative) = i64::safe_subtract_u64(u_new.slope, u_old.slope);

            // for handle slope changes incase negative
            let (bias_diff, bias_diff_is_negative) = i64::safe_subtract_u64(u_new.bias, u_old.bias);
            //safe subtract if slope difference is negative other wise just add slope diff to last_point.slope
            last_point.slope = i64::safe_subtract_or_add(last_point.slope, slope_diff, slope_diff_is_negative);

            //safe subtract if bias difference is negative other wise just add bias diff to last_point.bias
            last_point.bias = i64::safe_subtract_or_add(last_point.bias, bias_diff, bias_diff_is_negative);
        };

        // Record the changed point into history
        table::upsert(&mut voting_escrow.point_history, epoch, last_point);

        if (token != @0x0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (old_locked.end > current_time) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                // Cancel previous old_dslope
                let (i_old_dslope, i_old_dslope_is_negative) =
                    i64::safe_add(
                        i64::from_u64(old_dslope.slope, old_dslope.is_negative),
                        i64::from_u64(u_old.slope, false)
                    );
                old_dslope.slope = i_old_dslope;
                old_dslope.is_negative = i_old_dslope_is_negative;

                // Handle new deposit (new_locked.end == old_locked.end)
                //It was a new deposit, not extension
                if (new_locked.end == old_locked.end) {
                    let (i_old_dslope, i_old_dslope_is_negative) =
                        i64::safe_sub(
                            i64::from_u64(old_dslope.slope, old_dslope.is_negative),
                            i64::from_u64(u_new.slope, false)
                        );
                    old_dslope.slope = i_old_dslope;
                    old_dslope.is_negative = i_old_dslope_is_negative;
                };

                //update slope changes
                table::upsert(&mut voting_escrow.slope_changes, old_locked.end, old_dslope);
            };

            if (new_locked.end > current_time) {
                if (new_locked.end > old_locked.end) {
                    // old slope disappeared at this point
                    let (i_new_dslope, i_new_dslope_is_negative) =
                        i64::safe_sub(
                            i64::from_u64(new_dslope.slope, new_dslope.is_negative),
                            i64::from_u64(u_new.slope, false)
                        );
                    new_dslope.slope = i_new_dslope;
                    new_dslope.is_negative = i_new_dslope_is_negative;

                    table::upsert(&mut voting_escrow.slope_changes, new_locked.end, new_dslope);
                };
                // else: we recorded it already in old_dslope
            };

            // Now handle token history
            let user_epoch = table::borrow_mut_with_default(&mut voting_escrow.user_point_epoch, token, 0);
            *user_epoch = *user_epoch + 1;
            u_new.ts = current_time;
            u_new.blk = current_blk_height;

            if (table::contains(&voting_escrow.user_point_history, token)) {
                let history =
                    table::borrow_mut(&mut voting_escrow.user_point_history, token);
                table::upsert(history, *user_epoch, u_new);
            } else {
                let history = table::new<u64, Point>();
                table::add(&mut history, *user_epoch, u_new);
                table::add(&mut voting_escrow.user_point_history, token, history);
            };
        }
    }

    /// Deposit and lock tokens for a NFT token.
    ///
    /// # Arguments
    /// * `user` - The signer.
    /// * `token` - Address of the NFT token.
    /// * `value` - Amount to deposit.
    /// * `unlock_time` - New time when to unlock the tokens, or 0 if unchanged (current time + lock period).
    /// * `type` - Type of operation (create lock, increase amount, increase unlock time).
    fun deposit_for_internal(
        voting_escrow: &mut VotingEscrow,
        user: &signer, token: address, value: u64, unlock_time: u64, type: u8
    ): u64 {
        let locked_balance =
            table::borrow_with_default(
                &voting_escrow.locked,
                token,
                &LockedBalance { amount: 0, end: 0 }
            );
        let locked = LockedBalance {
            amount: locked_balance.amount,
            end: locked_balance.end
        };
        let supply_before = voting_escrow.supply;

        voting_escrow.supply = supply_before + value;
        let old_locked = locked;

        // Adding to existing lock, or if a lock is expired - creating a new one
        locked.amount = locked.amount + value;

        if (unlock_time > 0) {
            locked.end = unlock_time;
        };

        table::upsert(&mut voting_escrow.locked, token, locked);

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // locked.end > block.timestamp (always)
        check_point_internal(
            voting_escrow,
            token,
            &old_locked,
            &locked
        );

        if (value > 0 && type != MERGE_TYPE && type != SPLIT_TYPE) {
            let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();

            assert!(
                primary_fungible_store::balance(address_of(user), dxlyn_metadata) >= value,
                ERROR_INSUFFICIENT_DXLYN_COIN
            );

            primary_fungible_store::transfer(
                user,
                dxlyn_metadata,
                // transfer to voting escrow address
                get_voting_escrow_address(),
                value
            );
        };

        event::emit(
            SupplyEvent { prev_supply: supply_before, supply: voting_escrow.supply }
        );

        locked.end
    }

    /// Mint an NFT representing a voting escrow position.
    ///
    /// # Arguments
    /// * `voting_escrow` - The voting escrow object.
    /// * `user` - The address to mint the NFT to.
    /// * `locked_end` - The end time of the lock.
    /// * `locked_amount` - The amount locked in the voting escrow.
    ///
    /// # Returns
    /// The address of the minted NFT.
    fun mint_nft(
        voting_escrow: &mut VotingEscrow,
        user: address,
        locked_end: u64,
        locked_amount: u64
    ): (address, String) {
        let collection_address = object::address_from_extend_ref(&voting_escrow.collection_extend_ref);
        let collection_object = object::address_to_object<Collection>(collection_address);

        voting_escrow.token_id = voting_escrow.token_id + 1;

        let (token_name, token_description, token_uri) = get_token_details(
            voting_escrow.token_id,
            locked_end, // locked_end
            locked_amount // value
        );

        let creator = &object::generate_signer_for_extending(&voting_escrow.extended_ref);

        let constructor_ref = token::create_named_token(creator,
            collection::name(collection_object),
            token_description,
            token_name,
            option::none(),
            token_uri,
        );

        let token_address = object::address_from_constructor_ref(&constructor_ref);
        let token = object::address_to_object<Token>(token_address);

        // Transfer the token to the user
        object::transfer(creator, token, user);

        let token_signer = &object::generate_signer(&constructor_ref);

        // Generate and store the burn and transfer references for future use
        move_to(token_signer, TokenRef {
            burn_ref: token::generate_burn_ref(&constructor_ref),
            transfer_ref: object::generate_transfer_ref(&constructor_ref)
        });

        // Return the address of the minted token
        (token_address, token_name)
    }

    /// Burn an NFT representing a voting escrow position.
    ///
    /// # Arguments
    /// * `token` - The address of the NFT token to burn.
    fun burn_nft(
        token: address
    ) acquires TokenRef {
        let token_data = move_from<TokenRef>(token);

        let TokenRef { burn_ref, transfer_ref: _ } = token_data;

        event::emit(BurnNFTEvent {
            token,
            ts: timestamp::now_seconds(),
        });

        token::burn(burn_ref)
    }

    /// Toggle the transfer state of a token.
    ///
    /// # Arguments
    /// * `token` - The address of the token to toggle transfer state for.
    fun toggle_transfer(
        token: address,
    ) acquires TokenRef {
        let token_data = borrow_global<TokenRef>(token);
        let token = object::address_to_object<Token>(token);

        // Toggle it based on its current state
        if (object::ungated_transfer_allowed(token)) {
            object::disable_ungated_transfer(&token_data.transfer_ref);
        } else {
            object::enable_ungated_transfer(&token_data.transfer_ref);
        }
    }

    /// Generate a token name for the NFT.
    ///
    /// # Arguments
    /// * `token_id` - The ID of the token.
    /// * `locked_end` - The end time of the lock.
    /// * `locked_amount` - The amount locked in the voting escrow.
    ///
    /// # Returns
    /// The token name , token description and token URI.
    fun get_token_details(token_id: u64, locked_end: u64, locked_amount: u64): (String, String, String) {
        (get_token_name(token_id), get_token_description(token_id, locked_end, locked_amount), get_token_uri(
            token_id,
            locked_end,
            locked_amount
        ))
    }

    /// Generate a token name for the NFT.
    ///
    /// # Arguments
    /// * `token_id` - The ID of the token.
    ///
    /// # Returns
    /// The token name
    fun get_token_name(token_id: u64): String {
        string_utils::format1(&b"veDXLYN position #{}", token_id)
    }

    /// Generate a token description for the NFT.
    ///
    /// # Arguments
    /// * `token_id` - The ID of the token.
    /// * `locked_end` - The end time of the lock.
    /// * `locked_amount` - The amount locked in the voting escrow.
    ///
    /// # Returns
    /// The token description
    fun get_token_description(token_id: u64, locked_end: u64, locked_amount: u64): String {
        string_utils::format3(
            &b"veDXLYN NFT position ID: {} , Lock end: {} , Locked Amount : {}",
            token_id,
            locked_end,
            locked_amount
        )
    }

    /// Generate a token URI for the NFT.
    ///
    /// # Arguments
    /// * `token_id` - The ID of the token.
    /// * `locked_end` - The end time of the lock.
    /// * `value` - The value of the lock.
    fun get_token_uri(token_id: u64, locked_end: u64, value: u64): string::String {
        let svg_image = string::utf8(
            b"<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 350 350\"><text x=\"10\" y=\"20\">VeDxlyn NFT</text>"
        );
        let svg_image_formatted = string_utils::format3(
            &b"<text x=\"10\" y=\"50\">ID:{},</text><text x=\"10\" y=\"70\" >Lock End:{},</text><text x=\"10\" y=\"90\" >Value:{}</text></svg>",
            token_id,
            locked_end,
            value
        );

        string::append(&mut svg_image, svg_image_formatted);

        let encoded_svg = base64::encode(string::bytes(&svg_image));
        let final_uri = string::utf8(b"data:image/svg+xml;base64,");

        string::append(&mut final_uri, encoded_svg);

        final_uri
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    public fun initialize(res: &signer) {
        init_module(res);
    }

    #[test_only]
    public fun get_voting_escrow_state():
    (
        u64, // epoch
        u64, // supply
        address, // admin
        address, // future_admin
        u64, // coins_value,
        address
    ) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);

        (
            voting_escrow.epoch,
            voting_escrow.supply,
            voting_escrow.admin,
            voting_escrow.future_admin,
            primary_fungible_store::balance(voting_escrow_address, dxlyn_coin::get_dxlyn_asset_metadata()),
            voting_escrow.voter
        )
    }

    #[test_only]
    public fun get_token_lock(token: address): (u64, u64) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let locked =
            table::borrow_with_default(
                &voting_escrow.locked,
                token,
                &LockedBalance { amount: 0, end: 0 }
            );
        (locked.amount, locked.end)
    }

    #[test_only]
    public fun get_token_point_history(
        token: address, epoch: u64
    ): (u64, u64, u64, u64) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let is_point_history_found =
            table::contains(&voting_escrow.user_point_history, token);
        if (is_point_history_found) {
            let user_point = table::borrow(&voting_escrow.user_point_history, token);
            let point =
                table::borrow_with_default(
                    user_point,
                    epoch,
                    &Point { bias: 0, slope: 0, ts: 0, blk: 0 }
                );
            (point.bias, point.slope, point.ts, point.blk)
        } else {
            (0, 0, 0, 0)
        }
    }

    #[test_only]
    public fun get_token_epoch(token: address): u64 acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        *table::borrow_with_default(&voting_escrow.user_point_epoch, token, &0)
    }

    #[test_only]
    public fun get_point_history(epoch: u64): (u64, u64, u64, u64) acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        let point =
            table::borrow_with_default(
                &voting_escrow.point_history,
                epoch,
                &Point { bias: 0, slope: 0, ts: 0, blk: 0 }
            );
        (point.bias, point.slope, point.ts, point.blk)
    }

    #[test_only]
    public fun is_voted(token: address): bool acquires VotingEscrow {
        let voting_escrow_address = get_voting_escrow_address();
        let voting_escrow = borrow_global<VotingEscrow>(voting_escrow_address);
        *table::borrow_with_default(&voting_escrow.voted, token, &false)
    }
}
