module dexlyn_tokenomics::gauge_clmm {
    use std::bcs;
    use std::signer::address_of;
    use std::vector;
    use aptos_std::math64;
    use aptos_std::table::{Self, Table};

    use aptos_token_objects::token::Token;
    use dexlyn_clmm::position_nft;
    use dexlyn_coin::dxlyn_coin;
    use supra_framework::event;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::object::{Self, address_to_object, ExtendRef, object_address};
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    friend dexlyn_tokenomics::voter;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator address of the GaugeClmm system.
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// Seeds for the GaugeClmm system, used to create a unique address for the gauge system
    const GAUGE_SYSTEM_SEEDS: vector<u8> = b"GAUGE_CLMM_SYSTEM";

    /// One week in seconds (7 days)
    const WEEK: u64 = 604800;

    /// 1 DXLYN_DECIMAL in smallest unit (10^8), for token amount scaling
    const DXLYN_DECIMAL: u64 = 100_000_000;

    /// Precision factor for reward calculations, used to prevent overflow and maintain precision
    const PRECISION: u256 = 100_00;

    /// Emergency mode active
    const EMERGENCY_MODE_ACTIVE: u8 = 1;
    /// Emergency mode inactive
    const EMERGENCY_MODE_INACTIVE: u8 = 0;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Gauge does not exist
    const ERROR_GAUGE_NOT_EXIST: u64 = 101;

    /// Gauge already exists
    const ERROR_GAUGE_ALREADY_EXIST: u64 = 102;

    /// Caller is not the owner of the gauge system
    const ERROR_NOT_OWNER: u64 = 103;

    /// Zero address (0x0) is not allowed
    const ERROR_ZERO_ADDRESS: u64 = 104;

    /// New address cannot be the same as the current address
    const ERROR_SAME_ADDRESS: u64 = 105;

    /// Gauge is already in this mode
    const ERROR_ALREADY_IN_THIS_MODE: u64 = 106;

    /// Gauge is not in emergency mode
    const ERROR_NOT_IN_EMERGENCY_MODE: u64 = 107;

    /// Amount must be greater than zero
    const ERROR_AMOUNT_MUST_BE_GREATER_THEN_ZERO: u64 = 108;

    /// Invalid LP token provided
    const ERROR_INVALID_LP_TOKEN_PROVIDED: u64 = 109;

    /// Withdraw and harvest are not allowed in emergency mode
    const ERROR_IN_EMERGENCY_MODE: u64 = 110;

    /// Insufficient balance for withdraw or harvest
    const ERROR_INSUFFICIENT_BALANCE: u64 = 111;

    /// Caller is not the distributor of the contract
    const ERROR_NOT_DISTRIBUTION: u64 = 112;

    /// Reward amount too high, may cause overflow
    const ERROR_REWARD_TOO_HIGH: u64 = 113;

    /// Unauthorized withdrawal
    const ERROR_INVALID_TOKEN_OWNER: u64 = 114;

    /// Invalid token (NFT)
    const ERROR_INVALID_TOKEN: u64 = 115;

    /// Unauthorized action
    const ERROR_UNAUTHORIZED_USER: u64 = 116;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Emits when an emergency mode is changed for a gauge
    struct EmergencyModeChangedEvent has store, drop {
        gauge: address,
        mode: u8,
        timestamp: u64
    }

    #[event]
    /// Emits when a deposit is made into the gauge
    struct DepositEvent has store, drop {
        user: address,
        amount: u128,
        gauge: address,
        pool: address,
        timestamp: u64,
        token: address
    }

    #[event]
    /// Emits when a withdrawal is made from the gauge
    struct WithdrawEvent has store, drop {
        user: address,
        amount: u128,
        gauge: address,
        pool: address,
        timestamp: u64,
        token: address
    }

    #[event]
    /// Emits when a user harvests rewards from the gauge
    struct HarvestEvent has store, drop {
        pool: address,
        gauge: address,
        user: address,
        reward: u64,
        timestamp: u64
    }

    #[event]
    /// Emits when a reward is added to the gauge
    struct RewardAddedEvent has store, drop {
        gauge_address: address,
        reward: u64,
        timestamp: u64
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// The GaugeClmmSystem struct holds the owner address and an extend reference for the gauge system.
    struct GaugeClmmSystem has key {
        owner: address,
        extend_ref: ExtendRef
    }

    /// The GaugeClmm struct represents a gauge for liquidity providers, holding various parameters and state.
    struct GaugeClmm has key {
        // Indicates if the gauge is in emergency mode
        emergency: bool,
        // The address of the reward token (DXLYN)
        reward_token: address,
        // The address of the distribution contract
        distribution: address,
        // The address of the external bribe contract
        external_bribe: address,
        // The duration of the reward period in seconds
        duration: u64,
        // The timestamp when the current reward period finishes
        period_finish: u64,
        // The current reward rate per second
        reward_rate: u256,
        // The last time the rewards were updated
        last_update_time: u64,
        // The total reward per token stored, used for calculating user rewards
        reward_per_token_stored: u256,
        // A mapping of user addresses to the last reward per token they were paid
        user_reward_per_token_paid: Table<address, u256>,
        // A mapping of user addresses to their accumulated rewards
        rewards: Table<address, u64>,
        // The total supply of LP tokens staked in this gauge
        total_supply: u128,
        // A mapping of user addresses to their staked balances in this gauge
        balances: Table<address, u128>,
        // An extend reference for the gauge, used for object management
        extend_ref: ExtendRef,
        // The pool address
        pool: address,
        // user address -> [tokens addresses]
        user_tokens: Table<address, vector<address>>
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    public(friend) fun initialize(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, GAUGE_SYSTEM_SEEDS);

        let extend_ref = object::generate_extend_ref(&constructor_ref);

        let gauge_sys_signer = object::generate_signer_for_extending(&extend_ref);

        move_to(
            &gauge_sys_signer,
            GaugeClmmSystem { owner: @owner, extend_ref }
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Sets the distribution address for a gauge.
    ///
    /// # Arguments
    /// * `owner` - The signer who is the owner of the gauge system.
    /// * `gauge_address` - The gauge address to set the distribution address.
    /// * `new_distribution` - The new distribution address to set.
    ///
    public entry fun set_distribution(
        owner: &signer, gauge_address: address, new_distribution: address
    ) acquires GaugeClmmSystem, GaugeClmm {
        // Validate owner
        assert!(new_distribution != @0x0, ERROR_ZERO_ADDRESS);
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);

        let gauge_system_address = get_gauge_system_address();
        let gauge_sys = borrow_global<GaugeClmmSystem>(gauge_system_address);
        assert!(address_of(owner) == gauge_sys.owner, ERROR_NOT_OWNER);

        // Validate and get the gauge
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);
        assert!(new_distribution != gauge.distribution, ERROR_SAME_ADDRESS);
        gauge.distribution = new_distribution;
    }


    /// Update the emergency mode for a gauge.
    ///
    /// # Arguments
    /// * `owner` - Signer who owns the gauge system.
    /// * `gauge_address` - Address of the gauge to update emergency mode.
    /// * `mode` - `true` to activate, `false` to deactivate emergency mode.
    public entry fun update_emergency_mode(
        owner: &signer, gauge_address: address, mode: bool
    ) acquires GaugeClmmSystem, GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);

        let gauge_system_address = get_gauge_system_address();
        let gauge_sys = borrow_global<GaugeClmmSystem>(gauge_system_address);
        assert!(address_of(owner) == gauge_sys.owner, ERROR_NOT_OWNER);

        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);

        // Mode must be different to change
        assert!(mode != gauge.emergency, ERROR_ALREADY_IN_THIS_MODE);
        gauge.emergency = mode;

        let mode = if (mode) { EMERGENCY_MODE_ACTIVE } else { EMERGENCY_MODE_INACTIVE };

        event::emit(
            EmergencyModeChangedEvent { gauge: gauge_address, mode, timestamp: timestamp::now_seconds() }
        );
    }

    /// Deposits a specified amount of LP tokens into the gauge.
    ///
    /// # Arguments
    /// * `user` - The signer representing the user depositing LP tokens.
    /// * `gauge_address` - The gauge address where LP tokens need to be deposited.
    /// * `token_address` - The token address.
    public entry fun deposit(
        user: &signer, gauge_address: address, token_address: address
    ) acquires GaugeClmm {
        // Check token owner
        let user_address = address_of(user);
        let token_object = address_to_object<Token>(token_address);
        assert!(object::is_owner(token_object, user_address), ERROR_INVALID_TOKEN_OWNER);

        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);
        assert!(!gauge.emergency, ERROR_IN_EMERGENCY_MODE);

        // Check validate token
        assert!(position_nft::is_valid_nft(token_address, gauge.pool), ERROR_INVALID_TOKEN);

        let liquidity = get_liquidity(gauge.pool, token_address);
        assert!(liquidity > 0, ERROR_AMOUNT_MUST_BE_GREATER_THEN_ZERO);

        //update global and user reward history
        update_reward(gauge, user_address);

        //update user balance
        let balance = table::borrow_mut_with_default(&mut gauge.balances, user_address, 0);
        *balance = *balance + liquidity;

        //update total supply
        gauge.total_supply = gauge.total_supply + liquidity;

        // Add token with user to validate user
        let tokens = table::borrow_mut_with_default(&mut gauge.user_tokens, user_address, vector[]);
        vector::push_back(tokens, token_address);

        object::transfer(user, token_object, gauge_address);

        event::emit(DepositEvent {
            user: user_address,
            amount: liquidity,
            gauge: gauge_address,
            pool: gauge.pool,
            token: token_address,
            timestamp: timestamp::now_seconds()
        });
    }

    /// Withdraw a certain amount of LP token.
    ///
    /// # Arguments
    /// * `user` - The signer representing the user withdrawing LP tokens.
    /// * `gauge_address` - The gauge address from where LP tokens need to be withdrawn.
    /// * `token_address` - The token_address
    public entry fun withdraw(
        user: &signer, gauge_address: address, token_address: address
    ) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);
        assert!(!gauge.emergency, ERROR_IN_EMERGENCY_MODE);

        let user_address = address_of(user);

        // Validate token
        assert!(position_nft::is_valid_nft(token_address, gauge.pool), ERROR_INVALID_TOKEN);

        // Is valid token owner
        assert!(table::contains(&gauge.user_tokens, user_address), ERROR_INVALID_TOKEN_OWNER);

        let tokens = table::borrow_mut(&mut gauge.user_tokens, user_address);

        let (found, index) = vector::index_of(tokens, &token_address);
        assert!(found, ERROR_INVALID_TOKEN_OWNER);

        // Remove token from user map
        vector::remove(tokens, index);

        let liquidity = get_liquidity(gauge.pool, token_address);
        assert!(liquidity > 0, ERROR_AMOUNT_MUST_BE_GREATER_THEN_ZERO);


        //update global and user reward history
        update_reward(gauge, user_address);

        //update user balance
        let balance = table::borrow_mut(&mut gauge.balances, user_address);
        assert!(*balance >= liquidity, ERROR_INSUFFICIENT_BALANCE);
        *balance = *balance - liquidity;

        //update total supply
        gauge.total_supply = gauge.total_supply - liquidity;

        //transfer lp token from gauge to user account
        let gauge_signer = &object::generate_signer_for_extending(&gauge.extend_ref);

        // Check token is for valid token
        object::transfer(
            gauge_signer, address_to_object<Token>(token_address), user_address
        );

        event::emit(WithdrawEvent {
            user: user_address,
            amount: liquidity,
            gauge: gauge_address,
            pool: gauge.pool,
            token: token_address,
            timestamp: timestamp::now_seconds()
        });
    }

    /// Withdraw all LP tokens in emergency mode.
    ///
    /// # Arguments
    /// * `user` - The signer representing the user withdrawing LP tokens in emergency mode.
    /// * `gauge_address` - The gauge address from where LP tokens need to be withdrawn.
    /// * `token_address` - The token address from that need to be withdrawn.
    public entry fun emergency_withdraw(
        user: &signer, gauge_address: address, token_address: address
    ) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);
        assert!(gauge.emergency, ERROR_NOT_IN_EMERGENCY_MODE);

        let user_address = address_of(user);

        // Is valid token owner
        assert!(table::contains(&gauge.user_tokens, user_address), ERROR_INVALID_TOKEN_OWNER);

        let tokens = table::borrow_mut(&mut gauge.user_tokens, user_address);
        let (found, index) = vector::index_of(tokens, &token_address);
        assert!(found, ERROR_INVALID_TOKEN_OWNER);

        // Remove token from user map
        vector::remove(tokens, index);

        //update user balance
        let balance = table::borrow_mut(&mut gauge.balances, user_address);
        assert!(*balance > 0, ERROR_INSUFFICIENT_BALANCE);

        let amount = *balance;

        //update total supply
        gauge.total_supply = gauge.total_supply - amount;

        *balance = 0;

        //transfer token from gauge to user account
        let gauge_signer = &object::generate_signer_for_extending(&gauge.extend_ref);

        // Check token is for valid token
        object::transfer(
            gauge_signer, address_to_object<Token>(token_address), user_address
        );

        event::emit(WithdrawEvent {
            user: user_address,
            amount,
            gauge: gauge_address,
            pool: gauge.pool,
            token: token_address,
            timestamp: timestamp::now_seconds()
        });
    }

    /// User harvest function called from distribution (voter allows harvest on multiple gauges)
    ///
    /// # Arguments
    /// * `distribution` - The signer representing the distribution contract.
    /// * `user_address` - The address of the user for whom to harvest rewards.
    /// * `gauge_address` - The gauge address from where rewards need to be harvest.
    public entry fun get_reward_distribution(
        distribution: &signer, user_address: address, gauge_address: address
    ) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);

        assert!(address_of(distribution) == gauge.distribution, ERROR_NOT_DISTRIBUTION);

        // Check is the user is registered on gauge rewards
        if (table::contains(&gauge.rewards, user_address)) {
            //update global and user reward history
            update_reward(gauge, user_address);

            let reward = table::borrow_mut(&mut gauge.rewards, user_address);
            if (*reward > 0) {
                //transfer DXLYN token from gauge object account to users account
                let gauge_signer = object::generate_signer_for_extending(&gauge.extend_ref);
                primary_fungible_store::transfer(
                    &gauge_signer,
                    address_to_object<Metadata>(gauge.reward_token),
                    user_address,
                    *reward
                );

                event::emit(
                    HarvestEvent {
                        pool: gauge.pool,
                        gauge: gauge_address,
                        user: user_address,
                        reward: *reward,
                        timestamp: timestamp::now_seconds()
                    }
                );

                *reward = 0;
            };
        };
    }

    /// User harvest function called from user.
    ///
    /// # Arguments
    /// * `user` - The signer representing the user harvesting rewards.
    /// * `gauge_address` - The gauge address from where rewards need to be harvested.
    public entry fun get_reward(user: &signer, gauge_address: address) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);

        let user_address = address_of(user);

        if (table::contains(&gauge.rewards, user_address)) {
            //update global and user reward history
            update_reward(gauge, user_address);

            let reward = table::borrow_mut(&mut gauge.rewards, user_address);
            if (*reward > 0) {
                //transfer DXLYN token from gauge object account to users account
                let gauge_signer = object::generate_signer_for_extending(&gauge.extend_ref);

                // Transfer reward
                primary_fungible_store::transfer(
                    &gauge_signer,
                    address_to_object<Metadata>(gauge.reward_token),
                    user_address,
                    *reward
                );

                event::emit(
                    HarvestEvent {
                        pool: gauge.pool,
                        gauge: gauge_address,
                        user: user_address,
                        reward: *reward,
                        timestamp: timestamp::now_seconds()
                    }
                );

                *reward = 0;
            };
        };
    }


    /// Notify the gauge of a new reward amount.
    ///
    /// # Arguments
    /// * `distribution` - The signer representing the distribution contract.
    /// * `gauge_address` - The gauge address from where reward amount need to be notified.
    /// * `reward` - The amount of reward to notify.
    public entry fun notify_reward_amount(
        distribution: &signer, gauge_address: address, reward: u64
    ) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);

        let gauge = borrow_global_mut<GaugeClmm>(gauge_address);
        assert!(!gauge.emergency, ERROR_IN_EMERGENCY_MODE);

        let distribution_addr = address_of(distribution);
        assert!(distribution_addr == gauge.distribution, ERROR_NOT_DISTRIBUTION);

        //update global history
        update_reward(gauge, @0x0);
        let current_time = timestamp::now_seconds();

        let dxlyn_metadata = address_to_object<Metadata>(gauge.reward_token);

        //transfer dxlyn coin from distribution to gauge
        primary_fungible_store::transfer(distribution, dxlyn_metadata, gauge_address, reward);

        // Scaled reward to extra 10^4 to avoid precision issues in reward rate calculations.
        let reward = (reward as u256) * PRECISION;

        //if time more then finish period then calculate new reward rate other wise remaining
        // This logic is still loose some precision
        if (current_time >= gauge.period_finish) {
            gauge.reward_rate = reward / (gauge.duration as u256);
        } else {
            let remaining = (gauge.period_finish - current_time as u256);
            let left_over = remaining * gauge.reward_rate;
            gauge.reward_rate = (reward + left_over) / (gauge.duration as u256);
        };

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of reward_rate in the earned and rewards_per_token functions;
        // Reward + left_over must be less than 2^64 / 10^8 to avoid overflow.
        let balance = primary_fungible_store::balance(gauge_address, dxlyn_metadata);
        // Scaled value for handle overflow issue
        let current_reward_rate_scaled_calc =
            ((balance as u256) * PRECISION) / (gauge.duration as u256);
        assert!(
            gauge.reward_rate <= current_reward_rate_scaled_calc,
            ERROR_REWARD_TOO_HIGH
        );

        gauge.last_update_time = current_time;
        gauge.period_finish = current_time + gauge.duration;

        event::emit(
            RewardAddedEvent {
                gauge_address,
                reward: (reward / PRECISION as u64),
                timestamp: current_time
            }
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    #[view]
    /// Returns the address of the GaugeClmm system.
    ///
    /// # Returns
    /// The address of the GaugeClmm system.
    public fun get_gauge_system_address(): address {
        object::create_object_address(&SC_ADMIN, GAUGE_SYSTEM_SEEDS)
    }

    #[view]
    /// Returns the address of a gauge for a given LP token.
    ///
    /// # Arguments
    /// * `pool_address` - The pool to get the gauge address.
    ///
    /// # Returns
    /// The address of the gauge for the specified LP token.
    public fun get_gauge_address(pool_address: address): address acquires GaugeClmmSystem {
        let gauge_system_address = get_gauge_system_address();
        let gauge_sys = borrow_global<GaugeClmmSystem>(gauge_system_address);
        let gauge_signer_address = object::address_from_extend_ref(&gauge_sys.extend_ref);
        object::create_object_address(
            &gauge_signer_address, bcs::to_bytes(&pool_address)
        )
    }

    #[view]
    /// Checks if a gauge exists for the given LP token and returns its address.
    ///
    /// # Arguments
    /// * `pool_address` - The pool to check the gauge address.
    ///
    /// # Returns
    /// The address of the gauge if it exists.
    ///
    public fun check_and_get_gauge_address(pool_address: address): address acquires GaugeClmmSystem {
        let gauge_address = get_gauge_address(pool_address);
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);

        gauge_address
    }

    #[view]
    /// Returns the total supply of LP tokens held in the gauge for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the total supply.
    ///
    /// # Returns
    /// The total supply of LP tokens in the gauge.
    ///
    public fun total_supply(gauge_address: address): u128 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        gauge.total_supply
    }

    #[view]
    /// Balance of a user in the gauge for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the user's balance.
    /// * `account` - The address of the user for whom to get the balance.
    ///
    /// # Returns
    /// The balance of the user in the gauge for the specified LP token.
    public fun balance_of(gauge_address: address, account: address): u128 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        *table::borrow_with_default(&gauge.balances, account, &0)
    }

    #[view]
    /// Returns the last time reward was applicable for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the last time reward was applicable.
    ///
    /// # Returns
    /// The last time reward was applicable for the specified LP token.
    public fun last_time_reward_applicable(gauge_address: address): u64 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        math64::min(timestamp::now_seconds(), gauge.period_finish)
    }

    #[view]
    /// Returns the reward per token for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the reward per token.
    ///
    /// # Returns
    /// The reward per token for the specified LP token.
    public fun reward_per_token(gauge_address: address): u256 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        reward_per_token_internal(gauge)
    }

    #[view]
    /// See earned rewards for user.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the earned rewards.
    /// * `account` - The address of the user for whom to get the earned rewards.
    ///
    /// # Returns
    /// The total earned rewards for the user in the specified gauge.
    public fun earned(gauge_address: address, account: address): u64 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        earned_internal(gauge, account)
    }

    #[view]
    /// See earned rewards for user for multiple gauges.
    ///
    /// # Arguments
    /// * `gauge_addresses` - The vector of gauge addresses.
    /// * `account` - The address of the user for whom to get the earned rewards.
    ///
    /// # Returns
    /// The total earned rewards for the user across all specified gauges and a vector of individual earned amounts.
    public fun earned_many(gauge_addresses: vector<address>, account: address): (u64, vector<u64>) acquires GaugeClmm {
        let result = vector::empty<u64>();
        let total_reward = 0;
        vector::for_each(gauge_addresses, |gauge_address| {
            let earned_amount = earned(gauge_address, account);
            total_reward = total_reward + earned_amount;
            vector::push_back(&mut result, earned_amount);
        });
        (total_reward, result)
    }

    #[view]
    /// Returns the total reward for the duration for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the total reward for the duration.
    ///
    /// # Returns
    /// The total reward for the duration for the specified LP token.
    public fun reward_for_duration(gauge_address: address): u64 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);

        (gauge.reward_rate * (gauge.duration as u256) / PRECISION as u64)
    }

    #[view]
    /// Returns the timestamp when the current reward period finishes for the specified LP token.
    ///
    /// # Arguments
    /// * `gauge_address` - The gauge address to get the period finish time.
    ///
    /// # Returns
    /// The timestamp when the current reward period finishes for the specified LP token.
    public fun period_finish(gauge_address: address): u64 acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);
        gauge.period_finish
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creates a new GaugeClmm for a given LP token.
    ///
    /// # Arguments
    /// * `distribution` - The address of the distribution contract for this gauge.
    /// * `external_bribe` - The address of the external bribe contract for this gauge.
    /// * `pool_addr` - The pool for which to create the gauge.
    ///
    public(friend) fun create_gauge(
        distribution: address,
        external_bribe: address,
        pool_addr: address
    ): address acquires GaugeClmmSystem {
        let gauge_system_address = get_gauge_system_address();

        let pool_seed = bcs::to_bytes(&pool_addr);

        let new_gauge_address =
            object::create_object_address(&gauge_system_address, pool_seed);

        //check whether gauge is exist or not
        assert!(
            !exists<GaugeClmm>(new_gauge_address),
            ERROR_GAUGE_ALREADY_EXIST
        );

        let gauge_sys = borrow_global<GaugeClmmSystem>(gauge_system_address);
        let gauge_sys_signer =
            object::generate_signer_for_extending(&gauge_sys.extend_ref);
        let new_gauge_contractor_ref =
            object::create_named_object(&gauge_sys_signer, pool_seed);
        let new_gauge_extend_ref = object::generate_extend_ref(&new_gauge_contractor_ref);
        let new_gauge_signer =
            &object::generate_signer_for_extending(&new_gauge_extend_ref);

        //dxlyn coin metadata
        let dxlyn_coin_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let dxlyn_coin_address = object_address(&dxlyn_coin_metadata);

        move_to(
            new_gauge_signer,
            GaugeClmm {
                emergency: false,
                reward_token: dxlyn_coin_address,
                distribution,
                external_bribe,
                duration: WEEK,
                period_finish: 0,
                reward_rate: 0,
                last_update_time: 0,
                reward_per_token_stored: 0,
                user_reward_per_token_paid: table::new<address, u256>(),
                rewards: table::new<address, u64>(),
                total_supply: 0,
                balances: table::new<address, u128>(),
                extend_ref: new_gauge_extend_ref,
                pool: pool_addr,
                user_tokens: table::new<address, vector<address>>()
            }
        );

        new_gauge_address
    }


    /// Returns liquidity that NFT token holds.
    ///
    /// # Arguments
    /// * `token address` - The address of the token.
    public(friend) fun get_liquidity(pool_address: address, token_address: address): u128 {
        // Verify token with pool address
        assert!(position_nft::is_valid_nft(token_address, pool_address), ERROR_INVALID_TOKEN);

        // Get nft details
        let token_records = position_nft::get_nft_details(vector[token_address]);
        let token_info = vector::borrow(&token_records, 0);

        // Extract the liquidity from token info
        let (_, _, _, _, liquidity) = position_nft::get_nft_details_struct(token_info);
        liquidity
    }

    /// Withdraw all LP tokens and harvest reward token.
    ///
    /// # Arguments
    /// * `user` - The signer representing the user withdrawing all LP tokens and harvesting rewards.
    /// * `gauge_address` - The gauge address from where LP tokens need to be withdrawn.
    /// * `token_address` - The address of the token
    public(friend) fun withdraw_all_and_harvest(
        user: &signer, gauge_address: address, token_address: address
    ) acquires GaugeClmm {
        withdraw(user, gauge_address, token_address);
        get_reward(user, gauge_address);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Updates the global and user reward history for a gauge.
    ///
    /// # Arguments
    /// * `gauge` - The gauge for which to update the reward.
    /// * `account` - The address of the user for whom to update the reward.
    fun update_reward(gauge: &mut GaugeClmm, account: address) {
        gauge.reward_per_token_stored = reward_per_token_internal(gauge);
        gauge.last_update_time = math64::min(
            timestamp::now_seconds(), gauge.period_finish
        );

        if (account != @0x0) {
            let earned = earned_internal(gauge, account);
            table::upsert(&mut gauge.rewards, account, earned);

            table::upsert(
                &mut gauge.user_reward_per_token_paid,
                account,
                gauge.reward_per_token_stored
            );
        }
    }


    /// Returns the reward per token for the specified gauge.
    ///
    /// # Arguments
    /// * `gauge` - The gauge for which to calculate the reward per token.
    ///
    /// # Returns
    /// The reward per token for the specified gauge.
    fun reward_per_token_internal(gauge: &GaugeClmm): u256 {
        if (gauge.total_supply == 0) {
            gauge.reward_per_token_stored
        } else {
            let last_time_reward_applicable =
                math64::min(timestamp::now_seconds(), gauge.period_finish);

            // Calculate the time difference since the last update
            let time_diff = last_time_reward_applicable - gauge.last_update_time;

            // Compute reward increment with scaled reward_rate
            // Convert to u256 for precision loss prevention and handel overflow issue
            let reward_increment =
                ((time_diff as u256) * (gauge.reward_rate) * (DXLYN_DECIMAL as u256))
                    / ((gauge.total_supply as u256) * PRECISION);

            gauge.reward_per_token_stored + reward_increment
        }
    }

    /// See earned rewards for user (internal)
    ///
    /// # Arguments
    /// * `gauge` - The gauge for which to calculate the earned rewards.
    /// * `account` - The address of the user for whom to calculate the earned rewards.
    ///
    /// # Returns
    /// The total earned rewards for the user in the specified gauge.
    fun earned_internal(gauge: &GaugeClmm, account: address): u64 {
        // Check if the balance not exist
        if (!table::contains(&gauge.balances, account)) {
            return 0
        };

        let reward = *table::borrow(&gauge.rewards, account);
        let balance = *table::borrow(&gauge.balances, account);
        let user_reward_per_token_paid = *table::borrow(&gauge.user_reward_per_token_paid, account);
        let reward_per_token_diff = reward_per_token_internal(gauge) - user_reward_per_token_paid;

        // Normalize by both DXLYN_DECIMAL and PRECISION
        // Convert to u256 for precision loss prevention and handel overflow issue
        let scaled_reward =
            (reward as u256)
                + ((balance as u256) * reward_per_token_diff) / ((DXLYN_DECIMAL) as u256);
        (scaled_reward as u64)
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    friend dexlyn_tokenomics::gauge_clmm_test;

    #[test_only]
    public fun assert_token_owner(owner: address, token_addr: address) {
        assert!(
            object::owner(address_to_object<Token>(token_addr)) == owner,
            ERROR_NOT_OWNER
        )
    }

    #[test_only]
    public fun test_initialize(res: &signer) {
        initialize(res);
    }

    #[test_only]
    public fun get_gauge_system_owner(): address acquires GaugeClmmSystem {
        let gauge_system_address = get_gauge_system_address();
        borrow_global<GaugeClmmSystem>(gauge_system_address).owner
    }

    #[test_only]
    public fun test_create_gauge(
        distribution: address,
        external_bribe: address,
        pool_address: address
    ) acquires GaugeClmmSystem {
        create_gauge(
            distribution,
            external_bribe,
            pool_address
        );
    }

    #[test_only]
    public fun get_gauge_state(
        gauge_address: address
    ): (bool, address, address, address, u64, u64, u256, u64, u256, u128, u64) acquires GaugeClmm {
        assert!(exists<GaugeClmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);
        let gauge = borrow_global<GaugeClmm>(gauge_address);

        (
            gauge.emergency,
            gauge.pool,
            gauge.distribution,
            gauge.external_bribe,
            gauge.duration,
            gauge.period_finish,
            gauge.reward_rate,
            gauge.last_update_time,
            gauge.reward_per_token_stored,
            gauge.total_supply,
            primary_fungible_store::balance(gauge_address, address_to_object<Metadata>(gauge.reward_token))
        )
    }
}
