## 标题
三种gauge的紧急提款功能未更新用户奖励，导致用户待领取奖励永久丢失

## 类型 ⚠️
交易层面 / Coding Mistake (会计记账缺失)

## 风险等级
中高

## 位置
- `sources/gauge_cpmm.move` 中 `emergency_withdraw_amount` 函数，第 487-529 行
- `sources/gauge_clmm.move` 中 `emergency_withdraw` 函数，第 412-458 行
- `sources/gauge_perp.move` 中 `emergency_withdraw_amount` 函数，第 490-532 行

## 发现依据

对比正常提款和紧急提款的逻辑：

**正常提款** (以gauge_cpmm为例，L907-946):
```907:946:sources/gauge_cpmm.move
fun withdraw_internal<LPCoin>(
    gauge: &mut GaugeCpmm, user: &signer, amount: u64
) {
    assert!(amount > 0, ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO);

    let user_address = address_of(user);

    //update global and user reward history
    update_reward(gauge, user_address);  // ← ✅ 更新奖励

    // Check user exists
    assert!(table::contains(&gauge.balances, user_address), ERROR_INSUFFICIENT_BALANCE);

    // Validate enough balance
    let balance = table::borrow_mut(&mut gauge.balances, user_address);
    assert!(*balance >= amount, ERROR_INSUFFICIENT_BALANCE);

    *balance = *balance - amount;

    //update total supply
    gauge.total_supply = gauge.total_supply - amount;

    let gauge_signer = object::generate_signer_for_extending(&gauge.extend_ref);

    //transfer lp token from gauge to user account
    supra_account::transfer_coins<LPCoin>(
        &gauge_signer,
        user_address,
        amount
    );
    ...
}
```

**紧急提款** (gauge_cpmm L487-529):
```487:529:sources/gauge_cpmm.move
public entry fun emergency_withdraw_amount<X, Y, Curve>(
    user: &signer,
    amount: u64
) acquires GaugeCpmm {
    assert!(amount > 0, ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO);

    let gauge_address = get_gauge_address_from_coin<X, Y, Curve>();
    assert!(exists<GaugeCpmm>(gauge_address), ERROR_GAUGE_NOT_EXIST);

    let gauge = borrow_global_mut<GaugeCpmm>(gauge_address);
    assert!(gauge.emergency, ERROR_NOT_IN_EMERGENCY_MODE);

    let user_address = address_of(user);

    // Check user exists
    assert!(table::contains(&gauge.balances, user_address), ERROR_INSUFFICIENT_BALANCE);

    // Validate enough balance
    let balance = table::borrow_mut(&mut gauge.balances, user_address);
    assert!(*balance >= amount, ERROR_INSUFFICIENT_BALANCE);

    // ❌ 缺失: update_reward(gauge, user_address);

    //update total supply
    gauge.total_supply = gauge.total_supply - amount;
    *balance = *balance - amount;

    let gauge_signer = object::generate_signer_for_extending(&gauge.extend_ref);

    //transfer lp token from gauge to user account
    supra_account::transfer_coins<LP<X, Y, Curve>>(
        &gauge_signer,
        user_address,
        amount
    );
    ...
}
```

**关键差异**：紧急提款缺少`update_reward(gauge, user_address)`调用。

**update_reward的作用** (L822-836):
```822:836:sources/gauge_cpmm.move
fun update_reward(gauge: &mut GaugeCpmm, account: address) {
    gauge.reward_per_token_stored = reward_per_token_internal(gauge);
    gauge.last_update_time = math64::min(
        timestamp::now_seconds(), gauge.period_finish
    );
    if (account != @0x0) {
        let earned = earned_internal(gauge, account);
        table::upsert(&mut gauge.rewards, account, earned);  // ← 保存待领取奖励
        table::upsert(
            &mut gauge.user_reward_per_token_paid,
            account,
            gauge.reward_per_token_stored
        );
    }
}
```

**earned计算逻辑** (L847-866):
```847:866:sources/gauge_cpmm.move
fun earned_internal(gauge: &GaugeCpmm, account: address): u64 {
    // Check if the balance not exist
    if (!table::contains(&gauge.balances, account)) {
        return 0
    };

    let reward = *table::borrow(&gauge.rewards, account);
    let balance = *table::borrow(&gauge.balances, account);  // ← 依赖balance
    let user_reward_per_token_paid =
        *table::borrow(&gauge.user_reward_per_token_paid, account);
    let reward_per_token_diff =
        reward_per_token_internal(gauge) - user_reward_per_token_paid;

    // Normalize by both DXLYN_DECIMAL and PRECISION
    // Convert to u256 for precision loss prevention and handel overflow issue
    let scaled_reward =
        (reward as u256)
            + ((balance as u256) * reward_per_token_diff) / ((DXLYN_DECIMAL) as u256);
    (scaled_reward as u64)
}
```

## 影响

### 会计恒等式破坏

在紧急提款时：
1. 用户的`balance`被减少或清零
2. 用户的`rewards[account]`**没有**被更新（因为缺少`update_reward`调用）
3. 用户在紧急提款前累积的奖励无法被领取（因为`earned_internal`需要`balance > 0`）
4. 这些DXLYN奖励永久留在gauge合约，破坏会计恒等式：

```
gauge_DXLYN余额 > sum(rewards[user] for all users)
```

### 具体损失场景

**场景1：用户全额紧急提款**
1. Alice在gauge_cpmm中质押100 LP
2. 经过一段时间，累积了10 DXLYN的待领取奖励（未调用get_reward）
3. Gauge进入紧急模式（emergency = true）
4. Alice调用`emergency_withdraw_amount(100)`提取全部LP
5. Alice的`balance`从100变为0
6. 但`rewards[Alice]`没有被更新到10 DXLYN
7. 后续Alice调用`get_reward`时，`earned_internal`返回0（因为`balance = 0`）
8. Alice永久丢失10 DXLYN

**场景2：用户部分紧急提款**
1. Bob在gauge_perp中质押200 DXLP
2. 累积了15 DXLYN的待领取奖励
3. Gauge进入紧急模式
4. Bob调用`emergency_withdraw_amount(150)`提取部分DXLP
5. Bob的`balance`从200变为50
6. 但`rewards[Bob]`没有被更新
7. 后续Bob的`earned_internal`只能基于剩余的50 balance计算新奖励
8. Bob在紧急提款前累积的15 DXLYN中，基于已提取的150份额部分（约11.25 DXLYN）永久丢失

### 累积效应

- 每次紧急提款都会导致用户奖励丢失
- 这些丢失的DXLYN累积在gauge合约中，无法被任何人领取
- 影响所有三种类型的gauge（CPMM, CLMM, PERP）

## 触发条件

1. Gauge的`emergency`标志被设为`true`（由owner通过`set_emergency_mode`触发）
2. 用户在紧急模式下调用紧急提款函数：
   - `gauge_cpmm::emergency_withdraw_amount`
   - `gauge_clmm::emergency_withdraw`
   - `gauge_perp::emergency_withdraw_amount`
3. 用户在紧急提款前有未领取的奖励

## 调用栈

```
[User EOA]
  ↓ 调用 emergency_withdraw_amount<X,Y,Curve>(amount)
  |
gauge_cpmm::emergency_withdraw_amount()
  ↓ L508-510: 减少balance和total_supply
  ↓ L515-518: 转出LP代币
  ✗ 缺失: update_reward(gauge, user_address)
  ✗ 结果: rewards[user]未更新，待领取奖励丢失
```

## 置信度
95%

**支持证据**:
1. 代码逻辑明确：三个gauge的紧急提款函数都缺少`update_reward`调用
2. 对比正常提款：正常提款都正确调用了`update_reward`
3. 会计影响可验证：用户的`rewards`表未更新，导致后续无法领取
4. 影响范围广：所有三种gauge都受影响
5. 用户损失可量化：丢失的奖励金额 = 紧急提款前累积的未领取奖励

**不确定性**:
- 紧急模式的触发频率（取决于治理决策）
- 用户在紧急提款前的平均未领取奖励金额
