# Finding 16 - POC Verification Report

## Executive Summary

**Verdict: VULNERABILITY CONFIRMED**

The reported vulnerability in `vesting::remove_shareholder` has been **successfully verified** through three comprehensive end-to-end POC tests. The vulnerability allows `vesting_admin` to withdraw time-vested-but-unclaimed tokens when removing a shareholder, causing direct loss to the shareholder.

---

## 1. Verification Target

**Vulnerability**: `vesting::remove_shareholder` function lacks vested token settlement before removing a shareholder, allowing admin to withdraw and steal shareholder's time-vested tokens.

**Location**: `sources/vesting.move:551-613`

**Reported Severity**: HIGH (downgraded to LOW-MEDIUM due to privilege requirement)

---

## 2. Environment Information

- **Codebase**: DexlynTokenomics - Aptos/Supra Move smart contracts
- **Test Framework**: Aptos Move Unit Tests
- **Compiler**: Move compiler (aptos-core)
- **Test Location**: `tests/finding_16_poc.move`

---

## 3. Prerequisites Verification

### Access Control Analysis

**Required Privileges**:
- Attacker must have `vesting_admin` role
- Contract must be in ACTIVE state
- Shareholder must exist in the contract

**Verification**:
- Source code confirms `assert_admin(address_of(admin))` at line 557
- This is a **privileged operation** but qualifies under Core-7 exception:
  - Removing shareholders is a normal/ideal admin operation
  - Loss arises from intrinsic protocol logic flaw
  - Comment at L544-545 confirms legitimate use cases

### State Reachability

**Preconditions**:
1. Vesting contract must be created and active
2. Shareholder must have vesting allocation
3. Time must pass to create vested-but-unclaimed tokens
4. Shareholder must NOT call `vest_individual` to claim

**Verification**:
All preconditions are achievable through normal protocol operations without special privileges.

---

## 4. Attack Path Analysis

### Exploit Execution Steps

**Step 1: Initial Setup**
```move
// Create vesting contract with 1000 DXLYN for Alice
// 10 periods, 10% per period, 1 month duration
let contract_addr = vesting::schedule_vesting_contract(
    dev,
    vector[alice_addr],
    vector[total_amount],
    vector[10],
    100,
    current_time,
    MONTH_IN_SECONDS,
    withdrawal_addr
);
```
**Result**: Contract created, Alice allocated 1000 DXLYN over 10 months.

---

**Step 2: Time Progression**
```move
// Fast forward 3 months (3 periods)
timestamp::fast_forward_seconds(3 * MONTH_IN_SECONDS);
```
**Result**:
- 3 periods have passed
- 300 DXLYN (30%) should be vested by time
- Alice's `left_amount` remains 1000 DXLYN (unchanged because vest() not called)

---

**Step 3: Exploit Execution**
```move
// Admin removes shareholder WITHOUT calling vest() first
vesting::remove_shareholder(dev, contract_addr, alice_addr);
```
**Result**:
- Function reads Alice's `left_amount` = 1000 DXLYN
- Transfers ALL 1000 DXLYN to withdrawal_address
- Alice removed from shareholders

---

**Step 4: Damage Assessment**
```move
// Verify balances
let alice_received = alice_balance_after - alice_balance_before;
let withdrawal_received = withdrawal_balance_after - withdrawal_balance_before;
```

**Verified Results**:
- Alice received: **0 DXLYN** (should have received ~300 DXLYN)
- Withdrawal address received: **1000 DXLYN** (should have received ~700 DXLYN)
- Alice's loss: **~300 DXLYN** (30% of allocation, already vested by time)

---

## 5. POC Test Results

### Test 1: Core Vulnerability Demonstration

**Test**: `test_remove_shareholder_steals_vested_tokens`

**Scenario**:
- Total allocation: 1000 DXLYN
- Periods: 10 (10% each)
- Time elapsed: 3 months (30% vested)
- Action: Remove shareholder WITHOUT calling vest()

**Verified Assertions**:
```move
assert!(alice_received == 0, 1001);                     // PASS
assert!(withdrawal_received == left_amount_before, 1002); // PASS
assert!(left_amount_before == init_amount, 1003);        // PASS
assert!(alice_loss > (init_amount * 25) / 100, 1004);    // PASS
```

**Conclusion**: Alice loses ~30% of her allocation (300 DXLYN) to admin withdrawal.

**Status**: ✅ **PASSED** - Vulnerability confirmed

---

### Test 2: Correct Implementation Comparison

**Test**: `test_remove_shareholder_correct_usage`

**Scenario**:
- Same setup as Test 1
- Action: Call `vest()` BEFORE `remove_shareholder()`

**Verified Assertions**:
```move
// Alice receives vested tokens
assert!(alice_received >= expected_min_vested, 2001);    // PASS

// Withdrawal receives only remaining (unvested) amount
assert!(withdrawal_received == remaining_amount, 2002);   // PASS

// Remaining is less than total (vested portion transferred to Alice)
assert!(remaining_amount < total_amount, 2003);          // PASS
```

**Conclusion**: When vest() is called first, Alice receives her vested tokens (~300 DXLYN) and withdrawal_address receives only the unvested remainder (~700 DXLYN).

**Status**: ✅ **PASSED** - Correct behavior demonstrated

---

### Test 3: Economic Impact Analysis

**Test**: `test_exploit_economic_analysis`

**Scenario**:
- Realistic allocation: 1,200 DXLYN over 12 months
- Time elapsed: 6 months (50% vested)
- Action: Remove shareholder WITHOUT calling vest()

**Verified Assertions**:
```move
assert!(alice_loss == 0, 3001);                   // PASS - Alice receives nothing
assert!(admin_gain == init_amount, 3002);         // PASS - Admin gets all
assert!(left_amount == init_amount, 3003);        // PASS - No vesting occurred
assert!(loss_percentage >= 45, 3004);             // PASS - ~50% loss verified
```

**Economic Impact**:
- Expected vested: 600 DXLYN (50%)
- Alice received: 0 DXLYN
- Admin withdrew: 1,200 DXLYN
- Alice's loss: ~600 DXLYN (~50% of allocation)

**Status**: ✅ **PASSED** - Significant economic loss confirmed

---

## 6. Root Cause Analysis

### Code Comparison

**Vulnerable Function** (`remove_shareholder` L571-581):
```move
let shareholder_amount = simple_map::borrow(shareholders, &shareholder).left_amount;
// NO VESTING SETTLEMENT HERE
primary_fungible_store::transfer(
    res_signer,
    dxlyn_metadata,
    res.withdrawal_address,
    shareholder_amount  // Transfers ALL left_amount including vested
);
```

**Correct Pattern** (`terminate_vesting_contract` L467-469):
```move
// Vest pending amounts before termination
// Contract must be active before terminate and it already handled in `vest` function
vest(contract);  // SETTLEMENT OCCURS FIRST
// ... then proceed with termination
```

### Key Findings

1. **Missing Settlement**: `remove_shareholder` does not call `vest_individual` or `vest` before transferring `left_amount`

2. **Inconsistent Implementation**: Protocol establishes settlement-before-withdrawal pattern in `terminate_vesting_contract` but violates it in `remove_shareholder`

3. **Semantic Understanding of `left_amount`**:
   - `left_amount` represents total remaining tokens in contract
   - Includes BOTH vested-but-unclaimed AND unvested portions
   - Only reduced when `vest_transfer` is called (via `vest_individual` or `vest`)
   - If no vest call occurs, `left_amount` remains at original allocation

4. **Test Suite Evidence**: Existing test at L1046 explicitly calls `vest()` before `remove_shareholder()`, indicating intended usage pattern but not enforced by function

---

## 7. State and Variable Analysis

### VestingRecord Structure
```move
struct VestingRecord has copy, store, drop {
    init_amount: u64,      // Initial allocation: 1000 DXLYN
    left_amount: u64,      // Current state: 1000 DXLYN (unchanged)
    last_vested_period: u64 // Last settled period: 0 (no settlement)
}
```

### State Transitions

**Normal Flow** (with vest call):
```
Time T0: left_amount = 1000, last_vested_period = 0
Time T3: [vest called] -> vest_transfer reduces left_amount by 300
         left_amount = 700, last_vested_period = 3
         Alice receives: 300 DXLYN
Time T3: [remove_shareholder] -> transfers remaining 700 to withdrawal
```

**Vulnerable Flow** (without vest call):
```
Time T0: left_amount = 1000, last_vested_period = 0
Time T3: [NO vest call] -> left_amount unchanged
         left_amount = 1000, last_vested_period = 0
Time T3: [remove_shareholder] -> transfers ALL 1000 to withdrawal
         Alice receives: 0 DXLYN (loss of 300 vested tokens)
```

---

## 8. Exploit Feasibility Assessment

### Attack Prerequisites

| Requirement | Status | Notes |
|------------|--------|-------|
| Attacker has vesting_admin role | ✅ Required | Privileged operation |
| Contract in ACTIVE state | ✅ Normal | Standard precondition |
| Shareholder exists | ✅ Normal | Standard precondition |
| Time has passed (vesting occurred) | ✅ Normal | Natural time progression |
| Shareholder hasn't claimed recently | ✅ Common | Many users don't claim immediately |

### Can Unprivileged User Exploit?

**NO** - Requires `vesting_admin` role verified at L557.

### Core-7 Exception Analysis

**Question**: Does this qualify as valid despite privilege requirement?

**Answer**: YES

**Reasoning**:
1. **Normal Operation**: Removing shareholders is documented legitimate use case (L544-545 comment)
2. **Intrinsic Flaw**: Loss arises from missing logic, not malicious intent
3. **Design Violation**: Inconsistent with established `terminate_vesting_contract` pattern
4. **No Documentation**: No warning about calling vest() first
5. **Test Pattern**: Tests show vest() should be called first but not enforced

**Classification**: Logic flaw causing unintended loss during normal admin operations.

---

## 9. Economic Analysis

### Attack Costs and Returns

**Attacker**: vesting_admin
**Victim**: Any shareholder with time-vested-but-unclaimed tokens

**Attack Cost**:
- Gas fee: ~0.001-0.01 APT (negligible)
- Prerequisites: Admin role (already held)

**Attack Gain**:
- All time-vested-but-unclaimed tokens for removed shareholder
- Example: 300-600 DXLYN per victim (depending on vesting progress)

**ROI**: Extremely high (thousands to millions x)

### Real-World Scenarios

**Scenario 1: Malicious Admin**
- Admin intentionally removes shareholders without calling vest()
- Direct theft of vested tokens
- Probability: Low (requires malicious admin)
- Impact: HIGH (complete loss for victim)

**Scenario 2: Operational Error**
- Well-intentioned admin doesn't know to call vest() first
- Accidental loss to shareholder
- Probability: MEDIUM (no docs, no enforcement)
- Impact: HIGH (complete loss for victim)

**Scenario 3: Legitimate Removal**
- Employee fired/left company
- Admin removes without proper procedure
- Shareholder loses earned vested tokens
- Violates vesting contract promise

---

## 10. Dependency Verification

### External Calls Analysis

**Dependencies Used**:
1. `simple_map::borrow` - Standard map read, no side effects
2. `simple_map::remove` - Standard map removal, no side effects
3. `primary_fungible_store::transfer` - Atomic transfer, no reentrancy

**Verification**: All dependencies behave as expected, no hidden state modifications.

---

## 11. Comparison with Protocol Patterns

### Established Pattern: terminate_vesting_contract

```move
public entry fun terminate_vesting_contract(
    admin: &signer, contract: address
) acquires VestingContract, VestingStore {
    // STEP 1: Settle all vested tokens FIRST
    vest(contract);  // L469

    // STEP 2: Then proceed with termination
    let res = borrow_global_mut<VestingContract>(contract);
    // ... set left_amount to 0, etc.
}
```

**Design Principle**: "Vest pending amounts before termination" (L467 comment)

### Violated Pattern: remove_shareholder

```move
public entry fun remove_shareholder(
    admin: &signer, contract: address, shareholder: address
) acquires VestingContract, VestingStore {
    // NO SETTLEMENT STEP - DIRECT VIOLATION

    let shareholder_amount = simple_map::borrow(shareholders, &shareholder).left_amount;
    primary_fungible_store::transfer(..., shareholder_amount);
}
```

**Missing**: Settlement step before withdrawal

---

## 12. Test Suite Evidence

### Existing Test Pattern (L1018-1077)

```move
#[test(dev = @dexlyn_tokenomics)]
fun test_admin_remove_shareholder(dev: &signer) {
    // ... setup ...

    timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
    vesting::vest(contract_addr);  // L1046 - EXPLICITLY CALLED

    // ... then remove shareholder ...
    vesting::remove_shareholder(dev, contract_addr, user1_addr);
}
```

**Key Observation**: Test explicitly calls `vest()` BEFORE `remove_shareholder()`

**Implication**: This is the INTENDED usage pattern but not enforced by the function implementation.

---

## 13. Final Feature vs Bug Assessment

### Evidence for BUG

| Evidence | Weight |
|----------|--------|
| Inconsistent with `terminate_vesting_contract` | ✅ Strong |
| L467-468 comment establishes design principle | ✅ Strong |
| Test pattern shows intended usage | ✅ Strong |
| Violates vesting contract semantics | ✅ Strong |
| No documentation of intentional behavior | ✅ Strong |
| Function naming doesn't indicate seizure | ✅ Medium |

### Evidence for FEATURE

| Evidence | Weight |
|----------|--------|
| None found | ❌ |

**Conclusion**: This is an **UNINTENTIONAL LOGIC FLAW**, not a feature.

---

## 14. Minimal Fix Recommendation

```move
public entry fun remove_shareholder(
    admin: &signer,
    contract: address,
    shareholder: address
) acquires VestingContract, VestingStore {
    assert_admin(address_of(admin));

    let res = borrow_global_mut<VestingContract>(contract);
    assert!(res.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

    // FIX: Vest pending amounts for this shareholder before removal
    if (timestamp::now_seconds() >= res.vesting_schedule.start_timestamp_secs +
                                     res.vesting_schedule.period_duration) {
        vesting_internal(contract, res, shareholder);
    }

    // ... rest of function unchanged ...
}
```

**Impact**: Ensures vested tokens are transferred to shareholder before removal.

---

## 15. Severity Justification

### Reporter Claimed: HIGH
### Adjudicated: LOW-MEDIUM
### POC Confirms: VALID LOGIC FLAW

**Downgrade Justification**:
1. Requires privileged admin role (not accessible to normal users)
2. Operational mitigation available (call vest() first)
3. Test suite shows proper usage pattern
4. Centralization assumption in audit scope

**Remains Valid Because**:
1. Violates established protocol design principle
2. Causes loss even in good-faith operations
3. No enforcement or documentation of proper usage
4. Inconsistent with `terminate_vesting_contract` implementation
5. Violates core vesting semantics (time-based ownership)

---

## 16. Risk Assessment

**Probability**: LOW-MEDIUM
- Requires admin action
- Mitigated if proper procedure followed
- But no docs warn about calling vest() first

**Impact**: HIGH (when occurs)
- Complete loss of time-vested tokens
- Violates vesting contract promise
- No recovery mechanism

**Overall Risk**: MEDIUM
- Privilege requirement reduces likelihood
- But consequences severe when triggered
- Footgun classification: dangerous API without safeguards

---

## 17. Recommendations

### 1. Code Fix (Critical)
Add `vesting_internal` call before withdrawal in `remove_shareholder` function.

### 2. Documentation (High)
Add explicit warning in comments:
```move
/// WARNING: Ensure all vested tokens are settled before calling this function
/// by calling vest() or vest_individual() first, otherwise the shareholder
/// will lose their time-vested tokens.
```

### 3. Operational Procedure (High)
Establish mandatory checklist for admin operations:
- [ ] Call vest(contract) before remove_shareholder
- [ ] Verify shareholder received vested tokens
- [ ] Then proceed with removal

### 4. Access Control Enhancement (Medium)
Consider two-step removal process:
1. Admin initiates removal (marks for removal)
2. Timelock period allows shareholder to claim
3. After timelock, complete removal

### 5. Event Enhancement (Low)
Emit detailed events showing:
- Vested amount transferred to shareholder
- Unvested amount returned to withdrawal_address
- Clear breakdown for auditability

---

## 18. Conclusion

### Verification Summary

✅ **VULNERABILITY CONFIRMED**

**Evidence**:
1. Three POC tests successfully demonstrate the vulnerability
2. Shareholder loses time-vested tokens when removed without vest() call
3. Withdrawal address receives all tokens including vested portion
4. Inconsistent with protocol's established design pattern
5. Violates core vesting contract semantics

**Core Issue**: `remove_shareholder` violates the protocol's established design principle of settling vested tokens before withdrawal operations, creating a footgun that causes unintended loss to shareholders.

**Classification**: Valid logic flaw with LOW-MEDIUM severity (privileged access required but normal operation affected)

**Recommendation**: Fix the inconsistency by adding vesting settlement before removal to align with `terminate_vesting_contract` pattern and protect protocol invariants.

---

## 19. POC Execution Evidence

### All Tests Passed

```
Running Move unit tests
[ PASS ] test_exploit_economic_analysis
[ PASS ] test_remove_shareholder_correct_usage
[ PASS ] test_remove_shareholder_steals_vested_tokens
Test result: OK. Total tests: 3; passed: 3; failed: 0
```

### Test Coverage

1. **Core vulnerability**: Demonstrated loss of vested tokens ✅
2. **Correct behavior**: Demonstrated proper usage pattern ✅
3. **Economic impact**: Demonstrated realistic loss scenarios ✅

---

## 20. Final Verdict

**Status**: ✅ **VULNERABILITY EXISTS - POC VERIFICATION SUCCESSFUL**

**Confidence Level**: VERY HIGH

**Evidence Quality**:
- End-to-end executable tests ✅
- Multiple scenarios covered ✅
- Comparison with correct implementation ✅
- Economic impact quantified ✅
- Code analysis complete ✅
- State transitions verified ✅

**Exploitability**:
- Requires admin privilege (limits scope)
- Normal operation (increases likelihood)
- No documentation (increases risk)
- High economic impact (severe consequences)

**Recommendation**: **FIX IMMEDIATELY** to align with protocol design principles and prevent unintended loss.
