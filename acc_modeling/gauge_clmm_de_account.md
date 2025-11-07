# gauge_clmm 模块复式记账分析

## 说明
gauge_clmm与gauge_cpmm的会计逻辑完全一致,区别仅在于质押资产类型:
- gauge_cpmm: 质押LP Coin代币
- gauge_clmm: 质押Position NFT,按liquidity计量

## 📌 核心函数复式记账

### gauge_clmm@deposit_internal

**变量变动同gauge_cpmm**,区别:
- `total_supply: u128` (而非u64)
- `balance_of[user]: u128`
- 托管的是position NFT(存入tokens列表),计量单位是liquidity

**会计平衡**: ✅

**关键逻辑**:
- L445 `liquidity = position_nft::get_position_info(token)` - 读取NFT的liquidity
- L461 `total_supply += liquidity`
- L464 `balance_of[user] += liquidity`
- L471 `object::transfer(user_signer, token, gauge_address)` - 转移NFT所有权

---

### gauge_clmm@withdraw_internal

**变量变动同gauge_cpmm**

**会计平衡**: ✅

**关键逻辑**:
- L487-542
- L507 `liquidity = token_ids[token]` - 读取记录的liquidity
- L520 `total_supply -= liquidity`
- L523 `balance_of[user] -= liquidity`
- L530 `object::transfer(gauge_signer, token, user)` - 归还NFT

---

### gauge_clmm@notify / get_reward / update_reward

**完全同gauge_cpmm**,公式一致:
```
reward_per_token_stored += (reward_rate * Δtime * PRECISION) / total_supply
rewards[user] += balance_of[user] * (reward_per_token - user_paid) / PRECISION
```

---

## 会计风险(同gauge_cpmm)

### 🔴 新增风险: Position NFT的liquidity可变

#### 1. Liquidity外部变更
- **场景**: 用户在CLMM pool中add/remove liquidity,改变position的liquidity
- **检查**: gauge_clmm在deposit时snapshot liquidity到`token_ids[token]`
- **风险**: 如果position liquidity在外部增加,gauge中的记录未更新
- **后果**: 
  - 用户实际liquidity > 记录的liquidity → 奖励计算偏少
  - 用户实际liquidity < 记录的liquidity → withdraw时可能异常
- **检查点**: 代码是否有同步机制?
  - 未见update_position_liquidity()函数
  - **结论**: 存在liquidity desync风险

#### 2. Position被外部关闭
- **场景**: position在CLMM pool中被close,liquidity归零
- **检查**: gauge中仍记录原liquidity
- **风险**: total_supply不准,奖励分配错误
- **后果**: 该用户占用奖励份额,但实际无流动性贡献

---

## 总结

### 同gauge_cpmm的会计公式
(略,见gauge_cpmm_de_account.md)

### 新增风险
- **Position liquidity可变**: gauge未追踪外部变更
- **建议**: 
  1. Deposit时锁定position,禁止外部modify
  2. 或添加sync_position函数更新liquidity

