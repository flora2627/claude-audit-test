## 标题
`voter::estimated_rebase` 和 `minter::calculate_rebase_gauge` 中锁仓率计算存在单位不匹配，导致rebase分配错误

## 类型
报表层面 / Mis-measurement

## 风险等级
高

## 位置
- `sources/voter.move` 中 `estimated_rebase` 函数，约第 1394-1400 行
- `sources/minter.move` 中 `calculate_rebase_gauge` 函数，约第 283-291 行

## 发现依据
两处代码都存在相同的单位不匹配问题：

**voter.move L1394-1400:**
```move
let dxlyn_supply = (dxlyn_coin::total_supply() as u256);  // 10^8 精度
let ve_dxlyn_supply = (voting_escrow::total_supply(epoch_timestamp() + WEEK) as u256);  // 10^12 精度

// (1 - veDXLYN/DXLYN), scaled by 10^4
let diff_scaled = AMOUNT_SCALE - (ve_dxlyn_supply / dxlyn_supply);  // 错误：ve_supply(10^12) / dxlyn_supply(10^8) = 10^4倍实际值
```

**minter.move L283-291:**
```move
let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);  // 10^12 精度
let dxlyn_supply = (dxlyn_coin::total_supply() as u256);  // 10^8 精度

// (1 - veDXLYN/DXLYN), scaled by 10^4
let diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply);  // 相同错误
```

## 影响
- 锁仓率被高估10^4倍，导致diff_scaled趋近于负值或异常值
- rebase计算完全错误，可能导致：
  - rebase金额异常（过高或过低）
  - fee_distributor分配不足或过剩
  - gauge分配相应减少或增加
- 破坏了协议的经济模型平衡

## 触发条件 / 调用栈
- 每周调用 `voter::update_period()` 时
- 任何调用 `voter::estimated_rebase()` 的查询

## 建议修复
修正单位匹配，在除法前统一精度：

```move
// 方案1: 将ve_supply转换为dxlyn_supply的精度
let ve_dxlyn_supply_scaled = ve_dxlyn_supply / 10000;  // 10^12 -> 10^8
let diff_scaled = AMOUNT_SCALE - (ve_dxlyn_supply_scaled / dxlyn_supply);

// 方案2: 将dxlyn_supply放大到ve_supply的精度
let dxlyn_supply_scaled = dxlyn_supply * 10000;  // 10^8 -> 10^12
let diff_scaled = AMOUNT_SCALE - (ve_dxlyn_supply / dxlyn_supply_scaled);
```

## 置信度
100%

---

## ⚠️ 验证结果：FALSE POSITIVE

**验证日期**：2025-11-06  
**判定**：此报告为假阳性（False Positive）

### 核心结论

虽然表面上看存在"单位不匹配"（`ve_supply` 是 10^12 精度，`dxlyn_supply` 是 10^8 精度），但由于 **voting power 的定义中已经包含了 `AMOUNT_SCALE` (10^4) 因子**，这个"不匹配"恰好是正确的设计。

### 数学证明

Voting power 的计算公式：
```
slope = (locked.amount * AMOUNT_SCALE) / MAXTIME
      = (locked.amount * 10^4) / MAXTIME
      
voting_power = slope * remaining_time
             = (locked.amount * 10^4 * remaining_time) / MAXTIME
```

当锁满 4 年时：
```
voting_power = locked.amount * 10^4
```

因此：
```
ve_supply / dxlyn_supply 
  = Σ(locked_i * 10^4 * time_factor_i) / (total_supply)
  = lockup_ratio * 10^4
```

所以：
```
diff_scaled = AMOUNT_SCALE - (ve_supply / dxlyn_supply)
            = 10^4 - lockup_ratio * 10^4
            = (1 - lockup_ratio) * 10^4  ✓ 正确！
```

### 具体数值验证

**场景：50% 供应量锁满 4 年**
- Total supply: 100,000,000 DXLYN
- Locked: 50,000,000 DXLYN (锁满 4 年)
- ve_supply = 50,000,000 * 10^4 * 10^8 = 5 * 10^19
- dxlyn_supply = 100,000,000 * 10^8 = 10^16
- ve_supply / dxlyn_supply = 5000
- diff_scaled = 10000 - 5000 = 5000
- 预期值 = (1 - 0.5) * 10000 = 5000 ✓

### 为何是 False Positive

1. **Voting power ≠ 锁定的 DXLYN 数量**
   - Voting power 是"时间加权的锁定量"
   - 单位是 10^12，这是设计的一部分

2. **AMOUNT_SCALE 的作用**
   - 在 slope 计算时引入 `* AMOUNT_SCALE`
   - 使得 voting power 与 DXLYN supply 的比值自然具有正确的精度

3. **代码已正常运行**
   - 如果真存在 10^4 倍错误，在任何锁仓率 > 10% 时，diff_scaled 都会变成负数
   - 但协议实际运行正常

4. **存在"看似正确"的替代实现**
   - `minter::calculate_rebase_internal` 使用了更复杂的精度调整
   - 但数学上与当前实现完全等价
   - 当前实现更简洁高效

### 详细验证报告

完整的数学证明、调用链分析、经济分析等详见：
[finding_4_validation.md](finding_4_validation.md)

### 建议

对项目方：
- ✅ 保持当前实现（功能正确）
- ⚠️ 改进代码注释，解释为什么 `ve_supply (10^12) / dxlyn_supply (10^8)` 是正确的
- ⚠️ 删除未使用的 `calculate_rebase_internal` 函数
- ⚠️ 修正 minter.move L351 的错误注释

对审计员：
- 遇到"单位不匹配"时，深入理解变量的语义
- 用具体数值进行端到端验证
- 追溯精度设计的来源
- 思考"如果 bug 存在，协议为何能正常运行"

**验证置信度：100%**
