## 标题
`voter::notify_reward_amount` 精度截断导致周排放永久滞留 `voter` 合约🚨

## 类型
Unsustainability / Financial Model Breakdown

## 风险等级
High

## 位置
- `sources/voter.move`: `notify_reward_amount` 与 `update_for_after_distribution`

## 发现依据
1. 每周排放 `amount` 会在 `notify_reward_amount` 顶部直接转入 `voter` 合约：


```1041:1059:sources/voter.move
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);
...
let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256);
let ratio = (scaled_ratio as u64);
if (ratio > 0) {
    voter.index = voter.index + ratio;
}
```

2. 若上一周总权重 `total_weight` 超过 `amount * 10^8`，`scaled_ratio` 的整数部分为 0，`ratio` 恒为 0，指数不再增长。随后在 `update_for_after_distribution`：


```1863:1875:sources/voter.move
let delta = index - supply_index;
if (delta > 0) {
    let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);
    *claimable = *claimable + share;
}
```

由于 `index` 未更新，`delta = 0`，所有 gauge 的 `claimable` 均保持 0；而对应 emission 已经进入 `voter`，永久滞留。

3. 锁仓权重以 10¹² 精度计（投票权 × 时间 × `AMOUNT_SCALE`），奖励缩放仅有 10⁸，限制条件约为：

```
amount ≥ total_weight / 10^8 ≈ (Σ锁仓 DXLYN) / 10^4
```

当系统锁仓 2,000 万 DXLYN 且全部锁满 4 年时，需要每周至少 ~2000 DXLYN 才能让 `ratio ≥ 1`。随着排放衰减（或攻击者巨量锁仓），极易触发 `ratio = 0` 的“停摆点”。

## 影响
- 一旦触发行权条件，协议仍持续铸造 DXLYN 并转入 `voter`，但所有 `claimable[gauge]` 永远不会增加，LP 与治理参与者拿不到本周奖励。
- 排放曲线出现断档，`voter` 合约资产 ≫ 负债（`sum(claimable)`），奖励体系实质被关闭，可构成“财务欺诈 / 激励瘫痪”。
- 攻击者只需在减排期之前加大锁仓权重，即可提前“锁死”奖励，不必直接获利也能破坏整个财务模型。

## 建议（非修复指引）
- 调整 `ratio` 计算的缩放逻辑，使 `amount` 与 `total_weight` 的精度兼容，可借鉴 `AMOUNT_SCALE * DXLYN_DECIMAL` 的乘积或随指数记录残余；
- 或为 `update_for_after_distribution` 引入残余追补机制，在指数不变时亦能分摊本周 emission，避免资金沉积。

## 置信度
高

---

# ADJUDICATION REPORT

## 1) Executive Verdict
**INFORMATIONAL** - The reported precision truncation mechanism exists and can cause permanent fund lock, but it is NOT exploitable by an unprivileged attacker under realistic economic conditions. This is a long-term protocol sustainability issue (manifests after ~13.5 years) rather than an active vulnerability.

## 2) Reporter's Claim Summary
The reporter claims that in `voter::notify_reward_amount`, when `total_weight > amount * 10^8`, the integer truncation of `ratio = (scaled_ratio as u64)` results in `ratio = 0`. This prevents the global `index` from increasing, which means no gauge receives any `claimable` rewards despite the weekly emission being transferred to the voter contract. The reporter suggests an attacker can deliberately trigger this by increasing locked stake.

## 3) Code-Level Analysis

### 3.1 Precision Truncation Logic (CONFIRMED)
**Location**: `sources/voter.move:1050-1058`

```move
let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256);
ratio = (scaled_ratio as u64);

if (ratio > 0) {
    voter.index = voter.index + ratio;
};
```

**Verification**: The truncation exists as claimed. When `scaled_ratio < 1`, casting to `u64` yields `ratio = 0`.

**Mathematical Condition**:
- `scaled_ratio = (amount * 10^8) / total_weight`
- For `ratio >= 1`: `amount * 10^8 >= total_weight`
- Therefore: `amount >= total_weight / 10^8`

### 3.2 Funds Transfer (CONFIRMED)
**Location**: `sources/voter.move:1039`

```move
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);
```

**Verification**: Funds are transferred BEFORE the ratio calculation, not conditionally. If `ratio = 0`, funds remain in voter contract but are not accounted for in any gauge's claimable amount.

### 3.3 Distribution Mechanism (CONFIRMED)
**Location**: `sources/voter.move:1863-1875`

```move
let delta = index - supply_index;

if (delta > 0) {
    let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);
    let is_alive = *table::borrow(&voter.is_alive, gauge);
    if (is_alive) {
        let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
        *claimable = *claimable + share;
    }
}
```

**Verification**: Distribution depends entirely on `delta` (index change). If `ratio = 0` in `notify_reward_amount`, then `voter.index` doesn't increase, resulting in `delta = 0` and no claimable additions.

### 3.4 Recovery Mechanism (NONE FOUND)
**Analysis**: Searched all `public entry fun` functions in voter.move. No administrative function exists to:
- Withdraw stuck funds
- Manually adjust the index
- Redistribute unaccounted emissions

**Conclusion**: Funds that result in `ratio = 0` are **permanently irrecoverable**.

## 4) Call Chain Trace

**Emission Flow (Weekly Epoch)**:

1. **Minter calls** `voter::notify_reward_amount`
   - Caller: `minter` (address from `voter.minter`)
   - Callee: `voter` contract
   - `msg.sender`: minter address
   - Call type: Direct entry function call
   - Value transferred: `amount` DXLYN tokens from minter to voter

2. **Voter contract** performs internal accounting
   - Reads `total_weights_per_epoch[epoch-WEEK]`
   - Calculates `ratio = (amount * 10^8) / total_weight`
   - Updates `voter.index += ratio` (IF ratio > 0)

3. **Distribution calls** `distribute_internal` → gauge-specific `notify_reward_amount`
   - Caller: Any user calling `distribute_*`
   - Callee: gauge contracts (CPMM/CLMM/Perp)
   - Calls `update_for_after_distribution` first
   - Transfers `claimable[gauge]` amount to gauge (IF claimable > 0)

**Critical Dependency**: Step 3's distribution amount depends on step 2's index update. If step 2 results in `ratio = 0`, step 3 distributes nothing, leaving funds in voter contract.

## 5) State Scope Analysis

### Global State (voter contract):
- `voter.index: u64` - Global accumulator (line 283 in struct Voter)
  - Storage: Voter resource at `@voter` address
  - Scope: Global, shared across all gauges
  - Updated only in `notify_reward_amount` when `ratio > 0`

- `voter.claimable: Table<address, u64>` - Per-gauge claimable amounts (line 289)
  - Storage: Voter resource
  - Scope: Per-gauge mapping
  - Updated in `update_for_after_distribution` when `delta > 0`

- `voter.supply_index: Table<address, u64>` - Last index per gauge (line 287)
  - Storage: Voter resource
  - Scope: Per-gauge checkpoint
  - Tracks when each gauge last claimed

- `voter.total_weights_per_epoch: Table<u64, u64>` - Total votes per epoch (line 305)
  - Storage: Voter resource
  - Scope: Per-epoch timestamp mapping
  - Populated during voting in `vote_internal` (line 1837)

### Voting Escrow State:
- Voting power calculation (voting_escrow.move:1448-1449, 1454-1455):
  ```move
  u_old.slope = (old_locked.amount * AMOUNT_SCALE) / MAXTIME;
  u_old.bias = u_old.slope * (old_locked.end - current_time);
  ```
  - `AMOUNT_SCALE = 10^4` (voting_escrow.move:52)
  - `MAXTIME = 126144000` (4 years in seconds) (voting_escrow.move:46)
  - For max lock: `voting_power = locked_amount * 10^4`

### Assembly/Slot Math:
**None found**. All storage uses Move's native Table structures.

## 6) Exploit Feasibility

### 6.1 Prerequisites for Ratio = 0

**Mathematical Requirement**:
```
total_weight > amount * 10^8
```

**Voting Power Calculation**:
- For 1 DXLYN (10^8 base units) locked for 4 years:
  - `voting_power ≈ 10^8 * 10^4 = 10^12`
- For X DXLYN tokens locked (max):
  - `total_weight ≈ X * 10^8 * 10^4 = X * 10^12`

**Threshold Calculation**:
```
amount >= total_weight / 10^8
amount >= (X * 10^12) / 10^8
amount >= X * 10^4
```

Where X is total DXLYN tokens locked.

### 6.2 Attack Scenarios

**Emission Parameters** (from test_emission.move:91-94):
- Initial supply: 100M DXLYN
- Initial emission: 2% = 2M DXLYN/week
- Decay rate: 1% per week (starting week 13)
- Total supply: 100M DXLYN

| Scenario | Locked TVL | Threshold | Required to DoS | Feasibility |
|----------|-----------|-----------|-----------------|-------------|
| Low TVL | 100K DXLYN | 10 DXLYN/week | N/A | Naturally occurs at week ~1,040 (20 years) |
| Medium TVL | 1M DXLYN | 100 DXLYN/week | N/A | Naturally occurs at week ~840 (16 years) |
| High TVL | 10M DXLYN | 1,000 DXLYN/week | N/A | Naturally occurs at week ~770 (14.8 years) |
| Very High TVL | 20M DXLYN | 2,000 DXLYN/week | N/A | Naturally occurs at week ~701 (13.5 years) |
| Current Emission | Any | - | 20B DXLYN | **IMPOSSIBLE** (200x total supply) |
| After decay to 10K/week | - | - | 100M DXLYN | **IMPOSSIBLE** (1x total supply, need to lock everything) |
| After decay to 5K/week | - | - | 50M DXLYN | **MARGINALLY POSSIBLE** (50% of supply) |

### 6.3 Can Unprivileged EOA Exploit?

**Attack Vector Analysis**:
1. **Direct Attack** (manipulate total_weight to exceed emission * 10^8):
   - Requires locking massive amounts of DXLYN
   - For initial 2M DXLYN/week emission: Need 20 billion DXLYN (200x total supply)
   - **VERDICT**: Not feasible

2. **Wait for Natural Decay**:
   - After ~13.5 years, emission naturally drops below threshold (assuming 20M TVL)
   - This is not an "attack" - it's a natural protocol lifecycle event
   - **VERDICT**: Not an exploit, but a design flaw

3. **Compound Effect** (lock additional stake as emissions decay):
   - To trigger earlier, attacker could lock 50M DXLYN when emission drops to 5K/week
   - Requires acquiring 50% of total supply
   - **VERDICT**: Economically irrational - the cost far exceeds any benefit

### 6.4 Privileged Operations

**No privileged operations required**. The issue occurs automatically in `notify_reward_amount` when mathematical condition is met. However, triggering it deliberately requires economic resources beyond any rational actor's capability.

## 7) Economic Analysis

### 7.1 Attack Input/Output

**Scenario: Deliberate DoS Attack (when emission = 5,000 DXLYN/week)**

**Inputs (Attacker Cost)**:
- Acquire 50M DXLYN (50% of total supply)
- Assume market price: $1 per DXLYN
- **Cost**: $50,000,000
- Lock for 4 years (capital locked, no liquidity)
- **Opportunity cost**: 4 years of lost yield/trading opportunities

**Outputs (Attacker Gain)**:
- Blocks 5,000 DXLYN distribution for that week
- Value denied to LPs: $5,000
- No direct financial gain to attacker
- Creates governance crisis / loss of faith in protocol

**ROI Calculation**:
```
ROI = (Gain - Cost) / Cost
ROI = ($0 - $50,000,000) / $50,000,000
ROI = -100%
```

**Expected Value**: Strongly negative. Attack is economically irrational.

### 7.2 Sensitivity Analysis

| Emission Level | Required Lock | Cost (@ $1/token) | Weekly Damage | Attack ROI |
|---------------|--------------|-------------------|---------------|-----------|
| 2M DXLYN/week | 20B DXLYN | **IMPOSSIBLE** | $2M | N/A |
| 10K DXLYN/week | 100M DXLYN | **IMPOSSIBLE** | $10K | N/A |
| 5K DXLYN/week | 50M DXLYN | $50M | $5K | -99.99% |
| 2K DXLYN/week | 20M DXLYN | $20M | $2K | -99.99% |
| 1K DXLYN/week | 10M DXLYN | $10M | $1K | -99.99% |

**Conclusion**: At no emission level is this attack economically viable. The cost-to-impact ratio is orders of magnitude unfavorable.

### 7.3 Natural Occurrence Impact

When this occurs naturally (after ~13.5 years with 20M TVL):
- **Direct Loss**: 2,000 DXLYN/week permanently locked in voter contract
- **Cumulative Loss**: If undetected, compounds weekly
- **Systemic Impact**: Breaks reward distribution, LPs lose incentives
- **Protocol Death**: Likely causes mass exodus once discovered

## 8) Dependency/Library Reading

### 8.1 Supra Framework Dependencies

**primary_fungible_store::transfer** (supra_framework):
- Standard token transfer from one address to another
- No special rounding or precision logic
- Exact amount transferred as specified

**No precision-related helpers** were found in the codebase that could mitigate this issue.

### 8.2 Move Language Behavior

**Integer Division Truncation**:
- Move follows standard integer division semantics
- `(x as u256) / (y as u256)` truncates toward zero
- Casting `(result as u64)` discards fractional part
- **No automatic rounding** or precision preservation

From Move documentation:
> "Integer division truncates. There is no automatic conversion between integer types."

This confirms the reporter's claim about precision loss.

## 9) Final Feature-vs-Bug Assessment

### Is This Intended Behavior?

**Evidence AGAINST intentional design**:
1. No comments in code indicating this is expected
2. No emergency recovery mechanism (suggests oversight)
3. No precision accumulation logic (suggests not designed for this)
4. Economic impact is clearly negative for protocol

**Evidence FOR intentional design**:
1. None found

### Bug Classification

**Root Cause**: Precision mismatch between:
- Voting weight scale (uses `AMOUNT_SCALE = 10^4` from voting_escrow)
- Reward distribution scale (uses `DXLYN_DECIMAL = 10^8` from voter)
- No accumulator for fractional values

**Minimal Fix** (theoretical only, not providing implementation):
1. Track fractional remainder in a higher-precision accumulator
2. Add recovery mechanism for stuck funds
3. Use larger scaling factor (e.g., 10^18 instead of 10^8)
4. Implement minimum emission threshold check with revert

## 10) Severity Reassessment

### OWASP Risk Rating Methodology

**Likelihood**:
- **Exploitability**: 1/10 (Not exploitable by rational attacker)
- **Natural Occurrence**: 8/10 (Will happen after ~13.5 years)
- **Combined Likelihood**: LOW-MEDIUM (natural event, not exploit)

**Impact**:
- **Financial**: HIGH (permanent loss of emissions)
- **Technical**: HIGH (breaks core distribution mechanism)
- **Reputation**: HIGH (protocol failure)
- **Combined Impact**: HIGH

**Overall Severity**:
- As an exploit: **INFORMATIONAL** (not exploitable)
- As a design flaw: **MEDIUM** (long-term sustainability issue)
- As a CVE: **N/A** (not a security vulnerability)

### Recommended Classification

**INFORMATIONAL / LOW**

**Rationale**:
1. Not exploitable by unprivileged attackers (requires impossible economic conditions)
2. Manifests only after 13+ years of operation
3. Protocol can be upgraded before issue becomes critical
4. More appropriate for "long-term protocol sustainability" category
5. Does not meet criteria for "High" severity vulnerability:
   - No immediate fund loss
   - No attacker profit
   - Requires unrealistic economic conditions for deliberate trigger
   - Natural occurrence is far in the future

### Comparison to Reporter's Rating

**Reporter claimed**: High severity vulnerability with active attack vector

**Adjudicator finding**: Informational/Low - natural protocol lifecycle issue, not exploitable

**Key disagreement**: Reporter's assumption that "攻击者只需在减排期之前加大锁仓权重" is economically feasible. Our analysis shows this requires 50-200x total supply worth of capital for negative ROI, making it completely irrational.

## 11) Additional Observations

### 11.1 Dust Accumulation
Even when `ratio >= 1`, fractional losses occur on every epoch. However, analysis shows:
- With typical emission/TVL ratios, fractional part is negligible
- Example: 2M emission / 20M TVL → ratio = 1000, fraction = 0
- Dust only becomes significant when emission approaches threshold

### 11.2 Protocol Longevity Assumptions
This issue assumes:
1. Protocol runs unchanged for 13+ years
2. No governance upgrades to fix precision issue
3. Constant high TVL maintained throughout

These assumptions are unrealistic for DeFi protocols, which typically upgrade frequently.

### 11.3 User Behavior Context (Core-9)
Per directive: "用户是技术背景的普通用户，会严格遵守规则，但是会严格检查自己的操作和协议配置"

**Application**: Sophisticated users would notice when weekly rewards stop being distributed and could:
- Alert governance
- Trigger emergency pause
- Demand protocol upgrade

This provides a detection mechanism before significant damage accumulates.

---

## FINAL VERDICT

**Status**: FALSE POSITIVE as a "High Severity Vulnerability"

**Correct Classification**: INFORMATIONAL - Long-term protocol sustainability issue

**Summary**:
The reported precision truncation mechanism exists and will cause fund lock after ~13.5 years of operation (or sooner with very high TVL). However, this is NOT an exploitable vulnerability because:

1. ✗ **Not exploitable**: Requires 50-200x total supply to trigger deliberately (impossible)
2. ✗ **No economic incentive**: Attack has -100% ROI
3. ✗ **Not immediate**: Only manifests after 13+ years of natural decay
4. ✓ **Real technical issue**: Funds do become permanently locked when condition occurs
5. ✓ **Design flaw**: Should be fixed in future protocol upgrade

**Recommendation**: Track as a technical debt item for future protocol v2 upgrade, not as an active security vulnerability requiring immediate remediation.

