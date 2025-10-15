module dexlyn_tokenomics::emission {
    use std::signer::address_of;
    use aptos_std::table::{Self, Table};

    use supra_framework::event;
    use supra_framework::object;
    use supra_framework::timestamp;

    friend dexlyn_tokenomics::minter;


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Creator address of the emission object account
    const SC_ADMIN: address = @dexlyn_tokenomics;

    /// This should be always same as the minter MINTER_OBJECT_ACCOUNT_SEED
    const MINTER_OBJECT_ACCOUNT_SEED: vector<u8> = b"MINTER";

    /// 604800 (Week in seconds)
    const EPOCH: u64 = 604800;

    /// Basis points denominator
    const BPS_DENOMINATOR: u64 = 100;


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Emission schedule already setuped
    const ERROR_EMISSION_SCHEDULE_ALREADY_EXIST: u64 = 101;

    /// Emission schedule must be initialized first
    const ERROR_EMISSION_SCHEDULE_NOT_EXIST: u64 = 102;

    /// Initial supply must be greater than zero
    const ERROR_ZERO_INITIAL_SUPPLY: u64 = 103;

    /// Rate basis point is invalid ( it must be > 0 and < 10000 )
    const ERROR_INVALID_RATE: u64 = 104;

    /// Decay must start at 1 or later epoch
    const ERROR_DECAY_START_TOO_EARLY: u64 = 105;

    /// Calller must be the admin to perform this action
    const ERROR_NOT_ADMIN: u64 = 106;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// EmissionEvent is emitted when emissions are calculated for an epoch
    struct EmissionEvent has store, drop {
        epoch: u64,
        emission_amount: u64,
        total_emitted: u64,
        emission_rate: u64,
        timestamp: u64
    }

    #[event]
    /// EmissionPausedEvent is emitted when emissions are paused or unpaused
    struct EmissionPausedEvent has store, drop {
        paused: bool,
        timestamp: u64
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Emission record for a specific epoch
    struct EmissionRecord has store, copy, drop {
        emission_amount: u64,
        emission_rate: u64,
        timestamp: u64
    }

    /// Main emission schedule configuration
    struct EmissionSchedule has key {
        initial_supply: u64,
        initial_rate_bps: u64,
        decay_rate_bps: u64,
        decay_start_epoch: u64,
        total_emitted: u64,
        emissions_by_epoch: Table<u64, EmissionRecord>,
        epoch_counter: u64,
        created_at: u64,
        last_emission: u64,
        is_paused: bool,
        admin: address
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                              ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Pause or unpause emissions (admin only)
    ///
    /// # Arguments
    /// * `admin` - The current admin signer.
    /// * `paused` - True to pause emissions, false to unpause
    public entry fun set_emission_pause(admin: &signer, paused: bool) acquires EmissionSchedule {
        let addr = object::create_object_address(&SC_ADMIN, MINTER_OBJECT_ACCOUNT_SEED);

        let schedule = borrow_global_mut<EmissionSchedule>(addr);

        assert!(address_of(admin) == schedule.admin, ERROR_NOT_ADMIN);

        schedule.is_paused = paused;

        event::emit(EmissionPausedEvent { paused, timestamp: timestamp::now_seconds() });
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[view]
    /// Get comprehensive emission schedule details
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    public fun get_emission_schedule(
        addr: address
    ): (u64, u64, u64, u64, u64, u64, bool, u64) acquires EmissionSchedule {
        let schedule = borrow_global<EmissionSchedule>(addr);
        (
            schedule.initial_supply,
            schedule.initial_rate_bps,
            schedule.decay_rate_bps,
            schedule.decay_start_epoch,
            schedule.total_emitted,
            schedule.epoch_counter,
            schedule.is_paused,
            schedule.last_emission,
        )
    }

    #[view]
    /// Get emission record for specific epoch
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    /// * `epoch` - Epoch number
    public fun get_emission_record(addr: address, epoch: u64): (u64, u64, u64) acquires EmissionSchedule {
        let schedule = borrow_global<EmissionSchedule>(addr);
        if (table::contains(&schedule.emissions_by_epoch, epoch)) {
            let record = table::borrow(&schedule.emissions_by_epoch, epoch);
            (record.emission_amount, record.emission_rate, record.timestamp)
        } else {
            (0, 0, 0)
        }
    }

    #[view]
    /// Get number of epochs passed since emission started
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    public fun get_emission_epoch_count(addr: address): u64 acquires EmissionSchedule {
        let schedule = borrow_global<EmissionSchedule>(addr);
        (timestamp::now_seconds() - schedule.created_at) / EPOCH
    }

    #[view]
    /// Get total emissions that should be released up to current time
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    public fun get_pending_emissions(addr: address): u64 acquires EmissionSchedule {
        let schedule = borrow_global<EmissionSchedule>(addr);
        let current_epoch_offset = (timestamp::now_seconds() - schedule.created_at) / EPOCH;

        if (current_epoch_offset <= schedule.epoch_counter) { 0 }
        else {
            current_epoch_offset - schedule.epoch_counter
        }
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                             FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initialize emission schedule with parameter validation
    ///
    /// # Arguments
    /// * `dxlyn_obj_signer` - Signer of the emission object account
    /// * `admin` - Admin address of the emission schedule
    /// * `initial_supply` - Initial supply of the emission schedule
    /// * `initial_rate_bps` - Initial emission rate in basis points
    /// * `decay_rate_bps` - Decay rate in basis points
    /// * `decay_start_epoch` - Epoch at which decay starts
    public(friend) fun initialized_emission(
        dxlyn_obj_signer: &signer,
        admin: address,
        initial_supply: u64,
        initial_rate_bps: u64,
        decay_rate_bps: u64,
        decay_start_epoch: u64
    ) {
        // Parameter validation
        assert_zero_init_supply(initial_supply);
        assert_rate_bps(initial_rate_bps);
        assert_rate_bps(decay_rate_bps);
        assert_decay_start_epoch(decay_start_epoch);

        assert!(
            !exists<EmissionSchedule>(address_of(dxlyn_obj_signer)),
            ERROR_EMISSION_SCHEDULE_ALREADY_EXIST
        );

        let current_time = timestamp::now_seconds();
        // adjust time to current epoch
        let current_epoch = current_time / EPOCH * EPOCH;

        move_to(
            dxlyn_obj_signer,
            EmissionSchedule {
                initial_supply,
                initial_rate_bps,
                decay_rate_bps,
                decay_start_epoch,
                total_emitted: 0,
                epoch_counter: 0,
                emissions_by_epoch: table::new<u64, EmissionRecord>(),
                created_at: current_epoch,
                last_emission: 0,
                is_paused: false,
                admin
            }
        );
    }

    /// Optimized emission calculation with overflow protection
    ///
    /// # Arguments
    /// * `last_emission` - Last emission amount
    /// * `initial_supply` - Initial supply of the emission schedule
    /// * `initial_rate_bps` - Initial emission rate in basis points
    /// * `decay_rate_bps` - Decay rate in basis points
    /// * `decay_start_epoch` - Epoch at which decay starts
    /// * `current_epoch` - Current epoch
    public(friend) fun calculate_emission(
        last_emission: u64,
        initial_supply: u64,
        initial_rate_bps: u64,
        decay_rate_bps: u64,
        decay_start_epoch: u64,
        current_epoch: u64
    ): u64 {
        let bps_denominator = BPS_DENOMINATOR;
        if (last_emission == 0) {
            // First emission: initial_supply * rate / 10000
            let (result, _) = calculate_with_overflow_check(initial_supply, initial_rate_bps);
            result / bps_denominator
        } else if (current_epoch >= decay_start_epoch) {
            // Decay phase: last_emission * (10000 - decay_rate) / 10000
            let decay_multiplier = bps_denominator - decay_rate_bps;

            let (result, _) = calculate_with_overflow_check(last_emission, decay_multiplier);
            result / bps_denominator
        } else {
            // Growth phase: last_emission * (1 + rate)
            let growth_multiplier = bps_denominator + initial_rate_bps;
            let (result, _) = calculate_with_overflow_check(last_emission, growth_multiplier);
            result / bps_denominator
        }
    }

    /// Calculate the current week emission
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    public(friend) fun weekly_emission(addr: address): u64 acquires EmissionSchedule {
        assert_emission_schedule_exists(&addr);

        let schedule = borrow_global_mut<EmissionSchedule>(addr);
        let _calculated_emission = 0;
        let current_time = timestamp::now_seconds();

        // First emission
        if (schedule.last_emission == 0) {
            let (result, _) = calculate_with_overflow_check(schedule.initial_supply, schedule.initial_rate_bps);

            _calculated_emission = result / BPS_DENOMINATOR;

            schedule.last_emission = _calculated_emission;
        } else {
            let current_epoch = (current_time - schedule.created_at) / EPOCH;

            let emission = calculate_emission(
                schedule.last_emission,
                schedule.initial_supply,
                schedule.initial_rate_bps,
                schedule.decay_rate_bps,
                schedule.decay_start_epoch,
                current_epoch
            );
            schedule.total_emitted = schedule.total_emitted + emission;
            schedule.last_emission = emission;
            _calculated_emission = emission;
        };

        // Store emission record with timestamp
        schedule.total_emitted = schedule.total_emitted + _calculated_emission;
        schedule.epoch_counter = schedule.epoch_counter + 1;

        let emission_rate =
            if (schedule.epoch_counter >= schedule.decay_start_epoch) {
                schedule.decay_rate_bps
            } else {
                schedule.initial_rate_bps
            };

        // Store emission record with timestamp
        table::upsert(
            &mut schedule.emissions_by_epoch,
            schedule.epoch_counter,
            EmissionRecord {
                emission_amount: _calculated_emission,
                emission_rate,
                timestamp: current_time
            }
        );

        // Emit event for each epoch
        event::emit(
            EmissionEvent {
                epoch: schedule.epoch_counter,
                emission_amount: _calculated_emission,
                total_emitted: schedule.total_emitted,
                emission_rate,
                timestamp: current_time
            }
        );

        _calculated_emission
    }

    /// Calculate `count` + `EPOCH` emission
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    /// * `count` - Number of epochs
    public(friend) fun get_emission(addr: address, count: u64): u64 acquires EmissionSchedule {
        assert_emission_schedule_exists(&addr);

        let schedule = borrow_global<EmissionSchedule>(addr);
        
        let current_epoch = ((timestamp::now_seconds() - schedule.created_at) / EPOCH) + count;

        calculate_emission(
            schedule.last_emission,
            schedule.initial_supply,
            schedule.initial_rate_bps,
            schedule.decay_rate_bps,
            schedule.decay_start_epoch,
            current_epoch
        )
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Helper function to check for overflow in multiplication
    ///
    /// # Arguments
    /// * `a` - First operand
    /// * `b` - Second operand
    fun calculate_with_overflow_check(a: u64, b: u64): (u64, bool) {
        let max_u64 = 18446744073709551615u64;
        if (a == 0 || b == 0) {
            return (0, false)
        };

        if (a > max_u64 / b) {
            // Overflow would occur
            (max_u64, true)
        } else {
            (a * b, false)
        }
    }

    /// Assert that initial supply is not zero
    ///
    /// # Arguments
    /// * `initial_supply` - Initial supply
    fun assert_zero_init_supply(initial_supply: u64) {
        assert!(initial_supply > 0, ERROR_ZERO_INITIAL_SUPPLY);
    }

    /// Assert that rate bps is valid
    ///
    /// # Arguments
    /// * `rate_bps` - Rate bps
    fun assert_rate_bps(rate_bps: u64) {
        assert!(
            rate_bps > 0 && rate_bps < BPS_DENOMINATOR,
            ERROR_INVALID_RATE
        );
    }

    /// Assert that decay starts with valid epoch
    ///
    /// # Arguments
    /// * `decay_start_epoch` - Decay start epoch
    fun assert_decay_start_epoch(decay_start_epoch: u64) {
        assert!(decay_start_epoch >= 1, ERROR_DECAY_START_TOO_EARLY);
    }

    /// Assert that emission schedule is exists
    ///
    /// # Arguments
    /// * `addr` - Address of the emission schedule
    fun assert_emission_schedule_exists(addr: &address) {
        assert!(exists<EmissionSchedule>(*addr), ERROR_EMISSION_SCHEDULE_NOT_EXIST);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[test_only]
    friend dexlyn_tokenomics::test_emission;

    #[test_only]
    public fun test_initialized_emission(
        dxlyn_obj_signer: &signer,
        admin: address,
        initial_supply: u64,
        initial_rate_bps: u64,
        decay_rate_bps: u64,
        decay_start_epoch: u64
    ) {
        initialized_emission(
            dxlyn_obj_signer,
            admin,
            initial_supply,
            initial_rate_bps,
            decay_rate_bps,
            decay_start_epoch
        );
    }

    #[test_only]
    /// Emit tokens for current eligible epochs with pause functionality
    public fun emit_tokens(addr: &address) acquires EmissionSchedule {
        let schedule = borrow_global_mut<EmissionSchedule>(*addr);

        // Check if emissions are paused
        if (schedule.is_paused) { return };

        let current_epoch_offset = (timestamp::now_seconds() - schedule.created_at)
            / EPOCH;

        if (current_epoch_offset <= schedule.epoch_counter) { return };

        let epoch = schedule.epoch_counter + 1;
        let current_timestamp = timestamp::now_seconds();

        while (epoch <= current_epoch_offset) {
            let emission_amount =
                calculate_emission(
                    schedule.last_emission,
                    schedule.initial_supply,
                    schedule.initial_rate_bps,
                    schedule.decay_rate_bps,
                    schedule.decay_start_epoch,
                    epoch
                );

            let emission_rate =
                if (epoch >= schedule.decay_start_epoch) {
                    schedule.decay_rate_bps
                } else {
                    schedule.initial_rate_bps
                };

            // Store emission record with timestamp
            table::upsert(
                &mut schedule.emissions_by_epoch,
                epoch,
                EmissionRecord {
                    emission_amount,
                    emission_rate,
                    timestamp: current_timestamp
                }
            );

            schedule.total_emitted = schedule.total_emitted + emission_amount;
            schedule.last_emission = emission_amount;

            // Emit event for each epoch
            event::emit(
                EmissionEvent {
                    epoch,
                    emission_amount,
                    total_emitted: schedule.total_emitted,
                    emission_rate,
                    timestamp: current_timestamp
                }
            );

            epoch = epoch + 1;
        };

        // Update epoch_counter to last emitted epoch
        schedule.epoch_counter = current_epoch_offset;
    }
}
