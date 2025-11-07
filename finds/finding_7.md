## 标题
`dxlyn_coin::InitialSupply` 仅社区可提取，其余 70% 初始代币永久锁死

## 类型
报表层面 / Omission

## 风险等级
高

## 位置
- `dexlyn_coin/sources/dxlyn_coin.move` 中 `init_module` 与 `InitialSupply` 结构体，约第 160-200 行
- `dexlyn_coin/sources/dxlyn_coin.move` 中唯一的提取函数 `mint_to_community`，约第 360-384 行

## 发现依据
- 初始化时一次性铸造 `INITIAL_SUPPLY = 100_000_000 * 10^8`，并拆分到 `InitialSupply` 资源的 7 个科目，只调用一次 `move_to` 保存：

```178:191:dexlyn_coin/sources/dxlyn_coin.move
        let initial_supply = coin::mint<DXLYN>(INITIAL_SUPPLY, &mint_cap);
        let ecosystem_grant = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 10 / 100);
        let protocol_airdrop = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 20 / 100);
        let private_round = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 250 / 10000);
        let genesis_liquidity = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 250 / 10000);
        let team = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 15 / 100);
        let foundation = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 20 / 100);
        let community_airdrop = coin::extract<DXLYN>(&mut initial_supply, INITIAL_SUPPLY * 30 / 100);
        coin::deposit(address_of(&dxlyn_obj_signer), initial_supply);
        move_to(&dxlyn_obj_signer, InitialSupply { ecosystem_grant, protocol_airdrop, private_round, genesis_liquidity, team, foundation, community_airdrop });
```

- 模块内唯一对 `InitialSupply` 的写操作是 `mint_to_community`，仅能从 `community_airdrop` 项划转，并转入 Fungible Asset：

```366:384:dexlyn_coin/sources/dxlyn_coin.move
    public entry fun mint_to_community(owner: &signer, to: address, amount: u64)
        acquires InitialSupply, DxlynInfo {
        ...
        let initial_supply = borrow_global_mut<InitialSupply>(object_add);
        let transfer_coin = coin::extract(&mut initial_supply.community_airdrop, amount);
        let fa_coin = coin::coin_to_fungible_asset(transfer_coin);
        primary_fungible_store::deposit(to, fa_coin);
    }
```

- 全仓库搜索确认不存在针对 `ecosystem_grant`、`protocol_airdrop`、`private_round`、`genesis_liquidity`、`team`、`foundation` 的任何提取或转换逻辑，也没有其它模块调用 `InitialSupply` 资源。

## 影响
- 初始 100% 供应中，仅 30%（community airdrop）可通过 `mint_to_community` 释放，其余 **70%（70,000,000 DXLYN）永久留在 `InitialSupply` 结构体中**，无法被 owner / minter / admin 提取或转化为可流通的 `FungibleAsset`。
- 生态基金、团队、投资轮、协议金库等全部分配计划无法执行，形成不可逆的资金锁死；任何尝试都只能再调用 `mint` 额外增发，导致账面“初始供应”与实际流通脱节，破坏核心会计恒等式和代币经济假设。
- 协议上线后，相关受益方永远无法领取预留额度，会计报表的“初始供应拆分”与链上实际余额长期不符，属于严重 Omission + 不变量缺失。

## 建议（非修复指引）
- 为每个 `InitialSupply` 科目提供对内管控函数（仅限授权角色），将 `coin::Coin<DXLYN>` 转换为 `FungibleAsset` 并划拨到目标地址。
- 同时为释放操作记录事件，确保对账可追溯，避免后续依赖“重新增发”绕过造成供应口径混乱。

