# vesting 模块复式记账分析

## 📌 vesting@create_vesting_contract

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `vesting_contracts` | 借(添加) | 索引 | 添加新vesting合约 |
| `nonce` | 平(递增) | 计数器 | 生成唯一地址 |
| 新VestingContract对象 | 借(创建) | 子实体 | 创建新会计主体 |

### ⚖️ 函数会计平衡式

```
无金额变动,仅创建合约框架
```

**调用**: 创建空vesting合约,需后续contribute注入资产

---

## 📌 vesting@contribute

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| vesting_contract合约DXLYN余额 | 借(增加) | 资产 | 接收contribute的DXLYN |
| sender的DXLYN余额 | 贷(减少) | 外部资产 | sender转出DXLYN |

### ⚖️ 函数会计平衡式

```
借方: Δvesting余额 = amount
贷方: Δsender余额 = amount
```

**会计平衡**: ✅

**调用**: L760-805
- L797 `primary_fungible_store::transfer(sender, vesting_address, amount)`

**无负债更新**: contribute只增加资产,不增加负债,需admin后续add_shareholders

---

## 📌 vesting@vest

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `vesting_records[shareholder].left_amount` | 贷(减少) | 负债 | 股东剩余待释放减少 |
| `vesting_records[shareholder].last_vested_period` | 平(更新) | 进度 | 记录领取到第几期 |
| vesting合约DXLYN余额 | 贷(减少) | 资产 | 转出已释放部分 |
| beneficiary的DXLYN余额 | 借(增加) | 外部资产 | 受益人收到DXLYN |

### ⚖️ 函数会计平衡式

```
vested_amount = calculate_vested(init_amount, periods)
Δleft_amount = -vested_amount

借方: Δbeneficiary余额 = vested_amount
贷方: Δleft_amount + Δvesting余额 = vested_amount
```

**会计平衡**: ✅

**调用链**: L513-629
- L534-554: 获取shareholder和beneficiary
- L556-572: 获取vesting_record
- L576-597: 计算current_period和vested_amount
  - L586 `vested_amount = get_vested_amount()`
  - L913-961 `get_vested_amount()`: 按schedule累加已释放比例
- L602 `left_amount -= vested_amount`
- L604 `last_vested_period = current_period`
- L616-621: 转账DXLYN给beneficiary

**关键风险**:
- L586 `vested_amount = min(computed, left_amount)` - 防止超额领取
- L913-961 FixedPoint32精度损失,可能最后一期left_amount>0

---

## 📌 vesting@admin_withdraw

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| vesting合约余额 | 贷(减少) | 资产 | admin提走DXLYN |
| admin余额 | 借(增加) | 外部资产 | admin收到DXLYN |
| `left_amount`总和 | 平(不变) | 负债 | **负债不变,资产减少!** |

### ⚖️ 函数会计平衡式

```
借方: Δadmin余额 = amount
贷方: Δvesting余额 = amount

⚠️ 资产 < 负债 (如果withdraw后)
```

**会计不平衡**: ❌ **严重风险**
- admin可提走资产,但left_amount负债不减
- **后果**: 股东vest时余额不足,revert

**调用链**: L687-732
- L721 `assert balance >= amount` - 只检查当前余额,不检查负债
- L724-729 转账给admin

**风险评估**: 🔴 **高危**
- admin可掏空合约,股东无法领取
- 需添加检查: `balance - amount >= sum(left_amount)`

---

## 📌 vesting@remove_shareholder

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `vesting_records[shareholder]` | 贷(移除) | 负债 | 移除股东记录 |
| vesting合约余额 | 贷(减少) | 资产 | 转出left_amount |
| beneficiary余额 | 借(增加) | 外部资产 | 受益人收到剩余DXLYN |

### ⚖️ 函数会计平衡式

```
借方: Δbeneficiary余额 = left_amount
贷方: Δvesting余额 + Δleft_amount负债 = left_amount
```

**会计平衡**: ✅
- 移除负债的同时转出对应资产

**调用链**: L645-685
- L667-672 vest当前已释放部分
- L674 `left_amount = vesting_record.left_amount`
- L676-681 转账left_amount给beneficiary
- L683 `simple_map::remove(vesting_records, shareholder)` - 移除记录

---

## 会计风险汇总

### 🔴 高风险

#### 1. admin_withdraw可导致资产<负债
- **位置**: L687-732
- **场景**: admin提走资产,但left_amount不减
- **后果**: 股东vest时revert,资不抵债
- **建议**: 添加检查 `余额 - amount >= sum(left_amount)`

### 🟡 中风险

#### 2. FixedPoint32精度损失
- **位置**: L913-961 `get_vested_amount()`
- **场景**: schedule计算精度损失,最后一期可能有dust
- **后果**: left_amount>0但schedule已100%,无法完全领取

#### 3. terminate后股东无法vest
- **位置**: L513 `assert state != TERMINATED`
- **场景**: admin terminate,股东损失未领取部分
- **缓解**: terminate前应通知股东

---

## 总结

### 核心会计公式
```
contribute: vesting余额↑ = 实际DXLYN流入
vest: left_amount↓ = vesting余额↓ = beneficiary收到
remove_shareholder: left_amount移除 = vesting余额↓
admin_withdraw: vesting余额↓, left_amount不变(❌ 风险)
```

### 关键风险
- **admin_withdraw破坏资产=负债**: 最严重风险
- **precision损失**: 最后一期可能有dust无法领取

