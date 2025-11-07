# emission 模块账套

## 模块概述
emission 模块纯计算引擎,不持有资产,仅记录排放曲线参数和历史emission数据。

## 资产类变量 (Assets)

### ❌ 无资产
emission模块不持有任何DXLYN,只负责计算每周应铸造的数量。

## 负债类变量 (Liabilities)

### ❌ 无负债
emission不欠任何人,只提供计算结果供minter使用。

## 权益类变量 (Equity)

### 1. `EmissionSchedule` 整体
- **类型**: EmissionSchedule struct
- **位置**: minter对象地址
- **含义**: 排放曲线的配置和状态
- **会计属性**: **排放权益** - 控制整个系统的DXLYN增发速率

### EmissionSchedule字段

#### 1. `initial_supply: u64`
- **含义**: 初始供应量(100M * 10^8)
- **会计属性**: **基准值**

#### 2. `initial_rate_bps: u64`
- **含义**: 初始增长率(2 bps = 0.02%)
- **会计属性**: **增长权益**

#### 3. `decay_rate_bps: u64`
- **含义**: 衰减率(1 bps = 0.01%)
- **会计属性**: **衰减权益**

#### 4. `decay_start_epoch: u64`
- **含义**: 开始衰减的epoch(第13周)
- **会计属性**: **衰减边界**

#### 5. `total_emitted: u64`
- **含义**: 历史累计emission总量
- **会计属性**: **累积发行量** - 仅增不减
- **用途**: 审计和统计

#### 6. `epoch_counter: u64`
- **含义**: 当前epoch计数(从0开始)
- **会计属性**: **时间索引**

#### 7. `last_emission: u64`
- **含义**: 上一周的emission数量
- **会计属性**: **上周发行量** - 用于计算本周emission

#### 8. `emissions_by_epoch: Table<u64, EmissionRecord>`
- **类型**: Table<epoch, EmissionRecord>
  ```move
  struct EmissionRecord {
      emission_amount: u64,
      emission_rate: u64,
      timestamp: u64
  }
  ```
- **含义**: 每个epoch的emission历史记录
- **会计属性**: **发行历史** - 不可变审计记录

#### 9. `is_paused: bool`
- **含义**: emission是否暂停
- **会计属性**: **权益控制开关**

#### 10. `admin: address`
- **含义**: 可暂停emission的admin

#### 11. `created_at: u64`
- **含义**: emission启动时间(对齐到周)

## 会计恒等式

### 主恒等式 (Emission累计)
```
total_emitted = sum(emissions_by_epoch[epoch].emission_amount for all epochs)
```

### 辅助恒等式

#### 1. Emission计算公式(增长期)
```
当epoch < decay_start_epoch:
emission[epoch] = last_emission * (1 + initial_rate_bps / 10000)
```

#### 2. Emission计算公式(衰减期)
```
当epoch >= decay_start_epoch:
emission[epoch] = last_emission * (1 - decay_rate_bps / 10000)
```

#### 3. 首次emission
```
emission[0] = initial_supply * initial_rate_bps / 10000
```

## 潜在会计风险

### 1. 溢出风险
- **场景**: total_emitted累加溢出u64
- **检查点**: 使用u64,最大1.8e19,按每周2M DXLYN(2e14),可运行9e4周≈1730年,无溢出风险

### 2. 精度损失累积
- **场景**: 每周的乘除法精度损失累积,导致total_emitted偏离理论值
- **检查点**: `calculate_emission()` L287-302
- **影响**: 微小,可忽略

### 3. Pause后恢复,epoch counter未补偿
- **场景**: pause期间epoch_counter未更新,恢复后epoch编号错位
- **检查点**: 代码中pause只影响`weekly_emission()`执行,不影响epoch计数
- **风险**: 低,emission::get_emission()仍可查询未来epoch

### 4. Epoch_counter与实际时间不同步
- **场景**: 如果长时间未调用weekly_emission,epoch_counter落后
- **检查点**: weekly_emission()每次调用epoch_counter+1,非时间自动更新
- **风险**: 中,需定时调用update_period()

## 待定科目

### 无

## 总结

emission是**纯计算型模块**:
- **无资产**: 不持有DXLYN
- **无负债**: 不欠任何人
- **权益**: 控制DXLYN增发曲线(EmissionSchedule参数)

核心会计公式:
```
epoch<13: emission = last * (1 + 0.02%)
epoch>=13: emission = last * (1 - 0.01%)
total_emitted = sum(all emissions)
```

emission是**排放规则的唯一真相源**,minter完全依赖其计算结果。

