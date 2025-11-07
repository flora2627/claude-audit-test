## 标题
`bribe` 模块的奖励计算存在双重精度损失和领取周期限制，导致部分奖励永久冻结 🚨

## 类型
Mis-measurement / Gas-DoS / Freeze

## 风险等级
Medium

## 位置
- `sources/bribe.move`: `reward_per_token_internal` (L1315), `earned_internal` (L1339), `earned_with_timestamp_internal` (L1265)

## 发现依据

`bribe` 模块的奖励领取机制存在两个独立但共同导致资金冻结的设计缺陷：

### 1. 双重整数除法截断 (精度损失)

奖励计算分为两步，每一步都存在整数除法导致的精度损失：

a. **计算每权重奖励 (`reward_per_token_internal`)**:
   ```1326:sources/bribe.move
   (reward_per_epoch * MULTIPLIER) / *total_supply
   ```
   如果 `reward_per_epoch * MULTIPLIER` 不能被 `total_supply` 整除，余数部分会被截断。这导致计算出的 `reward_per_token` 系统性地小于理论值。

b. **计算用户应得奖励 (`earned_internal`)**:
   ```1351:sources/bribe.move
   let rewards = (reward_per_token * balance) / MULTIPLIER;
   ```
   这一步使用上一步有偏差的结果，再次进行整数除法。如果 `reward_per_token * balance` 不能被 `MULTIPLIER` 整除，会发生第二次截断。

**影响**:
这两次截断的累积效应，使得 `sum(所有用户计算出的奖励)` **严格小于** `rewards_per_epoch` 的总量。这个差额（dust）会永久留在 `bribe` 合约中，无法被任何用户领取，构成**资金冻结 (Freeze)**。

### 2. 50 周领取上限 (Gas DoS)

`earned_with_timestamp_internal` 函数在计算用户可领取的总奖励时，使用了一个硬编码的 50 周循环上限：

```1280:sources/bribe.move
for (i in 0..FIFTY_WEEKS) {
```

**影响**:
- **强制多次交易**: 如果一个用户超过 50 周没有领取奖励，他必须反复调用 `get_reward` 函数才能领完所有历史奖励。
- **经济上的拒绝服务 (DoS)**: 对于持有少量投票权的用户，单次领取的奖励价值可能远低于发起一次交易所消耗的 Gas 费用。如果 `(总奖励 / 需要的交易次数) < Gas Fee`，那么对该用户而言，领取剩余奖励在经济上是不可行的。
- **事实上的资金冻结 (Freeze)**: 对于小额用户，部分奖励因为领取成本过高而被事实性地永久冻结在合约中。

## 综合影响
- **系统性资金流失**: 精度损失导致每一笔贿赂都有一部分被永久锁定。
- **损害小额用户利益**: 50 周的领取限制使得小额投票者无法经济地获取他们的全部奖励，构成了一种针对他们的 DoS 攻击。
- **会计不平衡**: `bribe` 合约的实际资产余额将逐渐且永久性地高于其可支付的负债总和。

## 攻击路径
这不是一个主动攻击获利的路径，而是一个被动导致用户资金损失的协议设计缺陷。

1.  **精度损失场景**:
    *   外部用户为某个池子提供了一笔不能被当时 `total_supply` 整除的贿赂。
    *   投票给该池子的用户在领取奖励时，每个人都会因双重截断而损失一小部分应得奖励。
    *   这些损失的灰尘累积在合约中。

2.  **50周限制场景**:
    *   一个小户参与投票，并获得了价值 $0.5 的贿赂奖励，分布在 52 周内。
    *   一年后，他尝试领取奖励。第一次 `get_reward` 调用花费了他 $0.1 的 Gas，领取了前 50 周的奖励（价值约 $0.48）。
    *   他需要再进行一次交易来领取最后 2 周的奖励（价值约 $0.02），但这次交易的 Gas 费仍然是 $0.1。
    *   **结果**: 该用户在经济上被迫放弃最后 $0.02 的奖励，这部分资金被永久冻结。

## 根因标签
`Mis-measurement` / `Gas-DoS` / `Freeze`

## 状态
Confirmed
