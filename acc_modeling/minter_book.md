# minter 模块账套

## 模块概述
minter 控制DXLYN的铸造和分配,每周计算rebase和emission,分别给fee_distributor和voter。

## 资产类变量 (Assets)

### 1. 临时持有待分配的DXLYN
- **类型**: 通过mint_cap临时铸造,立即转出
- **位置**: minter在`calculate_rebase_gauge()`中铸造
- **含义**: 每周铸造的DXLYN,用于rebase和emission
- **会计属性**: **流动资产** - 瞬时持有,立即分配
- **来源**: `dxlyn_coin::mint()` via mint_cap
- **去向**: 
  - rebase → fee_distributor
  - emission → voter

## 负债类变量 (Liabilities)

### ❌ 无负债
minter不记录对外部的债务,只执行铸造和转发。

## 权益类变量 (Equity)

### 1. `period: u64`
- **类型**: u64
- **位置**: `DxlynInfo` struct
- **含义**: 当前周期时间戳(对齐到周)
- **会计属性**: **控制权益** - 决定每周emission的触发时间
- **更新**: `calculate_rebase_gauge()` 每周更新

### 2. emission模块的EmissionSchedule
- **类型**: `EmissionSchedule` (在emission模块)
- **含义**: 排放曲线和衰减规则
- **会计属性**: **铸币权益** - 控制铸币速率
- **访问**: minter通过friend关系调用`emission::weekly_emission()`

### 3. mint_cap (在dxlyn_coin)
- **类型**: `MintCapability<DXLYN>`
- **位置**: dxlyn_coin模块的CoinCaps
- **含义**: DXLYN铸币权
- **会计属性**: **核心权益** - minter被设为dxlyn_coin的minter后可铸币

## 辅助管理变量

### 1. `owner: address`
- **含义**: minter owner

### 2. `vesting_admin: address`
- **含义**: vesting模块的admin地址

### 3. `is_initialized: bool`
- **含义**: 是否已完成first_mint初始化

### 4. `asset_object_address: address`
- **含义**: DXLYN FA的对象地址

### 5. `extend_ref: ExtendRef`
- **含义**: 用于生成signer调用emission和dxlyn_coin

## 会计恒等式

### 主恒等式 (Emission分配守恒)
```
weekly_emission = rebase + emission_to_voter
```

### 辅助恒等式

#### 1. Rebase计算
```
rebase = weekly_emission * (1 - (ve_supply / dxlyn_supply))^2 * 0.5
```
**说明**: ve锁仓率越高,rebase越少,emission_to_voter越多

#### 2. Emission to voter
```
emission_to_voter = weekly_emission - rebase
```

#### 3. Weekly_emission来源
```
weekly_emission = emission::weekly_emission(minter_address)
```
**说明**: 由emission模块的衰减曲线计算

## 潜在会计风险

### 1. rebase + emission_to_voter != weekly_emission
- **场景**: 精度损失导致分配总和偏离铸造量
- **检查点**: `calculate_rebase_gauge()` 函数计算逻辑
- **后果**: 可能有dust留在minter,或分配超额

### 2. ve_supply / dxlyn_supply溢出或精度问题
- **场景**: ve_supply > dxlyn_supply导致计算异常
- **检查点**: `estimated_rebase()` 使用u256计算,但voting_escrow的supply是scaled(10^12),dxlyn是10^8
- **风险**: 单位不匹配

### 3. 未初始化就铸币
- **场景**: first_mint未调用就触发weekly_emission
- **检查点**: `is_initialized` flag保护

### 4. Period未更新导致重复铸币
- **场景**: calculate_rebase_gauge()被多次调用在同一周
- **检查点**: 代码中应有period检查防止重复

## 待定科目

### emission::EmissionSchedule (关联模块)
- **含义**: 实际的排放曲线和历史记录
- **会计属性**: 属于emission模块的账套,minter只读取

## 总结

minter是**铸币分配枢纽**:
- **资产**: 临时持有每周铸造的DXLYN(瞬时)
- **无负债**: 不欠任何人,只转发铸币
- **权益**: 控制DXLYN的铸造权(mint_cap)和分配逻辑(rebase公式)

核心会计公式:
```
weekly_emission = emission_module.calculate()
rebase = weekly_emission * (1 - veRate)^2 * 0.5
emission = weekly_emission - rebase
```

minter是整个系统的**资金源头**,无会计风险,但要确保rebase计算正确。

