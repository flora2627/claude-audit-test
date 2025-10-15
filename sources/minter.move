module dexlyn_tokenomics::minter {
    use std::signer::address_of;

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::event;
    use supra_framework::object::{Self, ExtendRef, object_address};
    use supra_framework::timestamp;

    use dexlyn_tokenomics::emission;
    use dexlyn_tokenomics::voting_escrow;

    friend dexlyn_tokenomics::voter;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator address of the minter object account
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// The seed used to create the minter object account
    const MINTER_OBJECT_ACCOUNT_SEED: vector<u8> = b"MINTER";

    /// Week in seconds
    const WEEK: u64 = 604800;

    /// Amount scale for calculations
    const AMOUNT_SCALE: u256 = 10000;

    /// The number of decimals in a DXLYN token (10^8)
    const DXLYN_DECIMAL: u64 = 100_000_000;

    /// Initial supply of DXLYN token
    const INITIAL_SUPPLY: u64 = 100_000_000;

    /// Initial rate in basis points (bps) for the DXLYN token emission
    const INITIAL_RATE_BPS: u64 = 2;

    /// Decay rate in basis points (bps) for the DXLYN token emission
    const DECAY_RATE_BPS: u64 = 1;

    /// The epoch at which the decay starts
    const DECAY_START_EPOCH: u64 = 13;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Insufficient DXLYN balance to perform the operation
    const ERROR_INSUFFICIENT_BALANCE: u64 = 101;

    /// Caller must be the owner to perform this operation
    const ERROR_NOT_OWNER: u64 = 102;

    /// DXLYN info not set up yet
    const ERROR_DXLYN_INFO_NOT_FOUND: u64 = 103;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    #[event]
    /// Event emitted when owner changed
    struct SetOwnerEvent has drop, store {
        old_owner: address,
        new_owner: address,
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    struct DxlynInfo has key {
        extend_ref: ExtendRef,
        period: u64,
        owner: address,
        vesting_admin: address,
        is_initialized: bool,
        asset_object_address: address
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initialize module - as initialize dxlyn token
    public(friend) fun initialize(token_admin: &signer) {
        let constructor_ref =
            &object::create_named_object(token_admin, MINTER_OBJECT_ACCOUNT_SEED);

        let extend_ref = object::generate_extend_ref(constructor_ref);

        let minter_obj_signer = object::generate_signer(constructor_ref);
        let active_period = ((timestamp::now_seconds(
        ) + (2 * WEEK)) / WEEK) * WEEK; // Mimics MinterUpgradeable.initialize

        // Initialize emission
        emission::initialized_emission(
            &minter_obj_signer,
            @emission_admin,
            INITIAL_SUPPLY * DXLYN_DECIMAL,
            INITIAL_RATE_BPS,
            DECAY_RATE_BPS,
            DECAY_START_EPOCH,
        );

        move_to(
            &minter_obj_signer,
            DxlynInfo {
                extend_ref,
                period: active_period,
                owner: @owner,
                vesting_admin: @vesting_admin,
                asset_object_address: object_address(&dxlyn_coin::get_dxlyn_asset_metadata()),
                is_initialized: false
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

    /// Perform the first mint of tokens (owner only)
    ///
    /// # Arguments
    /// * `deployer` - Reference to the signer initiating the first mint (must be the contract owner)
    ///
    public entry fun first_mint(deployer: &signer) acquires DxlynInfo {
        let object_add = get_minter_object_address();
        assert!(exists<DxlynInfo>(object_add), ERROR_DXLYN_INFO_NOT_FOUND);

        let dxlyn_info = borrow_global_mut<DxlynInfo>(object_add);
        assert!(dxlyn_info.owner == address_of(deployer), ERROR_NOT_OWNER);

        if (!dxlyn_info.is_initialized) {
            dxlyn_info.period = (timestamp::now_seconds() / WEEK) * WEEK;
            dxlyn_info.is_initialized = true
        }
    }


    /// Set owner
    ///
    /// # Arguments
    /// * `owner` - Reference to the current owner's signer
    /// * `new_owner` - Address of the new owner to be assigned
    ///
    public entry fun set_owner(owner: &signer, new_owner: address) acquires DxlynInfo {
        let dxlyn_obj_addr = get_minter_object_address();
        assert!(exists<DxlynInfo>(dxlyn_obj_addr), ERROR_DXLYN_INFO_NOT_FOUND);

        let dxlyn_info = borrow_global_mut<DxlynInfo>(dxlyn_obj_addr);
        let owner_addr = address_of(owner);
        assert!(dxlyn_info.owner == owner_addr, ERROR_NOT_OWNER);

        event::emit(SetOwnerEvent {
            old_owner: owner_addr,
            new_owner
        });

        dxlyn_info.owner = new_owner;
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get current active emission period
    ///
    /// # Returns
    /// * `u64` - The current active period timestamp
    ///
    public fun active_period(): u64 acquires DxlynInfo {
        let dxlyn_addr = get_minter_object_address();
        assert!(exists<DxlynInfo>(dxlyn_addr), ERROR_DXLYN_INFO_NOT_FOUND);
        let active_period = borrow_global_mut<DxlynInfo>(dxlyn_addr);
        active_period.period
    }

    #[view]
    /// Get next week's projected emission amount
    ///
    /// # Returns
    /// * `u64` - Projected emission amount for the next week (epoch offset = 1)
    ///
    public fun get_next_emission(): u64 {
        let dxlyn_coin_address = get_minter_object_address();
        emission::get_emission(dxlyn_coin_address, 1) // For next week emission
    }

    #[view]
    /// Get last recorded emission amount
    ///
    /// # Returns
    /// * `u64` - Last recorded emission amount from the emission schedule
    ///
    public fun get_previous_emission(): u64 {
        let dxlyn_coin_address = get_minter_object_address();
        let (_, _, _, _, _, _, _, last_emission) =
            emission::get_emission_schedule(dxlyn_coin_address);
        last_emission
    }

    #[view]
    /// Create and get the minter object address
    ///
    /// # Returns
    /// * `address` - The address of the `DxlynInfo` minter object
    ///
    public fun get_minter_object_address(): address {
        object::create_object_address(&SC_ADMIN, MINTER_OBJECT_ACCOUNT_SEED)
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Set active period
    ///
    /// # Arguments
    /// * `period` - The new active period (typically a timestamp aligned to weekly boundaries)
    ///
    public(friend) fun set_active_period(period: u64) acquires DxlynInfo {
        let dxlyn_addr = get_minter_object_address();
        assert!(exists<DxlynInfo>(dxlyn_addr), ERROR_DXLYN_INFO_NOT_FOUND);

        let active_period = borrow_global_mut<DxlynInfo>(dxlyn_addr);
        active_period.period = period;
    }

    /// Calculate the rebase and gauge
    /// # Returns:
    /// - (rebase: u64, gauge: u64, dxlyn_signer: signer)
    public(friend) fun calculate_rebase_gauge(): (u64, u64, signer, bool) acquires DxlynInfo {
        let dxlyn_obj_addr = get_minter_object_address();
        assert!(exists<DxlynInfo>(dxlyn_obj_addr), ERROR_DXLYN_INFO_NOT_FOUND);

        let dxlyn_info = borrow_global_mut<DxlynInfo>(dxlyn_obj_addr);
        let dxlyn_signer = object::generate_signer_for_extending(&dxlyn_info.extend_ref);
        let current_time = timestamp::now_seconds();

        if (current_time >= dxlyn_info.period + WEEK && dxlyn_info.is_initialized) {
            dxlyn_info.period = (current_time / WEEK) * WEEK;

            let weekly_emission = emission::weekly_emission(dxlyn_obj_addr);

            let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
            let dxlyn_supply = (dxlyn_coin::total_supply() as u256);

            let rebase = if (ve_supply <= 0 || dxlyn_supply <= 0) {
                0
            }else {
                // Rebase = weeklyEmissions * (1 - (veDXLYN.totalSupply / DXLYN.totalSupply) )^2 * 0.5
                // (1 - veDXLYN/DXLYN), scaled by 10^4
                let diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply);

                // ( 10^4 * 10^4 * 10^4 -> 10^12 / 10^4 -> 10^8)
                let factor = ((diff_scaled * diff_scaled) * 5000) / AMOUNT_SCALE;

                // 10^8 * 10^8 -> 10^16 / 10^8 -> 10^8
                ((((weekly_emission as u256) * factor) / (DXLYN_DECIMAL as u256)) as u64)
            };

            let gauge = weekly_emission - rebase;

            // Mint weekly emission and rebase amount
            dxlyn_coin::mint(&dxlyn_signer, dxlyn_obj_addr, weekly_emission);

            (rebase, gauge, dxlyn_signer, true)
        } else {
            (0, 0, dxlyn_signer, false)
        }
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
    friend dexlyn_tokenomics::gauge_clmm_test;
    #[test_only]
    friend dexlyn_tokenomics::gauge_perp_test;
    #[test_only]
    friend dexlyn_tokenomics::test_emission;
    #[test_only]
    friend dexlyn_tokenomics::voter_cpmm_test;
    #[test_only]
    friend dexlyn_tokenomics::voter_clmm_test;
    #[test_only]
    friend dexlyn_tokenomics::gauge_cpmm_test;

    #[test_only]
    /// `calculate_rebase` function's internal calculation
    ///
    /// # Arguments
    /// * `ve_supply` - Total supply of vote-escrowed tokens (veDXLYN-Tokens) as `u256`
    /// * `dxlyn_supply` - Total circulating supply of the DXLYN token as `u256`
    /// * `emission_amount` - Total emission amount being distributed as `u256`
    ///
    /// # Returns
    /// * `u64` - The calculated rebase amount to be distributed to veDXLYN holders
    ///
    fun calculate_rebase_internal(
        ve_supply: u256, dxlyn_supply: u256, emission_amount: u256
    ): u64 {
        if (ve_supply <= 0 || dxlyn_supply <= 0) {
            0
        }else {
            // As dxlyn has 12 decimal
            let scaled_dxlyn = dxlyn_supply * AMOUNT_SCALE;

            // Step 1: diff = veDex / dex (scaled by 10000)
            let diff_scaled = (ve_supply * AMOUNT_SCALE) / scaled_dxlyn;

            // Step 2: oneMi = 1 - diff
            let one_minus_diff = AMOUNT_SCALE - diff_scaled;

            // Step 3: oneMi2 = oneMi * oneMi
            let one_minus_diff_squared = (one_minus_diff * one_minus_diff) / AMOUNT_SCALE;

            // Step 4: Five = oneMi2 * 0.5
            let factor = (one_minus_diff_squared * 5000) / AMOUNT_SCALE;

            // Step 5: result = emi * Five
            ((((emission_amount) * factor) / AMOUNT_SCALE) as u64)
        }
    }

    #[test_only]
    public fun test_initialize(signer: &signer) {
        initialize(signer);
    }

    #[test_only]
    public fun test_calculate_rebase(
        ve_supply: u256, // veDex (12 decimals)
        dxlyn_supply: u256, // dex (8 decimals)
        emission_amount: u256 // emi (8 decimals)
    ): u64 {
        if (ve_supply <= 0 || dxlyn_supply <= 0) {
            return 0
        };

        calculate_rebase_internal(ve_supply, dxlyn_supply, emission_amount)
    }

    #[test_only]
    public fun test_calculate_rebase2(
        emission_amount: u256 // emi (8 decimals)
    ): u64 {
        let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
        let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
        test_calculate_rebase(ve_supply, dxlyn_supply, emission_amount)
    }

    #[test_only]
    public fun test_calculate_rebase_gauge(): (u64, u64, signer, bool) acquires DxlynInfo {
        calculate_rebase_gauge()
    }
}
