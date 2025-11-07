# fee_distributor 模块账套

## 模块概述
fee_distributor 负责将每周的rebase DXLYN按veNFT权重分配给持有者。

## 资产类变量 (Assets)

### 1. `token_last_balance: u64`
- **类型**: u64
- **位置**: `FeeDistributor` struct
- **含义**: 上次checkpoint后的DXLYN余额快照
- **会计属性**: **资产账面值** - 追踪已分配vs未分配的DXLYN
- **更新时机**: `checkpoint_token_internal()`

### 2. 合约实际DXLYN余额
- **类型**: `primary_fungible_store::balance(fee_dis_address, dxlyn_metadata)`
- **位置**: fee_distributor合约地址
- **含义**: 合约实际持有的DXLYN总量
- **会计属性**: **实际资产** - 应 >= token_last_balance
- **增加**: `burn()` / `burn_rebase()` - 接收rebase
- **减少**: `claim()` / `claim_many()` - 用户领取

### 3. `total_received: u64`
- **类型**: u64
- **位置**: `FeeDistributor` struct
- **含义**: 历史累计接收的DXLYN总量
- **会计属性**: **累积资产流入** - 仅增不减,用于审计

## 负债类变量 (Liabilities)

### 1. `tokens_per_week: Table<u64, u64>`
- **类型**: Table<week_timestamp, dxlyn_amount>
- **位置**: `FeeDistributor` struct
- **含义**: 每周可供分配的DXLYN总量
- **会计属性**: **每周负债总额** - 该周所有veNFT持有者的总claim权利
- **计算**: `checkpoint_token_internal()` 根据新收到的DXLYN按时间比例分配
- **公式**: 按周分摊新收到的DXLYN

### 2. `ve_supply: Table<u64, u64>`
- **类型**: Table<week_timestamp, ve_total_supply>
- **位置**: `FeeDistributor` struct
- **含义**: 每周的veNFT总权重(从voting_escrow同步)
- **会计属性**: **权重总额** - 用于计算用户claim的分母
- **来源**: `checkpoint_total_supply_internal()` 从`voting_escrow::total_supply(t)`获取
- **用途**: `user_claim = (user_ve_balance / ve_supply) * tokens_per_week`

### 3. `time_cursor_of: Table<address, u64>`
- **类型**: Table<token, last_claim_week>
- **位置**: `FeeDistributor` struct
- **含义**: 每个veNFT上次claim到哪一周
- **会计属性**: **负债进度** - 标记已领取的部分
- **用途**: 下次claim从此时间戳开始计算

### 4. `user_epoch_of: Table<address, u64>`
- **类型**: Table<token, user_epoch>
- **位置**: `FeeDistributor` struct
- **含义**: 每个veNFT在claim计算中使用的epoch索引
- **会计属性**: **负债计算状态**

## 权益类变量 (Equity)

### ❌ 无自有权益
fee_distributor不留存任何DXLYN,所有接收的代币都分配给veNFT持有者。

## 辅助管理变量

### 1. `start_time: u64`
- **含义**: fee_distributor启动时间(对齐到周)

### 2. `time_cursor: u64`
- **含义**: 全局checkpoint进度(已同步ve_supply到哪一周)

### 3. `last_token_time: u64`
- **含义**: 上次checkpoint_token的时间

### 4. `admin: address`, `future_admin: address`
- **含义**: 管理员地址

### 5. `can_checkpoint_token: bool`
- **含义**: 是否允许任何人调用checkpoint_token

### 6. `emergency_return: address`
- **含义**: kill合约后,DXLYN退回地址

### 7. `is_killed: bool`
- **含义**: 合约是否被终止

## 会计恒等式

### 主恒等式 (资产=负债)
```
token_last_balance = sum(tokens_per_week[week] for all weeks) - sum(user_claimed)
```
**说明**: 账面余额应等于已分配但未领取的总和

### 辅助恒等式

#### 1. 实际余额 >= 账面余额
```
primary_fungible_store::balance(fee_dis_address) >= token_last_balance
```
**说明**: 如果有新rebase未checkpoint,实际余额会更高

#### 2. 用户claim计算
```
user_claim_for_week = (user_ve_balance_at_week / ve_supply[week]) * tokens_per_week[week]
```

#### 3. 每周分配总额
```
sum(user_claim_for_week for all users) = tokens_per_week[week]
```
**风险**: 精度损失可能导致sum < tokens_per_week

#### 4. Tokens_per_week的时间分配
```
checkpoint_token时,新收到的DXLYN按时间比例分配到各周:
tokens_per_week[this_week] += to_distribute * (current_time - t) / since_last
```

## 潜在会计风险

### 1. tokens_per_week总和 vs token_last_balance不一致
- **场景**: checkpoint_token计算精度损失累积
- **检查点**: `checkpoint_token_internal()` L800-859

### 2. ve_supply未同步导致分配错误
- **场景**: claim时ve_supply滞后,用户获得过多/过少奖励
- **检查点**: `claim_internal()` 依赖`fee_dis.ve_supply[week_cursor]`

### 3. 50周限制导致老用户无法完整claim
- **场景**: 用户超过50周未claim,单次claim只能领取前50周
- **检查点**: `claim_internal()` L964循环限制`FIFTY_WEEKS`
- **缓解**: 用户可多次调用claim

### 4. 精度损失导致dust累积
- **场景**: 每周的精度损失累积,最终有DXLYN无法被claim
- **检查点**: `claim_internal()` L1001除法

### 5. killed合约后资产去向
- **场景**: kill_me后,所有DXLYN转给emergency_return,用户无法claim
- **检查点**: `kill_me()` L341-357

### 6. checkpoint_token的20周限制
- **场景**: 如果超过20周未checkpoint,会有DXLYN分配缺失
- **检查点**: `checkpoint_token_internal()` L814循环限制`TWENTY_WEEKS`

## 待定科目

### `extended_ref: ExtendRef`
- **含义**: 用于生成signer进行DXLYN转账

## 总结

fee_distributor是**分配型账套**:
- **资产**: 托管的rebase DXLYN(`token_last_balance`和合约余额)
- **负债**: 对veNFT持有者的claim权利(`tokens_per_week` / `ve_supply`)
- **无自有权益**: 所有接收的DXLYN都属于veNFT持有者

核心会计公式:
```
token_last_balance = sum(tokens_per_week[week]) - sum(已claim)
user_claim = (user_ve / ve_supply) * tokens_per_week
```

关键风险: **精度损失**和**周限制**可能导致部分DXLYN永久无法领取

