module dexlyn_tokenomics::fee_distributor {

    use std::signer::address_of;
    use std::vector;
    use aptos_std::table::{Self, Table};

    use dexlyn_coin::dxlyn_coin::{Self, DXLYN};
    use supra_framework::coin;
    use supra_framework::event;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::object::{Self, ExtendRef};
    use supra_framework::primary_fungible_store;
    use supra_framework::supra_account;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::i64;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow::is_voter;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Address of the developer or deployer, used as the initial admin and emergency return
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// Seed for creating the fee distributor resource account
    const FEE_DISTRIBUTOR_SEEDS: vector<u8> = b"FEE_DISTRIBUTOR";

    /// One week in seconds (7 days), used for epoch calculations
    const WEEK: u64 = 604800;

    /// Deadline (1 day in seconds) for allowing token checkpoint updates
    const TOKEN_CHECKPOINT_DEADLINE: u64 = 86400;

    /// For iteration of the epoch calculation
    const ONE_TWENTY_EIGHT_EPOCHS: u64 = 128;

    /// For iteration of the weekly calculation
    const TWENTY_WEEKS: u64 = 20;

    /// For iteration of the weekly calculation
    const FIFTY_WEEKS: u64 = 50;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    /// Caller is not the admin
    const ERROR_NOT_ADMIN: u64 = 101;

    /// Unauthorized user or checkpoint time not reached
    const ERROR_NOT_ALLOWED: u64 = 102;

    /// Contract must be active (not killed) to perform this operation
    const ERROR_CONTRACT_KILLED: u64 = 103;

    /// Contract have insufficient DXLYN balance
    const ERROR_INSUFFICIENT_BALANCE: u64 = 104;

    /// Address cannot be the zero address
    const ERROR_ZERO_ADDRESS: u64 = 105;

    /// Cannot recover DXLYN tokens from the contract
    const ERROR_CAN_NOT_RECOVER_DXLYN: u64 = 106;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Represents the commitment to transfer admin rights
    struct CommitAdminEvent has store, drop, copy {
        admin: address
    }

    #[event]
    /// Represents the change of emergency return address
    struct ChangeEmergencyReturnEvent has store, drop, copy {
        new_emergency_return: address
    }

    #[event]
    /// Represents the application of admin rights transfer
    struct ApplyAdminEvent has store, drop, copy {
        admin: address
    }

    #[event]
    /// Represents the toggle of checkpoint token permission
    struct ToggleAllowCheckpointTokenEvent has store, drop, copy {
        toggle_flag: bool
    }

    #[event]
    /// Represents a token checkpoint event
    struct CheckpointTokenEvent has drop, copy, store {
        time: u64,
        tokens: u64
    }

    #[event]
    /// Represents a claim event
    struct ClaimedEvent has store, drop, copy {
        recipient: address,
        token: address,
        amount: u64,
        claim_epoch: u64,
        max_epoch: u64
    }

    #[event]
    /// Represents a claim event for a specific week
    struct WeeklyClaimedEvent has store, drop, copy {
        recipient: address,
        token: address,
        week: u64,
        amount: u64,
        ts: u64
    }

    #[event]
    /// Represents a rebase added event
    struct RebaseAddedEvent has store, drop, copy {
        sender: address,
        amount: u64,
        ts: u64
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Represents a point in time with voting power and timestamp
    struct Point has drop, copy {
        bias: u64,
        slope: u64,
        ts: u64,
        blk: u64
    }

    /// Represents the fee distributor resource
    struct FeeDistributor has key {
        start_time: u64,
        time_cursor: u64,
        // token -> time
        time_cursor_of: Table<address, u64>,
        // token -> epoch
        user_epoch_of: Table<address, u64>,
        last_token_time: u64,
        // store time -> amount  note: change from array to table,
        tokens_per_week: Table<u64, u64>,
        total_received: u64,
        token_last_balance: u64,
        // weekly veDxlyn supply time -> supply
        ve_supply: Table<u64, u64>,
        admin: address,
        future_admin: address,
        can_checkpoint_token: bool,
        emergency_return: address,
        is_killed: bool,
        extended_ref: ExtendRef
    }

    /// Represents a weekly claim for view function
    struct WeeklyClaim has store, drop, copy {
        token: address,
        week: u64,
        amount: u64
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                            CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initializes the fee distributor resource
    ///
    /// # Arguments
    /// * `sender` - The signer requesting the initialization.
    fun init_module(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, FEE_DISTRIBUTOR_SEEDS);

        let fee_dis_signer = object::generate_signer(&constructor_ref);

        let t: u64 = round_to_week(timestamp::now_seconds());

        // migrated dxlyn coin to fungible store for handel both coins
        coin::migrate_to_fungible_store<DXLYN>(&fee_dis_signer);

        move_to<FeeDistributor>(
            &fee_dis_signer,
            FeeDistributor {
                start_time: t,
                time_cursor: t,
                last_token_time: t,
                time_cursor_of: table::new<address, u64>(),
                user_epoch_of: table::new<address, u64>(),
                tokens_per_week: table::new<u64, u64>(),
                total_received: 0,
                token_last_balance: 0,
                ve_supply: table::new<u64, u64>(),
                admin: @admin,
                future_admin: @0x0,
                can_checkpoint_token: false,
                emergency_return: @emergency_return,
                is_killed: false,
                extended_ref: object::generate_extend_ref(&constructor_ref)
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

    /// Commit transfer of ownership.
    ///
    /// # Arguments
    /// * `admin` - The current admin signer.
    /// * `new_future_admin` - The new admin address.
    public entry fun commit_admin(
        admin: &signer, new_future_admin: address
    ) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        fee_dis.future_admin = new_future_admin;

        event::emit(CommitAdminEvent { admin: new_future_admin })
    }

    /// Apply transfer of ownership.
    ///
    /// # Arguments
    /// * `admin` - The current admin signer.
    public entry fun apply_admin(admin: &signer) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);
        assert!(fee_dis.future_admin != @0x0, ERROR_ZERO_ADDRESS);

        fee_dis.admin = fee_dis.future_admin;

        event::emit(ApplyAdminEvent { admin: fee_dis.future_admin })
    }

    /// Updates the token checkpoint.
    ///
    /// # Arguments
    /// * `sender` - The signer calling the function.
    ///
    /// # Dev
    /// Calculates the total number of tokens to be distributed in a given week.
    /// During initial distribution, only the contract owner can call this.
    /// After setup, it can be enabled for anyone to call.
    public entry fun checkpoint_token(sender: &signer) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        let sender_address = address_of(sender);
        assert!(
            is_voter(sender_address) ||
                sender_address == fee_dis.admin
                || (
                fee_dis.can_checkpoint_token
                    && timestamp::now_seconds()
                    > fee_dis.last_token_time + TOKEN_CHECKPOINT_DEADLINE
            ),
            ERROR_NOT_ALLOWED
        );
        checkpoint_token_internal(fee_dis, fee_dis_address);
    }

    /// Updates the veDXLYN total supply checkpoint.
    ///
    /// # Dev
    /// The checkpoint is also updated by the first claimant each new epoch week.
    /// This function may be called independently of a claim to reduce claiming gas costs.
    public entry fun checkpoint_total_supply() acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);
        checkpoint_total_supply_internal(fee_dis);
    }

    /// Toggle permission for checkpoint by any account.
    ///
    /// # Arguments
    /// * `admin` - The admin signer.
    public entry fun toggle_allow_checkpoint_token(admin: &signer) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        let flag = !fee_dis.can_checkpoint_token;

        fee_dis.can_checkpoint_token = flag;

        event::emit(ToggleAllowCheckpointTokenEvent { toggle_flag: flag })
    }

    /// Kill the contract.
    ///
    /// # Arguments
    /// * `admin` - The admin signer.
    ///
    /// # Dev
    /// Killing transfers the entire DXLYN balance to the emergency return address
    /// and blocks the ability to claim or burn. The contract cannot be un-killed.
    public entry fun kill_me(admin: &signer) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        fee_dis.is_killed = true;

        let fee_dis_signer = object::generate_signer_for_extending(&fee_dis.extended_ref);
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let total_amount = primary_fungible_store::balance(address_of(&fee_dis_signer), dxlyn_metadata);
        primary_fungible_store::transfer(
            &fee_dis_signer,
            dxlyn_metadata,
            fee_dis.emergency_return,
            total_amount
        );
    }

    /// Recover any OLD (Legacy Token) tokens from this contract.
    ///
    /// # Type Parameters
    /// - `CoinType`: The legacy coin type to recover.
    ///
    /// # Parameters
    /// - `admin`: The admin signer.
    ///
    /// # Dev
    /// Tokens are sent to the emergency return address.
    public entry fun recover_balance_legacy_coin<CoinType>(admin: &signer) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        let fee_dis_signer = object::generate_signer_for_extending(&fee_dis.extended_ref);

        supra_account::transfer_coins<CoinType>(
            &fee_dis_signer,
            fee_dis.emergency_return,
            // transfer total amount from fee distributor
            coin::balance<CoinType>(fee_dis_address)
        );
    }

    /// Recover any FA tokens from this contract except DXLYN.
    /// Tokens are sent to the emergency return address.
    ///
    /// # Arguments
    /// * `admin` - The admin signer.
    /// * `coin` - The token address to recover.
    public entry fun recover_balance_fa(admin: &signer, coin: address) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        let dxlyn_address = dxlyn_coin::get_dxlyn_asset_address();

        assert!(dxlyn_address != coin, ERROR_CAN_NOT_RECOVER_DXLYN);

        let coin_metadata = object::address_to_object<Metadata>(coin);

        let fee_dis_signer = object::generate_signer_for_extending(&fee_dis.extended_ref);

        primary_fungible_store::transfer(
            &fee_dis_signer,
            coin_metadata,
            fee_dis.emergency_return,
            // transfer total amount from fee distributor
            primary_fungible_store::balance(fee_dis_address, coin_metadata)
        );
    }

    /// Changes the emergency return address.
    ///
    /// # Arguments
    /// * `admin` - The admin signer.
    /// * `new_emergency_return` - New emergency return address.
    public entry fun change_emergency_return(
        admin: &signer, new_emergency_return: address
    ) acquires FeeDistributor {
        assert!(new_emergency_return != @0x0, ERROR_ZERO_ADDRESS);

        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(address_of(admin) == fee_dis.admin, ERROR_NOT_ADMIN);

        fee_dis.emergency_return = new_emergency_return;

        event::emit(ChangeEmergencyReturnEvent { new_emergency_return })
    }

    /// Claims fees for the nft token.
    ///
    /// # Arguments
    /// * `sender` - The signer requesting the claim.
    /// * `token` - The address of the NFT token to claim for.
    ///
    /// # Dev
    /// Each call to `claim` processes up to 50 weeks of veDXLYN points.
    /// For accounts with extensive veDXLYN activity, multiple calls may be needed to claim all available fees.
    /// The `Claimed` event indicates if more claims are possible: if `claim_epoch` < `max_epoch`, the account can claim again.
    public entry fun claim(sender: &signer, token: address) acquires FeeDistributor {
        let sender_address = address_of(sender);

        // Check token ownership
        voting_escrow::assert_if_not_owner(sender_address, token);

        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);

        assert!(!fee_dis.is_killed, ERROR_CONTRACT_KILLED);

        let current_time = timestamp::now_seconds();
        // Update total voting supply if time_cursor is reached
        if (current_time >= fee_dis.time_cursor) {
            checkpoint_total_supply_internal(fee_dis);
        };

        // Perform token checkpoint if allowed and deadline passed
        let last_token_time = fee_dis.last_token_time;

        if (fee_dis.can_checkpoint_token && current_time > last_token_time + TOKEN_CHECKPOINT_DEADLINE) {
            checkpoint_token_internal(fee_dis, fee_dis_address);
            last_token_time = current_time;
        };

        // Round last_token_time to the start of the week
        last_token_time = round_to_week(last_token_time);

        // Call claim_internal to calculate and distribute tokens
        let amount = claim_internal(fee_dis, sender_address, token, last_token_time);

        // Update token_last_balance
        if (amount > 0) {
            let fee_dis_signer = object::generate_signer_for_extending(&fee_dis.extended_ref);
            primary_fungible_store::transfer(
                &fee_dis_signer,
                dxlyn_coin::get_dxlyn_asset_metadata(),
                sender_address,
                amount
            );

            fee_dis.token_last_balance = fee_dis.token_last_balance - amount;
        };
    }

    /// Make multiple fee claims in a single call.
    ///
    /// # Parameters
    /// * `sender` - The signer requesting the claims.
    /// * `tokens` - A vector of addresses representing the NFT tokens to claim for.
    ///
    /// # Dev
    /// Used to claim for many accounts at once, or to make multiple claims for the same address when that address has significant veDXLYN history.
    public entry fun claim_many(
        sender: &signer, tokens: vector<address>
    ) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);
        assert!(!fee_dis.is_killed, ERROR_CONTRACT_KILLED);

        let current_time = timestamp::now_seconds();
        // Update total voting supply if time_cursor is reached
        if (current_time >= fee_dis.time_cursor) {
            checkpoint_total_supply_internal(fee_dis);
        };

        let last_token_time = fee_dis.last_token_time;

        if (fee_dis.can_checkpoint_token && current_time > fee_dis.last_token_time + TOKEN_CHECKPOINT_DEADLINE) {
            checkpoint_token_internal(fee_dis, fee_dis_address);
            last_token_time = current_time;
        };

        // Round last_token_time to the start of the week
        last_token_time = round_to_week(last_token_time);

        // Claim for each address
        let total: u64 = 0;
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let fee_dis_signer = object::generate_signer_for_extending(&fee_dis.extended_ref);
        let sender_address = address_of(sender);

        for (i in 0..vector::length(&tokens)) {
            let token = *vector::borrow(&tokens, i);
            if (token == @0x0) { break };

            // Check token ownership
            voting_escrow::assert_if_not_owner(sender_address, token);

            let amount = claim_internal(fee_dis, sender_address, token, last_token_time);
            if (amount > 0) {
                primary_fungible_store::transfer(
                    &fee_dis_signer,
                    dxlyn_metadata,
                    sender_address,
                    amount
                );

                total = total + amount;
            };
        };

        // Update token_last_balance
        if (total > 0) {
            assert!(fee_dis.token_last_balance >= total, ERROR_INSUFFICIENT_BALANCE);
            fee_dis.token_last_balance = fee_dis.token_last_balance - total;
        };
    }

    /// Receive DXLYN into the contract and trigger a token checkpoint.
    ///
    /// # Arguments
    /// * `sender` - The signer sending the DXLYN.
    /// * `amount` - The amount of DXLYN to send.
    public entry fun burn(sender: &signer, amount: u64) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);
        assert!(!fee_dis.is_killed, ERROR_CONTRACT_KILLED);

        if (amount > 0) {
            primary_fungible_store::transfer(sender, dxlyn_coin::get_dxlyn_asset_metadata(), fee_dis_address, amount);

            let current_timestamp = timestamp::now_seconds();
            event::emit(RebaseAddedEvent {
                sender: address_of(sender),
                amount,
                ts: current_timestamp
            });

            if (fee_dis.can_checkpoint_token && current_timestamp
                > fee_dis.last_token_time + TOKEN_CHECKPOINT_DEADLINE) {
                checkpoint_token_internal(fee_dis, fee_dis_address)
            };
        }
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get the address of the fee distributor
    ///
    /// # Returns
    /// The address of the fee distributor resource.
    public fun get_fee_distributor_address(): address {
        object::create_object_address(&SC_ADMIN, FEE_DISTRIBUTOR_SEEDS)
    }

    #[view]
    /// Find the epoch for a given timestamp.
    ///
    /// # Arguments
    /// * `timestamp` - The timestamp to search for.
    ///
    /// # Returns
    /// The epoch number corresponding to the given timestamp.
    ///
    /// # Dev
    /// Uses binary search to find the epoch with the closest timestamp.
    fun find_timestamp_epoch(timestamp: u64): u64 {
        let min = 0;
        let max = voting_escrow::epoch();

        for (i in 0..ONE_TWENTY_EIGHT_EPOCHS) {
            if (min >= max) { break };
            let mid = (min + max + 2) / 2;
            let (_, _, _, ts) = voting_escrow::point_history(mid);
            if (ts <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        };

        min
    }

    #[view]
    /// Find the epoch for a given token and timestamp.
    ///
    /// # Arguments
    /// * `token` - The address of the NFT token.
    /// * `timestamp` - The timestamp to search for.
    /// * `max_user_epoch` - The maximum user epoch.
    ///
    /// # Returns
    /// The epoch number corresponding to the given nft token and timestamp.
    ///
    /// # Dev
    /// Uses binary search to find the token epoch with the closest timestamp.
    fun find_timestamp_user_epoch(
        token: address, timestamp: u64, max_user_epoch: u64
    ): u64 {
        let min = 0;
        let max = max_user_epoch;

        for (i in 0..ONE_TWENTY_EIGHT_EPOCHS) {
            if (min >= max) { break };
            let mid = (min + max + 2) / 2;
            let (_, _, _, ts) = voting_escrow::user_point_history(token, mid);
            if (ts <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        };

        min
    }

    #[view]
    /// Returns the veDXLYN balance for a NFT token at a specific timestamp.
    ///
    /// # Arguments
    /// * `token` - NFT token address to query balance for.
    /// * `timestamp` - Epoch time.
    ///
    /// # Returns
    /// * `u64` - veDXLYN balance in 10^12 units.
    public fun ve_for_at(token: address, timestamp: u64): u64 {
        let max_user_epoch = voting_escrow::user_point_epoch(token);
        let epoch = find_timestamp_user_epoch(token, timestamp, max_user_epoch);
        let (bias, slope, _, ts) = voting_escrow::user_point_history(token, epoch);

        // return veDXLYN power
        i64::max((bias - slope * (timestamp - ts)), 0)
    }

    #[view]
    /// Returns the claimable amount for a specific token.
    ///
    /// # Arguments
    /// * `token` - NFT token address to query balance for.
    ///
    /// # Returns
    /// Total claimable amount and vector of weekly claims.
    public fun claimable(token: address): (u64, vector<WeeklyClaim>) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);
        let rounded_last_token_time = round_to_week(fee_dis.last_token_time);
        claimable_internal(fee_dis, token, rounded_last_token_time)
    }

    #[view]
    /// Returns the claimable amount for a multiple tokens.
    ///
    /// # Arguments
    /// * `tokens` - Vector of NFT token addresses to query claimable balance for.
    ///
    /// # Returns
    /// Total claimable amount and vector of vectors of weekly claims.
    public fun claimable_many(tokens: vector<address>): (u64, vector<vector<WeeklyClaim>>) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);
        let rounded_last_token_time = round_to_week(fee_dis.last_token_time);
        let claimable_amounts = vector::empty<vector<WeeklyClaim>>();
        let total_claimable: u64 = 0;

        vector::for_each(tokens, |token| {
            let (total, claimable) = claimable_internal(fee_dis, token, rounded_last_token_time);
            total_claimable = total_claimable + total;
            vector::push_back(&mut claimable_amounts, claimable);
        });
        (total_claimable, claimable_amounts)
    }

    #[view]
    /// Returns the remaining claim calls for a given NFT token.
    ///
    /// # Arguments
    /// * `token` - NFT token address to query remaining claim calls for.
    ///
    /// # Returns
    /// The remaining claim calls.
    public fun get_remaining_claim_calls(token: address): u64 acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);
        let last_token_time = round_to_week(fee_dis.last_token_time);

        let last_claim_epoch = *table::borrow_with_default(&fee_dis.time_cursor_of, token, &0);

        if (last_claim_epoch < fee_dis.start_time) {
            last_claim_epoch = fee_dis.start_time;
        };

        if (last_claim_epoch >= last_token_time) {
            return 0
        };

        let unclaimed_epochs = (last_token_time - last_claim_epoch) / WEEK;

        (unclaimed_epochs + 49) / FIFTY_WEEKS
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Receive DXLYN into the contract and trigger without trigger used in update period
    ///
    /// # Arguments
    /// * `voter` - The signer voting to send the DXLYN.
    /// * `sender` - The signer sending the DXLYN.
    /// * `amount` - The amount of DXLYN to send.
    ///
    /// # Dev
    /// Only a voter can call this function to send DXLYN to the contract.
    public fun burn_rebase(voter: &signer, sender: &signer, amount: u64) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global_mut<FeeDistributor>(fee_dis_address);
        assert!(!fee_dis.is_killed, ERROR_CONTRACT_KILLED);

        // check if sender is a voter
        let voter_address = address_of(voter);
        voting_escrow::is_voter(voter_address);

        if (amount > 0) {
            primary_fungible_store::transfer(
                sender,
                dxlyn_coin::get_dxlyn_asset_metadata(),
                fee_dis_address,
                amount
            );

            event::emit(RebaseAddedEvent {
                sender: voter_address,
                amount,
                ts: timestamp::now_seconds()
            });
        }
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Checkpoint the token distribution
    ///
    /// # Arguments
    /// * `fee_dis`: A mutable reference to the `FeeDistributor` resource.
    fun checkpoint_token_internal(fee_dis: &mut FeeDistributor, fee_dis_address: address) {
        let token_balance = primary_fungible_store::balance(fee_dis_address, dxlyn_coin::get_dxlyn_asset_metadata());
        let to_distribute = token_balance - fee_dis.token_last_balance;

        fee_dis.token_last_balance = token_balance;

        let t = fee_dis.last_token_time;
        let current_time = timestamp::now_seconds();
        let since_last = current_time - t;
        fee_dis.last_token_time = current_time;
        let this_week = round_to_week(t);
        let _next_week = 0;
        let week = WEEK;

        for (i in 0..TWENTY_WEEKS) {
            // Calculate the start of the next week.
            _next_week = this_week + week;

            // Check if the current time is within the current week.
            if (current_time < _next_week) {
                // Handle edge case: no time has passed since the last checkpoint.
                if (since_last == 0 && current_time == t) {
                    // All tokens go to the current week.
                    let token_per_week = table::borrow_mut_with_default(&mut fee_dis.tokens_per_week, this_week, 0);
                    *token_per_week = *token_per_week + to_distribute;
                } else {
                    // Distribute tokens proportionally based on time spent in the current week.
                    let token_per_week = table::borrow_mut_with_default(&mut fee_dis.tokens_per_week, this_week, 0);

                    let scaled_token_per_week =
                        (*token_per_week as u256)
                            + ((to_distribute as u256)
                            * ((current_time - t) as u256)) / (
                            since_last as u256
                        );

                    *token_per_week = (scaled_token_per_week as u64);
                };
                // Exit the loop as we've allocated tokens up to the current week.
                break
            } else {
                if (since_last == 0 && _next_week == t) {
                    // All tokens go to the current week.
                    let token_per_week = table::borrow_mut_with_default(&mut fee_dis.tokens_per_week, this_week, 0);
                    *token_per_week = *token_per_week + to_distribute;
                } else {
                    // Distribute tokens proportionally for the full week.
                    let token_per_week = table::borrow_mut_with_default(&mut fee_dis.tokens_per_week, this_week, 0);

                    let scaled_token_per_week =
                        (*token_per_week as u256)
                            + ((to_distribute as u256) * ((_next_week - t) as u256))
                            / (since_last as u256);

                    *token_per_week = (scaled_token_per_week as u64);
                }
            };
            t = _next_week;
            this_week = _next_week;
        };

        event::emit(
            CheckpointTokenEvent { time: current_time, tokens: to_distribute }
        )
    }

    /// Checkpoint the total supply of veDXLYN.
    ///
    /// # Arguments
    /// * `fee_dis` - The FeeDistributor resource to update.
    ///
    /// # Dev
    /// This function updates the veDXLYN supply for 20 weeks from the last checkpoint to the current time.
    fun checkpoint_total_supply_internal(fee_dis: &mut FeeDistributor) {
        let t = fee_dis.time_cursor;
        let rounded_timestamp = round_to_week(timestamp::now_seconds());

        voting_escrow::checkpoint();
        let week = WEEK;

        for (i in 0..TWENTY_WEEKS) {
            if (t > rounded_timestamp) { break }
            else {
                let epoch = find_timestamp_epoch(t);
                let (bias, slope, _, ts) = voting_escrow::point_history(epoch);
                let dt = 0;
                if (t > ts) {
                    //If the point is at 0 epoch, it can actually be earlier than the first deposit
                    //Then make dt 0
                    dt = t - ts;
                };
                table::upsert(&mut fee_dis.ve_supply, t, i64::max((bias - slope * dt), 0));
            };
            t = t + week
        };

        fee_dis.time_cursor = t;
    }

    /// Distributes tokens to a user based on their voting power up to `last_token_time`.
    ///
    /// # Arguments
    /// * `fee_dis` - The FeeDistributor resource to update.
    /// * `token_owner` - The address of the token owner (the user).
    /// * `token` - The nft token address.
    /// * `last_token_time` - The end timestamp for the claim period (week-aligned).
    ///
    /// # Returns
    /// The amount of tokens to distribute.
    fun claim_internal(
        fee_dis: &mut FeeDistributor, token_owner: address, token: address, last_token_time: u64
    ): u64 {
        // Initialize variables
        let max_user_epoch = voting_escrow::user_point_epoch(token);

        // If user has no voting power, return 0
        if (max_user_epoch == 0) {
            return 0
        };

        let start_time = fee_dis.start_time;

        // Get or initialize week cursor and user epoch
        let week_cursor = *table::borrow_with_default(&fee_dis.time_cursor_of, token, &0);
        let user_epoch = if (week_cursor == 0) {
            // First claim, find the epoch at start_time
            // Need to do the initial binary search
            find_timestamp_user_epoch(token, start_time, max_user_epoch)
        } else {
            *table::borrow_with_default(&fee_dis.user_epoch_of, token, &0)
        };

        // Ensure user_epoch is at least 1
        if (user_epoch == 0) {
            user_epoch = 1;
        };

        // Get the user's voting point at user_epoch
        let (bias, slope, blk, ts) = voting_escrow::user_point_history(token, user_epoch);
        let user_point = Point { slope, bias, ts, blk };
        let week = WEEK;

        // Initialize week cursor if needed
        if (week_cursor == 0) {
            week_cursor = round_to_week(user_point.ts + week - 1);
        };

        // Check if no tokens to claim
        if (week_cursor >= last_token_time) {
            return 0
        };

        // Ensure week_cursor is not before start_time
        if (week_cursor < start_time) {
            week_cursor = start_time;
        };

        // Initialize old point
        let old_user_point = Point { slope: 0, bias: 0, ts: 0, blk: 0 };

        let to_distribute: u64 = 0;

        let current_timestamp = timestamp::now_seconds();
        // Iterate over weeks (up to 50 weeks)
        for (i in 0..FIFTY_WEEKS) {
            if (week_cursor >= last_token_time) { break };

            // Update epoch if week_cursor is past the current point's timestamp
            if (week_cursor >= user_point.ts && user_epoch <= max_user_epoch) {
                user_epoch = user_epoch + 1;
                old_user_point = user_point;

                if (user_epoch > max_user_epoch) {
                    // No more points, set to zero
                    user_point = Point { slope: 0, bias: 0, ts: 0, blk: 0 };
                } else {
                    // Get the next point
                    let (ibias, islope, iblk, its) =
                        voting_escrow::user_point_history(token, user_epoch);
                    user_point = Point { slope: islope, bias: ibias, ts: its, blk: iblk };
                };
            } else {
                // Calculate voting power at week_cursor
                let (dt, is_dt_nagetive) = i64::safe_subtract_u64(week_cursor, old_user_point.ts);

                let (bal, is_bal_negative) = i64::safe_sub(
                    i64::from_u64(old_user_point.bias, false),
                    i64::from_u64(dt * old_user_point.slope, is_dt_nagetive)
                );

                let balance_of = if (is_bal_negative) { 0 } else { bal };

                // Break if no balance and no more epochs
                if (balance_of == 0 && user_epoch > max_user_epoch) { break };

                let ve_supply = *table::borrow_with_default(&fee_dis.ve_supply, week_cursor, &0);
                // Calculate tokens to distribute
                if (balance_of > 0 && ve_supply > 0) {
                    let tokens_per_week = *table::borrow_with_default(&fee_dis.tokens_per_week, week_cursor, &0);

                    // converted into u256 for handle overflow issue
                    let to_distribute_internal: u256 = (balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256);
                    // to_distribute = to_distribute + (balance_of * tokens_per_week / ve_supply);
                    to_distribute = to_distribute + (to_distribute_internal as u64);

                    // Emit event for this week
                    event::emit(
                        WeeklyClaimedEvent {
                            recipient: token_owner,
                            token,
                            week: week_cursor,
                            amount: (to_distribute_internal as u64),
                            ts: current_timestamp
                        }
                    );
                };


                week_cursor = week_cursor + week;
            };
        };

        // Update user state
        user_epoch = i64::min(max_user_epoch, user_epoch - 1);
        table::upsert(&mut fee_dis.user_epoch_of, token, user_epoch);
        table::upsert(&mut fee_dis.time_cursor_of, token, week_cursor);

        // Emit Claimed event
        event::emit(
            ClaimedEvent {
                recipient: token_owner,
                token,
                amount: to_distribute,
                claim_epoch: user_epoch,
                max_epoch: max_user_epoch
            }
        );

        to_distribute
    }

    /// Distributes tokens to a user based on their voting power up to `last_token_time`.
    ///
    /// # Arguments
    /// * `fee_dis` - The FeeDistributor resource to update.
    /// * `token_owner` - The address of the token owner (the user).
    /// * `token` - The nft token address.
    /// * `last_token_time` - The end timestamp for the claim period (week-aligned).
    ///
    /// # Returns
    /// Total claimable amounts.
    /// Vector of WeeklyClaim structs for each week with claimable amounts.
    fun claimable_internal(
        fee_dis: &FeeDistributor, token: address, last_token_time: u64
    ): (u64, vector<WeeklyClaim>) {
        // Initialize variables
        let max_user_epoch = voting_escrow::user_point_epoch(token);

        let claimable: vector<WeeklyClaim> = vector::empty<WeeklyClaim>();
        let total_claimable: u64 = 0;

        // If user has no voting power, return 0
        if (max_user_epoch == 0) {
            return (total_claimable, claimable)
        };

        let start_time = fee_dis.start_time;

        // Get or initialize week cursor and user epoch
        let week_cursor = *table::borrow_with_default(&fee_dis.time_cursor_of, token, &0);
        let user_epoch = if (week_cursor == 0) {
            // First claim, find the epoch at start_time
            // Need to do the initial binary search
            find_timestamp_user_epoch(token, start_time, max_user_epoch)
        } else {
            *table::borrow_with_default(&fee_dis.user_epoch_of, token, &0)
        };

        // Ensure user_epoch is at least 1
        if (user_epoch == 0) {
            user_epoch = 1;
        };

        // Get the user's voting point at user_epoch
        let (bias, slope, blk, ts) = voting_escrow::user_point_history(token, user_epoch);
        let user_point = Point { slope, bias, ts, blk };
        let week = WEEK;

        // Initialize week cursor if needed
        if (week_cursor == 0) {
            week_cursor = round_to_week(user_point.ts + week - 1);
        };

        // Check if no tokens to claim
        if (week_cursor >= last_token_time) {
            return (total_claimable, claimable)
        };

        // Ensure week_cursor is not before start_time
        if (week_cursor < start_time) {
            week_cursor = start_time;
        };

        // Initialize old point
        let old_user_point = Point { slope: 0, bias: 0, ts: 0, blk: 0 };

        // Iterate till last_token_time
        loop {
            if (week_cursor >= last_token_time) { break };

            // Update epoch if week_cursor is past the current point's timestamp
            if (week_cursor >= user_point.ts && user_epoch <= max_user_epoch) {
                user_epoch = user_epoch + 1;
                old_user_point = user_point;

                if (user_epoch > max_user_epoch) {
                    // No more points, set to zero
                    user_point = Point { slope: 0, bias: 0, ts: 0, blk: 0 };
                } else {
                    // Get the next point
                    let (ibias, islope, iblk, its) =
                        voting_escrow::user_point_history(token, user_epoch);
                    user_point = Point { slope: islope, bias: ibias, ts: its, blk: iblk };
                };
            } else {
                // Calculate voting power at week_cursor
                let (dt, is_dt_nagetive) = i64::safe_subtract_u64(week_cursor, old_user_point.ts);

                let (bal, is_bal_negative) = i64::safe_sub(
                    i64::from_u64(old_user_point.bias, false),
                    i64::from_u64(dt * old_user_point.slope, is_dt_nagetive)
                );

                let balance_of = if (is_bal_negative) { 0 } else { bal };

                // Break if no balance and no more epochs
                if (balance_of == 0 && user_epoch > max_user_epoch) { break };

                let ve_supply = *table::borrow_with_default(&fee_dis.ve_supply, week_cursor, &0);
                // Calculate tokens to distribute
                if (balance_of > 0 && ve_supply > 0) {
                    let tokens_per_week = *table::borrow_with_default(&fee_dis.tokens_per_week, week_cursor, &0);

                    // converted into u256 for handle overflow issue
                    let to_distribute_internal: u256 = (balance_of as u256) * (tokens_per_week as u256) / (ve_supply as u256);

                    if (to_distribute_internal > 0) {
                        // to_distribute = to_distribute + (balance_of * tokens_per_week / ve_supply);
                        total_claimable = total_claimable + (to_distribute_internal as u64);

                        vector::push_back(&mut claimable, WeeklyClaim {
                            token,
                            week: week_cursor,
                            amount: (to_distribute_internal as u64),
                        });
                    };
                };

                week_cursor = week_cursor + week;
            };
        };

        (total_claimable, claimable)
    }

    /// Round a timestamp to the start of the week
    ///
    /// # Arguments
    /// * `timestamp` - The timestamp to round.
    fun round_to_week(timestamp: u64): u64 {
        timestamp / WEEK * WEEK
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    public fun initialize(res: &signer) {
        init_module(res);
    }

    #[test_only]
    public fun get_fee_distributor_state():
    (
        u64, // start_time
        u64, // time_cursor
        u64, // last_token_time
        u64, // coins balance
        u64, // total_received
        u64, // token_last_balance
        address, // admin
        address, // future_admin
        bool, // can_checkpoint_token
        address, // emergency_return
        bool // is_killed
    ) acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);
        (
            fee_dis.start_time,
            fee_dis.time_cursor,
            fee_dis.last_token_time,
            primary_fungible_store::balance(fee_dis_address, dxlyn_coin::get_dxlyn_asset_metadata()),
            fee_dis.total_received,
            fee_dis.token_last_balance,
            fee_dis.admin,
            fee_dis.future_admin,
            fee_dis.can_checkpoint_token,
            fee_dis.emergency_return,
            fee_dis.is_killed
        )
    }

    #[test_only]
    public fun get_tokens_per_week(_timestamp: u64): u64 acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);

        *table::borrow_with_default(
            &fee_dis.tokens_per_week, round_to_week(_timestamp), &0
        )
    }

    #[test_only]
    public fun get_ve_supply_at(_timestamp: u64): u64 acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);

        *table::borrow_with_default(&fee_dis.ve_supply, round_to_week(_timestamp), &0)
    }

    #[test_only]
    public fun get_user_epoch(token: address): u64 acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);

        *table::borrow_with_default(&fee_dis.user_epoch_of, token, &0)
    }

    #[test_only]
    public fun get_user_time_cursor_of(token: address): u64 acquires FeeDistributor {
        let fee_dis_address = get_fee_distributor_address();
        let fee_dis = borrow_global<FeeDistributor>(fee_dis_address);

        *table::borrow_with_default(&fee_dis.time_cursor_of, token, &0)
    }

    #[test_only]
    public fun convert_weekly_claim(weekly_claim: &WeeklyClaim): (address, u64, u64) {
        (weekly_claim.token, weekly_claim.week, weekly_claim.amount)
    }
}
