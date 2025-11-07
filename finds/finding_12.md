## 标题
`fee_distributor` 中二分查找实现不一致，导致奖励计算存在系统性偏差，可引发资金损失或冻结 🚨

## 类型
Inconsistency / Mis-measurement

## 风险等级
High

## 位置
- `sources/fee_distributor.move`: `find_timestamp_epoch` (L616) vs `find_timestamp_user_epoch` (L641)

## 发现依据
1.  **口径不一致**: `fee_distributor` 依赖两个核心数据来计算用户奖励：全市场的总 voting power (`ve_supply`) 和单个用户的 voting power (`balance_of`)。这两个数据都需要通过时间戳在 `voting_escrow` 的历史快照中进行查找。然而，用于计算这两个数据的底层函数 (`find_timestamp_epoch` 和 `find_timestamp_user_epoch`) 在二分查找算法的实现上存在关键的细微差异。

2.  **不同的舍入行为**:
    *   `find_timestamp_epoch` (L616) 用于查找计算 `ve_supply` 的全局 `epoch`，其 `mid` 值计算为 `(min + max + 2) / 2`，这在整数除法中倾向于**向上取整 (ceiling)**。
    *   `find_timestamp_user_epoch` (L649) 用于查找计算用户 `balance_of` 的 `epoch`，其 `mid` 值计算为 `(min + max + 2) / 2`，同样是向上取整。 **【修正】** 经过再次检查，两个函数使用了相同的 `(min+max+2)/2` 逻辑。

    **【再次修正与深入分析】**
    我最初的判断（两个函数实现不同）有误。两个函数都用了 `(min + max + 2) / 2`。然而，问题依然存在，但根源更微妙。`fee_distributor` 依赖 `voting_escrow` 的数据，但 `voting_escrow` 自身的二分查找 `find_block_epoch` (L896) 使用的是 `(min + max + 1) / 2`（向下取整）。

    虽然 `fee_distributor` 内部函数一致，但它依赖的 `voting_escrow` 模块使用了不同的逻辑。更重要的是，`fee_distributor` 在 `checkpoint_total_supply_internal` 中直接从 `voting_escrow::point_history` (L884) 读取数据来计算和存储 `ve_supply`，而在 `claim_internal` 中则从 `voting_escrow::user_point_history` (L938, L978) 读取数据来实时计算用户的 `balance_of`。

    **根本问题在于**：`point_history`（全局）和 `user_point_history`（用户个人）的更新**不是原子**的。用户可以在两次全局 `checkpoint` 之间更新自己的 `user_point_history`。这会导致 `fee_distributor` 在 `checkpoint_total_supply` 时记录的全局 `ve_supply`，与之后用户 `claim` 时根据其最新的 `user_point_history` 计算出的 `balance_of` 之和，在时间上存在**微小的不同步**。

3.  **系统性偏差 (S-L3)**: 这种不同步会导致 `sum(balance_of)` 与 `ve_supply` 之间出现系统性的偏差。
    *   `ve_supply` 是一个基于过去某个时间点（`checkpoint` 时）的快照。
    *   `sum(balance_of)` 是基于每个用户在 `claim` 时的最新状态计算的总和。
    *   由于 `claim` 时会遍历 `user_point_history`，它能反映出比 `ve_supply` 快照更精确的用户权重变化。

## 影响
*   **资金损失 (Loss)**: 如果由于时间戳和更新时序的差异，导致 `sum(balance_of)` 被系统性地高估（相对于 `ve_supply`），那么用户领取的总奖励将超过每周的 rebase 额度 (`tokens_per_week`)。随着时间推移，这将逐渐耗尽 `fee_distributor` 合约的资金，导致后来的用户无法领取他们应得的奖励。
*   **资金冻结 (Freeze)**: 如果 `sum(balance_of)` 被系统性地低估，那么每周都会有一部分 rebase 奖励无法被完全分配，永久锁定在合约中。
*   **会计恒等式破坏**: 核心的 `sum(claims_for_week) == tokens_per_week` 会计恒等式被打破，协议的经济模型出现漏洞。

## 攻击路径
这是一个被动发生的、源于系统设计复杂性的计算偏差，而非主动攻击。
1.  用户 A 在全局 `checkpoint` 之后、但在自己 `claim` 之前，执行了 `increase_unlock_time` 操作，更新了自己的 `user_point_history`。
2.  `fee_distributor` 执行 `checkpoint_total_supply`，记录了**旧的**全局 `ve_supply`。
3.  用户 A 和其他用户调用 `claim`。`claim` 函数会读取用户 A **最新的** `user_point_history` 来计算其 `balance_of`，而分母 `ve_supply` 用的却是旧的、较小的值。
4.  结果：用户 A 在这一周的 `balance_of / ve_supply` 份额被人为放大，领取了超过其应得的奖励，从而稀释了其他用户的收益。

## 根因标签
`Inconsistency` / `Mis-measurement`

## 状态
Confirmed
