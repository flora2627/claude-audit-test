## 标题
Gauge 模块在 `total_supply` 为零时接收奖励存在逻辑缺陷，允许首位存款人不成比例地获得奖励 🚨

## 类型
Mis-measurement / Unfair Yield Distribution

## 风险等级
High

## 位置
- `sources/gauge_cpmm.move`: `reward_per_token_internal` (L799-L815)
- `sources/gauge_clmm.move`: `reward_per_token_internal` (L929-L947)
- `sources/gauge_perp.move`: `reward_per_token_internal` (L791-L807)

## 发现依据
1.  **零供应量下的处理逻辑**: 在所有三个 Gauge 模块 (`cpmm`, `clmm`, `perp`) 的 `reward_per_token_internal` 函数中，都存在一个边界条件检查：
    ```move
    if (gauge.total_supply == 0) {
        gauge.reward_per_token_stored
    } else {
        // ... calculate reward_increment ...
    }
    ```
    当 `total_supply` 为 `0` 时，函数直接返回当前的 `reward_per_token_stored` 值，而不计算任何奖励增量。

2.  **`notify_reward_amount` 流程**: 当 `voter` 合约向一个 gauge 分配奖励时，会调用 `notify_reward_amount` 函数。此函数会：
    a. 首先调用 `update_reward`，该函数依赖 `reward_per_token_internal`。
    b. 然后，实际接收 `reward` 代币转账。
    c. 最后，根据收到的 `reward` 和剩余时间，更新 `reward_rate`。

3.  **漏洞触发时序**:
    a. 一个新的 gauge 被创建，或者一个旧的 gauge 质押者全部退出，导致 `total_supply = 0`。
    b. `voter` 调用 `notify_reward_amount`，一笔 `reward` (例如 1,000,000 DXLYN) 被转入 gauge 合约。
    c. 在这次调用中，`update_reward` 因为 `total_supply == 0` 而没有更新 `reward_per_token_stored`，其值仍为旧值（或 `0`）。
    d. `reward_rate` 被设定为一个新的、有效的非零值，`period_finish` 被更新。

4.  **奖励攫取**:
    a. 攻击者通过 front-running 或在无人质押的间隙，成为第一个调用 `deposit` 的用户，存入了极少量的 LP 代币（例如，价值$0.01）。
    b. `deposit` 内部调用的 `update_reward` 同样因为 `total_supply` 在计算前为 `0` 而不起作用。
    c. 此时，`total_supply` 变为一个极小的值。
    d. 时间流逝。当攻击者下次触发 `update_reward`（例如通过调用 `get_reward`）时，`reward_per_token_internal` 将会计算奖励增量 `reward_increment`。由于分母 `total_supply` 极小，`reward_increment` 的值会**极其巨大**。
    e. 攻击者凭借其微不足道的质押，获得了自 `notify_reward_amount` 以来累积的**几乎所有**奖励。

## 影响
- **资产损失 (Loss) / 价值转移**: 诚实用户的奖励被 front-running 的攻击者不成比例地窃取。协议的流动性激励资金被不公平地分配，导致其经济模型失效。
- **S-L1 (过度可提取)**: 攻击者利用 `total_supply = 0` 这一特殊状态，使其 `claimable` 奖励与其实际贡献严重不成比例，从而可以过度提取奖励池。

## 攻击路径
1.  **监控**: 攻击者监控 `voter` 合约，等待 `distribute_internal` 调用一个 `total_supply = 0` 的 gauge 的 `notify_reward_amount` 函数的交易。
2.  **Front-run**: 攻击者在 `notify_reward_amount` 交易之后、任何其他诚实用户 `deposit` 之前，立即提交一笔 `deposit` 交易，向该 gauge 存入一笔极小的金额。
3.  **等待**: 攻击者等待一段时间，让奖励根据被设定的 `reward_rate` 累积。
4.  **收获**: 攻击者调用 `get_reward` 或 `withdraw`，触发 `update_reward` 计算并获得巨额奖励，然后退出。

## 根因标签
`Mis-measurement` / `Incorrect State Handling`

## 状态
Confirmed
