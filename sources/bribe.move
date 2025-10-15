module dexlyn_tokenomics::bribe {

    use std::bcs::to_bytes;
    use std::signer::address_of;
    use std::vector;
    use aptos_std::table::{Self, Table};

    use aptos_token_objects::token::Token;
    use supra_framework::event;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::object::{Self, ExtendRef, ObjectCore};
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::minter;

    friend dexlyn_tokenomics::voter;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator of the bribe system object address
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// Seed for creating the bribe system object, used in object address generation
    const BRIBE_SYSTEM_SEED: vector<u8> = b"BRIBE_SYSTEM";

    /// One week in seconds (7 days), used for epoch calculations
    const WEEK: u64 = 604800;

    /// Scaling factor (10^8) for precision in reward calculations
    const MULTIPLIER: u64 = 100000000;

    /// We are only allowing 50 weeks of rewards to be claimed, this is used to limit the number of epochs
    const FIFTY_WEEKS: u64 = 50;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Caller must have owner privileges
    const ERROR_NOT_OWNER: u64 = 101;

    /// Bribe already exists for the specified liquidity pool
    const ERROR_ALREADY_EXISTS: u64 = 102;

    /// Bribe does not exist for the specified liquidity pool
    const ERROR_BRIBE_NOT_EXIST: u64 = 103;

    /// Provided amount is invalid (e.g., zero or less than required)
    const ERROR_INVALID_AMOUNT: u64 = 104;

    /// Caller must be the designated voter
    const ERROR_NOT_VOTER: u64 = 105;

    /// Provided token is not a verified reward token
    const ERROR_TOKEN_NOT_VERIFIED: u64 = 106;

    /// Insufficient balance of the reward token for the operation
    const ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE: u64 = 107;

    /// Address must not be the zero address
    const ERROR_INVALID_ADDRESS: u64 = 108;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Event emitted when a reward is added to the bribe
    struct RewardAddedEvent has drop, store {
        user: address,
        pool: address,
        reward_token: address,
        reward: u64,
        start_timestamp: u64,
        timestamp: u64,
        gauge: address
    }

    #[event]
    /// Event emitted when a user stakes (deposits) voting power
    struct StakedEvent has drop, store {
        token_owner: address,
        token: address,
        amount: u64
    }

    #[event]
    /// Event emitted when a user withdraws voting power
    struct WithdrawnEvent has drop, store {
        token_owner: address,
        token: address,
        amount: u64
    }

    #[event]
    /// Event emitted when a user claims their rewards
    struct RewardPaidEvent has drop, store {
        user: address,
        reward_token: address,
        reward: u64,
        pool: address,
        ts: u64
    }

    #[event]
    /// Event emitted when a user claims their rewards for a week
    struct WeeklyPaidRewardEvent has drop, store {
        user: address,
        reward_token: address,
        reward: u64,
        pool: address,
        gauge: address,
        week: u64,
        ts: u64
    }

    #[event]
    /// Event emitted when tokens are recovered from the contract
    struct RecoveredEvent has drop, store {
        token: address,
        amount: u64
    }

    #[event]
    /// Event emitted when owner changed
    struct SetOwnerEvent has drop, store {
        old_owner: address,
        new_owner: address,
    }

    #[event]
    /// Event emitted when system owner changed
    struct SetSystemOwnerEvent has drop, store {
        old_owner: address,
        new_owner: address,
    }

    #[event]
    /// Event emitted when voter changed
    struct SetVoterEvent has drop, store {
        old_voter: address,
        new_voter: address
    }

    #[event]
    struct RewardTokenAddedEvent has drop, store {
        reward_token: address,
        pool: address,
        gauge: address
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Store reward data for each epoch
    struct Reward has store, drop {
        period_finish: u64,
        rewards_per_epoch: u64,
        last_update_time: u64
    }

    /// Bribe system data
    struct BribeSystem has key {
        owner: address,
        extended_ref: ExtendRef
    }

    /// Store individual bribe data
    struct Bribe has key {
        first_bribe_timestamp: u64,
        // token -> startTimestamp -> Reward
        reward_data: Table<address, Table<u64, Reward>>,
        // reward token -> isRewardToken
        is_reward_token: Table<address, bool>,
        reward_tokens: vector<address>,
        voter: address,
        owner: address,
        // owner -> reward token -> lastTime
        user_reward_per_token_paid: Table<address, Table<address, u64>>,
        // owner -> reward token -> lastTime
        user_timestamp: Table<address, Table<address, u64>>,
        // timestamp -> amount
        total_supply: Table<u64, u64>,
        // owner -> timestamp -> amount
        balance: Table<address, Table<u64, u64>>,
        extended_ref: ExtendRef,
        gauge_address: address
    }

    struct WeeklyPaidReward has store, drop, copy {
        user: address,
        reward_token: address,
        reward: u64,
        pool: address,
        gauge: address,
        // epoch for which the reward is paid (start timestamp)
        week: u64,
        ts: u64
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initializes the BribeSystem contract.
    ///
    /// # Arguments
    /// * `sender` - The signer creating the BribeSystem contract.
    public(friend) fun initialize(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, BRIBE_SYSTEM_SEED);

        let signer = object::generate_signer(&constructor_ref);

        let extended_ref = object::generate_extend_ref(&constructor_ref);

        move_to<BribeSystem>(
            &signer,
            BribeSystem { owner: @owner, extended_ref }
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Set a new voter
    ///
    /// # Arguments
    /// * `owner` - The signer who owns the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `new_voter` - Address of the new voter.
    public entry fun set_voter(
        owner: &signer, pool: address, new_voter: address
    ) acquires Bribe {
        assert!(new_voter != @0x0, ERROR_INVALID_ADDRESS);
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        event::emit(SetVoterEvent { old_voter: bribe.voter, new_voter });

        bribe.voter = new_voter;
    }

    /// Set a new owner
    ///
    /// # Arguments
    /// * `owner` - The current owner signer.
    /// * `pool` - the liquidity pool address.
    /// * `new_owner` - Address of the new owner.
    public entry fun set_owner(
        owner: &signer, pool: address, new_owner: address
    ) acquires Bribe {
        assert!(new_owner != @0x0, ERROR_INVALID_ADDRESS);
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        event::emit(SetOwnerEvent { old_owner: bribe.owner, new_owner });

        bribe.owner = new_owner;
    }

    /// Sets a new owner for the bribe system.
    ///
    /// # Arguments
    /// * `owner` - The current owner signer.
    /// * `new_owner` - Address of the new owner.
    ///
    /// # Dev
    /// Allows the current owner to transfer ownership of the bribe system.
    public entry fun set_bribe_sys_owner(
        owner: &signer, new_owner: address
    ) acquires BribeSystem {
        assert!(new_owner != @0x0, ERROR_INVALID_ADDRESS);

        let bribe_system_address = get_bribe_system_address();
        let bribe_sys = borrow_global_mut<BribeSystem>(bribe_system_address);

        assert!(address_of(owner) == bribe_sys.owner, ERROR_NOT_OWNER);

        event::emit(SetSystemOwnerEvent { old_owner: bribe_sys.owner, new_owner });

        bribe_sys.owner = new_owner;
    }

    /// Recover some bribe token from the contract and update the given bribe.
    ///
    /// # Arguments
    /// * `owner` - The signer who owns the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `reward_token` - Address of the reward token.
    /// * `token_amount` - Amount of the token to recover.
    ///
    /// # Dev
    /// Only the owner can recover tokens.
    public entry fun recover_and_update_data(
        owner: &signer,
        pool: address,
        reward_token: address,
        token_amount: u64
    ) acquires Bribe {
        let bribe_address = check_and_get_bribe_address(pool);
        let reward_asset = object::address_to_object<Metadata>(reward_token);
        let token_balance = primary_fungible_store::balance(bribe_address, reward_asset);

        assert!(token_amount <= token_balance, ERROR_INVALID_AMOUNT);

        // check bribe exist or not and get address
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        let start_timestamp = minter::active_period() + WEEK;

        let last_reward = reward_per_epoch_internal(&bribe.reward_data, reward_token, start_timestamp);

        if (table::contains(&bribe.reward_data, reward_token)) {
            let reward_token_timestamp = table::borrow_mut(&mut bribe.reward_data, reward_token);
            let reward_data = table::borrow_mut(reward_token_timestamp, start_timestamp);
            reward_data.rewards_per_epoch = last_reward - token_amount;
            reward_data.last_update_time = timestamp::now_seconds();

            // transfer token from resource account to owner
            let bribe_signer = object::generate_signer_for_extending(&bribe.extended_ref);
            primary_fungible_store::transfer(
                &bribe_signer,
                reward_asset,
                bribe.owner,
                token_amount
            );

            event::emit(
                RecoveredEvent { amount: token_amount, token: reward_token }
            );
        }
    }

    /// Recover some token from the contract.
    ///
    /// # Arguments
    /// * `owner` - The signer who owns the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `reward_token` - Address of the reward token.
    /// * `token_amount` - Amount of the token to recover.
    ///
    /// # Dev
    /// Be careful: if called, then `get_reward()` at last epoch will fail because some rewards are missing!
    /// Consider calling `recover_and_update_data()`.
    public entry fun emergency_recover(
        owner: &signer,
        pool: address,
        reward_token: address,
        token_amount: u64
    ) acquires Bribe {
        let bribe_address = check_and_get_bribe_address(pool);
        let reward_asset = object::address_to_object<Metadata>(reward_token);
        let token_balance = primary_fungible_store::balance(bribe_address, reward_asset);

        assert!(token_amount <= token_balance, ERROR_INVALID_AMOUNT);

        // check bribe exist or not and get address
        let bribe = borrow_global<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        // transfer token from resource account to owner
        let bribe_signer = object::generate_signer_for_extending(&bribe.extended_ref);
        primary_fungible_store::transfer(
            &bribe_signer,
            reward_asset,
            bribe.owner,
            token_amount
        );

        event::emit(
            RecoveredEvent { amount: token_amount, token: reward_token }
        );
    }

    /// Adds reward tokens for a bribe.
    ///
    /// # Arguments
    /// * `owner` - The signer who owns the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `reward_tokens` - Addresses of the reward tokens.
    ///
    /// # Dev
    /// Only the owner can add reward tokens.
    public entry fun add_reward_tokens(
        owner: &signer, pool: address, reward_tokens: vector<address>
    ) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        vector::for_each(reward_tokens, |reward_token| {
            add_reward_token_internal(bribe, reward_token, pool);
        });
    }

    /// Adds a reward token for a bribe.
    ///
    /// # Arguments
    /// * `owner` - The signer who owns the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `reward_token` - Address of the reward token.
    ///
    /// # Dev
    /// Only the owner can add a reward token.
    public entry fun add_reward_token(
        owner: &signer, pool: address, reward_token: address
    ) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(owner) == bribe.owner, ERROR_NOT_OWNER);

        add_reward_token_internal(bribe, reward_token, pool);
    }

    /// Creates a bribe for the given liquidity pool.
    ///
    /// # Arguments
    /// * `sender` - The signer creating the bribe.
    /// * `voter` - The address of the bribe voter.
    /// * `pool` - the liquidity pool address.
    ///
    /// # Dev
    /// Only the owner can create a bribe for the specified pool.
    // TODO: Pending implementation of add multiple default reward tokens like in thena bribe factory do
    public entry fun create_bribe(
        sender: &signer, voter: address, pool: address, gauge_address: address
    ) acquires BribeSystem {
        let bribe_system_address = get_bribe_system_address();
        let bribe_sys = borrow_global<BribeSystem>(bribe_system_address);
        let sender_address = address_of(sender);

        // only owner can create bribe
        assert!(bribe_sys.owner == sender_address, ERROR_NOT_OWNER);

        let bribe_sys_signer =
            object::generate_signer_for_extending(&bribe_sys.extended_ref);

        let pool_bytes = to_bytes(&pool);

        // always create bribe from bribe signer
        let new_bribe_address =
            object::create_object_address(&address_of(&bribe_sys_signer), pool_bytes);

        // check bribe created or not for given pool
        assert!(
            !object::object_exists<ObjectCore>(new_bribe_address),
            ERROR_ALREADY_EXISTS
        );

        let new_bribe_constructor_ref = object::create_named_object(
            &bribe_sys_signer, pool_bytes
        );

        let new_bribe_signer = object::generate_signer(&new_bribe_constructor_ref);

        let new_bribe_extended_ref =
            object::generate_extend_ref(&new_bribe_constructor_ref);

        move_to<Bribe>(
            &new_bribe_signer,
            Bribe {
                first_bribe_timestamp: 0,
                reward_data: table::new<address, Table<u64, Reward>>(),
                is_reward_token: table::new<address, bool>(),
                reward_tokens: vector<address>[],
                voter,
                owner: @owner,
                user_reward_per_token_paid: table::new<address, Table<address, u64>>(),
                user_timestamp: table::new<address, Table<address, u64>>(),
                total_supply: table::new<u64, u64>(),
                balance: table::new<address, Table<u64, u64>>(),
                extended_ref: new_bribe_extended_ref,
                gauge_address
            }
        );
    }

    /// User votes deposit on bribe using NFT token.
    ///
    /// # Arguments
    /// * `voter` - The voter signer.
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the token.
    /// * `amount` - Amount to deposit.
    ///
    /// # Dev
    /// Called on `voter.vote()` or `voter.poke()`.
    /// Owner must reset before transferring token.
    public entry fun deposit(
        voter: &signer, pool: address, token: address, amount: u64
    ) acquires Bribe {
        assert!(amount > 0, ERROR_INVALID_AMOUNT);

        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);
        let voter_address = address_of(voter);
        assert!(voter_address == bribe.voter, ERROR_NOT_VOTER);

        let start_timestamp = minter::active_period() + WEEK;
        let old_supply = table::borrow_with_default(&bribe.total_supply, start_timestamp, &0);
        let token_owner = object::owner(object::address_to_object<Token>(token));
        let last_balance = balance_of_owner_at_internal(&bribe.balance, token_owner, start_timestamp);

        // update total supply
        table::upsert(&mut bribe.total_supply, start_timestamp, *old_supply + amount);

        // update user timestamp balance
        if (table::contains(&bribe.balance, token_owner)) {
            let owner_timestamp_balance = table::borrow_mut(&mut bribe.balance, token_owner);
            table::upsert(owner_timestamp_balance, start_timestamp, last_balance + amount);
        } else {
            let owner_timestamp_balance: Table<u64, u64> = table::new<u64, u64>();
            table::add(&mut owner_timestamp_balance, start_timestamp, last_balance + amount);
            table::add(&mut bribe.balance, token_owner, owner_timestamp_balance);
        };

        event::emit(StakedEvent { token_owner, token, amount });
    }

    /// User votes withdrawal using NFT token.
    ///
    /// # Arguments
    /// * `voter` - The voter signer.
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the token.
    /// * `amount` - Amount to withdraw.
    ///
    /// # Dev
    /// Called on `voter.reset()`
    public entry fun withdraw(
        voter: &signer, pool: address, token: address, amount: u64
    ) acquires Bribe {
        assert!(amount > 0, ERROR_INVALID_AMOUNT);

        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);
        let voter_address = address_of(voter);
        assert!(voter_address == bribe.voter, ERROR_NOT_VOTER);

        let start_timestamp = minter::active_period() + WEEK;
        let token_owner = object::owner(object::address_to_object<Token>(token));
        let old_balance = balance_of_owner_at_internal(&bribe.balance, token_owner, start_timestamp);

        if (amount <= old_balance) {
            let old_supply = table::borrow_with_default(&bribe.total_supply, start_timestamp, &0);

            // update total supply
            table::upsert(&mut bribe.total_supply, start_timestamp, *old_supply - amount);

            // update user timestamp balance
            if (table::contains(&bribe.balance, token_owner)) {
                let owner_timestamp_balance = table::borrow_mut(&mut bribe.balance, token_owner);
                table::upsert(owner_timestamp_balance, start_timestamp, old_balance - amount);
            } else {
                let owner_timestamp_balance: Table<u64, u64> = table::new<u64, u64>();
                table::add(&mut owner_timestamp_balance, start_timestamp, old_balance - amount);
                table::add(&mut bribe.balance, token_owner, owner_timestamp_balance);
            };

            event::emit(WithdrawnEvent { token_owner, token, amount });
        }
    }

    /// Claim rewards for a list of reward tokens.
    ///
    /// # Arguments
    /// * `owner` - signer of the user
    /// * `pool` - the liquidity pool address.
    /// * `reward_token` - address of the reward token
    public entry fun get_reward(
        owner: &signer, pool: address, reward_tokens: vector<address>
    ) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);
        let owner_address = address_of(owner);

        vector::for_each(reward_tokens, |reward_token| {
            get_reward_internal(
                bribe,
                bribe_address,
                owner_address,
                reward_token,
                pool
            );
        });
    }

    /// Claims rewards for a specific token owner.
    ///
    /// # Arguments
    /// * `voter` - The voter signer.
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the nft token.
    /// * `reward_token` - Address of the reward token.
    public entry fun get_reward_for_token_owner(
        _caller: &signer,
        pool: address,
        token: address,
        reward_tokens: vector<address>
    ) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        let token_owner = object::owner(object::address_to_object<Token>(token));

        vector::for_each(reward_tokens, |reward_token| {
            get_reward_internal(bribe, bribe_address, token_owner, reward_token, pool);
        });
    }

    /// Voter claims rewards for a specific address.
    ///
    /// # Arguments
    /// * `voter` - The voter signer.
    /// * `pool` - the liquidity pool address.
    /// * `owner` - Address of the owner.
    /// * `reward_token` - Address of the reward token.
    public entry fun get_reward_for_address(
        voter: &signer,
        pool: address,
        owner: address,
        reward_tokens: vector<address>
    ) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        assert!(address_of(voter) == bribe.voter, ERROR_NOT_VOTER);

        vector::for_each(reward_tokens, |reward_token| {
            get_reward_internal(bribe, bribe_address, owner, reward_token, pool);
        });
    }

    /// Notify a bribe amount.
    ///
    /// # Arguments
    /// * `sender` - The signer notifying the bribe.
    /// * `pool` - the liquidity pool address.
    /// * `reward_token` - Address of the reward token.
    /// * `reward` - Amount of the reward.
    ///
    /// # Dev
    /// Rewards are saved into NEXT EPOCH mapping.
    public entry fun notify_reward_amount(
        sender: &signer,
        pool: address,
        reward_token: address,
        reward: u64
    ) acquires Bribe {
        let reward_asset = object::address_to_object<Metadata>(reward_token);
        let sender_address = address_of(sender);
        assert!(
            primary_fungible_store::balance(sender_address, reward_asset) >= reward,
            ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE
        );

        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        // Check whether token is reward token or not
        assert!(*table::borrow_with_default(&bribe.is_reward_token, reward_token, &false), ERROR_TOKEN_NOT_VERIFIED);

        // transfer reward token to resource account
        primary_fungible_store::transfer(sender, reward_asset, bribe_address, reward);

        // period points to the current thursday. Bribes are distributed from next epoch (thursday)
        let week = WEEK;
        let current_timestamp = timestamp::now_seconds();
        let start_timestamp = minter::active_period() + week;

        if (bribe.first_bribe_timestamp == 0) {
            bribe.first_bribe_timestamp = start_timestamp;
        };

        let last_reward = reward_per_epoch_internal(&bribe.reward_data, reward_token, start_timestamp);

        if (table::contains(&bribe.reward_data, reward_token)) {
            let reward_token_timestamp = table::borrow_mut(&mut bribe.reward_data, reward_token);
            table::upsert(
                reward_token_timestamp,
                start_timestamp,
                Reward {
                    last_update_time: current_timestamp,
                    period_finish: start_timestamp + week,
                    rewards_per_epoch: last_reward + reward
                }
            );
        } else {
            let reward_token_timestamp = table::new<u64, Reward>();
            table::add(
                &mut reward_token_timestamp,
                start_timestamp,
                Reward {
                    last_update_time: current_timestamp,
                    period_finish: start_timestamp + week,
                    rewards_per_epoch: last_reward + reward
                }
            );
            table::add(&mut bribe.reward_data, reward_token, reward_token_timestamp);
        };

        event::emit(
            RewardAddedEvent {
                user: sender_address,
                pool,
                reward,
                reward_token,
                start_timestamp,
                timestamp: current_timestamp,
                gauge: bribe.gauge_address
            }
        )
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get the address of the bribe system
    ///
    /// # Returns
    /// The address of the bribe system
    public fun get_bribe_system_address(): address {
        object::create_object_address(&SC_ADMIN, BRIBE_SYSTEM_SEED)
    }

    #[view]
    /// Returns the bribe address associated with a specific liquidity pool.
    ///
    /// # Arguments
    /// * `pool` - The liquidity pool address for which to retrieve the bribe address.
    ///
    /// # Returns
    /// * The bribe address associated with the liquidity pool.
    public fun get_bribe_address(pool: address): address {
        let bribe_system_address = get_bribe_system_address();
        let pool_bytes = to_bytes(&pool);
        let bribe_address = object::create_object_address(&bribe_system_address, pool_bytes);
        bribe_address
    }

    #[view]
    /// Returns the bribe address for a given liquidity pool token.
    ///
    /// # Arguments
    /// * `pool` - The liquidity pool address for which to retrieve and check the bribe address.
    ///
    /// # Returns
    /// * The bribe address associated with the liquidity pool.
    ///
    /// # Dev
    /// Checks if the bribe exists for the given pool address.
    public fun check_and_get_bribe_address(pool: address): address {
        let bribe_system_address = get_bribe_system_address();
        let pool_bytes = to_bytes(&pool);
        let bribe_address = object::create_object_address(&bribe_system_address, pool_bytes);

        // check bribe created or not for lp token
        assert!(
            object::object_exists<ObjectCore>(bribe_address),
            ERROR_BRIBE_NOT_EXIST
        );
        bribe_address
    }

    #[view]
    /// Returns the current epoch.
    ///
    /// # Returns
    /// * The current epoch.
    public fun get_epoch_start(): u64 {
        minter::active_period()
    }

    #[view]
    /// Returns the next epoch start timestamp (where bribes are saved).
    ///
    /// # Returns
    /// * `u64` - The next epoch start timestamp.
    public fun get_next_epoch_start(): u64 {
        get_epoch_start() + WEEK
    }

    #[view]
    /// Get the length of the reward tokens
    ///
    /// # Arguments
    /// * `pool` - The liquidity pool address.
    ///
    /// # Returns
    /// Length of the reward tokens
    ///
    /// # Dev
    /// Checks if bribe exists or not
    public fun rewards_list_length(pool: address): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        vector::length(&bribe.reward_tokens)
    }

    #[view]
    /// Returns the last total supply (total votes for a pool).
    ///
    /// # Arguments
    /// * `pool` - The liquidity pool address.
    ///
    /// # Returns
    /// * `u64` - total supply of the current epoch.
    public fun total_supply(pool: address): u64 acquires Bribe {
        // equivalent to IMinter.active_period()
        let current_epoch_start = minter::active_period();
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        *table::borrow_with_default(&bribe.total_supply, current_epoch_start, &0)
    }

    #[view]
    /// Get a total supply given a timestamp
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address
    /// * `timestamp` - timestamp to get the total supply
    ///
    /// # Returns
    /// total supply of the given timestamp
    public fun total_supply_at(pool: address, timestamp: u64): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        *table::borrow_with_default(&bribe.total_supply, timestamp, &0)
    }

    #[view]
    /// Get the balance of an token owner in the current epoch.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the token.
    ///
    /// # Returns
    /// Balance of the token owner.
    public fun balance_of(pool: address, token: address): u64 acquires Bribe {
        let timestamp = get_next_epoch_start();
        let token_owner = object::owner(object::address_to_object<Token>(token));
        balance_of_owner_at(pool, token_owner, timestamp)
    }

    #[view]
    /// Get the balance of an token owner given a timestamp.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the token.
    /// * `timestamp` - Timestamp to get the balance.
    ///
    /// # Returns
    /// Balance of the token owner.
    public fun balance_of_at(
        pool: address, token: address, timestamp: u64
    ): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        let token_owner = object::owner(object::address_to_object<Token>(token));
        balance_of_owner_at_internal(&bribe.balance, token_owner, timestamp)
    }

    #[view]
    /// Get the balance of an owner in the current epoch.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `owner` - Address of the owner.
    ///
    /// # Returns
    /// Balance of the owner.
    public fun balance_of_owner(pool: address, owner: address): u64 acquires Bribe {
        let timestamp = get_next_epoch_start();
        balance_of_owner_at(pool, owner, timestamp)
    }

    #[view]
    /// Get the balance of an owner given a timestamp.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `owner` - Address of the owner.
    /// * `timestamp` - Timestamp to get the balance.
    ///
    /// # Returns
    /// Balance of the owner.
    public fun balance_of_owner_at(
        pool: address, owner: address, timestamp: u64
    ): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        balance_of_owner_at_internal(&bribe.balance, owner, timestamp)
    }

    #[view]
    /// Get the earned rewards using token.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `token` - Address of the token.
    /// * `reward_token` - Address of the reward token.
    ///
    /// # Returns
    /// (Total earned rewards, List of weekly paid rewards)
    public fun earned_from_token(
        pool: address, token: address, reward_token: address
    ): (u64, vector<WeeklyPaidReward>) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        let token_owner = object::owner(object::address_to_object<Token>(token));
        earned_internal_view(bribe, token_owner, reward_token, pool)
    }

    #[view]
    /// Get the earned rewards of an owner.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `owner` - Address of the owner.
    /// * `reward_token` - Address of the reward token.
    ///
    /// # Returns
    /// (Total earned rewards, List of weekly paid rewards)
    public fun earned(
        pool: address, owner: address, reward_token: address
    ): (u64, vector<WeeklyPaidReward>) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);
        earned_internal_view(bribe, owner, reward_token, pool)
    }

    #[view]
    /// Get the earned rewards of an owner for multiple pools.
    ///
    /// # Arguments
    /// * `pools` - List of liquidity pool addresses.
    /// * `owner` - Address of the owner.
    /// * `reward_token` - Address of the reward token.
    ///
    /// # Returns
    /// (Total earned rewards across all pools, List of weekly paid rewards for each pool)
    public fun earned_many(
        pools: vector<address>, owner: address, reward_token: address
    ): (u64, vector<vector<WeeklyPaidReward>>) acquires Bribe {
        let result = vector::empty<vector<WeeklyPaidReward>>();
        let total_earned = 0;

        vector::for_each(pools, |pool| {
            // check bribe exist or not and get address
            let (total, weekly_earned) = earned(pool, owner, reward_token);
            total_earned = total_earned + total;
            vector::push_back(&mut result, weekly_earned);
        });
        (total_earned, result)
    }

    #[view]
    /// Read earned amount given address and reward token, returns the rewards and the last user timestamp (used in case user do not claim since 50+ epochs)
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `owner` - address of the owner
    /// * `reward_token` - address of the reward token
    ///
    /// # Returns
    /// (earned rewards, last user timestamp)
    public fun earned_with_timestamp(
        pool: address, owner: address, reward_token: address
    ): (u64, u64) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);

        earned_with_timestamp_internal(bribe, owner, reward_token, pool, false)
    }

    #[view]
    /// Returns the rewards for a given token.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `timestamp` - Timestamp to get the reward.
    /// * `reward_token` - Address of the reward token.
    ///
    /// # Returns
    /// * Reward per token.
    public fun reward_per_token(
        pool: address, timestamp: u64, reward_token: address
    ): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);

        reward_per_token_internal(bribe, timestamp, reward_token)
    }

    #[view]
    /// Returns the list of reward tokens for a given liquidity pool.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    ///
    /// # Returns
    /// * List of reward token addresses.
    public fun reward_token_list(
        pool: address
    ): vector<address> acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);

        bribe.reward_tokens
    }

    #[view]
    /// Returns the remaining bribe claim calls for a given liquidity pool.
    ///
    /// # Arguments
    /// * `pool` - the liquidity pool address.
    /// * `token` - the token address.
    /// * `reward_token` - the reward token address.
    ///
    /// # Returns
    /// * The remaining bribe claim calls.
    public fun get_remaining_bribe_claim_calls(
        pool: address,
        token: address,
        reward_token: address
    ): u64 acquires Bribe {
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global<Bribe>(bribe_address);

        let token_owner = object::owner(object::address_to_object<Token>(token));

        // claim until current epoch
        let user_last_time = user_last_reward_timestamp_internal(&bribe.user_timestamp, token_owner, reward_token);

        // if user first time then set it to first bribe - week to avoid any timestamp problem
        if (user_last_time < bribe.first_bribe_timestamp) {
            user_last_time = bribe.first_bribe_timestamp - WEEK;
        };
        let end_timestamp = minter::active_period();

        let unclaimed_epochs = (end_timestamp - user_last_time) / WEEK;

        (unclaimed_epochs + 49) / FIFTY_WEEKS
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Internal function to add a reward token to the bribe
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `reward_token` - Address of the reward token
    fun add_reward_token_internal(
        bribe: &mut Bribe, reward_token: address, pool: address
    ) {
        // Check whether token is reward token or not
        if (!*table::borrow_with_default(&bribe.is_reward_token, reward_token, &false)) {
            table::add(&mut bribe.is_reward_token, reward_token, true);
            vector::push_back(&mut bribe.reward_tokens, reward_token);

            event::emit(RewardTokenAddedEvent {
                pool,
                reward_token,
                gauge: bribe.gauge_address
            })
        }
    }

    /// Internal function to get rewards for a user
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `bribe_address` - Address of the bribe account
    /// * `owner_address` - Address of the owner
    /// * `reward_token` - Address of the reward token
    fun get_reward_internal(
        bribe: &mut Bribe,
        bribe_address: address,
        owner_address: address,
        reward_token: address,
        pool: address
    ) {
        let (reward, user_last_time) = earned_with_timestamp_internal(bribe, owner_address, reward_token, pool, true);

        if (reward > 0) {
            let reward_asset = object::address_to_object<Metadata>(reward_token);
            assert!(
                primary_fungible_store::balance(bribe_address, reward_asset) >= reward,
                ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE
            );
            let bribe_signer = object::generate_signer_for_extending(&bribe.extended_ref);
            primary_fungible_store::transfer(
                &bribe_signer,
                reward_asset,
                owner_address,
                reward
            );
            event::emit(
                RewardPaidEvent {
                    user: owner_address,
                    reward,
                    reward_token,
                    pool,
                    ts: timestamp::now_seconds()
                }
            );
        };

        if (table::contains(&bribe.user_timestamp, owner_address)) {
            let owner_reward_last_timestamp = table::borrow_mut(&mut bribe.user_timestamp, owner_address);
            table::upsert(owner_reward_last_timestamp, reward_token, user_last_time);
        } else {
            let owner_reward_last_timestamp: Table<address, u64> = table::new<address, u64>();
            table::add(&mut owner_reward_last_timestamp, reward_token, user_last_time);
            table::add(&mut bribe.user_timestamp, owner_address, owner_reward_last_timestamp);
        };
    }

    /// Internal function to calculate earned rewards
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `owner` - Address of the owner
    /// * `reward_token` - Address of the reward token
    /// * `pool` - Address of the pool
    ///
    /// # Returns
    /// (Total earned rewards, List of weekly paid rewards)
    fun earned_internal_view(
        bribe: &Bribe,
        owner: address,
        reward_token: address,
        pool: address
    ): (u64, vector<WeeklyPaidReward>) {
        // claim until current epoch
        let user_last_time = user_last_reward_timestamp_internal(&bribe.user_timestamp, owner, reward_token);
        let end_timestamp = minter::active_period();
        let rewards: vector<WeeklyPaidReward> = vector[];
        let total_rewards = 0;

        if (end_timestamp == user_last_time) {
            return (total_rewards, rewards)
        };

        let week = WEEK;

        // if user first time then set it to first bribe - week to avoid any timestamp problem
        if (user_last_time < bribe.first_bribe_timestamp) {
            user_last_time = bribe.first_bribe_timestamp - week;
        };

        let current_timestamp = timestamp::now_seconds();

        loop {
            if (user_last_time == end_timestamp) {
                // if we reach the current epoch, exit
                break
            };

            let week_reward = earned_internal(bribe, owner, user_last_time, reward_token);
            if (week_reward > 0) {
                total_rewards = total_rewards + week_reward;
                vector::push_back(&mut rewards, WeeklyPaidReward {
                    user: owner,
                    reward_token,
                    reward: week_reward,
                    pool,
                    gauge: bribe.gauge_address,
                    week: user_last_time,
                    ts: current_timestamp
                });
            };

            user_last_time = user_last_time + week;
        };

        return (total_rewards, rewards)
    }

    /// Internal function to calculate earned rewards with timestamp
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `owner` - Address of the owner
    /// * `reward_token` - Address of the reward token
    /// * `pool` - Address of the pool
    /// * `is_event_emit` - Whether to emit events or not
    ///
    /// # Returns
    /// (Total earned rewards, Last user timestamp)
    fun earned_with_timestamp_internal(
        bribe: &Bribe, owner: address, reward_token: address, pool: address, is_event_emit: bool
    ): (u64, u64) {
        // claim until current epoch
        let user_last_time = user_last_reward_timestamp_internal(&bribe.user_timestamp, owner, reward_token);
        let week = WEEK;

        // if user first time then set it to first bribe - week to avoid any timestamp problem
        if (user_last_time < bribe.first_bribe_timestamp) {
            user_last_time = bribe.first_bribe_timestamp - week;
        };

        let reward = 0;
        let end_timestamp = minter::active_period();
        let current_timestamp = timestamp::now_seconds();
        for (i in 0..FIFTY_WEEKS) {
            if (user_last_time == end_timestamp) {
                // if we reach the current epoch, exit
                break
            };

            let week_reward = earned_internal(bribe, owner, user_last_time, reward_token);
            if (is_event_emit) {
                event::emit(WeeklyPaidRewardEvent {
                    user: owner,
                    reward_token,
                    reward: week_reward,
                    pool,
                    gauge: bribe.gauge_address,
                    week: user_last_time,
                    ts: current_timestamp
                });
            };

            reward = reward + week_reward;
            user_last_time = user_last_time + week;
        };

        (reward, user_last_time)
    }

    /// Internal function to calculate reward per token
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `timestamp` - Timestamp to get the reward
    /// * `reward_token` - Address of the reward token
    ///
    /// # Returns
    /// * Reward per token
    fun reward_per_token_internal(
        bribe: &Bribe, timestamp: u64, reward_token: address
    ): u64 {
        let total_supply = table::borrow_with_default(&bribe.total_supply, timestamp, &0);
        let reward_per_epoch = reward_per_epoch_internal(&bribe.reward_data, reward_token, timestamp);

        if (*total_supply == 0) {
            return reward_per_epoch
        };

        // calculation may lose precision in some case
        (reward_per_epoch * MULTIPLIER) / *total_supply
    }

    /// Internal function to calculate earned rewards for a user
    ///
    /// # Arguments
    /// * `bribe` - Reference to the Bribe object
    /// * `owner` - Address of the owner
    /// * `timestamp` - Timestamp to get the rewards
    /// * `reward_token` - Address of the reward token
    ///
    /// # Returns
    /// Earned rewards for the user
    fun earned_internal(
        bribe: &Bribe,
        owner: address,
        timestamp: u64,
        reward_token: address
    ): u64 {
        let balance = balance_of_owner_at_internal(&bribe.balance, owner, timestamp);
        if (balance == 0) { 0 }
        else {
            let reward_per_token = reward_per_token_internal(bribe, timestamp, reward_token);

            // calculation may lose precision in some case
            let rewards = (reward_per_token * balance) / MULTIPLIER;
            rewards
        }
    }

    /// Internal function to get the balance of an owner at a specific timestamp
    ///
    /// # Arguments
    /// * `balance` - Reference to the balance table
    /// * `owner` - Address of the owner
    /// * `timestamp` - Timestamp to get the balance
    ///
    /// # Returns
    /// Balance of the owner at the specified timestamp
    fun balance_of_owner_at_internal(
        balance: &Table<address, aptos_std::table::Table<u64, u64>>,
        owner: address,
        timestamp: u64
    ): u64 {
        if (table::contains(balance, owner)) {
            let owner_balance = table::borrow(balance, owner);
            *table::borrow_with_default(owner_balance, timestamp, &0)
        } else { 0 }
    }

    /// Internal function to get the reward per epoch for a given reward token and timestamp
    ///
    /// # Arguments
    /// * `reward_data` - Reference to the reward data table
    /// * `reward_token` - Address of the reward token
    /// * `timestamp` - Timestamp to get the reward per epoch
    ///
    /// # Returns
    /// Reward per epoch for the specified reward token and timestamp
    fun reward_per_epoch_internal(
        reward_data: &Table<address, Table<u64, Reward>>,
        reward_token: address,
        timestamp: u64
    ): u64 {
        if (table::contains(reward_data, reward_token)) {
            let reward_token_timestamp = table::borrow(reward_data, reward_token);
            table::borrow_with_default(
                reward_token_timestamp,
                timestamp,
                &Reward { last_update_time: 0, period_finish: 0, rewards_per_epoch: 0 }
            ).rewards_per_epoch
        } else { 0 }
    }

    /// Internal function to get the last reward timestamp for a user and reward token
    ///
    /// # Arguments
    /// * `user_timestamp` - Reference to the user timestamp table
    /// * `owner` - Address of the owner
    /// * `reward_token` - Address of the reward token
    ///
    /// # Returns
    /// Last reward timestamp for the specified user and reward token
    fun user_last_reward_timestamp_internal(
        user_timestamp: &Table<address, Table<address, u64>>,
        owner: address,
        reward_token: address
    ): u64 {
        if (table::contains(user_timestamp, owner)) {
            let user_timestamp_internal = table::borrow(user_timestamp, owner);
            *table::borrow_with_default(user_timestamp_internal, reward_token, &0)
        } else { 0 }
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    public fun test_initialize(sender: &signer) {
        initialize(sender);
    }

    #[test_only]
    public fun get_bribe_state(pool: address): (u64, address, address) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);

        (bribe.first_bribe_timestamp, bribe.owner, bribe.voter)
    }

    #[test_only]
    public fun get_token_data(
        pool: address, reward_token: address
    ): (bool, bool) acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);
        let is_added =
            *table::borrow_with_default(&bribe.is_reward_token, reward_token, &false);
        let is_contain_in_list = vector::contains(&bribe.reward_tokens, &reward_token);
        (is_added, is_contain_in_list)
    }

    #[test_only]
    public fun earned_at_time(
        pool: address,
        owner: address,
        timestamp: u64,
        reward_token: address
    ): u64 acquires Bribe {
        // check bribe exist or not and get address
        let bribe_address = check_and_get_bribe_address(pool);
        let bribe = borrow_global_mut<Bribe>(bribe_address);
        let balance = balance_of_owner_at_internal(&bribe.balance, owner, timestamp);
        if (balance == 0) { 0 }
        else {
            let reward_per_token =
                reward_per_token_internal(bribe, timestamp, reward_token);

            // calculation may lose precision in some case
            let rewards = reward_per_token * balance / MULTIPLIER;
            rewards
        }
    }

    #[test_only]
    public fun get_week_reward_data(week_reward: &WeeklyPaidReward): (u64, u64) {
        (week_reward.week, week_reward.reward)
    }
}
