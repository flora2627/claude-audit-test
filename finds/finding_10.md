## 标题
`voting_escrow::check_point_internal` 中的无界循环可导致永久性拒绝服务（DoS），冻结所有锁仓修改功能 🚨

## 类型
Unsustainability / Gas-DoS

## 风险等级
High

## 位置
- `sources/voting_escrow.move`: `check_point_internal` 函数 (L1508-L1546)
- 所有调用该函数的入口函数，包括 `merge`, `split`, `increase_amount`, `increase_unlock_time`, `create_lock`

## 发现依据
1.  **无界循环**: `check_point_internal` 函数包含一个 `for (i in 0..TWO_FIFTY_FIVE_WEEKS)` 循环，该循环的实际迭代次数取决于 `current_time - last_checkpoint` 的时长。当协议长时间（例如超过5年）没有发生任何会触发 `checkpoint` 的操作时，此循环的迭代次数会接近255次。

    ```1507:1546:sources/voting_escrow.move
    let t_i = (last_checkpoint / week) * week;
    for (i in 0..TWO_FIFTY_FIVE_WEEKS) {
        // ...
        t_i = t_i + week;
        // ...
        if (t_i > current_time) {
            t_i = current_time;
        } else {
            d_slope =
                *table::borrow_with_default(
                    &voting_escrow.slope_changes,
                    t_i,
                    &SlopeChange { slope: 0, is_negative: false }
                );
        };
        // ... (State reads and arithmetic operations)
        if (t_i == current_time) {
            break
        } else {
            table::upsert(&mut voting_escrow.point_history, epoch, last_point);
        }
    };
    ```

2.  **线性增长的 Gas 消耗**: 循环的每次迭代都包含状态读取 (`table::borrow_with_default`) 和可能的写入 (`table::upsert`)，导致单次交易的 Gas 消耗随迭代次数线性增长。

3.  **触发 Gas 上限**: 一旦时间间隔足够长，任何调用 `check_point_internal` 的交易（如 `merge`, `split` 等）都会因为 Gas 消耗超过 Aptos/Supra 的区块 Gas 上限而失败。

4.  **永久性 DoS**: 这个问题是永久性的。因为时间只能前进，`current_time - last_checkpoint` 的差值只会越来越大。一旦达到 Gas 耗尽的阈值，所有依赖 `checkpoint` 的核心功能将永久不可用，无法通过常规交易修复。

## 影响
- **功能冻结 (Freeze/DoS)**: 所有修改 veNFT 锁仓状态的核心功能（`merge`, `split`, `increase_amount`, `increase_unlock_time`, `create_lock`）将全部失效，用户无法再管理他们的锁仓头寸。
- **协议停滞**: 协议的核心部分（投票权重更新）陷入停滞，因为无法创建新的或修改旧的锁仓。虽然现有的 veNFT 仍可投票和领取奖励，但系统的动态调整能力完全丧失。
- **无需恶意即可触发**: 这个问题不一定需要恶意攻击者。一个早期用户锁定少量代币后长期不活跃，几年后当他或其他用户尝试与协议交互时，就可能触发这个 DoS，影响所有用户。

## 攻击路径
1.  **准备**: 一个早期用户调用 `create_lock` 创建一个 veNFT。此时 `last_checkpoint` 被更新为当前时间。
2.  **等待**: 该用户（或整个协议）保持不活跃状态，时长超过 `N` 周，其中 `N` * (单次循环 Gas 消耗) > `Block Gas Limit`。对于 `N=255`，这个条件几乎必然满足。
3.  **触发**: 任何用户（包括当初的早期用户）调用 `merge`, `split` 或任何其他需要 `checkpoint` 的函数。
4.  **结果**: 交易因 out-of-gas 而失败。此后，任何相关尝试都会失败。

## 根因标签
`Gas-DoS` / `Unbounded Loop`

## 状态
Confirmed

