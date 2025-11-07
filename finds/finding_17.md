## 标题
`voter::kill_gauge` 永久冻结待分配奖励，导致会计失衡与资产损失 🚨

## 分类
Freeze / Loss – Inconsistent State Handling

## 位置
- `sources/voter.move`: `kill_gauge` 函数 (L663-L686)

## 二级指标与影响
- **二级指标**: `voter.claimable: Table<address, u64>`，此为 `voter` 合约对各 `gauge` 合约的负债表。
- **核心断言**: `S-L3 (跨口径搬移)` / `Invariant-Broken`。`voter` 合约的资产（持有的 DXLYN 余额）应与其负债（`sum(voter.claimable)`) 保持平衡。`kill_gauge` 操作破坏了此恒等式。
- **影响门槛**: `Freeze` / `Loss`。该操作导致 `voter` 合约中的部分 DXLYN 资产永久无法被分配或提取，对协议构成资产损失。

## 详细说明

### 触发条件 / 调用栈
1.  一个或多个 `gauge` 获得了投票权重，`voter` 合约通过 `update_period()` → `notify_reward_amount()` 流程为它们记入了非零的 `claimable` 奖励。
2.  在这些奖励通过 `distribute_*` 函数被实际分发到 `gauge` 合约之前，治理方 (`governance`) 出于正常业务原因（例如，某个池子已弃用）调用 `voter::kill_gauge(gauge_address)`。

### 二级公式与口径
- **资产**: `voter` 合约自身的 DXLYN 余额。
- **负债**: `sum_claimable = Σ voter.claimable[g_i] for all i`
- **正常状态不变量**: `voter.balance_of(DXLYN) ≈ sum_claimable` (忽略微小精度损失)

### 缺陷分析
`kill_gauge` 函数在执行时，存在致命的逻辑遗漏：

```673:675:sources/voter.move
*is_alive = false;

table::upsert(&mut voter.claimable, gauge, 0);
```
- **L675 `table::upsert(&mut voter.claimable, gauge, 0);`**: 这一行代码直接将 `voter` 合约对该 `gauge` 的负债（即待分配的奖励金额）抹除，设置为 `0`。
- **遗漏步骤**: 函数在清零负债后，**没有对相应的资产进行任何处理**。这笔本应分配给 `gauge` 的 DXLYN 代币仍然留在 `voter` 合约的余额中。
- **状态不一致**: 该操作导致 `voter` 合约的资产负债表立刻失衡：`voter.balance_of(DXLYN) > sum_claimable`。差额正好等于被抹掉的 `claimable` 金额。

### 证据 (P1-P3)
-   **交易序列 (P1)**:
    1.  `voter::update_period()` 被调用，为 `gauge_A` 记入 `claimable[gauge_A] = 1,000,000`。此时 `voter` 合约收到 1,000,000 DXLYN。
    2.  `governance` 调用 `voter::kill_gauge(gauge_A)`。
    3.  **结果**: `claimable[gauge_A]` 变为 `0`，但 `voter` 合约的余额中仍有那 1,000,000 DXLYN。

-   **变量前后 (P2)**:
    *   `voter.claimable[gauge_A]`: `1,000,000` → `0`
    *   `voter.balance_of(DXLYN)`: `N + 1,000,000` → `N + 1,000,000` (未变)
    *   `sum(voter.claimable)`: `S + 1,000,000` → `S`
    *   **资产负债差额**: `0` → `1,000,000`

-   **影响量化 (P3)**:
    *   **冻结/损失金额**: 等于在 `distribute` 前被 `kill` 的所有 `gauge` 的 `claimable` 总额。这可能累积到数百万甚至更多的代币。
    *   **永久性**: `voter` 合约没有提供任何函数来提取这些无主资金（例如 `sweep` 或 `recover` 函数）。因此，这些资金被永久冻结，构成了事实上的协议资产损失。

### 利用草图
这是一个需要治理权限才能触发的协议逻辑缺陷，而非外部攻击。一个正常但不知情的治理操作即可触发此漏洞。

1.  **场景**: 协议运行数周后，决定下线一个旧的流动性池 `LP_Pool_Old`。
2.  **正常操作**:
    *   `voter` 合约按计划运行 `update_period()`，为 `LP_Pool_Old` 对应的 `gauge_old` 分配了当周的 `claimable` 奖励。
    *   在任何人调用 `distribute_all()` 之前，治理方执行 `kill_gauge(gauge_old)` 来使其失效。
3.  **损失发生**: `gauge_old` 的所有待领取奖励被清零，资金被永久困在 `voter` 合约中。流动性提供者因此损失了他们应得的全部奖励。

## 根因标签
-   `Inconsistent State Handling`
-   `Invariant-Broken`
-   `Missing Logic`

## 状态
Confirmed

---

# 🔍 Strict Adjudication Analysis

## Executive Verdict
**FALSE POSITIVE** - Reporter's claim contains factual errors about token flow timing, and the "vulnerability" represents a deliberate design trade-off for malicious gauge handling, not an unintended protocol flaw.

## Reporter's Claim Summary
Reporter claims that `kill_gauge` causes permanent token loss by zeroing `claimable[gauge]` without refunding tokens, breaking the invariant `voter.balance ≈ sum(claimable)`, resulting in frozen DXLYN tokens in the voter contract with no recovery mechanism.

## Code-Level Analysis

### Critical Factual Error in Reporter's Description

The reporter states (line 40-41):
> `voter::update_period()` 被调用，为 `gauge_A` 记入 `claimable[gauge_A] = 1,000,000`

**This is factually incorrect.** After deep code analysis:

**sources/voter.move:1027-1059 - `notify_reward_amount`:**
```move
public entry fun notify_reward_amount(minter: &signer, amount: u64) acquires Voter {
    ...
    primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);  // L1039
    ...
    voter.index = voter.index + ratio;  // L1057 - Updates GLOBAL index only
}
```
- This function transfers tokens to voter and updates a **global index**
- It does NOT set `claimable` for any specific gauge

**sources/voter.move:1847-1881 - `update_for_after_distribution`:**
```move
fun update_for_after_distribution(voter: &mut Voter, gauge: address) {
    ...
    if (delta > 0) {
        let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);

        let is_alive = *table::borrow(&voter.is_alive, gauge);  // L1871
        if (is_alive) {  // L1872 - CHECK: Only if alive
            let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
            *claimable = *claimable + share;  // L1874 - Sets claimable ONLY during distribution
        }
    }
}
```
- `claimable[gauge]` is ONLY set during distribution, not during `notify_reward_amount`
- It is ONLY set if `is_alive == true` (L1872)

**sources/voter.move:1650-1701 - `distribute_internal`:**
```move
fun distribute_internal(...) {
    ...
    update_for_after_distribution(voter, gauge);  // L1664 - Sets claimable here

    let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);  // L1666
    if (*claimable <= 0) { return };  // L1667-1668

    let is_alive = *table::borrow(&voter.is_alive, gauge);  // L1671
    if (*claimable > 0 && is_alive) {  // L1673
        gauge_*::notify_reward_amount(distribution, gauge, *claimable);  // L1686-1690
        *claimable = 0;  // L1693
    }
}
```
- Within a SINGLE transaction: claimable is calculated, checked, and distributed
- No window exists for pre-existing `claimable` balance before distribution

### The Actual Token Flow

**Reality:**
1. Epoch T: Gauge has voting weight W
2. End of Epoch T: `notify_reward_amount(A)` transfers A tokens to voter, updates global index
3. **Tokens are held in voter as a POOL, not pre-allocated to gauges**
4. During distribution: Each gauge's share is calculated on-the-fly based on weight
5. If gauge is dead when distribution runs, its share is NEVER calculated into `claimable`

**Key Insight:** The tokens are NOT "taken" from the gauge - they were NEVER allocated to it in the first place. The reporter's accounting model assumes pre-allocation, which is incorrect.

## Call Chain Trace

### Scenario: kill_gauge before distribution

**Step 1: notify_reward_amount**
- **Caller**: Minter contract
- **Callee**: voter::notify_reward_amount
- **msg.sender**: minter address (checked at L1032)
- **Call type**: `primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount)` (L1039)
- **Value**: `amount` DXLYN tokens transferred from minter to voter
- **State change**: `voter.index += ratio` (L1057)
- **Reentrancy**: None - simple state update

**Step 2: kill_gauge**
- **Caller**: Governance EOA
- **Callee**: voter::kill_gauge
- **msg.sender**: governance address (checked at L668)
- **State changes**:
  - `voter.is_alive[gauge] = false` (L673)
  - `voter.claimable[gauge] = 0` (L675)
  - `voter.total_weights_per_epoch[current_epoch] -= weights_per_epoch` (L683)
- **Call type**: Pure state manipulation
- **Reentrancy**: None

**Step 3: distribute_internal**
- **Caller**: Any EOA (via distribute_all/distribute_range)
- **Callee**: voter::distribute_internal → update_for_after_distribution
- **msg.sender**: voter contract (internal call)
- **Flow**:
  1. `update_for_after_distribution` calculates share = (weight * index_delta) / PRECISION
  2. Checks `is_alive == false` (L1871)
  3. SKIPS setting claimable (L1872-1875 not executed)
  4. Returns early at L1667-1668 because claimable == 0
- **Result**: Share is never allocated, never distributed

**Step 4: Token fate**
- **Location**: Remains in `primary_fungible_store` balance of voter contract address
- **Recoverability**: No sweep/rescue function exists in voter.move (verified via grep)

## State Scope Analysis

### voter.claimable: Table<address, u64>
- **Storage scope**: Global state in Voter resource at voter_address
- **Mapping key**: gauge address
- **Write locations**:
  - sources/voter.move:675 - `kill_gauge` sets to 0
  - sources/voter.move:1693 - `distribute_internal` sets to 0 after distribution
  - sources/voter.move:1874 - `update_for_after_distribution` increments (only if is_alive)
- **Context dependency**: Per-gauge accounting, NOT per-user

### voter balance (DXLYN tokens)
- **Storage scope**: FungibleAsset PrimaryFungibleStore at voter_address
- **Increases**:
  - sources/voter.move:1039 - `notify_reward_amount` transfers from minter
- **Decreases**:
  - sources/gauge_cpmm.move:351 - `notify_reward_amount` transfers from voter (distribution signer) to gauge
  - sources/gauge_clmm.move:~equivalent
  - sources/gauge_perp.move:~equivalent

### voter.index: u64
- **Storage scope**: Global state in Voter resource
- **Updates**: sources/voter.move:1057 - incremented by ratio on each emission
- **Purpose**: Global accumulator for proportional distribution calculation

### voter.is_alive: Table<address, bool>
- **Storage scope**: Global state in Voter resource
- **Mapping key**: gauge address
- **Write locations**:
  - sources/voter.move:673 - `kill_gauge` sets to false
  - sources/voter.move:706 - `revive_gauge` sets to true
- **Critical usage**: Guards claimable allocation at sources/voter.move:1872

## Exploit Feasibility

### Prerequisites
1. **Privileged access**: Requires governance signer (ERROR_NOT_GOVERNANCE at L668)
2. **Timing**: Must call kill_gauge BEFORE distribute_* for a gauge with voting weight
3. **On-chain controllability**: ❌ **FAILS** - Normal unprivileged EOA CANNOT execute this

### Attack Path Assessment
- **Attacker profile**: Must BE governance or compromise governance key
- **Per [Core-4]**: "Only accept attacks that a normal, unprivileged account can initiate"
- **Verdict**: This is a **governance operational risk**, not an unprivileged exploit

### Realistic Scenario
1. Governance discovers a gauge is compromised/malicious
2. Governance calls `kill_gauge` to immediately stop it
3. Distribution happens → share for killed gauge is not allocated
4. Tokens remain in voter, but this is INTENTIONAL design

### Counter-Scenario: Emergency Mode
**Reporter might argue:**
> What if gauge was already in emergency mode, distribution failed, claimable remained set, then kill_gauge zeros it?

**Verification - sources/gauge_cpmm.move:333-351:**
```move
public entry fun notify_reward_amount(distribution: &signer, gauge_address: address, reward: u64) {
    assert!(!gauge.emergency, ERROR_IN_EMERGENCY_MODE);  // L338
    ...
    primary_fungible_store::transfer(distribution, dxlyn_metadata, gauge_address, reward);  // L351
}
```

**Analysis:**
- If emergency mode, distribution fails at L338 BEFORE claimable update
- Looking at distribute_internal flow:
  - L1664: `update_for_after_distribution` sets claimable
  - L1686-1690: transfer fails → transaction reverts
  - L1693: never reached, claimable NOT zeroed
- So claimable COULD remain set after failed distribution
- Then kill_gauge zeros it → tokens stuck

**But:** This is STILL governance-initiated (both emergency mode and kill_gauge require privileges), not an unprivileged attack.

## Economic Analysis

### Input-Output for "Attacker"
**Cost:**
- Must compromise governance account (social engineering, key theft, etc.)
- Or be malicious governance insider

**Gain:**
- Tokens are frozen in voter, not stolen
- Attacker gains NOTHING economically
- Protocol loses tokens, LPs lose rewards

**Expected Value:**
- EV = 0 for attacker (no extraction possible)
- This is a **loss bug**, not an **exploit for profit**

### Impact on Parties
**Liquidity Providers:**
- Lose rewards for the killed gauge
- Impact: Real loss of yield

**Protocol:**
- Tokens stuck in voter contract forever
- No recovery mechanism (verified by examining all 23 public entry functions)
- Cumulative loss grows with each kill_gauge

**Realistic Scale:**
- Depends on gauge's weight share: if 10% of 1M emission = 100k DXLYN lost
- If governance kills 5 gauges over protocol lifetime: 500k DXLYN frozen
- At $1 per DXLYN: $500k permanent loss

### Gas vs Reward
Not applicable - this is not a gas-arbitrage or flashloan-style attack.

## Dependency/Library Reading

### primary_fungible_store::transfer
**Source**: Supra Framework (Aptos fork)
**File**: supra_framework/primary_fungible_store.move
**Behavior (verified from standard Aptos implementation):**
- Transfers fungible assets between addresses
- Updates sender's balance: `balance[sender] -= amount`
- Updates receiver's balance: `balance[receiver] += amount`
- No callbacks, no reentrancy vectors
- Atomic operation

### primary_fungible_store::balance
**Source**: Supra Framework
**Behavior:**
- Returns current balance of fungible asset for given address
- Pure read operation
- No state modifications

### table::upsert
**Source**: aptos_std::table
**Behavior:**
- If key exists: updates value
- If key doesn't exist: inserts new entry
- Pure state operation

**Note**: No complex external dependencies are involved in the vulnerability path. All operations are straightforward state manipulations.

## Final Feature-vs-Bug Assessment

### Is This Intended Behavior?

**Evidence for INTENDED design:**

1. **Function naming**: `kill_gauge` - implies permanent, irreversible action
2. **Function comment** (sources/voter.move:655): "Kill a malicious gauge"
   - Use case: Immediate shutdown of compromised gauge
   - Priority: Stop malicious activity > perfect accounting
3. **No refund logic**: Governance makes deliberate choice to kill gauge, accepting collateral damage
4. **revive_gauge exists** (L696) but does NOT restore claimable:
   - If token recovery was intended, revive would restore it
   - The fact it doesn't suggests intentional forfeit
5. **Design pattern**: Emergency actions often sacrifice accounting precision for speed/safety
   - Example: Emergency withdrawals in DeFi often leave dust/residue

**Evidence for UNINTENDED bug:**

1. **No sweep function**: Protocol has no way to recover frozen tokens
2. **Cumulative loss**: Each kill compounds the problem
3. **User impact**: LPs lose rewards through no fault of their own
4. **Accounting discrepancy** (per acc_modeling/voter_de_account.md:367-371):
   - System recognizes this as a "risk"
   - Lists it under "高风险" (high risk)
5. **Alternative design exists**: Could transfer claimable to treasury before zeroing

### The Verdict

**This is a DESIGN FLAW presented as a feature.**

The behavior is **technically intentional** (no code bug), but represents a **poor design choice** that:
- Harms innocent LPs who staked in good faith
- Causes permanent protocol loss with no recovery
- Could be easily fixed by adding a sweep function or transferring claimable to treasury

However, per the strict adjudication criteria:

### [Core-7] Assessment
"If impact depends on a privileged user performing fully normal/ideal actions, confirm that the loss arises from an intrinsic protocol logic flaw."

- ✅ Privileged user (governance) performs normal action (killing malicious gauge)
- ✅ Loss arises (tokens frozen)
- ❓ Is this an "intrinsic flaw" or "accepted trade-off"?

The function's PURPOSE is to kill malicious gauges. Denying rewards to a malicious gauge is arguably CORRECT behavior. The fact that tokens get stuck in voter is collateral damage.

### [Core-8] Assessment
"Perform final feature-vs-bug assessment to determine whether the behavior is intentional design, not a defect."

**Conclusion**: This is **intentional design with suboptimal implementation**.

**Recommended Fix** (not a critical bug fix):
```move
public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
    ...
    // BEFORE zeroing claimable, transfer it to treasury
    let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
    if (claimable_amount > 0) {
        primary_fungible_store::transfer(
            &voter_signer,
            dxlyn_metadata,
            voter.fee_treasury,  // Or burn address
            claimable_amount
        );
    }

    table::upsert(&mut voter.claimable, gauge, 0);
    ...
}
```

But the absence of this is NOT a critical vulnerability - it's a **quality-of-life improvement** for better token management.

---

# 📊 Final Classification

| Criterion | Assessment |
|-----------|------------|
| **Logic Existence** | ✅ Behavior exists as described (with timing correction) |
| **Exploitability** | ❌ Requires governance privileges (fails [Core-4]) |
| **Economic Viability** | ❌ No profit for attacker (loss bug, not exploit) |
| **Attack Path** | ❌ Not 100% attacker-controlled (requires governance) |
| **Practical Risk** | ⚠️ Real loss to LPs, but from governance action |
| **Feature vs Bug** | ⚠️ Intentional design with poor UX |

**Final Verdict**: **INFORMATIONAL / CENTRALIZATION RISK**

This is NOT a critical vulnerability per strict audit standards:
- Cannot be exploited by unprivileged attackers ([Core-4])
- Is a result of privileged governance action
- Represents a design trade-off, not a code bug
- Falls under "centralization issues" which per [Core-5] are **out of scope**

**Recommended Action**: Document as "improvement suggestion" rather than critical finding. Governance should be aware of token loss when calling kill_gauge, and ideally a sweep function should be added for better treasury management.
