## 标题
`voter::notify_reward_amount` 精度截断导致周排放永久滞留 `voter` 合约🚨

## 类型
Unsustainability / Financial Model Breakdown

## 风险等级
High

## 位置
- `sources/voter.move`: `notify_reward_amount` 与 `update_for_after_distribution`

## 发现依据
1. 每周排放 `amount` 会在 `notify_reward_amount` 顶部直接转入 `voter` 合约：


```1041:1059:sources/voter.move
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);
...
let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256);
let ratio = (scaled_ratio as u64);
if (ratio > 0) {
    voter.index = voter.index + ratio;
}
```

2. 若上一周总权重 `total_weight` 超过 `amount * 10^8`，`scaled_ratio` 的整数部分为 0，`ratio` 恒为 0，指数不再增长。随后在 `update_for_after_distribution`：


```1863:1875:sources/voter.move
let delta = index - supply_index;
if (delta > 0) {
    let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);
    *claimable = *claimable + share;
}
```

由于 `index` 未更新，`delta = 0`，所有 gauge 的 `claimable` 均保持 0；而对应 emission 已经进入 `voter`，永久滞留。

3. 锁仓权重以 10¹² 精度计（投票权 × 时间 × `AMOUNT_SCALE`），奖励缩放仅有 10⁸，限制条件约为：

```
amount ≥ total_weight / 10^8 ≈ (Σ锁仓 DXLYN) / 10^4
```

当系统锁仓 2,000 万 DXLYN 且全部锁满 4 年时，需要每周至少 ~2000 DXLYN 才能让 `ratio ≥ 1`。随着排放衰减（或攻击者巨量锁仓），极易触发 `ratio = 0` 的“停摆点”。

## 影响
- 一旦触发行权条件，协议仍持续铸造 DXLYN 并转入 `voter`，但所有 `claimable[gauge]` 永远不会增加，LP 与治理参与者拿不到本周奖励。
- 排放曲线出现断档，`voter` 合约资产 ≫ 负债（`sum(claimable)`），奖励体系实质被关闭，可构成“财务欺诈 / 激励瘫痪”。
- 攻击者只需在减排期之前加大锁仓权重，即可提前“锁死”奖励，不必直接获利也能破坏整个财务模型。

## 建议（非修复指引）
- 调整 `ratio` 计算的缩放逻辑，使 `amount` 与 `total_weight` 的精度兼容，可借鉴 `AMOUNT_SCALE * DXLYN_DECIMAL` 的乘积或随指数记录残余；
- 或为 `update_for_after_distribution` 引入残余追补机制，在指数不变时亦能分摊本周 emission，避免资金沉积。

## 置信度
高


