# Dexlyn Tokenomics 多主体会计安全模型

## 1. 核心会计主体识别

### 主体A: `voting_escrow.move` - 锁仓托管中心
- **功能**: 托管用户锁仓的DXLYN,发行代表投票权的veNFT
- **资产**: 锁仓DXLYN总量(`supply`)
- **负债**: 对veNFT持有者的DXLYN债务(`locked` table)

### 主体B: `voter.move` - 投票权重分配中心
- **功能**: 管理veNFT的投票权重,分配emission到各gauge
- **资产**: 临时持有待分配的emission DXLYN
- **负债**: 各gauge应得的奖励(`claimable`)
- **权益**: 控制emission分配逻辑(`index`机制)

### 主体C: `fee_distributor.move` - Rebase分配中心
- **功能**: 接收rebase DXLYN,按veNFT权重分配给持有者
- **资产**: 待分配的rebase DXLYN(`token_last_balance`)
- **负债**: 对veNFT持有者的claim权利(`tokens_per_week` / `ve_supply`)

### 主体D: `minter.move` - 铸币分配枢纽
- **功能**: 每周铸造DXLYN,分配rebase和emission
- **资产**: 临时持有新铸DXLYN
- **权益**: 控制铸币权和分配公式

### 主体E: `emission.move` - 排放计算引擎
- **功能**: 计算每周emission数量
- **权益**: 控制排放曲线参数

### 主体F: `gauge_cpmm.move` / `gauge_clmm.move` / `gauge_perp.move` - 流动性挖矿池
- **功能**: 托管LP代币/NFT,分配DXLYN奖励
- **资产**: 托管的LP/DXLP代币(`total_supply`)和待分配DXLYN
- **负债**: 对用户的LP债务(`balance_of`)和奖励债务(`rewards`)

### 主体G: `bribe.move` - 贿赂激励池
- **功能**: 托管外部贿赂代币,激励投票
- **资产**: 多种奖励代币
- **负债**: 对投票者的奖励债务(`balance`, `reward_data`)

### 主体H: `vesting.move` - 代币释放合约
- **功能**: 线性释放锁定DXLYN
- **资产**: 待释放DXLYN
- **负债**: 对股东的释放债务(`VestingRecord`)

### 主体I: `dxlyn_coin.move` - 代币发行中心
- **功能**: DXLYN的铸造和初始分配
- **资产**: InitialSupply储备(100M)
- **权益**: 铸币权(mint_cap)

---

## 2. 主体内部会计模型

### 2.1 主体A: `voting_escrow`
**资产**:
- `supply`: u64 - 锁仓DXLYN总量
- 合约实际DXLYN余额

**负债**:
- `locked: Table<address, LockedBalance>` - 每个veNFT的锁仓记录
- `user_point_history` - veNFT的voting power快照

**[!] 主体内会计恒等式**:
```
supply = sum(locked[token].amount for all active tokens)
合约实际余额 >= supply (可能有过期未提取的)
```

---

### 2.2 主体B: `voter`
**资产**:
- voter合约DXLYN余额

**负债**:
- `claimable: Table<address, u64>` - 各gauge应得奖励
- `weights_per_epoch` - 各pool的投票权重
- `votes` - 各veNFT的投票分配

**权益**:
- `index: u64` - 全局累积收益率

**[!] 主体内会计恒等式**:
```
voter合约DXLYN余额 ≈ sum(claimable[gauge] for all gauges)
total_weights_per_epoch[t] = sum(weights_per_epoch[t][pool])
```

---

### 2.3 主体C: `fee_distributor`
**资产**:
- `token_last_balance`: u64 - 账面DXLYN余额
- 合约实际DXLYN余额

**负债**:
- `tokens_per_week: Table<u64, u64>` - 每周可分配总额
- `ve_supply: Table<u64, u64>` - 每周veNFT总权重

**[!] 主体内会计恒等式**:
```
token_last_balance = sum(tokens_per_week[week]) - sum(已claim)
合约实际余额 >= token_last_balance
```

---

### 2.4 主体D: `minter`
**资产**:
- 临时持有新铸DXLYN(瞬时)

**权益**:
- mint_cap(通过dxlyn_coin)
- emission计算权

**[!] 主体内会计恒等式**:
```
weekly_emission = rebase + emission_to_voter
(无资产累积,瞬时转发)
```

---

### 2.5 主体E: `emission`
**权益**:
- EmissionSchedule - 排放曲线参数

**[!] 主体内会计恒等式**:
```
total_emitted = sum(emissions_by_epoch[i].emission_amount)
```
**⚠️ 潜在bug**: 代码L340可能重复累加total_emitted

---

### 2.6 主体F: `gauge_*` (cpmm/clmm/perp)
**资产**:
- `total_supply` - 托管LP/liquidity总量
- 合约LP余额,合约DXLYN余额

**负债**:
- `balance_of: Table<address, u64/u128>` - 用户LP份额
- `rewards: Table<address, u64>` - 用户DXLYN奖励

**权益**:
- `reward_per_token_stored` - 累积收益率

**[!] 主体内会计恒等式**:
```
total_supply = sum(balance_of[user])
合约LP余额 = total_supply
合约DXLYN余额 >= sum(rewards[user])
```

---

### 2.7 主体G: `bribe`
**资产**:
- 合约持有的多种reward tokens

**负债**:
- `total_supply[epoch]` - 每周总投票权重
- `balance[owner][epoch]` - 用户权重
- `reward_data[token][epoch]` - 每周奖励总额

**[!] 主体内会计恒等式**:
```
total_supply[epoch] = sum(balance[owner][epoch])
合约reward_token余额 >= sum(未领取奖励)
```

---

### 2.8 主体H: `vesting`
**资产**:
- vesting合约DXLYN余额

**负债**:
- `vesting_records[shareholder].left_amount` - 待释放总量

**[!] 主体内会计恒等式**:
```
vesting余额 >= sum(left_amount[shareholder])
```
**⚠️ 风险**: admin_withdraw可破坏此恒等式!

---

### 2.9 主体I: `dxlyn_coin`
**资产**:
- `InitialSupply` 各类别储备

**权益**:
- mint_cap, burn_cap

**[!] 主体内会计恒等式**:
```
DXLYN.total_supply = 100M + sum(minted) - sum(burned)
```

---

## 3. 跨主体会计恒等式 (核心风险点)

### 3.1 交互对: (voting_escrow ↔ voter)

**依赖关系**: 
- voter读取voting_escrow的veNFT voting power用于计算pool权重
- voter调用voting_escrow的friend函数(voting/abstain)锁定/解锁veNFT

**[!!] 跨主体恒等式 1: Voting Power守恒**
```
sum(votes[token][pool] for all pools) = voting_escrow::balance_of(token, vote_time)
```

**风险场景**: 
如果此恒等式被破坏,意味着:
- voter可能记录了超过veNFT实际power的votes
- 可能导致emission分配超额,voter合约DXLYN不足

**检查点**: voter::vote_internal() L1724-1756
- L1724 `weight = voting_escrow::balance_of(token, now)`
- L1754 `pool_weight = (weight_to_pool * weight) / total_vote_weight`
- **风险**: 精度损失导致sum(pool_weight) < weight,小额丢失

**[!!] 跨主体恒等式 2: Total Weights vs Individual Votes**
```
weights_per_epoch[t][pool] = sum(votes[token][pool] for all tokens that voted in epoch t-1)
total_weights_per_epoch[t] = sum(weights_per_epoch[t][pool])
```

**风险场景**:
如果此恒等式被破坏:
- pool权重计算错误,emission分配不公
- total_weights错误,导致index计算偏差

**检查点**: voter::vote_internal() L1784, L1839
- L1784 `weights_per_epoch[time][pool] += pool_weight`
- L1839 `total_weights_per_epoch[time] += total_weight`
- **风险**: killed gauge的权重处理(L685已减total_weights,正确)

---

### 3.2 交互对: (voter ↔ gauge_*)

**依赖关系**:
- voter每周调用gauge的notify_reward_amount,分配emission
- gauge的奖励总量来源于voter的claimable

**[!!] 跨主体恒等式 3: Emission分配守恒**
```
sum(gauge.累计接收的emission) = sum(voter.claimable已分配) 
```

**风险场景**:
如果voter.claimable计算错误:
- claimable总和 > voter余额 → distribute时部分gauge无法领取,revert
- claimable总和 < voter余额 → 有emission留在voter,永久丢失

**检查点**: voter::update_for_after_distribution() L1849-1882
- L1866 `delta = index - supply_index[gauge]`
- L1871 `share = (supplied * delta) / 1e8`
- **风险**: 精度损失累积,sum(claimable) < 实际应分配

**[!!] 跨主体恒等式 4: Gauge奖励计算**
```
claimable[gauge] = (index - supply_index[gauge]) * pool_weight[last_week] / 1e8
```

**风险场景**:
- 如果pool_weight被操纵(伪造投票),gauge可领取超额emission
- **信任边界**: voter信任voting_escrow提供的balance_of

---

### 3.3 交互对: (minter ↔ voter)

**依赖关系**:
- minter每周铸造emission,调用voter.notify_reward_amount分配
- voter信任minter提供的emission数量

**[!!] 跨主体恒等式 5: Emission来源守恒**
```
voter接收的emission = minter计算的gauge_emission
gauge_emission = weekly_emission - rebase
```

**风险场景**:
如果minter计算错误(rebase公式bug):
- rebase偏大 → voter接收的emission偏少 → gauge分配不足
- rebase偏小 → voter接收emission偏多 → fee_distributor分配不足

**检查点**: minter::calculate_rebase_gauge() (代码中未见完整实现,需查找)
- voter::estimated_rebase() L1391-1408提供了公式
- **公式**: `rebase = emission * ((1 - ve_rate)^2) * 0.5`
- **风险**: 
  - L1394 `dxlyn_supply = dxlyn_coin::total_supply()` (10^8)
  - L1397 `ve_dxlyn_supply = voting_escrow::total_supply(next_epoch)` (10^12)
  - L1400 `diff_scaled = 10000 - (ve_supply / dxlyn_supply)` - **单位不匹配!**
  - **bug**: ve_supply是10^12,dxlyn_supply是10^8,直接除会得到10^4倍的锁仓率
  - **后果**: diff_scaled为负或异常,rebase计算错误

---

### 3.4 交互对: (minter ↔ fee_distributor)

**依赖关系**:
- minter每周调用fee_distributor.burn_rebase,转入rebase
- fee_distributor信任minter提供的rebase数量

**[!!] 跨主体恒等式 6: Rebase流转守恒**
```
fee_distributor接收的rebase = minter计算的rebase
sum(tokens_per_week[week]) ≈ sum(接收的rebase)
```

**风险场景**:
如果fee_distributor的checkpoint_token未及时调用:
- 新rebase未分配到tokens_per_week
- 用户无法claim该部分rebase

**检查点**: 
- voter::update_period() L752-764
  - L759 `fee_distributor::burn_rebase(&voter, &dxlyn_signer, rebase)`
  - L760 `fee_distributor::checkpoint_token(&voter)`
- **保护**: update_period在同一调用中完成转账和checkpoint

---

### 3.5 交互对: (fee_distributor ↔ voting_escrow)

**依赖关系**:
- fee_distributor读取voting_escrow的ve_supply用于计算claim份额
- fee_distributor需要voting_escrow的point_history数据

**[!!] 跨主体恒等式 7: VE Supply同步**
```
fee_distributor.ve_supply[week] = voting_escrow::total_supply(week)
```

**风险场景**:
如果ve_supply未同步或滞后:
- 用户claim计算使用错误的ve_supply
- 可能领取过多或过少rebase

**检查点**: fee_distributor::checkpoint_total_supply_internal() L873-896
- L877 `voting_escrow::checkpoint()` - 先触发VE checkpoint
- L884 `(bias, slope, _, ts) = voting_escrow::point_history(epoch)`
- L891 `ve_supply[t] = bias - slope * dt` - **间接计算**,非直接查询total_supply
- **风险**: 计算可能与voting_escrow::total_supply()不一致

---

### 3.6 交互对: (voter ↔ bribe)

**依赖关系**:
- voter调用bribe.deposit记录投票权重
- bribe按权重分配外部贿赂

**[!!] 跨主体恒等式 8: Voting Power同步**
```
对于每个pool和epoch:
bribe.total_supply[epoch][pool] = sum(voter.votes[token][pool] for tokens voted in epoch-1)
```

**风险场景**:
如果voter调用bribe.deposit时传入错误的amount:
- bribe记录的权重 ≠ 实际投票权重
- 用户可领取超额贿赂

**检查点**: voter::vote_internal() L1806
- `bribe::deposit(&voter, pool, token, pool_weight)`
- **信任假设**: voter正确计算pool_weight

**[!!] 跨主体恒等式 9: Bribe Balance vs Voter Votes**
```
bribe.balance[token_owner][epoch][pool] = sum(voter.votes[token][pool] for token owned by owner)
```

**风险场景**:
如果NFT所有权变更后bribe未感知:
- 原owner仍可领取新owner的贿赂
- **保护**: bribe使用`object::owner(token)`动态查询owner,安全

---

### 3.7 交互对: (minter ↔ emission)

**依赖关系**:
- minter调用emission.weekly_emission()获取本周emission数量
- minter根据emission结果铸造DXLYN

**[!!] 跨主体恒等式 10: Emission一致性**
```
minter铸造量 = emission::weekly_emission()返回值
```

**风险场景**:
如果emission计算bug(如total_emitted重复累加):
- emission.total_emitted统计错误,但不影响实际铸造
- **影响**: 仅统计数据错误,非安全风险

**检查点**: emission::weekly_emission() L309-372
- **发现的bug**: L320和L340, L334和L340 重复累加total_emitted
- **后果**: total_emitted = 实际emission的2倍
- **风险级别**: 🟡 中 - 仅影响统计,不影响实际铸造

---

### 3.8 交互对: (gauge_* ↔ users)

**依赖关系**:
- 用户质押LP到gauge,gauge记录balance_of
- gauge托管LP,必须能归还

**[!!] 跨主体恒等式 11: LP托管守恒**
```
gauge.total_supply = sum(gauge.balance_of[user])
gauge合约LP余额 = gauge.total_supply
```

**风险场景**:
如果total_supply与实际余额不一致:
- 可能有用户无法withdraw(资产不足)
- 或有LP滞留在合约(total_supply < 实际余额)

**检查点**: 
- deposit_internal() 同时增加total_supply和balance_of
- withdraw_internal() 同时减少total_supply和balance_of
- **保护**: ✅ 代码逻辑正确

**特殊风险(gauge_clmm)**:
```
gauge.total_supply = sum(token_ids[nft].liquidity)
但NFT的liquidity可在外部改变!
```
- **风险**: Position在CLMM pool中增加liquidity,gauge未感知
- **后果**: total_supply低估,奖励分配不准

---

### 3.9 交互对: (vesting ↔ users)

**依赖关系**:
- 用户vest时,vesting转出DXLYN
- vesting必须有足够余额偿付left_amount

**[!!] 跨主体恒等式 12: Vesting资产>=负债**
```
vesting合约余额 >= sum(vesting_records[shareholder].left_amount)
```

**风险场景**:
如果admin_withdraw后余额不足:
- 股东vest时revert,无法领取
- **破坏者**: admin

**检查点**: vesting::admin_withdraw() L721
- `assert balance >= amount` - 只检查当前余额
- **缺失检查**: `assert balance - amount >= sum(left_amount)`
- **风险级别**: 🔴 高 - admin可掏空合约

---

## 4. 关键操作的复式记账分析

### 4.1 操作: 用户锁仓获得veNFT (`voting_escrow::create_lock`)

**业务描述**: 用户锁定DXLYN,获得veNFT代表时间衰减的投票权

**会计分录**:

**主体A(voting_escrow)账本**:
- 借(Debit): supply ↑ value (资产增加)
- 借(Debit): 合约DXLYN余额 ↑ value
- 贷(Credit): locked[new_nft] ↑ value (负债增加)

**用户账本**:
- 借(Debit): veNFT所有权 (获得NFT资产)
- 贷(Credit): DXLYN余额 ↓ value

**对账检查**: 
- voting_escrow资产=负债 ✅
- 用户付出DXLYN,获得veNFT ✅

---

### 4.2 操作: 用户投票给pool (`voter::vote`)

**业务描述**: veNFT持有者投票给pool,影响emission分配

**会计分录**:

**主体A(voting_escrow)账本**:
- 借(Debit): voted[token] = true (标记投票中)
- (无金额变动)

**主体B(voter)账本**:
- 贷(Credit): votes[token][pool] = pool_weight (记录权重分配)
- 贷(Credit): weights_per_epoch[time][pool] ↑ pool_weight
- 贷(Credit): total_weights_per_epoch[time] ↑ pool_weight

**主体G(bribe)账本**:
- 贷(Credit): balance[user][next_epoch] ↑ pool_weight (记录贿赂领取权)
- 贷(Credit): total_supply[next_epoch][pool] ↑ pool_weight

**对账检查**:
- voter的权重总和 = veNFT的voting power ✅ (有精度损失)
- bribe的权重 = voter的votes ✅

---

### 4.3 操作: Minter每周铸币分配 (`minter::calculate_rebase_gauge` + `voter::update_period`)

**业务描述**: 每周铸造DXLYN,分配rebase和emission

**会计分录**:

**主体D(minter)账本**:
- 借(Debit): minter DXLYN余额 ↑ weekly_emission (铸造)
- 贷(Credit): DXLYN.total_supply ↑ weekly_emission (总供应增加)

**主体E(emission)账本**:
- 借(Debit): total_emitted ↑ weekly_emission (记录发行)

**Rebase分配**:

**主体D(minter)账本**:
- 贷(Credit): minter余额 ↓ rebase

**主体C(fee_distributor)账本**:
- 借(Debit): fee_distributor余额 ↑ rebase

**Emission分配**:

**主体D(minter)账本**:
- 贷(Credit): minter余额 ↓ gauge_emission

**主体B(voter)账本**:
- 借(Debit): voter余额 ↑ gauge_emission
- 借(Debit): index ↑ (gauge_emission * 1e8) / total_weight (虚拟资产)

**对账检查**:
- rebase + gauge_emission = weekly_emission ✅ (有精度损失)
- minter余额减少 = fee_distributor增加 + voter增加 ✅

---

### 4.4 操作: Voter分配emission到gauge (`voter::distribute_internal`)

**业务描述**: voter将claimable转给gauge

**会计分录**:

**主体B(voter)账本**:
- 贷(Credit): claimable[gauge] ↓ (归零)
- 贷(Credit): voter余额 ↓ claimable金额

**主体F(gauge)账本**:
- 借(Debit): gauge DXLYN余额 ↑ claimable金额
- 贷(Credit): reward_rate 更新 (未来负债增加)

**对账检查**:
- voter余额减少 = gauge余额增加 ✅

---

### 4.5 操作: 用户质押LP到gauge (`gauge_cpmm::deposit`)

**业务描述**: 用户质押LP,赚取emission

**会计分录**:

**主体F(gauge)账本**:
- 借(Debit): total_supply ↑ amount (LP资产增加)
- 借(Debit): 合约LP余额 ↑ amount
- 贷(Credit): balance_of[user] ↑ amount (对用户LP负债增加)
- 贷(Credit): rewards[user] 更新 (update_reward计算新增奖励)

**用户账本**:
- 贷(Credit): LP余额 ↓ amount
- 借(Debit): gauge质押凭证 (balance_of)

**对账检查**:
- gauge资产增加 = 负债增加 = amount ✅
- 用户付出LP,获得质押权益 ✅

---

### 4.6 操作: 用户领取emission奖励 (`gauge::get_reward`)

**业务描述**: 用户从gauge领取DXLYN奖励

**会计分录**:

**主体F(gauge)账本**:
- 贷(Credit): rewards[user] ↓ (归零,负债消失)
- 贷(Credit): gauge DXLYN余额 ↓ reward

**用户账本**:
- 借(Debit): DXLYN余额 ↑ reward

**对账检查**:
- gauge负债减少 = gauge资产减少 = 用户收到 ✅

---

### 4.7 操作: 用户从fee_distributor领取rebase (`fee_distributor::claim`)

**业务描述**: veNFT持有者领取rebase奖励

**会计分录**:

**主体C(fee_distributor)账本**:
- 贷(Credit): fee_distributor余额 ↓ to_distribute
- 贷(Credit): (隐式)tokens_per_week的"已领取"标记(通过time_cursor_of)

**主体A(voting_escrow)账本**:
- (无变动,仅读取user_point_history计算权重)

**用户账本**:
- 借(Debit): DXLYN余额 ↑ to_distribute

**对账检查**:
- fee_distributor资产减少 = 用户收到 ✅
- 计算依赖voting_escrow的历史point ✅

**[!!] 跨主体恒等式 13: Rebase分配正确性**
```
user_claim = sum((user_ve_balance[week] / ve_supply[week]) * tokens_per_week[week])

其中:
user_ve_balance = voting_escrow::balance_of(token, week)
ve_supply[week] = 从voting_escrow同步
```

**风险场景**:
- ve_supply滞后 → 用户claim份额错误
- user_point_history不准 → user_ve_balance错误

---

### 4.8 操作: 外部用户贿赂pool (`bribe::notify_reward_amount`)

**业务描述**: 外部用户存入奖励代币,激励投票

**会计分录**:

**主体G(bribe)账本**:
- 借(Debit): bribe合约reward_token余额 ↑ reward
- 贷(Credit): reward_data[token][next_epoch] ↑ reward (负债增加)

**外部用户账本**:
- 贷(Credit): reward_token余额 ↓ reward

**对账检查**:
- bribe资产增加 = 负债增加 = reward ✅

---

## 5. 系统级会计恒等式

### [!!!] 全局恒等式 1: DXLYN总供应守恒

```
DXLYN.total_supply = 
  InitialSupply(100M) +
  emission.total_emitted -
  sum(burned)

其中:
  emission.total_emitted = sum(weekly_emission)
```

**检查**: 
- ⚠️ emission.total_emitted可能重复累加,需修复

---

### [!!!] 全局恒等式 2: DXLYN分布守恒

```
DXLYN.total_supply = 
  voting_escrow.supply +
  sum(gauge.DXLYN余额) +
  voter.DXLYN余额 +
  fee_distributor.DXLYN余额 +
  sum(vesting.DXLYN余额) +
  sum(user.DXLYN余额) +
  dxlyn_coin.InitialSupply +
  其他合约余额
```

**说明**: 所有DXLYN的分布总和 = 总供应

---

### [!!!] 全局恒等式 3: Emission分配守恒 (每周)

```
weekly_emission = rebase + emission_to_voter

rebase → fee_distributor → veNFT持有者
emission_to_voter → voter → gauges → LP质押者
```

**检查每一环**:
1. minter铸造 = weekly_emission ✅
2. rebase + emission = weekly_emission ⚠️ (精度损失,单位问题)
3. fee_distributor接收 = rebase ✅
4. voter接收 = emission ✅
5. sum(claimable[gauge]) ≈ voter余额 ⚠️ (精度损失)
6. sum(gauge接收) = sum(claimable已分配) ✅

---

### [!!!] 全局恒等式 4: Voting Power流转

```
veNFT.voting_power →(vote)→ voter.votes →(deposit)→ bribe.balance
                  →(notify)→ voter.index →(distribute)→ gauge.claimable

veNFT的voting power被"消费"三次:
1. 在voter中决定emission分配
2. 在bribe中领取贿赂
3. 在fee_distributor中领取rebase
```

**关键**: 同一个voting power可多次使用,不是"消耗",而是"权重引用"

---

## 6. 跨主体信任边界与凭证伪造风险

### 6.1 voter → voting_escrow (Friend Trust)

**信任关系**: voter通过friend权限调用voting_escrow的:
- `voting(token)` - 标记投票,禁止转移
- `abstain(token)` - 解除投票,允许转移

**伪造风险**:
- 如果voter合约有bug,可能:
  - 标记任意token为voted,冻结用户资产
  - 或永不调用abstain,导致NFT永久无法提取

**检查点**: 
- voter::vote_internal() L1834调用`voting()`
- voter::reset_internal() L745调用`abstain()`
- **保护**: voter逻辑正确即可,无需额外验证

---

### 6.2 voter → bribe (Friend Trust)

**信任关系**: voter调用bribe的:
- `deposit(pool, token, amount)` - 记录投票权重
- `withdraw(pool, token, amount)` - 撤销投票权重

**伪造风险**:
- 如果voter传入错误的amount:
  - 过大 → 用户可领取超额贿赂
  - 过小 → 用户贿赂损失

**检查点**: voter::vote_internal() L1806
- `pool_weight = (weight_to_pool * weight) / total_vote_weight` L1754
- **计算正确性**: 依赖voting_escrow::balance_of的返回值
- **风险**: 如果voting_escrow::balance_of可被操纵,整个权重体系崩溃

---

### 6.3 fee_distributor → voting_escrow (Read Trust)

**信任关系**: fee_distributor读取voting_escrow的:
- `point_history[epoch]` - 计算ve_supply
- `user_point_history[token][epoch]` - 计算user_ve_balance

**伪造风险**:
- 如果voting_escrow的point计算有bug:
  - 返回虚增的voting power → 用户可领取超额rebase
  - 返回虚减的voting power → 用户rebase损失

**检查点**: voting_escrow::check_point_internal()的正确性
- **关键**: bias和slope计算必须准确
- **公式**: `bias = amount * AMOUNT_SCALE / MAXTIME * (end - current_time)`
- **风险**: 溢出或精度损失

---

### 6.4 voter → gauge (Distributor Trust)

**信任关系**: voter调用gauge的:
- `notify_reward_amount(gauge, amount)`

**伪造风险**:
- 如果voter.claimable计算错误:
  - claimable > 实际应得 → distribute时voter余额不足,revert
  - claimable < 实际应得 → emission累积在voter,丢失

**检查点**: voter::update_for_after_distribution() L1871
- `share = (supplied * delta) / 1e8`
- **风险**: 精度损失,sum(share) < 实际应分配

---

### 6.5 minter → dxlyn_coin (Minter Trust)

**信任关系**: minter调用dxlyn_coin的mint

**伪造风险**:
- 如果minter未按emission曲线铸造:
  - 超额铸造 → 通胀
  - 不足铸造 → 奖励短缺

**检查点**: 
- minter必须调用emission::weekly_emission()
- 不可自行决定铸造量
- **保护**: 代码审查minter逻辑

---

## 7. 发现的严重会计漏洞

### 🔴 漏洞1: vesting::admin_withdraw破坏资产=负债

**位置**: vesting::admin_withdraw() L687-732

**漏洞描述**:
- admin可提走vesting合约的DXLYN,但不减少left_amount负债
- 导致: 合约余额 < sum(left_amount)
- 后果: 股东vest时revert

**修复建议**:
```move
assert!(balance - amount >= sum_of_left_amounts(), ERROR_INSUFFICIENT_FOR_LIABILITIES);
```

---

### 🔴 漏洞2: emission::weekly_emission重复累加total_emitted

**位置**: emission::weekly_emission() L320, L334, L340

**漏洞描述**:
- L320: 首次emission, `total_emitted += _calculated_emission`
- L340: 再次累加 `total_emitted += _calculated_emission`
- 导致: total_emitted = 实际emission的2倍

**修复建议**:
- 移除L340的累加,或移除L320和L334的累加

---

### 🔴 漏洞3: dxlyn_coin::InitialSupply无提取函数

**位置**: dxlyn_coin::init_module() L190

**漏洞描述**:
- 100M DXLYN的InitialSupply锁在合约,无entry函数提取
- 导致: 这些代币永久无法使用

**修复建议**:
- 添加admin函数逐类提取储备

---

### 🔴 漏洞4: voter.rebase计算的单位不匹配

**位置**: voter::estimated_rebase() L1400

**漏洞描述**:
```move
dxlyn_supply = dxlyn_coin::total_supply()  // 10^8精度
ve_dxlyn_supply = voting_escrow::total_supply()  // 10^12精度
diff_scaled = 10000 - (ve_supply / dxlyn_supply)  // 除法结果异常
```
- ve_supply / dxlyn_supply 会得到 10^4 倍的值
- 导致: diff_scaled可能为负,或rebase计算完全错误

**修复建议**:
- 统一单位: `diff_scaled = 10000 - (ve_supply / (dxlyn_supply * 10^4))`

---

### 🟡 漏洞5: voting_escrow::merge的supply减增不原子

**位置**: voting_escrow::merge() L595, L601

**漏洞描述**:
- L595 `supply -= value0`
- L598 `burn_nft(from_token)`
- L601 `deposit_for_internal()` 会在L1658增加supply
- 如果L598-601之间revert,supply永久减少

**修复建议**:
- 将supply操作移到deposit_for_internal内部,确保原子性

---

### 🟡 漏洞6: gauge在total_supply=0时notify,奖励丢失

**位置**: gauge_cpmm::reward_per_token_internal() L704-710

**漏洞描述**:
- 如果total_supply=0,L710返回当前reward_per_token_stored不更新
- 导致: 该次notify的奖励无法分配,留在合约
- 后果: 后续用户会分享这些"免费"奖励

**修复建议**:
- notify时检查total_supply>0
- 或将未分配奖励累积到下次

---

### 🟡 漏洞7: voter::kill_gauge后claimable归零,DXLYN去向不明

**位置**: voter::kill_gauge() L677

**漏洞描述**:
- gauge被kill后,claimable直接清零
- 这些DXLYN留在voter合约,无回收机制
- 累积: 多次kill会累积大量无主DXLYN

**修复建议**:
- kill时将claimable转回minter或fee_distributor
- 或转给treasury

---

## 8. 系统会计安全性评估

### ✅ 设计良好的部分

1. **主体隔离**: 每个模块职责明确,资产负债清晰
2. **Friend控制**: voter↔voting_escrow通过friend限制,权限边界清晰
3. **权重系统**: voting_escrow → voter → bribe的权重流转设计合理
4. **Checkpoint机制**: 各模块使用checkpoint防止重入和状态不一致

### ⚠️ 存在风险的部分

1. **精度损失普遍**: 几乎每个分配计算都有除法精度损失
   - voter的pool_weight计算
   - gauge的reward计算
   - fee_distributor的claim计算
   - bribe的reward计算
   - **累积后果**: 系统中会有dust无法领取

2. **周限制风险**: 50周(bribe/fee_dist claim), 20周(checkpoint)
   - 老用户需多次调用
   - 超限后可能有遗漏

3. **total_supply=0的边界条件**: gauge和bribe在无质押/投票时notify会丢失奖励

4. **单位不匹配**: voter.rebase计算中ve_supply(10^12)和dxlyn_supply(10^8)直接除法

5. **资产<负债的可能**: vesting的admin_withdraw

### 🔴 严重漏洞

1. **vesting资不抵债**: admin_withdraw可掏空合约
2. **InitialSupply锁定**: 100M DXLYN无法提取
3. **rebase单位错误**: 可能导致分配完全错误
4. **emission统计错误**: total_emitted重复累加

---

## 9. 审计建议

### 立即修复

1. **vesting::admin_withdraw**: 添加负债检查
2. **dxlyn_coin::InitialSupply**: 添加提取函数
3. **voter::estimated_rebase**: 修正单位匹配
4. **emission::weekly_emission**: 修复重复累加

### 增强检查

1. **添加invariant tests**:
   - `voting_escrow.supply = sum(locked.amount)`
   - `gauge.total_supply = sum(balance_of)`
   - `voter.余额 ≈ sum(claimable)`
   - `vesting.余额 >= sum(left_amount)`

2. **添加total_supply=0保护**:
   - gauge.notify前检查total_supply>0
   - bribe.notify前检查total_supply>0

3. **添加admin权限时间锁**:
   - vesting.admin_withdraw需timelock
   - voter/fee_distributor的kill函数需governance多签

### 监控指标

1. **精度损失累积**: 定期检查各合约的dust累积量
2. **分配完整性**: sum(已分配) vs sum(应分配)
3. **资产负债比**: 各主体的实际余额 vs 负债总和

---

## 10. 结论

Dexlyn Tokenomics系统采用了清晰的主体拆分和复式记账设计,但存在以下系统性风险:

### 架构级风险
- **精度损失**: 每级分配都有精度损失,长期累积可观
- **单位不匹配**: ve_supply(10^12) vs dxlyn_supply(10^8)

### 实现级漏洞
- **vesting资不抵债**: admin可掏空
- **InitialSupply锁定**: 100M无法提取
- **emission统计错误**: 重复累加

### 建议
- 优先修复🔴级漏洞
- 添加invariant tests保护核心恒等式
- 监控精度损失累积

**总体评估**: 系统设计合理,但实现中存在多个可导致资金损失的漏洞,需立即修复后方可上线。

