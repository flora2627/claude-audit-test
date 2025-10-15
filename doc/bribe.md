
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::bribe`



-  [Struct `RewardAddedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardAddedEvent)
-  [Struct `StakedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_StakedEvent)
-  [Struct `WithdrawnEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WithdrawnEvent)
-  [Struct `RewardPaidEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardPaidEvent)
-  [Struct `WeeklyPaidRewardEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidRewardEvent)
-  [Struct `RecoveredEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RecoveredEvent)
-  [Struct `SetOwnerEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetOwnerEvent)
-  [Struct `SetSystemOwnerEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetSystemOwnerEvent)
-  [Struct `SetVoterEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetVoterEvent)
-  [Struct `RewardTokenAddedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardTokenAddedEvent)
-  [Struct `Reward`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward)
-  [Resource `BribeSystem`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem)
-  [Resource `Bribe`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe)
-  [Struct `WeeklyPaidReward`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_initialize)
    -  [Arguments](#@Arguments_1)
-  [Function `set_voter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_voter)
    -  [Arguments](#@Arguments_2)
-  [Function `set_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_owner)
    -  [Arguments](#@Arguments_3)
-  [Function `set_bribe_sys_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_bribe_sys_owner)
    -  [Arguments](#@Arguments_4)
    -  [Dev](#@Dev_5)
-  [Function `recover_and_update_data`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_recover_and_update_data)
    -  [Arguments](#@Arguments_6)
    -  [Dev](#@Dev_7)
-  [Function `emergency_recover`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_emergency_recover)
    -  [Arguments](#@Arguments_8)
    -  [Dev](#@Dev_9)
-  [Function `add_reward_tokens`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_tokens)
    -  [Arguments](#@Arguments_10)
    -  [Dev](#@Dev_11)
-  [Function `add_reward_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token)
    -  [Arguments](#@Arguments_12)
    -  [Dev](#@Dev_13)
-  [Function `create_bribe`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_create_bribe)
    -  [Arguments](#@Arguments_14)
    -  [Dev](#@Dev_15)
-  [Function `deposit`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_deposit)
    -  [Arguments](#@Arguments_16)
    -  [Dev](#@Dev_17)
-  [Function `withdraw`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_withdraw)
    -  [Arguments](#@Arguments_18)
    -  [Dev](#@Dev_19)
-  [Function `get_reward`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward)
    -  [Arguments](#@Arguments_20)
-  [Function `get_reward_for_token_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_token_owner)
    -  [Arguments](#@Arguments_21)
-  [Function `get_reward_for_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_address)
    -  [Arguments](#@Arguments_22)
-  [Function `notify_reward_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_notify_reward_amount)
    -  [Arguments](#@Arguments_23)
    -  [Dev](#@Dev_24)
-  [Function `get_bribe_system_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address)
    -  [Returns](#@Returns_25)
-  [Function `get_bribe_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_address)
    -  [Arguments](#@Arguments_26)
    -  [Returns](#@Returns_27)
-  [Function `check_and_get_bribe_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address)
    -  [Arguments](#@Arguments_28)
    -  [Returns](#@Returns_29)
    -  [Dev](#@Dev_30)
-  [Function `get_epoch_start`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_epoch_start)
    -  [Returns](#@Returns_31)
-  [Function `get_next_epoch_start`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start)
    -  [Returns](#@Returns_32)
-  [Function `rewards_list_length`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_rewards_list_length)
    -  [Arguments](#@Arguments_33)
    -  [Returns](#@Returns_34)
    -  [Dev](#@Dev_35)
-  [Function `total_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply)
    -  [Arguments](#@Arguments_36)
    -  [Returns](#@Returns_37)
-  [Function `total_supply_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply_at)
    -  [Arguments](#@Arguments_38)
    -  [Returns](#@Returns_39)
-  [Function `balance_of`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of)
    -  [Arguments](#@Arguments_40)
    -  [Returns](#@Returns_41)
-  [Function `balance_of_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_at)
    -  [Arguments](#@Arguments_42)
    -  [Returns](#@Returns_43)
-  [Function `balance_of_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner)
    -  [Arguments](#@Arguments_44)
    -  [Returns](#@Returns_45)
-  [Function `balance_of_owner_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at)
    -  [Arguments](#@Arguments_46)
    -  [Returns](#@Returns_47)
-  [Function `earned_from_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_from_token)
    -  [Arguments](#@Arguments_48)
    -  [Returns](#@Returns_49)
-  [Function `earned`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned)
    -  [Arguments](#@Arguments_50)
    -  [Returns](#@Returns_51)
-  [Function `earned_many`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_many)
    -  [Arguments](#@Arguments_52)
    -  [Returns](#@Returns_53)
-  [Function `earned_with_timestamp`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp)
    -  [Arguments](#@Arguments_54)
    -  [Returns](#@Returns_55)
-  [Function `reward_per_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token)
    -  [Arguments](#@Arguments_56)
    -  [Returns](#@Returns_57)
-  [Function `reward_token_list`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_token_list)
    -  [Arguments](#@Arguments_58)
    -  [Returns](#@Returns_59)
-  [Function `get_remaining_bribe_claim_calls`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_remaining_bribe_claim_calls)
    -  [Arguments](#@Arguments_60)
    -  [Returns](#@Returns_61)
-  [Function `add_reward_token_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal)
    -  [Arguments](#@Arguments_62)
-  [Function `get_reward_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal)
    -  [Arguments](#@Arguments_63)
-  [Function `earned_internal_view`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view)
    -  [Arguments](#@Arguments_64)
    -  [Returns](#@Returns_65)
-  [Function `earned_with_timestamp_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal)
    -  [Arguments](#@Arguments_66)
    -  [Returns](#@Returns_67)
-  [Function `reward_per_token_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal)
    -  [Arguments](#@Arguments_68)
    -  [Returns](#@Returns_69)
-  [Function `earned_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal)
    -  [Arguments](#@Arguments_70)
    -  [Returns](#@Returns_71)
-  [Function `balance_of_owner_at_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal)
    -  [Arguments](#@Arguments_72)
    -  [Returns](#@Returns_73)
-  [Function `reward_per_epoch_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal)
    -  [Arguments](#@Arguments_74)
    -  [Returns](#@Returns_75)
-  [Function `user_last_reward_timestamp_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal)
    -  [Arguments](#@Arguments_76)
    -  [Returns](#@Returns_77)


<pre><code><b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::minter</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardAddedEvent"></a>

## Struct `RewardAddedEvent`

Event emitted when a reward is added to the bribe


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardAddedEvent">RewardAddedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>start_timestamp: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_StakedEvent"></a>

## Struct `StakedEvent`

Event emitted when a user stakes (deposits) voting power


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_StakedEvent">StakedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>token_owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WithdrawnEvent"></a>

## Struct `WithdrawnEvent`

Event emitted when a user withdraws voting power


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WithdrawnEvent">WithdrawnEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>token_owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardPaidEvent"></a>

## Struct `RewardPaidEvent`

Event emitted when a user claims their rewards


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardPaidEvent">RewardPaidEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidRewardEvent"></a>

## Struct `WeeklyPaidRewardEvent`

Event emitted when a user claims their rewards for a week


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidRewardEvent">WeeklyPaidRewardEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>week: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RecoveredEvent"></a>

## Struct `RecoveredEvent`

Event emitted when tokens are recovered from the contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RecoveredEvent">RecoveredEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetOwnerEvent"></a>

## Struct `SetOwnerEvent`

Event emitted when owner changed


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetOwnerEvent">SetOwnerEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>new_owner: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetSystemOwnerEvent"></a>

## Struct `SetSystemOwnerEvent`

Event emitted when system owner changed


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetSystemOwnerEvent">SetSystemOwnerEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>new_owner: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetVoterEvent"></a>

## Struct `SetVoterEvent`

Event emitted when voter changed


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetVoterEvent">SetVoterEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_voter: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>new_voter: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardTokenAddedEvent"></a>

## Struct `RewardTokenAddedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardTokenAddedEvent">RewardTokenAddedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward"></a>

## Struct `Reward`

Store reward data for each epoch


<pre><code><b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>period_finish: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>rewards_per_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_update_time: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem"></a>

## Resource `BribeSystem`

Bribe system data


<pre><code><b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>extended_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe"></a>

## Resource `Bribe`

Store individual bribe data


<pre><code><b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>first_bribe_timestamp: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_data: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;u64, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">bribe::Reward</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>is_reward_token: <a href="_Table">table::Table</a>&lt;<b>address</b>, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>user_reward_per_token_paid: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>user_timestamp: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_supply: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>balance: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;u64, u64&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>extended_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward"></a>

## Struct `WeeklyPaidReward`



<pre><code><b>struct</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>week: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER"></a>

Caller must have owner privileges


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SC_ADMIN"></a>

Creator of the bribe system object address


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_VOTER"></a>

Caller must be the designated voter


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_MULTIPLIER"></a>

Scaling factor (10^8) for precision in reward calculations


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_MULTIPLIER">MULTIPLIER</a>: u64 = 100000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK"></a>

One week in seconds (7 days), used for epoch calculations


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BRIBE_SYSTEM_SEED"></a>

Seed for creating the bribe system object, used in object address generation


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BRIBE_SYSTEM_SEED">BRIBE_SYSTEM_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [66, 82, 73, 66, 69, 95, 83, 89, 83, 84, 69, 77];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_ALREADY_EXISTS"></a>

Bribe already exists for the specified liquidity pool


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_ALREADY_EXISTS">ERROR_ALREADY_EXISTS</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_BRIBE_NOT_EXIST"></a>

Bribe does not exist for the specified liquidity pool


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_BRIBE_NOT_EXIST">ERROR_BRIBE_NOT_EXIST</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE"></a>

Insufficient balance of the reward token for the operation


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE">ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_ADDRESS"></a>

Address must not be the zero address


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_ADDRESS">ERROR_INVALID_ADDRESS</a>: u64 = 108;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT"></a>

Provided amount is invalid (e.g., zero or less than required)


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_TOKEN_NOT_VERIFIED"></a>

Provided token is not a verified reward token


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_TOKEN_NOT_VERIFIED">ERROR_TOKEN_NOT_VERIFIED</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_FIFTY_WEEKS"></a>

We are only allowing 50 weeks of rewards to be claimed, this is used to limit the number of epochs


<pre><code><b>const</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_FIFTY_WEEKS">FIFTY_WEEKS</a>: u64 = 50;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_initialize"></a>

## Function `initialize`

Initializes the BribeSystem contract.


<a id="@Arguments_1"></a>

### Arguments

* <code>sender</code> - The signer creating the BribeSystem contract.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_initialize">initialize</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_initialize">initialize</a>(sender: &<a href="">signer</a>) {
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(sender, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BRIBE_SYSTEM_SEED">BRIBE_SYSTEM_SEED</a>);

    <b>let</b> <a href="">signer</a> = <a href="_generate_signer">object::generate_signer</a>(&constructor_ref);

    <b>let</b> extended_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref);

    <b>move_to</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a>&gt;(
        &<a href="">signer</a>,
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a> { owner: @owner, extended_ref }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_voter"></a>

## Function `set_voter`

Set a new voter


<a id="@Arguments_2"></a>

### Arguments

* <code>owner</code> - The signer who owns the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>new_voter</code> - Address of the new voter.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_voter">set_voter</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, new_voter: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_voter">set_voter</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, new_voter: <b>address</b>
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>assert</b>!(new_voter != @0x0, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_ADDRESS">ERROR_INVALID_ADDRESS</a>);
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetVoterEvent">SetVoterEvent</a> { old_voter: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, new_voter });

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = new_voter;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_owner"></a>

## Function `set_owner`

Set a new owner


<a id="@Arguments_3"></a>

### Arguments

* <code>owner</code> - The current owner signer.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>new_owner</code> - Address of the new owner.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_owner">set_owner</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, new_owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_owner">set_owner</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, new_owner: <b>address</b>
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>assert</b>!(new_owner != @0x0, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_ADDRESS">ERROR_INVALID_ADDRESS</a>);
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetOwnerEvent">SetOwnerEvent</a> { old_owner: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, new_owner });

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner = new_owner;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_bribe_sys_owner"></a>

## Function `set_bribe_sys_owner`

Sets a new owner for the bribe system.


<a id="@Arguments_4"></a>

### Arguments

* <code>owner</code> - The current owner signer.
* <code>new_owner</code> - Address of the new owner.


<a id="@Dev_5"></a>

### Dev

Allows the current owner to transfer ownership of the bribe system.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_bribe_sys_owner">set_bribe_sys_owner</a>(owner: &<a href="">signer</a>, new_owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_set_bribe_sys_owner">set_bribe_sys_owner</a>(
    owner: &<a href="">signer</a>, new_owner: <b>address</b>
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a> {
    <b>assert</b>!(new_owner != @0x0, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_ADDRESS">ERROR_INVALID_ADDRESS</a>);

    <b>let</b> bribe_system_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>();
    <b>let</b> bribe_sys = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a>&gt;(bribe_system_address);

    <b>assert</b>!(address_of(owner) == bribe_sys.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SetSystemOwnerEvent">SetSystemOwnerEvent</a> { old_owner: bribe_sys.owner, new_owner });

    bribe_sys.owner = new_owner;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_recover_and_update_data"></a>

## Function `recover_and_update_data`

Recover some bribe token from the contract and update the given bribe.


<a id="@Arguments_6"></a>

### Arguments

* <code>owner</code> - The signer who owns the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_token</code> - Address of the reward token.
* <code>token_amount</code> - Amount of the token to recover.


<a id="@Dev_7"></a>

### Dev

Only the owner can recover tokens.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_recover_and_update_data">recover_and_update_data</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_token: <b>address</b>, token_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_recover_and_update_data">recover_and_update_data</a>(
    owner: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>,
    reward_token: <b>address</b>,
    token_amount: u64
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> reward_asset = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(reward_token);
    <b>let</b> token_balance = <a href="_balance">primary_fungible_store::balance</a>(bribe_address, reward_asset);

    <b>assert</b>!(token_amount &lt;= token_balance, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <b>let</b> start_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>() + <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;

    <b>let</b> last_reward = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal">reward_per_epoch_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token, start_timestamp);

    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token)) {
        <b>let</b> reward_token_timestamp = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token);
        <b>let</b> reward_data = <a href="_borrow_mut">table::borrow_mut</a>(reward_token_timestamp, start_timestamp);
        reward_data.rewards_per_epoch = last_reward - token_amount;
        reward_data.last_update_time = <a href="_now_seconds">timestamp::now_seconds</a>();

        // transfer <a href="">token</a> from resource <a href="">account</a> <b>to</b> owner
        <b>let</b> bribe_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.extended_ref);
        <a href="_transfer">primary_fungible_store::transfer</a>(
            &bribe_signer,
            reward_asset,
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner,
            token_amount
        );

        <a href="_emit">event::emit</a>(
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RecoveredEvent">RecoveredEvent</a> { amount: token_amount, <a href="">token</a>: reward_token }
        );
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_emergency_recover"></a>

## Function `emergency_recover`

Recover some token from the contract.


<a id="@Arguments_8"></a>

### Arguments

* <code>owner</code> - The signer who owns the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_token</code> - Address of the reward token.
* <code>token_amount</code> - Amount of the token to recover.


<a id="@Dev_9"></a>

### Dev

Be careful: if called, then <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward">get_reward</a>()</code> at last epoch will fail because some rewards are missing!
Consider calling <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_recover_and_update_data">recover_and_update_data</a>()</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_emergency_recover">emergency_recover</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_token: <b>address</b>, token_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_emergency_recover">emergency_recover</a>(
    owner: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>,
    reward_token: <b>address</b>,
    token_amount: u64
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> reward_asset = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(reward_token);
    <b>let</b> token_balance = <a href="_balance">primary_fungible_store::balance</a>(bribe_address, reward_asset);

    <b>assert</b>!(token_amount &lt;= token_balance, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    // transfer <a href="">token</a> from resource <a href="">account</a> <b>to</b> owner
    <b>let</b> bribe_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.extended_ref);
    <a href="_transfer">primary_fungible_store::transfer</a>(
        &bribe_signer,
        reward_asset,
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner,
        token_amount
    );

    <a href="_emit">event::emit</a>(
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RecoveredEvent">RecoveredEvent</a> { amount: token_amount, <a href="">token</a>: reward_token }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_tokens"></a>

## Function `add_reward_tokens`

Adds reward tokens for a bribe.


<a id="@Arguments_10"></a>

### Arguments

* <code>owner</code> - The signer who owns the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_tokens</code> - Addresses of the reward tokens.


<a id="@Dev_11"></a>

### Dev

Only the owner can add reward tokens.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_tokens">add_reward_tokens</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_tokens">add_reward_tokens</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_for_each">vector::for_each</a>(reward_tokens, |reward_token| {
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal">add_reward_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, reward_token, <a href="">pool</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token"></a>

## Function `add_reward_token`

Adds a reward token for a bribe.


<a id="@Arguments_12"></a>

### Arguments

* <code>owner</code> - The signer who owns the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_token</code> - Address of the reward token.


<a id="@Dev_13"></a>

### Dev

Only the owner can add a reward token.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token">add_reward_token</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_token: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token">add_reward_token</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_token: <b>address</b>
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(owner) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.owner, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal">add_reward_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, reward_token, <a href="">pool</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_create_bribe"></a>

## Function `create_bribe`

Creates a bribe for the given liquidity pool.


<a id="@Arguments_14"></a>

### Arguments

* <code>sender</code> - The signer creating the bribe.
* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The address of the bribe voter.
* <code><a href="">pool</a></code> - the liquidity pool address.


<a id="@Dev_15"></a>

### Dev

Only the owner can create a bribe for the specified pool.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_create_bribe">create_bribe</a>(sender: &<a href="">signer</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b>, <a href="">pool</a>: <b>address</b>, gauge_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_create_bribe">create_bribe</a>(
    sender: &<a href="">signer</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b>, <a href="">pool</a>: <b>address</b>, gauge_address: <b>address</b>
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a> {
    <b>let</b> bribe_system_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>();
    <b>let</b> bribe_sys = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BribeSystem">BribeSystem</a>&gt;(bribe_system_address);
    <b>let</b> sender_address = address_of(sender);

    // only owner can create <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>
    <b>assert</b>!(bribe_sys.owner == sender_address, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <b>let</b> bribe_sys_signer =
        <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&bribe_sys.extended_ref);

    <b>let</b> pool_bytes = to_bytes(&<a href="">pool</a>);

    // always create <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> from <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> <a href="">signer</a>
    <b>let</b> new_bribe_address =
        <a href="_create_object_address">object::create_object_address</a>(&address_of(&bribe_sys_signer), pool_bytes);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> created or not for given <a href="">pool</a>
    <b>assert</b>!(
        !<a href="_object_exists">object::object_exists</a>&lt;ObjectCore&gt;(new_bribe_address),
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_ALREADY_EXISTS">ERROR_ALREADY_EXISTS</a>
    );

    <b>let</b> new_bribe_constructor_ref = <a href="_create_named_object">object::create_named_object</a>(
        &bribe_sys_signer, pool_bytes
    );

    <b>let</b> new_bribe_signer = <a href="_generate_signer">object::generate_signer</a>(&new_bribe_constructor_ref);

    <b>let</b> new_bribe_extended_ref =
        <a href="_generate_extend_ref">object::generate_extend_ref</a>(&new_bribe_constructor_ref);

    <b>move_to</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(
        &new_bribe_signer,
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
            first_bribe_timestamp: 0,
            reward_data: <a href="_new">table::new</a>&lt;<b>address</b>, Table&lt;u64, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a>&gt;&gt;(),
            is_reward_token: <a href="_new">table::new</a>&lt;<b>address</b>, bool&gt;(),
            reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;[],
            <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>,
            owner: @owner,
            user_reward_per_token_paid: <a href="_new">table::new</a>&lt;<b>address</b>, Table&lt;<b>address</b>, u64&gt;&gt;(),
            user_timestamp: <a href="_new">table::new</a>&lt;<b>address</b>, Table&lt;<b>address</b>, u64&gt;&gt;(),
            total_supply: <a href="_new">table::new</a>&lt;u64, u64&gt;(),
            balance: <a href="_new">table::new</a>&lt;<b>address</b>, Table&lt;u64, u64&gt;&gt;(),
            extended_ref: new_bribe_extended_ref,
            gauge_address
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_deposit"></a>

## Function `deposit`

User votes deposit on bribe using NFT token.


<a id="@Arguments_16"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The voter signer.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the token.
* <code>amount</code> - Amount to deposit.


<a id="@Dev_17"></a>

### Dev

Called on <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote()</code> or <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.poke()</code>.
Owner must reset before transferring token.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_deposit">deposit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_deposit">deposit</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, amount: u64
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>assert</b>!(amount &gt; 0, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <b>let</b> voter_address = address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>);
    <b>assert</b>!(voter_address == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>);

    <b>let</b> start_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>() + <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;
    <b>let</b> old_supply = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, start_timestamp, &0);
    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));
    <b>let</b> last_balance = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner, start_timestamp);

    // <b>update</b> total supply
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, start_timestamp, *old_supply + amount);

    // <b>update</b> user <a href="">timestamp</a> balance
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner)) {
        <b>let</b> owner_timestamp_balance = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner);
        <a href="_upsert">table::upsert</a>(owner_timestamp_balance, start_timestamp, last_balance + amount);
    } <b>else</b> {
        <b>let</b> owner_timestamp_balance: Table&lt;u64, u64&gt; = <a href="_new">table::new</a>&lt;u64, u64&gt;();
        <a href="_add">table::add</a>(&<b>mut</b> owner_timestamp_balance, start_timestamp, last_balance + amount);
        <a href="_add">table::add</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner, owner_timestamp_balance);
    };

    <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_StakedEvent">StakedEvent</a> { token_owner, <a href="">token</a>, amount });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_withdraw"></a>

## Function `withdraw`

User votes withdrawal using NFT token.


<a id="@Arguments_18"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The voter signer.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the token.
* <code>amount</code> - Amount to withdraw.


<a id="@Dev_19"></a>

### Dev

Called on <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.reset()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_withdraw">withdraw</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_withdraw">withdraw</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, amount: u64
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>assert</b>!(amount &gt; 0, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <b>let</b> voter_address = address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>);
    <b>assert</b>!(voter_address == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>);

    <b>let</b> start_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>() + <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;
    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));
    <b>let</b> old_balance = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner, start_timestamp);

    <b>if</b> (amount &lt;= old_balance) {
        <b>let</b> old_supply = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, start_timestamp, &0);

        // <b>update</b> total supply
        <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, start_timestamp, *old_supply - amount);

        // <b>update</b> user <a href="">timestamp</a> balance
        <b>if</b> (<a href="_contains">table::contains</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner)) {
            <b>let</b> owner_timestamp_balance = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner);
            <a href="_upsert">table::upsert</a>(owner_timestamp_balance, start_timestamp, old_balance - amount);
        } <b>else</b> {
            <b>let</b> owner_timestamp_balance: Table&lt;u64, u64&gt; = <a href="_new">table::new</a>&lt;u64, u64&gt;();
            <a href="_add">table::add</a>(&<b>mut</b> owner_timestamp_balance, start_timestamp, old_balance - amount);
            <a href="_add">table::add</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner, owner_timestamp_balance);
        };

        <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WithdrawnEvent">WithdrawnEvent</a> { token_owner, <a href="">token</a>, amount });
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward"></a>

## Function `get_reward`

Claim rewards for a list of reward tokens.


<a id="@Arguments_20"></a>

### Arguments

* <code>owner</code> - signer of the user
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_token</code> - address of the reward token


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward">get_reward</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward">get_reward</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <b>let</b> owner_address = address_of(owner);

    <a href="_for_each">vector::for_each</a>(reward_tokens, |reward_token| {
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal">get_reward_internal</a>(
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>,
            bribe_address,
            owner_address,
            reward_token,
            <a href="">pool</a>
        );
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_token_owner"></a>

## Function `get_reward_for_token_owner`

Claims rewards for a specific token owner.


<a id="@Arguments_21"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The voter signer.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the nft token.
* <code>reward_token</code> - Address of the reward token.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_token_owner">get_reward_for_token_owner</a>(_caller: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_token_owner">get_reward_for_token_owner</a>(
    _caller: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>,
    <a href="">token</a>: <b>address</b>,
    reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));

    <a href="_for_each">vector::for_each</a>(reward_tokens, |reward_token| {
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal">get_reward_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, bribe_address, token_owner, reward_token, <a href="">pool</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_address"></a>

## Function `get_reward_for_address`

Voter claims rewards for a specific address.


<a id="@Arguments_22"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The voter signer.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>owner</code> - Address of the owner.
* <code>reward_token</code> - Address of the reward token.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_address">get_reward_for_address</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, owner: <b>address</b>, reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_address">get_reward_for_address</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>,
    owner: <b>address</b>,
    reward_tokens: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>assert</b>!(address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>) == <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>);

    <a href="_for_each">vector::for_each</a>(reward_tokens, |reward_token| {
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal">get_reward_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, bribe_address, owner, reward_token, <a href="">pool</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_notify_reward_amount"></a>

## Function `notify_reward_amount`

Notify a bribe amount.


<a id="@Arguments_23"></a>

### Arguments

* <code>sender</code> - The signer notifying the bribe.
* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>reward_token</code> - Address of the reward token.
* <code>reward</code> - Amount of the reward.


<a id="@Dev_24"></a>

### Dev

Rewards are saved into NEXT EPOCH mapping.


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_notify_reward_amount">notify_reward_amount</a>(sender: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>, reward_token: <b>address</b>, reward: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_notify_reward_amount">notify_reward_amount</a>(
    sender: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>,
    reward_token: <b>address</b>,
    reward: u64
) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> reward_asset = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(reward_token);
    <b>let</b> sender_address = address_of(sender);
    <b>assert</b>!(
        <a href="_balance">primary_fungible_store::balance</a>(sender_address, reward_asset) &gt;= reward,
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE">ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE</a>
    );

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global_mut</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    // Check whether <a href="">token</a> is reward <a href="">token</a> or not
    <b>assert</b>!(*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.is_reward_token, reward_token, &<b>false</b>), <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_TOKEN_NOT_VERIFIED">ERROR_TOKEN_NOT_VERIFIED</a>);

    // transfer reward <a href="">token</a> <b>to</b> resource <a href="">account</a>
    <a href="_transfer">primary_fungible_store::transfer</a>(sender, reward_asset, bribe_address, reward);

    // period points <b>to</b> the current thursday. Bribes are distributed from next epoch (thursday)
    <b>let</b> week = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;
    <b>let</b> current_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>let</b> start_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>() + week;

    <b>if</b> (<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp == 0) {
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp = start_timestamp;
    };

    <b>let</b> last_reward = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal">reward_per_epoch_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token, start_timestamp);

    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token)) {
        <b>let</b> reward_token_timestamp = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token);
        <a href="_upsert">table::upsert</a>(
            reward_token_timestamp,
            start_timestamp,
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a> {
                last_update_time: current_timestamp,
                period_finish: start_timestamp + week,
                rewards_per_epoch: last_reward + reward
            }
        );
    } <b>else</b> {
        <b>let</b> reward_token_timestamp = <a href="_new">table::new</a>&lt;u64, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a>&gt;();
        <a href="_add">table::add</a>(
            &<b>mut</b> reward_token_timestamp,
            start_timestamp,
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a> {
                last_update_time: current_timestamp,
                period_finish: start_timestamp + week,
                rewards_per_epoch: last_reward + reward
            }
        );
        <a href="_add">table::add</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token, reward_token_timestamp);
    };

    <a href="_emit">event::emit</a>(
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardAddedEvent">RewardAddedEvent</a> {
            user: sender_address,
            <a href="">pool</a>,
            reward,
            reward_token,
            start_timestamp,
            <a href="">timestamp</a>: current_timestamp,
            gauge: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.gauge_address
        }
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address"></a>

## Function `get_bribe_system_address`

Get the address of the bribe system


<a id="@Returns_25"></a>

### Returns

The address of the bribe system


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_SC_ADMIN">SC_ADMIN</a>, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_BRIBE_SYSTEM_SEED">BRIBE_SYSTEM_SEED</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_address"></a>

## Function `get_bribe_address`

Returns the bribe address associated with a specific liquidity pool.


<a id="@Arguments_26"></a>

### Arguments

* <code><a href="">pool</a></code> - The liquidity pool address for which to retrieve the bribe address.


<a id="@Returns_27"></a>

### Returns

* The bribe address associated with the liquidity pool.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_address">get_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_address">get_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b> {
    <b>let</b> bribe_system_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>();
    <b>let</b> pool_bytes = to_bytes(&<a href="">pool</a>);
    <b>let</b> bribe_address = <a href="_create_object_address">object::create_object_address</a>(&bribe_system_address, pool_bytes);
    bribe_address
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address"></a>

## Function `check_and_get_bribe_address`

Returns the bribe address for a given liquidity pool token.


<a id="@Arguments_28"></a>

### Arguments

* <code><a href="">pool</a></code> - The liquidity pool address for which to retrieve and check the bribe address.


<a id="@Returns_29"></a>

### Returns

* The bribe address associated with the liquidity pool.


<a id="@Dev_30"></a>

### Dev

Checks if the bribe exists for the given pool address.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b> {
    <b>let</b> bribe_system_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_system_address">get_bribe_system_address</a>();
    <b>let</b> pool_bytes = to_bytes(&<a href="">pool</a>);
    <b>let</b> bribe_address = <a href="_create_object_address">object::create_object_address</a>(&bribe_system_address, pool_bytes);

    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> created or not for lp <a href="">token</a>
    <b>assert</b>!(
        <a href="_object_exists">object::object_exists</a>&lt;ObjectCore&gt;(bribe_address),
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_BRIBE_NOT_EXIST">ERROR_BRIBE_NOT_EXIST</a>
    );
    bribe_address
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_epoch_start"></a>

## Function `get_epoch_start`

Returns the current epoch.


<a id="@Returns_31"></a>

### Returns

* The current epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_epoch_start">get_epoch_start</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_epoch_start">get_epoch_start</a>(): u64 {
    <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>()
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start"></a>

## Function `get_next_epoch_start`

Returns the next epoch start timestamp (where bribes are saved).


<a id="@Returns_32"></a>

### Returns

* <code>u64</code> - The next epoch start timestamp.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start">get_next_epoch_start</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start">get_next_epoch_start</a>(): u64 {
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_epoch_start">get_epoch_start</a>() + <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_rewards_list_length"></a>

## Function `rewards_list_length`

Get the length of the reward tokens


<a id="@Arguments_33"></a>

### Arguments

* <code><a href="">pool</a></code> - The liquidity pool address.


<a id="@Returns_34"></a>

### Returns

Length of the reward tokens


<a id="@Dev_35"></a>

### Dev

Checks if bribe exists or not


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_rewards_list_length">rewards_list_length</a>(<a href="">pool</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_rewards_list_length">rewards_list_length</a>(<a href="">pool</a>: <b>address</b>): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <a href="_length">vector::length</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_tokens)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply"></a>

## Function `total_supply`

Returns the last total supply (total votes for a pool).


<a id="@Arguments_36"></a>

### Arguments

* <code><a href="">pool</a></code> - The liquidity pool address.


<a id="@Returns_37"></a>

### Returns

* <code>u64</code> - total supply of the current epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply">total_supply</a>(<a href="">pool</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply">total_supply</a>(<a href="">pool</a>: <b>address</b>): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // equivalent <b>to</b> IMinter.active_period()
    <b>let</b> current_epoch_start = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>();
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, current_epoch_start, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply_at"></a>

## Function `total_supply_at`

Get a total supply given a timestamp


<a id="@Arguments_38"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address
* <code><a href="">timestamp</a></code> - timestamp to get the total supply


<a id="@Returns_39"></a>

### Returns

total supply of the given timestamp


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply_at">total_supply_at</a>(<a href="">pool</a>: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_total_supply_at">total_supply_at</a>(<a href="">pool</a>: <b>address</b>, <a href="">timestamp</a>: u64): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, <a href="">timestamp</a>, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of"></a>

## Function `balance_of`

Get the balance of an token owner in the current epoch.


<a id="@Arguments_40"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the token.


<a id="@Returns_41"></a>

### Returns

Balance of the token owner.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of">balance_of</a>(<a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of">balance_of</a>(<a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> <a href="">timestamp</a> = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start">get_next_epoch_start</a>();
    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at">balance_of_owner_at</a>(<a href="">pool</a>, token_owner, <a href="">timestamp</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_at"></a>

## Function `balance_of_at`

Get the balance of an token owner given a timestamp.


<a id="@Arguments_42"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the token.
* <code><a href="">timestamp</a></code> - Timestamp to get the balance.


<a id="@Returns_43"></a>

### Returns

Balance of the token owner.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_at">balance_of_at</a>(<a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_at">balance_of_at</a>(
    <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64
): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, token_owner, <a href="">timestamp</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner"></a>

## Function `balance_of_owner`

Get the balance of an owner in the current epoch.


<a id="@Arguments_44"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>owner</code> - Address of the owner.


<a id="@Returns_45"></a>

### Returns

Balance of the owner.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner">balance_of_owner</a>(<a href="">pool</a>: <b>address</b>, owner: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner">balance_of_owner</a>(<a href="">pool</a>: <b>address</b>, owner: <b>address</b>): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> <a href="">timestamp</a> = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_next_epoch_start">get_next_epoch_start</a>();
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at">balance_of_owner_at</a>(<a href="">pool</a>, owner, <a href="">timestamp</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at"></a>

## Function `balance_of_owner_at`

Get the balance of an owner given a timestamp.


<a id="@Arguments_46"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>owner</code> - Address of the owner.
* <code><a href="">timestamp</a></code> - Timestamp to get the balance.


<a id="@Returns_47"></a>

### Returns

Balance of the owner.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at">balance_of_owner_at</a>(<a href="">pool</a>: <b>address</b>, owner: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at">balance_of_owner_at</a>(
    <a href="">pool</a>: <b>address</b>, owner: <b>address</b>, <a href="">timestamp</a>: u64
): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, owner, <a href="">timestamp</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_from_token"></a>

## Function `earned_from_token`

Get the earned rewards using token.


<a id="@Arguments_48"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - Address of the token.
* <code>reward_token</code> - Address of the reward token.


<a id="@Returns_49"></a>

### Returns

(Total earned rewards, List of weekly paid rewards)


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_from_token">earned_from_token</a>(<a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, reward_token: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">bribe::WeeklyPaidReward</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_from_token">earned_from_token</a>(
    <a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, reward_token: <b>address</b>
): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt;) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view">earned_internal_view</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, token_owner, reward_token, <a href="">pool</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned"></a>

## Function `earned`

Get the earned rewards of an owner.


<a id="@Arguments_50"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>owner</code> - Address of the owner.
* <code>reward_token</code> - Address of the reward token.


<a id="@Returns_51"></a>

### Returns

(Total earned rewards, List of weekly paid rewards)


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned">earned</a>(<a href="">pool</a>: <b>address</b>, owner: <b>address</b>, reward_token: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">bribe::WeeklyPaidReward</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned">earned</a>(
    <a href="">pool</a>: <b>address</b>, owner: <b>address</b>, reward_token: <b>address</b>
): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt;) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view">earned_internal_view</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, owner, reward_token, <a href="">pool</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_many"></a>

## Function `earned_many`

Get the earned rewards of an owner for multiple pools.


<a id="@Arguments_52"></a>

### Arguments

* <code>pools</code> - List of liquidity pool addresses.
* <code>owner</code> - Address of the owner.
* <code>reward_token</code> - Address of the reward token.


<a id="@Returns_53"></a>

### Returns

(Total earned rewards across all pools, List of weekly paid rewards for each pool)


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_many">earned_many</a>(pools: <a href="">vector</a>&lt;<b>address</b>&gt;, owner: <b>address</b>, reward_token: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">bribe::WeeklyPaidReward</a>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_many">earned_many</a>(
    pools: <a href="">vector</a>&lt;<b>address</b>&gt;, owner: <b>address</b>, reward_token: <b>address</b>
): (u64, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt;&gt;) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> result = <a href="_empty">vector::empty</a>&lt;<a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt;&gt;();
    <b>let</b> total_earned = 0;

    <a href="_for_each">vector::for_each</a>(pools, |<a href="">pool</a>| {
        // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
        <b>let</b> (total, weekly_earned) = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned">earned</a>(<a href="">pool</a>, owner, reward_token);
        total_earned = total_earned + total;
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, weekly_earned);
    });
    (total_earned, result)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp"></a>

## Function `earned_with_timestamp`

Read earned amount given address and reward token, returns the rewards and the last user timestamp (used in case user do not claim since 50+ epochs)


<a id="@Arguments_54"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code>owner</code> - address of the owner
* <code>reward_token</code> - address of the reward token


<a id="@Returns_55"></a>

### Returns

(earned rewards, last user timestamp)


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp">earned_with_timestamp</a>(<a href="">pool</a>: <b>address</b>, owner: <b>address</b>, reward_token: <b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp">earned_with_timestamp</a>(
    <a href="">pool</a>: <b>address</b>, owner: <b>address</b>, reward_token: <b>address</b>
): (u64, u64) <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal">earned_with_timestamp_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, owner, reward_token, <a href="">pool</a>, <b>false</b>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token"></a>

## Function `reward_per_token`

Returns the rewards for a given token.


<a id="@Arguments_56"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">timestamp</a></code> - Timestamp to get the reward.
* <code>reward_token</code> - Address of the reward token.


<a id="@Returns_57"></a>

### Returns

* Reward per token.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token">reward_per_token</a>(<a href="">pool</a>: <b>address</b>, <a href="">timestamp</a>: u64, reward_token: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token">reward_per_token</a>(
    <a href="">pool</a>: <b>address</b>, <a href="">timestamp</a>: u64, reward_token: <b>address</b>
): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal">reward_per_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, <a href="">timestamp</a>, reward_token)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_token_list"></a>

## Function `reward_token_list`

Returns the list of reward tokens for a given liquidity pool.


<a id="@Arguments_58"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.


<a id="@Returns_59"></a>

### Returns

* List of reward token addresses.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_token_list">reward_token_list</a>(<a href="">pool</a>: <b>address</b>): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_token_list">reward_token_list</a>(
    <a href="">pool</a>: <b>address</b>
): <a href="">vector</a>&lt;<b>address</b>&gt; <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    // check <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> exist or not and get <b>address</b>
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_tokens
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_remaining_bribe_claim_calls"></a>

## Function `get_remaining_bribe_claim_calls`

Returns the remaining bribe claim calls for a given liquidity pool.


<a id="@Arguments_60"></a>

### Arguments

* <code><a href="">pool</a></code> - the liquidity pool address.
* <code><a href="">token</a></code> - the token address.
* <code>reward_token</code> - the reward token address.


<a id="@Returns_61"></a>

### Returns

* The remaining bribe claim calls.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_remaining_bribe_claim_calls">get_remaining_bribe_claim_calls</a>(<a href="">pool</a>: <b>address</b>, <a href="">token</a>: <b>address</b>, reward_token: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_remaining_bribe_claim_calls">get_remaining_bribe_claim_calls</a>(
    <a href="">pool</a>: <b>address</b>,
    <a href="">token</a>: <b>address</b>,
    reward_token: <b>address</b>
): u64 <b>acquires</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a> {
    <b>let</b> bribe_address = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_check_and_get_bribe_address">check_and_get_bribe_address</a>(<a href="">pool</a>);
    <b>let</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> = <b>borrow_global</b>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>&gt;(bribe_address);

    <b>let</b> token_owner = <a href="_owner">object::owner</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>));

    // claim until current epoch
    <b>let</b> user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal">user_last_reward_timestamp_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, token_owner, reward_token);

    // <b>if</b> user first time then set it <b>to</b> first <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> - week <b>to</b> avoid <a href="">any</a> <a href="">timestamp</a> problem
    <b>if</b> (user_last_time &lt; <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp) {
        user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp - <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;
    };
    <b>let</b> end_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>();

    <b>let</b> unclaimed_epochs = (end_timestamp - user_last_time) / <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;

    (unclaimed_epochs + 49) / <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_FIFTY_WEEKS">FIFTY_WEEKS</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal"></a>

## Function `add_reward_token_internal`

Internal function to add a reward token to the bribe


<a id="@Arguments_62"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code>reward_token</code> - Address of the reward token


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal">add_reward_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_add_reward_token_internal">add_reward_token_internal</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>
) {
    // Check whether <a href="">token</a> is reward <a href="">token</a> or not
    <b>if</b> (!*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.is_reward_token, reward_token, &<b>false</b>)) {
        <a href="_add">table::add</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.is_reward_token, reward_token, <b>true</b>);
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_tokens, reward_token);

        <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardTokenAddedEvent">RewardTokenAddedEvent</a> {
            <a href="">pool</a>,
            reward_token,
            gauge: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.gauge_address
        })
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal"></a>

## Function `get_reward_internal`

Internal function to get rewards for a user


<a id="@Arguments_63"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code>bribe_address</code> - Address of the bribe account
* <code>owner_address</code> - Address of the owner
* <code>reward_token</code> - Address of the reward token


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal">get_reward_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, bribe_address: <b>address</b>, owner_address: <b>address</b>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_internal">get_reward_internal</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>,
    bribe_address: <b>address</b>,
    owner_address: <b>address</b>,
    reward_token: <b>address</b>,
    <a href="">pool</a>: <b>address</b>
) {
    <b>let</b> (reward, user_last_time) = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal">earned_with_timestamp_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, owner_address, reward_token, <a href="">pool</a>, <b>true</b>);

    <b>if</b> (reward &gt; 0) {
        <b>let</b> reward_asset = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(reward_token);
        <b>assert</b>!(
            <a href="_balance">primary_fungible_store::balance</a>(bribe_address, reward_asset) &gt;= reward,
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE">ERROR_INSUFFICIENT_REWARD_TOKEN_BALANCE</a>
        );
        <b>let</b> bribe_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.extended_ref);
        <a href="_transfer">primary_fungible_store::transfer</a>(
            &bribe_signer,
            reward_asset,
            owner_address,
            reward
        );
        <a href="_emit">event::emit</a>(
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_RewardPaidEvent">RewardPaidEvent</a> {
                user: owner_address,
                reward,
                reward_token,
                <a href="">pool</a>,
                ts: <a href="_now_seconds">timestamp::now_seconds</a>()
            }
        );
    };

    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, owner_address)) {
        <b>let</b> owner_reward_last_timestamp = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, owner_address);
        <a href="_upsert">table::upsert</a>(owner_reward_last_timestamp, reward_token, user_last_time);
    } <b>else</b> {
        <b>let</b> owner_reward_last_timestamp: Table&lt;<b>address</b>, u64&gt; = <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;();
        <a href="_add">table::add</a>(&<b>mut</b> owner_reward_last_timestamp, reward_token, user_last_time);
        <a href="_add">table::add</a>(&<b>mut</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, owner_address, owner_reward_last_timestamp);
    };
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view"></a>

## Function `earned_internal_view`

Internal function to calculate earned rewards


<a id="@Arguments_64"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code>owner</code> - Address of the owner
* <code>reward_token</code> - Address of the reward token
* <code><a href="">pool</a></code> - Address of the pool


<a id="@Returns_65"></a>

### Returns

(Total earned rewards, List of weekly paid rewards)


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view">earned_internal_view</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, owner: <b>address</b>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">bribe::WeeklyPaidReward</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal_view">earned_internal_view</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>,
    owner: <b>address</b>,
    reward_token: <b>address</b>,
    <a href="">pool</a>: <b>address</b>
): (u64, <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt;) {
    // claim until current epoch
    <b>let</b> user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal">user_last_reward_timestamp_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, owner, reward_token);
    <b>let</b> end_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>();
    <b>let</b> rewards: <a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a>&gt; = <a href="">vector</a>[];
    <b>let</b> total_rewards = 0;

    <b>if</b> (end_timestamp == user_last_time) {
        <b>return</b> (total_rewards, rewards)
    };

    <b>let</b> week = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;

    // <b>if</b> user first time then set it <b>to</b> first <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> - week <b>to</b> avoid <a href="">any</a> <a href="">timestamp</a> problem
    <b>if</b> (user_last_time &lt; <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp) {
        user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp - week;
    };

    <b>let</b> current_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>();

    <b>loop</b> {
        <b>if</b> (user_last_time == end_timestamp) {
            // <b>if</b> we reach the current epoch, exit
            <b>break</b>
        };

        <b>let</b> week_reward = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal">earned_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, owner, user_last_time, reward_token);
        <b>if</b> (week_reward &gt; 0) {
            total_rewards = total_rewards + week_reward;
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> rewards, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">WeeklyPaidReward</a> {
                user: owner,
                reward_token,
                reward: week_reward,
                <a href="">pool</a>,
                gauge: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.gauge_address,
                week: user_last_time,
                ts: current_timestamp
            });
        };

        user_last_time = user_last_time + week;
    };

    <b>return</b> (total_rewards, rewards)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal"></a>

## Function `earned_with_timestamp_internal`

Internal function to calculate earned rewards with timestamp


<a id="@Arguments_66"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code>owner</code> - Address of the owner
* <code>reward_token</code> - Address of the reward token
* <code><a href="">pool</a></code> - Address of the pool
* <code>is_event_emit</code> - Whether to emit events or not


<a id="@Returns_67"></a>

### Returns

(Total earned rewards, Last user timestamp)


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal">earned_with_timestamp_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, owner: <b>address</b>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>, is_event_emit: bool): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_with_timestamp_internal">earned_with_timestamp_internal</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>, owner: <b>address</b>, reward_token: <b>address</b>, <a href="">pool</a>: <b>address</b>, is_event_emit: bool
): (u64, u64) {
    // claim until current epoch
    <b>let</b> user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal">user_last_reward_timestamp_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.user_timestamp, owner, reward_token);
    <b>let</b> week = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WEEK">WEEK</a>;

    // <b>if</b> user first time then set it <b>to</b> first <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> - week <b>to</b> avoid <a href="">any</a> <a href="">timestamp</a> problem
    <b>if</b> (user_last_time &lt; <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp) {
        user_last_time = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.first_bribe_timestamp - week;
    };

    <b>let</b> reward = 0;
    <b>let</b> end_timestamp = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>();
    <b>let</b> current_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>();
    for (i in 0..<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_FIFTY_WEEKS">FIFTY_WEEKS</a>) {
        <b>if</b> (user_last_time == end_timestamp) {
            // <b>if</b> we reach the current epoch, exit
            <b>break</b>
        };

        <b>let</b> week_reward = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal">earned_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, owner, user_last_time, reward_token);
        <b>if</b> (is_event_emit) {
            <a href="_emit">event::emit</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidRewardEvent">WeeklyPaidRewardEvent</a> {
                user: owner,
                reward_token,
                reward: week_reward,
                <a href="">pool</a>,
                gauge: <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.gauge_address,
                week: user_last_time,
                ts: current_timestamp
            });
        };

        reward = reward + week_reward;
        user_last_time = user_last_time + week;
    };

    (reward, user_last_time)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal"></a>

## Function `reward_per_token_internal`

Internal function to calculate reward per token


<a id="@Arguments_68"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code><a href="">timestamp</a></code> - Timestamp to get the reward
* <code>reward_token</code> - Address of the reward token


<a id="@Returns_69"></a>

### Returns

* Reward per token


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal">reward_per_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, <a href="">timestamp</a>: u64, reward_token: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal">reward_per_token_internal</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>, <a href="">timestamp</a>: u64, reward_token: <b>address</b>
): u64 {
    <b>let</b> total_supply = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.total_supply, <a href="">timestamp</a>, &0);
    <b>let</b> reward_per_epoch = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal">reward_per_epoch_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.reward_data, reward_token, <a href="">timestamp</a>);

    <b>if</b> (*total_supply == 0) {
        <b>return</b> reward_per_epoch
    };

    // calculation may lose precision in some case
    (reward_per_epoch * <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_MULTIPLIER">MULTIPLIER</a>) / *total_supply
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal"></a>

## Function `earned_internal`

Internal function to calculate earned rewards for a user


<a id="@Arguments_70"></a>

### Arguments

* <code><a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a></code> - Reference to the Bribe object
* <code>owner</code> - Address of the owner
* <code><a href="">timestamp</a></code> - Timestamp to get the rewards
* <code>reward_token</code> - Address of the reward token


<a id="@Returns_71"></a>

### Returns

Earned rewards for the user


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal">earned_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">bribe::Bribe</a>, owner: <b>address</b>, <a href="">timestamp</a>: u64, reward_token: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_internal">earned_internal</a>(
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>: &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Bribe">Bribe</a>,
    owner: <b>address</b>,
    <a href="">timestamp</a>: u64,
    reward_token: <b>address</b>
): u64 {
    <b>let</b> balance = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(&<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>.balance, owner, <a href="">timestamp</a>);
    <b>if</b> (balance == 0) { 0 }
    <b>else</b> {
        <b>let</b> reward_per_token = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_token_internal">reward_per_token_internal</a>(<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>, <a href="">timestamp</a>, reward_token);

        // calculation may lose precision in some case
        <b>let</b> rewards = (reward_per_token * balance) / <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_MULTIPLIER">MULTIPLIER</a>;
        rewards
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal"></a>

## Function `balance_of_owner_at_internal`

Internal function to get the balance of an owner at a specific timestamp


<a id="@Arguments_72"></a>

### Arguments

* <code>balance</code> - Reference to the balance table
* <code>owner</code> - Address of the owner
* <code><a href="">timestamp</a></code> - Timestamp to get the balance


<a id="@Returns_73"></a>

### Returns

Balance of the owner at the specified timestamp


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(balance: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;u64, u64&gt;&gt;, owner: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_balance_of_owner_at_internal">balance_of_owner_at_internal</a>(
    balance: &Table&lt;<b>address</b>, aptos_std::table::Table&lt;u64, u64&gt;&gt;,
    owner: <b>address</b>,
    <a href="">timestamp</a>: u64
): u64 {
    <b>if</b> (<a href="_contains">table::contains</a>(balance, owner)) {
        <b>let</b> owner_balance = <a href="_borrow">table::borrow</a>(balance, owner);
        *<a href="_borrow_with_default">table::borrow_with_default</a>(owner_balance, <a href="">timestamp</a>, &0)
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal"></a>

## Function `reward_per_epoch_internal`

Internal function to get the reward per epoch for a given reward token and timestamp


<a id="@Arguments_74"></a>

### Arguments

* <code>reward_data</code> - Reference to the reward data table
* <code>reward_token</code> - Address of the reward token
* <code><a href="">timestamp</a></code> - Timestamp to get the reward per epoch


<a id="@Returns_75"></a>

### Returns

Reward per epoch for the specified reward token and timestamp


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal">reward_per_epoch_internal</a>(reward_data: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;u64, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">bribe::Reward</a>&gt;&gt;, reward_token: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_reward_per_epoch_internal">reward_per_epoch_internal</a>(
    reward_data: &Table&lt;<b>address</b>, Table&lt;u64, <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a>&gt;&gt;,
    reward_token: <b>address</b>,
    <a href="">timestamp</a>: u64
): u64 {
    <b>if</b> (<a href="_contains">table::contains</a>(reward_data, reward_token)) {
        <b>let</b> reward_token_timestamp = <a href="_borrow">table::borrow</a>(reward_data, reward_token);
        <a href="_borrow_with_default">table::borrow_with_default</a>(
            reward_token_timestamp,
            <a href="">timestamp</a>,
            &<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_Reward">Reward</a> { last_update_time: 0, period_finish: 0, rewards_per_epoch: 0 }
        ).rewards_per_epoch
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal"></a>

## Function `user_last_reward_timestamp_internal`

Internal function to get the last reward timestamp for a user and reward token


<a id="@Arguments_76"></a>

### Arguments

* <code>user_timestamp</code> - Reference to the user timestamp table
* <code>owner</code> - Address of the owner
* <code>reward_token</code> - Address of the reward token


<a id="@Returns_77"></a>

### Returns

Last reward timestamp for the specified user and reward token


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal">user_last_reward_timestamp_internal</a>(user_timestamp: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;, owner: <b>address</b>, reward_token: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_user_last_reward_timestamp_internal">user_last_reward_timestamp_internal</a>(
    user_timestamp: &Table&lt;<b>address</b>, Table&lt;<b>address</b>, u64&gt;&gt;,
    owner: <b>address</b>,
    reward_token: <b>address</b>
): u64 {
    <b>if</b> (<a href="_contains">table::contains</a>(user_timestamp, owner)) {
        <b>let</b> user_timestamp_internal = <a href="_borrow">table::borrow</a>(user_timestamp, owner);
        *<a href="_borrow_with_default">table::borrow_with_default</a>(user_timestamp_internal, reward_token, &0)
    } <b>else</b> { 0 }
}
</code></pre>



</details>
