# bribe 模块账套

## 模块概述
bribe 允许外部用户激励veNFT持有者投票给特定pool,托管各类奖励代币并按投票权重分配。

## 资产类变量 (Assets)

### 1. 合约持有的reward tokens
- **类型**: 通过`primary_fungible_store::balance(bribe_address, reward_token_metadata)`查询
- **位置**: 每个bribe合约地址
- **含义**: bribe托管的各类奖励代币(USDC, DXLYN等)
- **会计属性**: **多币种资产** - 按reward_token分类
- **增加**: `notify_reward_amount()` - 外部用户存入
- **减少**: `get_reward()` - 用户领取

## 负债类变量 (Liabilities)

### 1. `balance: Table<address, Table<u64, u64>>`
- **类型**: Table<token_owner, Table<epoch_timestamp, voting_power>>
- **位置**: `Bribe` struct
- **含义**: 每个用户在每个epoch的投票权重
- **会计属性**: **权重负债** - 用户的贿赂领取权重
- **来源**: voter调用`deposit()`时写入

### 2. `total_supply: Table<u64, u64>`
- **类型**: Table<epoch_timestamp, total_voting_power>
- **位置**: `Bribe` struct
- **含义**: 每个epoch该pool的总投票权重
- **会计属性**: **权重总额** - 用于计算用户份额
- **恒等式**: `total_supply[epoch] = sum(balance[user][epoch])`

### 3. `reward_data: Table<address, Table<u64, Reward>>`
- **类型**: Table<reward_token, Table<epoch_timestamp, Reward>>
  ```move
  struct Reward {
      period_finish: u64,
      rewards_per_epoch: u64,
      last_update_time: u64
  }
  ```
- **位置**: `Bribe` struct
- **含义**: 每个奖励代币在每个epoch的奖励总量
- **会计属性**: **奖励负债** - 该epoch可分配的奖励总额

### 4. `user_timestamp: Table<address, Table<address, u64>>`
- **类型**: Table<user, Table<reward_token, last_claim_epoch>>
- **位置**: `Bribe` struct
- **含义**: 每个用户每个奖励代币的上次领取时间戳
- **会计属性**: **领取进度** - 标记已领取的epoch

## 权益类变量 (Equity)

### ❌ 无自有权益
bribe不留存奖励,所有notify的代币都分配给投票者。

### 准权益变量

#### 1. `first_bribe_timestamp: u64`
- **含义**: 第一次收到bribe的epoch时间戳
- **用途**: 作为claim的起始边界

#### 2. `is_reward_token: Table<address, bool>`
- **含义**: 标记哪些代币可作为奖励
- **权益属性**: **奖励白名单** - owner控制

#### 3. `reward_tokens: vector<address>`
- **含义**: 所有奖励代币列表

## 辅助管理变量

### 1. `owner: address`
- **含义**: bribe合约owner,可添加reward_token, recover资产

### 2. `voter: address`
- **含义**: 唯一可调用deposit/withdraw的voter合约

### 3. `gauge_address: address`
- **含义**: 关联的gauge地址

## 会计恒等式

### 主恒等式 (权重守恒)
```
total_supply[epoch] = sum(balance[user][epoch] for all users)
```

### 辅助恒等式

#### 1. 奖励资产 >= 负债
```
对于每个reward_token:
actual_balance(bribe_address, reward_token) >= sum(unclaimed_rewards)
```

#### 2. 用户奖励计算
```
user_reward_for_epoch = (balance[user][epoch] / total_supply[epoch]) * reward_data[token][epoch].rewards_per_epoch
```

#### 3. 精度系数
```
reward_per_token = (rewards_per_epoch * MULTIPLIER) / total_supply
user_reward = (balance * reward_per_token) / MULTIPLIER
```

## 潜在会计风险

### 1. total_supply与balance总和不匹配
- **场景**: voter调用deposit/withdraw时计算错误
- **检查点**: `deposit()` L532-561, `withdraw()` L574-606

### 2. 精度损失导致奖励累积
- **场景**: `earned_internal()` L1339-1353除法精度损失
- **后果**: 合约中会有无法领取的dust

### 3. 50周限制导致老用户无法完全领取
- **场景**: 用户超过50周未领取,单次只能领前50周
- **检查点**: `earned_with_timestamp_internal()` L1280循环`FIFTY_WEEKS`
- **缓解**: 用户可多次调用

### 4. notify未来epoch的奖励可被提前领取
- **场景**: notify写入next epoch,但total_supply用current epoch
- **检查点**: `notify_reward_amount()` L718, `start_timestamp = active_period() + WEEK`
- **安全性**: 正确,用户只能领取已结束epoch的奖励

### 5. reward_token未verify时notify成功
- **场景**: owner忘记add_reward_token,用户notify失败
- **检查点**: `notify_reward_amount()` L710 assert verify

## 待定科目

### 1. `user_reward_per_token_paid: Table<address, Table<address, u64>>`
- **类型**: Table<user, Table<reward_token, last_reward_per_token>>
- **含义**: 似乎未使用,代码中未见更新逻辑
- **会计属性**: **冗余字段?**

### 2. `extended_ref: ExtendRef`
- **含义**: 用于生成signer转账

## 总结

bribe是**多币种奖励型账套**:
- **资产**: 托管多种奖励代币(由`reward_data`记录每周分配量)
- **负债**: 对投票者的奖励债务(由`balance`和`total_supply`计算份额)
- **无自有权益**: 所有notify的代币都分配给用户

核心会计公式:
```
total_supply[epoch] = sum(balance[user][epoch])
user_reward = (balance / total_supply) * rewards_per_epoch
```

关键风险: **50周领取限制**和**精度损失**

