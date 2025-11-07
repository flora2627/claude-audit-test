## 标题
`vesting::remove_shareholder` 函数缺少到期归属结算，允许 admin 撤回并窃取股东已到期的代币 🚨

## 类型
Access Control / Inconsistent State Handling

## 风险等级
High

## 位置
- `sources/vesting.move`: `remove_shareholder` 函数 (L551-L613)

## 发现依据
1.  **功能与权限**: `remove_shareholder` 是一个特权函数，允许 `vesting_admin` 从 vesting 合约中移除任何一个股东。其设计意图可能是为了处理离职员工或违规参与者等情况。

2.  **逻辑缺陷**: 该函数在移除股东时，直接读取股东的 `left_amount`（剩余待释放总量），并将此数额**全部**转回给 admin 控制的 `withdrawal_address`。
    ```571:581:sources/vesting.move
    let shareholder_amount =
        simple_map::borrow(shareholders, &shareholder).left_amount;
    // ...
    primary_fungible_store::transfer(
        res_signer,
        dxlyn_metadata,
        res.withdrawal_address,
        shareholder_amount
    );
    ```
    `left_amount` 包含了**已到期但未领取** (vested but unclaimed) 的部分和**未到期** (unvested) 的部分。该函数错误地将这两部分资金全部撤回。

3.  **缺少结算步骤**: 与正确的 `terminate_vesting_contract` 函数 (L463) 不同，`remove_shareholder` 在执行撤回操作前，**没有**调用 `vest_individual` 或 `vesting_internal` 来为该股东结算并转移其已经到期的代币。`terminate_vesting_contract` 在 L469 正确地调用了 `vest(contract)` 来确保所有已到期的份额在终止前得到分配。

## 攻击路径 (S-L1 / Loss)
1.  **初始状态**: 股东 Alice 有一个 vesting 合约，每月解锁 100 DXLYN。合约已运行 6 个月，Alice 已有 600 DXLYN 到期但尚未领取 (`claim`)。她的 `VestingRecord` 中 `left_amount` 仍然是她最初的总分配额。

2.  **Admin 操作**: `vesting_admin`（可能是恶意的，或因业务需要移除 Alice）调用 `remove_shareholder(contract, Alice)`。

3.  **执行与影响**:
    *   函数读取 Alice 的全额 `left_amount`。
    *   函数将 Alice 的**全部**剩余代币（包括已经到期的 600 DXLYN 和未来未到期的部分）转账给 `withdrawal_address`。
    *   Alice 被从股东列表中移除。

4.  **结果**: Alice 永久性地损失了她已经合法拥有（Vested）的 600 DXLYN。这构成了直接的资产窃取，因为 vesting 合约的核心承诺是，一旦代币到期，其所有权就应归属于受益人。

## 影响
- **资产损失 (Loss)**: 对被移除的股东造成直接的、不可逆的资产损失。Admin 可以利用此函数窃取任何股东已到期但未领取的资金。
- **违反协议核心承诺**: vesting 合约的根本目的是保证在满足时间条件后将资产转移给受益人。此漏洞完全破坏了这一信任基础。
- **与设计意图不符**: `terminate_vesting_contract` 的正确实现表明，协议的设计意图是在任何终止操作前都应先结算已到期的份额。`remove_shareholder` 的实现与此相悖，应被视为一个严重的逻辑遗漏。

## 根因标签
`Missing Logic` / `Inconsistent State Handling` / `Access Control`

## 状态
Confirmed

---

# ADJUDICATION REPORT

## Executive Verdict
**Valid Logic Flaw / Downgraded to LOW-MEDIUM Severity** - The reported logic inconsistency exists and violates protocol design principles, but requires privileged access and is avoidable through proper operational procedures. Severity downgraded from HIGH to LOW-MEDIUM due to privilege requirements and centralization assumptions.

## Reporter's Claim Summary
The reporter claims that `remove_shareholder` function at vesting.move:551-613 lacks vested token settlement before removing a shareholder, allowing admin to withdraw all `left_amount` including time-vested-but-unclaimed tokens, unlike `terminate_vesting_contract` which correctly calls `vest()` first at line 469.

## Code-Level Analysis

### 1. Logic Existence Verification ✓ CONFIRMED

**`remove_shareholder` implementation (vesting.move:551-613):**
```move
public entry fun remove_shareholder(
    admin: &signer,
    contract: address,
    shareholder: address
) acquires VestingContract, VestingStore
{
    assert_admin(address_of(admin));  // L557 - requires vesting_admin

    let res = borrow_global_mut<VestingContract>(contract);
    assert!(res.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

    let shareholder_amount =
        simple_map::borrow(shareholders, &shareholder).left_amount;  // L571-572

    primary_fungible_store::transfer(
        res_signer,
        dxlyn_metadata,
        res.withdrawal_address,
        shareholder_amount  // L580 - transfers ALL left_amount
    );

    simple_map::remove(shareholders, &shareholder);  // L592-593
}
```

**Key observation:** NO call to `vest_individual`, `vest`, or `vesting_internal` before transferring `left_amount`.

**Comparison with `terminate_vesting_contract` (vesting.move:463-490):**
```move
public entry fun terminate_vesting_contract(
    admin: &signer, contract: address
) acquires VestingContract, VestingStore
{
    vest(contract);  // L469 - CRITICAL: settles ALL vested tokens first!

    let res = borrow_global_mut<VestingContract>(contract);
    assert_admin(address_of(admin));

    // Set each shareholder's left_amount to 0
    let shareholders_address = simple_map::keys(&res.shareholders);
    vector::for_each_ref(&shareholders_address, |shareholder| {
        let shareholder_amount = simple_map::borrow_mut(&mut res.shareholders, shareholder);
        shareholder_amount.left_amount = 0;  // L485 - zeroes after vesting
    });

    set_terminate_vesting_contract(contract, res);
}
```

**Critical finding:** `terminate_vesting_contract` explicitly calls `vest(contract)` at L469 with comment at L467-468: "Vest pending amounts before termination". This establishes the protocol design principle: **always settle vested tokens before any withdrawal operation**.

### 2. Understanding `left_amount` Semantics

**VestingRecord structure (vesting.move:182-186):**
```move
struct VestingRecord has copy, store, drop {
    init_amount: u64,      // Initial allocation
    left_amount: u64,      // Remaining amount in contract
    last_vested_period: u64 // Last settled period
}
```

**How vesting works:**
1. Time passes → vesting periods complete
2. Anyone calls `vest(contract)` or `vest_individual(contract, shareholder)` (both PUBLIC ENTRY, no permission required)
3. `vesting_internal` calculates vested periods and calls `vest_transfer`
4. `vest_transfer` (vesting.move:922-946) transfers vested tokens to beneficiary AND reduces `left_amount`:
   ```move
   fun vest_transfer(
       vesting_record: &mut VestingRecord,
       extendRef: &ExtendRef,
       beneficiary: address,
       fraction: FixedPoint32
   ): bool {
       let amount = min(
           vesting_record.left_amount,
           fixed_point32::multiply_u64(vesting_record.init_amount, fraction)
       );

       if (amount > 0) {
           vesting_record.left_amount = vesting_record.left_amount - amount;  // L936
           primary_fungible_store::transfer(&contract_signer, metadata, beneficiary, amount);  // L938-943
           true
       } else { false }
   }
   ```

**Critical insight:** Vesting is CLAIM-BASED, not automatic. If no one calls `vest_individual`, then:
- Time passes → periods are "vested" by time
- But `left_amount` remains unchanged
- Tokens stay in contract, not transferred to beneficiary
- `remove_shareholder` captures these time-vested-but-unclaimed tokens

## Call Chain Trace

### remove_shareholder Execution Path:

1. **EOA → vesting::remove_shareholder(admin, contract, shareholder)**
   - Caller: EOA (must be vesting_admin)
   - Callee: vesting module
   - msg.sender: admin address
   - Function selector: `remove_shareholder`
   - Call type: entry function call
   - Validation: `assert_admin(address_of(admin))` at L557

2. **vesting module → primary_fungible_store::transfer(...)**
   - Caller: vesting contract signer (via extendRef)
   - Callee: primary_fungible_store module
   - msg.sender: vesting contract object address
   - Arguments: `(res_signer, dxlyn_metadata, res.withdrawal_address, shareholder_amount)`
   - Call type: module function call
   - Value transferred: ALL `left_amount` (includes time-vested-but-unclaimed tokens)
   - No reentrancy risk: fungible asset transfer is atomic

3. **vesting module → simple_map::remove(...)**
   - Removes shareholder from `res.shareholders` map
   - Pure state manipulation, no external calls

### terminate_vesting_contract Execution Path (for comparison):

1. **EOA → vesting::terminate_vesting_contract(admin, contract)**
   - Validation: same as above

2. **vesting module → vesting::vest(contract)** ← **KEY DIFFERENCE**
   - This step is MISSING in remove_shareholder
   - Settles all vested tokens for all shareholders
   - Transfers vested amounts to beneficiaries
   - Reduces `left_amount` for each shareholder

3. **vesting module → primary_fungible_store::transfer(...)**
   - Only transfers REMAINING (unvested) amount
   - After vesting settlement, this is correct

## State Scope Analysis

### Variables and Storage Scope:

1. **`VestingContract` resource** (storage)
   - Location: `@contract_address`
   - Context: Global storage at contract object address
   - Fields accessed:
     - `state: u8` (read only, checked for ACTIVE)
     - `admin: address` (read only, for validation)
     - `shareholders: SimpleMap<address, VestingRecord>` (read-write)
     - `withdrawal_address: address` (read only)
     - `extendRef: ExtendRef` (read only)

2. **`VestingRecord` in shareholders map** (storage)
   - Location: `VestingContract.shareholders[shareholder]`
   - Context: Nested storage in SimpleMap
   - Fields:
     - `left_amount: u64` - **CRITICAL STATE**
       - Read at L571-572
       - NOT modified before removal
       - SHOULD be reduced by calling `vest_individual` first
       - Contains both unvested AND time-vested-but-unclaimed tokens
     - `init_amount: u64` (not accessed)
     - `last_vested_period: u64` (not accessed)

3. **Fungible asset balances** (storage)
   - Contract balance: Reduced by `shareholder_amount`
   - `withdrawal_address` balance: Increased by `shareholder_amount`
   - No assembly or custom storage slot manipulation

4. **No msg.sender context manipulation**
   - All transfers use proper signers (res_signer from extendRef)
   - No delegatecall or proxy patterns

## Exploit Feasibility

### Prerequisites:
1. ✓ Attacker must be `vesting_admin` - **PRIVILEGED ROLE REQUIRED**
2. ✓ Contract must be active (not terminated)
3. ✓ Shareholder must exist in contract
4. ✓ Shareholder must have time-vested-but-unclaimed tokens (hasn't called `vest_individual` recently)

### Can a normal unprivileged EOA exploit this?
**NO** - Requires `vesting_admin` role, checked at L557 via `assert_admin`.

### Per Core-4:
> Only accept attacks that a normal, unprivileged account can initiate.

**Result:** This would normally be **REJECTED** as it requires privileged access.

### However, per Core-7 Exception:
> If impact depends on a privileged user performing fully normal/ideal actions, confirm that the loss arises from an intrinsic protocol logic flaw.

**Analysis:**
1. Is removing a shareholder a "normal/ideal" admin operation? **YES**
   - Comment at L544-545: "If a shareholder is flagged as suspicious or no longer eligible, the admin can remove them."
   - Legitimate use cases: fired employee, policy violation, regulatory requirement
   - NOT a malicious or unusual operation

2. Does loss arise from intrinsic protocol logic flaw? **YES**
   - Missing call to `vest_individual` before transferring `left_amount`
   - Inconsistent with `terminate_vesting_contract` pattern
   - Violates established protocol principle (vest before withdraw)

**Conclusion:** Core-7 exception applies. This IS a valid logic flaw despite privilege requirement.

## Economic Analysis

### Attack Scenario:
- **Attacker:** `vesting_admin` (privileged role)
- **Victim:** Shareholder with time-vested-but-unclaimed tokens
- **Cost to attacker:** Gas fee for `remove_shareholder` (~0.001-0.01 APT, negligible)
- **Gain to attacker:** All time-vested-but-unclaimed tokens

### Example Calculation:
```
Initial allocation: 1,200 DXLYN (100/month for 12 months)
Time passed: 6 months
Vested by time: 600 DXLYN
Shareholder called vest_individual: NO
Current left_amount: 1,200 DXLYN (unchanged)

Admin calls remove_shareholder:
- Withdraws: 1,200 DXLYN (all left_amount)
- Should withdraw: 600 DXLYN (only unvested)
- Victim loss: 600 DXLYN (time-vested tokens)
- ROI: 600 DXLYN / 0.01 APT gas = ~60,000x (assuming 1 DXLYN = 1 APT)
```

### Economic Viability:
- **For malicious admin:** Extremely profitable
- **For well-intentioned admin:** Unintended loss to shareholder due to operational error

### Real-World Risk Assessment:
1. **Probability:** LOW-MEDIUM
   - Requires admin to NOT follow proper procedure (calling `vest()` first)
   - Test suite shows proper usage (calling `vest()` before removal)
   - Docs/comments don't warn about this requirement

2. **Impact:** HIGH (if occurs)
   - Complete loss of time-vested tokens for victim
   - Violates core vesting contract promise

3. **Overall Risk:** MEDIUM
   - Mitigated by privilege requirement and operational procedures
   - But violates protocol invariant and design principles

## Dependency/Library Analysis

### External Dependencies Used:
1. **`simple_map` (aptos_std):**
   - Function: `borrow`, `remove`, `contains_key`
   - Behavior verified: Standard map operations, no unexpected side effects
   - Source: aptos-core standard library

2. **`primary_fungible_store::transfer` (supra_framework):**
   - Function: Transfer fungible assets
   - Behavior: Atomic transfer, no reentrancy
   - Arguments: `(signer, metadata, recipient, amount)`
   - Source: Supra/Aptos framework standard module

3. **No OpenZeppelin or complex DeFi dependencies**

### Verification:
- All dependencies behave as expected
- No hidden state modifications in dependency calls
- No reentrancy vectors

## Evidence from Test Suite

**Critical finding from vesting_test.move:1018-1077:**
```move
#[test(dev = @dexlyn_tokenomics)]
fun test_admin_remove_shareholder(dev: &signer) {
    // ... setup vesting contract with 2 shareholders ...

    // --- First vesting period completes ---
    timestamp::fast_forward_seconds(MONTH_IN_SECONDS);
    vesting::vest(contract_addr);  // L1046 - CALLED BEFORE REMOVAL!

    // ... verify users received vested tokens ...

    // --- Admin removes shareholder ---
    let (_, remaining_vested_amount, _) =
        vesting::get_shareholder_vesting_record(contract_addr, user1_addr);

    vesting::remove_shareholder(dev, contract_addr, user1_addr);  // L1067

    // Verify withdrawn amount equals remaining (after vesting)
    assert!(balance_after == balance_before + remaining_vested_amount);  // L1073-1076
}
```

**Key observations:**
1. Test explicitly calls `vest()` BEFORE `remove_shareholder()` (L1046)
2. This ensures `left_amount` is reduced before removal
3. Test would FAIL if `vest()` was not called first (would withdraw more than `remaining_vested_amount`)
4. **This test pattern reveals the INTENDED usage but function doesn't enforce it**

## Final Feature-vs-Bug Assessment

### Is this intended behavior or a bug?

**Evidence for BUG:**
1. ✓ **Inconsistency:** `terminate_vesting_contract` calls `vest()` first (L469)
2. ✓ **Comment evidence:** L467-468 states "Vest pending amounts before termination" - establishes design principle
3. ✓ **Test pattern:** Test calls `vest()` before `remove_shareholder()` - shows intended usage
4. ✓ **Semantic violation:** Vesting contracts universally promise time-based ownership
5. ✓ **No documentation:** No comments indicating this is intentional recovery mechanism
6. ✓ **Function naming:** "remove_shareholder" not "revoke_and_seize_vesting"

**Evidence for FEATURE:**
1. ✗ None - no documentation, comments, or design rationale supporting intentional seizure

**Conclusion:** This is an **UNINTENTIONAL LOGIC FLAW**, not a feature. The missing `vest_individual` call is a coding error, not a design decision.

### Minimal Fix:
```move
public entry fun remove_shareholder(
    admin: &signer,
    contract: address,
    shareholder: address
) acquires VestingContract, VestingStore
{
    assert_admin(address_of(admin));

    let res = borrow_global_mut<VestingContract>(contract);
    assert!(res.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

    // FIX: Vest pending amounts for this shareholder before removal
    if (timestamp::now_seconds() >= res.vesting_schedule.start_timestamp_secs + res.vesting_schedule.period_duration) {
        vesting_internal(contract, res, shareholder);
    }

    // ... rest of function unchanged ...
}
```

## Severity Assessment

### Reporter claims: HIGH
### Adjudicated severity: **LOW-MEDIUM**

**Reasoning for downgrade:**
1. **Privilege requirement:** Requires `vesting_admin` role (not accessible to normal users)
2. **Centralization assumption:** Per audit scope, admin roles are trusted
3. **Operational mitigation:** Admin can avoid by calling `vest()` first (as test shows)
4. **Not directly exploitable:** Requires either malicious admin OR operational error
5. **Footgun classification:** This is more a "footgun" (dangerous API) than an "exploit"

**However, it remains VALID because:**
1. Violates protocol design principle (inconsistent with `terminate_vesting_contract`)
2. Violates vesting semantics (time-based ownership)
3. Causes unintended loss even in good-faith operations
4. No warning in docs/comments about calling `vest()` first

## Risk Mitigation Recommendations

1. **Code fix:** Add `vesting_internal` call before withdrawal (see minimal fix above)
2. **Documentation:** Add explicit warning to call `vest()` before `remove_shareholder()`
3. **Operational procedure:** Establish mandatory pre-removal vesting in admin playbook
4. **Access control:** Consider adding two-step removal with timelock for shareholder protection
5. **Monitoring:** Emit event with detailed breakdown (vested vs unvested amounts)

---

## Summary

**Verdict:** VALID logic flaw with LOW-MEDIUM severity (downgraded from HIGH)

**Core Issue:** `remove_shareholder` violates the protocol's established design principle of settling vested tokens before withdrawal operations, creating a footgun that could cause unintended loss to shareholders.

**Key Finding:** While this requires privileged access (normally out of scope per Core-4), it qualifies under Core-7 exception as the loss arises from an intrinsic logic flaw during normal admin operations, not from intentional malicious behavior.

**Recommendation:** Fix the inconsistency by adding vesting settlement before removal to align with `terminate_vesting_contract` pattern and protect protocol invariants.
