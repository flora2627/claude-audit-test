## 标题
`gauge_clmm` 未能同步更新 Position NFT 流动性，导致用户可“零贡献”骗取奖励并破坏协议会计状态 🚨

## 类型
Financial Model Breakdown / Inconsistency

## 风险等级
Critical

## 位置
- `sources/gauge_clmm.move`: `deposit` (L300), `withdraw` (L344), `update_reward` (L898)

## 发现依据
1.  **流动性快照机制**: `gauge_clmm` 在用户调用 `deposit` 时，通过 `get_liquidity` (L315) 从外部 CLMM 合约获取 Position NFT 的当前流动性，并将此值作为**一次性快照**累加到用户的 `balances[user]` 和全局的 `total_supply` 中。

2.  **外部状态可变性**: CLMM Position NFT 的实际流动性并非静态。当池子市场价格移动到用户设定的价格范围之外时，其有效流动性会变为 `0`。这个状态变化发生在外部 CLMM 模块，`gauge_clmm` 合约无法感知。

3.  **奖励计算漏洞**: `update_reward` 函数 (L898) 根据 gauge 内部存储的 `balances[user]` 和 `total_supply` 来计算和分配奖励。它错误地假设了这两个快照值在整个质押期间都代表了用户的真实流动性贡献。

4.  **提现逻辑缺陷**: `withdraw` 函数 (L373) 虽然会重新获取 NFT 的**当前**流动性，但它仅从 `balances` 和 `total_supply` 中减去这个当前值。如果当前流动性为 `0`，则会计记录完全不会被更新。

## 攻击路径 (S-L2 资格误判)
1.  **准备**: 攻击者 Alice 创建一个具有大量流动性 (`L_large`) 但**价格范围极窄**的 Position NFT。诚实用户 Bob 创建并质押了一个具有正常流动性 (`L_bob`) 的 NFT。

2.  **质押**: Alice 质押她的 NFT。`gauge_clmm` 记录 `balances[Alice] += L_large` 和 `total_supply += L_large`。Alice 获得了池中绝大部分的奖励份额。

3.  **操纵价格使流动性归零**: Alice 在外部市场（如另一个 DEX）进行交易，将 CLMM 池的价格推到她的窄范围之外。此时，她的 NFT 实际流动性变为 `0`，不再为协议提供任何价值。然而，`gauge_clmm` 内部的会计状态（`balances` 和 `total_supply`）**保持不变**。

4.  **“零贡献”骗取奖励**: 在 Alice 的 NFT 流动性为 `0` 的期间，`voter` 持续向 gauge 发放奖励。`update_reward` 仍然根据被夸大的 `balances[Alice] = L_large` 为她计算并累积了大部分奖励。

5.  **提现并固化不当得利**: 在领取奖励前，Alice 保持价格在范围外，然后调用 `withdraw()`。
    *   `get_liquidity` (L373) 获取到**当前流动性为 `0`**。
    *   `update_reward` (L378) 被调用，根据 `balances[Alice] = L_large` 计算并最终确定了她应得的（被夸大的）奖励，存入 `rewards[Alice]`。
    *   `*balance = *balance - 0` (L383) -> `balances[Alice]` **没有被清零**。
    *   `gauge.total_supply = gauge.total_supply - 0` (L386) -> `total_supply` **没有被减少**。
    *   `object::transfer` (L393) 将 NFT 归还给 Alice。

6.  **最终获利**:
    *   Alice 成功取回了 NFT，并可以随时调用 `get_reward` 领取她不劳而获的奖励。
    *   **协议状态被永久破坏**: `balances[Alice]` 和 `total_supply` 包含了已经不在合约中的 NFT 的流动性。这会永久性地稀释后续所有诚实用户的奖励，因为分母 (`total_supply`) 被虚增了。

## 影响
- **资产损失 (Loss)**: 攻击者在不提供流动性的情况下窃取了诚实用户的奖励。
- **协议状态损坏 (DoS/Inconsistency)**: `withdraw` 函数未能正确清理会计状态，导致 `total_supply` 和用户 `balance_of` 被永久污染。这会持续损害后续所有用户的利益，可视为一种慢性的协议 DoS。
- **核心不变量被打破**: `total_supply = sum(liquidity of all staked NFTs)` 这一核心不变量被打破。

## 根因标签
`Inconsistency` / `Mis-measurement`

## 状态
Confirmed

