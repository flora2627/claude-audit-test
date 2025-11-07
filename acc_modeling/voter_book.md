# voter 模块账套

## 模块概述
voter 模块是投票权重分配中心,负责接收veNFT的投票,计算各pool的权重,分配emission奖励到各gauge。

## 资产类变量 (Assets)

### ✅ 持有临时资产

#### 1. 合约DXLYN余额
- **类型**: 通过 `primary_fungible_store::balance()` 查询
- **位置**: voter合约地址
- **含义**: voter合约接收的emission DXLYN,待分配给各gauge
- **会计属性**: **待分配资产** - 来自minter的weekly emission
- **增加场景**: `notify_reward_amount()` - minter每周调用
- **减少场景**: `distribute_internal()` - 分配给各gauge

## 负债类变量 (Liabilities)

### 1. `votes: Table<address, Table<address, u64>>`
- **类型**: Table<token, Table<pool, vote_weight>>
- **位置**: `Voter` struct
- **含义**: 记录每个veNFT对每个pool的投票权重
- **会计属性**: **权重分配记录** - 记录veNFT权力的分配去向
- **单位**: 10^12精度的投票权重(继承自voting_escrow的bias)

### 2. `pool_vote: Table<address, SmartVector<address>>`
- **类型**: Table<token, SmartVector<pool_addresses>>
- **位置**: `Voter` struct
- **含义**: 记录每个veNFT投票给了哪些pool
- **会计属性**: **投票关系索引**

### 3. `weights_per_epoch: Table<u64, Table<address, u64>>`
- **类型**: Table<timestamp, Table<pool, total_weight>>
- **位置**: `Voter` struct
- **含义**: 每个epoch各pool获得的总投票权重
- **会计属性**: **负债聚合** - 用于计算pool应得的emission份额
- **关键公式**: `weights_per_epoch[epoch][pool] = sum(votes[token][pool] for all tokens)`

### 4. `total_weights_per_epoch: Table<u64, u64>`
- **类型**: Table<timestamp, total_weight>
- **位置**: `Voter` struct
- **含义**: 每个epoch所有pool的总权重
- **会计属性**: **负债总额** - 用于计算每个pool的相对份额
- **关键公式**: `total_weights_per_epoch[epoch] = sum(weights_per_epoch[epoch][pool])`

### 5. `last_voted: Table<address, u64>`
- **类型**: Table<token, timestamp>
- **位置**: `Voter` struct
- **含义**: 每个veNFT上次投票的时间戳
- **会计属性**: **负债时间戳** - 用于防止频繁改票,执行vote_delay

### 6. `claimable: Table<address, u64>`
- **类型**: Table<gauge, dxlyn_amount>
- **位置**: `Voter` struct
- **含义**: 每个gauge已计算出但尚未分配的DXLYN奖励
- **会计属性**: **负债金额** - gauge应得但未领取的emission
- **增加场景**: `update_for_after_distribution()` - 根据权重计算
- **减少场景**: `distribute_internal()` - 转给gauge后清零

## 权益类变量 (Equity)

### 1. `index: u64`
- **类型**: u64
- **位置**: `Voter` struct
- **含义**: 全局累积的reward index(每次notify_reward_amount增加)
- **会计属性**: **累积收益率** - 用于计算增量奖励
- **计算公式**: `index += (amount * 1e8) / total_weight`
- **用途**: 通过index差值计算gauge应得的新奖励

### 2. `supply_index: Table<address, u64>`
- **类型**: Table<gauge, last_index>
- **位置**: `Voter` struct
- **含义**: 每个gauge上次同步时的index值
- **会计属性**: **分配检查点** - 用于计算增量奖励
- **用途**: `claimable[gauge] += (index - supply_index[gauge]) * pool_weight / 1e8`

### 准权益变量

#### 1. `gauges: Table<address, address>`
- **类型**: Table<pool, gauge_address>
- **位置**: `Voter` struct
- **含义**: pool到gauge的映射
- **会计属性**: **权益分配路由**

#### 2. `pool_for_gauge: Table<address, address>`
- **类型**: Table<gauge, pool>
- **位置**: `Voter` struct
- **含义**: gauge到pool的反向映射

#### 3. `is_alive: Table<address, bool>`
- **类型**: Table<gauge, is_alive>
- **位置**: `Voter` struct
- **含义**: gauge是否存活(被kill后为false)
- **会计属性**: **权益状态** - 死亡的gauge不再获得新奖励

#### 4. `is_whitelisted: Table<address, bool>`
- **类型**: Table<pool, is_whitelisted>
- **位置**: `Voter` struct
- **含义**: pool是否可以接收投票和奖励
- **会计属性**: **权益准入控制**

## 辅助管理变量

### 1. `owner: address`
- **含义**: 可创建gauge的owner

### 2. `voter_admin: address`
- **含义**: 可设置vote_delay, minter, external_bribe的管理员

### 3. `governance: address`
- **含义**: 可whitelist/blacklist pool, kill/revive gauge的治理地址

### 4. `minter: address`
- **含义**: 唯一可调用`notify_reward_amount()`的minter地址

### 5. `vote_delay: u64`
- **含义**: 两次投票之间的最小时间间隔(防止频繁改票)

### 6. `edit_vote_penalty: u64`
- **含义**: 同一epoch内改票的DXLYN惩罚金额

### 7. `pools: SmartVector<address>`
- **含义**: 所有pool的列表(用于distribute_all遍历)

### 8. `external_bribes: Table<address, address>`
- **类型**: Table<gauge, bribe_address>
- **含义**: 每个gauge对应的外部bribe合约

### 9. `gauges_distribution_timestamp: Table<address, u64>`
- **类型**: Table<gauge, last_distribution_time>
- **含义**: 每个gauge上次分配奖励的时间戳

### 10. `is_gauge: Table<address, bool>`
- **含义**: 地址是否是有效的gauge

### 11. `gauge_to_type: Table<address, u8>`
- **含义**: gauge类型(CPMM=0, CLMM=1, DXLP=2)

## 会计恒等式

### 主恒等式 (Emission分配守恒)
```
资产(voter合约DXLYN余额) = sum(claimable[gauge] for all gauges)
```
**说明**: voter合约的DXLYN应等于所有gauge待领取的总和

### 辅助恒等式

#### 1. 权重聚合正确性
```
total_weights_per_epoch[t] = sum(weights_per_epoch[t][pool] for all pools)
```

#### 2. 用户投票权重 vs pool权重
```
对于每个epoch t:
weights_per_epoch[t][pool] = sum(votes[token][pool] for all tokens voted in epoch t-1)
```
**说明**: epoch t的pool权重来自epoch t-1结束时的投票

#### 3. Index增量 vs 分配总额
```
Δindex * total_weight / 1e8 = notify_amount
```
**说明**: 每次notify时,index增量应等于分配金额

#### 4. Claimable计算正确性
```
claimable[gauge] = (index - supply_index[gauge]) * pool_weight[gauge] / 1e8
```
**说明**: gauge的claimable应等于index差值乘以权重

## 潜在会计风险

### 1. claimable总和超过合约余额
- **场景**: `notify_reward_amount()` 和 `update_for_after_distribution()` 计算不一致
- **检查点**: 精度损失累积导致claimable总和 > 实际转入的amount

### 2. killed gauge的权重仍被计算
- **场景**: gauge被kill后,已投票权重未从total_weights中扣除
- **检查点**: `kill_gauge()` 函数L677-685,会扣除total_weights

### 3. 同一epoch内改票的penalty未收取
- **场景**: 用户在同一epoch内改票,应收取penalty到fee_treasury
- **检查点**: `vote()` 函数L860-867

### 4. vote_delay绕过
- **场景**: 通过poke()或vote()绕过vote_delay限制
- **检查点**: `poke()` 和 `vote()` 都检查了vote_delay

### 5. 过期epoch的投票权重未清理
- **场景**: 旧epoch的weights_per_epoch占用存储,可能被错误使用
- **检查点**: 代码仅查询特定epoch,应无此风险

### 6. Index溢出
- **场景**: index持续累加,可能溢出u64
- **检查点**: 使用u64,最大值1.8e19,按每周增加1e8计算,可运行1e11周≈1.9e9年,无溢出风险

## 待定科目

### 1. `extended_ref: ExtendRef`
- **含义**: 用于生成voter_signer调用其他模块的friend函数
- **会计属性**: **跨模块权限** - 可调用voting_escrow.voting/abstain, bribe.deposit/withdraw, fee_distributor.burn_rebase

## 总结

voter模块是**权重分配型账套**:
- **资产**: 临时持有待分配的emission DXLYN
- **负债**: 记录各gauge应得的奖励(`claimable`)和各pool的投票权重(`weights_per_epoch`)
- **权益**: 控制emission的分配逻辑,通过`index`机制计算增量奖励

核心会计公式:
```
voter合约余额 ≈ sum(claimable[gauge])
claimable[gauge] = (index - supply_index[gauge]) * pool_weight / 1e8
```

