## 标题
`voter::notify_reward_amount` 在上周权重为 0 时丢失整周 emission，造成资产负债失衡

## 类型
交易层面 / 借贷不平

## 风险等级
中

## 位置
`sources/voter.move` 中 `notify_reward_amount` 与 `update_for_after_distribution`，约第 1041-1070 行 & 1845-1875 行

## 发现依据
- `notify_reward_amount` 先把本周 `gauge` emission 通过 `primary_fungible_store::transfer` 转入 `voter` 合约余额（L1041-L1048）。
- 随后按 `epoch = epoch_timestamp() - WEEK` 取上一周的总权重 `total_weight`：

```1041:1059:sources/voter.move
primary_fungible_store::transfer(minter, dxlyn_metadata, voter_address, amount);
...
if (table::contains(&voter.total_weights_per_epoch, epoch)) {
    let total_weight = *table::borrow(&voter.total_weights_per_epoch, epoch);
    let ratio = 0;

    if (total_weight > 0) {
        let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256)
            / (total_weight as u256);
        ratio = (scaled_ratio as u64);
    };

    if (ratio > 0) {
        voter.index = voter.index + ratio;
    };
};
```

- 当上一周没有任何票权（`total_weight == 0`，或根本不存在该 key）时，`ratio` 保持 0 → `voter.index` 不更新。
- 后续 `update_for_after_distribution` 按照 `delta = index - supply_index[gauge]` 计算应计奖励：

```1847:1875:sources/voter.move
let supplied = weights_per_epoch_internal(&voter.weights_per_epoch, time, *pool);
...
if (supplied > 0) {
    let supply_index = *table::borrow_with_default(&voter.supply_index, gauge, &0);
    let index = voter.index;
    table::upsert(&mut voter.supply_index, gauge, index);
    let delta = index - supply_index;
    if (delta > 0) {
        let share = ((supplied as u256) * (delta as u256) / (DXLYN_DECIMAL as u256) as u64);
        let claimable = table::borrow_mut_with_default(&mut voter.claimable, gauge, 0);
        *claimable = *claimable + share;
    }
} else {
    table::upsert(&mut voter.supply_index, gauge, voter.index);
}
```

- 由于 `index` 未增长，`delta == 0`，所有 `claimable[gauge]` 保持 0。整个 `amount` 被永远卡在 `voter` 的 DXLYN 余额中。
- 此时资产侧：`voter` 合约 DXLYN 余额增加；负债侧：`claimable` 没有对应增加 → 借贷不平。

## 影响
- 任意执行者只需在 `update_period` 触发前让上一周总权重为 0（例如所有 veNFT 在该周调用 `reset`/`kill` 票权，或系统刚上线尚未有投票）即可让当周整笔 `gauge` emission 永久消失。
- 被卡住的 DXLYN 无法通过后续 `distribute_*`、`revive_gauge` 或任何路径释放，造成协议排放统计与真实可领取奖励断裂：`voter` 资产余额 > `sum(claimable)`，且全体 LP 当周奖励被吞没。
- 若治理方或恶意大户重复在周切换前撤票并调用 `update_period()`，可以持续抹掉每周的 `gauge` emission，使所有 gauge 的奖励发放中断，直接破坏激励模型。

## 触发条件 / 调用栈
1. 周切换（`minter::calculate_rebase_gauge` 返回 `is_new_week = true`）。
2. 在前一周结束时 `total_weights_per_epoch[epoch]` 不存在或值为 0。
3. 任何人调用 `voter::update_period()` → `notify_reward_amount()` → `update_for_after_distribution()`。

## 置信度
95%

## 建议（不属于修复，只用于定位）
- 当上一周总权重为 0 时应拒绝转账或将 `amount` 记入专门的“待分配池”，并在下一次存在有效权重时补发；
- 或在 `update_for_after_distribution` 中把未分配的 `amount` 显式累计到 `claimable_remainder`，避免资产侧出现悬挂余额。

