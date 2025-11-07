# minter 模块复式记账分析

## 📌 minter@calculate_rebase_gauge

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| minter合约DXLYN余额 | 借(增加) | 资产 | 铸造新一周emission |
| DXLYN.total_supply | 借(增加) | 全局资产 | DXLYN总供应增加 |
| `period` | 平(更新) | 时间 | 切换到新周 |
| emission.total_emitted | 借(增加) | 外部权益 | emission模块记录累积发行量 |

### ⚖️ 函数会计平衡式

```
weekly_emission = emission::weekly_emission()
rebase = weekly_emission * (1 - (ve_supply / dxlyn_supply))^2 * 0.5
gauge_emission = weekly_emission - rebase

借方: Δminter余额 = weekly_emission
贷方: Δtotal_emitted = weekly_emission

分配:
  rebase → fee_distributor
  gauge_emission → (返回给voter,由voter调用notify)
```

**会计平衡**: ⚠️ **精度损失**

**调用**: minter::calculate_rebase_gauge() (未直接在代码中找到,可能在其他调用链)

**关键公式**: 
- ve锁仓率 = ve_supply / dxlyn_supply
- rebase比例 = (1 - 锁仓率)^2 * 0.5
- **精度**: 使用u256计算,AMOUNT_SCALE=10000

**风险**:
- rebase + gauge_emission 可能因精度损失 ≠ weekly_emission
- 差额dust留在minter或分配偏差

---

## 📌 minter@first_mint

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `is_initialized` | 平(设为true) | 状态 | 标记初始化完成 |
| `period` | 平(更新) | 时间 | 对齐到当前周 |

### ⚖️ 函数会计平衡式

```
无金额变动,仅初始化
```

**调用**: L154-164

---

## 会计风险汇总

### 🔴 高风险

#### 1. rebase计算精度损失
- **场景**: ve_supply单位是10^12,dxlyn_supply是10^8,除法后可能精度问题
- **检查**: voter::estimated_rebase() L1391-1408
  - L1400 `diff_scaled = 10000 - (ve_supply / dxlyn_supply)` - 除法
  - L1403 `factor = (diff_scaled^2 * 5000) / 10000` 
  - L1408 `rebase = (emission * factor) / 1e8`
- **风险**: 多次除法精度损失
- **后果**: rebase + gauge ≠ emission,差额<1 DXLYN,可忽略

### 🟡 中风险

#### 2. weekly_emission未检查period
- **场景**: 同一周多次调用calculate_rebase_gauge
- **风险**: 重复铸币
- **检查**: 需验证minter是否有period检查逻辑(代码中未直接看到entry函数)

---

## 总结

### 核心会计公式
```
mint: weekly_emission = emission.calculate()
split: 
  rebase = emission * (1 - ve_rate)^2 * 0.5
  gauge = emission - rebase
distribute:
  rebase → fee_distributor
  gauge → voter
```

### 关键风险
- **精度损失**: rebase计算的多次除法
- **period控制**: 需确保每周只铸造一次

