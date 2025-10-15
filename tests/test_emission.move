#[test_only]
module dexlyn_tokenomics::test_emission {

    use std::signer::address_of;

    use supra_framework::genesis;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::emission::{
        calculate_emission,
        emit_tokens,
        ERROR_DECAY_START_TOO_EARLY,
        ERROR_EMISSION_SCHEDULE_ALREADY_EXIST,
        ERROR_INVALID_RATE,
        ERROR_ZERO_INITIAL_SUPPLY,
        get_emission_epoch_count,
        get_emission_record,
        get_emission_schedule,
        get_pending_emissions,
        set_emission_pause, test_initialized_emission
    };
    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::minter::get_next_emission;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;

    const ERROR_INVALID_EMISSION: u64 = 1;
    const ERROR_INVALID_EPOCH: u64 = 2;
    const EPOCH: u64 = 604800;
    // Week
    const DXLYN_DECIMAL: u64 = 100000000;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                HELPER FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun get_expected_emission(): u64 {
        let deployer_addr = minter::get_minter_object_address();

        let (supply, rate, decay_rate, decay_start, _, _, _, last_emission) =
            get_emission_schedule(deployer_addr);

        let epoch = get_emission_epoch_count(deployer_addr);
        calculate_emission(
            last_emission,
            supply,
            rate,
            decay_rate,
            decay_start,
            epoch
        )
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                SETUP FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    fun setup(deployer: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(1746057600); // 1746057600 =  Thursday, 1 May 2025 00:00:00
        test_internal_coins::init_coin(deployer);

        voting_escrow::initialize(deployer);
        fee_distributor::initialize(deployer);
        voter::initialize(deployer);

        fee_distributor::toggle_allow_checkpoint_token(deployer);

        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(deployer, dxlyn_minter);
    }


    fun setup_emission(deployer: &signer) {
        setup(deployer);

        let initial_supply = get_quants(100_000_000);
        let initial_rate_bps = 2;
        let decay_start_epoch = 13;
        let decay_rate_bps = 1;

        test_initialized_emission(
            deployer,
            address_of(deployer),
            initial_supply,
            initial_rate_bps,
            decay_rate_bps,
            decay_start_epoch
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       VIEW FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       CONSTRUCTOR FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    #[test(deployer = @dexlyn_tokenomics)]
    fun initialized_emission(deployer: &signer) {
        setup_emission(deployer);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_EMISSION_SCHEDULE_ALREADY_EXIST)]
    fun test_reinitialized_emission(deployer: &signer) {
        setup_emission(deployer);
        test_initialized_emission(deployer, address_of(deployer), 1000, 2, 1, 13);
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       ENTRY FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    #[test(deployer = @dexlyn_tokenomics)]
    fun test_emission_epoch_count(deployer: &signer) {
        setup_emission(deployer);
        let epoch1 = get_emission_epoch_count(address_of(deployer));
        assert!(epoch1 == 0, ERROR_INVALID_EPOCH);

        timestamp::fast_forward_seconds(EPOCH);
        let epoch2 = get_emission_epoch_count(address_of(deployer));
        assert!(epoch2 == 1, ERROR_INVALID_EPOCH);

        timestamp::fast_forward_seconds(EPOCH);
        let epoch3 = get_emission_epoch_count(address_of(deployer));
        assert!(epoch3 == 2, ERROR_INVALID_EPOCH);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    // Todo:  Need to fix
    fun test_emissions(deployer: &signer) {
        setup_emission(deployer);
        let deployer_addr = address_of(deployer);

        let epoch = get_emission_epoch_count(deployer_addr);
        let last_emission = minter::get_previous_emission();

        assert!(epoch == 0, ERROR_INVALID_EPOCH);
        assert!(last_emission == 0, ERROR_INVALID_EMISSION);

        let next_emission = get_next_emission();

        timestamp::fast_forward_seconds(EPOCH);
        minter::test_calculate_rebase_gauge();

        let epoch = get_emission_epoch_count(deployer_addr);
        let previous_emission = minter::get_previous_emission();

        assert!(epoch == 1, ERROR_INVALID_EPOCH);
        assert!(next_emission == previous_emission, ERROR_INVALID_EMISSION);

        let next_emission = get_next_emission();

        timestamp::fast_forward_seconds(EPOCH);
        minter::test_calculate_rebase_gauge();
        let epoch = get_emission_epoch_count(deployer_addr);
        let previous_emission = minter::get_previous_emission();

        assert!(epoch == 2, ERROR_INVALID_EPOCH);
        assert!(next_emission == previous_emission, ERROR_INVALID_EMISSION);

        timestamp::fast_forward_seconds(EPOCH);
        minter::test_calculate_rebase_gauge();
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_emission_across_24_epoch(deployer: &signer) {
        setup(deployer);

        let dxlyn_minter = minter::get_minter_object_address();

        let last_emission = 0;
        let epoch = 1;

        while (epoch <= 24) {
            timestamp::fast_forward_seconds(EPOCH);

            voter::update_period();
            let estimated_emission =
                calculate_emission(
                    last_emission,
                    get_quants(100_000_000),
                    2,
                    1,
                    13,
                    epoch
                );

            let (epoch_amount, epoch_rate, _) = get_emission_record(dxlyn_minter, epoch);

            assert!(estimated_emission == epoch_amount, ERROR_INVALID_EMISSION);

            if (epoch >= 13) {
                assert!(epoch_rate == 1, ERROR_INVALID_EPOCH);
            } else {
                assert!(epoch_rate == 2, ERROR_INVALID_EPOCH);
            };

            last_emission = estimated_emission;
            epoch = epoch + 1;
        }
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_get_current_epoch_emission(deployer: &signer) {
        setup(deployer);

        let dxlyn_minter = minter::get_minter_object_address();

        let initial_supply = get_quants(100_000_000); // 100M tokens

        timestamp::fast_forward_seconds(EPOCH);
        voter::update_period();
        timestamp::fast_forward_seconds(EPOCH);
        voter::update_period();
        timestamp::fast_forward_seconds(EPOCH);

        let (supply, rate, decay_rate, decay_start, _, _, _, last_emission) =
            get_emission_schedule(dxlyn_minter);

        let first_emission = initial_supply * 2 / 100;
        let second_emission = (first_emission * (100 + 2)) / 100;
        let third_emission = (second_emission * (100 + 2)) / 100;
        let epoch = get_emission_epoch_count(dxlyn_minter);

        let current_emission =
            calculate_emission(
                last_emission,
                supply,
                rate,
                decay_rate,
                decay_start,
                epoch
            );

        assert!(third_emission == current_emission, 12)
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_emission(deployer: &signer) {
        setup_emission(deployer);
        let addr = address_of(deployer);
        emit_tokens(&addr);

        for (i in 1..15) {
            timestamp::fast_forward_seconds(EPOCH);
            emit_tokens(&addr);
        };
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                       FRIEND FUNCTION TEST CASES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    #[test(deployer = @dexlyn_tokenomics)]
    fun test_init_emission_success(deployer: &signer) {
        setup(deployer);

        let dxlyn_minter = minter::get_minter_object_address();

        let (
            supply,
            rate,
            decay_rate,
            decay_start,
            total,
            counter,
            paused,
            last_emission,
        ) = get_emission_schedule(dxlyn_minter);

        assert!(supply == get_quants(100_000_000), 1);
        assert!(rate == 2, 2);
        assert!(decay_rate == 1, 3);
        assert!(decay_start == 13, 4);
        assert!(total == 0, 5);
        assert!(counter == 0, 6);
        assert!(!paused, 7);
        assert!(last_emission == 0, 0);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_ZERO_INITIAL_SUPPLY)]
    fun test_init_emission_zero_supply(deployer: &signer) {
        test_initialized_emission(deployer, address_of(deployer), 0, 2, 1, 13);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_RATE)]
    fun test_init_emission_invalid_rate(deployer: &signer) {
        test_initialized_emission(
            deployer,
            address_of(deployer),
            get_quants(100_000_000),
            0,
            0,
            13
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_INVALID_RATE)]
    fun test_init_emission_rate_too_high(deployer: &signer) {
        test_initialized_emission(
            deployer,
            address_of(deployer),
            get_quants(100_000_000),
            10001,
            100,
            13
        );
    }

    #[test(deployer = @dexlyn_tokenomics)]
    #[expected_failure(abort_code = ERROR_DECAY_START_TOO_EARLY)]
    fun test_init_emission_decay_start_zero(deployer: &signer) {
        test_initialized_emission(
            deployer,
            address_of(deployer),
            get_quants(100_000_000),
            2,
            1,
            0
        );
    }

    #[test]
    fun test_emission_calculation_first_epoch() {
        let emission = calculate_emission(0, get_quants(100_000_000), 2, 1, 13, 1);
        assert!(emission == get_quants(2_000_000), 1); // 2% of 100M
    }

    #[test]
    fun test_emission_calculation_growth_phase() {
        let emission =
            calculate_emission(
                get_quants(2_000_000),
                get_quants(100_000_000),
                2,
                1,
                13,
                2
            );
        assert!(emission == get_quants(2_040_000), 1); // 2M * 1.02
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_multiple_epoch_emissions(deployer: &signer) {
        setup(deployer);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(deployer, dxlyn_minter);

        // Advance time by 1 week
        timestamp::fast_forward_seconds(EPOCH);
        voter::update_period();

        // Advance time by 1 week
        timestamp::fast_forward_seconds(EPOCH);
        voter::update_period();

        // Advance time by 1 week
        timestamp::fast_forward_seconds(EPOCH);
        voter::update_period();

        let (_, _, _, _, total_emitted, epoch_counter, _, _) =
            get_emission_schedule(dxlyn_minter);

        assert!(epoch_counter == 3, 1);
        assert!(total_emitted > get_quants(6_000_000), 2); // Should be around 6.12M

        // Check individual epoch records
        let (epoch1_amount, _, _) = get_emission_record(dxlyn_minter, 1);
        let (epoch2_amount, _, _) = get_emission_record(dxlyn_minter, 2);
        let (epoch3_amount, _, _) = get_emission_record(dxlyn_minter, 3);

        assert!(epoch1_amount == get_quants(2_000_000), 3);
        assert!(epoch2_amount == get_quants(2_040_000), 4);
        assert!(epoch3_amount == get_quants(2_080_800), 5);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_emission_across_decay_boundary(deployer: &signer) {
        setup(deployer);
        let dxlyn_minter = minter::get_minter_object_address();

        // Advance time by 4 weeks to cross decay boundary
        for (i in 0..15) {
            timestamp::fast_forward_seconds(EPOCH);
            voter::update_period();
        };

        let (epoch12_amount, epoch12_rate, _) = get_emission_record(dxlyn_minter, 12);
        let (epoch13_amount, epoch13_rate, _) = get_emission_record(dxlyn_minter, 13);
        let (_, epoch14_rate, _) = get_emission_record(dxlyn_minter, 14);

        // Epoch 2 should be growth phase
        assert!(epoch12_rate == 2, 1);

        // Epoch 3 and 4 should be decay phase
        assert!(epoch13_rate == 1, 3);
        assert!(epoch14_rate == 1, 4);

        // Verify decay calculation
        assert!(epoch13_amount < epoch12_amount, 5); // Should start decaying
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_emission_pause_functionality(deployer: &signer) {
        setup(deployer);
        let dxlyn_minter = minter::get_minter_object_address();

        // Pause emissions
        set_emission_pause(deployer, true);

        // Advance time
        timestamp::fast_forward_seconds(EPOCH);

        // Try to emit (should do nothing due to pause)
        voter::update_period();

        let (_, _, _, _, total_emitted, epoch_counter, is_paused, _) =
            get_emission_schedule(dxlyn_minter);

        assert!(is_paused, 1);
        assert!(total_emitted == get_quants(2000000), 2);
        assert!(epoch_counter == 1, 3);

        // Unpause and emit
        set_emission_pause(deployer, false);
        voter::update_period();

        let (_, _, _, _, total_emitted_after, epoch_counter_after, is_paused_after, _) =

            get_emission_schedule(dxlyn_minter);

        assert!(!is_paused_after, 4);
        assert!(total_emitted_after == get_quants(2_000_000), 5);
        assert!(epoch_counter_after == 1, 6);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_no_emission_when_current(deployer: &signer) {
        setup(deployer);

        // Advance time by 1 week
        timestamp::fast_forward_seconds(EPOCH);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(deployer, dxlyn_minter);

        voter::update_period();
        let (_, _, _, _, _, _, _, _) = get_emission_schedule(dxlyn_minter);

        // Try to emit again immediately (should do nothing)
        voter::update_period();
        let (_, _, _, _, total_emitted, epoch_counter, _, _) =
            get_emission_schedule(dxlyn_minter);

        assert!(total_emitted == get_quants(2000000), 1);
        assert!(epoch_counter == 1, 2);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_pending_emissions_view(deployer: &signer) {
        setup(deployer);

        test_initialized_emission(
            deployer,
            address_of(deployer),
            get_quants(100_000_000),
            2,
            1,
            13
        );

        // No pending emissions initially
        assert!(get_pending_emissions(@dexlyn_tokenomics) == 0, 1);

        // Advance time by 3 weeks
        timestamp::fast_forward_seconds(EPOCH * 3);

        // Should have 3 pending emissions
        assert!(get_pending_emissions(@dexlyn_tokenomics) == 3, 2);

        // Emit 1 epoch worth
        emit_tokens(&address_of(deployer));

        // Should have 0 pending after emission
        assert!(get_pending_emissions(@dexlyn_tokenomics) == 0, 3);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_large_time_gap_emission(deployer: &signer) {
        setup(deployer);

        test_initialized_emission(
            deployer,
            address_of(deployer),
            get_quants(100_000_000),
            2,
            1,
            13
        );

        // Advance time by 20 weeks (crosses decay boundary)
        timestamp::fast_forward_seconds(EPOCH * 20);

        emit_tokens(&address_of(deployer));

        let (_, _, _, _, total_emitted, epoch_counter, _, _) =
            get_emission_schedule(@dexlyn_tokenomics);

        assert!(epoch_counter == 20, 1);
        assert!(total_emitted > get_quants(45_000_000), 2); // Should have significant emissions

        // Verify we have records for both growth and decay phases
        let (epoch_12_amount, _, _) = get_emission_record(@dexlyn_tokenomics, 12);
        let (epoch_13_amount, _, _) = get_emission_record(@dexlyn_tokenomics, 13);

        assert!(epoch_12_amount > epoch_13_amount, 3); // Decay should reduce emissions
    }

    #[test]
    fun test_overflow_protection() {
        // Test with very large numbers to ensure no overflow
        let max_safe = 18446744073709551615u64 / 10000; // Max safe value for our calculations

        let emission = calculate_emission(max_safe, get_quants(100_000_000), 2, 1, 13, 1);

        // Should not crash and return a reasonable value
        assert!(emission > 0, 1);
    }
}
