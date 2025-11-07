# dxlyn_coin 模块账套

## 模块概述
dxlyn_coin 是DXLYN代币的发行模块,持有初始分配储备,控制铸币和销毁权限。

## 资产类变量 (Assets)

### 1. `InitialSupply` 储备
- **类型**: InitialSupply struct
  ```move
  struct InitialSupply {
      ecosystem_grant: Coin<DXLYN>,      // 10%
      protocol_airdrop: Coin<DXLYN>,     // 20%
      private_round: Coin<DXLYN>,        // 2.5%
      genesis_liquidity: Coin<DXLYN>,    // 2.5%
      team: Coin<DXLYN>,                 // 15%
      foundation: Coin<DXLYN>,           // 20%
      community_airdrop: Coin<DXLYN>,    // 30%
  }
  ```
- **位置**: dxlyn_coin对象地址
- **含义**: 初始铸造的100M DXLYN中,预留给各用途的部分
- **会计属性**: **待分配资产** - 初始供应的各类储备
- **总量**: 100M * 10^8 = 10^16
- **分配**: 通过extract提取后转给对应地址

### 2. dxlyn_coin对象地址的余额
- **类型**: `primary_fungible_store::balance(dxlyn_coin_address, dxlyn_metadata)`
- **位置**: dxlyn_coin对象地址
- **含义**: init_module时deposit的剩余DXLYN(如果有)
- **会计属性**: **未分类资产** - L189 deposit了extract后的剩余部分

## 负债类变量 (Liabilities)

### ❌ 无负债
dxlyn_coin不欠用户,InitialSupply属于owner资产,可随时提取。

## 权益类变量 (Equity)

### 1. `CoinCaps`
- **类型**: CoinCaps struct
  ```move
  struct CoinCaps {
      mint_cap: MintCapability<DXLYN>,
      burn_cap: BurnCapability<DXLYN>,
      freeze_cap: FreezeCapability<DXLYN>,
  }
  ```
- **位置**: dxlyn_coin对象地址
- **含义**: DXLYN的铸币、销毁、冻结权限
- **会计属性**: **核心权益** - 控制DXLYN供应的终极权力
- **访问**: 仅minter(被设为minter后)可调用mint

### 2. `owner: address` (在DxlynInfo)
- **含义**: dxlyn_coin的owner,可提取InitialSupply

### 3. `minter: address` (在DxlynInfo)
- **含义**: 唯一可调用mint的minter地址(通常是minter模块)

### 4. `paused: bool` (在DxlynInfo)
- **含义**: mint是否暂停

## 辅助管理变量

### 1. `future_owner: address`, `future_minter: address`
- **含义**: 待接管的owner和minter

## 会计恒等式

### 主恒等式 (Initial Supply分配)
```
INITIAL_SUPPLY = ecosystem_grant + protocol_airdrop + private_round +
                 genesis_liquidity + team + foundation + community_airdrop
```
**验证**: 10% + 20% + 2.5% + 2.5% + 15% + 20% + 30% = 100% ✓

### 辅助恒等式

#### 1. DXLYN总供应量
```
total_supply = INITIAL_SUPPLY + sum(minted) - sum(burned)
```
**说明**: 100M初始 + emission铸币 - 销毁

#### 2. InitialSupply余额
```
sum(InitialSupply各字段的coin::value()) = 未提取的初始供应
```

## 潜在会计风险

### 1. InitialSupply无提取函数
- **场景**: init_module后InitialSupply锁在合约,无entry函数提取
- **检查点**: 代码中未见`withdraw_initial_supply()`之类的函数
- **后果**: 这100M DXLYN可能永久锁定
- **建议**: 检查是否有admin函数提取

### 2. Mint权限被滥用
- **场景**: minter恶意铸造超额DXLYN
- **检查点**: minter模块必须忠实执行emission曲线
- **保护**: minter应为不可升级合约,或有timelock

### 3. Paused状态可被随意切换
- **场景**: owner可pause阻止minter铸币
- **检查点**: `pause()` / `unpause()` L276-300

### 4. Burn_cap未使用
- **场景**: 代码中未见burn函数,burn_cap可能未使用
- **检查点**: 搜索`coin::burn`

## 待定科目

### `extend_ref: ExtendRef` (在DxlynInfo)
- **含义**: 用于生成signer进行资产操作

## 总结

dxlyn_coin是**代币发行中心**:
- **资产**: InitialSupply储备(100M DXLYN)
- **无负债**: 储备属于owner资产
- **权益**: 铸币/销毁权限(CoinCaps)

核心会计公式:
```
total_supply = 100M + emission_minted - burned
InitialSupply = 100M (10%+20%+2.5%+2.5%+15%+20%+30%)
```

关键风险: **InitialSupply可能无提取函数**, **mint权限需严格控制**

