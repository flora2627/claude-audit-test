# gauge_cpmm 模块账套

## 模块概述
gauge_cpmm 是CPMM(恒定乘积做市商)的流动性挖矿合约,用户质押LP代币赚取DXLYN emission奖励。

## 资产类变量 (Assets)

### 1. `total_supply: u64`
- **类型**: u64
- **位置**: `GaugeCpmm` struct
- **含义**: 质押在gauge中的LP代币总量
- **会计属性**: **托管资产总额** - gauge托管的LP代币数量
- **增加**: `deposit()` - 用户质押LP
- **减少**: `withdraw()` / `emergency_withdraw()` - 用户提取LP

### 2. 合约实际LP余额
- **类型**: 根据LP类型查询(Coin或FA)
- **位置**: gauge_cpmm合约地址
- **含义**: 合约实际持有的LP代币
- **会计属性**: **实际托管资产** - 应等于total_supply

### 3. 合约DXLYN余额
- **类型**: `primary_fungible_store::balance(gauge_address, dxlyn_metadata)`
- **位置**: gauge_cpmm合约地址
- **含义**: gauge托管的待分配DXLYN奖励
- **会计属性**: **奖励资产** - 来自voter的emission
- **增加**: `notify_reward_amount()` - voter每周调用
- **减少**: `get_reward()` - 用户领取奖励

## 负债类变量 (Liabilities)

### 1. `balance_of: Table<address, u64>`
- **类型**: Table<user_address, lp_amount>
- **位置**: `GaugeCpmm` struct
- **含义**: 每个用户质押的LP数量
- **会计属性**: **负债明细** - 对每个用户的LP债务
- **恒等式**: `sum(balance_of[user]) = total_supply`

### 2. `rewards: Table<address, u64>`
- **类型**: Table<user_address, dxlyn_amount>
- **位置**: `GaugeCpmm` struct
- **含义**: 每个用户已计算但未领取的DXLYN奖励
- **会计属性**: **奖励负债** - 对用户的DXLYN债务
- **更新**: `update_reward()` modifier在每次操作时更新
- **计算**: `rewards[user] += balance_of[user] * (reward_per_token_stored - user_reward_per_token_paid[user])`

### 3. `user_reward_per_token_paid: Table<address, u256>`
- **类型**: Table<user_address, last_reward_per_token>
- **位置**: `GaugeCpmm` struct
- **含义**: 每个用户上次同步时的reward_per_token值
- **会计属性**: **负债检查点** - 用于计算增量奖励

## 权益类变量 (Equity)

### 1. `reward_per_token_stored: u256`
- **类型**: u256 (精度PRECISION=10000)
- **位置**: `GaugeCpmm` struct
- **含义**: 累积的每单位LP可获得的DXLYN奖励
- **会计属性**: **累积收益率** - 全局奖励索引
- **计算**: `reward_per_token_stored += (new_rewards * PRECISION) / total_supply`

### 2. `reward_rate: u256`
- **类型**: u256
- **位置**: `GaugeCpmm` struct
- **含义**: 每秒分配的DXLYN奖励速率
- **会计属性**: **收益流量** - 用于计算时间加权奖励
- **计算**: `reward_rate = reward_amount / duration(1周)`

### 3. `period_finish: u64`
- **类型**: u64
- **位置**: `GaugeCpmm` struct
- **含义**: 当前奖励期结束时间戳
- **会计属性**: **奖励期限**

### 4. `last_update_time: u64`
- **类型**: u64
- **位置**: `GaugeCpmm` struct
- **含义**: 上次更新reward_per_token_stored的时间
- **会计属性**: **收益更新点**

## 辅助管理变量

### 1. `emergency: bool`
- **含义**: 是否处于紧急模式(emergency时只能emergency_withdraw,无奖励)

### 2. `reward_token: address`
- **含义**: 奖励代币地址(DXLYN的FA地址)

### 3. `distribution: address`
- **含义**: 唯一可调用notify_reward_amount的distributor(voter)

### 4. `external_bribe: address`
- **含义**: 关联的外部bribe合约地址

### 5. `duration: u64`
- **含义**: 奖励分配周期(1周=604800秒)

### 6. `lp_type_name: String`
- **含义**: LP代币的类型名称(用于识别是Coin还是FA)

### 7. `lp_coin: address`
- **含义**: LP代币的地址(pool address)

## 会计恒等式

### 主恒等式 (LP托管守恒)
```
total_supply = sum(balance_of[user] for all users)
```

### 辅助恒等式

#### 1. LP实际余额 = 账面余额
```
actual_lp_balance(gauge_address) = total_supply
```

#### 2. 奖励计算正确性
```
对于任意用户:
pending_reward = balance_of[user] * (reward_per_token_stored - user_reward_per_token_paid[user]) / PRECISION + rewards[user]
```

#### 3. Reward_per_token更新
```
Δreward_per_token = (reward_rate * Δtime * PRECISION) / total_supply
```

#### 4. 已分配奖励 <= 通知奖励
```
sum(rewards[user]) + sum(已领取) <= sum(notify_amount)
```

#### 5. 合约DXLYN余额 >= 待领取奖励
```
primary_fungible_store::balance(gauge_address, dxlyn) >= sum(rewards[user])
```

## 潜在会计风险

### 1. total_supply与balance_of总和不一致
- **场景**: deposit/withdraw时更新顺序错误
- **检查点**: `deposit_internal()` L437-479, `withdraw_internal()` L499-548

### 2. 精度损失导致奖励无法完全领取
- **场景**: reward_per_token的除法精度损失累积
- **检查点**: `reward_per_token_internal()` L707除法

### 3. reward_rate溢出
- **场景**: notify_reward_amount传入过大的reward导致reward_rate溢出
- **检查点**: `notify_reward_amount()` L581,使用u256,溢出检查`ERROR_REWARD_TOO_HIGH`

### 4. total_supply为0时notify导致奖励丢失
- **场景**: 无人质押时notify,reward_per_token_stored无法更新,奖励累积到合约
- **检查点**: `reward_per_token_internal()` L704-710,total_supply=0时返回当前值不更新
- **后果**: 后续用户会分享这些"免费"奖励

### 5. emergency模式提前提现导致奖励丢失
- **场景**: emergency_withdraw不计算奖励,用户损失
- **检查点**: `emergency_withdraw()` L564-596

### 6. 奖励期重叠导致reward_rate计算错误
- **场景**: 新的notify在旧期未结束时调用
- **检查点**: `notify_reward_amount()` L581-615,会计算leftover并累加

## 待定科目

### 1. `extend_ref: ExtendRef`
- **含义**: 用于生成signer进行资产转移
- **会计属性**: **资产操作权**

### 2. `pool: address`
- **含义**: 关联的CPMM pool地址
- **会计属性**: **LP来源标识**

## 总结

gauge_cpmm是**质押奖励型账套**:
- **资产**: 托管的LP代币(`total_supply`)和待分配的DXLYN
- **负债**: 对用户的LP债务(`balance_of`)和DXLYN奖励债务(`rewards`)
- **权益**: 通过`reward_per_token_stored`和`reward_rate`控制奖励分配逻辑

核心会计公式:
```
total_supply = sum(balance_of[user])
pending_reward = balance_of * (reward_per_token_stored - user_paid) / PRECISION
```

关键风险: **precision损失**和**total_supply=0时的notify**

