## 标题
`voting_escrow::split` 的整数截断会无偿销毁锁仓 DXLYN

## 类型
实现层 / Coding Mistake

## 风险等级
高

## 位置
`sources/voting_escrow.move` 中 `split` 逻辑（约第 647-692 行）及内部 `_value_internal = value * weight / total_weight` 计算（第 669 行）

## 发现依据
- `split` 先执行 `voting_escrow.supply = voting_escrow.supply - value`，随后对每个权重计算 `_value_internal = value * weight / total_weight` 并通过 `deposit_for_internal` 逐一回填。

```
647:681:sources/voting_escrow.move
        // reset supply, deposit_for_internal increase it
        voting_escrow.supply = voting_escrow.supply - value;
        let total_weight = 0;
        vector::for_each(split_weights, |weight| {
            assert!(weight > 0, ERROR_INVALID_WEIGHT);
            total_weight = total_weight + weight;
        });
        // ... existing code ...
        vector::for_each(split_weights, |weight| {
            _value_internal = value * weight / total_weight;
            let (minted_token_address, token_name) = mint_nft(voting_escrow, user_address, end, _value_internal);
            let lock_end = deposit_for_internal(
                voting_escrow,
                user,
                minted_token_address,
                _value_internal,
                end,
                SPLIT_TYPE
            );
            event::emit(SplitLockEvent { /* ... */ });
        });
```
- 该计算使用整数除法，`value * weight / total_weight` 会向下取整。任意存在余数的拆分都会使得 `∑_i floor(value * weight_i / total_weight) < value`。
- 由于 `deposit_for_internal` 只回填截断后的数值，最终 `supply_new = supply_old - value + ∑_i floor(value * weight_i / total_weight)`。余数部分永久消失，`locked` 记录也不再包含这部分本金。
- `acc_modeling/voting_escrow_book.md` 的主恒等式要求 “`supply = sum(locked.amount)`”。被截断的余数让 `locked` 与原始本金脱钩，导致真实锁仓与用户债务不符。
- 示例：用户锁定 5 枚 DXLYN。调用 `split([1,1], token)` 后，合约将 `supply` 先减 5，再分别回填 `floor(5×1/2)=2` 与 `2`，剩余 1 枚无处记录。用户后续从两个新 NFT 提现时只能取回 4 枚 DXLYN，其余 1 枚被无偿卡死在合约中。
- 更极端地，当 `value = 1` 且 `split_weights = [1,1]` 时，所有 `_value_internal` 均为 0，新 NFT 锁仓为 0，原锁仓的 1 枚 DXLYN 完全丢失。

## 影响
- 任何未对齐权重的拆分都会消耗用户本金。余数部分既不会返还给用户，也不会保存在新的锁仓记录中，构成直接资金损失。
- 合约层面产生“幽灵资产”：`primary_fungible_store` 中仍留有被截断的 DXLYN，但 `locked` 与 `supply` 已不再计入，协议账面长期失衡。
- 恶意者可诱导用户使用特制权重（或多次细分）反复榨取残余，形成累积性资金黑洞。

## 触发条件 / 调用栈
`voting_escrow::split`（用户入口） → `mint_nft` → `deposit_for_internal`（`type = SPLIT_TYPE`，不会校验余数）

## 置信度
高

