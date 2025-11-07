# voting_escrow 模块账套

## 模块概述
voting_escrow 模块是锁仓托管主体,用户锁定DXLYN获得veNFT,veNFT代表时间衰减的投票权。

## 资产类变量 (Assets)

### 1. `supply: u64`
- **类型**: u64
- **位置**: `VotingEscrow` struct
- **含义**: 当前所有有效锁仓的DXLYN总量(不含已过期未提取的)
- **会计属性**: **资产总额** - 代表合约托管的DXLYN总量
- **增加场景**: create_lock, increase_amount, merge
- **减少场景**: withdraw, merge(from_token)

### 2. 合约实际DXLYN余额
- **类型**: 通过 `primary_fungible_store::balance()` 查询
- **位置**: voting_escrow合约地址
- **含义**: 合约地址实际持有的DXLYN FungibleAsset数量
- **会计属性**: **实际资产** - 应等于supply(如无过期未提取的锁仓)
- **备注**: 如有过期锁仓未提取,实际余额可能>supply

## 负债类变量 (Liabilities)

### 1. `locked: Table<address, LockedBalance>`
- **类型**: Table<address, LockedBalance>
  ```move
  struct LockedBalance {
      amount: u64,
      end: u64
  }
  ```
- **位置**: `VotingEscrow` struct
- **含义**: 每个veNFT(由token地址标识)的锁仓记录
- **会计属性**: **负债明细** - 对每个veNFT持有者的DXLYN债务
- **关键字段**:
  - `amount`: 锁仓的DXLYN数量
  - `end`: 锁仓到期时间戳(unix秒)

### 2. `user_point_history: Table<address, Table<u64, Point>>`
- **类型**: Table<address, Table<u64, Point>>
  ```move
  struct Point {
      bias: u64,    // 当前时刻的投票权(衰减后)
      slope: u64,   // 投票权衰减速率
      ts: u64,      // 时间戳
      blk: u64      // 区块高度
  }
  ```
- **位置**: `VotingEscrow` struct
- **含义**: 每个veNFT的投票权历史快照
- **会计属性**: **负债衍生物** - 基于锁仓amount和end计算的权重,用于投票和奖励分配
- **计算公式**: `bias = amount * (end - current_time) / MAXTIME * AMOUNT_SCALE`

### 3. `user_point_epoch: Table<address, u64>`
- **类型**: Table<address, u64>
- **位置**: `VotingEscrow` struct
- **含义**: 每个veNFT的checkpoint epoch计数器
- **会计属性**: **负债索引** - 用于快速查找最新的user_point_history

### 4. `voted: Table<address, bool>`
- **类型**: Table<address, bool>
- **位置**: `VotingEscrow` struct
- **含义**: 标记veNFT是否正在参与投票
- **会计属性**: **负债状态** - voted=true时,veNFT不可转移/合并/分割/提取
- **控制逻辑**: 由voter模块通过friend权限调用`voting()`和`abstain()`修改

## 权益类变量 (Equity)

### ❌ 无典型权益变量
voting_escrow模块**不控制手续费收入或协议盈余**,仅作为托管中介,因此无独立的权益类变量。

但以下变量与治理权益相关:

### 准权益变量

#### 1. `point_history: Table<u64, Point>`
- **类型**: Table<u64, Point>
- **位置**: `VotingEscrow` struct
- **含义**: 全局投票权总量的历史快照
- **会计属性**: **总权益代理** - 代表所有veNFT持有者的总投票权
- **用途**: 用于fee_distributor计算每个epoch的veNFT总权重

#### 2. `epoch: u64`
- **类型**: u64
- **位置**: `VotingEscrow` struct
- **含义**: checkpoint的epoch计数器
- **会计属性**: **时间索引**

#### 3. `slope_changes: Table<u64, SlopeChange>`
- **类型**: Table<u64, SlopeChange>
  ```move
  struct SlopeChange {
      slope: u64,
      is_negative: bool
  }
  ```
- **位置**: `VotingEscrow` struct
- **含义**: 记录未来每周的slope变化量(用于提前计算投票权衰减)
- **会计属性**: **未来负债变动预测**

## 辅助管理变量

### 1. `admin: address`
- **类型**: address
- **位置**: `VotingEscrow` struct
- **含义**: 合约管理员地址
- **权限**: 可以set_voter, commit/apply ownership transfer

### 2. `future_admin: address`
- **类型**: address
- **位置**: `VotingEscrow` struct
- **含义**: 待接管的管理员地址

### 3. `voter: address`
- **类型**: address
- **位置**: `VotingEscrow` struct
- **含义**: voter合约地址,唯一可调用`voting()`/`abstain()`的friend
- **权限边界**: voter模块可修改`voted`状态和NFT transfer权限

### 4. `extended_ref: ExtendRef`
- **类型**: ExtendRef
- **位置**: `VotingEscrow` struct
- **含义**: 对象扩展引用,用于生成signer进行资产转移

### 5. NFT相关
- `collection_extend_ref: ExtendRef`
- `mutator_ref: MutatorRef`
- `token_id: u64` - NFT的序列号生成器

## 会计恒等式

### 主恒等式 (Primary Identity)
```
资产 = 负债

supply = sum(locked[token].amount for all token where locked[token].end > 0)
```

### 辅助恒等式

#### 1. 实际余额 vs supply
```
primary_fungible_store::balance(voting_escrow_address) >= supply
```
**说明**: 如果存在已过期但未提取的锁仓,实际余额会大于supply

#### 2. Point计算正确性
```
对于任意token:
user_point[token].bias = locked[token].amount * AMOUNT_SCALE / MAXTIME * (locked[token].end - current_time)
user_point[token].slope = locked[token].amount * AMOUNT_SCALE / MAXTIME
```

#### 3. 全局point vs 用户point总和
```
point_history[epoch].bias ≈ sum(user_point_history[token][user_epoch].bias for all active tokens)
point_history[epoch].slope ≈ sum(user_point_history[token][user_epoch].slope for all active tokens)
```
**说明**: 由于checkpoint异步性,可能存在轻微偏差

## 潜在会计风险

### 1. supply不等于locked总和
- **场景**: withdraw()时先减locked再减supply,如果中途revert,可能不一致
- **检查点**: `withdraw()` 函数L724-730

### 2. merge导致supply计算错误
- **场景**: merge()先减from_token的supply,再deposit_for(),如果deposit失败,supply会少
- **检查点**: `merge()` 函数L595

### 3. 过期锁仓的资产滞留
- **场景**: 用户不提取过期锁仓,DXLYN永久锁在合约
- **检查点**: 无自动sweep机制

### 4. checkpoint异步导致point不同步
- **场景**: 用户操作后未立即checkpoint,全局point_history可能滞后
- **检查点**: `checkpoint_internal()` 调用时机

## 待定科目

### `TokenRef` 资源
- **类型**: 每个veNFT token地址下的独立资源
  ```move
  struct TokenRef {
      burn_ref: BurnRef,
      transfer_ref: TransferRef,
  }
  ```
- **含义**: NFT的销毁和转移权限引用
- **会计属性**: **负债控制权** - 用于在用户提取/合并时销毁NFT
- **分类理由**: 不直接代表资产或负债,是对负债(NFT)的操作权限

## 总结

voting_escrow模块是典型的**托管型账套**:
- **资产**: 锁定的DXLYN代币(`supply`和合约余额)
- **负债**: 对veNFT持有者的DXLYN债务(`locked`表)
- **无自有权益**: 合约不留存任何手续费或收益

核心会计公式: **锁仓DXLYN总量 = 所有veNFT的locked.amount总和**

