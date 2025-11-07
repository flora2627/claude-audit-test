# gauge_perp 模块复式记账分析

## 说明
gauge_perp与gauge_cpmm的会计逻辑完全一致,区别仅在于质押资产类型:
- gauge_cpmm: 质押AMM的LP代币
- gauge_perp: 质押Perpetual的DXLP代币

## 📌 核心函数复式记账

### 所有函数的变量变动与会计平衡

**完全同gauge_cpmm**:
- `deposit_internal`: total_supply↑ = balance_of[user]↑ = 实际DXLP流入
- `withdraw_internal`: total_supply↓ = balance_of[user]↓ = 实际DXLP流出
- `notify_reward_amount`: 合约DXLYN↑, reward_rate更新
- `update_reward`: reward_per_token↑, rewards[user]↑
- `get_reward`: rewards[user]↓ = 实际DXLYN流出

---

## 会计公式(同gauge_cpmm)

```
total_supply = sum(balance_of[user])
reward_per_token_stored += (reward_rate * Δtime * PRECISION) / total_supply
rewards[user] += balance_of[user] * (reward_per_token - user_paid) / PRECISION
```

---

## 会计风险(同gauge_cpmm)

### 🔴 高风险(继承自gauge_cpmm)

#### 1. total_supply=0时notify,奖励丢失
#### 2. 精度损失累积

### ❌ 无新增风险

DXLP是标准Coin类型,无类似gauge_clmm的liquidity可变性问题。

---

## 总结

gauge_perp与gauge_cpmm完全同构,仅资产类型不同:
- **资产**: DXLP代币(total_supply)
- **负债**: 用户份额(balance_of)和奖励(rewards)
- **权益**: 奖励分配逻辑(reward_per_token_stored)

所有会计风险与gauge_cpmm一致,无新增风险点。

