# Dexlyn Tokenomics 会计主体识别表

## 分析日期
2025-11-06

## 系统概述
Dexlyn Tokenomics 是一个基于 Move 语言的 ve-tokenomics 系统,包含投票锁仓、奖励分配、流动性挖矿等模块。

## 会计主体识别结果

| 模块名 | 有资产？ | 有负债？ | 有权益？ | 是否拆分账目 | 合约入口 | 说明备注 |
|--------|----------|----------|----------|--------------|----------|----------|
| **dxlyn_coin** | ✅ | ❌ | ✅ | 是 | `dxlyn_coin::mint()`, `dxlyn_coin::burn()` | 代币发行模块,持有未分配的初始代币(InitialSupply),控制铸币权(mint_cap) |
| **voting_escrow** | ✅ | ✅ | ❌ | 是 | `voting_escrow::create_lock()`, `voting_escrow::withdraw()` | 托管用户锁仓的DXLYN(资产),记录每个veNFT的锁仓量和到期时间(负债),supply字段追踪总锁仓 |
| **voter** | ❌ | ✅ | ✅ | 是 | `voter::vote()`, `voter::distribute_all()` | 不直接持有资产,但管理投票权重(负债)和emission分配权(权益),claimable记录各gauge应得奖励 |
| **emission** | ❌ | ❌ | ✅ | 是 | `emission::weekly_emission()` | 不持有资产,只计算和记录排放曲线,控制emission规则(权益) |
| **minter** | ✅ | ❌ | ✅ | 是 | `minter::calculate_rebase_gauge()` | 托管待分配的DXLYN(通过mint),控制铸币权和分配逻辑(权益) |
| **fee_distributor** | ✅ | ✅ | ❌ | 是 | `fee_distributor::claim()`, `fee_distributor::burn()` | 托管rebase奖励DXLYN(资产),记录用户claim权利(tokens_per_week,ve_supply)(负债) |
| **bribe** | ✅ | ✅ | ❌ | 是 | `bribe::notify_reward_amount()`, `bribe::get_reward()` | 托管贿赂代币(reward_data)(资产),记录用户voting power和应得奖励(balance, rewards)(负债) |
| **gauge_cpmm** | ✅ | ✅ | ❌ | 是 | `gauge_cpmm::deposit()`, `gauge_cpmm::get_reward()` | 托管用户的CPMM LP代币(total_supply)(资产),记录用户份额和待领取奖励(balance_of, rewards)(负债) |
| **gauge_clmm** | ✅ | ✅ | ❌ | 是 | `gauge_clmm::deposit()`, `gauge_clmm::get_reward()` | 托管用户的CLMM NFT position(tokens,total_supply)(资产),记录用户份额和待领取奖励(balance_of, rewards)(负债) |
| **gauge_perp** | ✅ | ✅ | ❌ | 是 | `gauge_perp::deposit()`, `gauge_perp::get_reward()` | 托管用户的DXLP代币(total_supply)(资产),记录用户份额和待领取奖励(balance_of, rewards)(负债) |
| **vesting** | ✅ | ✅ | ❌ | 是 | `vesting::create_vesting_contract()`, `vesting::vest()` | 托管待释放的DXLYN(vesting合约余额)(资产),记录股东的vesting记录(VestingRecord)(负债) |
| **base64** | ❌ | ❌ | ❌ | 否 | N/A | 纯工具库,无会计要素 |
| **i64** | ❌ | ❌ | ❌ | 否 | N/A | 纯工具库,无会计要素 |

## 会计主体说明

### 1. dxlyn_coin (代币铸造中心)
- **资产**: `InitialSupply` 结构中未分配的各类代币储备
- **权益**: 铸币权(mint_cap)和销毁权(burn_cap)的控制权
- **核心功能**: 代币的创建、销毁和初始分配

### 2. voting_escrow (锁仓托管主体)
- **资产**: 用户锁仓的DXLYN总量(`supply`字段,实际代币在合约地址)
- **负债**: 用户的veNFT代表的锁仓记录(`locked: Table<address, LockedBalance>`)
- **恒等关系**: `supply = sum(locked[token].amount)`
- **核心功能**: 时间加权的投票权管理

### 3. voter (投票权重分配中心)
- **负债**: 记录每个pool的投票权重(`weights_per_epoch`, `votes`)
- **权益**: 控制emission的分配权(`claimable`记录各gauge应得奖励)
- **核心功能**: 将veNFT的投票权转化为gauge的奖励权重

### 4. emission (排放计算引擎)
- **权益**: 控制代币排放曲线和衰减规则
- **核心功能**: 计算每周应排放的DXLYN数量,不直接持有资产

### 5. minter (铸币分配主体)
- **资产**: 通过铸币权临时持有待分配的DXLYN
- **权益**: 控制每周的rebase和gauge emission铸造
- **核心功能**: 执行emission模块计算的铸币,并分配给fee_distributor和voter

### 6. fee_distributor (手续费分配主体)
- **资产**: 托管的rebase DXLYN(`token_last_balance`,合约实际余额)
- **负债**: 用户基于veNFT的claim权利(`tokens_per_week`, `ve_supply`, `time_cursor_of`)
- **恒等关系**: `sum(user_claimable) ≤ total_received`
- **核心功能**: 按veNFT权重分配rebase奖励

### 7. bribe (贿赂激励主体)
- **资产**: 托管的各种贿赂代币(`reward_data`)
- **负债**: 用户的voting power(`balance`)和待领取奖励(`rewards`)
- **恒等关系**: `sum(user_rewards[token]) ≤ reward_data[token].rewards_per_epoch`
- **核心功能**: 激励用户投票给特定pool

### 8. gauge_cpmm/clmm/perp (流动性挖矿主体)
- **资产**: 托管用户的LP代币或NFT position(`total_supply`)
- **负债**: 用户的质押份额(`balance_of`)和待领取的DXLYN奖励(`rewards`)
- **恒等关系**: `sum(balance_of[user]) = total_supply` , `sum(rewards[user]) ≤ notified_rewards`
- **核心功能**: 按LP份额分配DXLYN emission奖励

### 9. vesting (代币释放主体)
- **资产**: 托管待释放的DXLYN(vesting合约余额)
- **负债**: 各股东的vesting记录(`VestingRecord: init_amount, left_amount`)
- **恒等关系**: `sum(left_amount[shareholders]) ≤ contract_balance`
- **核心功能**: 线性释放锁定的DXLYN给预设的股东

### 10. base64 & i64 (工具库)
- **无会计要素**: 纯粹的编码/解码工具,不涉及资产流转

## 跨主体资金流向关系

```
dxlyn_coin (铸币) 
    ↓ mint
minter (分配枢纽)
    ↓ rebase → fee_distributor (按veNFT分配)
    ↓ gauge  → voter → gauge_cpmm/clmm/perp (按投票权重分配)

用户 DXLYN 
    ↓ lock
voting_escrow (获得veNFT)
    ↓ vote
voter (投票给pool)
    ↓ deposit to gauge
gauge_* (质押LP,赚取emission)

外部用户
    ↓ notify
bribe (贿赂特定pool的投票者)

dxlyn_coin
    ↓ initial supply
vesting (线性释放给股东)
```

## 关键会计风险点

1. **voting_escrow**: `supply` 是否等于所有 `locked[token].amount` 之和
2. **voter**: `claimable[gauge]` 的累计是否超过minter实际铸造量
3. **fee_distributor**: `tokens_per_week` 的分配是否与 `ve_supply` 保持比例
4. **bribe**: 每个epoch的 `reward_data` 是否与用户 `rewards` 的总和匹配
5. **gauge_***: `total_supply` 是否等于所有用户 `balance_of` 之和
6. **vesting**: 股东 `left_amount` 总和是否超过合约实际余额

## 审计重点

根据会计主体拆分,重点关注:
- 各主体内部的资产=负债恒等式
- 跨主体的代币流转是否闭环(minter→voter→gauge,minter→fee_distributor)
- 份额计算的精度损失是否累积成攻击面
- epoch边界的状态更新一致性(weekly的checkpoint机制)
- friend权限边界是否被滥用(voter可调用voting_escrow.voting/abstain)

