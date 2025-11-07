# fee_distributor 模块复式记账分析

## 模块概述
fee_distributor接收rebase DXLYN,按veNFT权重分配给持有者。

---

## 📌 fee_distributor@burn_rebase (friend函数)

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| fee_distributor合约DXLYN余额 | 借(增加) | 资产 | 接收rebase DXLYN |
| minter(sender)合约DXLYN余额 | 贷(减少) | 外部资产 | minter转出rebase |

### ⚖️ 函数会计平衡式

```
借方: Δfee_distributor余额 = amount
贷方: Δminter余额 = amount
```

**会计平衡**: ✅

**调用链**: L762-785
- L769 `voting_escrow::is_voter(voter_address)` - 权限检查
- L772-777 `primary_fungible_store::transfer(sender, fee_dis_address, amount)`

**关键**: 只转账,不更新`tokens_per_week`,需后续调用`checkpoint_token`

---

## 📌 fee_distributor@checkpoint_token_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `token_last_balance` | 借(更新) | 资产账面 | 同步为当前实际余额 |
| `tokens_per_week[week_i]` | 贷(增加) | 负债 | 按时间比例分配新收到的DXLYN到各周 |
| `last_token_time` | 平(更新) | 时间戳 | 记录checkpoint时间 |

### ⚖️ 函数会计平衡式

```
to_distribute = 实际余额 - token_last_balance
sum(Δtokens_per_week[week_i]) = to_distribute
```

**会计平衡**: ⚠️ **存在精度损失**

**调用链**: L800-863
- L801 `to_distribute = token_balance - token_last_balance`
- L804 `token_last_balance = token_balance` - 同步账面
- L808 `since_last = current_time - t`
- L814-859: 遍历最多20周,按时间比例分配
  - L832 `tokens_per_week[this_week] += (to_distribute * (current_time - t)) / since_last`
  - **精度损失**: 除法会丢失小数部分

**关键风险**:
- 20周限制: L814 `TWENTY_WEEKS`,如果超过20周未checkpoint,后续周无分配
- 精度损失: sum(分配到各周) 可能 < to_distribute,差额成为dust

---

## 📌 fee_distributor@claim_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| fee_distributor合约余额 | 贷(减少) | 资产 | 转出DXLYN给用户 |
| 用户DXLYN余额 | 借(增加) | 外部资产 | 用户领取奖励 |
| `time_cursor_of[token]` | 平(更新) | 检查点 | 记录领取到哪一周 |
| `user_epoch_of[token]` | 平(更新) | 检查点 | 记录使用的epoch索引 |

### ⚖️ 函数会计平衡式

```
to_distribute = sum(user_ve_balance[week] / ve_supply[week] * tokens_per_week[week] for week in [last_claim, last_token_time))
```

**会计平衡**: ⚠️ **精度损失**

**调用链**: L909-1038
- L913 `max_user_epoch = voting_escrow::user_point_epoch(token)`
- L923 `week_cursor = time_cursor_of[token]` - 上次领取位置
- L928 `user_epoch = find_timestamp_user_epoch()` - 二分查找epoch
- L964-1020: 遍历最多50周
  - L983 `dt = week_cursor - old_user_point.ts`
  - L985-988 `balance_of = old_user_point.bias - dt * old_user_point.slope` - 计算该周的ve权重
  - L995 `ve_supply = ve_supply[week_cursor]` - 该周总权重
  - L1001 `to_distribute += (balance_of * tokens_per_week) / ve_supply` - **精度损失点**

**关键风险**:
1. 50周限制: L964 `FIFTY_WEEKS`,老用户需多次claim
2. 精度损失: L1001除法,sum(用户claim) 可能 < tokens_per_week
3. ve_supply未同步: 如果ve_supply[week]=0,会除零吗? - 否,L997检查`ve_supply>0`

---

## 📌 fee_distributor@checkpoint_total_supply_internal

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| `ve_supply[week_i]` | 贷(更新) | 负债-总权重 | 从voting_escrow同步每周的total_supply |
| `time_cursor` | 平(更新) | 检查点 | 记录同步到哪一周 |

### ⚖️ 函数会计平衡式

```
ve_supply[week] = voting_escrow::total_supply(week)
```

**会计平衡**: N/A (同步数据,无金额变动)

**调用链**: L873-896
- L877 `voting_escrow::checkpoint()` - 先触发VE的全局checkpoint
- L880-894: 遍历20周
  - L883 `epoch = find_timestamp_epoch(t)` - 查找对应epoch
  - L884 `(bias, slope, _, ts) = voting_escrow::point_history(epoch)`
  - L891 `ve_supply[t] = bias - slope * dt` - 计算该周的total supply

**关键**: 
- 从voting_escrow的point_history获取数据,不是直接查询
- 20周限制: L880 `TWENTY_WEEKS`

---

## 📌 fee_distributor@burn

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| fee_distributor余额 | 借(增加) | 资产 | 接收用户/外部的DXLYN |
| sender余额 | 贷(减少) | 外部资产 | sender转出DXLYN |
| (可能触发checkpoint_token) | - | - | - |

### ⚖️ 函数会计平衡式

```
借方: Δfee_distributor余额 = amount
贷方: Δsender余额 = amount
```

**会计平衡**: ✅

**调用链**: L559-579
- L565 `primary_fungible_store::transfer(sender, fee_dis_address, amount)`
- L574-577: 如果允许且deadline过,自动checkpoint_token

**用途**: 
- 外部注入rebase(除了burn_rebase,还允许任何人burn)
- 可能是协议手续费收入的入口

---

## 📌 fee_distributor@kill_me

### 🧾 变量变动表

| 变量名 | 方向(借/贷) | 会计科目类别 | 解释 |
|--------|-------------|--------------|------|
| fee_distributor余额 | 贷(归零) | 资产 | 全部转给emergency_return |
| emergency_return余额 | 借(增加) | 外部资产 | 接收所有DXLYN |
| `is_killed` | 平(设为true) | 状态 | 合约终止 |

### ⚖️ 函数会计平衡式

```
借方: Δemergency_return = total_amount
贷方: Δfee_distributor余额 = total_amount
```

**会计影响**: 
- 所有未claim的DXLYN转给emergency_return
- 用户永久失去claim权利
- `token_last_balance`未清零,但无意义

**调用链**: L341-357

---

## 会计风险汇总

### 🔴 高风险

#### 1. checkpoint_token的20周限制
- **位置**: L814 `TWENTY_WEEKS`
- **风险**: 如果超过20周未调用,后续周的tokens_per_week为0
- **后果**: 这段时间收到的DXLYN无法分配,成为dust
- **缓解**: voter每周调用update_period会触发checkpoint

#### 2. 精度损失导致tokens_per_week分配不完全
- **位置**: L832 `(to_distribute * (current_time - t)) / since_last`
- **风险**: 精度损失累积,sum(tokens_per_week) < to_distribute
- **后果**: 有DXLYN永久无法claim

#### 3. claim的50周限制
- **位置**: L964 `FIFTY_WEEKS`
- **风险**: 老用户单次claim最多50周,需多次调用
- **后果**: 可能gas费超出收益,小额用户放弃claim

### 🟡 中风险

#### 4. ve_supply未同步导致claim错误
- **位置**: L995 `ve_supply[week_cursor]`
- **风险**: 如果ve_supply未checkpoint,为0,导致claim失败
- **缓解**: L997检查`ve_supply>0`

#### 5. checkpoint_total_supply的20周限制
- **位置**: L880 `TWENTY_WEEKS`
- **风险**: 超过20周未同步,ve_supply滞后
- **后果**: claim计算使用错误的ve_supply

#### 6. kill_me后用户无法挽回
- **位置**: L347 `is_killed = true`
- **风险**: admin恶意或误操作kill,用户损失所有未claim奖励
- **缓解**: 需要governance控制admin权限

---

## 总结

### 核心会计公式
```
checkpoint_token: 分配新DXLYN到各周
  tokens_per_week[week] += to_distribute * time_ratio

checkpoint_total_supply: 同步veNFT总权重
  ve_supply[week] = voting_escrow.total_supply(week)

claim: 按veNFT权重领取
  user_claim = sum((user_ve / ve_supply) * tokens_per_week for each week)
```

### 会计平衡
- [✅] burn: 实际流入 = amount
- [⚠️] checkpoint_token: sum(分配) ≈ to_distribute (精度损失)
- [⚠️] claim: sum(用户领取) ≈ tokens_per_week (精度损失)
- [✅] kill: 全部转出

### 最大风险
**周限制**和**精度损失**导致部分DXLYN永久无法claim

