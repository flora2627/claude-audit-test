# emission 模块复式记账分析

## 📌 emission@weekly_emission (friend函数)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `total_emitted` | 借(增加) | 权益-累积发行量 | 累计emission增加 |
| `last_emission` | 平(更新) | 权益-上周发行 | 记录本周emission |
| `epoch_counter` | 平(递增) | 索引 | epoch计数器+1 |
| `emissions_by_epoch[epoch]` | 贷(记录) | 历史记录 | 记录本周emission数据 |

### ⚖️ 函数会计平衡式

```
无实际资产流动,仅计算和记录

Δtotal_emitted = calculated_emission
emissions_by_epoch[epoch] = EmissionRecord{calculated_emission, rate, timestamp}
```

**会计平衡**: N/A (纯计算模块)

**调用链**: L309-372
- L318-322: 如果首次,计算`initial_supply * initial_rate / 100`
- L324-336: 否则调用`calculate_emission()`
  - L287-302: 如果epoch < decay_start,增长: `last * (100 + rate) / 100`
  - 如果epoch >= decay_start,衰减: `last * (100 - rate) / 100`
- L340 `total_emitted += _calculated_emission` - **累加两次?**
  - L322已加一次,L340又加一次,bug!
  - 检查: L322在if分支,L340在主流程,但L334也有`total_emitted +=`,**重复累加风险**

---

## 📌 emission@calculate_emission (friend函数)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| (无状态变动,纯计算) | - | - | - |

### ⚖️ 函数会计平衡式

```
epoch < decay_start: emission = last * (100 + initial_rate) / 100
epoch >= decay_start: emission = last * (100 - decay_rate) / 100
```

**会计平衡**: N/A

**调用**: L278-302

---

## 📌 emission@set_emission_pause

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `is_paused` | 平(切换) | 权益控制 | 暂停/恢复emission |

### ⚖️ 函数会计平衡式

```
无金额变动,仅控制开关
```

**调用**: L127-137

---

## 会计风险汇总

### 🔴 高风险

#### 1. total_emitted可能重复累加
- **位置**: L340 `total_emitted += _calculated_emission`
- **检查**: L320在首次emission分支也有累加,L334在else分支也有累加
- **分析**:
  - L320: 首次, `_calculated_emission = result / BPS`, L340 再加一次 → **累加两次**
  - L334: 非首次, `total_emitted += emission`, L340 再加一次 → **累加两次**
- **后果**: total_emitted = 实际emission的2倍, **严重bug!**

### 🟡 中风险

#### 2. Pause后epoch_counter不更新
- **场景**: pause期间,epoch_counter停滞
- **后果**: 恢复后时间错位
- **检查**: weekly_emission()在pause时直接return,不更新counter

#### 3. 计算溢出保护不足
- **位置**: L411-422 `calculate_with_overflow_check()`
- **检查**: 溢出时返回max_u64
- **风险**: 溢出后emission被cap,打破曲线

---

## 总结

### 核心会计公式
```
first: emission = initial_supply * initial_rate / 100
growth: emission = last * (1 + rate%)
decay: emission = last * (1 - rate%)
total_emitted = sum(all emissions)
```

### 关键风险
- **total_emitted重复累加**: 严重bug,需修复
- **pause逻辑**: 需检查恢复后的epoch对齐

