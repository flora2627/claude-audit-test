## 标题
`minter::calculate_rebase_gauge` 函数中错误的单位换算导致会计系统崩溃 🚨

## 分类
Loss / Invariant-Broken – Mis-measurement

## 位置
- `sources/minter.move`: `calculate_rebase_gauge` 函数 (L270-L309)

## 二级指标与影响
- **二级指标**: `rebase` 和 `gauge` emission 的分割比例。
- **核心断言**: `Invariant-Broken`。协议的核心会计不变量——即资产（铸造的代币）必须等于负债（承诺分配的奖励）——被彻底破坏。
- **影响门槛**: `Loss` / `DoS`。此缺陷导致 `voter` 和 `fee_distributor` 模块记下天量的虚假负债，远超实际铸造的资产，最终将导致所有奖励申领交易失败，使协议核心经济激励功能陷入永久性拒绝服务。

## 详细说明

### 触发条件 / 调用栈
1.  每周时间窗口切换时，任何用户调用 `voter::update_period()`。
2.  `voter` 模块调用 `friend` 函数 `minter::calculate_rebase_gauge()` 来获取当周的 `rebase` 和 `gauge` emission 分配额。

### 缺陷分析
`calculate_rebase_gauge` 函数在计算 `rebase` 比例时，存在一个灾难性的单位换算错误：

```283:291:sources/minter.move
let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
let dxlyn_supply = (dxlyn_coin::total_supply() as u256);

let rebase = if (ve_supply <= 0 || dxlyn_supply <= 0) {
    0
}else {
    // ...
    let diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply);
```
- **L283**: `ve_supply` 从 `voting_escrow` 获取，其精度为 `10^12`。
- **L284**: `dxlyn_supply` 从 `dxlyn_coin` 获取，其精度为 `10^8`。
- **L291**: 代码在未进行任何精度调整的情况下，直接将 `ve_supply` 除以 `dxlyn_supply`。

**漏洞核心**:
由于精度差异，`ve_supply / dxlyn_supply` 的计算结果会比实际的 "锁仓率" 大 `10^4` 倍。
- **示例**: 假设 veDXLYN 的总供应量是 DXLYN 总供应量的 1% (即 `ve_supply / dxlyn_supply` 的真实比率应为 0.01)。由于单位错误，计算结果将是 `0.01 * 10^4 = 100`。
- **整数下溢**: `diff_scaled` 的计算 `AMOUNT_SCALE - (ve_supply / dxlyn_supply)` (即 `10000 - 100 * 10000` in ratio) 会变成一个巨大的负数，由于 `u256` 的下溢，它会 wrap around 变成一个接近 `MAX_U256` 的极大正数。
- **天量 `rebase`**: 随后的 `factor` 和 `rebase` 计算 (L294, L297) 会滚雪球般地产生一个天文数字。
- **天量 `gauge`**: `gauge = weekly_emission - rebase` (L300) 同样会因下溢而变成一个天文数字。
- **错误的返回值**: 函数最终将这两个不合逻辑的、巨大的 `rebase` 和 `gauge` 值返回给 `voter` 模块。

### 系统性崩溃
`voter` 模块接收到这两个值后，会：
1.  将天量的 `gauge` 值用于更新其内部的奖励 `index`，从而凭空创造出巨额的负债。
2.  调用 `fee_distributor::burn_rebase`，虽然实际转账的代币数量受限于 `minter` 实际铸造的 `weekly_emission`，但 `fee_distributor` 的内部会计同样会被错误的 `rebase` 值污染。

最终，`voter` 和 `fee_distributor` 两个核心分账模块的负债（对用户的奖励承诺）将远远超过它们实际拥有的资产。当用户尝试 `claim` 或 `get_reward` 时，交易将因资产不足而失败，导致整个代币经济激励系统瘫痪。

### 证据 (P1-P3)
-   **交易序列 (P1)**:
    1.  `voter::update_period()` 被调用。
    2.  `minter::calculate_rebase_gauge()` 返回 `rebase` 和 `gauge` 的天量数值。
    3.  `voter` 内部 `index` 被错误更新，`fee_distributor` 的会计被污染。
    4.  后续所有 `fee_distributor::claim` 和 `gauge::get_reward` 调用都将失败。

-   **变量前后 (P2)**:
    *   `ve_supply / dxlyn_supply`: `~0.01 * 10^12` / `~1 * 10^8` → `~100` (应为 `~0.01`)
    *   `rebase`: `~weekly_emission * 0.3` → `MAX_U64`
    *   `gauge`: `~weekly_emission * 0.7` → `MAX_U64`
    *   `voter.index`: `N` → `N + (MAX_U64 / total_weight)` (剧增)

-   **影响量化 (P3)**:
    *   **DoS**: 整个 rebase 和 gauge 奖励分发系统将永久性瘫痪。
    *   **Loss**: 虽然没有直接的代币被盗，但所有应发放给 veNFT 持有者和流动性提供者的奖励都将无法领取，构成事实上的 100% 资金损失。

## 根因标签
-   `Mis-measurement`
-   `Invariant-Broken`
-   `Systemic Failure`

## 状态
Confirmed

---

# AUDIT ADJUDICATION REPORT

## Executive Verdict: **FALSE POSITIVE**

The reported unit conversion error does not exist. The code correctly implements the rebase formula by intentionally accounting for the 10^4 scaling factor present in voting power calculations. No underflow occurs, and the accounting system functions as designed.

---

## Reporter's Claim Summary

The reporter claims:
1. `ve_supply` has precision 10^12 while `dxlyn_supply` has precision 10^8
2. Direct division without adjustment causes the ratio to be 10^4 times larger than intended
3. This causes integer underflow in `diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply)`
4. Astronomical rebase/gauge values result, breaking the accounting system

---

## Code-Level Disproof

### Claim 1: ve_supply precision is 10^12 (FALSE)

**File: sources/voting_escrow.move:1454-1455**

```move
u_new.slope = (new_locked.amount * AMOUNT_SCALE) / MAXTIME;
u_new.bias = u_new.slope * (new_locked.end - current_time);
```

Where:
- `AMOUNT_SCALE = 10000` (10^4) - voting_escrow.move:52
- `MAXTIME = 126144000` (4 years) - voting_escrow.move:46

For maximum lock duration (4 years):
```
voting_power = (locked_amount * 10^4 / MAXTIME) * MAXTIME = locked_amount * 10^4
```

**Verification**: If 1 DXLYN (10^8 base units) is locked for 4 years:
- voting_power = 10^8 * 10^4 = 10^12

**Key Finding**: The voting power is scaled by 10^4, NOT 10^12. The comment "in 10^12 units" (voting_escrow.move:1047) is misleading and refers to an internal precision constant `MULTIPLIER` used for block interpolation (line 1499), not the actual voting power magnitude.

### Claim 2: Ratio is 10^4 times larger (TRUE but INTENTIONAL)

**File: sources/minter.move:283-291**

```move
let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
// ...
let diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply);
```

The ratio `ve_supply / dxlyn_supply` is indeed scaled by 10^4 because:
- `ve_supply = locked_amount * 10^4 * (remaining_time / MAXTIME)`
- `dxlyn_supply = total_supply * 10^8`

For 100% locked at max time:
```
ratio = (total_supply * 10^4) / (total_supply) = 10^4 = 10000
```

**Critical Insight**: This 10^4 scaling is INTENTIONAL and correctly handled by `AMOUNT_SCALE = 10000` in line 291.

### Claim 3: Integer underflow occurs (FALSE)

**Mathematical Proof**:

Maximum possible ratio:
```
ratio_max = ve_supply_max / dxlyn_supply
         = (dxlyn_supply * 10^4 * 1) / dxlyn_supply  [max lock time factor = 1]
         = 10^4 = 10000
```

Therefore:
```
diff_scaled_min = AMOUNT_SCALE - ratio_max = 10000 - 10000 = 0
```

**Conclusion**: `diff_scaled` is bounded by [0, 10000]. No underflow is mathematically possible.

### Claim 4: Formula produces astronomical values (FALSE)

**Verification with Concrete Example**:

Scenario:
- Total supply: 100,000,000 DXLYN = 10^16 base units
- Locked: 10,000,000 DXLYN (10%) for 4 years = 10^15 base units
- Weekly emission: 1,000,000 DXLYN = 10^14 base units

Calculation trace:
1. `ve_supply = 10^15 * 10^4 = 10^19`
2. `ratio = 10^19 / 10^16 = 1000`
3. `diff_scaled = 10000 - 1000 = 9000`
4. `factor = (9000^2 * 5000) / 10000 = 40,500,000`
5. `rebase = (10^14 * 40,500,000) / 10^8 = 4.05 * 10^13`

Converting to DXLYN tokens: `4.05 * 10^13 / 10^8 = 405,000 DXLYN`

**Expected by formula**: `rebase = weekly * (1 - 0.1)^2 * 0.5 = 1,000,000 * 0.81 * 0.5 = 405,000 DXLYN`

**Result**: ✅ EXACT MATCH - The calculation is correct!

---

## Call Chain Trace

### Primary Call Path

**voter.move::update_period() → minter.move::calculate_rebase_gauge()**

| Step | Caller | Callee | msg.sender Context | Function | Call Type | Value Transfer |
|------|--------|--------|-------------------|----------|-----------|----------------|
| 1 | EOA/User | voter::update_period() | User address | Entry function | direct | None |
| 2 | voter module | minter::calculate_rebase_gauge() | @dexlyn_tokenomics | Friend function | direct | None |
| 3 | minter module | voting_escrow::total_supply() | @dexlyn_tokenomics | Public view | direct | None |
| 4 | minter module | dxlyn_coin::total_supply() | @dexlyn_tokenomics | Public view | direct | None |
| 5 | minter module | emission::weekly_emission() | @dexlyn_tokenomics | Friend function | direct | None |
| 6 | minter module | dxlyn_coin::mint() | @dexlyn_tokenomics (via object signer) | Public function | direct | Mints weekly_emission |

**Reentrancy Analysis**: No external calls that could trigger reentrancy. All functions are synchronous module calls.

---

## State Scope Analysis

### Key Variables and Storage

| Variable | Storage Scope | Type | Location | Access Pattern |
|----------|---------------|------|----------|----------------|
| `ve_supply` | memory/computation | u256 | minter.move:283 | Computed from global voting_escrow state |
| `dxlyn_supply` | memory/computation | u256 | minter.move:284 | Read from global coin supply |
| `diff_scaled` | memory | u256 | minter.move:291 | Local computation |
| `rebase` | return value | u64 | minter.move:297 | Returned to voter module |
| `gauge` | return value | u64 | minter.move:300 | Returned to voter module |

### State Dependencies

**voting_escrow::total_supply()** reads:
- `VotingEscrow.point_history[epoch]` (global storage at @dexlyn_tokenomics)
- Checkpoint data: `bias`, `slope`, `ts`, `blk`

**dxlyn_coin::total_supply()** reads:
- `coin::supply<DXLYN>()` (global coin supply tracking)

**No storage slots are manipulated via assembly**. All state access uses standard Move storage operations.

---

## Exploit Feasibility Assessment

### Prerequisites for Claimed Attack
1. ❌ Lock rate > 1% (routine protocol operation, not an attack)
2. ❌ Call `voter::update_period()` (permissionless but intended functionality)
3. ❌ Integer underflow condition (mathematically impossible as proven)

### Attacker Capabilities Required
- **Privilege Level**: None (permissionless entry function)
- **Capital Required**: None (monitoring/calling update_period is free)
- **Governance Control**: None
- **Oracle Manipulation**: None
- **Social Engineering**: None

### Can a Normal EOA Execute This?
✅ Yes, any EOA can call `voter::update_period()`, but this is **intended functionality**, not an exploit vector.

### Actual Outcome
When an EOA calls `update_period()`:
1. `calculate_rebase_gauge()` returns mathematically correct values
2. `rebase` and `gauge` are properly bounded
3. Voter indices update correctly
4. Fee distributor accounting remains consistent
5. Users can claim rewards successfully

**Conclusion**: No exploit path exists. The reported "catastrophic unit conversion error" is actually correct, intentional scaling.

---

## Economic Analysis

### Reporter's Impact Claims
- **Claimed**: Astronomical rebase/gauge values causing DoS
- **Claimed**: 100% loss of rewards due to insolvency
- **Claimed**: Permanent system collapse

### Actual Economic Impact: **ZERO**

**Calculation Verification (Multiple Scenarios)**:

| Lock Rate | Lock Duration | Ratio | diff_scaled | Rebase % | Status |
|-----------|---------------|-------|-------------|----------|--------|
| 1% | 4 years | 100 | 9900 | 49.01% | ✅ Valid |
| 10% | 4 years | 1000 | 9000 | 40.5% | ✅ Valid |
| 50% | 4 years | 5000 | 5000 | 12.5% | ✅ Valid |
| 100% | 4 years | 10000 | 0 | 0% | ✅ Valid |
| 10% | 2 years | 500 | 9500 | 45.13% | ✅ Valid |

**Invariant Check**: `rebase + gauge = weekly_emission` ✅

All scenarios produce valid, bounded results with:
- `0 <= rebase <= weekly_emission`
- `0 <= gauge <= weekly_emission`
- `rebase + gauge = weekly_emission`

### Attacker ROI/EV
**Input**: Gas cost to call `update_period()` (~0.001 DXLYN equivalent)
**Output**: No exploitable condition exists
**ROI**: N/A (not exploitable)

### Sensitivity Analysis
Even under extreme conditions (99.99% locked for max time):
- `ratio = 9999`
- `diff_scaled = 1`
- `factor = (1^2 * 5000) / 10000 = 0.5`
- `rebase ≈ weekly_emission * 0.5 / 10^8` (negligible)
- `gauge ≈ weekly_emission`

Result: System functions correctly, directing nearly all emissions to gauges (economically sensible for high lock rates).

---

## Dependency/Library Reading

### voting_escrow Module Dependencies

**AMOUNT_SCALE Usage** (voting_escrow.move:52):
```move
const AMOUNT_SCALE: u64 = 10000;
```

Applied at voting_escrow.move:1448, 1454:
```move
u_old.slope = (old_locked.amount * AMOUNT_SCALE) / MAXTIME;
u_new.slope = (new_locked.amount * AMOUNT_SCALE) / MAXTIME;
```

**Purpose**: Preserve precision in integer division by scaling locked amounts by 10^4 before dividing by MAXTIME.

### minter Module Dependencies

**AMOUNT_SCALE Usage** (minter.move:32):
```move
const AMOUNT_SCALE: u256 = 10000;
```

Applied at minter.move:291:
```move
let diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply);
```

**Purpose**: Match the 10^4 scaling from voting_escrow to correctly compute the lock rate ratio.

**DXLYN_DECIMAL** (minter.move:35):
```move
const DXLYN_DECIMAL: u64 = 100_000_000; // 10^8
```

Applied at minter.move:297:
```move
rebase = ((((weekly_emission as u256) * factor) / (DXLYN_DECIMAL as u256)) as u64)
```

**Purpose**: Normalize the factor (which is scaled by 10^8) back to base units.

### Mathematical Verification

**Intended Formula** (from comment at minter.move:289):
```
rebase = weeklyEmissions * (1 - (veDXLYN.totalSupply / DXLYN.totalSupply))^2 * 0.5
```

**Actual Implementation**:
```
lock_rate = ve_supply / dxlyn_supply / 10^4           [scaled ratio]
diff_scaled = 10000 - (ve_supply / dxlyn_supply)     [= (1 - lock_rate) * 10^4]
factor = (diff_scaled^2 * 5000) / 10000              [= (1 - lock_rate)^2 * 0.5 * 10^8]
rebase = (weekly_emission * factor) / 10^8           [= weekly * (1 - lock_rate)^2 * 0.5]
```

**Algebraic Proof**:
```
Let R = lock_rate (0 to 1)
ve_supply / dxlyn_supply = R * 10^4
diff_scaled = 10000 - R * 10000 = 10000(1 - R)
factor = [10000(1 - R)]^2 * 5000 / 10000
       = 10^8 * (1 - R)^2 * 5000 / 10000
       = 10^8 * (1 - R)^2 * 0.5
rebase = weekly * 10^8 * (1 - R)^2 * 0.5 / 10^8
       = weekly * (1 - R)^2 * 0.5 ✅
```

---

## Final Feature-vs-Bug Assessment

### Is This Intended Behavior? **YES**

**Evidence**:
1. **Consistent Scaling**: Both modules use `AMOUNT_SCALE = 10000`
2. **Comment Alignment**: The comment "(1 - veDXLYN/DXLYN), scaled by 10^4" (minter.move:290) explicitly acknowledges the scaling
3. **Mathematical Correctness**: The formula produces exactly the intended result
4. **Boundary Handling**: Edge cases (0% locked, 100% locked) behave correctly
5. **Design Pattern**: The ve(3,3) tokenomics model requires precise calculation of lock-weighted ratios, which necessitates this scaling approach

### Root Cause of Confusion

The **misleading documentation comment** at voting_escrow.move:1047 states "Total voting power in 10^12 units" when the actual scaling is 10^4. This is likely a documentation error where the author confused:
- `MULTIPLIER = 10^12` (used for block interpolation precision)
- `AMOUNT_SCALE = 10^4` (used for voting power scaling)

However, this documentation inconsistency does NOT cause any code-level bug. The implementation is mathematically sound.

---

## Conclusion

**Classification**: FALSE POSITIVE - No Fix Required

**Rationale**:
1. The claimed "unit conversion error" is intentional and correct scaling
2. No integer underflow is possible (mathematically bounded)
3. All calculations produce expected results per the rebase formula
4. No economic risk or DoS condition exists
5. System accounting remains consistent under all scenarios

**Recommendation**: Update documentation at voting_escrow.move:1047 to clarify that voting power is scaled by 10^4 (AMOUNT_SCALE), not 10^12, to prevent future confusion. The code itself requires no changes.
