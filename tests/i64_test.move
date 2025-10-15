#[test_only]
module dexlyn_tokenomics::i64_test {

    use dexlyn_tokenomics::i64::{
        from_i64,
        from_u64,
        safe_add,
        safe_sub,
        safe_subtract_or_add, safe_subtract_u64,
        subtract_or_zero,
    };

    // Test from_u64
    #[test]
    fun test_from_u64() {
        let (value, is_negative) = from_i64(from_u64(10, false));
        assert!(value == 10 && !is_negative, 1);

        let (value, is_negative) = from_i64(from_u64(10, true));
        assert!(value == 10 && is_negative, 2);

        let (value, is_negative) = from_i64(from_u64(0, false));
        assert!(value == 0 && !is_negative, 3);

        let (value, is_negative) = from_i64(from_u64(0, true));
        assert!(value == 0 && !is_negative, 4);

        let (value, is_negative) = from_i64(from_u64(18446744073709551615, false)); // u64::MAX
        assert!(
            value == 18446744073709551615 && !is_negative,
            5
        );
    }

    // Test from_i64
    #[test]
    fun test_from_i64() {
        let i64 = from_u64(10, false);
        let (value, is_negative) = from_i64(i64);
        assert!(value == 10 && !is_negative, 1);

        let i64 = from_u64(10, true);
        let (value, is_negative) = from_i64(i64);
        assert!(value == 10 && is_negative, 2);

        let i64 = from_u64(0, false);
        let (value, is_negative) = from_i64(i64);
        assert!(value == 0 && !is_negative, 3);

        let i64 = from_u64(0, false);
        let (value, is_negative) = from_i64(i64);
        assert!(value == 0 && !is_negative, 4);
    }

    // Test subtract_or_zero
    #[test]
    fun test_subtract_or_zero() {
        assert!(subtract_or_zero(10, 5) == 5, 1);
        assert!(subtract_or_zero(10, 10) == 0, 2);
        assert!(subtract_or_zero(5, 10) == 0, 3);
        assert!(subtract_or_zero(0, 0) == 0, 4);
        assert!(subtract_or_zero(0, 5) == 0, 5);
        assert!(subtract_or_zero(18446744073709551615, 1) == 18446744073709551614, 6); // u64::MAX - 1
    }

    // Test safe_subtract_u64
    #[test]
    fun test_safe_subtract_u64() {
        let (value, is_negative) = safe_subtract_u64(10, 5);
        assert!(value == 5 && !is_negative, 1);

        let (value, is_negative) = safe_subtract_u64(10, 10);
        assert!(value == 0 && !is_negative, 2);

        let (value, is_negative) = safe_subtract_u64(5, 10);
        assert!(value == 5 && is_negative, 3);

        let (value, is_negative) = safe_subtract_u64(0, 0);
        assert!(value == 0 && !is_negative, 4);

        let (value, is_negative) = safe_subtract_u64(0, 5);
        assert!(value == 5 && is_negative, 5);

        let (value, is_negative) = safe_subtract_u64(18446744073709551615, 1);
        assert!(
            value == 18446744073709551614 && !is_negative,
            6
        );
    }

    // Test safe_subtract_or_add
    #[test]
    fun test_safe_subtract_or_add() {
        assert!(safe_subtract_or_add(10, 5, false) == 15, 1); // 10 + 5
        assert!(safe_subtract_or_add(10, 5, true) == 5, 2); // 10 - 5
        assert!(safe_subtract_or_add(5, 10, true) == 0, 3); // 5 - 10
        assert!(safe_subtract_or_add(0, 0, false) == 0, 4); // 0 + 0
        assert!(safe_subtract_or_add(0, 5, true) == 0, 5); // 0 - 5
        assert!(
            safe_subtract_or_add(18446744073709551614, 1, false) == 18446744073709551615,
            6
        ); // (u64::MAX - 1) + 1
    }

    // Test safe_add
    #[test]
    fun test_safe_add() {
        // Positive + Positive
        let (value, is_negative) = safe_add(from_u64(10, false), from_u64(5, false));
        assert!(value == 15 && !is_negative, 1);

        // Negative + Negative
        let (value, is_negative) = safe_add(from_u64(10, true), from_u64(5, true));
        assert!(value == 15 && is_negative, 2);

        // Positive + Negative
        let (value, is_negative) = safe_add(from_u64(10, false), from_u64(5, true));
        assert!(value == 5 && !is_negative, 3);
        let (value, is_negative) = safe_add(from_u64(5, false), from_u64(10, true));
        assert!(value == 5 && is_negative, 4);
        let (value, is_negative) = safe_add(from_u64(10, false), from_u64(10, true));
        assert!(value == 0 && !is_negative, 5);

        // Negative + Positive
        let (value, is_negative) = safe_add(from_u64(10, true), from_u64(5, false));
        assert!(value == 5 && is_negative, 6);
        let (value, is_negative) = safe_add(from_u64(5, true), from_u64(10, false));
        assert!(value == 5 && !is_negative, 7);
        let (value, is_negative) = safe_add(from_u64(10, true), from_u64(10, false));
        assert!(value == 0 && !is_negative, 8);

        // Zero Cases
        let (value, is_negative) = safe_add(from_u64(0, false), from_u64(0, false));
        assert!(value == 0 && !is_negative, 9);
        let (value, is_negative) = safe_add(from_u64(0, false), from_u64(5, true));
        assert!(value == 5 && is_negative, 10);
        let (value, is_negative) = safe_add(from_u64(5, true), from_u64(0, false));
        assert!(value == 5 && is_negative, 11);

        // Large Values
        let (value, is_negative) =
            safe_add(
                from_u64(18446744073709551615, false),
                from_u64(0, false)
            );
        assert!(
            value == 18446744073709551615 && !is_negative,
            12
        );
    }

    // Test safe_sub
    #[test]
    fun test_safe_sub() {
        // Negative - Positive
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(5, false));
        assert!(value == 15 && is_negative, 1); // -10 - 5
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(10, false));
        assert!(value == 20 && is_negative, 2); // -10 - 10
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(50, false));
        assert!(value == 60 && is_negative, 3); // -10 - 50

        // Positive - Negative
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(5, true));
        assert!(value == 15 && !is_negative, 4); // 10 - (-5)
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(10, true));
        assert!(value == 20 && !is_negative, 5); // 10 - (-10)
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(50, true));
        assert!(value == 60 && !is_negative, 6); // 10 - (-50)

        // Negative - Negative
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(5, true));
        assert!(value == 5 && is_negative, 7); // -10 - (-5)
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(10, true));
        assert!(value == 0 && !is_negative, 8); // -10 - (-10)
        let (value, is_negative) = safe_sub(from_u64(10, true), from_u64(50, true));
        assert!(value == 40 && !is_negative, 9); // -10 - (-50)

        // Positive - Positive
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(5, false));
        assert!(value == 5 && !is_negative, 10); // 10 - 5
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(10, false));
        assert!(value == 0 && !is_negative, 11); // 10 - 10
        let (value, is_negative) = safe_sub(from_u64(10, false), from_u64(50, false));
        assert!(value == 40 && is_negative, 12); // 10 - 50

        // Zero Cases
        let (value, is_negative) = safe_sub(from_u64(0, false), from_u64(0, false));
        assert!(value == 0 && !is_negative, 13);
        let (value, is_negative) = safe_sub(from_u64(0, false), from_u64(5, false));
        assert!(value == 5 && is_negative, 14);
        let (value, is_negative) = safe_sub(from_u64(0, false), from_u64(5, true));
        assert!(value == 5 && !is_negative, 15);
        let (value, is_negative) = safe_sub(from_u64(5, true), from_u64(0, false));
        assert!(value == 5 && is_negative, 16);

        // Large Values
        let (value, is_negative) =
            safe_sub(
                from_u64(18446744073709551615, false),
                from_u64(1, false)
            );
        assert!(
            value == 18446744073709551614 && !is_negative,
            17
        );
    }

    // Test overflow edge case (will panic, so marked as expected failure)
    #[test]
    #[expected_failure]
    fun test_safe_add_overflow() {
        let (_, _) = safe_add(
            from_u64(18446744073709551615, false),
            from_u64(1, false)
        ); // u64::MAX + 1
    }

    #[test]
    #[expected_failure]
    fun test_safe_sub_overflow() {
        let (_, _) = safe_sub(
            from_u64(18446744073709551615, false),
            from_u64(1, true)
        ); // u64::MAX + 1
    }
}