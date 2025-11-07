# vesting 模块账套

## 模块概述
vesting 管理DXLYN的线性释放,为预设股东按schedule释放锁定代币。

## 资产类变量 (Assets)

### 1. 每个VestingContract的DXLYN余额
- **类型**: `primary_fungible_store::balance(vesting_contract_address, dxlyn_metadata)`
- **位置**: 每个vesting_contract对象地址
- **含义**: 该vesting合约托管的待释放DXLYN
- **会计属性**: **托管资产** - 股东的锁定代币
- **增加**: `contribute()` - 外部注入DXLYN
- **减少**: `vest()` - 股东领取已释放部分

## 负债类变量 (Liabilities)

### 1. `VestingRecord` (在VestingContract.vesting_records)
- **类型**: `SimpleMap<address, VestingRecord>`
  ```move
  struct VestingRecord {
      init_amount: u64,
      left_amount: u64,
      last_vested_period: u64
  }
  ```
- **位置**: `VestingContract` struct
- **含义**: 每个股东的vesting记录
- **会计属性**: **负债明细**
  - `init_amount`: 初始分配的总量(不变)
  - `left_amount`: 尚未释放的量(递减)
  - `last_vested_period`: 上次领取到第几期

### 2. `VestingSchedule`
- **类型**: VestingSchedule struct
  ```move
  struct VestingSchedule {
      schedules: vector<FixedPoint32>,  // 每期释放比例
      start_timestamp_secs: u64,
      period_duration: u64,
      last_vested_period: u64
  }
  ```
- **位置**: `VestingContract` struct
- **含义**: 释放时间表
- **会计属性**: **负债规则** - 定义如何计算已释放量
- **关键字段**:
  - `schedules`: 例如[1/24, 1/24, 1/48]表示前两月各释放1/24,之后每月1/48直至完成
  - `period_duration`: 每期时长(如1个月)
  - `last_vested_period`: 合约级别的领取进度

## 权益类变量 (Equity)

### ❌ 无自有权益
vesting不留存DXLYN,所有contribute的代币都属于股东。

## 辅助管理变量

### VestingStore(系统级)

#### 1. `admin: address`
- **含义**: vesting系统管理员

#### 2. `vesting_contracts: vector<address>`
- **含义**: 所有vesting合约列表

#### 3. `nonce: u64`
- **含义**: 用于生成唯一的vesting合约地址

### VestingContract(合约级)

#### 1. `state: u8`
- **含义**: 合约状态(ACTIVE=1, TERMINATED=2)

#### 2. `admin: address`
- **含义**: 该vesting合约的管理员

#### 3. `beneficiaries: SimpleMap<address, address>`
- **含义**: 股东到受益人的映射(股东可指定其他地址领取)

## 会计恒等式

### 主恒等式 (资产=负债)
```
vesting_contract_balance >= sum(vesting_records[shareholder].left_amount for all shareholders)
```
**说明**: 合约余额应>=所有股东剩余待释放总和(可能有外部contribute超额)

### 辅助恒等式

#### 1. 单个股东的释放计算
```
已释放量 = init_amount * sum(schedules[0..current_period])
left_amount = init_amount - 已释放量
```

#### 2. 总初始分配 <= 总资产
```
sum(vesting_records[shareholder].init_amount) <= vesting_contract_balance + sum(已领取)
```

#### 3. Period计算
```
current_period = (current_time - start_timestamp) / period_duration
```

## 潜在会计风险

### 1. left_amount总和 > 合约余额
- **场景**: vest()减少left_amount但转账失败,或admin_withdraw提走资产
- **检查点**: `vest()` L513-629, `admin_withdraw()` L687-732

### 2. 精度损失导致无法完全释放
- **场景**: FixedPoint32计算精度损失,最后一期left_amount>0但schedule已完
- **检查点**: `get_vested_amount()` L913-961

### 3. Terminate后股东无法领取
- **场景**: admin terminate后,股东的left_amount无法vest
- **检查点**: `vest()` L513 assert not terminated

### 4. Schedule定义错误导致释放超100%或不足100%
- **场景**: schedules总和!=1(denominator)
- **检查点**: `create_vesting_contract()` 参数校验L306-314
- **保护**: 要求sum(numerators) <= denominator

### 5. 股东移除后left_amount去向
- **场景**: `remove_shareholder()`将left_amount转给beneficiary,但left_amount计算可能不准
- **检查点**: L645-685

## 待定科目

### `extendRef: ExtendRef` (VestingStore)
- **含义**: 用于创建新vesting合约

### `withdraw_address: address` (VestingContract)
- **含义**: 默认的提取地址(已废弃,现用beneficiaries)

## 总结

vesting是**线性释放型账套**:
- **资产**: 托管的待释放DXLYN(每个vesting_contract持有)
- **负债**: 对股东的释放债务(VestingRecord.left_amount)
- **无自有权益**: 所有代币都属于股东

核心会计公式:
```
vesting_contract_balance >= sum(left_amount[shareholder])
已释放 = init_amount * schedule_percentage
left_amount = init_amount - 已释放
```

关键风险: **admin_withdraw可能导致资产<负债**, **terminate阻止领取**

