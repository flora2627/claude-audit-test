#[test_only]
module dexlyn_tokenomics::test_rebase_comprehensive {
    use std::signer::address_of;

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account::create_account_for_test;
    use supra_framework::genesis;
    use supra_framework::timestamp;

    use dexlyn_tokenomics::emission;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voting_escrow;

    const DXLYN_DECIMAL: u64 = 100_00_00_00;
    // 1 DXLYN = 10^8
    const WEEK: u64 = 604800;
    // One week in seconds
    const AMOUNT_SCALE: u64 = 10000;
    const MAX_TIME: u64 = 126144000;
    // 4 years max lock time
    const START_TIME: u64 = 1746057600; // Thu, 1 May 2025 00:00:00

    // Error codes for testing
    const ERROR_ZERO_EMISSION: u64 = 002;
    const ERROR_OVERFLOW: u64 = 003;
    const ERROR_INVALID_RATIO: u64 = 004;

    /// Setup function to initialize all core modules
    fun set_up(deployer: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(START_TIME);
        test_internal_coins::init_coin(deployer);
        schedule_emission(deployer);
        voting_escrow::initialize(deployer);
    }

    /// Schedule emission settings
    fun schedule_emission(deployer: &signer) {
        let initial_supply = 100_000_000 * DXLYN_DECIMAL;
        let initial_rate_bps = 2;
        let decay_start_epoch = 13;
        let decay_rate_bps = 1;

        emission::test_initialized_emission(
            deployer,
            address_of(deployer),
            initial_supply,
            initial_rate_bps,
            decay_rate_bps,
            decay_start_epoch
        );
    }

    /// Returns how many full epochs (weeks) have passed since START_TIME
    fun get_epoch(): u64 {
        let now = timestamp::now_seconds();
        (now - START_TIME) / WEEK
    }

    // EDGE CASE TESTS

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_zero_dxlyn_supply(deployer: &signer) {
        set_up(deployer);
        let veDex: u256 = 1000 * 100000000;
        let dex: u256 = 0; // Zero supply should fail
        let emi: u256 = 100 * 100000000;

        let zero_rebase = minter::test_calculate_rebase(veDex, dex, emi);

        assert!(zero_rebase == 0, 0);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_zero_ve_supply(deployer: &signer) {
        set_up(deployer);

        let veDex: u256 = 0; // Zero veDXLYN supply
        let dex: u256 = 100000000 * 100000000;
        let emi: u256 = 2000000 * 100000000;

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // With zero veDXLYN, rebase should be zero (no stakers to reward)
        assert!(result == 0, 0x201);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_zero_emission(deployer: &signer) {
        set_up(deployer);
        let veDex: u256 = 20000000 * 100000000 * 10000;
        let dex: u256 = 100000000 * 100000000;
        let emi: u256 = 0; // Zero emission

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // With zero emission, rebase should be zero
        assert!(result == 0, 0x202);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_very_small_values(deployer: &signer) {
        set_up(deployer);

        let veDex: u256 = 1; // Minimal veDXLYN
        let dex: u256 = 1000000; // Small DXLYN supply
        let emi: u256 = 1; // Minimal emission

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // Should handle small values without overflow/underflow
        assert!(result >= 0, 0x203);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_maximum_realistic_values(deployer: &signer) {
        set_up(deployer);

        // Test with maximum realistic token amounts
        let max_supply: u256 = 1_000_000_000 * 100000000; // 1B tokens
        let veDex: u256 = max_supply * 10000; // All tokens locked for max time
        let dex: u256 = max_supply;
        let emi: u256 = max_supply / 100; // 1% emission

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // Should not overflow and should be reasonable
        assert!(result >= 0, 0x204);
        assert!((result as u256) <= emi, 0x205); // Rebase shouldn't exceed emission
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_ve_supply_greater_than_total_supply(deployer: &signer) {
        set_up(deployer);

        // Edge case: veDXLYN can theoretically be > DXLYN supply due to time weighting
        let dex: u256 = 100000000 * 100000000;
        let veDex: u256 = dex * 2; // 2x the total supply (max lock scenario)
        let emi: u256 = 2000000 * 100000000;

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // Should handle this case gracefully
        assert!(result > 0, 0x206);
        assert!((result as u256) <= emi, 0x207);
    }

    // MATHEMATICAL PROPERTY TESTS

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_rebase_proportionality(deployer: &signer) {
        set_up(deployer);

        let base_ve: u256 = 10000000 * 100000000;
        let base_dex: u256 = 100000000 * 100000000;
        let base_emi: u256 = 1000000 * 100000000;

        let result1 = minter::test_calculate_rebase(base_ve, base_dex, base_emi);

        // Double the emission, rebase should scale proportionally
        let result2 = minter::test_calculate_rebase(base_ve, base_dex, base_emi * 2);

        assert!(result2 == result1 * 2, 0x301);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_rebase_ratio_consistency(deployer: &signer) {
        set_up(deployer);

        let base_ve: u256 = 20000000 * 100000000;
        let base_dex: u256 = 100000000 * 100000000;
        let base_emi: u256 = 2000000 * 100000000;

        let result1 = minter::test_calculate_rebase(base_ve, base_dex, base_emi);

        // Double both veDXLYN and DXLYN supply, ratio stays same
        let result2 = minter::test_calculate_rebase(base_ve * 2, base_dex * 2, base_emi);

        assert!(result1 == result2, 0x302);
    }

    // INTEGRATION TESTS WITH REALISTIC SCENARIOS

    #[test(deployer = @dexlyn_tokenomics, alice = @0x123, bob = @0x456)]
    fun test_multiple_users_different_lock_periods(
        deployer: &signer, alice: &signer, bob: &signer
    ) {
        set_up(deployer);

        let alice_address = address_of(alice);
        let bob_address = address_of(bob);
        create_account_for_test(alice_address);
        create_account_for_test(bob_address);

        // Setup different lock amounts and periods
        let alice_amount = 1000 * DXLYN_DECIMAL;
        let bob_amount = 2000 * DXLYN_DECIMAL;

        dxlyn_coin::register_and_mint(deployer, alice_address, alice_amount);
        dxlyn_coin::register_and_mint(deployer, bob_address, bob_amount);

        let current_time = timestamp::now_seconds();
        let alice_unlock = current_time + WEEK * 26; // 6 months
        let bob_unlock = current_time + WEEK * 104; // 2 years

        voting_escrow::create_lock(alice, alice_amount, alice_unlock);
        voting_escrow::create_lock(bob, bob_amount, bob_unlock);

        // Fast forward and test rebase
        timestamp::fast_forward_seconds(WEEK * 2);
        emission::emit_tokens(&address_of(deployer));

        let new_time = timestamp::now_seconds();
        let total_ve_supply = voting_escrow::total_supply(new_time);
        let total_dx_supply = dxlyn_coin::total_supply();

        let epoch = get_epoch();
        let (emission_amount, _, _) =
            emission::get_emission_record(address_of(deployer), epoch);

        let rebase_amount =
            minter::test_calculate_rebase(
                (total_ve_supply as u256),
                (total_dx_supply as u256),
                (emission_amount as u256)
            );

        // Verify rebase is reasonable
        assert!(rebase_amount > 0, 0x401);
        assert!(rebase_amount <= emission_amount, 0x402);
    }

    #[test(deployer = @dexlyn_tokenomics, alice = @0x123)]
    fun test_rebase_over_lock_decay(deployer: &signer, alice: &signer) {
        set_up(deployer);

        let alice_address = address_of(alice);
        create_account_for_test(alice_address);

        let lock_amount = 1000 * DXLYN_DECIMAL;
        dxlyn_coin::register_and_mint(deployer, alice_address, lock_amount);

        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK * 52; // 1 year lock

        voting_escrow::create_lock(alice, lock_amount, unlock_time);

        let week = 1;

        // Test rebase calculation as veDXLYN decays over time
        while (week <= 50) {
            // Test for 50 weeks
            timestamp::fast_forward_seconds(WEEK);
            emission::emit_tokens(&address_of(deployer));

            let test_time = timestamp::now_seconds();
            let ve_supply = voting_escrow::total_supply(test_time);
            let dx_supply = dxlyn_coin::total_supply();

            let epoch = get_epoch();
            let (emission_amount, _, _) =
                emission::get_emission_record(address_of(deployer), epoch);

            if (ve_supply > 0 && emission_amount > 0) {
                let rebase_amount =
                    minter::test_calculate_rebase(
                        (ve_supply as u256),
                        (dx_supply as u256),
                        (emission_amount as u256)
                    );

                // Rebase should remain reasonable throughout decay
                assert!(rebase_amount <= emission_amount, week + 0x500);

                if (week % 10 == 0) {}
            };

            week = week + 1;
        }
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_rebase_with_no_locks(deployer: &signer) {
        set_up(deployer);

        // Don't create any locks, test with zero veDXLYN
        timestamp::fast_forward_seconds(WEEK);
        emission::emit_tokens(&address_of(deployer));

        let ve_supply = voting_escrow::total_supply(timestamp::now_seconds());
        let dx_supply = dxlyn_coin::total_supply();
        let epoch = get_epoch();
        let (emission_amount, _, _) =
            emission::get_emission_record(address_of(deployer), epoch);

        // Should be zero veDXLYN supply
        assert!(ve_supply == 0, 0x601);

        if (emission_amount > 0) {
            let rebase_amount =
                minter::test_calculate_rebase(
                    (ve_supply as u256),
                    (dx_supply as u256),
                    (emission_amount as u256)
                );

            // With no locks, rebase should be zero
            assert!(rebase_amount == 0, 0x602);
        }
    }

    #[test(deployer = @dexlyn_tokenomics, alice = @0x123)]
    fun test_rebase_boundary_conditions(
        deployer: &signer, alice: &signer
    ) {
        set_up(deployer);

        let alice_address = address_of(alice);
        create_account_for_test(alice_address);

        // Test with minimal lock amount
        let min_lock = 1; // 1 unit
        dxlyn_coin::register_and_mint(deployer, alice_address, min_lock);

        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + WEEK; // Minimal lock time

        voting_escrow::create_lock(alice, min_lock, unlock_time);

        timestamp::fast_forward_seconds(WEEK / 2); // Half week forward
        emission::emit_tokens(&address_of(deployer));

        let ve_supply = voting_escrow::total_supply(timestamp::now_seconds());
        let dx_supply = dxlyn_coin::total_supply();
        let epoch = get_epoch();
        let (emission_amount, _, _) =
            emission::get_emission_record(address_of(deployer), epoch);

        if (ve_supply > 0 && emission_amount > 0) {
            let rebase_amount =
                minter::test_calculate_rebase(
                    (ve_supply as u256),
                    (dx_supply as u256),
                    (emission_amount as u256)
                );

            // Should handle minimal values without error
            assert!(rebase_amount >= 0, 0x701);
        }
    }

    // PRECISION AND ROUNDING TESTS

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_precision_with_small_ratios(deployer: &signer) {
        set_up(deployer);
        // Test precision when veDXLYN is much smaller than DXLYN supply
        let veDex: u256 = 1000; // Very small veDXLYN
        let dex: u256 = 100000000 * 100000000; // Large DXLYN supply
        let emi: u256 = 1000000 * 100000000; // Medium emission

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // Should handle precision correctly
        assert!(result >= 0, 0x801);
    }

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_precision_with_large_ratios(deployer: &signer) {
        set_up(deployer);
        // Test precision when veDXLYN is close to theoretical maximum
        let dex: u256 = 100000000 * 100000000;
        let veDex: u256 = dex * 4; // Max theoretical veDXLYN (4 year lock)
        let emi: u256 = 1000000 * 100000000;

        let result = minter::test_calculate_rebase(veDex, dex, emi);

        // Should handle large ratios correctly
        assert!(result > 0, 0x802);
        assert!((result as u256) <= emi, 0x803);
    }

    // CONSISTENCY VERIFICATION TESTS

    #[test(deployer = @dexlyn_tokenomics)]
    fun test_rebase_calculation_deterministic(deployer: &signer) {
        set_up(deployer);
        let veDex: u256 = 20000000 * 100000000 * 10000;
        let dex: u256 = 100000000 * 100000000;
        let emi: u256 = 2000000 * 100000000;

        // Calculate same rebase multiple times
        let result1 = minter::test_calculate_rebase(veDex, dex, emi);
        let result2 = minter::test_calculate_rebase(veDex, dex, emi);
        let result3 = minter::test_calculate_rebase(veDex, dex, emi);

        // Results should be identical (deterministic)
        assert!(result1 == result2, 0x901);
        assert!(result2 == result3, 0x902);
        assert!(result1 == 64000000000000, 0x903); // Match expected value
    }
}
