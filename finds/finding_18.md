## 标题
`dxlyn_coin` 合约缺少提现函数，导致 70% 的初始供应量被永久冻结 🚨

## 分类
Freeze - Missing Logic

## 位置
- `dexlyn_coin/sources/dxlyn_coin.move`: 整体模块设计，特别是 `init_module` (L161-L207)

## 二级指标与影响
- **二级指标**: `InitialSupply` 结构体中存储的各部分 `coin::Coin<DXLYN>` 余额。
- **核心断言**: `S-F1 (冻结—冷却/epoch)`。协议设计的核心资产（初始代币供应）应具备可访问性。当前实现使得大部分资产进入不可退出状态。
- **影响门槛**: `Freeze`。占总初始供应量 70% 的代币被永久锁定在合约中，无法被项目方或指定接收者提取，构成事实上的永久资产冻结。

## 详细说明

### 触发条件 / 调用栈
此问题并非由特定交易触发，而是源于合约的初始化设计缺陷。
1.  在部署时，`dxlyn_coin::init_module` 函数被调用。
2.  该函数铸造 `INITIAL_SUPPLY` (1 亿 `DXLYN`) 并将其按预定比例分配到 `InitialSupply` 结构体的各个字段中，例如 `ecosystem_grant`, `protocol_airdrop`, `team` 等。
3.  该 `InitialSupply` 结构体被 `move_to` 保存至合约对象地址的存储中 (L190)。

### 缺陷分析
对 `dexlyn_coin.move` 合约的完整审查显示：
-   合约中存在一个 `public entry fun mint_to_community(...)` 函数 (L366)，它允许 `owner` 或 `minter` 从 `InitialSupply.community_airdrop` (占初始供应的 30%) 中提取代币。
-   然而，合约**完全缺失**任何用于提取其他 70% 资金的 `public entry` 函数。具体包括：
    -   `ecosystem_grant` (10%)
    -   `protocol_airdrop` (20%)
    -   `private_round` (2.5%)
    -   `genesis_liquidity` (2.5%)
    -   `team` (15%)
    -   `foundation` (20%)

由于 Move 合约只能通过 `public entry` 函数与外部交互来改变状态，缺少相应的提现函数意味着这些资金被永久地困在了合约的存储中，无法被转移或使用。

### 证据 (P1-P3)
-   **交易序列 (P1)**:
    1.  `deployer` 调用 `dxlyn_coin::init_module(deployer)`。
    2.  **结果**: 1 亿 `DXLYN` 被铸造并存入 `InitialSupply` 结构。其中 7000 万 `DXLYN` 被存入上述无法访问的字段中。

-   **状态变量分析 (P2)**:
    *   **`InitialSupply` 结构体 (L135)**:
        ```move
        struct InitialSupply has key {
            ecosystem_grant: coin::Coin<DXLYN>,   // 10%
            protocol_airdrop: coin::Coin<DXLYN>,  // 20%
            private_round: coin::Coin<DXLYN>,     // 2.5%
            genesis_liquidity: coin::Coin<DXLYN>, // 2.5%
            team: coin::Coin<DXLYN>,              // 15%
            foundation: coin::Coin<DXLYN>,        // 20%
            community_airdrop: coin::Coin<DXLYN>, // 30% (唯一可提取)
        }
        ```
    *   **代码审查**: 对合约所有 `public entry` 函数进行检查，确认只有 `mint_to_community` 访问了 `InitialSupply` 结构体，且仅访问了 `community_airdrop` 字段。

-   **影响量化 (P3)**:
    *   **冻结金额**: `INITIAL_SUPPLY * 70%` = `100,000,000 * 10^8 * 0.7` = **70,000,000 * 10^8** `DXLYN` 代币。
    *   **冻结时长**: 永久。除非合约可升级（`Move.toml` 未指定 `arbitrary` 升级策略），否则这些资金无法恢复。
    *   **受影响账户**: 协议本身以及所有预期的代币接收者（团队、基金会、生态建设者等）。

### 利用草图
这不是一个可被“利用”的漏洞，而是一个灾难性的部署设计失误。协议在创世阶段即永久损失了其大部分核心资产。

## 根因标签
-   `Missing Logic`
-   `Asset Freeze`

## 状态
Confirmed
