# gauge_cpmm 模块复式记账分析

## 📌 gauge_cpmm@deposit_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `total_supply` | 借(增加) | 资产 | LP代币托管总量增加 |
| `balance_of[user]` | 贷(增加) | 负债 | 用户质押份额增加 |
| 合约LP余额 | 借(增加) | 实际资产 | 接收用户LP代币 |
| 用户LP余额 | 贷(减少) | 外部资产 | 用户转出LP |
| `rewards[user]` | 贷(更新) | 负债-奖励 | update_reward计算待领奖励 |
| `user_reward_per_token_paid[user]` | 平(更新) | 检查点 | 同步到最新reward_per_token_stored |

### ⚖️ 函数会计平衡式

```
借方: Δtotal_supply + Δ合约LP余额 = amount
贷方: Δbalance_of[user] + Δ用户LP余额 = amount
```

**会计平衡**: ✅

**调用链**: deposit → deposit_internal → update_reward → 转账LP

---

## 📌 gauge_cpmm@withdraw_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `total_supply` | 贷(减少) | 资产 | LP托管减少 |
| `balance_of[user]` | 贷(减少) | 负债 | 用户质押减少 |
| 合约LP余额 | 贷(减少) | 实际资产 | 返还LP给用户 |
| 用户LP余额 | 借(增加) | 外部资产 | 用户收到LP |
| `rewards[user]` | 贷(更新) | 负债-奖励 | update_reward计算 |

### ⚖️ 函数会计平衡式

```
借方: Δ用户LP余额 = amount
贷方: Δtotal_supply + Δbalance_of[user] + Δ合约LP余额 = amount
```

**会计平衡**: ✅

---

## 📌 gauge_cpmm@get_reward (harvest)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `rewards[user]` | 贷(归零) | 负债 | 用户奖励归零 |
| 合约DXLYN余额 | 贷(减少) | 资产 | 转出DXLYN奖励 |
| 用户DXLYN余额 | 借(增加) | 外部资产 | 用户收到奖励 |

### ⚖️ 函数会计平衡式

```
借方: Δ用户DXLYN = rewards[user]
贷方: Δrewards[user] + Δ合约DXLYN余额 = rewards[user]
```

**会计平衡**: ✅

**调用**: update_reward → 转账DXLYN → rewards归零

---

## 📌 gauge_cpmm@notify_reward_amount

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| 合约DXLYN余额 | 借(增加) | 资产 | 接收voter的emission |
| voter合约DXLYN余额 | 贷(减少) | 外部资产 | voter转出 |
| `reward_rate` | 借(更新) | 权益-收益率 | 计算新的每秒奖励速率 |
| `period_finish` | 平(更新) | 时间 | 更新奖励结束时间 |
| `last_update_time` | 平(更新) | 时间 | 更新奖励更新时间 |

### ⚖️ 函数会计平衡式

```
借方: Δ合约DXLYN = reward
贷方: Δvoter余额 = reward

reward_rate = (reward + leftover) / duration
```

**会计平衡**: ✅

**关键逻辑**: L581-615
- 如果period未结束,计算leftover: `leftover = remaining * reward_rate`
- `new_reward_rate = (reward + leftover) / duration`
- **风险**: 精度损失,leftover可能<实际剩余

---

## 📌 gauge_cpmm@update_reward (内部modifier)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `reward_per_token_stored` | 借(增加) | 权益-累积收益率 | 更新全局奖励索引 |
| `last_update_time` | 平(更新) | 时间 | 更新时间 |
| `rewards[account]` | 贷(增加) | 负债-奖励 | 计算用户新增奖励 |
| `user_reward_per_token_paid[account]` | 平(更新) | 检查点 | 同步用户索引 |

### ⚖️ 函数会计平衡式

```
Δreward_per_token_stored = (reward_rate * Δtime * PRECISION) / total_supply
Δrewards[user] = balance_of[user] * (reward_per_token_stored - user_paid) / PRECISION
```

**会计平衡**: ⚠️ **精度损失**
- L707 `reward_per_token_stored += (reward_rate * Δtime * PRECISION) / total_supply`
- L718 `rewards[user] += (balance_of * delta_reward_per_token) / PRECISION`
- **风险**: 两次除法都可能损失精度

**关键**: 
- 如果total_supply=0,L710返回当前值不更新
- **后果**: total_supply=0时notify的奖励永久无法分配

---

## 会计风险汇总

### 🔴 高风险

#### 1. total_supply=0时notify,奖励丢失
- **位置**: L704-710 `reward_per_token_internal()`
- **场景**: gauge创建后立即notify,还没人deposit
- **后果**: reward_per_token_stored不更新,奖励留在合约,后续用户会分享

#### 2. 精度损失累积
- **位置**: L707, L718
- **累积**: 每次update_reward都有两次除法精度损失
- **后果**: sum(rewards[user]) < 实际应得,差额dust留在合约

### 🟡 中风险

#### 3. emergency_withdraw无奖励
- **位置**: `emergency_withdraw()`不调用update_reward
- **后果**: 用户损失未领取奖励

#### 4. notify的leftover计算不准
- **位置**: L588 `leftover = remaining * reward_rate / 1e18`
- **风险**: reward_rate从u256转u64时可能截断
- **后果**: 新周期的reward_rate偏小

---

## 总结

### 核心会计公式
```
deposit: total_supply↑ = balance_of[user]↑ = 实际LP流入
withdraw: total_supply↓ = balance_of[user]↓ = 实际LP流出
notify: 合约DXLYN↑, reward_rate = reward / duration
update_reward: reward_per_token↑, rewards[user]↑
get_reward: rewards[user]↓ = 实际DXLYN流出
```

### 关键风险
- **total_supply=0时notify**: 奖励无法分配
- **精度损失**: 每次update_reward都损失精度

