module dexlyn_tokenomics::i64 {

    struct I64 has store, drop, copy {
        // The absolute value of the unsigned integer
        value: u64,
        // True for subtract (negative), false for add (positive)
        is_negative: bool
    }

    public fun from_u64(value: u64, is_negative: bool): I64 {
        if (value == 0) {
            return I64 { value, is_negative: false }
        };
        I64 { value, is_negative }
    }

    public fun from_i64(value: I64): (u64, bool) {
        if (value.value == 0) {
            return (value.value, false)
        };

        (value.value, value.is_negative)
    }

    public inline fun subtract_or_zero(a: u64, b: u64): u64 {
        if (a > b) { a - b }
        else { 0 }
    }

    public inline fun max(a: u64, b: u64): u64 {
        if (a >= b) a else b
    }

    public inline fun min(a: u64, b: u64): u64 {
        if (a < b) a else b
    }

    public fun safe_subtract_or_add(a: u64, b: u64, is_b_negative: bool): u64 {
        if (is_b_negative) {
            // if b is negative and a is grater then b then subtract (ex : 10 += (-5))
            subtract_or_zero(a, b)
        } else {
            // if b is positive then add a + b
            a + b
        }
    }

    public fun safe_subtract_u64(a: u64, b: u64): (u64, bool) {
        if (a >= b) {
            // No underflow: return positive result
            (a - b, false)
        } else {
            // Underflow: return "negative" result as positive magnitude
            (b - a, true)
        }
    }

    // Function to safely add two Int structs
    public fun safe_add(a: I64, b: I64): (u64, bool) {
        if (a.is_negative == b.is_negative) {
            // Same sign: add magnitudes, keep sign
            (a.value + b.value, a.is_negative)
        } else {
            // Different signs: subtract smaller from larger
            if (a.value > b.value) {
                (a.value - b.value, a.is_negative)
            } else if (b.value > a.value) {
                (b.value - a.value, b.is_negative)
            } else {
                // Magnitudes equal: result is zero (positive by convention)
                (0, false)
            }
        }
    }

    public fun safe_sub(a: I64, b: I64): (u64, bool) {
        if (a.is_negative == b.is_negative) {
            // Same sign: a - b
            if (a.value > b.value) {
                (a.value - b.value, a.is_negative)
            } else if (b.value > a.value) {
                (b.value - a.value, !a.is_negative)
            } else {
                (0, false)
            }
        } else {
            // Different signs: a + |b| or -(|a| + b)
            (a.value + b.value, a.is_negative)
        }
    }
}
