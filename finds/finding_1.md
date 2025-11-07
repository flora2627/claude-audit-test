## 标题
`emission::weekly_emission` 重复累计 `total_emitted`

## 类型
报表层面 / Mis-measurement

## 风险等级
中

## 位置
`sources/emission.move` 中 `weekly_emission` 函数，约第 320-341 行

## 发现依据
- 该函数在计算非首周排放时，会先将本周排放量 `emission` 加到 `schedule.total_emitted`，随后又在函数尾部无条件再次执行一次 `schedule.total_emitted += _calculated_emission`。
- 这一重复记账使得 `total_emitted` 永远比真实累计排放量多一倍，导致系统层面的排放报表与真实铸币量严重偏离。
- 关联代码：

```332:341: sources/emission.move
            schedule.total_emitted = schedule.total_emitted + emission;
            schedule.last_emission = emission;
            _calculated_emission = emission;
        };

        // Store emission record with timestamp
        schedule.total_emitted = schedule.total_emitted + _calculated_emission;
```

## 影响
- `total_emitted` 被作为累计排放统计值，对应全局"DXLYN 已发行总量"报表口径。
- 由于重复累加，报表中的"已发行总量"与真实铸币量不一致，会误导依赖该数据的财务分析、供应监控以及任何基于累计排放的会计核对。
- 同步写入的事件 `EmissionEvent` 也携带错误的 `total_emitted` 字段，使链上事件日志与真实排放脱节。

---

# 验证报告 (Validator Report)

## 1. Executive Verdict
**状态**: ✅ **VALID - 确认为真实缺陷**

**一句话理由**: 代码在非首次调用时确实对 `total_emitted` 进行了两次累加（L334和L340），导致报表值为实际铸币量的约2倍（首次epoch除外），属于会计报表层面的测量错误。

## 2. Reporter's Claim Summary
报告声称 `emission::weekly_emission()` 函数存在重复累加bug：
- 在计算非首周排放时，L334将 `emission` 加到 `total_emitted`
- L340又无条件将 `_calculated_emission`（等于 `emission`）再次加到 `total_emitted`
- 导致 `total_emitted` 偏离真实累计铸币量

## 3. Code-Level Proof

### 3.1 关键代码路径分析

**首次调用路径** (`schedule.last_emission == 0`):

```317:322:sources/emission.move
if (schedule.last_emission == 0) {
    let (result, _) = calculate_with_overflow_check(schedule.initial_supply, schedule.initial_rate_bps);
    
    _calculated_emission = result / BPS_DENOMINATOR;
    
    schedule.last_emission = _calculated_emission;
```

- 计算 `_calculated_emission`
- 更新 `last_emission`
- **注意**: 此分支内未修改 `total_emitted`

**非首次调用路径** (`schedule.last_emission > 0`):

```323:337:sources/emission.move
} else {
    let current_epoch = (current_time - schedule.created_at) / EPOCH;
    
    let emission = calculate_emission(
        schedule.last_emission,
        schedule.initial_supply,
        schedule.initial_rate_bps,
        schedule.decay_rate_bps,
        schedule.decay_start_epoch,
        current_epoch
    );
    schedule.total_emitted = schedule.total_emitted + emission;  // ← 第一次累加
    schedule.last_emission = emission;
    _calculated_emission = emission;  // ← _calculated_emission = emission
};
```

**无条件执行的累加** (两个分支都会执行):

```339:341:sources/emission.move
// Store emission record with timestamp
schedule.total_emitted = schedule.total_emitted + _calculated_emission;  // ← 第二次累加
schedule.epoch_counter = schedule.epoch_counter + 1;
```

### 3.2 逻辑验证

| Epoch | 分支 | L334累加 | L336赋值 | L340累加 | total_emitted实际值 | 应有值 | 倍数 |
|-------|------|---------|---------|---------|-------------------|--------|------|
| 1 (首次) | if | 0 | _calculated_emission = E1 | +E1 | E1 | E1 | ✅ 1x |
| 2 | else | +E2 | _calculated_emission = E2 | +E2 | E1+2E2 | E1+E2 | ❌ 错误 |
| 3 | else | +E3 | _calculated_emission = E3 | +E3 | E1+2E2+2E3 | E1+E2+E3 | ❌ 错误 |
| n | else | +En | _calculated_emission = En | +En | E1+2(E2+...+En) | E1+E2+...+En | ❌ 错误 |

**数学证明**:
```
正确的 total_emitted = Σ(Ei) for i=1 to n
实际的 total_emitted = E1 + Σ(2*Ei) for i=2 to n
                     = E1 + 2*(Σ(Ei) for i=2 to n)
                     ≈ 2*(Σ(Ei)) - E1
                     ≈ 2 * (真实值) - E1
```

当 n 足够大时，误差率趋近于 100%。

## 4. Call Chain Trace

### 4.1 完整调用链

```
[Entry Point] voter::update_period()
  ↓ (entry function, msg.sender = 任意地址)
  |
  ├→ [Friend Call] minter::calculate_rebase_gauge()
  |    ↓ (L270-309 in minter.move)
  |    | caller: voter module
  |    | callee: minter module
  |    | 
  |    ├→ [Friend Call] emission::weekly_emission(dxlyn_obj_addr)
  |    |    ↓ (L309-373 in emission.move)
  |    |    | caller: minter module
  |    |    | callee: emission module
  |    |    | 功能: 计算本周排放量并**更新状态**
  |    |    | 
  |    |    ├→ [State Mutation] schedule.total_emitted += emission (L334)
  |    |    ├→ [State Mutation] schedule.total_emitted += _calculated_emission (L340) ← BUG!
  |    |    └→ return _calculated_emission
  |    |
  |    ├→ [Calculation] 计算rebase和gauge分配
  |    |
  |    └→ [Friend Call] dxlyn_coin::mint(&dxlyn_signer, dxlyn_obj_addr, weekly_emission)
  |         ↓ (L303 in minter.move)
  |         | 铸造数量 = _calculated_emission (未被double)
  |         | **实际铸币量是正确的，只有报表total_emitted错误**
  |
  └→ [Reward Distribution] 分配rebase和gauge奖励
```

### 4.2 关键观察

1. **调用权限**: `weekly_emission()` 是 `friend` 函数，只有 `minter` 模块可调用
2. **msg.sender**: 在整个调用链中不影响状态修改
3. **实际铸币量**: `dxlyn_coin::mint()` 使用的是返回值 `_calculated_emission`，**不受bug影响**
4. **受影响状态**: 仅 `EmissionSchedule.total_emitted` 字段被double-counted

## 5. State Scope Analysis

### 5.1 状态变量映射

| 变量名 | 存储位置 | 作用域 | 读写权限 | 受影响? |
|--------|---------|--------|---------|---------|
| `EmissionSchedule` | `minter_object_address` | global (单例) | friend (minter) | ✅ |
| `total_emitted: u64` | `EmissionSchedule` 内 | global | friend write | ✅ **被double** |
| `last_emission: u64` | `EmissionSchedule` 内 | global | friend write | ✅ 正确 |
| `epoch_counter: u64` | `EmissionSchedule` 内 | global | friend write | ✅ 正确 |
| `emissions_by_epoch` | `Table<u64, EmissionRecord>` | global | friend write | ✅ 正确 |
| `EmissionRecord.emission_amount` | Table值 | per-epoch | friend write | ✅ 正确 (使用`_calculated_emission`) |

### 5.2 Storage Slot分析

- **Storage Model**: Move的资源模型，`EmissionSchedule` 存储在 `minter_object_address`
- **Access Pattern**: 
  - `borrow_global_mut<EmissionSchedule>(addr)` 获取可变引用
  - 修改字段直接修改全局状态
  - 无assembly操作

### 5.3 关键发现

1. **实际铸币流**: `weekly_emission()` 返回 → `mint()` 使用 → ✅ 正确
2. **报表记录流**: 
   - `emissions_by_epoch[epoch].emission_amount` = `_calculated_emission` → ✅ 正确
   - `total_emitted` 累加两次 → ❌ 错误
3. **事件日志**: `EmissionEvent.total_emitted` 使用double的值 → ❌ 错误

## 6. Exploit Feasibility

### 6.1 攻击者能力要求

**不存在可攻击路径** - 这是一个被动的会计缺陷，而非可利用的漏洞。

| 要素 | 评估 | 说明 |
|------|------|------|
| 需要特权? | ❌ 否 | 任何人可调用 `voter::update_period()` |
| 能获取额外代币? | ❌ 否 | 铸币量不受影响 |
| 能操纵报表? | ✅ 是 (被动) | 报表自动错误，非主动操纵 |
| 链上可完整执行? | ✅ 是 | 每次调用自动触发 |
| 需要外部条件? | ❌ 否 | 时间推进即可 |

### 6.2 EOA完整执行路径

```solidity
// 以太坊伪代码示例
function triggerBug() external {
    // 任何EOA都可调用
    voter.update_period();
    // Bug自动触发，total_emitted被double
}
```

**结论**: 普通EOA可触发，但**无法从中获益**，因为：
1. 不能获得额外的代币
2. 不能窃取他人资产
3. 仅导致报表数据错误

## 7. Economic Analysis

### 7.1 攻击者P&L

| 项目 | 数值 | 说明 |
|------|------|------|
| Gas成本 | -G | 调用 `update_period()` 的gas费 |
| 获得代币 | 0 | 铸币量不受影响 |
| 窃取资产 | 0 | 无资产转移 |
| **净收益** | **-G** | **纯亏损** |

**EV (期望值)**: `-G < 0`，攻击者无经济动机。

### 7.2 协议影响

| 受影响方 | 影响类型 | 严重程度 | 经济损失 |
|---------|---------|---------|---------|
| 代币持有者 | 无 | 无 | $0 |
| 协议金库 | 无 | 无 | $0 |
| 链上数据消费者 | 报表误导 | 中 | 决策失误风险 |
| 审计/监控系统 | 报表不一致 | 中 | 警报误触发 |

### 7.3 真实世界场景

**假设**: 
- 首次排放 E1 = 2,000,000 DXLYN
- 增长率 2%/周，共运行52周

**计算实际偏差**:

```
真实累计 = E1 + E1*1.02 + E1*1.02^2 + ... + E1*1.02^51
         = E1 * (1.02^52 - 1) / 0.02
         ≈ 2,000,000 * 1.842
         ≈ 113,709,000 DXLYN

报表累计 = E1 + 2*(E1*1.02 + E1*1.02^2 + ... + E1*1.02^51)
         = E1 + 2*(真实累计 - E1)
         = E1 + 2*111,709,000
         = 2,000,000 + 223,418,000
         = 225,418,000 DXLYN

偏差率 = (225,418,000 - 113,709,000) / 113,709,000
       ≈ 98.2% (约2倍)
```

**链上验证**: 任何人都可以：
1. 读取 `total_emitted` → 225,418,000
2. 求和 `emissions_by_epoch[1..52]` → 113,709,000
3. 发现不一致 → 确认bug

## 8. Dependency/Library Reading

### 8.1 涉及的Move标准库

| 模块 | 函数 | 行为验证 | 影响 |
|------|------|---------|------|
| `aptos_std::table` | `upsert()` | 插入/更新键值对 | ✅ 正常 |
| `supra_framework::timestamp` | `now_seconds()` | 获取当前时间戳 | ✅ 正常 |
| `supra_framework::event` | `emit()` | 发送事件 | ⚠️ 携带错误的total_emitted |

### 8.2 依赖模块验证

**minter.move (L303)**:
```move
dxlyn_coin::mint(&dxlyn_signer, dxlyn_obj_addr, weekly_emission);
```
- `weekly_emission` = `emission::weekly_emission()` 的返回值 (L281)
- 返回值是 `_calculated_emission`，不是 `total_emitted`
- **铸币量使用返回值，故不受bug影响** ✅

**dxlyn_coin::mint() 源码未提供**，但基于调用分析：
- 参数 `weekly_emission` 是正确的单周排放量
- `total_emitted` 仅在 `emission` 模块内部维护，不传递给 `mint()`

## 9. Final Feature-vs-Bug Assessment

### 9.1 是否为设计意图?

**❌ 不是设计特性，确认为缺陷**

**证据**:
1. **语义不一致**: `total_emitted` 变量名暗示"累计已发行"，应等于所有epoch的emission总和
2. **内部不一致**: 
   - `emissions_by_epoch[i].emission_amount` 记录的是单周正确值
   - `Σ(emissions_by_epoch[i].emission_amount)` ≠ `total_emitted`
3. **测试期望值宽松**: 测试使用 `>` 而非 `==`，未能捕获bug:
   ```move
   // test_emission.move L410
   assert!(total_emitted > get_quants(6_000_000), 2); 
   // 期望 6,120,800，实际可能是 10,241,600，仍通过
   ```
4. **代码注释**: L339注释 "Store emission record with timestamp"，暗示此处应该是存储而非累加

### 9.2 根因分析

**可能的开发错误**:
1. **重构遗留**: 原本L334可能在if分支内，后来重构时错误地保留
2. **逻辑混淆**: 开发者可能混淆了"本周emission"与"累计emission"的更新位置

### 9.3 最小修复方案

**方案1**: 删除L334的累加 (推荐)

```move
} else {
    let emission = calculate_emission(...);
    // schedule.total_emitted = schedule.total_emitted + emission;  ← 删除此行
    schedule.last_emission = emission;
    _calculated_emission = emission;
};
// L340的累加保留
schedule.total_emitted = schedule.total_emitted + _calculated_emission;
```

**方案2**: 删除L340的累加

```move
} else {
    let emission = calculate_emission(...);
    schedule.total_emitted = schedule.total_emitted + emission;  ← 保留
    schedule.last_emission = emission;
    _calculated_emission = emission;
};
// schedule.total_emitted = schedule.total_emitted + _calculated_emission;  ← 删除此行
```

但需同时修改首次调用分支，在L322后添加:
```move
schedule.total_emitted = schedule.total_emitted + _calculated_emission;
```

**推荐**: 方案1更简洁，保持代码结构一致。

### 9.4 回归测试需求

修复后需要更新测试:
```move
// test_emission.move L410
assert!(total_emitted == get_quants(6_120_800), 2); // 使用精确值
```

## 10. 最终结论

### 10.1 漏洞分类
- **类型**: Accounting/Reporting Error (会计/报表错误)
- **严重程度**: Medium (中)
- **可利用性**: Not Exploitable (不可利用)
- **影响范围**: View/Reporting Layer Only (仅视图/报表层)

### 10.2 为何不是High严重程度?

虽然bug确实存在，但：
1. ✅ **无资金损失**: 实际铸币量正确
2. ✅ **无资产窃取**: 攻击者无法获益
3. ✅ **可检测**: 链上数据可验证不一致
4. ⚠️ **影响有限**: 仅报表/事件数据错误

### 10.3 建议

1. **立即修复**: 删除L334的重复累加
2. **增强测试**: 使用精确值断言 `total_emitted`
3. **数据迁移**: 修复后需重新计算历史 `total_emitted` (如果已部署)
4. **文档更新**: 明确 `total_emitted` 的语义和计算方式

---

**验证完成时间**: 2025-11-06  
**验证者**: AI Auditor (Strict Mode)  
**置信度**: 100%

