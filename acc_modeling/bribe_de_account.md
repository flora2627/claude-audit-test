# bribe 模块复式记账分析

## 📌 bribe@deposit (friend函数,由voter调用)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `total_supply[next_epoch]` | 借(增加) | 负债-总权重 | 下周该pool的总投票权重增加 |
| `balance[token_owner][next_epoch]` | 贷(增加) | 负债-用户权重 | 该用户在下周的权重增加 |

### ⚖️ 函数会计平衡式

```
total_supply[next_epoch] ↑ amount
balance[token_owner][next_epoch] ↑ amount

sum(balance[user][epoch]) = total_supply[epoch]
```

**会计平衡**: ✅

**调用链**: L532-561
- L543 `start_timestamp = active_period() + WEEK` - 记录到**下周**
- L544 `old_supply = total_supply[start_timestamp]`
- L545 `token_owner = object::owner(token)` - 获取NFT owner
- L546 `last_balance = balance[token_owner][start_timestamp]`
- L549 `total_supply[start_timestamp] = old_supply + amount`
- L554 `balance[token_owner][start_timestamp] = last_balance + amount`

**关键**: 记录到**next epoch**,确保当周权重已确定,不可操纵

---

## 📌 bribe@withdraw (friend函数,由voter调用)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `total_supply[next_epoch]` | 贷(减少) | 负债-总权重 | 下周总权重减少 |
| `balance[token_owner][next_epoch]` | 贷(减少) | 负债-用户权重 | 用户权重减少 |

### ⚖️ 函数会计平衡式

```
Δtotal_supply[next_epoch] = -amount
Δbalance[token_owner][next_epoch] = -amount

前提: amount <= old_balance
```

**会计平衡**: ✅

**调用链**: L574-606
- L589 `if (amount <= old_balance)` - 防止下溢
- L593 `total_supply[next_epoch] -= amount`
- L598 `balance[token_owner][next_epoch] -= amount`

---

## 📌 bribe@notify_reward_amount

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| bribe合约reward_token余额 | 借(增加) | 资产 | 接收奖励代币 |
| sender的reward_token余额 | 贷(减少) | 外部资产 | sender转出 |
| `reward_data[token][next_epoch]` | 贷(增加) | 负债-奖励总额 | 下周该代币的奖励总量 |

### ⚖️ 函数会计平衡式

```
借方: Δbribe合约余额 = reward
贷方: Δsender余额 + Δreward_data[token][next_epoch].rewards_per_epoch = reward
```

**会计平衡**: ✅

**调用链**: L692-761
- L713 `primary_fungible_store::transfer(sender, bribe_address, reward)` - 实际转账
- L718 `start_timestamp = active_period() + WEEK` - 记录到**下周**
- L724 `last_reward = reward_per_epoch[start_timestamp]` - 获取已有奖励
- L734 `rewards_per_epoch = last_reward + reward` - 累加奖励

**关键**: 
- 允许多次notify同一周,奖励累加
- L720-722: 首次notify记录`first_bribe_timestamp`

---

## 📌 bribe@get_reward_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `user_timestamp[owner][token]` | 平(更新) | 检查点 | 记录领取到哪个epoch |
| bribe合约reward_token余额 | 贷(减少) | 资产 | 转出奖励 |
| 用户reward_token余额 | 借(增加) | 外部资产 | 用户收到奖励 |

### ⚖️ 函数会计平衡式

```
reward = sum(
  (balance[owner][epoch] / total_supply[epoch]) * rewards_per_epoch[epoch]
  for epoch in [user_last_time, end_timestamp)
)
```

**会计平衡**: ⚠️ **精度损失**

**调用链**: L1150-1191
- L1157 `(reward, user_last_time) = earned_with_timestamp_internal()` - 计算应得
- L1166 `primary_fungible_store::transfer(bribe_signer, owner, reward)` - 转账
- L1185 `user_timestamp[owner][token] = user_last_time` - 更新进度

**关键风险**:
- L1351 `earned_internal()`: `rewards = (reward_per_token * balance) / MULTIPLIER`
- L1326 `reward_per_token_internal()`: `(rewards_per_epoch * MULTIPLIER) / total_supply`
- **两次除法**精度损失,sum(user_reward) < rewards_per_epoch

---

## 📌 bribe@earned_with_timestamp_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| (无状态变动,仅计算) | - | - | View函数逻辑 |

### ⚖️ 函数会计平衡式

```
reward = sum(
  (balance[owner][epoch] / total_supply[epoch]) * reward_per_epoch[epoch]
  for epoch in [user_last_time, end_timestamp), max 50 weeks
)
```

**会计平衡**: N/A (view函数)

**调用链**: L1265-1303
- L1269 `user_last_time = user_timestamp[owner][token]`
- L1273-1274: 如果首次领取,设为`first_bribe_timestamp - WEEK`
- L1280-1301: 遍历最多50周,累加reward

**关键风险**:
- 50周限制: 老用户需多次调用

---

## 会计风险汇总

### 🔴 高风险

#### 1. 精度损失累积
- **位置**: L1326 和 L1351 两次除法
- **场景**: 每个epoch的精度损失累积
- **后果**: sum(user_claim) < notify的总额,差额dust留在合约

#### 2. total_supply=0时notify
- **位置**: L1322 `if total_supply == 0 return reward_per_epoch`
- **场景**: 该pool无投票时,外部用户notify
- **后果**: reward_per_token无法计算,奖励分配给0,永久丢失

### 🟡 中风险

#### 3. 50周领取限制
- **位置**: L1280 `FIFTY_WEEKS`
- **后果**: 老用户需多次调用

#### 4. user_timestamp未初始化
- **位置**: L1273 `if user_last_time < first_bribe_timestamp`
- **处理**: 设为`first_bribe_timestamp - WEEK`
- **风险**: 首次领取会领到first_bribe之前的奖励吗? - 否,L1273-1274已防护

---

## 总结

### 核心会计公式
```
deposit: total_supply[next_epoch]↑ = balance[user][next_epoch]↑
notify: rewards_per_epoch[next_epoch]↑
get_reward: 
  reward = sum((balance / total_supply) * rewards_per_epoch)
  合约余额↓ = user余额↑
```

### 关键风险
- **total_supply=0时notify**: 奖励永久丢失
- **精度损失**: 两级除法累积
- **50周限制**: 老用户需分批claim

