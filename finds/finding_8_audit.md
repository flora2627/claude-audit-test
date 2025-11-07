# Audit Report: Finding 8 - Integer Truncation in `voting_escrow::split`

## Executive Verdict: **VALID (Medium Severity)**

The vulnerability exists and causes permanent loss of user funds through integer truncation. However, the economic impact is typically negligible for realistic usage patterns due to the 8-decimal precision of DXLYN tokens.

---

## Reporter's Claim Summary

The reporter claims that the `split` function in `voting_escrow.move` has an integer truncation vulnerability where:
1. The function decreases `supply` by the full locked amount
2. For each split weight, it calculates `_value_internal = value * weight / total_weight` using integer division
3. The sum of truncated values is less than the original amount
4. The difference is permanently lost to users and creates accounting imbalance

**Example cited**: Splitting 5 DXLYN with weights [1,1] results in two NFTs with 2 DXLYN each (total 4), losing 1 DXLYN permanently.

---

## Code-Level Analysis

### File and Line Anchors

**Primary Location**: `sources/voting_escrow.move:614-693` (split function)
**Secondary Location**: `sources/voting_escrow.move:1642-1703` (deposit_for_internal function)

### Call Chain Trace

1. **Entry Point**: `voting_escrow::split(user, split_weights, token)`
   - Caller: User (EOA)
   - msg.sender: User address
   - Permissions: Must own the NFT token
   - Call type: public entry function

2. **Line 647**: `voting_escrow.supply = voting_escrow.supply - value;`
   - Decreases total supply by full locked amount
   - State: `supply` is modified in storage

3. **Line 669** (loop iteration): `_value_internal = value * weight / total_weight;`
   - Integer division truncates fractional parts
   - No rounding or remainder handling
   - Result stored in memory variable

4. **Line 671**: `mint_nft(voting_escrow, user_address, end, _value_internal)`
   - Creates new NFT token
   - No token transfer occurs
   - Call type: internal function

5. **Lines 674-681**: `deposit_for_internal(voting_escrow, user, minted_token_address, _value_internal, end, SPLIT_TYPE)`
   - Caller: split function
   - Callee: deposit_for_internal (internal)
   - msg.sender: Same as original (user)
   - Key parameters:
     - `value`: `_value_internal` (truncated amount)
     - `type`: `SPLIT_TYPE` (constant = 3)
   - Call type: internal function call

6. **Line 1658** (in deposit_for_internal): `voting_escrow.supply = supply_before + value;`
   - Increases supply by truncated amount
   - State: `supply` is modified in storage
   - Net effect after all iterations: `supply` increases by sum of truncated values (< original)

7. **Line 1662** (in deposit_for_internal): `locked.amount = locked.amount + value;`
   - Records the truncated amount in the new NFT's locked balance
   - State: `locked` table is modified in storage

8. **Line 1681** (in deposit_for_internal): `if (value > 0 && type != MERGE_TYPE && type != SPLIT_TYPE)`
   - **CRITICAL**: When `type == SPLIT_TYPE`, NO token transfer occurs
   - The tokens remain in the contract from the original lock
   - No `primary_fungible_store::transfer` is executed

### State Scope Analysis

#### Storage State (persistent)

1. **`voting_escrow.supply: u64`**
   - Scope: Global storage at `@dexlyn_tokenomics`
   - Modification sequence:
     - Before: `supply = S`
     - Line 647: `supply = S - value`
     - After loop: `supply = S - value + Σ(truncated_values)`
   - Final state: `supply < original_supply` if truncation occurred

2. **`voting_escrow.locked: Table<address, LockedBalance>`**
   - Scope: Global storage table
   - Key: NFT token address
   - Modifications:
     - Line 657: Old token entry cleared to `{amount: 0, end: 0}`
     - Line 1668 (each iteration): New token entry created/updated with truncated amount
   - Final state: Sum of new locked amounts = sum of truncated values (< original value)

3. **Physical token balance**: `primary_fungible_store::balance(voting_escrow_address, DXLYN)`
   - Scope: Fungible store at voting_escrow contract address
   - **NOT MODIFIED** during split operation (line 1681 condition prevents transfer)
   - State: Unchanged, still holds the original full amount

#### Memory/Transient State

- `_value_internal: u64` (line 666): Memory variable, reset each loop iteration
- `total_weight: u64` (line 649): Memory accumulator for weight sum
- `locked: LockedBalance` (line 634): Memory copy of original locked balance

### Key Context Variables

- `user` (signer): The user splitting their position
- `address_of(user)`: Used for ownership verification (line 624)
- `token` (address): The NFT being split (verified as owned by user at line 624)
- No assembly or manual slot computation

---

## Mathematical Proof of Truncation

### Example 1: Small Odd Amount
```
Initial state:
- value = 5 (5 base units, 0.00000005 DXLYN)
- split_weights = [1, 1]
- total_weight = 2

Iteration 1:
- _value_internal = 5 * 1 / 2 = 2 (integer division, 0.5 truncated)

Iteration 2:
- _value_internal = 5 * 1 / 2 = 2 (integer division, 0.5 truncated)

Result:
- Sum of new locked amounts: 2 + 2 = 4
- Lost amount: 5 - 4 = 1 (20% loss)
```

### Example 2: Extreme Case
```
Initial state:
- value = 1 (1 base unit, 0.00000001 DXLYN)
- split_weights = [1, 1]
- total_weight = 2

Iteration 1:
- _value_internal = 1 * 1 / 2 = 0 (integer division, 0.5 truncated)

Iteration 2:
- _value_internal = 1 * 1 / 2 = 0 (integer division, 0.5 truncated)

Result:
- Sum of new locked amounts: 0 + 0 = 0
- Lost amount: 1 - 0 = 1 (100% loss)
- Both NFTs have zero locked amount
```

### Example 3: Realistic Amount
```
Initial state:
- value = 1000 * 10^8 = 100,000,000,000 (1000 DXLYN)
- split_weights = [3, 2]
- total_weight = 5

Iteration 1:
- _value_internal = 100,000,000,000 * 3 / 5 = 60,000,000,000

Iteration 2:
- _value_internal = 100,000,000,000 * 2 / 5 = 40,000,000,000

Result:
- Sum: 100,000,000,000 (no loss, divides evenly)
```

### Example 4: Realistic with Remainder
```
Initial state:
- value = 100,000,000,001 (1000.00000001 DXLYN)
- split_weights = [3, 2]
- total_weight = 5

Iteration 1:
- _value_internal = 100,000,000,001 * 3 / 5 = 60,000,000,000 (truncates 0.6)

Iteration 2:
- _value_internal = 100,000,000,001 * 2 / 5 = 40,000,000,000 (truncates 0.4)

Result:
- Sum: 100,000,000,000
- Lost: 1 base unit (0.00000001 DXLYN, ~$0.000001 at $0.10/DXLYN)
```

---

## Exploit Feasibility

### Prerequisites
1. User must own a veNFT with locked DXLYN
2. Lock must not be expired
3. NFT must not be actively voting
4. User must choose split weights that don't divide evenly with the locked amount

### Attack Path (Non-Profitable)

**This is NOT an exploitable attack** because the "attacker" would be losing their own funds. The vulnerability is an **accidental loss scenario**:

1. User locks DXLYN tokens (any amount)
2. User calls `split([1, 1], token_address)` to split position in half
3. If locked amount is odd, user permanently loses remainder
4. User cannot recover lost tokens even after lock expires

### Unprivileged EOA Capability: **YES**

Any user with a locked position can trigger this vulnerability by:
- Calling the public entry function `voting_escrow::split`
- No admin privileges required
- No governance approval required
- No external dependencies or oracle conditions

### Can Normal EOA Execute Full Path: **YES**

```move
// Pseudocode exploit (actually causes self-harm):
voting_escrow::split(
    user_signer,           // User's own signer
    vector[1, 1],          // Equal split weights
    user_nft_address       // User's own NFT
);
// Result: User loses remainder from truncation
```

---

## Economic Analysis

### Input Assumptions

1. **DXLYN Token Properties**:
   - Decimals: 8
   - 1 DXLYN = 100,000,000 base units
   - Assumed price: $0.10 per DXLYN (for illustration)

2. **Gas Costs** (Aptos/Supra network):
   - Estimated cost per split: ~0.001 APT (~$0.01 at $10/APT)

3. **User Behavior** (from instructions):
   - Technical users who check operations carefully
   - Would lock economically meaningful amounts (> gas cost)

### Cost-Benefit Analysis

#### Scenario A: Large Position (1000 DXLYN)
```
Locked amount: 1000 DXLYN = 100,000,000,000 base units
Split weights: [1, 1]
Expected loss: 0 base units (divides evenly)
Dollar loss: $0

With odd amount (1000.00000001 DXLYN):
Expected loss: 1 base unit
Dollar loss: $0.000001
Percentage loss: 0.0000001%
```

#### Scenario B: Small Odd Amount (0.00000099 DXLYN)
```
Locked amount: 99 base units
Split weights: [1, 1]
Calculation:
- First split: 99 * 1 / 2 = 49
- Second split: 99 * 1 / 2 = 49
- Sum: 98
Expected loss: 1 base unit
Dollar loss: $0.000001
Percentage loss: 1.01%
```

#### Scenario C: Extreme Edge Case (1 base unit)
```
Locked amount: 1 base unit = 0.00000001 DXLYN
Split weights: [1, 1]
Expected loss: 1 base unit (100%)
Dollar loss: $0.000001

Economic rationality:
- Gas cost: $0.01
- Value at risk: $0.000001
- ROI: -99.99%
NO rational user would lock such tiny amounts
```

### Attacker ROI/EV

**Expected Value: NEGATIVE**

An attacker attempting to exploit this would need to:
1. Lock their own funds
2. Pay gas to split
3. Lose remainder to truncation
4. No mechanism to extract lost funds

The lost tokens are stuck in the contract and cannot be recovered by anyone, including the attacker.

**Conclusion**: This is not an exploit opportunity but a **foot-gun vulnerability** that causes accidental self-harm.

### Sensitivity Analysis

| Locked Amount (DXLYN) | Splits | Max Loss (base units) | Max Loss (USD @ $0.10) | Loss % |
|------------------------|--------|-----------------------|------------------------|--------|
| 0.00000001             | [1,1]  | 1                     | $0.000001              | 100%   |
| 0.00000099             | [1,1]  | 1                     | $0.000001              | 1.01%  |
| 0.00001001             | [1,1]  | 1                     | $0.000001              | 0.01%  |
| 1.00000001             | [1,1]  | 1                     | $0.000001              | 0.000001% |
| 1000.00000001          | [1,1]  | 1                     | $0.000001              | 0.0000001% |

**Key Insight**: For any realistic locking amount (> 1 DXLYN), the absolute loss is capped at a few base units (< $0.00001), making it economically negligible despite being a real bug.

---

## Dependency/Library Reading Notes

### Move Standard Library - Integer Division

The vulnerability stems from Move's built-in integer division operator `/` which performs floor division:

```move
// From Move language specification
5 / 2 == 2  // Not 2.5, no floating point
1 / 2 == 0  // Truncates to zero
```

This is standard behavior across all Move implementations (Aptos, Sui, Supra). No external library is involved.

### Primary Fungible Store (Aptos Framework)

**Function**: `primary_fungible_store::balance(owner: address, metadata: Object<Metadata>) -> u64`

**Source**: Aptos Framework (Supra fork)

**Behavior**: Returns the actual balance of fungible assets held by an address. This is independent of the `supply` accounting variable in the voting escrow contract.

**Key Observation**: The physical token balance in the voting escrow contract remains unchanged after a split operation because:
1. Line 1681 in `deposit_for_internal` checks: `if (value > 0 && type != MERGE_TYPE && type != SPLIT_TYPE)`
2. When `type == SPLIT_TYPE`, no transfer occurs
3. The tokens were already in the contract from the original lock

This creates the **ghost asset** scenario described by the reporter: tokens exist in the contract but are not recorded in any NFT's `locked.amount`.

---

## Invariant Violation Analysis

### Documented Invariant (from `acc_modeling/voting_escrow_book.md`)

**Line 137**:
```
supply = sum(locked[token].amount for all token where locked[token].end > 0)
```

**Translation**: The total supply should equal the sum of all active locked amounts.

### Violation Proof

**Before split**:
```
supply = 5
locked[token1] = {amount: 5, end: T}
Sum of locked amounts = 5
Invariant holds: 5 == 5 ✓
```

**After split with [1,1]**:
```
supply = 4 (decreased by 5, increased by 2+2)
locked[token1] = {amount: 0, end: 0} (burned)
locked[token2] = {amount: 2, end: T}
locked[token3] = {amount: 2, end: T}
Sum of locked amounts = 4
Invariant holds: 4 == 4 ✓ (but this is wrong!)
```

**Wait, the invariant appears to hold!** Let me reconsider...

The accounting is internally consistent: both `supply` and the sum of `locked.amount` are decreased by the truncated remainder. The issue is that this is **consistently wrong** relative to the physical token balance:

```
Physical balance in contract: 5 tokens
supply: 4
Sum of locked amounts: 4
Unaccounted tokens: 1 (ghost asset)
```

### Impact of Invariant Violation

The **real** invariant that should hold but doesn't:
```
primary_fungible_store::balance(voting_escrow_address) == supply + expired_but_not_withdrawn_tokens
```

After truncation:
```
Balance: 5
supply: 4
Expired tokens: 0
5 != 4 ✗ VIOLATION
```

This means:
1. The contract holds more tokens than it accounts for
2. Users can only withdraw what's in their `locked.amount`
3. The difference is permanently stuck (no function can access unaccounted tokens)

---

## Validation Against Core Directives

### [Core-1] Practical Economic Risk

**Assessment**: **LOW** for typical usage, **MEDIUM** for edge cases

- For realistic locking amounts (> 100 DXLYN), loss is < 1 base unit (< $0.00001)
- Gas costs exceed the loss in all practical scenarios
- Only edge cases with very small amounts or repeated splits cause meaningful percentage losses

### [Core-2] Dependency Source Code

**Verified**: Move standard library integer division behavior confirmed from language specification.

### [Core-3] End-to-End Attack Flow

**Traced**: Full execution path verified from `split` → `deposit_for_internal` → state updates. No profitable attack path exists.

### [Core-4] Privileged Account Requirement

**Assessment**: None required. Any user can trigger on their own position (but harms themselves).

### [Core-5] Centralization Issues

**Not applicable**: This is a pure logic bug, not a centralization concern.

### [Core-6] 100% On-Chain Attacker Control

**Verified**: User has complete control to trigger the bug by calling `split` with chosen weights. However, no benefit to the user.

### [Core-7] Privileged User Actions

**Not applicable**: No privileged user actions are involved.

### [Core-8] Feature vs. Bug Assessment

**Verdict: BUG**

Evidence this is not intentional:
1. **Documentation mismatch**: Function doc says "amounts %" but doesn't warn about truncation
2. **Test limitations**: All existing tests use evenly divisible values (50/50 split of 1000 DXLYN)
3. **No validation**: Function accepts any weights without checking divisibility
4. **Invariant violation**: Creates unaccounted "ghost assets" in the contract
5. **No recovery mechanism**: No admin function to sweep unaccounted tokens

If this were intentional, we would expect:
- Documentation warning users to use weights that divide evenly
- A require statement to enforce divisibility
- Tests covering odd amounts
- A mechanism to recover or redistribute dust

### [Core-9] User Behavior Assumption

**Assessment**: Technical users would likely:
- Test with small amounts first (discovering the issue)
- Read the code (seeing the integer division)
- Use large amounts that make truncation negligible
- Use simple splits like [1,1] or [50,50] that work with most amounts

However, users might:
- Split positions without testing
- Use arbitrary weights like [7, 3] expecting 70/30 split
- Not realize integer division causes truncation

---

## Proof of Concept

### PoC Code

```move
#[test(dev = @dexlyn_tokenomics, supra_framework = @supra_framework, alice = @0x123)]
fun test_split_truncation_loss(
    dev: &signer, supra_framework: &signer, alice: &signer
) {
    // Setup
    setup_test_with_genesis(dev, supra_framework);
    let alice_address = address_of(alice);

    // Lock an ODD number of base units
    let value = 99;  // Will lose 1 base unit when split [1,1]
    dxlyn_coin::register_and_mint(dev, alice_address, value);
    let unlock_time = timestamp::now_seconds() + WEEK;
    voting_escrow::create_lock(alice, value, unlock_time);

    let (token1, _) = get_nft_token_address(1);

    // Record state before split
    let (_, supply_before, _, _, balance_before, _) = voting_escrow::get_voting_escrow_state();
    assert!(supply_before == 99, 0);
    assert!(balance_before == 99, 0);

    // Split with equal weights
    voting_escrow::split(alice, vector[1, 1], token1);

    // Check state after split
    let (token2, _) = get_nft_token_address(2);
    let (token3, _) = get_nft_token_address(3);
    let (amount2, _) = voting_escrow::get_token_lock(token2);
    let (amount3, _) = voting_escrow::get_token_lock(token3);
    let (_, supply_after, _, _, balance_after, _) = voting_escrow::get_voting_escrow_state();

    // VULNERABILITY: Loss of 1 base unit
    assert!(amount2 == 49, 1);  // 99 * 1 / 2 = 49
    assert!(amount3 == 49, 2);  // 99 * 1 / 2 = 49
    assert!(supply_after == 98, 3);  // Should be 99!
    assert!(balance_after == 99, 4);  // Physical balance unchanged

    // Ghost asset: 1 base unit unaccounted for
    assert!(balance_after > supply_after, 5);  // 99 > 98
}
```

### Expected Behavior vs Actual Behavior

**Expected**:
- Total locked in new NFTs: 99 base units
- Supply: 99
- Balance: 99

**Actual**:
- Total locked in new NFTs: 98 base units (49 + 49)
- Supply: 98
- Balance: 99
- **Lost: 1 base unit** stuck in contract forever

---

## Impact Assessment

### Direct Impacts

1. **User Principal Loss**: Users permanently lose the truncated remainder of their locked tokens. The loss is immediate and cannot be recovered.

2. **Accounting Imbalance**: The contract's physical balance exceeds the sum of recorded locked amounts, creating "ghost assets" that no function can access.

3. **Invariant Violation**: The relationship `balance >= supply` holds, but `supply == sum(locked.amount)` remains consistent (both are reduced by truncation). The real issue is `balance > supply + expired_tokens`.

### Indirect Impacts

1. **Protocol Trust**: Discovery of stuck tokens could damage user confidence, even if amounts are small.

2. **Accumulated Dust**: Over many operations, unaccounted tokens could accumulate (though total is bounded by number of split operations × max truncation per operation).

3. **No Systemic Risk**: Since supply is not used in critical calculations by other modules (verified via grep), the accounting imbalance doesn't break voting, emissions, or fee distribution.

### Severity Classification

**Severity: MEDIUM**

Rationale:
- ✅ Real loss of user funds (not theoretical)
- ✅ Permanent and unrecoverable
- ✅ No privileged access required
- ✅ Violates documented accounting model
- ❌ Economic impact is typically negligible (< $0.00001 per split)
- ❌ Only affects users who split odd amounts
- ❌ No cascading effects on protocol functions
- ❌ Not profitable to exploit (self-harm only)
- ❌ Unlikely to be triggered by rational actors with realistic amounts

**Not High Severity** because:
- Practical loss is micro-cents for realistic use cases
- Gas costs exceed loss amount
- No systemic protocol risk
- Self-contained issue (doesn't affect other users)

**Not Low/Informational** because:
- Real loss of user funds (even if small)
- Violates stated invariants
- Poor user experience
- Accumulates over time

---

## Final Feature-vs-Bug Assessment

### Verdict: **BUG (Unintentional Logic Error)**

### Evidence for BUG Classification

1. **No Documentation of Limitation**:
   - Function documentation (line 618) says "amounts %" without mentioning divisibility requirements
   - No warning about integer truncation in comments or external docs
   - No example of safe vs unsafe weight combinations

2. **Test Suite Blind Spot**:
   - All existing split tests use evenly divisible amounts (1000 DXLYN split 50/50)
   - No test for odd amounts or arbitrary weight ratios
   - Suggests developers didn't consider truncation case

3. **No Input Validation**:
   - Function accepts any positive weights without checks
   - No assertion to ensure truncation doesn't occur
   - Compare to similar functions in DeFi that validate precision

4. **Invariant Violation**:
   - Creates ghost assets that violate accounting model
   - Document `acc_modeling/voting_escrow_book.md` lists potential risks but doesn't mention split truncation
   - Indicates issue was not considered during design

5. **No Recovery Mechanism**:
   - No admin function to sweep unaccounted tokens
   - No internal mechanism to redistribute dust
   - Tokens are permanently stuck

6. **Pattern Mismatch**:
   - The merge function (line 595) has similar logic but uses `deposit_for_internal` which adds full amount
   - Split uniquely creates this truncation scenario
   - Suggests split implementation was not fully thought through

### Minimal Fix (Conceptual)

```move
// Option 1: Allocate remainder to last split
vector::for_each_with_index(split_weights, |i, weight| {
    if (i == vector::length(&split_weights) - 1) {
        // Last iteration: allocate ALL remaining
        _value_internal = value - sum_allocated_so_far;
    } else {
        _value_internal = value * weight / total_weight;
        sum_allocated_so_far = sum_allocated_so_far + _value_internal;
    }
    // ... mint and deposit ...
});

// Option 2: Require even divisibility
let test_sum = 0;
vector::for_each(split_weights, |weight| {
    test_sum = test_sum + (value * weight / total_weight);
});
assert!(test_sum == value, ERROR_SPLIT_TRUNCATION);
```

---

## Conclusion

**The vulnerability is VALID** but with **MEDIUM severity** due to negligible economic impact in realistic scenarios.

### Summary

- **Logic flaw confirmed**: Integer truncation in split calculation causes permanent loss
- **Math verified**: Examples correctly demonstrate truncation behavior
- **Exploitability**: Not profitable; causes self-harm only
- **Economic impact**: Micro-cents for typical usage (> 100 DXLYN positions)
- **Invariant violation**: Creates ghost assets in contract
- **Classification**: Bug, not feature

### Recommendations

1. **Immediate**: Document the truncation behavior and recommend users only split large amounts or use evenly divisible weights
2. **Short-term**: Add input validation to reject splits that would cause truncation > threshold
3. **Medium-term**: Implement remainder allocation to last NFT to prevent any loss
4. **Long-term**: Consider sweep function for accumulated dust (requires governance)

### Risk Rating

- **Likelihood**: MEDIUM (can happen accidentally with normal usage)
- **Impact**: LOW (economic loss typically < $0.00001)
- **Overall Severity**: **MEDIUM**

