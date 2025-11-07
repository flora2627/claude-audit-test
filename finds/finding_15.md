## 标题
`bribe` 模块的奖励计算存在双重精度损失和领取周期限制，导致部分奖励永久冻结 🚨

## 类型
Mis-measurement / Gas-DoS / Freeze

## 风险等级
Medium

## 位置
- `sources/bribe.move`: `reward_per_token_internal` (L1315), `earned_internal` (L1339), `earned_with_timestamp_internal` (L1265)

## 发现依据

`bribe` 模块的奖励领取机制存在两个独立但共同导致资金冻结的设计缺陷：

### 1. 双重整数除法截断 (精度损失)

奖励计算分为两步，每一步都存在整数除法导致的精度损失：

a. **计算每权重奖励 (`reward_per_token_internal`)**:
   ```1326:sources/bribe.move
   (reward_per_epoch * MULTIPLIER) / *total_supply
   ```
   如果 `reward_per_epoch * MULTIPLIER` 不能被 `total_supply` 整除，余数部分会被截断。这导致计算出的 `reward_per_token` 系统性地小于理论值。

b. **计算用户应得奖励 (`earned_internal`)**:
   ```1351:sources/bribe.move
   let rewards = (reward_per_token * balance) / MULTIPLIER;
   ```
   这一步使用上一步有偏差的结果，再次进行整数除法。如果 `reward_per_token * balance` 不能被 `MULTIPLIER` 整除，会发生第二次截断。

**影响**:
这两次截断的累积效应，使得 `sum(所有用户计算出的奖励)` **严格小于** `rewards_per_epoch` 的总量。这个差额（dust）会永久留在 `bribe` 合约中，无法被任何用户领取，构成**资金冻结 (Freeze)**。

### 2. 50 周领取上限 (Gas DoS)

`earned_with_timestamp_internal` 函数在计算用户可领取的总奖励时，使用了一个硬编码的 50 周循环上限：

```1280:sources/bribe.move
for (i in 0..FIFTY_WEEKS) {
```

**影响**:
- **强制多次交易**: 如果一个用户超过 50 周没有领取奖励，他必须反复调用 `get_reward` 函数才能领完所有历史奖励。
- **经济上的拒绝服务 (DoS)**: 对于持有少量投票权的用户，单次领取的奖励价值可能远低于发起一次交易所消耗的 Gas 费用。如果 `(总奖励 / 需要的交易次数) < Gas Fee`，那么对该用户而言，领取剩余奖励在经济上是不可行的。
- **事实上的资金冻结 (Freeze)**: 对于小额用户，部分奖励因为领取成本过高而被事实性地永久冻结在合约中。

## 综合影响
- **系统性资金流失**: 精度损失导致每一笔贿赂都有一部分被永久锁定。
- **损害小额用户利益**: 50 周的领取限制使得小额投票者无法经济地获取他们的全部奖励，构成了一种针对他们的 DoS 攻击。
- **会计不平衡**: `bribe` 合约的实际资产余额将逐渐且永久性地高于其可支付的负债总和。

## 攻击路径
这不是一个主动攻击获利的路径，而是一个被动导致用户资金损失的协议设计缺陷。

1.  **精度损失场景**:
    *   外部用户为某个池子提供了一笔不能被当时 `total_supply` 整除的贿赂。
    *   投票给该池子的用户在领取奖励时，每个人都会因双重截断而损失一小部分应得奖励。
    *   这些损失的灰尘累积在合约中。

2.  **50周限制场景**:
    *   一个小户参与投票，并获得了价值 $0.5 的贿赂奖励，分布在 52 周内。
    *   一年后，他尝试领取奖励。第一次 `get_reward` 调用花费了他 $0.1 的 Gas，领取了前 50 周的奖励（价值约 $0.48）。
    *   他需要再进行一次交易来领取最后 2 周的奖励（价值约 $0.02），但这次交易的 Gas 费仍然是 $0.1。
    *   **结果**: 该用户在经济上被迫放弃最后 $0.02 的奖励，这部分资金被永久冻结。

## 根因标签
`Mis-measurement` / `Gas-DoS` / `Freeze`

## 状态
Confirmed

---

# ADJUDICATION REPORT

## Executive Verdict: **FALSE POSITIVE** (Informational at best)

Both claimed issues exist in the code but neither constitutes a valid vulnerability. The precision loss is a standard limitation of integer arithmetic in smart contracts and is not exploitable. The 50-week claim limit is an intentional gas optimization feature, not a DoS vulnerability. Dust accumulation can be recovered by privileged owners, and users retain full control over their rewards through multiple claims.

---

## Reporter's Claim Summary

The report alleges two issues in the bribe module:
1. **Double integer division truncation**: Two-step reward calculation causes precision loss, leaving "dust" permanently frozen in the contract
2. **50-week claim limit**: Forces users to make multiple transactions, creating economic DoS for small holders when gas costs exceed remaining rewards

---

## Code-Level Analysis

### Issue 1: Double Division Precision Loss

**Location**: `sources/bribe.move`
- Line 1326: `reward_per_token_internal`
- Line 1351: `earned_internal`

**Code Verification**:

```move
// Step 1: Line 1326
(reward_per_epoch * MULTIPLIER) / *total_supply

// Step 2: Line 1351
let rewards = (reward_per_token * balance) / MULTIPLIER;
```

**Finding**: ✅ The double division DOES exist as claimed.

**Mathematical Analysis**:

Given:
- `R` = reward_per_epoch
- `S` = total_supply
- `B` = user balance
- `M` = MULTIPLIER (100,000,000)

The code computes:
```
rpt = floor((R * M) / S)
user_reward = floor((rpt * B) / M)
```

Expected direct calculation:
```
user_reward = floor((R * B) / S)
```

**Worst-case loss computation**:

Example with extreme parameters:
- R = 100 tokens
- S = 3 (three users with B=1 each)
- M = 100,000,000

Step 1: `rpt = floor(100 * 100,000,000 / 3) = 3,333,333,333`

Each user: `floor(3,333,333,333 * 1 / 100,000,000) = 33`

Total distributed: 99 tokens
**Loss: 1 token (1% of reward)**

**However**, with realistic parameters:
- R = 10,000 tokens
- S = 1,500,000 voting power
- M = 100,000,000

Step 1: `rpt = floor(10,000 * 100,000,000 / 1,500,000) = 666,666`

User with B=10,000: `floor(666,666 * 10,000 / 100,000,000) = 66`

Expected: `floor(10,000 * 10,000 / 1,500,000) = 66`

**Loss: negligible (< 0.01% typically)**

### Issue 2: 50-Week Claim Limit

**Location**: `sources/bribe.move:1280`

```move
for (i in 0..FIFTY_WEEKS) {
    if (user_last_time == end_timestamp) {
        break
    };
    let week_reward = earned_internal(bribe, owner, user_last_time, reward_token);
    // ... accumulate rewards
    user_last_time = user_last_time + week;
};
```

**Finding**: ✅ The 50-week loop limit DOES exist as claimed.

**However**, examining the reward claim flow (lines 1150-1191):

```move
fun get_reward_internal(...) {
    let (reward, user_last_time) = earned_with_timestamp_internal(...);

    // Transfer rewards
    // ...

    // CRITICAL: Update user's timestamp to new position (line 1185)
    table::upsert(owner_reward_last_timestamp, reward_token, user_last_time);
}
```

**Key observation**: After claiming 50 weeks, `user_last_time` advances by 50 weeks and is saved. The next `get_reward` call starts from this new position and can claim the next 50 weeks.

**This means**: Users can claim ALL rewards through multiple transactions. No rewards are "permanently frozen" - they just require additional transaction calls.

---

## Call Chain Trace

### Reward Claim Flow:

1. **User calls**: `get_reward(owner, pool, reward_tokens)` (line 615)
   - Caller: User EOA
   - msg.sender: User address
   - Call type: entry function

2. **Calls**: `get_reward_internal(bribe, bribe_address, owner_address, reward_token, pool)` (line 1150)
   - Caller: bribe module
   - Callee: internal function
   - Context: Same transaction

3. **Calls**: `earned_with_timestamp_internal(bribe, owner_address, reward_token, pool, true)` (line 1157)
   - Returns: (total_reward, updated_user_last_time)
   - Loops: Up to 50 iterations
   - Each iteration calls: `earned_internal(bribe, owner, timestamp, reward_token)` (line 1286)

4. **Transfers**: Rewards via `primary_fungible_store::transfer` (line 1166)
   - From: bribe contract
   - To: user address
   - Amount: Computed rewards for up to 50 weeks

5. **Updates state**: `table::upsert(owner_reward_last_timestamp, reward_token, user_last_time)` (line 1185)
   - **CRITICAL**: Advances user's checkpoint by 50 weeks
   - Next claim starts from this new position

### External Calls:
- `primary_fungible_store::transfer` (line 1166): Standard Aptos framework call
- No delegatecall or complex reentrancy vectors

---

## State Scope & Context Audit

### Key State Variables:

1. **`total_supply: Table<u64, u64>`** (line 203)
   - Storage: Per-bribe, per-timestamp
   - Scope: Maps timestamp → total voting power at that epoch
   - Access: Read-only in reward calculations

2. **`balance: Table<address, Table<u64, u64>>`** (line 205)
   - Storage: Per-bribe, per-user, per-timestamp
   - Scope: Maps (user_address, timestamp) → voting power balance
   - Access: Read-only in reward calculations

3. **`user_timestamp: Table<address, Table<address, u64>>`** (line 201)
   - Storage: Per-bribe, per-user, per-reward-token
   - Scope: Maps (user, reward_token) → last_claim_timestamp
   - **Critical**: This advances by up to 50 weeks per claim (line 1185)
   - **User-specific**: Each user has independent checkpoint

4. **`reward_data: Table<address, Table<u64, Reward>>`** (line 192)
   - Storage: Per-bribe, per-reward-token, per-epoch
   - Scope: Maps (reward_token, timestamp) → Reward struct
   - Contains: rewards_per_epoch for distribution

### Storage Slot Validation:

No assembly or custom storage slot manipulation detected. All state access uses standard Move table operations with clear scoping.

---

## Exploit Feasibility

### Issue 1: Precision Loss

**Can an unprivileged EOA exploit this?** ❌ NO

- The precision loss is **systematic**, not exploitable
- All users lose proportionally (no one gains)
- An attacker cannot manipulate the loss to their advantage
- The loss is a function of arithmetic rounding, not controllable input

**Attack prerequisites**: None (because no attack exists)

### Issue 2: 50-Week Limit

**Can an unprivileged EOA exploit this?** ❌ NO

- This is a **gas optimization**, not a vulnerability
- Users can claim all rewards through multiple transactions
- User checkpoint (`user_timestamp`) advances with each claim
- No rewards are made inaccessible

**Attack prerequisites**: None (this is not an attack vector)

---

## Economic Analysis

### Issue 1: Dust Accumulation

**Assumptions**:
- Typical bribe: 10,000 tokens per epoch
- Typical total_supply: 1,000,000 voting power
- 100 active users

**Computed loss per epoch**:
- First division remainder: < 1 token (0.0001%)
- Second division cumulative: < number_of_users in smallest units
- **Total loss: < 0.01% of reward in realistic scenarios**

**Annual accumulation** (52 epochs):
- Worst case: 52 * 1 = 52 tokens dust
- At $1/token: **$52 per year** across entire protocol

**Recovery mechanism**:
Lines 330-370: `recover_and_update_data` allows owner to recover excess tokens
Lines 383-412: `emergency_recover` provides fallback recovery

**Conclusion**: Dust is NOT permanently frozen - privileged owner can recover it.

### Issue 2: Gas Economics

**Reporter's claim**:
- User has $0.5 rewards over 52 weeks
- Gas cost: $0.1 per transaction
- After claiming 50 weeks ($0.48), remaining $0.02 < $0.1 gas

**Reality check on Aptos/Supra gas costs**:

Aptos/Supra typical transaction costs:
- Simple transfer: ~0.0001-0.001 APT
- Complex function: ~0.001-0.01 APT
- At $10/APT: **$0.001 to $0.1** per transaction

**Revised analysis with realistic gas ($0.01)**:
- Claim 50 weeks ($0.48): Net = $0.48 - $0.01 = $0.47 ✅ Profitable
- Claim 2 weeks ($0.02): Net = $0.02 - $0.01 = $0.01 ✅ Still profitable

**Even at high gas ($0.05)**:
- Claim 50 weeks: Net = $0.43 ✅
- Claim 2 weeks: Net = -$0.03 ❌ Unprofitable

**But**:
1. Users can claim more frequently (every 20-40 weeks) to avoid this
2. Users can batch multiple reward tokens in one call
3. Small holders naturally gravitate to pools with higher bribes
4. This is user choice, not protocol vulnerability

**Input-Output Ratio**:
- Attacker input: None (no attack exists)
- Attacker output: None
- **ROI: N/A** (this is not exploitable)

---

## Dependency/Library Reading Notes

**Aptos Framework Dependencies**:

1. **`primary_fungible_store::transfer`** (line 1166):
   ```move
   // From aptos_framework::primary_fungible_store
   public fun transfer<T: key>(
       sender: &signer,
       metadata: Object<T>,
       recipient: address,
       amount: u64
   )
   ```
   - Standard Aptos transfer
   - No hidden behavior
   - Amount parameter directly controls transfer size
   - Verified: No rounding or precision loss in transfer itself

2. **`table::upsert`** (line 1185):
   ```move
   // From aptos_std::table
   public fun upsert<K: copy + drop, V: drop>(table: &mut Table<K, V>, key: K, value: V)
   ```
   - Updates or inserts key-value pair
   - No side effects
   - Verified: User checkpoint updates correctly

**No unexpected behaviors found in dependencies.**

---

## Feature vs. Bug Assessment

### Issue 1: Precision Loss

**Is this intentional design?** ✅ YES

Evidence:
- Line 1325 comment: `// calculation may lose precision in some case`
- Line 1350 comment: `// calculation may lose precision in some case`
- Developer explicitly acknowledged this limitation

**Why use two-step calculation?**
- `reward_per_token` can be computed once and reused for all users
- More gas-efficient than computing `(reward * balance / supply)` for each user
- Standard pattern in DeFi (e.g., Synthetix StakingRewards)

**Is this a bug?** ❌ NO
- This is a known tradeoff: gas efficiency vs. precision
- Loss is negligible (< 0.01% in realistic scenarios)
- Recoverable by owner
- Does not violate any protocol invariants

### Issue 2: 50-Week Limit

**Is this intentional design?** ✅ YES

Evidence:
- Line 40: `const FIFTY_WEEKS: u64 = 50;` - explicitly defined constant
- Line 39 comment: `/// We are only allowing 50 weeks of rewards to be claimed`
- Function `get_remaining_bribe_claim_calls` (line 1089) - helper for users to check remaining claims

**Why limit to 50 weeks?**
- Prevents unbounded loops that could exceed gas limits
- 50 weeks = ~1 year of rewards in single transaction
- Users expected to claim at least annually
- Multiple claims supported via checkpoint system

**Is this a bug?** ❌ NO
- This is intentional gas optimization
- Standard pattern for preventing unbounded iteration
- Users retain full control via multiple claims
- No funds are frozen or inaccessible

---

## Final Assessment

### Issue 1: Precision Loss - FALSE POSITIVE

**Verdict**: This is **not a vulnerability**, it is a **known design tradeoff**.

**Reasoning**:
1. ✅ Logic exists as described
2. ❌ Not exploitable by unprivileged users
3. ❌ No economic gain possible for attackers
4. ✅ Loss is negligible in realistic scenarios (< 0.01%)
5. ✅ Dust is recoverable by protocol owner
6. ✅ Explicitly acknowledged by developers (comments)
7. ✅ Standard DeFi pattern for gas optimization

**Classification**: Informational / Known limitation of integer arithmetic

### Issue 2: 50-Week Claim Limit - FALSE POSITIVE

**Verdict**: This is **not a DoS vulnerability**, it is an **intentional gas optimization feature**.

**Reasoning**:
1. ✅ Logic exists as described
2. ❌ Not a DoS - users can make multiple claims
3. ❌ No funds are frozen or inaccessible
4. ✅ User checkpoint advances correctly
5. ❌ Gas economics claim based on unrealistic assumptions ($0.1 gas)
6. ✅ Users can optimize by claiming more frequently
7. ✅ Explicitly designed feature with helper functions

**Classification**: Informational / Gas optimization design choice

### Combined Verdict: **FALSE POSITIVE**

Neither issue constitutes a valid vulnerability. The report mischaracterizes intentional design decisions as bugs and uses unrealistic economic assumptions to inflate severity.

**Correct severity**: Informational (if included at all)

**Recommendations** (for protocol improvement, not bug fixes):
1. Document the precision loss tradeoff in user-facing materials
2. Provide UI warnings when users have >40 weeks of unclaimed rewards
3. Consider adding batch claim helper for multiple pools/tokens
4. Document gas optimization rationale for 50-week limit

---

**Adjudication completed by**: Strict Vulnerability Auditor
**Date**: 2025-11-07
**Methodology**: Full source code verification, dependency analysis, economic modeling, and adversarial testing
