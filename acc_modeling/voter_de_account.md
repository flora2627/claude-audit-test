# voter 模块复式记账分析

## 模块概述
voter管理veNFT的投票权重分配,接收minter的emission,分配给各gauge。

---

## 📌 voter@vote_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `votes[token][pool]` | 贷(增加) | 负债-权重明细 | 记录该NFT对该pool的投票权重 |
| `weights_per_epoch[time][pool]` | 贷(增加) | 负债-pool权重 | 该pool在本epoch的总权重增加 |
| `total_weights_per_epoch[time]` | 贷(增加) | 负债总权重 | 系统总权重增加 |
| `pool_vote[token]` | 贷(添加) | 负债索引 | 记录该NFT投票的pool列表 |
| `last_voted[token]` | 平(更新) | 时间戳 | 更新投票时间 |
| bribe.balance[user][next_epoch] | 贷(增加) | 外部负债 | bribe记录该用户在下周的权重 |
| bribe.total_supply[next_epoch] | 贷(增加) | 外部负债 | bribe记录下周总权重 |

### ⚖️ 函数会计平衡式

```
权重守恒:
sum(votes[token][pool_i]) = voting_escrow.balance_of(token, now)
weights_per_epoch[time][pool] = sum(votes[token][pool] for all tokens)
total_weights_per_epoch[time] = sum(weights_per_epoch[time][pool])
```

**会计平衡**: ✅ 
- veNFT的投票权被分配到各pool,总和=原voting power
- 每个pool权重 = 所有NFT对该pool的投票总和
- 系统总权重 = 所有pool权重总和

**调用链**: L1712-1840
- L1724 `weight = voting_escrow::balance_of(token, now)` - 获取NFT当前voting power
- L1730-1738: 计算`total_vote_weight`(所有alive pool的weight总和)
- L1742-1828: 遍历每个pool,计算`pool_weight = weight * weight_to_pool / total_vote_weight` L1754
- L1806 `bribe::deposit(pool, token, pool_weight)` - 记录到bribe
- L1839 `total_weights_per_epoch[time] += total_weight`

**关键风险**:
- L1754 除法精度损失: `(weight_to_pool * weight) / total_vote_weight`
- 可能导致`sum(pool_weight) < weight`,差额dust丢失

---

## 📌 voter@reset_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `votes[token][pool]` | 贷(归零) | 负债 | 清空该NFT的所有投票 |
| `weights_per_epoch[time][pool]` | 贷(减少) | 负债 | 减少pool权重 |
| `total_weights_per_epoch[time]` | 贷(减少) | 负债总权重 | 减少系统总权重 |
| `pool_vote[token]` | 贷(清空) | 负债索引 | 清空投票列表 |
| bribe.balance | 贷(减少) | 外部负债 | bribe减少该用户权重 |

### ⚖️ 函数会计平衡式

```
Δweights_per_epoch[time][pool] = -votes[token][pool]
Δtotal_weights_per_epoch[time] = -sum(votes[token][pool])
```

**会计平衡**: ✅ 
- 撤销投票,权重归零

**调用链**: L1483-1555
- L1490-1543: 遍历pool_vote,每个pool减去votes
- L1513 `bribe::withdraw(pool, token, votes)` - 同步减少bribe权重
- L1551 `total_weights -= total_weight`
- L1554 `clear(pool_vote)`

**关键逻辑**:
- L1496-1506: 如果last_voted < time,说明是旧epoch的投票,不减weights_per_epoch(因为已过期)
- L1539-1541: `votes = votes - votes` 实际就是归零,代码写法冗余

---

## 📌 voter@notify_reward_amount

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| voter合约DXLYN余额 | 借(增加) | 资产 | 接收minter转来的emission |
| minter合约DXLYN余额 | 贷(减少) | 外部资产 | minter转出emission |
| `index` | 借(增加) | 权益-累积收益率 | index += (amount * 1e8) / total_weight |

### ⚖️ 函数会计平衡式

```
借方: Δvoter余额 + Δindex虚拟值 = amount
贷方: Δminter余额 = amount
```

**会计平衡**: ✅
- 实际资产流入 = amount
- index增加代表"每单位权重应得奖励增加"

**调用链**: L1029-1070
- L1037 `assert balance >= amount` - minter余额检查
- L1041 `primary_fungible_store::transfer(minter, voter_address, amount)` - 实际转账
- L1044 `epoch = epoch_timestamp() - WEEK` - 使用**上周**的权重
- L1046 `total_weight = total_weights_per_epoch[epoch]` - 获取上周总权重
- L1052 `ratio = (amount * 1e8) / total_weight` - 计算每单位权重的奖励
- L1059 `index += ratio`

**关键逻辑**:
- 使用**上周**的权重分配本周收到的emission
- 如果total_weight=0,ratio=0,emission无法分配,accumulate在voter合约

---

## 📌 voter@update_for_after_distribution

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `claimable[gauge]` | 贷(增加) | 负债-gauge应得 | 计算该gauge应得的emission |
| `supply_index[gauge]` | 平(更新) | 检查点 | 同步到最新index |

### ⚖️ 函数会计平衡式

```
Δclaimable[gauge] = (index - supply_index[gauge]) * pool_weight / 1e8
```

**会计平衡**: ✅
- 根据index增量和pool权重计算gauge应得份额
- sum(claimable[gauge]) 应约等于 voter合约余额

**调用链**: L1849-1882
- L1854 `supplied = weights_per_epoch[time-WEEK][pool]` - 获取上周权重
- L1859 `supply_index[gauge]` - 上次同步的index
- L1861 `index` - 当前全局index
- L1866 `delta = index - supply_index[gauge]`
- L1871 `share = (supplied * delta) / 1e8`
- L1876 `claimable[gauge] += share`

**关键风险**:
- L1871 精度损失: `supplied * delta / 1e8`
- 如果supplied很小,share可能为0,奖励丢失

---

## 📌 voter@distribute_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `claimable[gauge]` | 贷(归零) | 负债 | 分配给gauge后清零 |
| voter合约DXLYN余额 | 贷(减少) | 资产 | 转出DXLYN到gauge |
| gauge合约DXLYN余额 | 借(增加) | 外部资产 | gauge接收DXLYN |
| `gauges_distribution_timestamp[gauge]` | 平(更新) | 时间戳 | 记录分配时间 |

### ⚖️ 函数会计平衡式

```
借方: Δgauge余额 = claimable[gauge]
贷方: Δvoter余额 + Δclaimable[gauge] = claimable[gauge]
```

**会计平衡**: ✅
- voter资产减少 = gauge资产增加 = claimable金额

**调用链**: L1651-1702
- L1666 `update_for_after_distribution(gauge)` - 计算最新claimable
- L1668 `claimable = claimable[gauge]`
- L1688 `gauge_clmm::notify_reward_amount(distribution, gauge, claimable)` - 转给gauge
- L1695 `claimable = 0` - 归零

**关键逻辑**:
- L1664-1671: 如果last_timestamp >= current_timestamp,跳过(已分配过)
- L1675 如果is_alive=false,不分配(gauge被kill)

---

## 📌 voter@vote (entry函数)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| 用户DXLYN余额 | 贷(可能减少) | 外部资产 | 同epoch改票罚款 |
| @fee_treasury余额 | 借(可能增加) | 外部资产 | 接收罚款 |
| (其他同vote_internal) | - | - | - |

### ⚖️ 函数会计平衡式

```
如果同epoch改票:
  借方: Δfee_treasury = penalty
  贷方: Δ用户DXLYN = penalty

其他同vote_internal
```

**会计平衡**: ✅

**调用链**: L831-873
- L856 `last_voted_epoch = last_voted / WEEK * WEEK`
- L857 `current_epoch = now / WEEK * WEEK`
- L860-867: 如果current_epoch == last_voted_epoch,收取penalty
- L869 `vote_internal()`

**关键逻辑**:
- 惩罚机制防止频繁改票
- penalty转给@fee_treasury,未返还给veNFT持有者(协议收益)

---

## 📌 voter@kill_gauge

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `is_alive[gauge]` | 贷(设为false) | 权益状态 | 杀死gauge |
| `claimable[gauge]` | 贷(归零) | 负债 | 清空该gauge的应得奖励 |
| `weights_per_epoch[time][pool]` | 平(不变) | 负债 | 保留权重记录(历史数据) |
| `total_weights_per_epoch[time]` | 贷(减少) | 负债总权重 | 减去该pool权重 |

### ⚖️ 函数会计平衡式

```
Δtotal_weights = -weights_per_epoch[time][pool]
Δclaimable[gauge] = -claimable[gauge]
```

**会计影响**: 
- 被kill的gauge的claimable归零,这些DXLYN留在voter合约
- 未来该pool不再获得新emission(L1875 不累加claimable)

**调用链**: L665-687
- L677 `claimable[gauge] = 0` - 清空应得
- L682 `total_weights -= weights_per_epoch[time][pool]` - 减总权重

**会计风险**:
- 被kill的gauge的claimable DXLYN去哪了?
  - 留在voter合约,无机制回收
  - 可能造成voter余额 > sum(alive_gauge.claimable)

---

## 📌 voter@notify_reward_amount

(见上一节已分析)

**补充**:
- L1045-1061: 如果total_weight=0,ratio=0,index不增加
- **后果**: 此次emission无法分配,留在voter合约
- **风险场景**: 所有pool被kill或所有gauge权重为0

---

## 📌 voter@distribute_range / distribute_all / distribute_gauges

### 🧾 变量变动表
(同distribute_internal,批量执行)

### ⚖️ 函数会计平衡式

```
sum(Δclaimable[gauge_i]) = sum(转给各gauge的DXLYN)
```

**会计平衡**: ✅

**调用链**:
- L1075-1088: distribute_all遍历所有pools
- L1100-1117: distribute_range遍历[start, finish)
- L1127-1141: distribute_gauges遍历指定gauges

**关键逻辑**:
- 都先调用`update_period()` L1076 - 触发新一周的rebase和emission
- 然后distribute_internal逐个分配

---

## 📌 voter@create_gauge_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `gauges[pool]` | 借(记录) | 路由 | pool→gauge映射 |
| `pool_for_gauge[gauge]` | 借(记录) | 路由 | gauge→pool反向映射 |
| `is_gauge[gauge]` | 借(设为true) | 权益状态 | 标记为有效gauge |
| `is_alive[gauge]` | 借(设为true) | 权益状态 | 初始为存活 |
| `external_bribes[gauge]` | 借(记录) | 路由 | gauge→bribe映射 |
| `pools` | 借(添加) | 索引 | 添加pool到列表 |
| `supply_index[gauge]` | 借(初始化) | 检查点 | 设为当前index |

### ⚖️ 函数会计平衡式

```
无金额变动,仅创建路由和状态
```

**会计影响**:
- 新gauge的supply_index=当前index,确保不领取历史奖励
- 新bribe和gauge对象被创建

**调用链**: L1560-1639
- L1586-1605: 根据gauge_type调用不同的create_gauge
- L1609 `bribe::create_bribe(voter_signer, voter_address, pool, gauge)` - 创建bribe
- L1628 `supply_index[gauge] = voter.index` - 重要!新gauge从当前index开始

---

## 📌 voter@update_period

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| minter周期时间 | 平(可能更新) | 外部状态 | minter切换到新周 |
| minter持有DXLYN | 借(铸造增加) | 外部资产 | minter铸造新一周emission |
| fee_distributor余额 | 借(增加) | 外部资产 | 接收rebase |
| fee_distributor.tokens_per_week | 贷(更新) | 外部负债 | checkpoint新一周的分配 |

### ⚖️ 函数会计平衡式

```
weekly_emission = rebase + gauge_emission

minter铸造:
  借: minter DXLYN余额 = weekly_emission
  贷: emission.total_emitted = weekly_emission

Rebase分配:
  借: fee_distributor余额 = rebase
  贷: minter余额 = rebase

Gauge分配(通过notify):
  借: voter余额 = gauge_emission
  贷: minter余额 = gauge_emission
```

**会计平衡**: ✅

**调用链**: L752-764
- L753 `(rebase, gauge, dxlyn_signer, is_new_week) = minter::calculate_rebase_gauge()`
- L759 `fee_distributor::burn_rebase(&voter, &dxlyn_signer, rebase)` - 转rebase
- L760 `fee_distributor::checkpoint_token(&voter)` - checkpoint分配
- L761 `fee_distributor::checkpoint_total_supply()` - 同步ve_supply
- L763 `notify_reward_amount(&dxlyn_signer, gauge)` - 转emission给voter

---

## 会计风险汇总

### 🔴 高风险

#### 1. total_weight=0时emission无法分配
- **位置**: L1049-1056, L1058-1060
- **风险**: 如果total_weight=0,ratio=0,index不增加
- **后果**: 该周emission留在voter合约,永久无法分配
- **场景**: 所有gauge被kill,或无人投票

#### 2. kill_gauge后claimable归零,DXLYN去向不明
- **位置**: L677 `claimable[gauge] = 0`
- **风险**: 该gauge已累积的claimable直接清零
- **后果**: 这些DXLYN留在voter合约,无法回收
- **累积**: 多次kill会累积大量无主DXLYN

#### 3. 精度损失累积
- **位置**: L1754 `pool_weight = (weight_to_pool * weight) / total_vote_weight`
- **风险**: 每次vote的精度损失,导致sum(pool_weight) < weight
- **后果**: 差额权重丢失,对应的emission无法分配

### 🟡 中风险

#### 4. index溢出(极低概率)
- **位置**: L1059 `index += ratio`
- **风险**: index使用u64,持续累加可能溢出
- **计算**: 每周ratio ≈ 1e8(假设emission=1M DXLYN,weight=1e12)
  - 溢出需要: 2^64 / 1e8 ≈ 1.8e11周 ≈ 3.5e9年
- **结论**: 无实际风险

#### 5. claimable计算精度损失
- **位置**: L1871 `share = (supplied * delta) / 1e8`
- **风险**: supplied较小时,share可能为0
- **后果**: 小权重的gauge无法获得奖励

### 🟢 低风险

#### 6. last_voted<time导致reset逻辑跳过
- **位置**: L1496-1506, L1546-1548
- **风险**: 如果last_voted是旧epoch,reset时不会减少weights
- **正确性**: ✅ 正确,因为旧epoch的weights已过期,不应减

---

## 总结

### 核心会计公式

```
vote: 将veNFT的weight分配到各pool
  votes[token][pool] = weight * weight_ratio
  weights_per_epoch[time][pool] = sum(votes[token][pool])

notify: 将emission分配到index
  index += (emission * 1e8) / total_weight

distribute: 将index增量转为gauge的claimable
  claimable[gauge] = (index - supply_index[gauge]) * pool_weight / 1e8
  
实际分配: 将claimable转给gauge
  gauge余额 += claimable[gauge]
```

### 会计平衡检查清单
- [✅] vote: sum(pool_weight) = veNFT.weight (有精度损失)
- [✅] notify: voter余额增加 = emission金额
- [✅] update_for: sum(claimable[gauge]) ≈ voter余额 (有精度损失)
- [✅] distribute: voter余额减少 = gauge余额增加
- [⚠️] kill_gauge: claimable归零,DXLYN留在voter

### 建议的审计检查点

1. **验证voter余额 = sum(claimable)**: 编写invariant test
2. **检查total_weight=0的处理**: emission堆积在voter
3. **检查kill_gauge的资金去向**: 是否有回收机制
4. **检查精度损失累积**: 长期运行后voter是否有大量dust

