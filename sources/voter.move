module dexlyn_tokenomics::voter {
    use std::bcs;
    use std::option;
    use std::signer::address_of;
    use std::string::{Self, String};
    use std::vector::{Self, for_each};
    use aptos_std::smart_vector;
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;

    use dexlyn_clmm::pool;
    use dexlyn_coin::dxlyn_coin;
    use dexlyn_perp::house_lp::DXLP;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::event;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::object::{Self, address_to_object, ExtendRef, object_address};
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::bribe::{Self, WeeklyPaidReward};
    use dexlyn_tokenomics::fee_distributor::{Self, WeeklyClaim};
    use dexlyn_tokenomics::gauge_clmm;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::gauge_perp;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::voting_escrow;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// One week in seconds (7 days)
    /// rewards are released over 7 days
    const DURATION: u64 = 604800;

    /// Max vote delay allowed in seconds
    const MAX_VOTE_DELAY: u64 = 604800;

    /// One week in seconds (7 days), used to round lock times
    const WEEK: u64 = 604800;

    /// Seed for Voter object
    const VOTER_SEEDS: vector<u8> = b"VOTER";

    /// Creator address of the Voter object account
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// Seed for the DXLYN fungible asset, used to create a unique address for the token
    const DXLYN_FA_SEED: vector<u8> = b"DXLYN";

    /// 1 DXLYN_DECIMAL in smallest unit (10^8), for token amount scaling
    const DXLYN_DECIMAL: u64 = 100_000_000;

    // Represents the type of liquidity pool used in the gauge system.
    /// CPMM (Constant Product Market Maker)
    const CPMM_POOL: u8 = 0;

    /// CLMM (Concentrated Liquidity Market Maker)
    const CLMM_POOL: u8 = 1;

    /// DXLP (Perpetual dex pool)
    const DXLP_POOL: u8 = 2;

    const AMOUNT_SCALE: u256 = 10000;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Unauthorized action
    const ERROR_NOT_VOTER_ADMIN: u64 = 101;

    /// Vote delay is already set
    const ERROR_VOTE_DELAY_ALREADY_SET: u64 = 102;

    /// Vote delay exceeds the maximum allowed
    const ERROR_NOT_MORE_THEN_MAX_DELAY: u64 = 103;

    /// Gauge does not exist
    const ERROR_GAUGE_NOT_EXIST: u64 = 104;

    /// Caller is not governance
    const ERROR_NOT_GOVERNANCE: u64 = 105;

    /// Address cannot be zero
    const ERROR_ZERO_ADDRESS: u64 = 106;

    /// Pool is already whitelisted
    const ERROR_POOL_ALREADY_WHITELISTED: u64 = 107;

    /// Pool is not whitelisted
    const ERROR_POOL_NOT_WHITELISTED: u64 = 108;

    /// Gauge is already killed
    const ERROR_GAUGE_ALREADY_KILLED: u64 = 109;

    /// Throw the trying to revive a gauge that is alive
    const ERROR_GAUGE_ALIVE: u64 = 110;

    /// Vote delay has not passed
    const ERROR_VOTE_DELAY: u64 = 111;

    /// Votes not found for the user
    const ERROR_VOTES_NOT_FOUND: u64 = 112;

    /// Pool votes and weights must have the same length
    const ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH: u64 = 113;

    /// Vote already exists for the user in the pool
    const ERROR_VOTE_FOUND: u64 = 114;

    /// Pool weight cannot be zero
    const ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO: u64 = 115;

    /// Bribes and tokens must have the same length when claiming
    const ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH: u64 = 116;

    /// Caller is not the minter
    const ERROR_NOT_MINTER: u64 = 117;

    /// Insufficient DXLYN token balance to notify rewards
    const ERROR_INSUFFICIENT_DXLYN_COIN: u64 = 118;

    /// Gauge start time cannot be after finish time
    const ERROR_START_MUST_BE_LESS_THEN_FINISH: u64 = 119;

    /// Caller is not the gauge owner
    const ERROR_NOT_OWNER: u64 = 120;

    /// Gauge already exists for the pool
    const ERROR_GAUGE_ALREADY_EXIST_FOR_POOL: u64 = 121;

    /// Pool not found for the gauge
    const ERROR_POOL_NOT_FOUND_FOR_GAUGE: u64 = 122;

    /// Cannot whitelist a pool that is not registered
    const ERROR_POOL_NOT_EXISTS: u64 = 123;

    /// Caller is not the NFT owner
    const ERROR_NOT_NFT_OWNER: u64 = 124;

    /// Penalty amount cannot be zero
    const ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO: u64 = 125;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Sets the voter delay for voting
    struct SetVoteDelayEvent has store, drop {
        old_delay: u64,
        latest_delay: u64
    }

    #[event]
    /// Sets the same epoch vote penalty
    struct EditVotePenaltyEvent has store, drop {
        old_penalty: u64,
        new_penalty: u64
    }

    #[event]
    /// Sets the minter
    struct SetMinterEvent has store, drop {
        old_minter: address,
        latest_minter: address
    }

    #[event]
    /// Sets the external bribe for a gauge
    struct SetExternalBribeForEvent has store, drop {
        old_bribe: address,
        latest_bribe: address,
        gauge: address
    }

    #[event]
    /// Whitelists a pool for gauge creation
    struct WhitelistedEvent has store, drop {
        whitelister: address,
        pool: address,
        gauge: address,
        gauge_type: u8,
        asset: String
    }

    #[event]
    /// Blacklists a pool
    struct BlacklistedEvent has store, drop {
        blacklister: address,
        pool: address
    }

    #[event]
    /// Kills a gauge
    struct GaugeKilledEvent has store, drop {
        gauge: address
    }

    #[event]
    /// Token abstained from voting
    struct AbstainedEvent has store, drop {
        pool: address,
        gauge: address,
        user: address,
        token: address,
        weight: u64,
        timestamp: u64,
        epoch: u64
    }

    #[event]
    /// Token voted for a pool
    struct VotedEvent has store, drop {
        pool: address,
        gauge: address,
        user: address,
        token: address,
        weight: u64,
        timestamp: u64,
        epoch: u64
    }

    #[event]
    /// Notify rewards to the gauge
    struct NotifyRewardEvent has store, drop {
        sender: address,
        reward: address,
        amount: u64
    }

    #[event]
    /// Distribute rewards to the gauge
    struct DistributeRewardEvent has store, drop {
        sender: address,
        gauge: address,
        amount: u64,
        ecpoh: u64,
        timestamp: u64,
    }

    #[event]
    /// Create a gauge
    struct GaugeCreatedEvent has store, drop {
        gauge: address,
        creator: address,
        external_bribe: address,
        pool: address,
        gauge_type: u8
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    struct Voter has key {
        owner: address,
        voter_admin: address,
        governance: address,
        minter: address,
        // all pools viable for incentives
        pools: smart_vector::SmartVector<address>,
        // gauge index
        index: u64,
        // delay between votes in seconds
        vote_delay: u64,
        // gauge    => index
        supply_index: Table<address, u64>,
        // gauge    => claimable DXLYN
        claimable: Table<address, u64>,
        // pool     => gauge
        gauges: Table<address, address>,
        // gauge    => last Distribution Time
        gauges_distribution_timestamp: Table<address, u64>,
        // gauge    => pool
        pool_for_gauge: Table<address, address>,
        // gauge    => external bribe (real bribes)
        external_bribes: Table<address, address>,
        // token      => pool     => votes
        votes: Table<address, Table<address, u64>>,
        // token      => pools
        pool_vote: Table<address, smart_vector::SmartVector<address>>,
        // timestamp => pool => weights
        weights_per_epoch: Table<u64, Table<address, u64>>,
        // timestamp => total weights
        total_weights_per_epoch: Table<u64, u64>,
        // token      => timestamp of last vote
        last_voted: Table<address, u64>,
        // gauge    => boolean [is a gauge?]
        is_gauge: Table<address, bool>,
        // pool    => boolean [is an allowed token?]
        is_whitelisted: Table<address, bool>,
        // gauge    => boolean [is the gauge alive?]
        is_alive: Table<address, bool>,
        extended_ref: ExtendRef,
        gauge_to_type: Table<address, u8>,
        dxlyn_coin_address: address,
        // Number of DXLYN Penalty in decimals of 10^8
        edit_vote_penalty: u64
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    fun init_module(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, VOTER_SEEDS);

        let extended_ref = object::generate_extend_ref(&constructor_ref);

        let voter_signer = object::generate_signer(&constructor_ref);

        //dxlyn coin address
        let dxlyn_coin_address = object_address(&dxlyn_coin::get_dxlyn_asset_metadata());

        minter::initialize(sender);
        bribe::initialize(sender);
        gauge_cpmm::initialize(sender);
        gauge_clmm::initialize(sender);
        gauge_perp::initialize(sender);

        move_to<Voter>(
            &voter_signer,
            Voter {
                owner: @owner,
                voter_admin: @voter_admin,
                governance: @voter_governance,
                minter: @voter_minter,
                pools: smart_vector::empty(),
                index: 0,
                vote_delay: 0,
                supply_index: table::new(),
                claimable: table::new(),
                gauges: table::new(),
                gauges_distribution_timestamp: table::new(),
                pool_for_gauge: table::new(),
                external_bribes: table::new(),
                votes: table::new(),
                pool_vote: table::new(),
                weights_per_epoch: table::new(),
                total_weights_per_epoch: table::new(),
                last_voted: table::new(),
                is_gauge: table::new(),
                is_whitelisted: table::new(),
                is_alive: table::new(),
                extended_ref,
                dxlyn_coin_address,
                gauge_to_type: table::new(),
                edit_vote_penalty: 1 * DXLYN_DECIMAL
            }
        )
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    /// Sets vote delay for voting
    ///
    /// # Arguments
    /// * `voter_admin` - The signer with voter admin rights
    /// * `delay` - The delay in seconds between votes
    ///
    /// # Dev
    /// Only the voter admin can set the delay.
    /// The delay must not be more than `MAX_VOTE_DELAY`.
    public entry fun set_voter_delay(voter_admin: &signer, delay: u64) acquires Voter {
        assert!(delay <= MAX_VOTE_DELAY, ERROR_NOT_MORE_THEN_MAX_DELAY);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(delay != voter.vote_delay, ERROR_VOTE_DELAY_ALREADY_SET);
        assert!(address_of(voter_admin) == voter.voter_admin, ERROR_NOT_VOTER_ADMIN);

        event::emit(SetVoteDelayEvent { old_delay: voter.vote_delay, latest_delay: delay });

        voter.vote_delay = delay;
    }

    /// Sets the penalty amount imposed for voting within the same epoch.
    ///
    /// # Arguments
    /// * `voter_admin` - The signer with voter admin rights.
    /// * `new_penalty` - The new penalty amount to be applied when a voter votes within the same epoch as their last vote.
    ///
    /// # Dev Notes
    /// Only the voter admin is authorized to set this penalty.
    /// The penalty should be set responsibly to discourage invalid or repeated voting within the same epoch.
    /// Emits a `SetChangeVotePenalty` event to log the change in penalty amount.
    public entry fun set_edit_vote_penalty(voter_admin: &signer, new_penalty: u64) acquires Voter {
        assert!(new_penalty > 0, ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        // Validate Admin
        assert!(address_of(voter_admin) == voter.voter_admin, ERROR_NOT_VOTER_ADMIN);

        event::emit(
            EditVotePenaltyEvent { old_penalty: voter.edit_vote_penalty, new_penalty }
        );
        voter.edit_vote_penalty = new_penalty;
    }

    /// Sets a new minter address.
    ///
    /// # Arguments
    /// * `voter_admin` - The signer with voter admin rights.
    /// * `minter` - The address of the new minter.
    ///
    /// # Dev
    /// Only the voter admin can set the minter.
    public entry fun set_minter(voter_admin: &signer, minter: address) acquires Voter {
        assert!(minter != @0x0, ERROR_ZERO_ADDRESS);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(address_of(voter_admin) == voter.voter_admin, ERROR_NOT_VOTER_ADMIN);

        event::emit(SetMinterEvent { old_minter: voter.minter, latest_minter: minter });

        voter.minter = minter;
    }

    /// Sets the external bribe for a gauge.
    ///
    /// # Arguments
    /// * `voter_admin` - The signer with voter admin rights.
    /// * `gauge` - The address of the gauge.
    /// * `external` - The address of the external bribe.
    ///
    /// # Dev
    /// Only the voter admin can set the external bribe.
    /// The gauge must exist in the voter.
    public entry fun set_external_bribe_for_gauge(
        voter_admin: &signer, gauge: address, external: address
    ) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);


        assert!(address_of(voter_admin) == voter.voter_admin, ERROR_NOT_VOTER_ADMIN);
        assert!(table::contains(&voter.is_gauge, gauge), ERROR_GAUGE_NOT_EXIST);

        let old_bribe = table::borrow_mut(&mut voter.external_bribes, gauge);

        event::emit(
            SetExternalBribeForEvent { old_bribe: *old_bribe, latest_bribe: external, gauge }
        );

        *old_bribe = external;
    }

    /// Whitelist a Perpectual DXLP for gauge creation.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `TypeArgument` - The AssetT type.
    ///
    /// # Dev
    /// Only governance can whitelist perpectual coin.
    public entry fun whitelist_perp_pool<AssetT>(
        governance: &signer
    ) acquires Voter {
        // Dxlp object address
        let pool = gauge_perp::get_dxlp_coin_address<AssetT>();

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);


        // Pool should not exist or should be blacklisted
        let is_whitelist = table::borrow_mut_with_default(&mut voter.is_whitelisted, pool, false);
        assert!(!*is_whitelist, ERROR_POOL_ALREADY_WHITELISTED);

        let gauge = object::create_object_address(&gauge_perp::get_gauge_system_address(), bcs::to_bytes(&pool));

        if (!table::contains(&voter.gauges, pool)) {
            table::add(&mut voter.gauges, pool, gauge);
            table::add(&mut voter.gauge_to_type, gauge, DXLP_POOL);
        };

        // Whitelist pool
        *is_whitelist = true;

        event::emit(
            WhitelistedEvent {
                whitelister: governance_address,
                pool,
                gauge,
                gauge_type: DXLP_POOL,
                asset: type_info::type_name<DXLP<AssetT>>()
            }
        );
    }

    /// Whitelist a CPMM pool for gauge creation.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `TypeArguments` - The pool types <X, Y, Curve>.
    ///
    /// # Dev
    /// Only governance can whitelist CPMM pools.
    public entry fun whitelist_cpmm_pool<X, Y, Curve>(
        governance: &signer
    ) acquires Voter {
        // Validate the pool exist
        assert!(liquidity_pool::is_pool_exists<X, Y, Curve>(), ERROR_POOL_NOT_EXISTS);
        let pool = liquidity_pool::generate_lp_object_address<X, Y, Curve>();

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

        // Pool should not exist or should be blacklisted
        let is_whitelist = table::borrow_mut_with_default(&mut voter.is_whitelisted, pool, false);
        assert!(!*is_whitelist, ERROR_POOL_ALREADY_WHITELISTED);

        let gauge = object::create_object_address(&gauge_cpmm::get_gauge_system_address(), bcs::to_bytes(&pool));

        if (!table::contains(&voter.gauges, pool)) {
            table::add(&mut voter.gauges, pool, gauge);
            table::add(&mut voter.gauge_to_type, gauge, CPMM_POOL);
        };

        // Whitelist pool
        *is_whitelist = true;

        event::emit(
            WhitelistedEvent {
                whitelister: governance_address,
                pool,
                gauge,
                gauge_type: CPMM_POOL,
                asset: type_info::type_name<LP<X, Y, Curve>>()
            }
        );
    }

    /// Whitelist CLMM pool for gauge creation.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `pool_address` - The pool address
    ///
    /// # Dev
    /// Only the governance can whitelist pools.
    /// Tokens must be sorted
    public entry fun whitelist_clmm_pool(
        governance: &signer,
        pool_address: address
    ) acquires Voter {
        // Check is valid pool
        let results = pool::is_pool_exists(vector[pool_address]);
        assert!(*vector::borrow(&results, 0), ERROR_POOL_NOT_EXISTS);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

        // Pool should not exist or should be blacklisted
        let is_whitelisted = table::borrow_mut_with_default(&mut voter.is_whitelisted, pool_address, false);
        assert!(!*is_whitelisted, ERROR_POOL_ALREADY_WHITELISTED);

        let gauge = object::create_object_address(
            &gauge_clmm::get_gauge_system_address(),
            bcs::to_bytes(&pool_address)
        );

        if (!table::contains(&voter.gauges, pool_address)) {
            table::add(&mut voter.gauges, pool_address, gauge);
            table::add(&mut voter.gauge_to_type, gauge, CLMM_POOL);
        };

        // Whitelist pool
        *is_whitelisted = true;

        event::emit(
            WhitelistedEvent {
                whitelister: governance_address,
                pool: pool_address,
                gauge, gauge_type: CLMM_POOL,
                asset: string::utf8(b"")
            }
        );
    }

    /// Blacklist a malicious pool.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `pools` - The addresses of the pools to blacklist.
    ///
    /// # Dev
    /// Only the governance can blacklist pools.
    /// The pool address must not be zero.
    /// The pool must be whitelisted.
    public entry fun blacklist(governance: &signer, pools: vector<address>) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

        vector::for_each(pools, |pool| {
            assert!(pool != @0x0, ERROR_ZERO_ADDRESS);

            // Pool should exist or should be whitelisted
            let is_whitelisted = table::borrow_mut_with_default(&mut voter.is_whitelisted, pool, false);
            assert!(*is_whitelisted, ERROR_POOL_NOT_WHITELISTED);

            // Blacklist pool
            *is_whitelisted = false;

            event::emit(BlacklistedEvent { blacklister: governance_address, pool });
        });
    }

    /// Kill a malicious gauge.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `gauge` - The address of the gauge to kill.
    ///
    /// # Dev
    /// Only the governance can kill a gauge.
    public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

        assert!(table::contains(&voter.is_alive, gauge), ERROR_GAUGE_NOT_EXIST);
        let is_alive = table::borrow_mut(&mut voter.is_alive, gauge);
        assert!(*is_alive, ERROR_GAUGE_ALREADY_KILLED);
        *is_alive = false;

        table::upsert(&mut voter.claimable, gauge, 0);

        let time = epoch_timestamp();
        let pool = table::borrow(&voter.pool_for_gauge, gauge);
        let weights_per_epoch =
            weights_per_epoch_internal(&voter.weights_per_epoch, time, *pool);

        let total_weights_per_epoch = table::borrow_mut_with_default(&mut voter.total_weights_per_epoch, time, 0);
        *total_weights_per_epoch = *total_weights_per_epoch - weights_per_epoch;

        event::emit(GaugeKilledEvent { gauge })
    }

    /// Revive a malicious gauge.
    ///
    /// # Arguments
    /// * `governance` - The signer with governance rights.
    /// * `gauge` - The address of the gauge to revive.
    ///
    /// # Dev
    /// Only the governance can revive a gauge.
    public entry fun revive_gauge(governance: &signer, gauge: address) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let governance_address = address_of(governance);
        assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);
        assert!(table::contains(&voter.is_gauge, gauge), ERROR_GAUGE_NOT_EXIST);

        let is_alive = table::borrow_mut(&mut voter.is_alive, gauge);
        assert!(!*is_alive, ERROR_GAUGE_ALIVE);
        *is_alive = true;

        event::emit(GaugeKilledEvent { gauge })
    }

    /// Resets the votes of the caller.
    ///
    /// # Arguments
    /// * `caller` - The caller who wants to reset their votes.
    /// * `token` - The address of the nft token to reset votes for.
    ///
    /// # Dev
    /// This function resets the votes of the user and updates the last voted timestamp.
    public entry fun reset(caller: &signer, token: address) acquires Voter {
        let caller_address = address_of(caller);
        // Check if the caller is the owner of the token and return the token owner
        voting_escrow::assert_if_not_owner(caller_address, token);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(
            table::contains(&voter.pool_vote, token), ERROR_VOTES_NOT_FOUND
        );

        // Check vote delay
        let last_voted = table::borrow_mut(&mut voter.last_voted, token);
        assert!(
            timestamp::now_seconds() > *last_voted + voter.vote_delay,
            ERROR_VOTE_DELAY
        );

        // Reset votes
        reset_internal(voter, caller_address, token);

        let voter_singer = &object::generate_signer_for_extending(&voter.extended_ref);
        // Call abstain on voting escrow
        // only voter can call this function
        voting_escrow::abstain(voter_singer, token);

        // Update last voted timestamp
        table::upsert(&mut voter.last_voted, token, epoch_timestamp() + 1);
    }

    /// This function is called every week to calculate the rebase,emission and distribute rewards.
    public entry fun update_period() acquires Voter {
        let (rebase, gauge, dxlyn_signer, is_new_week) = minter::calculate_rebase_gauge();

        if (is_new_week) {
            let voter_address = get_voter_address();
            let voter = borrow_global_mut<Voter>(voter_address);
            let voter = object::generate_signer_for_extending(&voter.extended_ref);
            fee_distributor::burn_rebase(&voter, &dxlyn_signer, rebase);
            fee_distributor::checkpoint_token(&voter);
            fee_distributor::checkpoint_total_supply();

            notify_reward_amount(&dxlyn_signer, gauge);
        }
    }

    /// Recast the saved votes of a nft token.
    ///
    /// # Arguments
    /// * `caller` - The caller who wants to recast their votes.
    /// * `token` - The address of the token to recast votes for.
    ///
    /// # Dev
    /// This function recasts the votes of the token to the same pools with the same weights.
    /// The token must have voted before, otherwise an error is thrown.
    /// The token must wait for the vote delay before recasting their votes.
    public entry fun poke(caller: &signer, token: address) acquires Voter {
        let caller_address = address_of(caller);

        // Check if the caller is the owner of the token and return the token owner
        voting_escrow::assert_if_not_owner(caller_address, token);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(
            table::contains(&voter.pool_vote, token), ERROR_VOTES_NOT_FOUND
        );

        // Check vote delay
        let last_voted =
            table::borrow_with_default(&voter.last_voted, token, &0);
        assert!(
            timestamp::now_seconds() > *last_voted + voter.vote_delay,
            ERROR_VOTE_DELAY
        );

        let pool_vote = smart_vector::to_vector(table::borrow(&voter.pool_vote, token));
        let weights = vector::empty<u64>();

        vector::for_each(pool_vote, |pool| {
            //get pool votes for token
            let weight = get_vote_internal(voter, token, pool);
            //add add previous pool weights to list
            vector::push_back(&mut weights, weight);
        });

        // Cast vote to same pool with same weights
        vote_internal(
            voter,
            caller_address,
            token,
            pool_vote,
            weights
        );

        // Update last voted timestamp
        table::upsert(&mut voter.last_voted, token, epoch_timestamp() + 1);
    }

    /// Vote for pools.
    ///
    /// # Arguments
    /// * `caller` - The caller who wants to vote.
    /// * `token` - The address of the token from vote will submit (e\.g\., veDXLYN).
    /// * `pool_vote` - Array of LP pool addresses to vote (e\.g\., \[sAMM usdc-usdt, sAMM busd-usdt, vAMM wbnb-the, ...\]).
    /// * `weights` - Array of weights for each LP pool (e\.g\., \[10, 90, 45, ...\]).
    ///
    /// # Dev
    /// This function allows veDXLYN holders to vote for pools with weights.
    /// The caller must wait for the vote delay before voting.
    public entry fun vote(
        caller: &signer, token: address, pool_vote: vector<address>, weights: vector<u64>
    ) acquires Voter {
        // Check pool and weights length match or not
        assert!(
            vector::length(&pool_vote) == vector::length(&weights),
            ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH
        );

        let caller_address = address_of(caller);
        // Check if the caller is the owner of the token and return the token owner
        voting_escrow::assert_if_not_owner(caller_address, token);

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        // Check vote delay
        let last_voted =
            table::borrow_with_default(&voter.last_voted, token, &0);
        assert!(
            timestamp::now_seconds() > *last_voted + voter.vote_delay,
            ERROR_VOTE_DELAY
        );

        let week = WEEK;
        let last_voted_epoch = *last_voted / week * week;
        let current_epoch = timestamp::now_seconds() / week * week;

        // If the user attempts to vote within the same epoch as their last vote, apply a penalty
        if (current_epoch == last_voted_epoch) {
            primary_fungible_store::transfer(
                caller,
                dxlyn_coin::get_dxlyn_asset_metadata(),
                @fee_treasury,
                voter.edit_vote_penalty
            );
        };

        vote_internal(voter, caller_address, token, pool_vote, weights);

        // Update last voted timestamp
        table::upsert(&mut voter.last_voted, token, epoch_timestamp() + 1);
    }

    /// Claim emission reward for gauges.
    ///
    /// # Arguments
    /// * `user` - The user who wants to claim rewards.
    /// * `gauges` - The addresses of the gauges to claim rewards from.
    public entry fun claim_emission(user: &signer, gauges: vector<address>) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        vector::for_each(gauges, |gauge| {
            //fetch pool (lp) address for gauge
            assert!(table::contains(&voter.pool_for_gauge, gauge), ERROR_GAUGE_NOT_EXIST);

            let gauge_type = table::borrow(&mut voter.gauge_to_type, gauge);
            //claim reward from the gauge
            if (*gauge_type == CLMM_POOL) {
                gauge_clmm::get_reward(user, gauge);
            } else if (*gauge_type == CPMM_POOL) {
                gauge_cpmm::get_reward(user, gauge);
            } else {
                gauge_perp::get_reward(user, gauge);
            }
        });
    }

    /// Claims bribes for the user.
    ///
    /// # Arguments
    /// * `user` - The user who wants to claim bribes.
    /// * `pools` - The addresses of the pool from which bribes will be claim.
    /// * `tokens` - The addresses of the tokens to claim bribes for.
    ///
    /// # Dev
    /// The length of bribes and tokens must match.
    public entry fun claim_bribes(
        user: &signer, pools: vector<address>, tokens: vector<vector<address>>
    ) {
        let pools_cnt = vector::length(&pools);
        let tokens_cnt = vector::length(&tokens);

        assert!(pools_cnt == tokens_cnt, ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH);

        vector::enumerate_ref(&pools, |index, pool| {
            let token = vector::borrow(&tokens, index);
            // claim the bribe reward by owner
            bribe::get_reward(user, *pool, *token);
        });
    }


    /// Claims bribes for the token owner.
    ///
    /// # Arguments
    /// * `caller` - The caller signer of transaction.
    /// * `token` - The address of the nft token.
    /// * `pools` - The addresses of the pool from which bribes will be claim.
    /// * `tokens` - The addresses of the reward tokens to claim bribes for.
    ///
    /// # Dev
    /// The length of bribes and tokens must match.
    public entry fun claim_bribe_for_token(
        _caller: &signer, token: address, pools: vector<address>, tokens: vector<vector<address>>
    ) {
        let pools_cnt = vector::length(&pools);
        let tokens_cnt = vector::length(&tokens);

        assert!(pools_cnt == tokens_cnt, ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH);

        vector::enumerate_ref(&pools, |index, pool| {
            let token_i = vector::borrow(&tokens, index);
            // claim the bribe reward for token owner
            bribe::get_reward_for_token_owner(_caller, *pool, token, *token_i);
        });
    }

    /// Claims bribes for the user for a specific address.
    ///
    /// # Arguments
    /// * `user` - The address of the user who wants to claim bribes.
    /// * `pools` - The addresses of the pool from which bribes will be claim.
    /// * `tokens` - The addresses of the tokens to claim bribes for.
    ///
    /// # Dev
    /// The length of bribes and tokens must match.
    /// This function is used to claim bribes for a specific user address.
    public entry fun claim_bribes_for_address(
        user: address, pools: vector<address>, tokens: vector<vector<address>>
    ) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        let pools_cnt = vector::length(&pools);
        let tokens_cnt = vector::length(&tokens);

        assert!(pools_cnt == tokens_cnt, ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH);

        vector::enumerate_ref(&pools, |index, pool| {
            let token = vector::borrow(&tokens, index);

            let voter = object::generate_signer_for_extending(&voter.extended_ref);
            //Claim the bribe reward for user
            bribe::get_reward_for_address(&voter, *pool, user, *token);
        });
    }

    /// Creates multiple gauges.
    ///
    /// # Arguments
    /// * `owner` - The owner of the voter .
    /// * `pools` - The addresses of the pools for which gauges are to be created.
    ///
    /// # Dev
    /// The length of `pools` and `gauge_types` must match.
    /// Only the owner can create gauges.
    /// The pools must be whitelisted.
    public entry fun create_gauges(
        owner: &signer, pools: vector<address>
    ) acquires Voter {
        let voter_address = get_voter_address();

        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(address_of(owner) == voter.owner, ERROR_NOT_OWNER);

        vector::enumerate_ref(&pools, |index, pool| {
            create_gauge_internal(voter, owner, *pool);
        });
    }

    /// Creates a gauge.
    ///
    /// # Arguments
    /// * `owner` - The owner of the voter
    /// * `pool` - LP address
    ///
    /// # Dev
    /// Only the owner can create a gauge.
    /// The pool must be whitelisted.
    public entry fun create_gauge(
        owner: &signer, pool: address
    ) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        assert!(address_of(owner) == voter.owner, ERROR_NOT_OWNER);
        create_gauge_internal(voter, owner, pool);
    }

    /// Notifies the reward amount for the gauge.
    ///
    /// # Arguments
    /// * `minter` - The signer authorized to notify rewards.
    /// * `amount` - The amount to distribute.
    ///
    /// # Dev
    /// This function is called by the minter each epoch.
    public entry fun notify_reward_amount(minter: &signer, amount: u64) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        let minter_address = address_of(minter);

        assert!(minter_address == voter.minter, ERROR_NOT_MINTER);

        let dxlyn_metadata = address_to_object<Metadata>(voter.dxlyn_coin_address);
        let balance = primary_fungible_store::balance(minter_address, dxlyn_metadata);
        assert!(balance >= amount, ERROR_INSUFFICIENT_DXLYN_COIN);

        //transfer dexlyn coins
        primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);

        // minter call notify after updates active_period, loads votes - 1 week
        let epoch = epoch_timestamp() - WEEK;
        if (table::contains(&voter.total_weights_per_epoch, epoch)) {
            let total_weight = *table::borrow(&voter.total_weights_per_epoch, epoch);
            let ratio = 0;

            if (total_weight > 0) {
                // 1e8 adjustment is removed during claim
                // scaled ratio is used to avoid overflow
                let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256)
                    / (total_weight as u256);
                // convert scaled ratio to u64
                ratio = (scaled_ratio as u64);
            };

            if (ratio > 0) {
                voter.index = voter.index + ratio;
            };
        };

        event::emit(
            NotifyRewardEvent {
                sender: minter_address,
                reward: object::object_address(&dxlyn_metadata),
                amount
            }
        );
    }

    /// Distribute the emission for ALL gauges
    /// # Arguments
    /// * `caller` - The user as singer.
    public entry fun distribute_all(_sender: &signer) acquires Voter {
        update_period();
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        let distribution = &object::generate_signer_for_extending(&voter.extended_ref);

        let stop = smart_vector::length(&voter.pools);

        for (i in 0..stop) {
            let pool = *smart_vector::borrow(&voter.pools, i);
            let gauge = *table::borrow(&voter.gauges, pool);
            let gauge_type = *table::borrow(&voter.gauge_to_type, gauge);
            distribute_internal(voter, distribution, gauge, gauge_type);
        }
    }

    /// Distribute the emission for a range of gauges.
    ///
    /// # Arguments
    /// * `_sender` - The sender calling the function.
    /// * `start` - Start index of the pools array.
    /// * `finish` - Finish index of the pools array.
    ///
    /// # Dev
    /// Use this function when there are too many pools and the gas limit may be reached.
    public entry fun distribute_range(
        _sender: &signer, start: u64, finish: u64
    ) acquires Voter {
        assert!(start < finish, ERROR_START_MUST_BE_LESS_THEN_FINISH);

        update_period();

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        let distribution = &object::generate_signer_for_extending(&voter.extended_ref);


        for (i in start..finish) {
            let pool = *smart_vector::borrow(&voter.pools, i);
            let gauge = *table::borrow(&voter.gauges, pool);
            let gauge_type = *table::borrow(&voter.gauge_to_type, gauge);
            distribute_internal(voter, distribution, gauge, gauge_type);
        }
    }

    /// Distributes rewards only for the specified gauges.
    ///
    /// # Arguments
    /// * `_sender` - The sender calling the function.
    /// * `gauges` - A vector of addresses representing the gauges to distribute rewards for.
    /// # Dev
    /// This function is used in case some distributions fail.
    public entry fun distribute_gauges(
        _sender: &signer, gauges: vector<address>
    ) acquires Voter {
        update_period();

        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);
        let distribution = &object::generate_signer_for_extending(&voter.extended_ref);

        vector::for_each(gauges, |gauge| {
            assert!(table::contains(&voter.is_gauge, gauge), ERROR_GAUGE_NOT_EXIST);

            let type = *table::borrow(&voter.gauge_to_type, gauge);
            distribute_internal(voter, distribution, gauge, type);
        })
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// View the vote penalty amount applied for voting in the same epoch.
    ///
    /// # Returns
    /// The penalty amount imposed when a voter votes within the same epoch as their last vote.
    public fun get_edit_vote_penalty(): u64 acquires Voter {
        let voter_address = get_voter_address();
        borrow_global<Voter>(voter_address).edit_vote_penalty
    }

    #[view]
    /// View address of the Voter object address.
    public fun get_voter_address(): address {
        object::create_object_address(&SC_ADMIN, VOTER_SEEDS)
    }

    #[view]
    /// View the external bribe address for a given pool.
    ///
    /// # Arguments
    /// * `pool` - The address of the pool for which the external bribe address is to be retrieved.
    ///
    /// # Returns
    /// The address of the external bribe for the given pool.
    public fun get_external_bribe_address(pool: address): address {
        bribe::get_bribe_address(pool)
    }


    #[view]
    /// View the total length of the pools.
    ///
    /// # Returns
    /// The total number of pools in the Voter.
    public fun length(): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);

        smart_vector::length(&voter.pools)
    }

    #[view]
    /// View the total number of pools voted by the given token address.
    ///
    /// # Arguments
    /// * `token` - The address of the nft token.
    ///
    /// # Returns
    /// The total number of pools voted by the token.
    public fun pool_vote_length(token: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);

        if (table::contains(&voter.pool_vote, token)) {
            let voted_pools = table::borrow(&voter.pool_vote, token);
            smart_vector::length(voted_pools)
        } else { 0 }
    }

    #[view]
    /// View the total weight of a pool.
    ///
    /// # Arguments
    /// * `pool` - The address of the pool for which the weight is to be retrieved.
    ///
    /// # Returns
    /// The total weight of the pool at the current epoch.
    public fun weights(pool: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        let time = epoch_timestamp();

        weights_per_epoch_internal(&voter.weights_per_epoch, time, pool)
    }

    #[view]
    /// View the total weight of a pool at a specific time.
    ///
    /// # Arguments
    /// * `pool` - The address of the pool for which the weight is to be retrieved.
    /// * `time` - The specific time at which the weight is to be retrieved.
    ///
    /// # Returns
    /// The total weight of the pool at the specified time.
    public fun weights_at(pool: address, time: u64): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);

        weights_per_epoch_internal(&voter.weights_per_epoch, time, pool)
    }

    #[view]
    /// View the total weight of the current epoch.
    ///
    /// # Returns
    /// The total weight of the current epoch.
    public fun total_weight(): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        let time = epoch_timestamp();

        *table::borrow_with_default(&voter.total_weights_per_epoch, time, &0)
    }

    #[view]
    /// View the total weight of a specific epoch.
    ///
    /// # Arguments
    /// * `time` - The specific epoch time for which the total weight is to be retrieved.
    ///
    /// # Returns
    /// The total weight of the specified epoch.
    public fun total_weight_at(time: u64): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);

        *table::borrow_with_default(&voter.total_weights_per_epoch, time, &0)
    }

    #[view]
    /// get the current epoch
    /// # Returns
    /// The current epoch timestamp.
    public fun epoch_timestamp(): u64 {
        minter::active_period()
    }

    #[view]
    /// View the earned rewards for a user across multiple gauges.
    ///
    /// # Arguments
    /// * `user_address` - The address of the user whose earnings are to be checked.
    /// * `cpmm_gauge_addresses` - A vector of addresses of CPMM gauges.
    /// * `clmm_gauge_addresses` - A vector of addresses of CLMM gauges.
    /// * `prep_gauge_addresses` - A vector of addresses of Perp gauges.
    ///
    /// # Returns
    /// A tuple containing:
    /// Total reward for all gauges and vectors of weekly earned rewards for each gauge type.
    public fun earned_all_gauges(
        user_address: address,
        cpmm_gauge_addresses: vector<address>,
        clmm_gauge_addresses: vector<address>,
        perp_gauge_addresses: vector<address>
    ): (u64, u64, u64, vector<u64>, vector<u64>, vector<u64>) {
        let (total_reward_cpmm, weekly_earned_cpmm) = gauge_cpmm::earned_many(cpmm_gauge_addresses, user_address);
        let (total_reward_clmm, weekly_earned_clmm) = gauge_clmm::earned_many(clmm_gauge_addresses, user_address);
        let (total_reward_perp, weekly_earned_perp) = gauge_perp::earned_many(perp_gauge_addresses, user_address);

        (total_reward_cpmm, total_reward_clmm, total_reward_perp, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp)
    }

    #[view]
    /// View the total claimable rewards for a user across multiple gauges, ve rewards, and bribes.
    ///
    /// # Arguments
    /// * `user_address` - The address of the user whose claimable rewards are to be checked.
    /// * `reward_token_for_bribe` - The address of the reward token for bribes.
    /// * `cpmm_gauge_addresses_for_emission` - A vector of addresses of CPMM gauges.
    /// * `clmm_gauge_addresses_for_emission` - A vector of addresses of CLMM gauges.
    /// * `perp_gauge_addresses_for_emission` - A vector of addresses of Perp gauges.
    /// * `tokens_for_ve_reward` - A vector of addresses of tokens for ve rewards.
    /// * `pools_for_bribe` - A vector of addresses of pools for bribes.
    ///
    /// # Returns
    /// A tuple containing:
    /// Total rewards for CPMM, CLMM, Perp gauges, ve rewards, and bribes,
    /// and vectors of weekly earned rewards for each gauge type, ve rewards, and bribes.
    public fun total_claimable_rewards(
        user_address: address,
        reward_token_for_bribe: address,
        cpmm_gauge_addresses_for_emission: vector<address>,
        clmm_gauge_addresses_for_emission: vector<address>,
        perp_gauge_addresses_for_emission: vector<address>,
        tokens_for_ve_reward: vector<address>,
        pools_for_bribe: vector<address>
    ): (
        u64, // total_reward_cpmm
        u64, // total_reward_clmm
        u64, // total_reward_perp
        u64, // total_ve_reward
        u64, // total_bribe
        vector<u64>, // weekly_earned_cpmm
        vector<u64>, // weekly_earned_clmm
        vector<u64>, // weekly_earned_perp
        vector<vector<WeeklyClaim>>, // weekly_ve_reward,
        vector<vector<WeeklyPaidReward>> // weekly_earned_bribe
    ) {
        let (total_reward_cpmm, total_reward_clmm, total_reward_perp, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp) = earned_all_gauges(
            user_address,
            cpmm_gauge_addresses_for_emission,
            clmm_gauge_addresses_for_emission,
            perp_gauge_addresses_for_emission
        );

        let (total_ve_reward, weekly_ve_reward) = fee_distributor::claimable_many(tokens_for_ve_reward);

        let (total_bribe, weekly_earned_bribe) = bribe::earned_many(
            pools_for_bribe,
            user_address,
            reward_token_for_bribe
        );

        (total_reward_cpmm, total_reward_clmm, total_reward_perp, total_ve_reward, total_bribe, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp, weekly_ve_reward, weekly_earned_bribe)
    }

    #[view]
    /// Estimate the emission rewards for a list of pools based on their weights.
    ///
    /// # Arguments
    /// * `pools` - A vector of pool addresses for which to estimate rewards.
    ///
    /// # Returns
    /// A vector of estimated rewards for each pool.
    public fun estimated_emission_reward_for_pools(pools: vector<address>): vector<u64> acquires Voter {
        let total_weight = total_weight();
        let pool_rewards = vector::empty<u64>();
        if (total_weight == 0) {
            return pool_rewards
        };

        let gauge = minter::get_next_emission() - estimated_rebase();
        let expected_ratio = (gauge as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256);

        for_each(pools, |pool|{
            // Expected reward for a pool
            vector::push_back(
                &mut pool_rewards, ((weights(pool) as u256) * expected_ratio / (DXLYN_DECIMAL as u256) as u64)
            );
        });

        pool_rewards
    }

    #[view]
    /// Estimate the weekly rebase amount based on the epoch end veDXLYN power and total DXLYN supply.
    ///
    /// # Returns
    /// The estimated weekly rebase amount.
    public fun estimated_rebase(): u64 {
        // Rebase = weeklyEmissions * (1 - (veDXLYN.totalSupply / DXLYN.totalSupply) )^2 * 0.5
        // Get total DXLYN supply (10^8)
        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);

        // Get veDXLYN supply at start of next epoch (10^12)
        let ve_dxlyn_supply = (voting_escrow::total_supply(epoch_timestamp() + WEEK) as u256);

        // (1 - veDXLYN/DXLYN), scaled by 10^4
        let diff_scaled = AMOUNT_SCALE - (ve_dxlyn_supply / dxlyn_supply);

        // ( 10^4 * 10^4 * 10^4 -> 10^12 / 10^4 -> 10^8)
        let factor = ((diff_scaled * diff_scaled) * 5000) / AMOUNT_SCALE;

        let emission_amount = (minter::get_next_emission() as u256);

        // 10^8 * 10^8 -> 10^16 / 10^8 -> 10^8
        (((emission_amount * factor) / (DXLYN_DECIMAL as u256)) as u64)
    }


    #[view]
    /// Estimate the rebase rewards for a list of tokens based on their epoch end veDXLYN power.
    ///
    /// # Arguments
    /// * `tokens` - A vector of token addresses for which to estimate rebase rewards.
    ///
    /// # Returns
    /// A vector of estimated rebase rewards for each token.
    public fun estimated_rebase_for_tokens(tokens: vector<address>): vector<u64> {
        // veDXLYN power of the token at the start of next epoch
        let ve_dxlyn_supply = (voting_escrow::total_supply(epoch_timestamp() + WEEK) as u256);
        let token_rewards = vector::empty<u64>();

        if (ve_dxlyn_supply == 0) {
            return token_rewards
        };

        let estimated_weekly_rebase = (estimated_rebase() as u256);

        for_each(tokens, |token|{
            let token_ve_dxlyn_supply = (voting_escrow::balance_of(token, epoch_timestamp() + WEEK) as u256);
            // Expected reward for a pool
            vector::push_back(
                &mut token_rewards, (token_ve_dxlyn_supply * estimated_weekly_rebase / ve_dxlyn_supply as u64)
            );
        });

        token_rewards
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Returns the weight for a given pool at a specific epoch.
    ///
    /// * `weights_per_epoch` - Table mapping epoch (u64) to a table of pool addresses and their weights.
    /// * `time` - The target epoch.
    /// * `pool` - The pool address to look up the weight for.
    public(friend) fun weights_per_epoch_internal(
        weights_per_epoch: &Table<u64, Table<address, u64>>,
        time: u64,
        pool: address
    ): u64 {
        if (table::contains(weights_per_epoch, time)) {
            let epoch_weights = table::borrow(weights_per_epoch, time);
            if (table::contains(epoch_weights, pool)) {
                *table::borrow(epoch_weights, pool)
            } else { 0 }
        } else { 0 }
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    /// Internal function to reset votes
    /// # Arguments
    /// * `voter` - The mutable reference to the VoterV3 object.
    /// * `user` - The address of the user who call function.
    /// * `token` - The address of the nft token to reset votes for.
    fun reset_internal(voter: &mut Voter, user: address, token: address) {
        let pool_vote = table::borrow_mut(&mut voter.pool_vote, token);
        let time = epoch_timestamp();
        let total_weight: u64 = 0;

        let votes_table = table::borrow_mut(&mut voter.votes, token);

        smart_vector::for_each_ref(pool_vote, |pool_address| {
            let pool = *pool_address;
            let votes = table::borrow_mut_with_default(votes_table, pool, 0);
            if (*votes > 0) {
                // if token last vote is < than epochTimestamp then votes are 0! IF not underflow occur
                let last_voted = *table::borrow_with_default(&voter.last_voted, token, &0);
                if (last_voted > time) {
                    let epoch_weights =
                        table::borrow_mut(&mut voter.weights_per_epoch, time);
                    let pool_weight =
                        table::borrow_mut_with_default(epoch_weights, pool, 0);
                    //handel underflow
                    *pool_weight =
                        if (*pool_weight > *votes) {
                            *pool_weight - *votes
                        } else { 0 };
                };

                // Withdraw votes from bribes
                let gauge = table::borrow(&voter.gauges, pool);

                // only voter can call this function
                let voter_singer = object::generate_signer_for_extending(&voter.extended_ref);
                bribe::withdraw(
                    &voter_singer,
                    pool,
                    token,
                    *votes
                );

                // if is alive remove _votes, else don't because we already done it in kill_gauge()
                if (*table::borrow(&voter.is_alive, *gauge)) {
                    total_weight = total_weight + *votes;
                };

                // Emit Abstained event
                event::emit(
                    AbstainedEvent {
                        pool,
                        gauge: *gauge,
                        user,
                        token,
                        weight: *votes,
                        timestamp: timestamp::now_seconds(),
                        epoch: last_voted - 1
                    }
                );

                //handel underflow
                *votes = if (*votes > *votes) {
                    *votes - *votes
                } else { 0 };
            };
        });

        // if token last vote is < than epochTimestamp then _totalWeight is 0! IF not underflow occur
        if (*table::borrow_with_default(&voter.last_voted, token, &0) < time) {
            total_weight = 0;
        };

        let total_weights = table::borrow_mut_with_default(&mut voter.total_weights_per_epoch, time, 0);
        *total_weights = *total_weights - total_weight;

        // Clear pool_vote
        smart_vector::clear(pool_vote);
    }

    /// * `voter`: Voter resource
    /// * `owner`: The owner of the voter
    /// * `pool`: LP address
    fun create_gauge_internal(
        voter: &mut Voter,
        owner: &signer,
        pool: address
    ) {
        //check if pool is whitelisted or not
        //we converted token whitelist to pool whitelist
        assert!(*table::borrow_with_default(&voter.is_whitelisted, pool, &false), ERROR_POOL_NOT_WHITELISTED);

        let gauge_i = *table::borrow_with_default(&voter.gauges, pool, &@0x0);
        assert!(
            gauge_i != @0x0 && !table::contains(&voter.is_gauge, gauge_i),
            ERROR_GAUGE_ALREADY_EXIST_FOR_POOL
        );
        let owner_address = address_of(owner);

        let voter_signer = object::generate_signer_for_extending(&voter.extended_ref);

        //get the same address which create bribe function generate for external bribe for store in external_bribes
        let expected_external_bribe_address = get_external_bribe_address(pool);

        //created gauge for lp pool address assign voter as a distribution
        let distribution = address_of(&voter_signer);

        let gauge_type = *table::borrow(&voter.gauge_to_type, gauge_i);

        let gauge: address =
            if (gauge_type == CLMM_POOL) {
                gauge_clmm::create_gauge(
                    distribution,
                    expected_external_bribe_address,
                    pool
                )
            } else if (gauge_type == CPMM_POOL) {
                gauge_cpmm::create_gauge(
                    distribution,
                    expected_external_bribe_address,
                    pool,
                )
            } else {
                gauge_perp::create_gauge(
                    distribution,
                    expected_external_bribe_address,
                    pool,
                )
            };

        //create bribe and assign voter signer as a voter of bribe
        //TODO:Check need to go with current methodology or user other
        bribe::create_bribe(&voter_signer, address_of(&voter_signer), pool, gauge);

        //save data
        //update external bribe for gauge
        table::add(&mut voter.external_bribes, gauge, expected_external_bribe_address);

        //update gauge for pool
        table::add(&mut voter.pool_for_gauge, gauge, pool);

        table::add(&mut voter.is_gauge, gauge, true);

        table::add(&mut voter.is_alive, gauge, true);

        // add pool to existing pool list
        smart_vector::push_back(&mut voter.pools, pool);

        //update index
        // new gauges are set to the default global state

        table::add(&mut voter.supply_index, gauge, voter.index);

        event::emit(
            GaugeCreatedEvent {
                gauge,
                creator: owner_address,
                pool,
                external_bribe: expected_external_bribe_address,
                gauge_type
            }
        )
    }

    /// Internal function to distribute rewards for a specific gauge
    ///
    /// # Arguments
    /// * `voter` - The Voter resource.
    /// * `distribution` - The signer authorized to distribute rewards.
    /// * `gauge` - The address of the gauge for which rewards are to be distributed.
    /// * `gauge_type` - The gauge tye `CPMM = 0 & CLMM = 1` .
    ///
    /// # Dev
    /// This function is called by the distribute_all, distribute_range, and distribute_gauges functions.
    fun distribute_internal(
        voter: &mut Voter,
        distribution: &signer,
        gauge: address,
        gauge_type: u8
    ) {
        let last_timestamp =
            *table::borrow_with_default(
                &mut voter.gauges_distribution_timestamp, gauge, &0
            );

        let current_timestamp = epoch_timestamp();

        if (last_timestamp < current_timestamp) {
            // should set claimable to 0 if killed
            update_for_after_distribution(voter, gauge);

            let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
            if (*claimable <= 0) {
                return
            };

            let is_alive = *table::borrow(&voter.is_alive, gauge);
            // distribute only if claimable is > 0, currentEpoch != last epoch and gauge is alive
            if (*claimable > 0 && is_alive) {
                event::emit(
                    DistributeRewardEvent {
                        sender: address_of(distribution),
                        gauge,
                        amount: *claimable,
                        ecpoh: epoch_timestamp() - WEEK,
                        timestamp: timestamp::now_seconds()
                    }
                );

                // type based gauge notify dxlyn emission reward to gauge
                if (gauge_type == CLMM_POOL) {
                    gauge_clmm::notify_reward_amount(distribution, gauge, *claimable);
                } else if (gauge_type == CPMM_POOL) {
                    gauge_cpmm::notify_reward_amount(distribution, gauge, *claimable);
                } else {
                    gauge_perp::notify_reward_amount(distribution, gauge, *claimable);
                };

                *claimable = 0;
                table::upsert(
                    &mut voter.gauges_distribution_timestamp,
                    gauge,
                    current_timestamp
                );
            }
        }
    }

    /// Internal function to get the vote for a specific pool
    /// # Arguments
    /// * `voter` - The mutable reference to the VoterV3 object.
    /// * `user` - The address of the user who call function.
    /// * `token` - The address of the token from vote to submit.
    /// * `pool` - The address of the pool to get the vote for.
    /// * `weights` - The weights vector to store the weights for each pool.
    fun vote_internal(
        voter: &mut Voter,
        user: address,
        token: address,
        pool_vote: vector<address>,
        weights: vector<u64>
    ) {
        //Rest the previous vote before cast new one
        if (table::contains(&voter.pool_vote, token)) {
            reset_internal(voter, user, token);
        };
        //get current voting power
        let weight = voting_escrow::balance_of(token, timestamp::now_seconds());
        let total_vote_weight = 0;
        let total_weight = 0;
        let used_weight = 0;
        let time = epoch_timestamp();

        vector::enumerate_ref(&pool_vote, |index, pool| {
            let gauge = *table::borrow(&voter.gauges, *pool);
            let is_alive = *table::borrow_with_default(&voter.is_alive, gauge, &false);
            // Check if the gauge is alive and is a gauge alive add weight to the total vote weight other wise skip
            if (is_alive) {
                let weight_to_pool = *vector::borrow(&weights, index);
                total_vote_weight = total_vote_weight + weight_to_pool;
            }
        });

        assert!(total_vote_weight > 0, ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO);

        vector::enumerate_ref(&pool_vote, |index, pool| {
            let gauge = *table::borrow(&voter.gauges, *pool);
            let is_gauge = *table::borrow_with_default(&voter.is_gauge, gauge, &false);
            let is_alive = *table::borrow_with_default(&voter.is_alive, gauge, &false);

            if (is_gauge && is_alive) {
                let weight_to_pool = *vector::borrow(&weights, index);

                // Weight to assign to the pool
                // used u256 because of overflow (10^12 * 10^12) / (10^12)
                // case : when user vote and trying to poke same vote to next week that time weight_to_pool and total_vote_weight is in form of 10^12 for it will overflow
                let safe_pool_weight_calc: u256 =
                    (weight_to_pool as u256) * (weight as u256)
                        / (total_vote_weight as u256);
                let pool_weight = (safe_pool_weight_calc as u64);
                assert!(pool_weight > 0, ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO);

                //get pool votes for caller
                let votes = get_vote_internal(voter, token, *pool);

                //if vote found on the pool then assert (need to reset first)
                assert!(votes == 0, ERROR_VOTE_FOUND);
                assert!(pool_weight > 0, ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO);

                //add the new pool to users pool_vote
                //if token has no pool vote then add the new pool
                if (table::contains(&voter.pool_vote, token)) {
                    let pools = table::borrow_mut(&mut voter.pool_vote, token);
                    smart_vector::push_back(pools, *pool);
                } else {
                    let pools = smart_vector::new<address>();
                    smart_vector::push_back(&mut pools, *pool);
                    table::add(&mut voter.pool_vote, token, pools);
                };

                // Update the weights per epoch
                // if weight not found for time add new time and assign pool weight
                if (table::contains(&voter.weights_per_epoch, time)) {
                    let weight_per_epochs =
                        table::borrow_mut(&mut voter.weights_per_epoch, time);
                    let epoch_weight =
                        table::borrow_mut_with_default(weight_per_epochs, *pool, 0);
                    *epoch_weight = *epoch_weight + pool_weight;
                } else {
                    let weight_per_epochs = table::new<address, u64>();
                    table::add(&mut weight_per_epochs, *pool, pool_weight);
                    table::add(&mut voter.weights_per_epoch, time, weight_per_epochs);
                };

                // Update the token pool weight
                if (table::contains(&voter.votes, token)) {
                    let pool_weights =
                        table::borrow_mut(&mut voter.votes, token);
                    let pool_weight_i =
                        table::borrow_mut_with_default(pool_weights, *pool, 0);
                    *pool_weight_i = *pool_weight_i + pool_weight;
                } else {
                    let pool_weights = table::new<address, u64>();
                    table::add(&mut pool_weights, *pool, pool_weight);
                    table::add(&mut voter.votes, token, pool_weights);
                };

                // only voter can call this function
                let voter = object::generate_signer_for_extending(&voter.extended_ref);
                bribe::deposit(
                    &voter,
                    *pool,
                    token,
                    pool_weight
                );

                used_weight = used_weight + pool_weight;
                total_weight = total_weight + pool_weight;

                event::emit(
                    VotedEvent {
                        pool: *pool,
                        gauge,
                        user,
                        token,
                        weight: pool_weight,
                        timestamp: timestamp::now_seconds(),
                        epoch: time
                    }
                );
            }
        });

        if (used_weight > 0) {
            let voter = &object::generate_signer_for_extending(&voter.extended_ref);
            // Call abstain on voting escrow
            // only voter can call this function
            voting_escrow::voting(voter, token);
        };

        let total_weights_per_epoch =
            table::borrow_mut_with_default(&mut voter.total_weights_per_epoch, time, 0);
        *total_weights_per_epoch = *total_weights_per_epoch + total_weight;
    }

    /// Update info for gauges
    ///
    /// # Arguments
    /// * `voter` - The Voter resource.
    /// * `gauge` - The address of the gauge to update.
    /// # Dev
    /// This function track the gauge index to emit the correct DXLYN amount after the distribution
    fun update_for_after_distribution(
        voter: &mut Voter, gauge: address
    ) {
        let pool = table::borrow(&voter.pool_for_gauge, gauge);
        let time = epoch_timestamp() - WEEK;
        let supplied = weights_per_epoch_internal(
            &voter.weights_per_epoch, time, *pool
        );

        if (supplied > 0) {
            let supply_index = *table::borrow_with_default(&voter.supply_index, gauge, &0);
            // get global index0 for accumulated distro
            let index = voter.index;
            // update gauge current position to global position
            table::upsert(&mut voter.supply_index, gauge, index);

            // see if there is any difference that need to be accrued
            let delta = index - supply_index;

            if (delta > 0) {
                // add accrued difference for each supplied token
                // use u256 to avoid overflow in case of large numbers
                let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);

                let is_alive = *table::borrow(&voter.is_alive, gauge);
                if (is_alive) {
                    let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
                    *claimable = *claimable + share;
                }
            }
        } else {
            // new users are set to the default global state
            table::upsert(&mut voter.supply_index, gauge, voter.index);
        }
    }

    /// Returns the vote for a given pool.
    /// * `voter` - The Voter resource.
    /// * `caller_address` - The address of the user.
    /// * `pool` - Address used to identify the vote.
    fun get_vote_internal(
        voter: &Voter, token: address, pool: address
    ): u64 {
        if (!table::contains(&voter.votes, token)) {
            return 0
        };

        let votes_table = table::borrow(&voter.votes, token);
        *table::borrow_with_default(votes_table, pool, &0)
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    friend dexlyn_tokenomics::bribe_test;
    #[test_only]
    friend dexlyn_tokenomics::test_emission;
    #[test_only]
    friend dexlyn_tokenomics::voter_cpmm_test;

    #[test_only]
    public fun initialize(res: &signer) {
        init_module(res);

        // set minter contract as a minter of dexlyn_coin
        let minter = minter::get_minter_object_address();
        dxlyn_coin::commit_transfer_minter(res, minter);
        dxlyn_coin::apply_transfer_minter(res);
        minter::first_mint(res);

        let voter_address = get_voter_address();

        bribe::set_bribe_sys_owner(res, voter_address);
        //set voter as a voter of voting escrow contract
        voting_escrow::set_voter(res, voter_address);
    }

    #[test_only]
    public fun get_voter_state(): (address, address, address, address, u64, u64, u64) acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global_mut<Voter>(voter_address);

        (
            voter.owner,
            voter.voter_admin,
            voter.governance,
            voter.minter,
            voter.index,
            voter.vote_delay,
            primary_fungible_store::balance(voter_address, address_to_object<Metadata>(voter.dxlyn_coin_address))
        )
    }

    // Helper function to check is_whitelisted status
    #[test_only]
    public fun is_pool_whitelisted(pool_address: address): bool acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.is_whitelisted, pool_address, &false)
    }

    // Helper function to check if a gauge exists for a pool
    #[test_only]
    public fun is_gauge_for_pool(pool_address: address): bool acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        table::contains(&voter.gauges, pool_address)
    }

    // Helper function to get gauge address for a pool
    #[test_only]
    public fun get_gauge_for_pool(pool_address: address): address acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.gauges, pool_address, &@0x0)
    }

    // Helper function to get pool address for a gauge
    #[test_only]
    public fun get_pool_for_gauge(gauge_address: address): address acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.pool_for_gauge, gauge_address, &@0x0)
    }

    // Helper function to check if an address is a valid gauge
    #[test_only]
    public fun is_gauge_valid(gauge_address: address): bool acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.is_gauge, gauge_address, &false)
    }

    // Helper function to check if a gauge is alive
    #[test_only]
    public fun is_gauge_alive(gauge_address: address): bool acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.is_alive, gauge_address, &false)
    }

    // Helper function to get supply index for a gauge
    #[test_only]
    public fun get_supply_index(gauge_address: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.supply_index, gauge_address, &0)
    }

    // Helper function to check if a pool is in the pools vector
    #[test_only]
    public fun is_pool_in_pools(pool_address: address): bool acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        smart_vector::contains(&voter.pools, &pool_address)
    }

    // Helper function to get external bribe address for a gauge
    #[test_only]
    public fun get_external_bribe(gauge_address: address): address acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.external_bribes, gauge_address, &@0x0)
    }

    #[test_only]
    public fun get_claimable(gauge_address: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.claimable, gauge_address, &0)
    }

    #[test_only]
    public fun get_votes(token: address, pool: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        get_vote_internal(voter, token, pool)
    }

    #[test_only]
    public fun get_last_voted(token: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(&voter.last_voted, token, &0)
    }

    #[test_only]
    public fun get_gauges_distribution_timestamp(gauge_address: address): u64 acquires Voter {
        let voter_address = get_voter_address();
        let voter = borrow_global<Voter>(voter_address);
        *table::borrow_with_default(
            &voter.gauges_distribution_timestamp, gauge_address, &0
        )
    }
}
