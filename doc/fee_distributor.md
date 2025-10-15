
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::fee_distributor`



-  [Struct `CommitAdminEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CommitAdminEvent)
-  [Struct `ChangeEmergencyReturnEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ChangeEmergencyReturnEvent)
-  [Struct `ApplyAdminEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ApplyAdminEvent)
-  [Struct `ToggleAllowCheckpointTokenEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ToggleAllowCheckpointTokenEvent)
-  [Struct `CheckpointTokenEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CheckpointTokenEvent)
-  [Struct `ClaimedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ClaimedEvent)
-  [Struct `WeeklyClaimedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaimedEvent)
-  [Struct `RebaseAddedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_RebaseAddedEvent)
-  [Struct `Point`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point)
-  [Resource `FeeDistributor`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor)
-  [Struct `WeeklyClaim`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_init_module)
    -  [Arguments](#@Arguments_1)
-  [Function `commit_admin`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_commit_admin)
    -  [Arguments](#@Arguments_2)
-  [Function `apply_admin`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_apply_admin)
    -  [Arguments](#@Arguments_3)
-  [Function `checkpoint_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token)
    -  [Arguments](#@Arguments_4)
    -  [Dev](#@Dev_5)
-  [Function `checkpoint_total_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply)
    -  [Dev](#@Dev_6)
-  [Function `toggle_allow_checkpoint_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_toggle_allow_checkpoint_token)
    -  [Arguments](#@Arguments_7)
-  [Function `kill_me`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_kill_me)
    -  [Arguments](#@Arguments_8)
    -  [Dev](#@Dev_9)
-  [Function `recover_balance_legacy_coin`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_legacy_coin)
    -  [Type Parameters](#@Type_Parameters_10)
    -  [Parameters](#@Parameters_11)
    -  [Dev](#@Dev_12)
-  [Function `recover_balance_fa`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_fa)
    -  [Arguments](#@Arguments_13)
-  [Function `change_emergency_return`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_change_emergency_return)
    -  [Arguments](#@Arguments_14)
-  [Function `claim`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim)
    -  [Arguments](#@Arguments_15)
    -  [Dev](#@Dev_16)
-  [Function `claim_many`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_many)
    -  [Parameters](#@Parameters_17)
    -  [Dev](#@Dev_18)
-  [Function `burn`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn)
    -  [Arguments](#@Arguments_19)
-  [Function `get_fee_distributor_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address)
    -  [Returns](#@Returns_20)
-  [Function `find_timestamp_epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_epoch)
    -  [Arguments](#@Arguments_21)
    -  [Returns](#@Returns_22)
    -  [Dev](#@Dev_23)
-  [Function `find_timestamp_user_epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch)
    -  [Arguments](#@Arguments_24)
    -  [Returns](#@Returns_25)
    -  [Dev](#@Dev_26)
-  [Function `ve_for_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ve_for_at)
    -  [Arguments](#@Arguments_27)
    -  [Returns](#@Returns_28)
-  [Function `claimable`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable)
    -  [Arguments](#@Arguments_29)
    -  [Returns](#@Returns_30)
-  [Function `claimable_many`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_many)
    -  [Arguments](#@Arguments_31)
    -  [Returns](#@Returns_32)
-  [Function `get_remaining_claim_calls`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_remaining_claim_calls)
    -  [Arguments](#@Arguments_33)
    -  [Returns](#@Returns_34)
-  [Function `burn_rebase`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn_rebase)
    -  [Arguments](#@Arguments_35)
    -  [Dev](#@Dev_36)
-  [Function `checkpoint_token_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal)
    -  [Arguments](#@Arguments_37)
-  [Function `checkpoint_total_supply_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal)
    -  [Arguments](#@Arguments_38)
    -  [Dev](#@Dev_39)
-  [Function `claim_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal)
    -  [Arguments](#@Arguments_40)
    -  [Returns](#@Returns_41)
-  [Function `claimable_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal)
    -  [Arguments](#@Arguments_42)
    -  [Returns](#@Returns_43)
-  [Function `round_to_week`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week)
    -  [Arguments](#@Arguments_44)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::supra_account</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
<b>use</b> <a href="i64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_i64">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::i64</a>;
<b>use</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::voting_escrow</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CommitAdminEvent"></a>

## Struct `CommitAdminEvent`

Represents the commitment to transfer admin rights


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CommitAdminEvent">CommitAdminEvent</a> <b>has</b> <b>copy</b>, drop, store
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ChangeEmergencyReturnEvent"></a>

## Struct `ChangeEmergencyReturnEvent`

Represents the change of emergency return address


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ChangeEmergencyReturnEvent">ChangeEmergencyReturnEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>new_emergency_return: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ApplyAdminEvent"></a>

## Struct `ApplyAdminEvent`

Represents the application of admin rights transfer


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ApplyAdminEvent">ApplyAdminEvent</a> <b>has</b> <b>copy</b>, drop, store
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ToggleAllowCheckpointTokenEvent"></a>

## Struct `ToggleAllowCheckpointTokenEvent`

Represents the toggle of checkpoint token permission


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ToggleAllowCheckpointTokenEvent">ToggleAllowCheckpointTokenEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>toggle_flag: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CheckpointTokenEvent"></a>

## Struct `CheckpointTokenEvent`

Represents a token checkpoint event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CheckpointTokenEvent">CheckpointTokenEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>time: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tokens: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ClaimedEvent"></a>

## Struct `ClaimedEvent`

Represents a claim event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ClaimedEvent">ClaimedEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>recipient: <b>address</b></code>
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
<dt>
<code>claim_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>max_epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaimedEvent"></a>

## Struct `WeeklyClaimedEvent`

Represents a claim event for a specific week


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaimedEvent">WeeklyClaimedEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>recipient: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>week: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_RebaseAddedEvent"></a>

## Struct `RebaseAddedEvent`

Represents a rebase added event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_RebaseAddedEvent">RebaseAddedEvent</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sender: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point"></a>

## Struct `Point`

Represents a point in time with voting power and timestamp


<pre><code><b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> <b>has</b> <b>copy</b>, drop
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor"></a>

## Resource `FeeDistributor`

Represents the fee distributor resource


<pre><code><b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>start_time: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>time_cursor: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>time_cursor_of: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>user_epoch_of: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>last_token_time: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tokens_per_week: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_received: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>token_last_balance: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ve_supply: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
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
<code>can_checkpoint_token: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>emergency_return: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>is_killed: bool</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim"></a>

## Struct `WeeklyClaim`

Represents a weekly claim for view function


<pre><code><b>struct</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a> <b>has</b> <b>copy</b>, drop, store
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
<code>week: u64</code>
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

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_INSUFFICIENT_BALANCE"></a>

Contract have insufficient DXLYN balance


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_SC_ADMIN"></a>

Address of the developer or deployer, used as the initial admin and emergency return


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN"></a>

Caller is not the admin


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_ZERO_ADDRESS"></a>

Address cannot be the zero address


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ONE_TWENTY_EIGHT_EPOCHS"></a>

For iteration of the epoch calculation


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>: u64 = 128;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK"></a>

One week in seconds (7 days), used for epoch calculations


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FIFTY_WEEKS"></a>

For iteration of the weekly calculation


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FIFTY_WEEKS">FIFTY_WEEKS</a>: u64 = 50;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CAN_NOT_RECOVER_DXLYN"></a>

Cannot recover DXLYN tokens from the contract


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CAN_NOT_RECOVER_DXLYN">ERROR_CAN_NOT_RECOVER_DXLYN</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED"></a>

Contract must be active (not killed) to perform this operation


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED">ERROR_CONTRACT_KILLED</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ALLOWED"></a>

Unauthorized user or checkpoint time not reached


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ALLOWED">ERROR_NOT_ALLOWED</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FEE_DISTRIBUTOR_SEEDS"></a>

Seed for creating the fee distributor resource account


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FEE_DISTRIBUTOR_SEEDS">FEE_DISTRIBUTOR_SEEDS</a>: <a href="">vector</a>&lt;u8&gt; = [70, 69, 69, 95, 68, 73, 83, 84, 82, 73, 66, 85, 84, 79, 82];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE"></a>

Deadline (1 day in seconds) for allowing token checkpoint updates


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE">TOKEN_CHECKPOINT_DEADLINE</a>: u64 = 86400;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TWENTY_WEEKS"></a>

For iteration of the weekly calculation


<pre><code><b>const</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TWENTY_WEEKS">TWENTY_WEEKS</a>: u64 = 20;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_init_module"></a>

## Function `init_module`

Initializes the fee distributor resource


<a id="@Arguments_1"></a>

### Arguments

* <code>sender</code> - The signer requesting the initialization.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_init_module">init_module</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_init_module">init_module</a>(sender: &<a href="">signer</a>) {
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(sender, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FEE_DISTRIBUTOR_SEEDS">FEE_DISTRIBUTOR_SEEDS</a>);

    <b>let</b> fee_dis_signer = <a href="_generate_signer">object::generate_signer</a>(&constructor_ref);

    <b>let</b> t: u64 = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(<a href="_now_seconds">timestamp::now_seconds</a>());

    // migrated dxlyn <a href="">coin</a> <b>to</b> fungible store for handel both coins
    <a href="_migrate_to_fungible_store">coin::migrate_to_fungible_store</a>&lt;DXLYN&gt;(&fee_dis_signer);

    <b>move_to</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(
        &fee_dis_signer,
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
            start_time: t,
            time_cursor: t,
            last_token_time: t,
            time_cursor_of: <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;(),
            user_epoch_of: <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;(),
            tokens_per_week: <a href="_new">table::new</a>&lt;u64, u64&gt;(),
            total_received: 0,
            token_last_balance: 0,
            ve_supply: <a href="_new">table::new</a>&lt;u64, u64&gt;(),
            admin: @admin,
            future_admin: @0x0,
            can_checkpoint_token: <b>false</b>,
            emergency_return: @emergency_return,
            is_killed: <b>false</b>,
            extended_ref: <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref)
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_commit_admin"></a>

## Function `commit_admin`

Commit transfer of ownership.


<a id="@Arguments_2"></a>

### Arguments

* <code>admin</code> - The current admin signer.
* <code>new_future_admin</code> - The new admin address.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_commit_admin">commit_admin</a>(admin: &<a href="">signer</a>, new_future_admin: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_commit_admin">commit_admin</a>(
    admin: &<a href="">signer</a>, new_future_admin: <b>address</b>
) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    fee_dis.future_admin = new_future_admin;

    <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CommitAdminEvent">CommitAdminEvent</a> { admin: new_future_admin })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_apply_admin"></a>

## Function `apply_admin`

Apply transfer of ownership.


<a id="@Arguments_3"></a>

### Arguments

* <code>admin</code> - The current admin signer.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_apply_admin">apply_admin</a>(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_apply_admin">apply_admin</a>(admin: &<a href="">signer</a>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);
    <b>assert</b>!(fee_dis.future_admin != @0x0, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);

    fee_dis.admin = fee_dis.future_admin;

    <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ApplyAdminEvent">ApplyAdminEvent</a> { admin: fee_dis.future_admin })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token"></a>

## Function `checkpoint_token`

Updates the token checkpoint.


<a id="@Arguments_4"></a>

### Arguments

* <code>sender</code> - The signer calling the function.


<a id="@Dev_5"></a>

### Dev

Calculates the total number of tokens to be distributed in a given week.
During initial distribution, only the contract owner can call this.
After setup, it can be enabled for anyone to call.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token">checkpoint_token</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token">checkpoint_token</a>(sender: &<a href="">signer</a>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>let</b> sender_address = address_of(sender);
    <b>assert</b>!(
        is_voter(sender_address) ||
            sender_address == fee_dis.admin
            || (
            fee_dis.can_checkpoint_token
                && <a href="_now_seconds">timestamp::now_seconds</a>()
                &gt; fee_dis.last_token_time + <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE">TOKEN_CHECKPOINT_DEADLINE</a>
        ),
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ALLOWED">ERROR_NOT_ALLOWED</a>
    );
    <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis, fee_dis_address);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply"></a>

## Function `checkpoint_total_supply`

Updates the veDXLYN total supply checkpoint.


<a id="@Dev_6"></a>

### Dev

The checkpoint is also updated by the first claimant each new epoch week.
This function may be called independently of a claim to reduce claiming gas costs.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply">checkpoint_total_supply</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply">checkpoint_total_supply</a>() <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal">checkpoint_total_supply_internal</a>(fee_dis);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_toggle_allow_checkpoint_token"></a>

## Function `toggle_allow_checkpoint_token`

Toggle permission for checkpoint by any account.


<a id="@Arguments_7"></a>

### Arguments

* <code>admin</code> - The admin signer.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_toggle_allow_checkpoint_token">toggle_allow_checkpoint_token</a>(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_toggle_allow_checkpoint_token">toggle_allow_checkpoint_token</a>(admin: &<a href="">signer</a>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    <b>let</b> flag = !fee_dis.can_checkpoint_token;

    fee_dis.can_checkpoint_token = flag;

    <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ToggleAllowCheckpointTokenEvent">ToggleAllowCheckpointTokenEvent</a> { toggle_flag: flag })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_kill_me"></a>

## Function `kill_me`

Kill the contract.


<a id="@Arguments_8"></a>

### Arguments

* <code>admin</code> - The admin signer.


<a id="@Dev_9"></a>

### Dev

Killing transfers the entire DXLYN balance to the emergency return address
and blocks the ability to claim or burn. The contract cannot be un-killed.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_kill_me">kill_me</a>(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_kill_me">kill_me</a>(admin: &<a href="">signer</a>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    fee_dis.is_killed = <b>true</b>;

    <b>let</b> fee_dis_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&fee_dis.extended_ref);
    <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();
    <b>let</b> total_amount = <a href="_balance">primary_fungible_store::balance</a>(address_of(&fee_dis_signer), dxlyn_metadata);
    <a href="_transfer">primary_fungible_store::transfer</a>(
        &fee_dis_signer,
        dxlyn_metadata,
        fee_dis.emergency_return,
        total_amount
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_legacy_coin"></a>

## Function `recover_balance_legacy_coin`

Recover any OLD (Legacy Token) tokens from this contract.


<a id="@Type_Parameters_10"></a>

### Type Parameters

- <code>CoinType</code>: The legacy coin type to recover.


<a id="@Parameters_11"></a>

### Parameters

- <code>admin</code>: The admin signer.


<a id="@Dev_12"></a>

### Dev

Tokens are sent to the emergency return address.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_legacy_coin">recover_balance_legacy_coin</a>&lt;CoinType&gt;(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_legacy_coin">recover_balance_legacy_coin</a>&lt;CoinType&gt;(admin: &<a href="">signer</a>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    <b>let</b> fee_dis_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&fee_dis.extended_ref);

    <a href="_transfer_coins">supra_account::transfer_coins</a>&lt;CoinType&gt;(
        &fee_dis_signer,
        fee_dis.emergency_return,
        // transfer total amount from fee distributor
        <a href="_balance">coin::balance</a>&lt;CoinType&gt;(fee_dis_address)
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_fa"></a>

## Function `recover_balance_fa`

Recover any FA tokens from this contract except DXLYN.
Tokens are sent to the emergency return address.


<a id="@Arguments_13"></a>

### Arguments

* <code>admin</code> - The admin signer.
* <code><a href="">coin</a></code> - The token address to recover.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_fa">recover_balance_fa</a>(admin: &<a href="">signer</a>, <a href="">coin</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_recover_balance_fa">recover_balance_fa</a>(admin: &<a href="">signer</a>, <a href="">coin</a>: <b>address</b>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    <b>let</b> dxlyn_address = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_address">dxlyn_coin::get_dxlyn_asset_address</a>();

    <b>assert</b>!(dxlyn_address != <a href="">coin</a>, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CAN_NOT_RECOVER_DXLYN">ERROR_CAN_NOT_RECOVER_DXLYN</a>);

    <b>let</b> coin_metadata = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(<a href="">coin</a>);

    <b>let</b> fee_dis_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&fee_dis.extended_ref);

    <a href="_transfer">primary_fungible_store::transfer</a>(
        &fee_dis_signer,
        coin_metadata,
        fee_dis.emergency_return,
        // transfer total amount from fee distributor
        <a href="_balance">primary_fungible_store::balance</a>(fee_dis_address, coin_metadata)
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_change_emergency_return"></a>

## Function `change_emergency_return`

Changes the emergency return address.


<a id="@Arguments_14"></a>

### Arguments

* <code>admin</code> - The admin signer.
* <code>new_emergency_return</code> - New emergency return address.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_change_emergency_return">change_emergency_return</a>(admin: &<a href="">signer</a>, new_emergency_return: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_change_emergency_return">change_emergency_return</a>(
    admin: &<a href="">signer</a>, new_emergency_return: <b>address</b>
) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>assert</b>!(new_emergency_return != @0x0, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);

    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(address_of(admin) == fee_dis.admin, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    fee_dis.emergency_return = new_emergency_return;

    <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ChangeEmergencyReturnEvent">ChangeEmergencyReturnEvent</a> { new_emergency_return })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim"></a>

## Function `claim`

Claims fees for the nft token.


<a id="@Arguments_15"></a>

### Arguments

* <code>sender</code> - The signer requesting the claim.
* <code><a href="">token</a></code> - The address of the NFT token to claim for.


<a id="@Dev_16"></a>

### Dev

Each call to <code>claim</code> processes up to 50 weeks of veDXLYN points.
For accounts with extensive veDXLYN activity, multiple calls may be needed to claim all available fees.
The <code>Claimed</code> event indicates if more claims are possible: if <code>claim_epoch</code> < <code>max_epoch</code>, the account can claim again.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim">claim</a>(sender: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim">claim</a>(sender: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> sender_address = address_of(sender);

    // Check <a href="">token</a> ownership
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">voting_escrow::assert_if_not_owner</a>(sender_address, <a href="">token</a>);

    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);

    <b>assert</b>!(!fee_dis.is_killed, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED">ERROR_CONTRACT_KILLED</a>);

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    // Update total voting supply <b>if</b> time_cursor is reached
    <b>if</b> (current_time &gt;= fee_dis.time_cursor) {
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal">checkpoint_total_supply_internal</a>(fee_dis);
    };

    // Perform <a href="">token</a> checkpoint <b>if</b> allowed and deadline passed
    <b>let</b> last_token_time = fee_dis.last_token_time;

    <b>if</b> (fee_dis.can_checkpoint_token && current_time &gt; last_token_time + <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE">TOKEN_CHECKPOINT_DEADLINE</a>) {
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis, fee_dis_address);
        last_token_time = current_time;
    };

    // Round last_token_time <b>to</b> the start of the week
    last_token_time = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(last_token_time);

    // Call claim_internal <b>to</b> calculate and distribute tokens
    <b>let</b> amount = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal">claim_internal</a>(fee_dis, sender_address, <a href="">token</a>, last_token_time);

    // Update token_last_balance
    <b>if</b> (amount &gt; 0) {
        <b>let</b> fee_dis_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&fee_dis.extended_ref);
        <a href="_transfer">primary_fungible_store::transfer</a>(
            &fee_dis_signer,
            <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
            sender_address,
            amount
        );

        fee_dis.token_last_balance = fee_dis.token_last_balance - amount;
    };
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_many"></a>

## Function `claim_many`

Make multiple fee claims in a single call.


<a id="@Parameters_17"></a>

### Parameters

* <code>sender</code> - The signer requesting the claims.
* <code>tokens</code> - A vector of addresses representing the NFT tokens to claim for.


<a id="@Dev_18"></a>

### Dev

Used to claim for many accounts at once, or to make multiple claims for the same address when that address has significant veDXLYN history.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_many">claim_many</a>(sender: &<a href="">signer</a>, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_many">claim_many</a>(
    sender: &<a href="">signer</a>, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>assert</b>!(!fee_dis.is_killed, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED">ERROR_CONTRACT_KILLED</a>);

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    // Update total voting supply <b>if</b> time_cursor is reached
    <b>if</b> (current_time &gt;= fee_dis.time_cursor) {
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal">checkpoint_total_supply_internal</a>(fee_dis);
    };

    <b>let</b> last_token_time = fee_dis.last_token_time;

    <b>if</b> (fee_dis.can_checkpoint_token && current_time &gt; fee_dis.last_token_time + <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE">TOKEN_CHECKPOINT_DEADLINE</a>) {
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis, fee_dis_address);
        last_token_time = current_time;
    };

    // Round last_token_time <b>to</b> the start of the week
    last_token_time = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(last_token_time);

    // Claim for each <b>address</b>
    <b>let</b> total: u64 = 0;
    <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();
    <b>let</b> fee_dis_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&fee_dis.extended_ref);
    <b>let</b> sender_address = address_of(sender);

    for (i in 0..<a href="_length">vector::length</a>(&tokens)) {
        <b>let</b> <a href="">token</a> = *<a href="_borrow">vector::borrow</a>(&tokens, i);
        <b>if</b> (<a href="">token</a> == @0x0) { <b>break</b> };

        // Check <a href="">token</a> ownership
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">voting_escrow::assert_if_not_owner</a>(sender_address, <a href="">token</a>);

        <b>let</b> amount = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal">claim_internal</a>(fee_dis, sender_address, <a href="">token</a>, last_token_time);
        <b>if</b> (amount &gt; 0) {
            <a href="_transfer">primary_fungible_store::transfer</a>(
                &fee_dis_signer,
                dxlyn_metadata,
                sender_address,
                amount
            );

            total = total + amount;
        };
    };

    // Update token_last_balance
    <b>if</b> (total &gt; 0) {
        <b>assert</b>!(fee_dis.token_last_balance &gt;= total, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);
        fee_dis.token_last_balance = fee_dis.token_last_balance - total;
    };
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn"></a>

## Function `burn`

Receive DXLYN into the contract and trigger a token checkpoint.


<a id="@Arguments_19"></a>

### Arguments

* <code>sender</code> - The signer sending the DXLYN.
* <code>amount</code> - The amount of DXLYN to send.


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn">burn</a>(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn">burn</a>(sender: &<a href="">signer</a>, amount: u64) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>assert</b>!(!fee_dis.is_killed, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED">ERROR_CONTRACT_KILLED</a>);

    <b>if</b> (amount &gt; 0) {
        <a href="_transfer">primary_fungible_store::transfer</a>(sender, <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(), fee_dis_address, amount);

        <b>let</b> current_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>();
        <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_RebaseAddedEvent">RebaseAddedEvent</a> {
            sender: address_of(sender),
            amount,
            ts: current_timestamp
        });

        <b>if</b> (fee_dis.can_checkpoint_token && current_timestamp
            &gt; fee_dis.last_token_time + <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TOKEN_CHECKPOINT_DEADLINE">TOKEN_CHECKPOINT_DEADLINE</a>) {
            <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis, fee_dis_address)
        };
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address"></a>

## Function `get_fee_distributor_address`

Get the address of the fee distributor


<a id="@Returns_20"></a>

### Returns

The address of the fee distributor resource.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_SC_ADMIN">SC_ADMIN</a>, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FEE_DISTRIBUTOR_SEEDS">FEE_DISTRIBUTOR_SEEDS</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_epoch"></a>

## Function `find_timestamp_epoch`

Find the epoch for a given timestamp.


<a id="@Arguments_21"></a>

### Arguments

* <code><a href="">timestamp</a></code> - The timestamp to search for.


<a id="@Returns_22"></a>

### Returns

The epoch number corresponding to the given timestamp.


<a id="@Dev_23"></a>

### Dev

Uses binary search to find the epoch with the closest timestamp.


<pre><code>#[view]
<b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_epoch">find_timestamp_epoch</a>(<a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_epoch">find_timestamp_epoch</a>(<a href="">timestamp</a>: u64): u64 {
    <b>let</b> <b>min</b> = 0;
    <b>let</b> max = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_epoch">voting_escrow::epoch</a>();

    for (i in 0..<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>) {
        <b>if</b> (<b>min</b> &gt;= max) { <b>break</b> };
        <b>let</b> mid = (<b>min</b> + max + 2) / 2;
        <b>let</b> (_, _, _, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history">voting_escrow::point_history</a>(mid);
        <b>if</b> (ts &lt;= <a href="">timestamp</a>) {
            <b>min</b> = mid;
        } <b>else</b> {
            max = mid - 1;
        }
    };

    <b>min</b>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch"></a>

## Function `find_timestamp_user_epoch`

Find the epoch for a given token and timestamp.


<a id="@Arguments_24"></a>

### Arguments

* <code><a href="">token</a></code> - The address of the NFT token.
* <code><a href="">timestamp</a></code> - The timestamp to search for.
* <code>max_user_epoch</code> - The maximum user epoch.


<a id="@Returns_25"></a>

### Returns

The epoch number corresponding to the given nft token and timestamp.


<a id="@Dev_26"></a>

### Dev

Uses binary search to find the token epoch with the closest timestamp.


<pre><code>#[view]
<b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch">find_timestamp_user_epoch</a>(<a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64, max_user_epoch: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch">find_timestamp_user_epoch</a>(
    <a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64, max_user_epoch: u64
): u64 {
    <b>let</b> <b>min</b> = 0;
    <b>let</b> max = max_user_epoch;

    for (i in 0..<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ONE_TWENTY_EIGHT_EPOCHS">ONE_TWENTY_EIGHT_EPOCHS</a>) {
        <b>if</b> (<b>min</b> &gt;= max) { <b>break</b> };
        <b>let</b> mid = (<b>min</b> + max + 2) / 2;
        <b>let</b> (_, _, _, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, mid);
        <b>if</b> (ts &lt;= <a href="">timestamp</a>) {
            <b>min</b> = mid;
        } <b>else</b> {
            max = mid - 1;
        }
    };

    <b>min</b>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ve_for_at"></a>

## Function `ve_for_at`

Returns the veDXLYN balance for a NFT token at a specific timestamp.


<a id="@Arguments_27"></a>

### Arguments

* <code><a href="">token</a></code> - NFT token address to query balance for.
* <code><a href="">timestamp</a></code> - Epoch time.


<a id="@Returns_28"></a>

### Returns

* <code>u64</code> - veDXLYN balance in 10^12 units.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ve_for_at">ve_for_at</a>(<a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ve_for_at">ve_for_at</a>(<a href="">token</a>: <b>address</b>, <a href="">timestamp</a>: u64): u64 {
    <b>let</b> max_user_epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch">voting_escrow::user_point_epoch</a>(<a href="">token</a>);
    <b>let</b> epoch = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch">find_timestamp_user_epoch</a>(<a href="">token</a>, <a href="">timestamp</a>, max_user_epoch);
    <b>let</b> (bias, slope, _, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, epoch);

    // <b>return</b> veDXLYN power
    i64::max((bias - slope * (<a href="">timestamp</a> - ts)), 0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable"></a>

## Function `claimable`

Returns the claimable amount for a specific token.


<a id="@Arguments_29"></a>

### Arguments

* <code><a href="">token</a></code> - NFT token address to query balance for.


<a id="@Returns_30"></a>

### Returns

Total claimable amount and vector of weekly claims.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable">claimable</a>(<a href="">token</a>: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">fee_distributor::WeeklyClaim</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable">claimable</a>(<a href="">token</a>: <b>address</b>): (u64, <a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt;) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>let</b> rounded_last_token_time = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(fee_dis.last_token_time);
    <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal">claimable_internal</a>(fee_dis, <a href="">token</a>, rounded_last_token_time)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_many"></a>

## Function `claimable_many`

Returns the claimable amount for a multiple tokens.


<a id="@Arguments_31"></a>

### Arguments

* <code>tokens</code> - Vector of NFT token addresses to query claimable balance for.


<a id="@Returns_32"></a>

### Returns

Total claimable amount and vector of vectors of weekly claims.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_many">claimable_many</a>(tokens: <a href="">vector</a>&lt;<b>address</b>&gt;): (u64, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">fee_distributor::WeeklyClaim</a>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_many">claimable_many</a>(tokens: <a href="">vector</a>&lt;<b>address</b>&gt;): (u64, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt;&gt;) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>let</b> rounded_last_token_time = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(fee_dis.last_token_time);
    <b>let</b> claimable_amounts = <a href="_empty">vector::empty</a>&lt;<a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt;&gt;();
    <b>let</b> total_claimable: u64 = 0;

    <a href="_for_each">vector::for_each</a>(tokens, |<a href="">token</a>| {
        <b>let</b> (total, claimable) = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal">claimable_internal</a>(fee_dis, <a href="">token</a>, rounded_last_token_time);
        total_claimable = total_claimable + total;
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> claimable_amounts, claimable);
    });
    (total_claimable, claimable_amounts)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_remaining_claim_calls"></a>

## Function `get_remaining_claim_calls`

Returns the remaining claim calls for a given NFT token.


<a id="@Arguments_33"></a>

### Arguments

* <code><a href="">token</a></code> - NFT token address to query remaining claim calls for.


<a id="@Returns_34"></a>

### Returns

The remaining claim calls.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_remaining_claim_calls">get_remaining_claim_calls</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_remaining_claim_calls">get_remaining_claim_calls</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>let</b> last_token_time = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(fee_dis.last_token_time);

    <b>let</b> last_claim_epoch = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.time_cursor_of, <a href="">token</a>, &0);

    <b>if</b> (last_claim_epoch &lt; fee_dis.start_time) {
        last_claim_epoch = fee_dis.start_time;
    };

    <b>if</b> (last_claim_epoch &gt;= last_token_time) {
        <b>return</b> 0
    };

    <b>let</b> unclaimed_epochs = (last_token_time - last_claim_epoch) / <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>;

    (unclaimed_epochs + 49) / <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FIFTY_WEEKS">FIFTY_WEEKS</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn_rebase"></a>

## Function `burn_rebase`

Receive DXLYN into the contract and trigger without trigger used in update period


<a id="@Arguments_35"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The signer voting to send the DXLYN.
* <code>sender</code> - The signer sending the DXLYN.
* <code>amount</code> - The amount of DXLYN to send.


<a id="@Dev_36"></a>

### Dev

Only a voter can call this function to send DXLYN to the contract.


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn_rebase">burn_rebase</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn_rebase">burn_rebase</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="">signer</a>, sender: &<a href="">signer</a>, amount: u64) <b>acquires</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a> {
    <b>let</b> fee_dis_address = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_get_fee_distributor_address">get_fee_distributor_address</a>();
    <b>let</b> fee_dis = <b>borrow_global_mut</b>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>&gt;(fee_dis_address);
    <b>assert</b>!(!fee_dis.is_killed, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ERROR_CONTRACT_KILLED">ERROR_CONTRACT_KILLED</a>);

    // check <b>if</b> sender is a <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>
    <b>let</b> voter_address = address_of(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>);
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_is_voter">voting_escrow::is_voter</a>(voter_address);

    <b>if</b> (amount &gt; 0) {
        <a href="_transfer">primary_fungible_store::transfer</a>(
            sender,
            <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
            fee_dis_address,
            amount
        );

        <a href="_emit">event::emit</a>(<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_RebaseAddedEvent">RebaseAddedEvent</a> {
            sender: voter_address,
            amount,
            ts: <a href="_now_seconds">timestamp::now_seconds</a>()
        });
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal"></a>

## Function `checkpoint_token_internal`

Checkpoint the token distribution


<a id="@Arguments_37"></a>

### Arguments

* <code>fee_dis</code>: A mutable reference to the <code><a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a></code> resource.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">fee_distributor::FeeDistributor</a>, fee_dis_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token_internal">checkpoint_token_internal</a>(fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>, fee_dis_address: <b>address</b>) {
    <b>let</b> token_balance = <a href="_balance">primary_fungible_store::balance</a>(fee_dis_address, <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>());
    <b>let</b> to_distribute = token_balance - fee_dis.token_last_balance;

    fee_dis.token_last_balance = token_balance;

    <b>let</b> t = fee_dis.last_token_time;
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    <b>let</b> since_last = current_time - t;
    fee_dis.last_token_time = current_time;
    <b>let</b> this_week = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(t);
    <b>let</b> _next_week = 0;
    <b>let</b> week = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>;

    for (i in 0..<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TWENTY_WEEKS">TWENTY_WEEKS</a>) {
        // Calculate the start of the next week.
        _next_week = this_week + week;

        // Check <b>if</b> the current time is within the current week.
        <b>if</b> (current_time &lt; _next_week) {
            // Handle edge case: no time <b>has</b> passed since the last checkpoint.
            <b>if</b> (since_last == 0 && current_time == t) {
                // All tokens go <b>to</b> the current week.
                <b>let</b> token_per_week = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> fee_dis.tokens_per_week, this_week, 0);
                *token_per_week = *token_per_week + to_distribute;
            } <b>else</b> {
                // Distribute tokens proportionally based on time spent in the current week.
                <b>let</b> token_per_week = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> fee_dis.tokens_per_week, this_week, 0);

                <b>let</b> scaled_token_per_week =
                    (*token_per_week <b>as</b> <a href="">u256</a>)
                        + ((to_distribute <b>as</b> <a href="">u256</a>)
                        * ((current_time - t) <b>as</b> <a href="">u256</a>)) / (
                        since_last <b>as</b> <a href="">u256</a>
                    );

                *token_per_week = (scaled_token_per_week <b>as</b> u64);
            };
            // Exit the <b>loop</b> <b>as</b> we've allocated tokens up <b>to</b> the current week.
            <b>break</b>
        } <b>else</b> {
            <b>if</b> (since_last == 0 && _next_week == t) {
                // All tokens go <b>to</b> the current week.
                <b>let</b> token_per_week = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> fee_dis.tokens_per_week, this_week, 0);
                *token_per_week = *token_per_week + to_distribute;
            } <b>else</b> {
                // Distribute tokens proportionally for the full week.
                <b>let</b> token_per_week = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> fee_dis.tokens_per_week, this_week, 0);

                <b>let</b> scaled_token_per_week =
                    (*token_per_week <b>as</b> <a href="">u256</a>)
                        + ((to_distribute <b>as</b> <a href="">u256</a>) * ((_next_week - t) <b>as</b> <a href="">u256</a>))
                        / (since_last <b>as</b> <a href="">u256</a>);

                *token_per_week = (scaled_token_per_week <b>as</b> u64);
            }
        };
        t = _next_week;
        this_week = _next_week;
    };

    <a href="_emit">event::emit</a>(
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_CheckpointTokenEvent">CheckpointTokenEvent</a> { time: current_time, tokens: to_distribute }
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal"></a>

## Function `checkpoint_total_supply_internal`

Checkpoint the total supply of veDXLYN.


<a id="@Arguments_38"></a>

### Arguments

* <code>fee_dis</code> - The FeeDistributor resource to update.


<a id="@Dev_39"></a>

### Dev

This function updates the veDXLYN supply for 20 weeks from the last checkpoint to the current time.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal">checkpoint_total_supply_internal</a>(fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">fee_distributor::FeeDistributor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply_internal">checkpoint_total_supply_internal</a>(fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>) {
    <b>let</b> t = fee_dis.time_cursor;
    <b>let</b> rounded_timestamp = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(<a href="_now_seconds">timestamp::now_seconds</a>());

    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_checkpoint">voting_escrow::checkpoint</a>();
    <b>let</b> week = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>;

    for (i in 0..<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_TWENTY_WEEKS">TWENTY_WEEKS</a>) {
        <b>if</b> (t &gt; rounded_timestamp) { <b>break</b> }
        <b>else</b> {
            <b>let</b> epoch = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_epoch">find_timestamp_epoch</a>(t);
            <b>let</b> (bias, slope, _, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_point_history">voting_escrow::point_history</a>(epoch);
            <b>let</b> dt = 0;
            <b>if</b> (t &gt; ts) {
                //If the point is at 0 epoch, it can actually be earlier than the first deposit
                //Then make dt 0
                dt = t - ts;
            };
            <a href="_upsert">table::upsert</a>(&<b>mut</b> fee_dis.ve_supply, t, i64::max((bias - slope * dt), 0));
        };
        t = t + week
    };

    fee_dis.time_cursor = t;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal"></a>

## Function `claim_internal`

Distributes tokens to a user based on their voting power up to <code>last_token_time</code>.


<a id="@Arguments_40"></a>

### Arguments

* <code>fee_dis</code> - The FeeDistributor resource to update.
* <code>token_owner</code> - The address of the token owner (the user).
* <code><a href="">token</a></code> - The nft token address.
* <code>last_token_time</code> - The end timestamp for the claim period (week-aligned).


<a id="@Returns_41"></a>

### Returns

The amount of tokens to distribute.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal">claim_internal</a>(fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">fee_distributor::FeeDistributor</a>, token_owner: <b>address</b>, <a href="">token</a>: <b>address</b>, last_token_time: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claim_internal">claim_internal</a>(
    fee_dis: &<b>mut</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>, token_owner: <b>address</b>, <a href="">token</a>: <b>address</b>, last_token_time: u64
): u64 {
    // Initialize variables
    <b>let</b> max_user_epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch">voting_escrow::user_point_epoch</a>(<a href="">token</a>);

    // If user <b>has</b> no voting power, <b>return</b> 0
    <b>if</b> (max_user_epoch == 0) {
        <b>return</b> 0
    };

    <b>let</b> start_time = fee_dis.start_time;

    // Get or initialize week cursor and user epoch
    <b>let</b> week_cursor = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.time_cursor_of, <a href="">token</a>, &0);
    <b>let</b> user_epoch = <b>if</b> (week_cursor == 0) {
        // First claim, find the epoch at start_time
        // Need <b>to</b> do the initial binary search
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch">find_timestamp_user_epoch</a>(<a href="">token</a>, start_time, max_user_epoch)
    } <b>else</b> {
        *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.user_epoch_of, <a href="">token</a>, &0)
    };

    // Ensure user_epoch is at least 1
    <b>if</b> (user_epoch == 0) {
        user_epoch = 1;
    };

    // Get the user's voting point at user_epoch
    <b>let</b> (bias, slope, blk, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, user_epoch);
    <b>let</b> user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope, bias, ts, blk };
    <b>let</b> week = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>;

    // Initialize week cursor <b>if</b> needed
    <b>if</b> (week_cursor == 0) {
        week_cursor = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(user_point.ts + week - 1);
    };

    // Check <b>if</b> no tokens <b>to</b> claim
    <b>if</b> (week_cursor &gt;= last_token_time) {
        <b>return</b> 0
    };

    // Ensure week_cursor is not before start_time
    <b>if</b> (week_cursor &lt; start_time) {
        week_cursor = start_time;
    };

    // Initialize <b>old</b> point
    <b>let</b> old_user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: 0, bias: 0, ts: 0, blk: 0 };

    <b>let</b> to_distribute: u64 = 0;

    <b>let</b> current_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>();
    // Iterate over weeks (up <b>to</b> 50 weeks)
    for (i in 0..<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FIFTY_WEEKS">FIFTY_WEEKS</a>) {
        <b>if</b> (week_cursor &gt;= last_token_time) { <b>break</b> };

        // Update epoch <b>if</b> week_cursor is past the current point's <a href="">timestamp</a>
        <b>if</b> (week_cursor &gt;= user_point.ts && user_epoch &lt;= max_user_epoch) {
            user_epoch = user_epoch + 1;
            old_user_point = user_point;

            <b>if</b> (user_epoch &gt; max_user_epoch) {
                // No more points, set <b>to</b> zero
                user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: 0, bias: 0, ts: 0, blk: 0 };
            } <b>else</b> {
                // Get the next point
                <b>let</b> (ibias, islope, iblk, its) =
                    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, user_epoch);
                user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: islope, bias: ibias, ts: its, blk: iblk };
            };
        } <b>else</b> {
            // Calculate voting power at week_cursor
            <b>let</b> (dt, is_dt_nagetive) = i64::safe_subtract_u64(week_cursor, old_user_point.ts);

            <b>let</b> (bal, is_bal_negative) = i64::safe_sub(
                <a href="_from_u64">i64::from_u64</a>(old_user_point.bias, <b>false</b>),
                <a href="_from_u64">i64::from_u64</a>(dt * old_user_point.slope, is_dt_nagetive)
            );

            <b>let</b> balance_of = <b>if</b> (is_bal_negative) { 0 } <b>else</b> { bal };

            // Break <b>if</b> no balance and no more epochs
            <b>if</b> (balance_of == 0 && user_epoch &gt; max_user_epoch) { <b>break</b> };

            <b>let</b> ve_supply = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.ve_supply, week_cursor, &0);
            // Calculate tokens <b>to</b> distribute
            <b>if</b> (balance_of &gt; 0 && ve_supply &gt; 0) {
                <b>let</b> tokens_per_week = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.tokens_per_week, week_cursor, &0);

                // converted into <a href="">u256</a> for handle overflow issue
                <b>let</b> to_distribute_internal: <a href="">u256</a> = (balance_of <b>as</b> <a href="">u256</a>) * (tokens_per_week <b>as</b> <a href="">u256</a>) / (ve_supply <b>as</b> <a href="">u256</a>);
                // to_distribute = to_distribute + (balance_of * tokens_per_week / ve_supply);
                to_distribute = to_distribute + (to_distribute_internal <b>as</b> u64);

                // Emit <a href="">event</a> for this week
                <a href="_emit">event::emit</a>(
                    <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaimedEvent">WeeklyClaimedEvent</a> {
                        recipient: token_owner,
                        <a href="">token</a>,
                        week: week_cursor,
                        amount: (to_distribute_internal <b>as</b> u64),
                        ts: current_timestamp
                    }
                );
            };


            week_cursor = week_cursor + week;
        };
    };

    // Update user state
    user_epoch = i64::min(max_user_epoch, user_epoch - 1);
    <a href="_upsert">table::upsert</a>(&<b>mut</b> fee_dis.user_epoch_of, <a href="">token</a>, user_epoch);
    <a href="_upsert">table::upsert</a>(&<b>mut</b> fee_dis.time_cursor_of, <a href="">token</a>, week_cursor);

    // Emit Claimed <a href="">event</a>
    <a href="_emit">event::emit</a>(
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_ClaimedEvent">ClaimedEvent</a> {
            recipient: token_owner,
            <a href="">token</a>,
            amount: to_distribute,
            claim_epoch: user_epoch,
            max_epoch: max_user_epoch
        }
    );

    to_distribute
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal"></a>

## Function `claimable_internal`

Distributes tokens to a user based on their voting power up to <code>last_token_time</code>.


<a id="@Arguments_42"></a>

### Arguments

* <code>fee_dis</code> - The FeeDistributor resource to update.
* <code>token_owner</code> - The address of the token owner (the user).
* <code><a href="">token</a></code> - The nft token address.
* <code>last_token_time</code> - The end timestamp for the claim period (week-aligned).


<a id="@Returns_43"></a>

### Returns

Total claimable amounts.
Vector of WeeklyClaim structs for each week with claimable amounts.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal">claimable_internal</a>(fee_dis: &<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">fee_distributor::FeeDistributor</a>, <a href="">token</a>: <b>address</b>, last_token_time: u64): (u64, <a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">fee_distributor::WeeklyClaim</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_internal">claimable_internal</a>(
    fee_dis: &<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_FeeDistributor">FeeDistributor</a>, <a href="">token</a>: <b>address</b>, last_token_time: u64
): (u64, <a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt;) {
    // Initialize variables
    <b>let</b> max_user_epoch = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_epoch">voting_escrow::user_point_epoch</a>(<a href="">token</a>);

    <b>let</b> claimable: <a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt; = <a href="_empty">vector::empty</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a>&gt;();
    <b>let</b> total_claimable: u64 = 0;

    // If user <b>has</b> no voting power, <b>return</b> 0
    <b>if</b> (max_user_epoch == 0) {
        <b>return</b> (total_claimable, claimable)
    };

    <b>let</b> start_time = fee_dis.start_time;

    // Get or initialize week cursor and user epoch
    <b>let</b> week_cursor = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.time_cursor_of, <a href="">token</a>, &0);
    <b>let</b> user_epoch = <b>if</b> (week_cursor == 0) {
        // First claim, find the epoch at start_time
        // Need <b>to</b> do the initial binary search
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_find_timestamp_user_epoch">find_timestamp_user_epoch</a>(<a href="">token</a>, start_time, max_user_epoch)
    } <b>else</b> {
        *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.user_epoch_of, <a href="">token</a>, &0)
    };

    // Ensure user_epoch is at least 1
    <b>if</b> (user_epoch == 0) {
        user_epoch = 1;
    };

    // Get the user's voting point at user_epoch
    <b>let</b> (bias, slope, blk, ts) = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, user_epoch);
    <b>let</b> user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope, bias, ts, blk };
    <b>let</b> week = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>;

    // Initialize week cursor <b>if</b> needed
    <b>if</b> (week_cursor == 0) {
        week_cursor = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(user_point.ts + week - 1);
    };

    // Check <b>if</b> no tokens <b>to</b> claim
    <b>if</b> (week_cursor &gt;= last_token_time) {
        <b>return</b> (total_claimable, claimable)
    };

    // Ensure week_cursor is not before start_time
    <b>if</b> (week_cursor &lt; start_time) {
        week_cursor = start_time;
    };

    // Initialize <b>old</b> point
    <b>let</b> old_user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: 0, bias: 0, ts: 0, blk: 0 };

    // Iterate till last_token_time
    <b>loop</b> {
        <b>if</b> (week_cursor &gt;= last_token_time) { <b>break</b> };

        // Update epoch <b>if</b> week_cursor is past the current point's <a href="">timestamp</a>
        <b>if</b> (week_cursor &gt;= user_point.ts && user_epoch &lt;= max_user_epoch) {
            user_epoch = user_epoch + 1;
            old_user_point = user_point;

            <b>if</b> (user_epoch &gt; max_user_epoch) {
                // No more points, set <b>to</b> zero
                user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: 0, bias: 0, ts: 0, blk: 0 };
            } <b>else</b> {
                // Get the next point
                <b>let</b> (ibias, islope, iblk, its) =
                    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_user_point_history">voting_escrow::user_point_history</a>(<a href="">token</a>, user_epoch);
                user_point = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_Point">Point</a> { slope: islope, bias: ibias, ts: its, blk: iblk };
            };
        } <b>else</b> {
            // Calculate voting power at week_cursor
            <b>let</b> (dt, is_dt_nagetive) = i64::safe_subtract_u64(week_cursor, old_user_point.ts);

            <b>let</b> (bal, is_bal_negative) = i64::safe_sub(
                <a href="_from_u64">i64::from_u64</a>(old_user_point.bias, <b>false</b>),
                <a href="_from_u64">i64::from_u64</a>(dt * old_user_point.slope, is_dt_nagetive)
            );

            <b>let</b> balance_of = <b>if</b> (is_bal_negative) { 0 } <b>else</b> { bal };

            // Break <b>if</b> no balance and no more epochs
            <b>if</b> (balance_of == 0 && user_epoch &gt; max_user_epoch) { <b>break</b> };

            <b>let</b> ve_supply = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.ve_supply, week_cursor, &0);
            // Calculate tokens <b>to</b> distribute
            <b>if</b> (balance_of &gt; 0 && ve_supply &gt; 0) {
                <b>let</b> tokens_per_week = *<a href="_borrow_with_default">table::borrow_with_default</a>(&fee_dis.tokens_per_week, week_cursor, &0);

                // converted into <a href="">u256</a> for handle overflow issue
                <b>let</b> to_distribute_internal: <a href="">u256</a> = (balance_of <b>as</b> <a href="">u256</a>) * (tokens_per_week <b>as</b> <a href="">u256</a>) / (ve_supply <b>as</b> <a href="">u256</a>);

                <b>if</b> (to_distribute_internal &gt; 0) {
                    // to_distribute = to_distribute + (balance_of * tokens_per_week / ve_supply);
                    total_claimable = total_claimable + (to_distribute_internal <b>as</b> u64);

                    <a href="_push_back">vector::push_back</a>(&<b>mut</b> claimable, <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">WeeklyClaim</a> {
                        <a href="">token</a>,
                        week: week_cursor,
                        amount: (to_distribute_internal <b>as</b> u64),
                    });
                };
            };

            week_cursor = week_cursor + week;
        };
    };

    (total_claimable, claimable)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week"></a>

## Function `round_to_week`

Round a timestamp to the start of the week


<a id="@Arguments_44"></a>

### Arguments

* <code><a href="">timestamp</a></code> - The timestamp to round.


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(<a href="">timestamp</a>: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_round_to_week">round_to_week</a>(<a href="">timestamp</a>: u64): u64 {
    <a href="">timestamp</a> / <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a> * <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WEEK">WEEK</a>
}
</code></pre>



</details>
