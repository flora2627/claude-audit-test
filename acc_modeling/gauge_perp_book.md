# gauge_perp 模块账套

## 模块概述
gauge_perp 是Perpetual DEX的流动性挖矿合约,用户质押DXLP代币赚取DXLYN。

**与gauge_cpmm的主要区别**: 
- gauge_cpmm质押AMM的LP token
- gauge_perp质押perpetual house的DXLP token

## 资产类变量 (Assets)

### 1. `total_supply: u64`
- **类型**: u64
- **位置**: `GaugePerp` struct
- **含义**: 质押在gauge中的DXLP代币总量
- **会计属性**: **托管资产总额**

### 2. 合约实际DXLP余额
- **类型**: `coin::balance<DXLP<AssetT>>(gauge_address)` 或 FA balance
- **位置**: gauge_perp合约地址
- **含义**: 合约实际持有的DXLP代币
- **会计属性**: **实际托管资产** - 应等于total_supply

### 3. 合约DXLYN余额
- **类型**: `primary_fungible_store::balance(gauge_address, dxlyn_metadata)`
- **含义**: 待分配的DXLYN奖励
- **会计属性**: **奖励资产**

## 负债类变量 (Liabilities)

### 1. `balance_of: Table<address, u64>`
- **类型**: Table<user_address, dxlp_amount>
- **含义**: 每个用户质押的DXLP数量
- **会计属性**: **负债明细**
- **恒等式**: `sum(balance_of[user]) = total_supply`

### 2. `rewards: Table<address, u64>`
- **类型**: Table<user_address, dxlyn_amount>
- **含义**: 用户待领取的DXLYN奖励
- **会计属性**: **奖励负债**

### 3. `user_reward_per_token_paid: Table<address, u256>`
- **类型**: Table<user, last_reward_per_token>
- **含义**: 用户上次同步的reward_per_token
- **会计属性**: **奖励检查点**

## 权益类变量 (Equity)

### 1. `reward_per_token_stored: u256`
- **含义**: 累积的每单位DXLP的DXLYN奖励
- **会计属性**: **累积收益率**

### 2. `reward_rate: u256`
- **含义**: 每秒的DXLYN奖励速率
- **会计属性**: **收益流量**

### 3. `period_finish: u64`, `last_update_time: u64`, `duration: u64`
- **含义**: 奖励周期参数

### 4. `emergency: bool`
- **含义**: 紧急模式开关

## 辅助管理变量

### 1. `reward_token: address`
- **含义**: DXLYN的FA地址

### 2. `distribution: address`
- **含义**: voter合约地址

### 3. `external_bribe: address`
- **含义**: bribe合约地址

### 4. `coin: address`
- **含义**: DXLP代币地址(根据AssetT类型确定)

### 5. `coin_type_name: String`
- **含义**: DXLP代币的类型名称

## 会计恒等式

### 主恒等式 (DXLP托管守恒)
```
total_supply = sum(balance_of[user] for all users)
```

### 辅助恒等式

#### 1. DXLP实际余额 = 账面余额
```
actual_dxlp_balance(gauge_address) = total_supply
```

#### 2. 奖励计算
```
pending_reward = balance_of[user] * (reward_per_token_stored - user_reward_per_token_paid[user]) / PRECISION + rewards[user]
```

#### 3. Reward_per_token更新
```
Δreward_per_token = (reward_rate * Δtime * PRECISION) / total_supply
```

## 潜在会计风险

### 1. total_supply与balance_of总和不一致
- **场景**: deposit/withdraw时更新顺序错误
- **检查点**: `deposit_internal()`, `withdraw_internal()`

### 2. 精度损失
- **场景**: reward_per_token的除法精度损失累积
- **检查点**: `reward_per_token_internal()`

### 3. total_supply为0时notify导致奖励丢失
- **场景**: 无人质押时notify,reward_per_token_stored无法更新
- **检查点**: 与gauge_cpmm相同的风险

### 4. Emergency模式提前提现
- **场景**: emergency_withdraw不计算奖励
- **检查点**: `emergency_withdraw()`

### 5. DXLP类型混淆
- **场景**: 多个AssetT的DXLP混用
- **检查点**: 每个gauge应绑定唯一的`DXLP<AssetT>`类型

## 待定科目
(与gauge_cpmm相同)

## 总结

gauge_perp是**DXLP质押奖励型账套**:
- **资产**: 托管的DXLP代币(total_supply)和待分配的DXLYN
- **负债**: 对用户的DXLP债务(balance_of)和DXLYN奖励债务(rewards)
- **权益**: 奖励分配逻辑(reward_per_token_stored)

核心会计公式:
```
total_supply = sum(balance_of[user])
pending_reward = balance_of * (reward_per_token_stored - user_paid) / PRECISION
```

**与gauge_cpmm/clmm的异同**: 结构完全一致,只是质押资产类型不同(DXLP vs LP vs NFT position)

