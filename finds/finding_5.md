## 标题
`voter::kill_gauge` 后 claimable 清零但 DXLYN 留在合约，导致借贷不平

## 类型
交易层面 / 借贷不平

## 风险等级
中

## 位置
`sources/voter.move` 中 `kill_gauge` 函数，约第 677 行

## 发现依据
- kill_gauge 函数直接将 claimable[gauge] 清零，但不减少 voter 合约的 DXLYN 余额
- 这导致 voter 合约资产 > 负债总和，破坏资产=负债恒等式
- 被杀死的 gauge 的 DXLYN 奖励永久留在 voter 合约，无法分配

```675:679:sources/voter.move
*is_alive = false;

table::upsert(&mut voter.claimable, gauge, 0);
```

## 影响
- 破坏 voter 模块的核心会计恒等式：`voter合约DXLYN余额 ≈ sum(claimable[gauge])`
- 每次 kill_gauge 都会累积无法分配的 DXLYN 在 voter 合约
- 影响协议的经济模型完整性

## 触发条件 / 调用栈
- admin 调用 voter::kill_gauge 时
- gauge 被标记为死亡后

## 建议修复
在 kill_gauge 时将 claimable 金额转回 minter 或 treasury：

```move
let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
if (claimable_amount > 0) {
    // 转回 minter 或 treasury
    // 或者累积到特殊账户供后续处理
}
```

## 置信度
90%

---

# 验证报告 (Validation Report)

## 1. Executive Verdict

**结论**: **Valid** (有效漏洞)

**理由**: 在完全正常的治理操作下,`kill_gauge` 会导致 voter 合约的会计不变量被破坏,使已分配的 emission 永久锁定在合约中,无回收机制。虽然这是特权操作,但破坏了核心会计恒等式,且累积效应明显。

---

## 2. Reporter's Claim Summary

报告声称:
1. `voter::kill_gauge` 函数将 `claimable[gauge]` 清零,但不减少 voter 合约的 DXLYN 余额
2. 导致 voter 合约资产 > 负债总和,破坏资产=负债恒等式
3. 被杀死的 gauge 的 DXLYN 奖励永久留在 voter 合约,无法分配

---

## 3. Code-Level Proof (代码层面验证)

### 3.1 核心代码确认

**kill_gauge 函数** (`sources/voter.move:665-688`):

```665:688:sources/voter.move
public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
    let voter_address = get_voter_address();
    let voter = borrow_global_mut<Voter>(voter_address);

    let governance_address = address_of(governance);
    assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

    assert!(table::contains(&voter.is_alive, gauge), ERROR_GAUGE_NOT_EXIST);
    let is_alive = table::borrow_mut(&mut voter.is_alive, gauge);
    assert!(*is_alive, ERROR_GAUGE_ALREADY_KILLED);
    *is_alive = false;

    table::upsert(&mut voter.claimable, gauge, 0);  // ← 关键:清零 claimable

    let time = epoch_timestamp();
    let pool = table::borrow(&voter.pool_for_gauge, gauge);
    let weights_per_epoch =
        weights_per_epoch_internal(&voter.weights_per_epoch, time, *pool);

    let total_weights_per_epoch = table::borrow_mut_with_default(&mut voter.total_weights_per_epoch, time, 0);
    *total_weights_per_epoch = *total_weights_per_epoch - weights_per_epoch;

    event::emit(GaugeKilledEvent { gauge })
}
```

**关键发现**:
- **L677**: `table::upsert(&mut voter.claimable, gauge, 0);` 直接将 claimable 清零
- **无资产转移**: 函数内没有任何 DXLYN 转账代码
- **L682**: 仅减少 `total_weights_per_epoch`,不影响 voter 合约的 DXLYN 余额

### 3.2 claimable 的会计含义

**Voter 结构体** (`sources/voter.move:275-305`):

```275:305:sources/voter.move
struct Voter has key {
    owner: address,
    voter_admin: address,
    governance: address,
    minter: address,
    // all pools viable for incentives
    pools: smart_vector::SmartVector<address>,
    // gauge index
    index: u64,
    // delay between votes in seconds
    vote_delay: u64,
    // gauge    => index
    supply_index: Table<address, u64>,
    // gauge    => claimable DXLYN  ← 负债账本
    claimable: Table<address, u64>,
```

**会计分析**:
- `claimable[gauge]` 代表 gauge 应得的 DXLYN emission (负债)
- voter 合约持有的 DXLYN 是资产
- **核心恒等式**: `voter合约DXLYN余额 ≈ sum(claimable[gauge] for all gauges)`

### 3.3 claimable 的资金来源

**notify_reward_amount** (`sources/voter.move:1029-1070`):

```1041:1059:sources/voter.move
//transfer dexlyn coins
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);

// minter call notify after updates active_period, loads votes - 1 week
let epoch = epoch_timestamp() - WEEK;
if (table::contains(&voter.total_weights_per_epoch, epoch)) {
    let total_weight = *table::borrow(&voter.total_weights_per_epoch, epoch);
    let ratio = 0;

    if (total_weight > 0) {
        // 1e8 adjustment is removed during claim
        // scaled ratio is used to avoid overflow
        let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256)
            / (total_weight as u256);
        // convert scaled ratio to u64
        ratio = (scaled_ratio as u64);
    };

    if (ratio > 0) {
        voter.index = voter.index + ratio;  // ← 更新全局 index
    };
};
```

**资金流**:
1. L1041: minter 将 emission 转入 voter 合约 → voter 资产增加
2. L1059: voter.index 增加,代表每单位权重应得奖励增加
3. 后续通过 `update_for_after_distribution` 将 index 增量转为 claimable

**update_for_after_distribution** (`sources/voter.move:1849-1883`):

```1866:1877:sources/voter.move
// see if there is any difference that need to be accrued
let delta = index - supply_index;

if (delta > 0) {
    // add accrued difference for each supplied token
    // use u256 to avoid overflow in case of large numbers
    let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);

    let is_alive = *table::borrow(&voter.is_alive, gauge);
    if (is_alive) {  // ← 只有 alive 的 gauge 才累加 claimable
        let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
        *claimable = *claimable + share;
    }
}
```

**关键逻辑**:
- L1873: 检查 `is_alive` 标志
- L1875-1876: 只有 `is_alive == true` 时才累加 claimable
- **推论**: kill_gauge 后,该 gauge 不再累积新的 claimable,但已有的 claimable 在 L677 被清零

### 3.4 资金去向追踪

**distribute_internal** (`sources/voter.move:1651-1703`):

```1666:1695:sources/voter.move
update_for_after_distribution(voter, gauge);

let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
if (*claimable <= 0) {
    return
};

let is_alive = *table::borrow(&voter.is_alive, gauge);
// distribute only if claimable is > 0, currentEpoch != last epoch and gauge is alive
if (*claimable > 0 && is_alive) {  // ← 需要 is_alive == true
    // ...
    // type based gauge notify dxlyn emission reward to gauge
    if (gauge_type == CLMM_POOL) {
        gauge_clmm::notify_reward_amount(distribution, gauge, *claimable);
    } else if (gauge_type == CPMM_POOL) {
        gauge_cpmm::notify_reward_amount(distribution, gauge, *claimable);
    } else {
        gauge_perp::notify_reward_amount(distribution, gauge, *claimable);
    };

    *claimable = 0;
```

**分析**:
- L1675: 检查 `is_alive` 标志
- 如果 `is_alive == false` (被 kill),则不会执行 L1688-1693 的转账
- **结论**: killed gauge 的 claimable 永远不会被分配

### 3.5 回收机制检查

**revive_gauge** (`sources/voter.move:698-711`):

```698:711:sources/voter.move
public entry fun revive_gauge(governance: &signer, gauge: address) acquires Voter {
    let voter_address = get_voter_address();
    let voter = borrow_global_mut<Voter>(voter_address);

    let governance_address = address_of(governance);
    assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);
    assert!(table::contains(&voter.is_gauge, gauge), ERROR_GAUGE_NOT_EXIST);

    let is_alive = table::borrow_mut(&mut voter.is_alive, gauge);
    assert!(!*is_alive, ERROR_GAUGE_ALIVE);
    *is_alive = true;

    event::emit(GaugeKilledEvent { gauge })
}
```

**分析**:
- L708: 仅设置 `is_alive = true`
- **不恢复 claimable**: 没有恢复被清零的 claimable 的代码
- **结论**: 即使 revive,被清零的 claimable 也无法恢复

**全模块搜索结果**:
```bash
grep -n "treasury|withdraw_dxlyn|recover|sweep" sources/voter.move
864:                @fee_treasury,
```
- 只找到 `@fee_treasury` (用于接收罚款)
- **没有** 回收 voter 合约 DXLYN 的函数

---

## 4. Call Chain Trace (完整调用链)

### 场景: kill_gauge 导致 DXLYN 锁定

**前置状态**:
- gauge_A 累积了 1000 DXLYN 的 claimable (通过 notify_reward_amount → update_for_after_distribution)
- voter 合约 DXLYN 余额 = 5000
- sum(claimable[all gauges]) = 5000

**调用链**:

1. **governance 调用 kill_gauge**:
   ```
   Caller: governance (0x123...)
   Callee: voter::kill_gauge
   msg.sender: governance
   Function: kill_gauge(governance: &signer, gauge: 0xAAA)
   Call Type: entry function (direct call)
   ```

2. **L670: 权限检查**:
   ```move
   assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);
   ```
   - msg.sender: governance
   - 验证通过 ✅

3. **L677: 清零 claimable**:
   ```move
   table::upsert(&mut voter.claimable, gauge, 0);
   ```
   - **状态变更**:
     - `claimable[gauge_A]`: 1000 → 0
     - voter 合约 DXLYN 余额: 5000 → 5000 (不变)
     - sum(claimable[all gauges]): 5000 → 4000

4. **会计不变量破坏**:
   ```
   之前: voter余额(5000) == sum(claimable)(5000) ✅
   之后: voter余额(5000) != sum(claimable)(4000) ❌
   差额: 1000 DXLYN 无对应负债记录
   ```

**后续尝试 distribute**:

5. **任意用户调用 distribute_all**:
   ```
   Caller: user (0x456...)
   Callee: voter::distribute_all → distribute_internal(gauge_A)
   ```

6. **L1666: update_for_after_distribution**:
   - L1873: `is_alive = false`
   - L1874-1877: 跳过 claimable 累加 (因为 !is_alive)
   - claimable[gauge_A] 保持为 0

7. **L1675: 检查 is_alive**:
   ```move
   if (*claimable > 0 && is_alive) { ... }
   ```
   - claimable = 0 ✅
   - is_alive = false ✅
   - 条件不满足,提前返回 (L1670)

8. **结果**:
   - gauge_A 永远不会收到这 1000 DXLYN
   - 这 1000 DXLYN 永久留在 voter 合约

**reentrancy 风险**: ❌ 无 (kill_gauge 不涉及外部调用)

---

## 5. State Scope Analysis (状态作用域分析)

### 5.1 claimable 的存储作用域

**存储位置**: 
- Scope: `Voter` 资源的 `claimable: Table<address, u64>`
- Storage: 全局存储,位于 `@dexlyn_tokenomics` 账户
- Access: 仅 `voter.move` 模块内可修改

**映射键**: 
- Key Type: `address` (gauge 地址)
- Key Source: `pool_for_gauge` 反向映射获得

**写操作**:
1. `update_for_after_distribution` L1876: `*claimable = *claimable + share;`
2. `kill_gauge` L677: `table::upsert(&mut voter.claimable, gauge, 0);`
3. `distribute_internal` L1695: `*claimable = 0;`

**读操作**:
1. `distribute_internal` L1668: `let claimable = table::borrow_mut_with_default(...)`
2. 各种 view 函数

### 5.2 voter DXLYN 余额的作用域

**存储位置**:
- Scope: `@voter_address` 的 `PrimaryFungibleStore<DXLYN>`
- Storage: Aptos 内置的 fungible asset 账户
- Access: 通过 `primary_fungible_store` 模块

**修改操作**:
1. `notify_reward_amount` L1041: 
   - `primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);`
   - Caller: minter
   - Callee: voter_address
   - Value Transfer: ✅ amount DXLYN

2. `distribute_internal` L1688-1693:
   - `gauge_clmm::notify_reward_amount(distribution, gauge, *claimable);`
   - 内部会调用 `primary_fungible_store::transfer(voter, ..., gauge, claimable);`
   - Caller: voter
   - Callee: gauge
   - Value Transfer: ✅ claimable DXLYN

3. **kill_gauge**: 
   - ❌ 无任何资金转移
   - voter 余额保持不变

### 5.3 Assembly / Slot Manipulation

**检查结果**: ❌ 无
- Move 语言不支持 assembly
- 所有状态操作通过类型安全的 API

---

## 6. Exploit Feasibility (利用可行性)

### 6.1 前置条件

**攻击者需要**:
- ❌ governance 权限 (kill_gauge 需要 governance signer)

**判定**: **非普通攻击者可利用**

**但是**: 根据审计规则 `[Core-4]` 和特权角色模型:
> "仅当 Owner／多签／Timelock 在'完全正常、符合业务需求'的操作下仍会造成资产损失或会计失衡时,才认定为漏洞"

**分析**:
1. kill_gauge 的业务需求: 杀死恶意或有问题的 gauge
2. 完全正常的操作: governance 发现 gauge 有问题,调用 kill_gauge
3. 结果: 会计不变量被破坏,DXLYN 永久锁定
4. **这是协议设计缺陷,而非攻击利用**

### 6.2 特权操作的正当性

**场景1: 恶意 gauge 需要被 kill**:
- 假设 gauge_X 存在漏洞,允许用户无限提取奖励
- governance 紧急调用 kill_gauge(gauge_X)
- 结果: 
  - ✅ 阻止了 gauge_X 继续获得新 emission
  - ❌ gauge_X 已累积的 claimable (例如 10000 DXLYN) 被清零
  - ❌ 这 10000 DXLYN 永久留在 voter 合约,无法分配给其他 gauge

**场景2: 临时禁用 gauge**:
- governance 想临时禁用 gauge_Y,后续恢复
- 操作: kill_gauge(gauge_Y) → 等待一段时间 → revive_gauge(gauge_Y)
- 结果:
  - ✅ gauge_Y 被禁用
  - ❌ gauge_Y 在禁用期间累积的 claimable 被清零 (例如 5000 DXLYN)
  - ❌ revive 后 claimable 不会恢复
  - ❌ 5000 DXLYN 永久丢失

**结论**: 即使是完全正当的治理操作,也会导致资金锁定,这是协议缺陷。

---

## 7. Economic Analysis (经济影响分析)

### 7.1 单次 kill_gauge 的影响

**假设**:
- weekly_emission = 1,000,000 DXLYN
- gauge_A 权重占比 = 10%
- gauge_A 运行 4 周后被 kill
- gauge_A 累积的 claimable = 400,000 DXLYN (假设每周 100,000,累积未 distribute)

**锁定资金**:
- 直接锁定: 400,000 DXLYN
- 占当周 emission: 40%
- 占年化 emission: ~0.77% (假设年 emission 5200万)

### 7.2 累积效应

**假设协议运行 1 年**:
- kill_gauge 操作次数: 5 次 (平均每 2.4 个月一次)
- 平均每次锁定: 200,000 DXLYN
- 总锁定: 1,000,000 DXLYN
- 占年化 emission: ~1.92%

**敏感性分析**:
- 如果 kill_gauge 频率更高 (例如每月 1 次): 总锁定 ~2,400,000 DXLYN (4.6%)
- 如果 claimable 累积更多 (例如季度 distribute): 单次锁定可达 1,300,000 DXLYN

### 7.3 对协议的影响

**直接影响**:
1. **emission 效率降低**: 锁定的 DXLYN 无法激励流动性
2. **会计不透明**: 链上数据显示 voter 余额 > sum(claimable),审计困难
3. **潜在信任危机**: 社区可能质疑协议的资金管理

**间接影响**:
1. **gauge 分配不公**: 被 kill 的 gauge 本应得的 emission 无法重新分配给其他 gauge
2. **LP 质押者受损**: 如果 gauge 在累积大量 claimable 后被 kill,LP 质押者损失奖励
3. **治理困境**: governance 需要在"及时 kill 恶意 gauge"和"减少资金锁定"之间权衡

### 7.4 ROI / EV 计算

**对于攻击者**: N/A (需要 governance 权限,无法利用)

**对于协议**:
- 预期损失 (Expected Loss): 年化 1-5% emission 锁定
- 损失现值 (PV): 假设 DXLYN = $0.1,年 emission 5200万
  - 年化损失 = 52万 ~ 260万 DXLYN = $5.2万 ~ $26万
  - 5年累积损失 PV (折现率 10%) ≈ $19.7万 ~ $98.6万

**对于用户**:
- LP 质押者: 如果所在 gauge 被 kill,损失未 claim 的奖励
- veNFT 持有者: 间接损失 (总 emission 效率降低)

---

## 8. Dependency/Library Reading Notes

### 8.1 primary_fungible_store

**相关代码**:
```move
use supra_framework::primary_fungible_store;

// 转账调用
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);
```

**源码验证** (SupraFramework):
- `transfer` 函数签名: `public fun transfer<T: key>(sender: &signer, metadata: Object<Metadata>, to: address, amount: u64)`
- 功能: 从 sender 的 primary store 转账到 to 的 primary store
- **关键**: 需要 sender 的 signer,无法伪造

**在 kill_gauge 中的应用**:
- ❌ kill_gauge 函数内没有调用 `primary_fungible_store::transfer`
- **结论**: 确认无资金转移

### 8.2 table (Aptos Stdlib)

**相关代码**:
```move
use aptos_std::table::{Self, Table};

table::upsert(&mut voter.claimable, gauge, 0);
```

**源码验证**:
- `upsert` 函数签名: `public fun upsert<K, V>(table: &mut Table<K, V>, key: K, value: V)`
- 功能: 如果 key 存在则更新,否则插入
- **关键**: 直接修改 table 存储,不涉及资金

**在 kill_gauge 中的应用**:
- L677: 将 `claimable[gauge]` 设为 0
- **纯状态操作**: 不触发任何 transfer

---

## 9. Final Feature-vs-Bug Assessment (特性 vs Bug 判定)

### 9.1 是否是设计意图?

**支持"是特性"的证据**:
- ❌ 无文档说明这是预期行为
- ❌ 无 treasury 函数可以回收这些 DXLYN
- ❌ revive_gauge 不恢复 claimable,暗示不是"临时禁用"的设计

**支持"是缺陷"的证据**:
- ✅ 破坏核心会计恒等式: `voter余额 ≈ sum(claimable)`
- ✅ 累积效应明显: 多次 kill 会锁定大量 emission
- ✅ 无回收机制: 这些 DXLYN 永久无法使用
- ✅ 与协议目标矛盾: emission 应该激励流动性,而非锁定在合约

### 9.2 与其他模块的对比

**对比1: gauge 的 kill 机制**:
- gauge_cpmm/clmm/perp 没有 "kill" 函数
- gauge 通过 voter 的 `is_alive` 控制是否接收 emission
- **设计一致性**: 如果 gauge 不需要清零奖励,voter 也不应该

**对比2: vesting 的 admin_withdraw**:
- `vesting::admin_withdraw` 允许 admin 提取 DXLYN
- 但在 `account_ivar.md` L823-836 中被标记为 "🔴 漏洞1"
- **相似性**: 两者都是特权操作导致会计不平衡

### 9.3 最小化修复方案

**修复目标**: 在 kill_gauge 时,将 claimable 转到明确的目的地

**方案1: 转回 minter**:
```move
let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
if (claimable_amount > 0) {
    let dxlyn_metadata = address_to_object<Metadata>(voter.dxlyn_coin_address);
    let voter_signer = object::generate_signer_for_extending(&voter.extended_ref);
    primary_fungible_store::transfer(&voter_signer, dxlyn_metadata, voter.minter, claimable_amount);
}
table::upsert(&mut voter.claimable, gauge, 0);
```

**方案2: 转给 fee_distributor (作为额外 rebase)**:
```move
let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
if (claimable_amount > 0) {
    fee_distributor::add_recovered_funds(&voter_signer, claimable_amount);
}
table::upsert(&mut voter.claimable, gauge, 0);
```

**方案3: 转给 treasury**:
```move
// 需要在 Voter 结构体中添加 treasury 地址
let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
if (claimable_amount > 0) {
    let dxlyn_metadata = address_to_object<Metadata>(voter.dxlyn_coin_address);
    let voter_signer = object::generate_signer_for_extending(&voter.extended_ref);
    primary_fungible_store::transfer(&voter_signer, dxlyn_metadata, voter.treasury, claimable_amount);
}
table::upsert(&mut voter.claimable, gauge, 0);
```

**推荐**: 方案2 (转给 fee_distributor),因为:
- 逻辑最简洁: emission 本应部分用于 rebase
- 受益者合理: veNFT 持有者(治理参与者)补偿
- 无需新增状态: 不需要 treasury 地址

### 9.4 最终判定

**这是一个 BUG,而非 FEATURE**

**理由**:
1. **违反会计原则**: 资产 ≠ 负债,长期不可持续
2. **无设计文档**: 无证据表明这是有意为之
3. **有更优方案**: 可以通过简单修改保持会计平衡
4. **协议目标矛盾**: emission 应流向生态,而非锁定

---

## 10. Comparison with Audit Scope Rules

### 10.1 特权角色模型检查

**规则**:
> "仅当 Owner／多签／Timelock 在'完全正常、符合业务需求'的操作下仍会造成资产损失或会计失衡时,才认定为漏洞"

**本案例**:
- ✅ 是特权操作: 需要 governance 权限
- ✅ 是正常操作: kill 恶意 gauge 是合理的治理需求
- ✅ 造成会计失衡: voter 资产 > 负债
- ✅ 造成资金损失: claimable DXLYN 永久锁定

**结论**: 符合漏洞定义 ✅

### 10.2 设计特性排除

**规则**:
> "特权功能若属协议设计需求(如铸币、暂停、迁移),则视为特性而非漏洞"

**本案例**:
- ✅ kill_gauge 是协议设计需求
- ❌ 但"清零 claimable 且不转移资金"不是合理设计
- ❌ 无文档说明资金锁定是预期行为

**结论**: 不能排除为特性 ❌

### 10.3 会计不变量评估

**规则**:
> "状态限定: 任何不变量检查均需限定在其适用的状态机阶段"

**不变量**:
```
voter合约DXLYN余额 ≈ sum(claimable[gauge] for all gauges)
```

**状态机阶段**:
- 活跃期: 协议正常运行,接收 emission 并分配
- kill_gauge 后: 仍在活跃期 (不是迁移或终止)

**检查**:
- ✅ 不变量在活跃期应该成立
- ❌ kill_gauge 破坏了不变量
- ✅ 没有"设计性的不平衡"理由

**结论**: 违反核心不变量 ✅

---

## 11. 验证总结

### 11.1 报告准确性

| 报告声称 | 验证结果 | 准确性 |
|---------|---------|--------|
| claimable 被清零 | ✅ 确认 (L677) | 100% |
| voter 余额不减少 | ✅ 确认 (无转账代码) | 100% |
| 破坏资产=负债恒等式 | ✅ 确认 (数学证明) | 100% |
| DXLYN 永久锁定 | ✅ 确认 (无回收机制) | 100% |

**总体准确性**: 100% ✅

### 11.2 风险评级验证

**报告风险等级**: 中

**验证意见**:
- 严重性: 中 ✅
  - 单次影响: 可锁定 10-40 万 DXLYN
  - 累积影响: 年化 1-5% emission
  - 可恢复性: 无 (永久锁定)
  
- 可能性: 低-中
  - 触发频率: 取决于治理决策
  - 假设: 年 5-12 次 kill 操作

- 综合: **Medium** 合理 ✅

**建议调整**: 无,风险评级准确

### 11.3 置信度验证

**报告置信度**: 90%

**验证评估**:
- ✅ 代码逻辑确认: 100% (实际代码验证)
- ✅ 会计影响确认: 100% (数学推导)
- ✅ 无回收机制: 100% (全模块搜索)
- ✅ 经济影响量化: 80% (基于假设)

**实际置信度**: **95%** (略高于报告)

---

## 12. 最终建议

### 12.1 立即修复 (Critical)

**实施方案**: 在 kill_gauge 时将 claimable 转给 fee_distributor

**代码修改**:
```move
public entry fun kill_gauge(governance: &signer, gauge: address) acquires Voter {
    let voter_address = get_voter_address();
    let voter = borrow_global_mut<Voter>(voter_address);

    let governance_address = address_of(governance);
    assert!(governance_address == voter.governance, ERROR_NOT_GOVERNANCE);

    assert!(table::contains(&voter.is_alive, gauge), ERROR_GAUGE_NOT_EXIST);
    let is_alive = table::borrow_mut(&mut voter.is_alive, gauge);
    assert!(*is_alive, ERROR_GAUGE_ALREADY_KILLED);
    *is_alive = false;

    // 新增: 回收 claimable
    let claimable_amount = *table::borrow_with_default(&voter.claimable, gauge, &0);
    if (claimable_amount > 0) {
        let dxlyn_metadata = address_to_object<Metadata>(voter.dxlyn_coin_address);
        let voter_signer = object::generate_signer_for_extending(&voter.extended_ref);
        // 转给 fee_distributor 作为额外 rebase
        primary_fungible_store::transfer(
            &voter_signer, 
            dxlyn_metadata, 
            fee_distributor::get_fee_distributor_address(), 
            claimable_amount
        );
        // 或者调用 fee_distributor::add_recovered_funds(&voter_signer, claimable_amount);
    }

    table::upsert(&mut voter.claimable, gauge, 0);

    let time = epoch_timestamp();
    let pool = table::borrow(&voter.pool_for_gauge, gauge);
    let weights_per_epoch =
        weights_per_epoch_internal(&voter.weights_per_epoch, time, *pool);

    let total_weights_per_epoch = table::borrow_mut_with_default(&mut voter.total_weights_per_epoch, time, 0);
    *total_weights_per_epoch = *total_weights_per_epoch - weights_per_epoch;

    event::emit(GaugeKilledEvent { gauge, recovered_amount: claimable_amount })  // 新增事件字段
}
```

### 12.2 测试验证

**添加测试用例**:
```move
#[test(governance = @0x123, minter = @0x456)]
fun test_kill_gauge_recovers_claimable(governance: &signer, minter: &signer) {
    // Setup
    let gauge = create_test_gauge();
    voter::notify_reward_amount(minter, 1000000);  // 添加 emission
    voter::update_for_after_distribution(gauge);   // 累积 claimable
    
    let claimable_before = voter::get_claimable(gauge);  // 例如 100000
    let voter_balance_before = voter::get_dxlyn_balance();
    let fee_dist_balance_before = fee_distributor::get_dxlyn_balance();
    
    // Execute
    voter::kill_gauge(governance, gauge);
    
    // Assert
    assert!(voter::get_claimable(gauge) == 0, 1);  // claimable 清零
    assert!(
        voter::get_dxlyn_balance() == voter_balance_before - claimable_before, 
        2
    );  // voter 余额减少
    assert!(
        fee_distributor::get_dxlyn_balance() == fee_dist_balance_before + claimable_before,
        3
    );  // fee_distributor 余额增加
}
```

### 12.3 文档更新

**添加到 doc/voter.md**:
```markdown
## kill_gauge

Kills a malicious or problematic gauge.

### Behavior
- Sets `is_alive[gauge] = false`
- Transfers any accumulated `claimable[gauge]` to fee_distributor as additional rebase
- Reduces `total_weights_per_epoch` by the gauge's weight
- Prevents the gauge from receiving future emissions

### Note
The recovered DXLYN from claimable is distributed to veNFT holders through fee_distributor, 
compensating the protocol for the killed gauge.
```

---

## 13. 结论

**Final Verdict**: **VALID VULNERABILITY**

**严重性**: Medium (中)

**关键发现**:
1. ✅ 代码逻辑缺陷确认: kill_gauge 清零 claimable 但不转移资金
2. ✅ 会计不变量破坏: voter 资产 ≠ 负债
3. ✅ 累积效应显著: 年化可锁定 1-5% emission
4. ✅ 无回收机制: 永久锁定,无法恢复

**与审计规则的符合性**:
- ✅ 符合"特权操作导致会计失衡"的漏洞定义
- ✅ 不属于"设计特性"(无文档支持)
- ✅ 破坏核心会计不变量
- ✅ 存在可行的修复方案

**修复优先级**: **High** (虽然风险评级为 Medium,但修复简单且影响深远)

**审计师意见**: 报告准确,建议立即修复。
