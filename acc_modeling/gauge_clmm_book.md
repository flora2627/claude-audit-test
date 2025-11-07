# gauge_clmm 模块账套

## 模块概述
gauge_clmm 是CLMM(集中流动性做市商)的流动性挖矿合约,用户质押position NFT赚取DXLYN。

**与gauge_cpmm的主要区别**: 
- gauge_cpmm质押Coin类型的LP token
- gauge_clmm质押NFT position,按liquidity计量

## 资产类变量 (Assets)

### 1. `tokens: vector<address>`
- **类型**: vector<nft_token_address>
- **位置**: `GaugeClmm` struct
- **含义**: 质押在gauge中的position NFT地址列表
- **会计属性**: **托管NFT资产** - 用户的position NFT

### 2. `total_supply: u128`
- **类型**: u128 (注意是u128,因为liquidity可能很大)
- **位置**: `GaugeClmm` struct
- **含义**: 所有质押position的liquidity总和
- **会计属性**: **流动性总额** - 以liquidity计量的质押总量
- **增加**: `deposit()` - 添加position的liquidity
- **减少**: `withdraw()` - 移除position的liquidity

### 3. 合约DXLYN余额
- **类型**: `primary_fungible_store::balance(gauge_address, dxlyn_metadata)`
- **含义**: 待分配的DXLYN奖励
- **会计属性**: **奖励资产**

## 负债类变量 (Liabilities)

### 1. `balance_of: Table<address, u128>`
- **类型**: Table<user_address, total_liquidity>
- **含义**: 每个用户质押的liquidity总和
- **会计属性**: **流动性负债** - 对用户的liquidity债务
- **恒等式**: `sum(balance_of[user]) = total_supply`

### 2. `user_tokens: Table<address, vector<address>>`
- **类型**: Table<user, vector<nft_addresses>>
- **含义**: 每个用户质押的position NFT列表
- **会计属性**: **NFT负债明细**

### 3. `token_ids: Table<address, u128>`
- **类型**: Table<nft_address, liquidity>
- **含义**: 每个position NFT的liquidity
- **会计属性**: **NFT流动性映射**

### 4. `rewards: Table<address, u64>`
- **类型**: Table<user_address, dxlyn_amount>
- **含义**: 用户待领取的DXLYN奖励
- **会计属性**: **奖励负债**

### 5. `user_reward_per_token_paid: Table<address, u256>`
- **类型**: Table<user, last_reward_per_token>
- **含义**: 用户上次同步的reward_per_token
- **会计属性**: **奖励检查点**

## 权益类变量 (Equity)

### 1. `reward_per_token_stored: u256`
- **含义**: 累积的每单位liquidity的DXLYN奖励
- **会计属性**: **累积收益率**

### 2. `reward_rate: u256`
- **含义**: 每秒的DXLYN奖励速率
- **会计属性**: **收益流量**

### 3. `period_finish: u64`, `last_update_time: u64`, `duration: u64`
- **含义**: 奖励周期参数

### 4. `emergency: bool`
- **含义**: 紧急模式开关

## 辅助管理变量
(与gauge_cpmm相同,略)

## 会计恒等式

### 主恒等式
```
total_supply = sum(balance_of[user] for all users)
total_supply = sum(token_ids[nft] for all nfts)
```

### 辅助恒等式

#### 1. 用户liquidity = NFT liquidity总和
```
balance_of[user] = sum(token_ids[nft] for nft in user_tokens[user])
```

#### 2. 奖励计算
```
pending_reward = balance_of[user] * (reward_per_token_stored - user_reward_per_token_paid[user]) / PRECISION + rewards[user]
```

## 潜在会计风险

### 1. NFT的liquidity可变
- **场景**: CLMM position的liquidity可通过add/remove liquidity改变,但gauge中的token_ids不更新
- **检查点**: 代码是否在deposit时snapshot liquidity,还是动态查询
- **风险**: 如果用户在外部增加了liquidity,gauge中的计量未更新,奖励计算错误

### 2. U128溢出
- **场景**: total_supply使用u128,是否有溢出保护
- **检查点**: u128最大3.4e38,CLMM liquidity通常<1e38,应无风险

### 3. NFT所有权变更
- **场景**: 用户在质押后转移NFT所有权,gauge中未感知
- **检查点**: withdraw时检查`object::owner(nft) == user`
- **保护**: L491 `assert_token_owner()`

### 4. Position被外部关闭
- **场景**: NFT position在CLMM pool中被close,liquidity归零
- **检查点**: gauge应检查position有效性
- **风险**: gauge中的token_ids[nft]可能>实际liquidity

## 待定科目
(与gauge_cpmm相同)

## 总结

gauge_clmm是**NFT质押奖励型账套**:
- **资产**: 托管的position NFT(tokens列表)和对应的liquidity(total_supply)
- **负债**: 对用户的liquidity债务(balance_of)和DXLYN奖励债务(rewards)
- **权益**: 奖励分配逻辑(reward_per_token_stored)

核心会计公式:
```
total_supply = sum(token_ids[nft])
balance_of[user] = sum(token_ids[nft] for user's nfts)
```

关键风险: **position liquidity可变性**, **NFT所有权检查**

