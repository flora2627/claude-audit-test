
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::voting_escrow`



-  [Struct `CommitOwnershipEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CommitOwnershipEvent)
-  [Struct `ApplyOwnershipEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ApplyOwnershipEvent)
-  [Struct `CreateLockEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CreateLockEvent)
-  [Struct `IncreaseAmountEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_IncreaseAmountEvent)
-  [Struct `ExtendLockupEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ExtendLockupEvent)
-  [Struct `MergeLockEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MergeLockEvent)
-  [Struct `SplitLockEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SplitLockEvent)
-  [Struct `WithdrawEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WithdrawEvent)
-  [Struct `SupplyEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SupplyEvent)
-  [Struct `ChangeVoterEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ChangeVoterEvent)
-  [Struct `BurnNFTEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_BurnNFTEvent)
-  [Struct `Point`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point)
-  [Struct `LockedBalance`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance)
-  [Struct `SlopeChange`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange)
-  [Resource `VotingEscrow`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow)
-  [Resource `TokenRef`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_init_module)
    -  [Arguments](#@Arguments_1)
-  [Function `set_voter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_set_voter)
    -  [Arguments](#@Arguments_2)
-  [Function `commit_transfer_ownership`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_commit_transfer_ownership)
    -  [Arguments](#@Arguments_3)
-  [Function `apply_transfer_ownership`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_apply_transfer_ownership)
    -  [Arguments](#@Arguments_4)
-  [Function `checkpoint`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_checkpoint)
-  [Function `create_lock`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock)
    -  [Arguments](#@Arguments_5)
-  [Function `create_lock_for`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_for)
    -  [Arguments](#@Arguments_6)
-  [Function `increase_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_amount)
    -  [Arguments](#@Arguments_7)
-  [Function `increase_unlock_time`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_unlock_time)
    -  [Arguments](#@Arguments_8)
-  [Function `merge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_merge)
    -  [Arguments](#@Arguments_9)
    -  [Dev](#@Dev_10)
-  [Function `split`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_split)
    -  [Arguments](#@Arguments_11)
-  [Function `withdraw`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_withdraw)
    -  [Arguments](#@Arguments_12)
    -  [Dev](#@Dev_13)
-  [Function `create_relock`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_relock)
    -  [Arguments](#@Arguments_14)
-  [Function `get_voting_escrow_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address)
-  [Function `get_last_user_slope`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_last_user_slope)
    -  [Arguments](#@Arguments_15)
    -  [Returns](#@Returns_16)
-  [Function `user_point_history_ts`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history_ts)
    -  [Arguments](#@Arguments_17)
    -  [Returns](#@Returns_18)
-  [Function `locked_end`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_end)
    -  [Arguments](#@Arguments_19)
    -  [Returns](#@Returns_20)
-  [Function `locked_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_amount)
    -  [Arguments](#@Arguments_21)
    -  [Returns](#@Returns_22)
-  [Function `find_block_epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch)
    -  [Parameters](#@Parameters_23)
    -  [Returns](#@Returns_24)
-  [Function `balance_of`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of)
    -  [Arguments](#@Arguments_25)
    -  [Returns](#@Returns_26)
-  [Function `balance_of_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of_at)
    -  [Arguments](#@Arguments_27)
    -  [Returns](#@Returns_28)
-  [Function `supply_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at)
    -  [Arguments](#@Arguments_29)
    -  [Returns](#@Returns_30)
-  [Function `total_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply)
    -  [Returns](#@Returns_31)
-  [Function `total_supply_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply_at)
    -  [Arguments](#@Arguments_32)
    -  [Returns](#@Returns_33)
-  [Function `epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch)
    -  [Returns](#@Returns_34)
-  [Function `point_history`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history)
    -  [Arguments](#@Arguments_35)
    -  [Returns](#@Returns_36)
    -  [Dev](#@Dev_37)
-  [Function `user_point_history`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history)
    -  [Arguments](#@Arguments_38)
    -  [Returns](#@Returns_39)
    -  [Dev](#@Dev_40)
-  [Function `user_point_epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch)
    -  [Arguments](#@Arguments_41)
    -  [Returns](#@Returns_42)
-  [Function `balance_after_merge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_merge)
    -  [Arguments](#@Arguments_43)
    -  [Returns](#@Returns_44)
-  [Function `balance_after_extend_time`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_extend_time)
    -  [Arguments](#@Arguments_45)
    -  [Returns](#@Returns_46)
-  [Function `balance_after_increase_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_increase_amount)
    -  [Arguments](#@Arguments_47)
    -  [Returns](#@Returns_48)
-  [Function `get_current_token_id`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_current_token_id)
    -  [Returns](#@Returns_49)
-  [Function `is_voter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_is_voter)
    -  [Arguments](#@Arguments_50)
-  [Function `voting`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_voting)
    -  [Arguments](#@Arguments_51)
-  [Function `abstain`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_abstain)
    -  [Arguments](#@Arguments_52)
-  [Function `create_lock_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal)
    -  [Arguments](#@Arguments_53)
-  [Function `assert_if_not_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner)
    -  [Arguments](#@Arguments_54)
-  [Function `check_point_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal)
    -  [Parameters](#@Parameters_55)
-  [Function `deposit_for_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal)
    -  [Arguments](#@Arguments_56)
-  [Function `mint_nft`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft)
    -  [Arguments](#@Arguments_57)
    -  [Returns](#@Returns_58)
-  [Function `burn_nft`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft)
    -  [Arguments](#@Arguments_59)
-  [Function `toggle_transfer`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer)
    -  [Arguments](#@Arguments_60)
-  [Function `get_token_details`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_details)
    -  [Arguments](#@Arguments_61)
    -  [Returns](#@Returns_62)
-  [Function `get_token_name`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_name)
    -  [Arguments](#@Arguments_63)
    -  [Returns](#@Returns_64)
-  [Function `get_token_description`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_description)
    -  [Arguments](#@Arguments_65)
    -  [Returns](#@Returns_66)
-  [Function `get_token_uri`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_uri)
    -  [Arguments](#@Arguments_67)


<pre><code><b>use</b> <a href="">0x1::block</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::royalty</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="base64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::base64</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
<b>use</b> <a href="i64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_i64">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::i64</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CommitOwnershipEvent"></a>

## Struct `CommitOwnershipEvent`

Represents the commitment to transfer ownership of the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CommitOwnershipEvent">CommitOwnershipEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ApplyOwnershipEvent"></a>

## Struct `ApplyOwnershipEvent`

Represents the application of ownership transfer in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ApplyOwnershipEvent">ApplyOwnershipEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CreateLockEvent"></a>

## Struct `CreateLockEvent`

Represents a create lock action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CreateLockEvent">CreateLockEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><b>to</b>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>locktime: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_IncreaseAmountEvent"></a>

## Struct `IncreaseAmountEvent`

Represents a increase lock amount action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_IncreaseAmountEvent">IncreaseAmountEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>locktime: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ExtendLockupEvent"></a>

## Struct `ExtendLockupEvent`

Represents a increase lock time action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ExtendLockupEvent">ExtendLockupEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>locktime: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MergeLockEvent"></a>

## Struct `MergeLockEvent`

Represents a merge lock action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MergeLockEvent">MergeLockEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>locktime: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>burned_token: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SplitLockEvent"></a>

## Struct `SplitLockEvent`

Represents a split lock action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SplitLockEvent">SplitLockEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>locktime: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>burned_token: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WithdrawEvent"></a>

## Struct `WithdrawEvent`

Represents a withdrawal action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WithdrawEvent">WithdrawEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>provider: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>value: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SupplyEvent"></a>

## Struct `SupplyEvent`

Represents a supply change in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SupplyEvent">SupplyEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>prev_supply: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>supply: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ChangeVoterEvent"></a>

## Struct `ChangeVoterEvent`

Represents a change in the voter address in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ChangeVoterEvent">ChangeVoterEvent</a> <b>has</b> drop, store
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_BurnNFTEvent"></a>

## Struct `BurnNFTEvent`

Represents burn action in the VotingEscrow contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_BurnNFTEvent">BurnNFTEvent</a> <b>has</b> drop, store
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
<code>ts: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point"></a>

## Struct `Point`

Use to store voting power and decay rate at a specific point in time
For track users and global voting power


<pre><code><b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bias: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>slope: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ts: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>blk: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance"></a>

## Struct `LockedBalance`

User locked balance and lock end time


<pre><code><b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>end: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange"></a>

## Struct `SlopeChange`

Represents a change in slope at a specific timestamp, used for tracking voting power decay


<pre><code><b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>slope: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>is_negative: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow"></a>

## Resource `VotingEscrow`

Store voting escrow state and user data


<pre><code><b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>locked: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">voting_escrow::LockedBalance</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>point_history: <a href="_Table">table::Table</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">voting_escrow::Point</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>user_point_history: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">voting_escrow::Point</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>user_point_epoch: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>slope_changes: <a href="_Table">table::Table</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">voting_escrow::SlopeChange</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>supply: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>future_admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>extended_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>voted: <a href="_Table">table::Table</a>&lt;<b>address</b>, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>collection_extend_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>mutator_ref: <a href="_MutatorRef">collection::MutatorRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>token_id: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef"></a>

## Resource `TokenRef`

Represents a reference to a token, used for burning and transferring tokens


<pre><code><b>struct</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>burn_ref: <a href="_BurnRef">token::BurnRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>transfer_ref: <a href="_TransferRef">object::TransferRef</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_DESCRIPTION"></a>



<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_DESCRIPTION">COLLECTION_DESCRIPTION</a>: <a href="">vector</a>&lt;u8&gt; = [68, 101, 120, 108, 121, 110, 32, 78, 70, 84, 32, 99, 111, 108, 108, 101, 99, 116, 105, 111, 110, 32, 102, 111, 114, 32, 118, 111, 116, 105, 110, 103, 32, 101, 115, 99, 114, 111, 119, 32, 99, 111, 110, 116, 114, 97, 99, 116];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SC_ADMIN"></a>

Creator address for the VotingEscrow contract object account.


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE"></a>

Scaling factor (10^4) for scale amount


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a>: u64 = 10000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_NAME"></a>



<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_NAME">COLLECTION_NAME</a>: <a href="">vector</a>&lt;u8&gt; = [68, 69, 88, 76, 89, 78, 95, 67, 79, 76, 76, 69, 67, 84, 73, 79, 78];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_URL"></a>



<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_URL">COLLECTION_URL</a>: <a href="">vector</a>&lt;u8&gt; = [104, 116, 116, 112, 115, 58, 47, 47, 100, 101, 120, 108, 121, 110, 46, 99, 111, 109, 47, 95, 110, 101, 120, 116, 47, 105, 109, 97, 103, 101, 63, 117, 114, 108, 61, 37, 50, 70, 105, 109, 97, 103, 101, 115, 37, 50, 70, 100, 101, 120, 108, 121, 110, 45, 116, 111, 107, 101, 110, 111, 109, 105, 99, 115, 46, 119, 101, 98, 112, 38, 119, 61, 49, 57, 50, 48, 38, 113, 61, 55, 53];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ADMIN_NOT_SET"></a>

Future admin must be set to apply ownership transfer


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ADMIN_NOT_SET">ERROR_ADMIN_NOT_SET</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_BLOCK_NUMBER_EXCEEDED"></a>

Block number exceeds the current block height


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_BLOCK_NUMBER_EXCEEDED">ERROR_BLOCK_NUMBER_EXCEEDED</a>: u64 = 111;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_CAN_ONLY_INCREASE_LOCK_DURATION"></a>

Unlock time can only be increased, not decreased (must be greater than current lock end)


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_CAN_ONLY_INCREASE_LOCK_DURATION">ERROR_CAN_ONLY_INCREASE_LOCK_DURATION</a>: u64 = 109;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME"></a>

Token addresses must be different for merging


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME">ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME</a>: u64 = 117;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST"></a>

Either from_token or to_token does not exist (token not issued by the contract)


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST">ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST</a>: u64 = 118;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INSUFFICIENT_DXLYN_COIN"></a>

User must have sufficient DXLYN tokens for the operation


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INSUFFICIENT_DXLYN_COIN">ERROR_INSUFFICIENT_DXLYN_COIN</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_UNLOCK_TIME"></a>

Unlock time must be in the future


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_UNLOCK_TIME">ERROR_INVALID_UNLOCK_TIME</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_WEIGHT"></a>

Invalid weight value in the split weights vector (must be greater than zero)


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_WEIGHT">ERROR_INVALID_WEIGHT</a>: u64 = 119;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_IS_EXPIRED"></a>

Lock has expired for the NFT token


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_IS_EXPIRED">ERROR_LOCK_IS_EXPIRED</a>: u64 = 108;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_NOT_EXPIRED"></a>

Lock must be expired before withdrawal


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_NOT_EXPIRED">ERROR_LOCK_NOT_EXPIRED</a>: u64 = 110;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_ADMIN"></a>

Caller must be the admin to perform the operation


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_NFT_OWNER"></a>

Caller must be the owner of the NFT token


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_NFT_OWNER">ERROR_NOT_NFT_OWNER</a>: u64 = 115;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_VOTER"></a>

Caller must be a voter to perform the operation


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>: u64 = 113;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND"></a>

No existing lock found for the NFT token


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST"></a>

Remove vote for the NFT token from the gauge before performing this action


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST">ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST</a>: u64 = 114;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN"></a>

Remove vote for the from_token from the gauge before merging


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN">ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN</a>: u64 = 116;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS"></a>

Unlock time must be no more than 4 years


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS">ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO"></a>

Value must be greater than zero for the operation


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO">ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ZERO_ADDRESS"></a>

Address cannot be the zero address


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>: u64 = 112;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME"></a>

Maximum lock duration of 4 years in seconds


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>: u64 = 126144000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MERGE_TYPE"></a>

Represents merging two locks into one


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MERGE_TYPE">MERGE_TYPE</a>: u8 = 1;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MULTIPLIER"></a>

Scaling factor (10^12) for precision in calculations


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MULTIPLIER">MULTIPLIER</a>: u64 = 1000000000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ONE_TWENTY_EIGHT_EPOCHS"></a>

For iterations of epochs


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>: u64 = 128;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SPLIT_TYPE"></a>

Represents splitting a lock into two or more separate locks


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SPLIT_TYPE">SPLIT_TYPE</a>: u8 = 2;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TWO_FIFTY_FIVE_WEEKS"></a>

For iterations of weeks


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TWO_FIFTY_FIVE_WEEKS">TWO_FIFTY_FIVE_WEEKS</a>: u64 = 255;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VOTING_ESCROW_SEED"></a>

Seeds for creating unique object addresses for the voting escrow


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VOTING_ESCROW_SEED">VOTING_ESCROW_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [86, 79, 84, 73, 78, 71, 95, 69, 83, 67, 82, 79, 87];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK"></a>

One week in seconds (7 days), used to round lock times


<pre><code><b>const</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_init_module"></a>

## Function `init_module`

Initializes the VotingEscrow contract


<a id="@Arguments_1"></a>

### Arguments

* <code>sender</code> - The signer creating the VotingEscrow contract


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_init_module">init_module</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_init_module">init_module</a>(sender: &<a href="">signer</a>) {
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(sender, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VOTING_ESCROW_SEED">VOTING_ESCROW_SEED</a>);

    <b>let</b> initial_point_history = <a href="_new">table::new</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a>&gt;();
    <a href="_add">table::add</a>(
        &<b>mut</b> initial_point_history,
        0,
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> {
            bias: 0,
            slope: 0,
            ts: <a href="_now_seconds">timestamp::now_seconds</a>(),
            blk: <a href="_get_current_block_height">block::get_current_block_height</a>()
        }
    );

    <b>let</b> ve_signer = <a href="_generate_signer">object::generate_signer</a>(&constructor_ref);
    // Created NFT <a href="">collection</a> for the <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> contract
    <b>let</b> collection_constructor_ref = <a href="_create_unlimited_collection">collection::create_unlimited_collection</a>(&ve_signer,
        <a href="_utf8">string::utf8</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_DESCRIPTION">COLLECTION_DESCRIPTION</a>),
        <a href="_utf8">string::utf8</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_NAME">COLLECTION_NAME</a>),
        <a href="_none">option::none</a>(),
        <a href="_utf8">string::utf8</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_COLLECTION_URL">COLLECTION_URL</a>)
    );

    <b>move_to</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(
        &ve_signer,
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
            locked: <a href="_new">table::new</a>&lt;<b>address</b>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a>&gt;(),
            point_history: initial_point_history,
            user_point_history: <a href="_new">table::new</a>&lt;<b>address</b>, Table&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a>&gt;&gt;(),
            user_point_epoch: <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;(),
            slope_changes: <a href="_new">table::new</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a>&gt;(),
            epoch: 0,
            supply: 0,
            admin: @voting_escrow_admin,
            future_admin: @0x0,
            extended_ref: <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref),
            <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: @voting_escrow_voter,
            voted: <a href="_new">table::new</a>&lt;<b>address</b>, bool&gt;(),
            collection_extend_ref: <a href="_generate_extend_ref">object::generate_extend_ref</a>(&collection_constructor_ref),
            mutator_ref: <a href="_generate_mutator_ref">collection::generate_mutator_ref</a>(&collection_constructor_ref),
            token_id: 0
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_set_voter"></a>

## Function `set_voter`

Set a new voter address for the VotingEscrow contract.


<a id="@Arguments_2"></a>

### Arguments

* <code>admin</code> - The signer.
* <code>new_voter</code> - The new voter address to set.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_set_voter">set_voter</a>(admin: &<a href="">signer</a>, new_voter: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_set_voter">set_voter</a>(admin: &<a href="">signer</a>, new_voter: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>assert</b>!(new_voter != @0x0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>assert</b>!(address_of(admin) == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.admin, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ChangeVoterEvent">ChangeVoterEvent</a> { old_voter: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, new_voter });

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = new_voter;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_commit_transfer_ownership"></a>

## Function `commit_transfer_ownership`

Transfers ownership of the VotingEscrow contract to <code>new_admin</code>.


<a id="@Arguments_3"></a>

### Arguments

* <code>admin</code> - The current admin signer.
* <code>new_admin</code> - The address to transfer ownership to.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_commit_transfer_ownership">commit_transfer_ownership</a>(admin: &<a href="">signer</a>, new_admin: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_commit_transfer_ownership">commit_transfer_ownership</a>(admin: &<a href="">signer</a>, new_admin: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>assert</b>!(address_of(admin) == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.admin, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.future_admin = new_admin;

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CommitOwnershipEvent">CommitOwnershipEvent</a> { admin: new_admin });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_apply_transfer_ownership"></a>

## Function `apply_transfer_ownership`

Transfers the ownership of the VotingEscrow to the future admin if the caller is the current admin.


<a id="@Arguments_4"></a>

### Arguments

* <code>admin</code> - The signer.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_apply_transfer_ownership">apply_transfer_ownership</a>(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_apply_transfer_ownership">apply_transfer_ownership</a>(admin: &<a href="">signer</a>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>assert</b>!(address_of(admin) == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.admin, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);
    <b>assert</b>!(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.future_admin != @0x0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_ADMIN_NOT_SET">ERROR_ADMIN_NOT_SET</a>);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.admin = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.future_admin;

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ApplyOwnershipEvent">ApplyOwnershipEvent</a> { admin: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.future_admin });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_checkpoint"></a>

## Function `checkpoint`

Record global data to checkpoint


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_checkpoint">checkpoint</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_checkpoint">checkpoint</a>() <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    //notice Record <b>global</b> data <b>to</b> checkpoint
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> empty_lock = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 };
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, @0x0, &empty_lock, &empty_lock);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock"></a>

## Function `create_lock`

Deposit <code>value</code> tokens for <code>user</code> and lock until <code>unlock_time</code>.


<a id="@Arguments_5"></a>

### Arguments

* <code>user</code> - The signer.
* <code>value</code> - Amount to deposit.
* <code>unlock_time</code> - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock">create_lock</a>(user: &<a href="">signer</a>, value: u64, unlock_time: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock">create_lock</a>(
    user: &<a href="">signer</a>, value: u64, unlock_time: u64
) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal">create_lock_internal</a>(user, value, unlock_time, address_of(user));
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_for"></a>

## Function `create_lock_for`

Deposit <code>value</code> tokens for <code><b>to</b></code> and lock until <code>unlock_time</code>.


<a id="@Arguments_6"></a>

### Arguments

* <code>caller</code> - The signer.
* <code>value</code> - Amount to deposit.
* <code>unlock_time</code> - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).
* <code><b>to</b></code> - Address of the user to receive the NFT token.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_for">create_lock_for</a>(caller: &<a href="">signer</a>, value: u64, unlock_time: u64, <b>to</b>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_for">create_lock_for</a>(
    caller: &<a href="">signer</a>, value: u64, unlock_time: u64, <b>to</b>: <b>address</b>
) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal">create_lock_internal</a>(caller, value, unlock_time, <b>to</b>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_amount"></a>

## Function `increase_amount`

Deposit <code>value</code> additional tokens for <code>NFT <a href="">token</a></code> without modifying the unlock time.


<a id="@Arguments_7"></a>

### Arguments

* <code>user</code> - The signer.
* <code><a href="">token</a></code> - Address of the NFT token.
* <code>value</code> - Amount of tokens to deposit and add to the lock.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_amount">increase_amount</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_amount">increase_amount</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, value: u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>assert</b>!(value &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO">ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO</a>);

    <b>let</b> user_address = address_of(user);

    // Check <b>if</b> the user is the owner of the <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, <a href="">token</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> locked =
        *<a href="_borrow_with_default">table::borrow_with_default</a>(
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
            <a href="">token</a>,
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 }
        );

    <b>assert</b>!(locked.amount &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>);
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>assert</b>!(locked.end &gt; current_time, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_IS_EXPIRED">ERROR_LOCK_IS_EXPIRED</a>);

    <b>let</b> lock_end = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, user, <a href="">token</a>, value, 0, 0);

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_IncreaseAmountEvent">IncreaseAmountEvent</a> {
        provider: user_address,
        <a href="">token</a>,
        value,
        locktime: lock_end,
        ts: current_time,
        nft_name: <a href="_name">token::name</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>))
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_unlock_time"></a>

## Function `increase_unlock_time`

Extends the unlock time for the NFT token to the specified <code>unlock_time</code>.


<a id="@Arguments_8"></a>

### Arguments

* <code>user</code> - The signer.
* <code><a href="">token</a></code> - Address of the NFT token.
* <code>unlock_time</code> - New epoch time for unlocking (current time + lock period)


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_unlock_time">increase_unlock_time</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, unlock_time: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_increase_unlock_time">increase_unlock_time</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, unlock_time: u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> unlock_time_internal = (unlock_time / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>) * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>; //Unlock time is rounded down <b>to</b> weeks

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>assert</b>!(unlock_time_internal &lt;= current_time + <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS">ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS</a>);

    <b>let</b> user_address = address_of(user);

    // Check <b>if</b> the user is the owner of the <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, <a href="">token</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> locked =
        *<a href="_borrow_with_default">table::borrow_with_default</a>(
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
            <a href="">token</a>,
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 }
        );

    <b>assert</b>!(locked.amount &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>);
    <b>assert</b>!(locked.end &gt; current_time, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_IS_EXPIRED">ERROR_LOCK_IS_EXPIRED</a>);
    <b>assert</b>!(unlock_time_internal &gt; locked.end, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_CAN_ONLY_INCREASE_LOCK_DURATION">ERROR_CAN_ONLY_INCREASE_LOCK_DURATION</a>);

    <b>let</b> lock_end = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>,
        user,
        <a href="">token</a>,
        0,
        unlock_time_internal,
        0
    );

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ExtendLockupEvent">ExtendLockupEvent</a> {
        provider: user_address,
        <a href="">token</a>,
        value: 0,
        locktime: lock_end,
        ts: current_time,
        nft_name: <a href="_name">token::name</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>))
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_merge"></a>

## Function `merge`

Merge <code>from_token</code> into <code>to_token</code> for the user.


<a id="@Arguments_9"></a>

### Arguments

* <code>user</code> - The signer.
* <code>from_token</code> - Address of the NFT token to merge from.
* <code>to_token</code> - Address of the NFT token to merge into.


<a id="@Dev_10"></a>

### Dev

Before merging the dxlyn token user must remove the vote from the gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_merge">merge</a>(user: &<a href="">signer</a>, from_token: <b>address</b>, to_token: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_merge">merge</a>(user: &<a href="">signer</a>, from_token: <b>address</b>, to_token: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>assert</b>!(from_token != to_token, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME">ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME</a>);

    <b>let</b> user_address = address_of(user);

    // Check <b>if</b> the user is the owner of both tokens
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, from_token);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, to_token);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    // Check is <a href="">token</a> voted or not before merge the position
    <b>assert</b>!(
        !*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.voted, from_token, &<b>false</b>),
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN">ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST_FOR_FROM_TOKEN</a>
    );

    <b>assert</b>!(
        <a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, from_token) && <a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, to_token),
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST">ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST</a>
    );

    <b>let</b> locked0 = *<a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, from_token);

    <b>let</b> locked1 = *<a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, to_token);

    <b>let</b> value0 = locked0.amount;
    // Find the maximum end time of the two tokens
    <b>let</b> end = max(locked0.end, locked1.end);

    // Make from_token locked balance zero
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, from_token, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 });

    // Perform checkpoint for from_token
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, from_token, &locked0, &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 });

    // Reduce the supply so when it's add supply remains the same
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply - value0;

    // Burn the from_token NFT
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft">burn_nft</a>(from_token);

    // Deposit the merged amount into to_token
    <b>let</b> lock_end = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, user, to_token, value0, end, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MERGE_TYPE">MERGE_TYPE</a>);

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MergeLockEvent">MergeLockEvent</a> {
        provider: user_address,
        <a href="">token</a>: to_token,
        value: value0,
        locktime: lock_end,
        ts: <a href="_now_seconds">timestamp::now_seconds</a>(),
        nft_name: <a href="_name">token::name</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(to_token)),
        burned_token: from_token
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_split"></a>

## Function `split`

Split the locked amount of <code><a href="">token</a></code> into multiple parts.


<a id="@Arguments_11"></a>

### Arguments

* <code>user</code> - The signer.
* <code>amount</code> - Vector of amounts % to split the locked balance into.
* <code><a href="">token</a></code> - Address of the NFT token to split.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_split">split</a>(user: &<a href="">signer</a>, split_weights: <a href="">vector</a>&lt;u64&gt;, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_split">split</a>(user: &<a href="">signer</a>, split_weights: <a href="">vector</a>&lt;u64&gt;, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> user_address = address_of(user);

    // Check <b>if</b> the user is the owner of the <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, <a href="">token</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    // Check is <a href="">token</a> voted or not before split the position
    <b>assert</b>!(!*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.voted, <a href="">token</a>, &<b>false</b>), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST">ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST</a>);

    <b>let</b> default_locked = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 };

    <b>let</b> locked = *<a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>, default_locked);

    <b>let</b> end = locked.end;
    <b>let</b> value = locked.amount;

    <b>assert</b>!(value &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>);

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();

    <b>assert</b>!(end &gt; current_time, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_UNLOCK_TIME">ERROR_INVALID_UNLOCK_TIME</a>);
    <b>assert</b>!(end &lt;= current_time + <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS">ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS</a>);

    // reset supply, deposit_for_internal increase it
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply - value;

    <b>let</b> total_weight = 0;

    <a href="_for_each">vector::for_each</a>(split_weights, |weight| {
        <b>assert</b>!(weight &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_WEIGHT">ERROR_INVALID_WEIGHT</a>);
        total_weight = total_weight + weight;
    });

    // remove <b>old</b> data
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>, default_locked);

    // Perform checkpoint for <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, <a href="">token</a>, &locked, &default_locked);

    // Burn the NFT <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft">burn_nft</a>(<a href="">token</a>);

    // added _ because of compiler warning
    <b>let</b> _value_internal = 0;

    <a href="_for_each">vector::for_each</a>(split_weights, |weight| {
        _value_internal = value * weight / total_weight;

        <b>let</b> (minted_token_address, token_name) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft">mint_nft</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, user_address, end, _value_internal);

        // Deposit the split amount into the new NFT <a href="">token</a>
        <b>let</b> lock_end = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(
            <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>,
            user,
            minted_token_address,
            _value_internal,
            end,
            <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SPLIT_TYPE">SPLIT_TYPE</a>
        );

        <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SplitLockEvent">SplitLockEvent</a> {
            provider: user_address,
            <a href="">token</a>: minted_token_address,
            value: _value_internal,
            locktime: lock_end,
            ts: <a href="_now_seconds">timestamp::now_seconds</a>(),
            nft_name: token_name,
            burned_token: <a href="">token</a>
        });
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_withdraw"></a>

## Function `withdraw`

Withdraw all tokens for <code>NFT <a href="">token</a></code>


<a id="@Arguments_12"></a>

### Arguments

* <code>user</code> - The signer.
* <code><a href="">token</a></code> - Address of the NFT token.


<a id="@Dev_13"></a>

### Dev

Before withdrawing the dxlyn token user must remove the vote from the gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_withdraw">withdraw</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_withdraw">withdraw</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> user_address = address_of(user);

    // Check <b>if</b> the user is the owner of the <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(user_address, <a href="">token</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    // Check is <a href="">token</a> voted or not before withdraw the dxlyn <a href="">token</a>
    <b>assert</b>!(!*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.voted, <a href="">token</a>, &<b>false</b>), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST">ERROR_REMOVE_VOTE_FROM_GAUGE_FIRST</a>);

    <b>let</b> locked =
        *<a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(
            &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
            <a href="">token</a>,
            <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 }
        );
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>assert</b>!(current_time &gt;= locked.end, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_NOT_EXPIRED">ERROR_LOCK_NOT_EXPIRED</a>);

    <b>let</b> value = locked.amount;
    <b>let</b> old_locked = locked;
    locked.end = 0;
    locked.amount = 0;
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>, locked);
    <b>let</b> supply_before = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply;
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply = subtract_or_zero(supply_before, value);

    // old_locked can have either expired &lt;= <a href="">timestamp</a> or zero end
    // Locked <b>has</b> only 0 end
    // Both can have &gt;= 0 amount
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>,
        <a href="">token</a>,
        &old_locked,
        &locked
    );

    // Transfer DXLYN <a href="">token</a> from voting escrow <a href="">object</a> <a href="">account</a> <b>to</b> users <a href="">account</a>
    <a href="_transfer">primary_fungible_store::transfer</a>(
        // ve_signer
        &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.extended_ref),
        <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
        user_address,
        value
    );

    // Burn the NFT <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft">burn_nft</a>(<a href="">token</a>);

    <a href="_emit">event::emit</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WithdrawEvent">WithdrawEvent</a> {
            provider: user_address,
            <a href="">token</a>,
            value,
            ts: current_time
        }
    );
    <a href="_emit">event::emit</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SupplyEvent">SupplyEvent</a> { prev_supply: supply_before, supply: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_relock"></a>

## Function `create_relock`

Withdraw all tokens for <code><a href="">token</a></code> and create a new lock with <code>unlock_time</code>.


<a id="@Arguments_14"></a>

### Arguments

* <code>user</code> - The signer.
* <code><a href="">token</a></code> - Address of the NFT token.
* <code>unlock_time</code> - New epoch time for unlocking (current time + lock period)


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_relock">create_relock</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, unlock_time: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_relock">create_relock</a>(user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, unlock_time: u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> value = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_amount">locked_amount</a>(<a href="">token</a>);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_withdraw">withdraw</a>(user, <a href="">token</a>);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal">create_lock_internal</a>(user, value, unlock_time, address_of(user));
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address"></a>

## Function `get_voting_escrow_address`

Get the address of the VotingEscrow contract


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SC_ADMIN">SC_ADMIN</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VOTING_ESCROW_SEED">VOTING_ESCROW_SEED</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_last_user_slope"></a>

## Function `get_last_user_slope`

Get the most recently recorded rate of voting power decrease for <code><a href="">token</a></code>.


<a id="@Arguments_15"></a>

### Arguments

* <code><a href="">token</a></code> - Address of the token.


<a id="@Returns_16"></a>

### Returns

Value of the slope.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_last_user_slope">get_last_user_slope</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_last_user_slope">get_last_user_slope</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    // Check <b>if</b> the point history and user point epoch is found
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>) && <a href="_contains">table::contains</a>(
        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch,
        <a href="">token</a>
    )) {
        <b>let</b> user_point = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>);
        <b>let</b> user_epoch = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch, <a href="">token</a>);

        // Check <b>if</b> the user point is found
        <b>if</b> (!<a href="_contains">table::contains</a>(user_point, *user_epoch)) {
            <b>return</b> 0
        };
        <a href="_borrow">table::borrow</a>(user_point, *user_epoch).slope
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history_ts"></a>

## Function `user_point_history_ts`

Get the timestamp for checkpoint <code>epoch</code> for <code><a href="">token</a></code>.


<a id="@Arguments_17"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code>epoch</code> - User epoch number.


<a id="@Returns_18"></a>

### Returns

Epoch time of the checkpoint.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history_ts">user_point_history_ts</a>(<a href="">token</a>: <b>address</b>, epoch: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history_ts">user_point_history_ts</a>(<a href="">token</a>: <b>address</b>, epoch: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    // Check <b>if</b> the point history is found
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>)) {
        <b>let</b> user_point = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>);
        // Check <b>if</b> the user point is found
        <b>if</b> (!<a href="_contains">table::contains</a>(user_point, epoch)) {
            <b>return</b> 0
        };
        <a href="_borrow">table::borrow</a>(user_point, epoch).ts
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_end"></a>

## Function `locked_end`

Get the timestamp when the lock for the given <code><a href="">token</a></code> finishes.


<a id="@Arguments_19"></a>

### Arguments

* <code><a href="">token</a></code> - token address.


<a id="@Returns_20"></a>

### Returns

Epoch time of the lock end.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_end">locked_end</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_end">locked_end</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>)) {
        <b>return</b> 0
    };
    <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>).end
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_amount"></a>

## Function `locked_amount`

Get the locked amount (DXLYN locked).


<a id="@Arguments_21"></a>

### Arguments

* <code><a href="">token</a></code> - token address.


<a id="@Returns_22"></a>

### Returns

Locked dxlyn amount.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_amount">locked_amount</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_locked_amount">locked_amount</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>)) {
        <b>return</b> 0
    };
    <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>).amount
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch"></a>

## Function `find_block_epoch`

Binary search to estimate timestamp for a given block number.


<a id="@Parameters_23"></a>

### Parameters

- <code><a href="">block</a></code>: Block number to find.
- <code>max_epoch</code>: Maximum epoch to search up to.


<a id="@Returns_24"></a>

### Returns

Approximate epoch for the given block.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch">find_block_epoch</a>(<a href="">block</a>: u64, max_epoch: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch">find_block_epoch</a>(<a href="">block</a>: u64, max_epoch: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> <b>min</b> = 0;
    <b>let</b> max = max_epoch;
    <b>let</b> default_point = &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { blk: 0, ts: 0, bias: 0, slope: 0 };

    //Binary search
    for (i in 0..<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>) {
        <b>if</b> (<b>min</b> &gt;= max) { <b>break</b> };
        <b>let</b> mid = (<b>min</b> + max + 1) / 2;
        <b>let</b> blk = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, mid, default_point).blk;
        <b>if</b> (blk &lt;= <a href="">block</a>) {
            <b>min</b> = mid;
        } <b>else</b> {
            max = mid - 1;
        };
    };

    <b>min</b>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of"></a>

## Function `balance_of`

Get the current voting power for a NFT token.


<a id="@Arguments_25"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code>t</code> - Epoch time to return voting power at.


<a id="@Returns_26"></a>

### Returns

User voting power in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of">balance_of</a>(<a href="">token</a>: <b>address</b>, t: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of">balance_of</a>(<a href="">token</a>: <b>address</b>, t: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> epoch = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch, <a href="">token</a>, &0);
    <b>if</b> (epoch == 0) {
        <b>return</b> 0 // No lock, no voting power
    } <b>else</b> {
        // Check is user point history <b>exists</b>
        <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>)) {
            <b>let</b> user_history = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>);
            <b>let</b> last_point =
                *<a href="_borrow_with_default">table::borrow_with_default</a>(
                    user_history,
                    epoch,
                    &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, ts: 0, blk: 0 }
                );

            // Prevent underflow and ensure non-negative
            // It will <b>return</b> bias
            subtract_or_zero(last_point.bias, last_point.slope * subtract_or_zero(t, last_point.ts))
        } <b>else</b> { 0 }
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of_at"></a>

## Function `balance_of_at`

Measure voting power of <code>NFT <a href="">token</a></code> at block height <code><a href="">block</a></code>.


<a id="@Arguments_27"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code><a href="">block</a></code> - Block to calculate the voting power at.


<a id="@Returns_28"></a>

### Returns

Voting power in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of_at">balance_of_at</a>(<a href="">token</a>: <b>address</b>, <a href="">block</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of_at">balance_of_at</a>(<a href="">token</a>: <b>address</b>, <a href="">block</a>: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> current_blk_height = <a href="_get_current_block_height">block::get_current_block_height</a>();
    <b>assert</b>!(<a href="">block</a> &lt;= current_blk_height, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_BLOCK_NUMBER_EXCEEDED">ERROR_BLOCK_NUMBER_EXCEEDED</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> <b>min</b> = 0;
    <b>let</b> max = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch, <a href="">token</a>, &0);
    <b>let</b> default_point = &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { blk: 0, ts: 0, bias: 0, slope: 0 };
    //Binary search
    for (i in 0..<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>) {
        <b>if</b> (<b>min</b> &gt;= max) { <b>break</b> };
        <b>let</b> mid = (<b>min</b> + max + 1) / 2;
        <b>let</b> blk = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, mid, default_point).blk;
        <b>if</b> (blk &lt;= <a href="">block</a>) {
            <b>min</b> = mid;
        } <b>else</b> {
            max = mid - 1;
        };
    };

    // Check is user point history <b>exists</b>
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>)) {
        <b>let</b> point_history = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>);
        <b>let</b> upoint = *<a href="_borrow_with_default">table::borrow_with_default</a>(point_history, <b>min</b>, default_point);
        <b>let</b> max_epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch;
        <b>let</b> epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch">find_block_epoch</a>(<a href="">block</a>, max_epoch);
        <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
        <b>let</b> point_0 = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch, default_point);

        <b>let</b> (d_block, d_t) = <b>if</b> (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch">epoch</a> &lt; max_epoch) {
            <b>let</b> point_1 = <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch + 1, default_point);
            (subtract_or_zero(point_1.blk, point_0.blk), subtract_or_zero(point_1.ts, point_0.ts))
        } <b>else</b> {
            (subtract_or_zero(current_blk_height, point_0.blk), subtract_or_zero(
                <a href="_now_seconds">timestamp::now_seconds</a>(),
                point_0.ts
            ))
        };
        <b>let</b> block_time = point_0.ts;
        <b>if</b> (d_block &gt; 0) {
            block_time = block_time + (d_t * subtract_or_zero(<a href="">block</a>, point_0.blk) / d_block);
        };

        upoint.bias = subtract_or_zero(upoint.bias, upoint.slope * subtract_or_zero(block_time, upoint.ts));
        upoint.bias
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at"></a>

## Function `supply_at`

Calculate total voting power at some point in the past.


<a id="@Arguments_29"></a>

### Arguments

* <code>point</code> - The point (bias/slope/ts/blk) to start search from.
* <code>t</code> - Time to calculate the total voting power at.


<a id="@Returns_30"></a>

### Returns

Total voting power at that time in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at">supply_at</a>(point_bias: u64, point_slope: u64, point_ts: u64, point_blk: u64, t: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at">supply_at</a>(
    point_bias: u64,
    point_slope: u64,
    point_ts: u64,
    point_blk: u64,
    t: u64
): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> last_point = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: point_bias, slope: point_slope, ts: point_ts, blk: point_blk };
    <b>let</b> week = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>;
    <b>let</b> t_i = (last_point.ts / week) * week;
    <b>let</b> default_slope_change = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> };
    for (i in 0..<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TWO_FIFTY_FIVE_WEEKS">TWO_FIFTY_FIVE_WEEKS</a>) {
        t_i = t_i + week;
        <b>let</b> d_slope = default_slope_change;
        <b>if</b> (t_i &gt; t) {
            t_i = t;
        } <b>else</b> {
            d_slope = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes, t_i, &default_slope_change);
        };
        last_point.bias = subtract_or_zero(
            last_point.bias,
            last_point.slope * subtract_or_zero(t_i, last_point.ts)
        );
        <b>if</b> (t_i == t) { <b>break</b> };

        //manual handel <b>if</b> slope is negative
        last_point.slope = i64::safe_subtract_or_add(last_point.slope, d_slope.slope, d_slope.is_negative);
        last_point.ts = t_i;
    };

    last_point.bias
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply"></a>

## Function `total_supply`

Calculate total voting power.


<a id="@Returns_31"></a>

### Returns

Total voting power in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply">total_supply</a>(t: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply">total_supply</a>(t: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch;

    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch)) {
        <b>return</b> 0
    };
    <b>let</b> last_point = <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at">supply_at</a>(
        last_point.bias,
        last_point.slope,
        last_point.ts,
        last_point.blk,
        t
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply_at"></a>

## Function `total_supply_at`

Calculate total voting power at some point in the past.


<a id="@Arguments_32"></a>

### Arguments

* <code><a href="">block</a></code> - Block to calculate the total voting power at.


<a id="@Returns_33"></a>

### Returns

Total voting power at <code><a href="">block</a></code> in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply_at">total_supply_at</a>(<a href="">block</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply_at">total_supply_at</a>(<a href="">block</a>: u64): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>assert</b>!(<a href="">block</a> &lt;= <a href="_get_current_block_height">block::get_current_block_height</a>(), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_BLOCK_NUMBER_EXCEEDED">ERROR_BLOCK_NUMBER_EXCEEDED</a>);
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch;
    <b>let</b> target_epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_find_block_epoch">find_block_epoch</a>(<a href="">block</a>, epoch);
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>let</b> point =
        *<a href="_borrow_with_default">table::borrow_with_default</a>(
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history,
            target_epoch,
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { blk: 0, ts: 0, bias: 0, slope: 0 }
        );
    <b>let</b> dt: u64 = 0;
    <b>if</b> (target_epoch &lt; epoch) {
        <b>let</b> point_next =
            *<a href="_borrow_with_default">table::borrow_with_default</a>(
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history,
                target_epoch + 1,
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { blk: 0, ts: 0, bias: 0, slope: 0 }
            );
        <b>if</b> (point.blk != point_next.blk) {
            dt = (<a href="">block</a> - point.blk) * (point_next.ts - point.ts) / (point_next.blk - point.blk);
        };
    } <b>else</b> {
        <b>if</b> (point.blk != <a href="_get_current_block_height">block::get_current_block_height</a>()) {
            dt = (<a href="">block</a> - point.blk) * (<a href="_now_seconds">timestamp::now_seconds</a>() - point.ts) / (<a href="_get_current_block_height">block::get_current_block_height</a>(
            ) - point.blk);
        };
    };

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_supply_at">supply_at</a>(
        point.bias,
        point.slope,
        point.ts,
        point.blk,
        point.ts + dt
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch"></a>

## Function `epoch`

Returns the current epoch.


<a id="@Returns_34"></a>

### Returns

The current epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch">epoch</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch">epoch</a>(): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history"></a>

## Function `point_history`

Returns the current point history for the given epoch.


<a id="@Arguments_35"></a>

### Arguments

* <code>epoch</code> - Epoch to get the point history for.


<a id="@Returns_36"></a>

### Returns

Tuple containing (bias, slope, block, timestamp).


<a id="@Dev_37"></a>

### Dev

If the point history is not found, returns (0, 0, 0, 0).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history">point_history</a>(epoch: u64): (u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history">point_history</a>(epoch: u64): (u64, u64, u64, u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <b>let</b> point =
        *<a href="_borrow_with_default">table::borrow_with_default</a>(
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history,
            epoch,
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { ts: 0, bias: 0, slope: 0, blk: 0 }
        );
    (point.bias, point.slope, point.blk, point.ts)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history"></a>

## Function `user_point_history`

Returns the current token point history.


<a id="@Arguments_38"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code>epoch</code> - Epoch to get the point history for.


<a id="@Returns_39"></a>

### Returns

User's point history (bias, slope, block, timestamp).


<a id="@Dev_40"></a>

### Dev

If the token has no point history, returns (0, 0, 0, 0).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">user_point_history</a>(<a href="">token</a>: <b>address</b>, epoch: u64): (u64, u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">user_point_history</a>(
    <a href="">token</a>: <b>address</b>, epoch: u64
): (u64, u64, u64, u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    // Check <b>if</b> the <a href="">token</a> <b>has</b> point history
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>)) {
        <b>let</b> point =
            <a href="_borrow_with_default">table::borrow_with_default</a>(
                <a href="_borrow">table::borrow</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>),
                epoch,
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, ts: 0, blk: 0 }
            );
        (point.bias, point.slope, point.blk, point.ts)
    } <b>else</b> {
        (0, 0, 0, 0)
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch"></a>

## Function `user_point_epoch`

Returns the current NFT token epoch.


<a id="@Arguments_41"></a>

### Arguments

* <code><a href="">token</a></code> - token address.


<a id="@Returns_42"></a>

### Returns

NFT token epoch. If the token has no epoch, returns 0.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch">user_point_epoch</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch">user_point_epoch</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch, <a href="">token</a>, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_merge"></a>

## Function `balance_after_merge`

Returns the balance(voting power) after merge.


<a id="@Arguments_43"></a>

### Arguments

* <code>from_token</code> - token address.
* <code>to_token</code> - token address.


<a id="@Returns_44"></a>

### Returns

Tuple containing (new_power, from_token_power).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_merge">balance_after_merge</a>(from_token: <b>address</b>, to_token: <b>address</b>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_merge">balance_after_merge</a>(
    from_token: <b>address</b>,
    to_token: <b>address</b>
): (u64, u64) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>assert</b>!(from_token != to_token, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME">ERROR_FROM_TOKEN_AND_TO_TOKEN_ARE_SAME</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>assert</b>!(
        <a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, from_token) && <a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, to_token),
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST">ERROR_FROM_TOKEN_OR_TO_TOKEN_DOES_NOT_EXIST</a>
    );

    <b>let</b> locked0 = *<a href="_borrow">table::borrow</a>(
        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
        from_token
    );

    <b>let</b> locked1 = *<a href="_borrow">table::borrow</a>(
        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
        to_token,
    );

    <b>let</b> value = locked0.amount + locked1.amount;

    // Find the maximum end time of the two tokens
    <b>let</b> lock_end = max(locked0.end, locked1.end);

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    // <b>as</b> we are adding the amount of from_token <b>to</b> to_token, so we need <b>to</b> calculate the power increase by max lock time
    <b>let</b> incresed_power_by = (locked0.amount * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a> / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>) * (lock_end - current_time);
    <b>let</b> new_power = (value * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a> / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>) * (lock_end - current_time);

    (new_power, incresed_power_by)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_extend_time"></a>

## Function `balance_after_extend_time`

Returns the balance(voting power) after extend time.


<a id="@Arguments_45"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code>time_to_extend</code> - time to extend. ( if want to extend lock by one week, pass 604800 )


<a id="@Returns_46"></a>

### Returns

New balance(voting power).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_extend_time">balance_after_extend_time</a>(<a href="">token</a>: <b>address</b>, time_to_extend: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_extend_time">balance_after_extend_time</a>(
    <a href="">token</a>: <b>address</b>,
    time_to_extend: u64
): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>);

    <b>let</b> locked = *<a href="_borrow">table::borrow</a>(
        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
        <a href="">token</a>
    );

    <b>let</b> unlock_time_internal = ((locked.end + time_to_extend) / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>) * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>; //Unlock time is rounded down <b>to</b> weeks

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>assert</b>!(unlock_time_internal &lt;= current_time + <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS">ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS</a>);

    (locked.amount * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a> / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>) * (unlock_time_internal - current_time)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_increase_amount"></a>

## Function `balance_after_increase_amount`

Returns the balance(voting power) after increase amount.


<a id="@Arguments_47"></a>

### Arguments

* <code><a href="">token</a></code> - token address.
* <code>amount_to_increase</code> - amount to increase.


<a id="@Returns_48"></a>

### Returns

New balance(voting power).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_increase_amount">balance_after_increase_amount</a>(<a href="">token</a>: <b>address</b>, amount_to_increase: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_after_increase_amount">balance_after_increase_amount</a>(
    <a href="">token</a>: <b>address</b>,
    amount_to_increase: u64
): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NO_EXISTING_LOCK_FOUND">ERROR_NO_EXISTING_LOCK_FOUND</a>);

    <b>let</b> locked = *<a href="_borrow">table::borrow</a>(
        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
        <a href="">token</a>
    );

    <b>assert</b>!(amount_to_increase &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO">ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO</a>);

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>assert</b>!(locked.end &gt; current_time, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_LOCK_IS_EXPIRED">ERROR_LOCK_IS_EXPIRED</a>);

    ((locked.amount + amount_to_increase) * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a> / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>) * (locked.end - current_time)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_current_token_id"></a>

## Function `get_current_token_id`

Returns the current token id.


<a id="@Returns_49"></a>

### Returns

Current token id


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_current_token_id">get_current_token_id</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_current_token_id">get_current_token_id</a>(): u64 <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address).token_id
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_is_voter"></a>

## Function `is_voter`

Check sender is voter or not


<a id="@Arguments_50"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The address of the sender.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_is_voter">is_voter</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_is_voter">is_voter</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: <b>address</b>): bool <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_voting"></a>

## Function `voting`

Set token as voted in gauge.


<a id="@Arguments_51"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The signer.
* <code><a href="">token</a></code> - Address of the token to set voting status for.


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_voting">voting</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_voting">voting</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>assert</b>!(address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>) == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>);

    // Disable transfer of <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer">toggle_transfer</a>(<a href="">token</a>, <b>false</b>);

    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.voted, <a href="">token</a>, <b>true</b>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_abstain"></a>

## Function `abstain`

Set token as abstained for gauge.


<a id="@Arguments_52"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The signer.
* <code><a href="">token</a></code> - Address of the token to set abstention status for.


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_abstain">abstain</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_abstain">abstain</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    <b>assert</b>!(address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>) == <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_VOTER">ERROR_NOT_VOTER</a>);

    // Enable transfer of <a href="">token</a>
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer">toggle_transfer</a>(<a href="">token</a>, <b>true</b>);

    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.voted, <a href="">token</a>, <b>false</b>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal"></a>

## Function `create_lock_internal`

Deposit <code>value</code> tokens for <code><b>to</b></code> and lock until <code>unlock_time</code>.


<a id="@Arguments_53"></a>

### Arguments

* <code>user</code> - The signer.
* <code>value</code> - Amount to deposit.
* <code>unlock_time</code> - Epoch time when tokens unlock, rounded down to whole weeks (current time + lock period).
* <code><b>to</b></code> - Address of the user to receive the NFT token.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal">create_lock_internal</a>(user: &<a href="">signer</a>, value: u64, unlock_time: u64, <b>to</b>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_create_lock_internal">create_lock_internal</a>(
    user: &<a href="">signer</a>, value: u64, unlock_time: u64, <b>to</b>: <b>address</b>
) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a> {
    <b>assert</b>!(value &gt; 0, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO">ERROR_VALUE_MUST_BE_GRATER_THEN_ZERO</a>);

    <b>let</b> unlock_time_internal = (unlock_time / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>) * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>;
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();

    <b>assert</b>!(unlock_time_internal &gt; current_time, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INVALID_UNLOCK_TIME">ERROR_INVALID_UNLOCK_TIME</a>);
    <b>assert</b>!(unlock_time_internal &lt;= current_time + <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS">ERROR_UNLOCK_TIME_NOT_MORE_THEN_4_YEARS</a>);

    <b>let</b> voting_escrow_address = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>();
    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a> = <b>borrow_global_mut</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>&gt;(voting_escrow_address);

    // Mint NFT for the <b>to</b> <b>address</b>
    <b>let</b> (minted_token_address, token_name) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft">mint_nft</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>, <b>to</b>, unlock_time_internal, value);

    <b>let</b> lock_end = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>,
        user,
        minted_token_address,
        value,
        unlock_time_internal,
        0
    );

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_CreateLockEvent">CreateLockEvent</a> {
        provider: address_of(user),
        <b>to</b>,
        <a href="">token</a>: minted_token_address,
        value,
        locktime: lock_end,
        ts: <a href="_now_seconds">timestamp::now_seconds</a>(),
        nft_name: token_name
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner"></a>

## Function `assert_if_not_owner`

Assert if the sender is not the owner of the token.


<a id="@Arguments_54"></a>

### Arguments

* <code>sender</code> - The address of the sender.
* <code><a href="">token</a></code> - The address of the token to check ownership for.


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(sender: <b>address</b>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">assert_if_not_owner</a>(sender: <b>address</b>, <a href="">token</a>: <b>address</b>) {
    <b>let</b> token_object = <a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(<a href="">token</a>);
    <b>assert</b>!(<a href="_is_owner">object::is_owner</a>(token_object, sender), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_NOT_NFT_OWNER">ERROR_NOT_NFT_OWNER</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal"></a>

## Function `check_point_internal`

Record global and per-user data to checkpoint.


<a id="@Parameters_55"></a>

### Parameters

- <code><a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a></code>: The mutable voting escrow resource.
- <code><a href="">token</a></code>: token address. No user checkpoint if <code>0x0</code>.
- <code>old_locked</code>: Previous locked amount / end lock time for the token.
- <code>new_locked</code>: New locked amount / end lock time for the token.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">voting_escrow::VotingEscrow</a>, <a href="">token</a>: <b>address</b>, old_locked: &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">voting_escrow::LockedBalance</a>, new_locked: &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">voting_escrow::LockedBalance</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>,
    <a href="">token</a>: <b>address</b>,
    old_locked: &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a>,
    new_locked: &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a>
) {
    <b>let</b> u_old: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, blk: 0, ts: 0 };
    <b>let</b> u_new: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, blk: 0, ts: 0 };
    <b>let</b> old_dslope: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> };
    <b>let</b> new_dslope: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> };
    <b>let</b> epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch;
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>let</b> current_blk_height = <a href="_get_current_block_height">block::get_current_block_height</a>();

    <b>if</b> (<a href="">token</a> != @0x0) {
        // Calculate slopes and biases
        // Kept at zero when they have <b>to</b>
        <b>if</b> (old_locked.end &gt; current_time && old_locked.amount &gt; 0) {
            //scaled amount for handel precision loss
            u_old.slope = (old_locked.amount * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a>) / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>;
            u_old.bias = u_old.slope * (old_locked.end - current_time);
        };

        <b>if</b> (new_locked.end &gt; current_time && new_locked.amount &gt; 0) {
            //scaled amount for handel precision loss
            u_new.slope = (new_locked.amount * <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_AMOUNT_SCALE">AMOUNT_SCALE</a>) / <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MAXTIME">MAXTIME</a>;
            u_new.bias = u_new.slope * (new_locked.end - current_time);
        };

        // Read values of scheduled changes in the slope
        // old_locked.end can be in the past and in the future
        // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
        old_dslope =
            *<a href="_borrow_with_default">table::borrow_with_default</a>(
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes,
                old_locked.end,
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> }
            );
        <b>if</b> (new_locked.end &gt; 0) {
            <b>if</b> (new_locked.end == old_locked.end) {
                new_dslope = <b>copy</b> old_dslope;
            } <b>else</b> {
                new_dslope =
                    *<a href="_borrow_with_default">table::borrow_with_default</a>(
                        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes,
                        new_locked.end,
                        &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> }
                    );
            }
        };
    };

    <b>let</b> last_point: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, blk: current_blk_height, ts: current_time };
    <b>if</b> (epoch &gt; 0) {
        last_point =
            *<a href="_borrow_with_default">table::borrow_with_default</a>(
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history,
                epoch,
                &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> { bias: 0, slope: 0, blk: 0, ts: 0 }
            );
    };
    <b>let</b> last_checkpoint: u64 = last_point.ts;
    // initial_last_point is used for extrapolation <b>to</b> calculate <a href="">block</a> number
    // (approximately, for *At methods) and save them
    // <b>as</b> we cannot figure that out exactly from inside the contract
    <b>let</b> initial_last_point: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a> = <b>copy</b> last_point;
    <b>let</b> block_slope: u64 = 0;

    <b>let</b> multiplier: u64 = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MULTIPLIER">MULTIPLIER</a>;
    <b>if</b> (current_time &gt; last_point.ts) {
        block_slope = multiplier * (current_blk_height - last_point.blk) / (current_time - last_point.ts);
    };
    // If last point is already recorded in this <a href="">block</a>, slope=0
    // But that's ok b/c we know the <a href="">block</a> in such case

    <b>let</b> week = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_WEEK">WEEK</a>;

    // Go over weeks <b>to</b> fill history and calculate what the current point is
    <b>let</b> t_i = (last_checkpoint / week) * week;
    for (i in 0..<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TWO_FIFTY_FIVE_WEEKS">TWO_FIFTY_FIVE_WEEKS</a>) {
        // Hopefully it won't happen that this won't get used in 5 years!
        // If it does, users will be able <b>to</b> withdraw but vote weight will be broken
        t_i = t_i + week;
        <b>let</b> d_slope: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> };
        <b>if</b> (t_i &gt; current_time) {
            t_i = current_time;
        } <b>else</b> {
            d_slope =
                *<a href="_borrow_with_default">table::borrow_with_default</a>(
                    &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes,
                    t_i,
                    &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SlopeChange">SlopeChange</a> { slope: 0, is_negative: <b>false</b> }
                );
        };

        //decay voting power for week
        last_point.bias = i64::subtract_or_zero(
            last_point.bias,
            last_point.slope * (t_i - last_checkpoint)
        );

        //decay slope rate for week
        last_point.slope = i64::safe_subtract_or_add(
            last_point.slope, d_slope.slope, d_slope.is_negative
        );

        last_checkpoint = t_i;
        last_point.ts = t_i;
        last_point.blk = initial_last_point.blk + block_slope * (t_i - initial_last_point.ts) / multiplier;
        epoch = epoch + 1;

        <b>if</b> (t_i == current_time) {
            last_point.blk = current_blk_height;
            <b>break</b>
        } <b>else</b> {
            <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch, last_point);
        }
    };

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.epoch = epoch;
    // Now point_history is filled until t=now

    <b>if</b> (<a href="">token</a> != @0x0) {
        // If last point was in this <a href="">block</a>, the slope change <b>has</b> been applied already
        // But in such case we have 0 slope(s)
        // for handle slope changes incase negative
        <b>let</b> (slope_diff, slope_diff_is_negative) = i64::safe_subtract_u64(u_new.slope, u_old.slope);

        // for handle slope changes incase negative
        <b>let</b> (bias_diff, bias_diff_is_negative) = i64::safe_subtract_u64(u_new.bias, u_old.bias);
        //safe subtract <b>if</b> slope difference is negative other wise just add slope diff <b>to</b> last_point.slope
        last_point.slope = i64::safe_subtract_or_add(last_point.slope, slope_diff, slope_diff_is_negative);

        //safe subtract <b>if</b> bias difference is negative other wise just add bias diff <b>to</b> last_point.bias
        last_point.bias = i64::safe_subtract_or_add(last_point.bias, bias_diff, bias_diff_is_negative);
    };

    // Record the changed point into history
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.point_history, epoch, last_point);

    <b>if</b> (<a href="">token</a> != @0x0) {
        // Schedule the slope changes (slope is going down)
        // We subtract new_user_slope from [new_locked.end]
        // and add old_user_slope <b>to</b> [old_locked.end]
        <b>if</b> (old_locked.end &gt; current_time) {
            // old_dslope was &lt;something&gt; - u_old.slope, so we cancel that
            // Cancel previous old_dslope
            <b>let</b> (i_old_dslope, i_old_dslope_is_negative) =
                i64::safe_add(
                    <a href="_from_u64">i64::from_u64</a>(old_dslope.slope, old_dslope.is_negative),
                    <a href="_from_u64">i64::from_u64</a>(u_old.slope, <b>false</b>)
                );
            old_dslope.slope = i_old_dslope;
            old_dslope.is_negative = i_old_dslope_is_negative;

            // Handle new deposit (new_locked.end == old_locked.end)
            //It was a new deposit, not extension
            <b>if</b> (new_locked.end == old_locked.end) {
                <b>let</b> (i_old_dslope, i_old_dslope_is_negative) =
                    i64::safe_sub(
                        <a href="_from_u64">i64::from_u64</a>(old_dslope.slope, old_dslope.is_negative),
                        <a href="_from_u64">i64::from_u64</a>(u_new.slope, <b>false</b>)
                    );
                old_dslope.slope = i_old_dslope;
                old_dslope.is_negative = i_old_dslope_is_negative;
            };

            //<b>update</b> slope changes
            <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes, old_locked.end, old_dslope);
        };

        <b>if</b> (new_locked.end &gt; current_time) {
            <b>if</b> (new_locked.end &gt; old_locked.end) {
                // <b>old</b> slope disappeared at this point
                <b>let</b> (i_new_dslope, i_new_dslope_is_negative) =
                    i64::safe_sub(
                        <a href="_from_u64">i64::from_u64</a>(new_dslope.slope, new_dslope.is_negative),
                        <a href="_from_u64">i64::from_u64</a>(u_new.slope, <b>false</b>)
                    );
                new_dslope.slope = i_new_dslope;
                new_dslope.is_negative = i_new_dslope_is_negative;

                <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.slope_changes, new_locked.end, new_dslope);
            };
            // <b>else</b>: we recorded it already in old_dslope
        };

        // Now handle <a href="">token</a> history
        <b>let</b> user_epoch = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_epoch, <a href="">token</a>, 0);
        *user_epoch = *user_epoch + 1;
        u_new.ts = current_time;
        u_new.blk = current_blk_height;

        <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>)) {
            <b>let</b> history =
                <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>);
            <a href="_upsert">table::upsert</a>(history, *user_epoch, u_new);
        } <b>else</b> {
            <b>let</b> history = <a href="_new">table::new</a>&lt;u64, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_Point">Point</a>&gt;();
            <a href="_add">table::add</a>(&<b>mut</b> history, *user_epoch, u_new);
            <a href="_add">table::add</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.user_point_history, <a href="">token</a>, history);
        };
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal"></a>

## Function `deposit_for_internal`

Deposit and lock tokens for a NFT token.


<a id="@Arguments_56"></a>

### Arguments

* <code>user</code> - The signer.
* <code><a href="">token</a></code> - Address of the NFT token.
* <code>value</code> - Amount to deposit.
* <code>unlock_time</code> - New time when to unlock the tokens, or 0 if unchanged (current time + lock period).
* <code>type</code> - Type of operation (create lock, increase amount, increase unlock time).


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">voting_escrow::VotingEscrow</a>, user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, value: u64, unlock_time: u64, type: u8): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_deposit_for_internal">deposit_for_internal</a>(
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>,
    user: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, value: u64, unlock_time: u64, type: u8
): u64 {
    <b>let</b> locked_balance =
        <a href="_borrow_with_default">table::borrow_with_default</a>(
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked,
            <a href="">token</a>,
            &<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> { amount: 0, end: 0 }
        );
    <b>let</b> locked = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_LockedBalance">LockedBalance</a> {
        amount: locked_balance.amount,
        end: locked_balance.end
    };
    <b>let</b> supply_before = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply;

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply = supply_before + value;
    <b>let</b> old_locked = locked;

    // Adding <b>to</b> existing lock, or <b>if</b> a lock is expired - creating a new one
    locked.amount = locked.amount + value;

    <b>if</b> (unlock_time &gt; 0) {
        locked.end = unlock_time;
    };

    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.locked, <a href="">token</a>, locked);

    // Possibilities:
    // Both old_locked.end could be current or expired (&gt;/&lt; <a href="">block</a>.<a href="">timestamp</a>)
    // value == 0 (extend lock) or value &gt; 0 (add <b>to</b> lock or extend lock)
    // locked.end &gt; <a href="">block</a>.<a href="">timestamp</a> (always)
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_check_point_internal">check_point_internal</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>,
        <a href="">token</a>,
        &old_locked,
        &locked
    );

    <b>if</b> (value &gt; 0 && type != <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_MERGE_TYPE">MERGE_TYPE</a> && type != <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SPLIT_TYPE">SPLIT_TYPE</a>) {
        <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();

        <b>assert</b>!(
            <a href="_balance">primary_fungible_store::balance</a>(address_of(user), dxlyn_metadata) &gt;= value,
            <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_ERROR_INSUFFICIENT_DXLYN_COIN">ERROR_INSUFFICIENT_DXLYN_COIN</a>
        );

        <a href="_transfer">primary_fungible_store::transfer</a>(
            user,
            dxlyn_metadata,
            // transfer <b>to</b> voting escrow <b>address</b>
            <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_voting_escrow_address">get_voting_escrow_address</a>(),
            value
        );
    };

    <a href="_emit">event::emit</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_SupplyEvent">SupplyEvent</a> { prev_supply: supply_before, supply: <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.supply }
    );

    locked.end
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft"></a>

## Function `mint_nft`

Mint an NFT representing a voting escrow position.


<a id="@Arguments_57"></a>

### Arguments

* <code><a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a></code> - The voting escrow object.
* <code>user</code> - The address to mint the NFT to.
* <code>locked_end</code> - The end time of the lock.
* <code>locked_amount</code> - The amount locked in the voting escrow.


<a id="@Returns_58"></a>

### Returns

The address of the minted NFT.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft">mint_nft</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">voting_escrow::VotingEscrow</a>, user: <b>address</b>, locked_end: u64, locked_amount: u64): (<b>address</b>, <a href="_String">string::String</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_mint_nft">mint_nft</a>(
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>: &<b>mut</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_VotingEscrow">VotingEscrow</a>,
    user: <b>address</b>,
    locked_end: u64,
    locked_amount: u64
): (<b>address</b>, String) {
    <b>let</b> collection_address = <a href="_address_from_extend_ref">object::address_from_extend_ref</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.collection_extend_ref);
    <b>let</b> collection_object = <a href="_address_to_object">object::address_to_object</a>&lt;Collection&gt;(collection_address);

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.token_id = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.token_id + 1;

    <b>let</b> (token_name, token_description, token_uri) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_details">get_token_details</a>(
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.token_id,
        locked_end, // locked_end
        locked_amount // value
    );

    <b>let</b> creator = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">voting_escrow</a>.extended_ref);

    <b>let</b> constructor_ref = <a href="_create_named_token">token::create_named_token</a>(creator,
        <a href="_name">collection::name</a>(collection_object),
        token_description,
        token_name,
        <a href="_none">option::none</a>(),
        token_uri,
    );

    <b>let</b> token_address = <a href="_address_from_constructor_ref">object::address_from_constructor_ref</a>(&constructor_ref);
    <b>let</b> <a href="">token</a> = <a href="_address_to_object">object::address_to_object</a>&lt;Token&gt;(token_address);

    // Transfer the <a href="">token</a> <b>to</b> the user
    <a href="_transfer">object::transfer</a>(creator, <a href="">token</a>, user);

    <b>let</b> token_signer = &<a href="_generate_signer">object::generate_signer</a>(&constructor_ref);

    // Generate and store the burn and transfer references for future <b>use</b>
    <b>move_to</b>(token_signer, <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
        burn_ref: <a href="_generate_burn_ref">token::generate_burn_ref</a>(&constructor_ref),
        transfer_ref: <a href="_generate_transfer_ref">object::generate_transfer_ref</a>(&constructor_ref)
    });

    // Return the <b>address</b> of the minted <a href="">token</a>
    (token_address, token_name)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft"></a>

## Function `burn_nft`

Burn an NFT representing a voting escrow position.


<a id="@Arguments_59"></a>

### Arguments

* <code><a href="">token</a></code> - The address of the NFT token to burn.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft">burn_nft</a>(<a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_burn_nft">burn_nft</a>(
    <a href="">token</a>: <b>address</b>
) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> token_data = <b>move_from</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a>&gt;(<a href="">token</a>);

    <b>let</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> { burn_ref, transfer_ref: _ } = token_data;

    <a href="_emit">event::emit</a>(<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_BurnNFTEvent">BurnNFTEvent</a> {
        <a href="">token</a>,
        ts: <a href="_now_seconds">timestamp::now_seconds</a>(),
    });

    <a href="_burn">token::burn</a>(burn_ref)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer"></a>

## Function `toggle_transfer`

Toggle the transfer state of a token.


<a id="@Arguments_60"></a>

### Arguments

* <code><a href="">token</a></code> - The address of the token to toggle transfer state for.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer">toggle_transfer</a>(<a href="">token</a>: <b>address</b>, allow_transfer: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_toggle_transfer">toggle_transfer</a>(
    <a href="">token</a>: <b>address</b>,
    allow_transfer: bool
) <b>acquires</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a> {
    <b>let</b> token_data = <b>borrow_global</b>&lt;<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_TokenRef">TokenRef</a>&gt;(<a href="">token</a>);

    // Toggle it based on its current state
    <b>if</b> (allow_transfer) {
        <a href="_enable_ungated_transfer">object::enable_ungated_transfer</a>(&token_data.transfer_ref);
    } <b>else</b> {
        <a href="_disable_ungated_transfer">object::disable_ungated_transfer</a>(&token_data.transfer_ref);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_details"></a>

## Function `get_token_details`

Generate a token name for the NFT.


<a id="@Arguments_61"></a>

### Arguments

* <code>token_id</code> - The ID of the token.
* <code>locked_end</code> - The end time of the lock.
* <code>locked_amount</code> - The amount locked in the voting escrow.


<a id="@Returns_62"></a>

### Returns

The token name , token description and token URI.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_details">get_token_details</a>(token_id: u64, locked_end: u64, locked_amount: u64): (<a href="_String">string::String</a>, <a href="_String">string::String</a>, <a href="_String">string::String</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_details">get_token_details</a>(token_id: u64, locked_end: u64, locked_amount: u64): (String, String, String) {
    (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_name">get_token_name</a>(token_id), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_description">get_token_description</a>(token_id, locked_end, locked_amount), <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_uri">get_token_uri</a>(
        token_id,
        locked_end,
        locked_amount
    ))
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_name"></a>

## Function `get_token_name`

Generate a token name for the NFT.


<a id="@Arguments_63"></a>

### Arguments

* <code>token_id</code> - The ID of the token.


<a id="@Returns_64"></a>

### Returns

The token name


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_name">get_token_name</a>(token_id: u64): <a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_name">get_token_name</a>(token_id: u64): String {
    <a href="_format1">string_utils::format1</a>(&b"veDXLYN position #{}", token_id)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_description"></a>

## Function `get_token_description`

Generate a token description for the NFT.


<a id="@Arguments_65"></a>

### Arguments

* <code>token_id</code> - The ID of the token.
* <code>locked_end</code> - The end time of the lock.
* <code>locked_amount</code> - The amount locked in the voting escrow.


<a id="@Returns_66"></a>

### Returns

The token description


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_description">get_token_description</a>(token_id: u64, locked_end: u64, locked_amount: u64): <a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_description">get_token_description</a>(token_id: u64, locked_end: u64, locked_amount: u64): String {
    <a href="_format3">string_utils::format3</a>(
        &b"veDXLYN NFT position ID: {} , Lock end: {} , Locked Amount : {}",
        token_id,
        locked_end,
        locked_amount
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_uri"></a>

## Function `get_token_uri`

Generate a token URI for the NFT.


<a id="@Arguments_67"></a>

### Arguments

* <code>token_id</code> - The ID of the token.
* <code>locked_end</code> - The end time of the lock.
* <code>value</code> - The value of the lock.


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_uri">get_token_uri</a>(token_id: u64, locked_end: u64, value: u64): <a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_get_token_uri">get_token_uri</a>(token_id: u64, locked_end: u64, value: u64): <a href="_String">string::String</a> {
    <b>let</b> svg_image = <a href="_utf8">string::utf8</a>(
        b"&lt;svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 350 350\"&gt;&lt;text x=\"10\" y=\"20\"&gt;VeDxlyn NFT&lt;/text&gt;"
    );
    <b>let</b> svg_image_formatted = <a href="_format3">string_utils::format3</a>(
        &b"&lt;text x=\"10\" y=\"50\"&gt;ID:{},&lt;/text&gt;&lt;text x=\"10\" y=\"70\" &gt;Lock End:{},&lt;/text&gt;&lt;text x=\"10\" y=\"90\" &gt;Value:{}&lt;/text&gt;&lt;/svg&gt;",
        token_id,
        locked_end,
        value
    );

    <a href="_append">string::append</a>(&<b>mut</b> svg_image, svg_image_formatted);

    <b>let</b> encoded_svg = <a href="base64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64_encode">base64::encode</a>(<a href="_bytes">string::bytes</a>(&svg_image));
    <b>let</b> final_uri = <a href="_utf8">string::utf8</a>(b"data:image/svg+xml;<a href="base64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64">base64</a>,");

    <a href="_append">string::append</a>(&<b>mut</b> final_uri, encoded_svg);

    final_uri
}
</code></pre>



</details>
