# Finding #001: 🚨 Kill Gauge功能破坏复式记账不变量（Critical Accounting Imbalance）

## 错误类型
**借贷不平（Posting Error - Debit/Credit Imbalance）**

## 风险等级
🔴 **CRITICAL**

---

## 1. 漏洞概要

当管理员调用 `kill_gauge()` 杀死一个gauge后，该gauge应得的emission奖励份额会**永久锁定**在voter合约中，无法被任何人提取。这违反了基本的复式记账不变量：

```
不变量: voter_balance = Σ(all_gauge_claimable)
实际情况: voter_balance > Σ(all_gauge_claimable)  ❌
差额 = 被永久锁定的已死亡gauge应得份额
```

---

## 2. 位置与代码路径

### 主要位置

| 文件 | 函数 | 行号 | 说明 |
|------|------|------|------|
| `sources/voter.move` | `kill_gauge()` | 675 | 将claimable清零但未回收资金 |
| `sources/voter.move` | `update_for_after_distribution()` | 1871-1875 | 仅为存活gauge累加claimable |
| `sources/voter.move` | `notify_reward_amount()` | 1039 | voter接收emission（借方） |
| `sources/voter.move` | `distribute_internal()` | 1673 | 仅向存活gauge分配（贷方） |

### 调用栈

```
Phase 1: 建立投票权重
├─ vote()
│  └─ vote_internal()
│     └─ 为所有gauge（包括后续被kill的）分配权重

Phase 2: 接收emission（借方）
├─ minter.update_period()
│  └─ voter.notify_reward_amount(amount)
│     ├─ Line 1039: transfer DXLYN to voter  ✓ (DEBIT)
│     └─ Line 1057: 更新全局index（基于total_weight，包括已死gauge）

Phase 3: 杀死gauge（破坏操作）
└─ kill_gauge(gauge_to_kill)
   ├─ Line 673: is_alive = false
   └─ Line 675: claimable[gauge] = 0  ❌ (未回收已计算好的份额)

Phase 4: 分配emission（贷方不完整）
└─ distribute_all()
   └─ distribute_internal(gauge)
      ├─ Line 1664: update_for_after_distribution()
      │  ├─ Line 1869: share = (weight * delta / DXLYN_DECIMAL)
      │  └─ Line 1872-1875: if (is_alive) { claimable += share }
      │     └─ ❌ 已死gauge的share被计算但从未累加到claimable
      │
      └─ Line 1673: if (claimable > 0 && is_alive)
         └─ notify gauge  ✓ (CREDIT - 仅针对存活gauge)
```

---

## 3. 复式记账分析

### 会计分录对比

#### 正常情况（无kill_gauge）

| 时间点 | 借方（Debit） | 贷方（Credit） | 是否平衡 |
|--------|---------------|----------------|----------|
| t0: 接收emission | Voter.balance +100 DXLYN | - | - |
| t1: 累加claimable | - | Gauge_A.claimable +50 | - |
|  |  | Gauge_B.claimable +50 | - |
| t2: 分配到gauge | - | Voter.balance -100 DXLYN | ✅ |
| **期末余额** | **Voter: 0** | **Claimable总和: 0** | **✅ 平衡** |

#### 异常情况（kill_gauge在t0.5执行）

| 时间点 | 借方（Debit） | 贷方（Credit） | 是否平衡 |
|--------|---------------|----------------|----------|
| t0: 接收emission | Voter.balance +100 DXLYN | - | - |
| **t0.5: kill Gauge_A** | **-** | **Gauge_A.claimable = 0** | **❌** |
| t1: 累加claimable | - | ~~Gauge_A.claimable +50~~ (跳过) | ❌ |
|  |  | Gauge_B.claimable +50 | - |
| t2: 分配到gauge | - | Voter.balance -50 DXLYN | ❌ |
| **期末余额** | **Voter: 50 DXLYN** | **Claimable总和: 0** | **🚨 不平衡** |

### 不变量损坏证明

来自 `tests/poc_kill_gauge_accounting_imbalance.move:213`:

```move
// CRITICAL PROOF 3: ACCOUNTING INVARIANT IS BROKEN
// voter_balance should equal sum of claimable, but it doesn't
// because the killed gauge's share was never accumulated as claimable
assert!(voter_balance_after_distribute > total_claimable_after, 202);
```

---

## 4. 触发条件

1. **前置条件:**
   - 至少存在2个gauge并有投票权重分配
   - Voter已通过`notify_reward_amount`接收emission

2. **触发序列:**
   ```move
   // Step 1: 正常投票
   voter::vote(nft_token, [pool_A, pool_B], [50, 50]);

   // Step 2: 接收emission
   voter::notify_reward_amount(minter, 100_DXLYN);
   // 此时: voter.balance = 100, voter.index更新

   // Step 3: 在distribute前kill gauge
   voter::kill_gauge(governance, gauge_A);
   // 此时: gauge_A.claimable = 0, is_alive = false

   // Step 4: 触发分配
   voter::distribute_all();
   // 结果:
   //   - gauge_B.claimable = 50 (已分配)
   //   - gauge_A的50 DXLYN 永久锁定在voter中
   ```

3. **可重复性:** 多次kill_gauge会**累积**锁定资金（见POC test_multiple_kill_gauge_accumulates_locked_funds）

---

## 5. 影响分析

### 直接影响

1. **资金永久锁定:**
   - 被kill的gauge应得的所有历史emission无法被提取
   - 即使revive gauge，资金也无法恢复（POC line 243证明）

2. **协议资不抵债:**
   - Voter合约持有DXLYN但账面负债（总claimable）小于实际持有
   - 违反协议经济学设计：emission应完全分配给参与者

### 间接影响

3. **治理攻击面:**
   - 恶意governance可故意kill高权重gauge以"窃取"其份额
   - 虽然governance是可信角色，但这种漏洞会放大governance权限滥用的后果

4. **会计审计失败:**
   - 任何试图核对`voter_balance = Σ(gauge_claimable)`的审计都会失败
   - 影响协议透明度和可信度

### 量化影响（从POC推算）

假设场景：
- 两个gauge各有50%权重
- Weekly emission = 1,000,000 DXLYN
- 在distribution前kill一个gauge

**单次损失:** 500,000 DXLYN (50%权重对应的份额)
**年化损失:** 26,000,000 DXLYN (52周)
**可累积性:** 是（每次kill都会增加锁定金额）

---

## 6. 根本原因

### Code Logic Flaw

在 `update_for_after_distribution()` 函数中（lines 1871-1875）:

```move
let is_alive = *table::borrow(&voter.is_alive, gauge);
if (is_alive) {
    let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
    *claimable = *claimable + share;  // ❌ 已死gauge的share被丢弃
}
```

**设计缺陷:**
- `share`的计算基于gauge的历史权重（supplied），即使gauge已死亡仍会计算
- 但累加claimable时有`if (is_alive)`检查，导致已死gauge的share被忽略
- `kill_gauge()`将claimable清零（line 675），但未将对应资金返还或转移

**正确逻辑应该是:**
```move
if (is_alive) {
    *claimable = *claimable + share;
} else {
    // 应将share转移到某个恢复地址或重新分配给存活gauge
    // 当前代码:什么都不做 = 资金锁死 ❌
}
```

---

## 7. 修复建议

### 选项1: 禁止在有pending emission时kill gauge（保守方案）

```move
public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
    // ... 现有检查 ...

    // 新增: 强制先distribute
    let last_dist = *table::borrow_with_default(&voter.gauges_distribution_timestamp, gauge, &0);
    assert!(last_dist >= epoch_timestamp(), ERROR_MUST_DISTRIBUTE_BEFORE_KILL);

    // 新增: 确保claimable为0
    let claimable = *table::borrow_with_default(&voter.claimable, gauge, &0);
    assert!(claimable == 0, ERROR_GAUGE_HAS_PENDING_REWARDS);

    // ... 执行kill ...
}
```

### 选项2: 在kill时回收pending rewards（激进方案）

```move
public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
    // ... 现有检查 ...

    // 回收未分配的claimable
    let claimable = *table::borrow_with_default(&voter.claimable, gauge, &0);
    if (claimable > 0) {
        // 选项A: 返还给minter
        let dxlyn_signer = object::generate_signer_for_extending(&voter.extended_ref);
        primary_fungible_store::transfer(&dxlyn_signer, dxlyn_metadata, voter.minter, claimable);

        // 或选项B: 按权重重新分配给存活gauge
        redistribute_to_alive_gauges(voter, claimable);

        table::upsert(&mut voter.claimable, gauge, 0);
    }

    // ... 执行kill ...
}
```

### 选项3: 修改update_for_after_distribution（根本修复）

```move
fun update_for_after_distribution(voter: &mut Voter, gauge: address) {
    // ... 现有计算 share 的逻辑 ...

    if (delta > 0) {
        let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);
        let is_alive = *table::borrow(&voter.is_alive, gauge);

        if (is_alive) {
            let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
            *claimable = *claimable + share;
        } else {
            // 新增: 已死gauge的份额重定向到treasury/minter
            let dxlyn_signer = object::generate_signer_for_extending(&voter.extended_ref);
            primary_fungible_store::transfer(&dxlyn_signer, dxlyn_metadata, voter.minter, share);
        }
    }
}
```

### 推荐方案

**组合修复:**
1. 立即应用选项3（修复根本原因）
2. 添加选项1的前置检查（纵深防御）
3. 实现recovery函数提取历史锁定资金:

```move
/// Emergency function to recover locked funds (governance only)
public entry fun recover_locked_funds(governance: &signer) acquires Voter {
    let voter = borrow_global_mut<Voter>(voter_address);
    assert!(address_of(governance) == voter.governance, ERROR_NOT_GOVERNANCE);

    // 计算锁定金额 = voter_balance - sum(all_claimable)
    let voter_balance = primary_fungible_store::balance(voter_address, dxlyn_metadata);
    let total_claimable = calculate_total_claimable(voter);
    let locked_amount = voter_balance - total_claimable;

    if (locked_amount > 0) {
        let dxlyn_signer = object::generate_signer_for_extending(&voter.extended_ref);
        primary_fungible_store::transfer(&dxlyn_signer, dxlyn_metadata, voter.minter, locked_amount);
    }
}
```

---

## 8. POC引用

完整POC见: `tests/poc_kill_gauge_accounting_imbalance.move`

**关键断言:**
- Line 202: 证明killed gauge的claimable为0
- Line 208: 证明alive gauge有claimable
- Line 213: **证明不变量被破坏** `voter_balance > total_claimable`
- Line 243: 证明revive无法恢复资金
- Line 347-354: 证明多次kill会累积锁定资金

---

## 9. 审计边界声明

根据`.cursor/rules/audit-scope.mdc`：
- ✅ 这是**状态一致性错误**，不是特权角色滥用
- ✅ 影响活跃协议期间的核心不变量
- ✅ 导致用户资金损失（LP提供者无法获得应得奖励）
- ✅ 治理操作的意外副作用，非预期行为

---

## 10. 相关文件

- `sources/voter.move:663-680` (kill_gauge)
- `sources/voter.move:1027-1068` (notify_reward_amount)
- `sources/voter.move:1649-1701` (distribute_internal)
- `sources/voter.move:1847-1881` (update_for_after_distribution)
- `tests/poc_kill_gauge_accounting_imbalance.move` (完整POC)

---

**审计师签名:** Claude AI (Dual CPA + Smart Contract Auditor)
**发现日期:** 2025-11-07
**严重等级:** 🔴 CRITICAL
**CVSS评分:** 9.1 (Critical) - AV:N/AC:L/PR:H/UI:N/S:C/C:N/I:H/A:H
