
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::gauge_perp`



-  [Struct `EmergencyModeChangedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyModeChangedEvent)
-  [Struct `EmergencyDeactivatedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyDeactivatedEvent)
-  [Struct `DepositEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DepositEvent)
-  [Struct `WithdrawEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WithdrawEvent)
-  [Struct `HarvestEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_HarvestEvent)
-  [Struct `RewardAddedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_RewardAddedEvent)
-  [Resource `GaugePerpSystem`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem)
-  [Resource `GaugePerp`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_initialize)
-  [Function `get_reward_distribution`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward_distribution)
    -  [Arguments](#@Arguments_1)
-  [Function `get_reward`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward)
    -  [Arguments](#@Arguments_2)
-  [Function `notify_reward_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_notify_reward_amount)
    -  [Arguments](#@Arguments_3)
-  [Function `set_distribution`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_set_distribution)
    -  [Arguments](#@Arguments_4)
-  [Function `update_emergency_mode`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_emergency_mode)
    -  [Arguments](#@Arguments_5)
-  [Function `deposit`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit)
    -  [Arguments](#@Arguments_6)
-  [Function `withdraw`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw)
    -  [Arguments](#@Arguments_7)
-  [Function `emergency_withdraw_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_emergency_withdraw_amount)
    -  [Arguments](#@Arguments_8)
-  [Function `get_gauge_system_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address)
    -  [Returns](#@Returns_9)
-  [Function `get_gauge_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address)
    -  [Arguments](#@Arguments_10)
    -  [Returns](#@Returns_11)
-  [Function `check_and_get_gauge_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_check_and_get_gauge_address)
    -  [Arguments](#@Arguments_12)
    -  [Returns](#@Returns_13)
-  [Function `total_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_total_supply)
    -  [Arguments](#@Arguments_14)
    -  [Returns](#@Returns_15)
-  [Function `balance_of`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_balance_of)
    -  [Arguments](#@Arguments_16)
    -  [Returns](#@Returns_17)
-  [Function `last_time_reward_applicable`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_last_time_reward_applicable)
    -  [Arguments](#@Arguments_18)
    -  [Returns](#@Returns_19)
-  [Function `reward_per_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token)
    -  [Arguments](#@Arguments_20)
    -  [Returns](#@Returns_21)
-  [Function `earned`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned)
    -  [Arguments](#@Arguments_22)
    -  [Returns](#@Returns_23)
-  [Function `earned_many`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_many)
    -  [Arguments](#@Arguments_24)
    -  [Returns](#@Returns_25)
-  [Function `reward_for_duration`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_for_duration)
    -  [Arguments](#@Arguments_26)
    -  [Returns](#@Returns_27)
-  [Function `period_finish`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_period_finish)
    -  [Arguments](#@Arguments_28)
    -  [Returns](#@Returns_29)
-  [Function `get_dxlp_coin_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address)
    -  [Arguments](#@Arguments_30)
    -  [Returns](#@Returns_31)
-  [Function `create_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_create_gauge)
    -  [Arguments](#@Arguments_32)
-  [Function `get_gauge_address_from_coin`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin)
-  [Function `reward_per_token_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal)
    -  [Arguments](#@Arguments_33)
    -  [Returns](#@Returns_34)
-  [Function `update_reward`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward)
    -  [Arguments](#@Arguments_35)
-  [Function `earned_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal)
    -  [Arguments](#@Arguments_36)
    -  [Returns](#@Returns_37)
-  [Function `deposit_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit_internal)
-  [Function `withdraw_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw_internal)


<pre><code><b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::math64</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::supra_account</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0xe20ad8ef9e1359af9660da6cc73f5ac092cc2d4e5a5f81101c07e938f33c7893::house_lp</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyModeChangedEvent"></a>

## Struct `EmergencyModeChangedEvent`

Emits when an emergency mode is changed for a gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyModeChangedEvent">EmergencyModeChangedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>mode: u8</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyDeactivatedEvent"></a>

## Struct `EmergencyDeactivatedEvent`

Emits when an emergency mode is deactivated for a gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyDeactivatedEvent">EmergencyDeactivatedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DepositEvent"></a>

## Struct `DepositEvent`

Emits when a deposit is made into the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DepositEvent">DepositEvent</a> <b>has</b> drop, store
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
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">coin</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>coin_type: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WithdrawEvent"></a>

## Struct `WithdrawEvent`

Emits when a withdrawal is made from the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WithdrawEvent">WithdrawEvent</a> <b>has</b> drop, store
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
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">coin</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>coin_type: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_HarvestEvent"></a>

## Struct `HarvestEvent`

Emits when a user harvests rewards from the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_HarvestEvent">HarvestEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="">coin</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_RewardAddedEvent"></a>

## Struct `RewardAddedEvent`

Emits when a reward is added to the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_RewardAddedEvent">RewardAddedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>gauge_address: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem"></a>

## Resource `GaugePerpSystem`

The GaugePerpSystem struct holds the owner address and an extend reference for the gauge system.


<pre><code><b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a> <b>has</b> key
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
<code>extend_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp"></a>

## Resource `GaugePerp`

The GaugePerp struct represents a gauge for liquidity providers, holding various parameters and state.


<pre><code><b>struct</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="">emergency</a>: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>distribution: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>external_bribe: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>duration: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>period_finish: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_rate: <a href="">u256</a></code>
</dt>
<dd>

</dd>
<dt>
<code>last_update_time: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_per_token_stored: <a href="">u256</a></code>
</dt>
<dd>

</dd>
<dt>
<code>user_reward_per_token_paid: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="">u256</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>rewards: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_supply: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>balances: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>extend_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">coin</a>: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE"></a>

Insufficient balance for withdraw or harvest


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 111;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_OWNER"></a>

Caller is not the owner of the gauge system


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_SC_ADMIN"></a>

Creator address of the GaugePerp system.


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ZERO_ADDRESS"></a>

Zero address (0x0) is not allowed


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WEEK"></a>

One week in seconds (7 days)


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DXLYN_DECIMAL"></a>

1 DXLYN_DECIMAL in smallest unit (10^8), for token amount scaling


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DXLYN_DECIMAL">DXLYN_DECIMAL</a>: u64 = 100000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_ACTIVE"></a>

Emergency mode active


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_ACTIVE">EMERGENCY_MODE_ACTIVE</a>: u8 = 1;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_INACTIVE"></a>

Emergency mode inactive


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_INACTIVE">EMERGENCY_MODE_INACTIVE</a>: u8 = 0;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ALREADY_IN_THIS_MODE"></a>

Gauge is already in this mode


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ALREADY_IN_THIS_MODE">ERROR_ALREADY_IN_THIS_MODE</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_ALREADY_EXIST"></a>

Gauge already exists


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_ALREADY_EXIST">ERROR_GAUGE_ALREADY_EXIST</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST"></a>

Gauge does not exist


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE"></a>

Withdraw and harvest are not allowed in emergency mode


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE">ERROR_IN_EMERGENCY_MODE</a>: u64 = 110;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_DISTRIBUTION"></a>

Caller is not the distributor of the contract


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_DISTRIBUTION">ERROR_NOT_DISTRIBUTION</a>: u64 = 112;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_IN_EMERGENCY_MODE"></a>

Gauge is not in emergency mode


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_IN_EMERGENCY_MODE">ERROR_NOT_IN_EMERGENCY_MODE</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_REWARD_TOO_HIGH"></a>

Reward amount too high, may cause overflow


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_REWARD_TOO_HIGH">ERROR_REWARD_TOO_HIGH</a>: u64 = 113;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_SAME_ADDRESS"></a>

New address cannot be the same as the current address


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_SAME_ADDRESS">ERROR_SAME_ADDRESS</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_UNAUTHORIZED_USER"></a>

Unauthorized action


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_UNAUTHORIZED_USER">ERROR_UNAUTHORIZED_USER</a>: u64 = 114;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GAUGE_SYSTEM_SEEDS"></a>

Seeds for the GaugePerp system, used to create a unique address for the gauge system


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GAUGE_SYSTEM_SEEDS">GAUGE_SYSTEM_SEEDS</a>: <a href="">vector</a>&lt;u8&gt; = [71, 65, 85, 71, 69, 95, 80, 69, 82, 80, 95, 83, 89, 83, 84, 69, 77];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION"></a>

Precision factor for reward calculations, used to prevent overflow and maintain precision


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a>: <a href="">u256</a> = 10000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO"></a>

Amount must be greater than zero


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO">ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO</a>: u64 = 108;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INVALID_COIN_TYPE"></a>

Invalid pool type


<pre><code><b>const</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INVALID_COIN_TYPE">ERROR_INVALID_COIN_TYPE</a>: u64 = 115;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_initialize"></a>

## Function `initialize`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_initialize">initialize</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_initialize">initialize</a>(sender: &<a href="">signer</a>) {
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(sender, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GAUGE_SYSTEM_SEEDS">GAUGE_SYSTEM_SEEDS</a>);

    <b>let</b> extend_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref);

    <b>let</b> gauge_sys_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&extend_ref);

    <b>move_to</b>(
        &gauge_sys_signer,
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a> { owner: @owner, extend_ref }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward_distribution"></a>

## Function `get_reward_distribution`

User harvest function called from distribution (voter allows harvest on multiple gauges)


<a id="@Arguments_1"></a>

### Arguments

* <code>distribution</code> - The signer representing the distribution contract.
* <code>user_address</code> - The address of the user for whom to harvest rewards.
* <code>gauge_address</code> - The address of gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward_distribution">get_reward_distribution</a>(distribution: &<a href="">signer</a>, user_address: <b>address</b>, gauge_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward_distribution">get_reward_distribution</a>(
    distribution: &<a href="">signer</a>, user_address: <b>address</b>, gauge_address: <b>address</b>
) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    <b>assert</b>!(address_of(distribution) == gauge.distribution, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_DISTRIBUTION">ERROR_NOT_DISTRIBUTION</a>);

    <b>if</b> (<a href="_contains">table::contains</a>(&gauge.rewards, user_address)) {
        //<b>update</b> <b>global</b> and user reward history
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge, user_address);

        <b>let</b> reward = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> gauge.rewards, user_address);
        <b>if</b> (*reward &gt; 0) {
            //transfer DXLYN <a href="">token</a> from gauge <a href="">object</a> <a href="">account</a> <b>to</b> users <a href="">account</a>
            <b>let</b> gauge_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&gauge.extend_ref);
            <a href="_transfer">primary_fungible_store::transfer</a>(
                &gauge_signer,
                address_to_object&lt;Metadata&gt;(gauge.reward_token),
                user_address,
                *reward
            );

            <a href="_emit">event::emit</a>(
                <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_HarvestEvent">HarvestEvent</a> {
                    <a href="">coin</a>: gauge.<a href="">coin</a>,
                    gauge: gauge_address,
                    user: user_address,
                    reward: *reward,
                    <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>()
                }
            );

            *reward = 0;
        }
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward"></a>

## Function `get_reward`

User harvest function called from user.


<a id="@Arguments_2"></a>

### Arguments

* <code>user</code> - The signer representing the user harvesting rewards.
* <code>gauge_address</code> - The address of gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward">get_reward</a>(user: &<a href="">signer</a>, gauge_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward">get_reward</a>(user: &<a href="">signer</a>, gauge_address: <b>address</b>) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    <b>let</b> user_address = address_of(user);
    <b>if</b> (<a href="_contains">table::contains</a>(&gauge.rewards, user_address)) {
        //<b>update</b> <b>global</b> and user reward history
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge, user_address);

        <b>let</b> reward = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> gauge.rewards, user_address);
        <b>if</b> (*reward &gt; 0) {
            <b>let</b> gauge_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&gauge.extend_ref);

            //transfer DXLYN <a href="">token</a> from gauge <a href="">object</a> <a href="">account</a> <b>to</b> users <a href="">account</a>
            <a href="_transfer">primary_fungible_store::transfer</a>(
                &gauge_signer,
                address_to_object&lt;Metadata&gt;(gauge.reward_token),
                user_address,
                *reward
            );

            <a href="_emit">event::emit</a>(
                <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_HarvestEvent">HarvestEvent</a> {
                    <a href="">coin</a>: gauge.<a href="">coin</a>,
                    gauge: gauge_address,
                    user: user_address,
                    reward: *reward,
                    <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>()
                }
            );
            *reward = 0;
        };
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_notify_reward_amount"></a>

## Function `notify_reward_amount`

Notify the gauge of a new reward amount.


<a id="@Arguments_3"></a>

### Arguments

* <code>distribution</code> - The signer representing the distribution contract.
* <code>gauge_address</code> - The address of gauge.
* <code>reward</code> - The amount of reward to notify.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_notify_reward_amount">notify_reward_amount</a>(distribution: &<a href="">signer</a>, gauge_address: <b>address</b>, reward: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_notify_reward_amount">notify_reward_amount</a>(
    distribution: &<a href="">signer</a>, gauge_address: <b>address</b>, reward: u64
) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <b>assert</b>!(!gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE">ERROR_IN_EMERGENCY_MODE</a>);

    <b>let</b> distribution_addr = address_of(distribution);
    <b>assert</b>!(distribution_addr == gauge.distribution, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_DISTRIBUTION">ERROR_NOT_DISTRIBUTION</a>);

    //<b>update</b> <b>global</b> history
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge, @0x0);

    <b>let</b> dxlyn_metadata = address_to_object&lt;Metadata&gt;(gauge.reward_token);

    //transfer dxlyn <a href="">coin</a> from distribution <b>to</b> gauge
    <a href="_transfer">primary_fungible_store::transfer</a>(distribution, dxlyn_metadata, gauge_address, reward);

    // Scaled reward <b>to</b> extra 10^4 <b>to</b> avoid precision issues in reward rate calculations.
    <b>let</b> reward = (reward <b>as</b> <a href="">u256</a>) * <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a>;

    //<b>if</b> time more then finish period then calculate new reward rate other wise remaining
    // This logic is still loose some precision
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();

    <b>if</b> (current_time &gt;= gauge.period_finish) {
        gauge.reward_rate = reward / (gauge.duration <b>as</b> <a href="">u256</a>);
    } <b>else</b> {
        <b>let</b> remaining = (gauge.period_finish - current_time <b>as</b> <a href="">u256</a>);
        <b>let</b> left_over = remaining * gauge.reward_rate;
        gauge.reward_rate = (reward + left_over) / (gauge.duration <b>as</b> <a href="">u256</a>);
    };

    // Ensure the provided reward amount is not more than the balance in the contract.
    // This keeps the reward rate in the right range, preventing overflows due <b>to</b>
    // very high values of reward_rate in the earned and rewards_per_token functions;
    // Reward + left_over must be less than 2^64 / 10^8 <b>to</b> avoid overflow.
    <b>let</b> balance = <a href="_balance">primary_fungible_store::balance</a>(gauge_address, dxlyn_metadata);
    // Scaled value for handle overflow issue
    <b>let</b> current_reward_rate_scaled_calc =
        ((balance <b>as</b> <a href="">u256</a>) * <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a>) / (gauge.duration <b>as</b> <a href="">u256</a>);
    <b>assert</b>!(
        gauge.reward_rate &lt;= current_reward_rate_scaled_calc,
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_REWARD_TOO_HIGH">ERROR_REWARD_TOO_HIGH</a>
    );

    gauge.last_update_time = current_time;
    gauge.period_finish = current_time + gauge.duration;

    <a href="_emit">event::emit</a>(
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_RewardAddedEvent">RewardAddedEvent</a> {
            gauge_address,
            reward: (reward / <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a> <b>as</b> u64),
            <a href="">timestamp</a>: current_time
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_set_distribution"></a>

## Function `set_distribution`

Sets the distribution address for a gauge.


<a id="@Arguments_4"></a>

### Arguments

* <code>owner</code> - The signer who is the owner of the gauge system.
* <code>gauge</code> - The gauge address
* <code>new_distribution</code> - The new distribution address to set.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_set_distribution">set_distribution</a>(owner: &<a href="">signer</a>, gauge: <b>address</b>, new_distribution: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_set_distribution">set_distribution</a>(
    owner: &<a href="">signer</a>, gauge: <b>address</b>, new_distribution: <b>address</b>
) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(new_distribution != @0x0, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);


    <b>let</b> gauge_system_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>();

    <b>let</b> gauge_sys = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a>&gt;(gauge_system_address);
    <b>assert</b>!(address_of(owner) == gauge_sys.owner, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge);
    <b>assert</b>!(new_distribution != gauge.distribution, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_SAME_ADDRESS">ERROR_SAME_ADDRESS</a>);

    gauge.distribution = new_distribution;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_emergency_mode"></a>

## Function `update_emergency_mode`

Update the emergency mode for a gauge.


<a id="@Arguments_5"></a>

### Arguments

* <code>owner</code> - Signer who owns the gauge system.
* <code>gauge_address</code> - Address of the gauge to update emergency mode.
* <code>mode</code> - <code><b>true</b></code> to activate, <code><b>false</b></code> to deactivate emergency mode.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_emergency_mode">update_emergency_mode</a>(owner: &<a href="">signer</a>, gauge_address: <b>address</b>, mode: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_emergency_mode">update_emergency_mode</a>(
    owner: &<a href="">signer</a>, gauge_address: <b>address</b>, mode: bool
) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> gauge_system_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>();
    <b>let</b> gauge_sys = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a>&gt;(gauge_system_address);
    <b>assert</b>!(address_of(owner) == gauge_sys.owner, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    // Mode must be different <b>to</b> change
    <b>assert</b>!(mode != gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_ALREADY_IN_THIS_MODE">ERROR_ALREADY_IN_THIS_MODE</a>);
    gauge.<a href="">emergency</a> = mode;

    <b>let</b> mode = <b>if</b> (mode) { <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_ACTIVE">EMERGENCY_MODE_ACTIVE</a> } <b>else</b> { <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EMERGENCY_MODE_INACTIVE">EMERGENCY_MODE_INACTIVE</a> };

    <a href="_emit">event::emit</a>(
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_EmergencyModeChangedEvent">EmergencyModeChangedEvent</a> { gauge: gauge_address, mode, <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>() }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit"></a>

## Function `deposit`

Deposits a specified amount of DXLP coins into the gauge.


<a id="@Arguments_6"></a>

### Arguments

* <code>user</code> - The signer representing the user depositing DXLP coins.
* <code>amount</code> - The amount of DXLP coins to deposit.
* <code>TypeArgument</code> - The DXLP coin type <AssetT>.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit">deposit</a>&lt;AssetT&gt;(user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit">deposit</a>&lt;AssetT&gt;(user: &<a href="">signer</a>, amount: u64) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>let</b> gauge_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin">get_gauge_address_from_coin</a>&lt;AssetT&gt;();
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <b>assert</b>!(!gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE">ERROR_IN_EMERGENCY_MODE</a>);

    <b>let</b> balance = <a href="_balance">coin::balance</a>&lt;DXLP&lt;AssetT&gt;&gt;(address_of(user));
    <b>assert</b>!(balance &gt;= amount, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit_internal">deposit_internal</a>&lt;DXLP&lt;AssetT&gt;&gt;(gauge, gauge_address, user, amount);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw"></a>

## Function `withdraw`

Withdraw a certain amount of LP coin.


<a id="@Arguments_7"></a>

### Arguments

* <code>user</code> - The signer representing the user withdrawing DXLP coins.
* <code>amount</code> - The amount of DXLP coins to withdraw.
* <code>TypeArgument</code> - The DXLP type <AssetT>.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw">withdraw</a>&lt;AssetT&gt;(user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw">withdraw</a>&lt;AssetT&gt;(user: &<a href="">signer</a>, amount: u64) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>let</b> gauge_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin">get_gauge_address_from_coin</a>&lt;AssetT&gt;();
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <b>assert</b>!(!gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE">ERROR_IN_EMERGENCY_MODE</a>);

    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw_internal">withdraw_internal</a>&lt;DXLP&lt;AssetT&gt;&gt;(gauge, user, amount);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_emergency_withdraw_amount"></a>

## Function `emergency_withdraw_amount`

Withdraw a certain amount of DXLP coin in emergency mode.


<a id="@Arguments_8"></a>

### Arguments

* <code>user</code> - The signer representing the user withdrawing DXLP coins in emergency mode.
* <code>amount</code> - The amount of DXLP coins to withdraw in emergency mode.
* <code>TypeArgument</code> - The DXLP type <AssetT>.


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_emergency_withdraw_amount">emergency_withdraw_amount</a>&lt;AssetT&gt;(user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_emergency_withdraw_amount">emergency_withdraw_amount</a>&lt;AssetT&gt;(
    user: &<a href="">signer</a>,
    amount: u64
) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(amount &gt; 0, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO">ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO</a>);

    <b>let</b> gauge_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin">get_gauge_address_from_coin</a>&lt;AssetT&gt;();
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> gauge = <b>borrow_global_mut</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <b>assert</b>!(gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_NOT_IN_EMERGENCY_MODE">ERROR_NOT_IN_EMERGENCY_MODE</a>);

    <b>let</b> user_address = address_of(user);

    // Check user <b>exists</b>
    <b>assert</b>!(<a href="_contains">table::contains</a>(&gauge.balances, user_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    // Validate enough balance
    <b>let</b> balance = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> gauge.balances, user_address);
    <b>assert</b>!(*balance &gt;= amount, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    //<b>update</b> total supply
    gauge.total_supply = gauge.total_supply - amount;
    *balance = *balance - amount;

    <b>let</b> gauge_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&gauge.extend_ref);

    //transfer DXLP <a href="">coin</a> from gauge <b>to</b> user <a href="">account</a>
    <a href="_transfer_coins">supra_account::transfer_coins</a>&lt;DXLP&lt;AssetT&gt;&gt;(
        &gauge_signer,
        user_address,
        amount
    );

    <a href="_emit">event::emit</a>(<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WithdrawEvent">WithdrawEvent</a> {
        user: user_address,
        amount,
        gauge: gauge_address,
        <a href="">coin</a>: gauge.<a href="">coin</a>,
        coin_type: <a href="_type_name">type_info::type_name</a>&lt;DXLP&lt;AssetT&gt;&gt;(),
        <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>()
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address"></a>

## Function `get_gauge_system_address`

Returns the address of the GaugePerp system.


<a id="@Returns_9"></a>

### Returns

The address of the GaugePerp system.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_SC_ADMIN">SC_ADMIN</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GAUGE_SYSTEM_SEEDS">GAUGE_SYSTEM_SEEDS</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address"></a>

## Function `get_gauge_address`

Returns the address of a gauge for a given DXLP coin.


<a id="@Arguments_10"></a>

### Arguments

* <code><a href="">coin</a></code> - The coin address to get gauge address.


<a id="@Returns_11"></a>

### Returns

The address of the gauge for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address">get_gauge_address</a>(<a href="">coin</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address">get_gauge_address</a>(<a href="">coin</a>: <b>address</b>): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(
        &<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>(),
        <a href="_to_bytes">bcs::to_bytes</a>(&<a href="">coin</a>)
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_check_and_get_gauge_address"></a>

## Function `check_and_get_gauge_address`

Checks if a gauge exists for the given DXLP coin and returns its address.


<a id="@Arguments_12"></a>

### Arguments

* <code><a href="">coin</a></code> - The coin address to get gauge address.


<a id="@Returns_13"></a>

### Returns

The address of the gauge if it exists.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_check_and_get_gauge_address">check_and_get_gauge_address</a>(<a href="">coin</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_check_and_get_gauge_address">check_and_get_gauge_address</a>(<a href="">coin</a>: <b>address</b>): <b>address</b> {
    <b>let</b> gauge_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address">get_gauge_address</a>(<a href="">coin</a>);
    //Check gauge created
    <b>assert</b>!(
        <b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address),
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>
    );
    gauge_address
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_total_supply"></a>

## Function `total_supply`

Returns the total supply of DXLP coins held in the gauge for the specified coin.


<a id="@Arguments_14"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the total supply.


<a id="@Returns_15"></a>

### Returns

The total supply of DXLP coins in the gauge.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_total_supply">total_supply</a>(gauge_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_total_supply">total_supply</a>(gauge_address: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    gauge.total_supply
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_balance_of"></a>

## Function `balance_of`

Balance of a user in the gauge for the specified DXLP coin.


<a id="@Arguments_16"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the user's balance.
* <code><a href="">account</a></code> - The address of the user for whom to get the balance.


<a id="@Returns_17"></a>

### Returns

The balance of the user in the gauge for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_balance_of">balance_of</a>(gauge_address: <b>address</b>, <a href="">account</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_balance_of">balance_of</a>(gauge_address: <b>address</b>, <a href="">account</a>: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    *<a href="_borrow_with_default">table::borrow_with_default</a>(&gauge.balances, <a href="">account</a>, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_last_time_reward_applicable"></a>

## Function `last_time_reward_applicable`

Returns the last time reward was applicable for the specified DXLP coin.


<a id="@Arguments_18"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the last time reward was applicable.


<a id="@Returns_19"></a>

### Returns

The last time reward was applicable for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_last_time_reward_applicable">last_time_reward_applicable</a>(gauge_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_last_time_reward_applicable">last_time_reward_applicable</a>(gauge_address: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>, {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <a href="_min">math64::min</a>(<a href="_now_seconds">timestamp::now_seconds</a>(), gauge.period_finish)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token"></a>

## Function `reward_per_token`

Returns the reward per token for the specified DXLP coin.


<a id="@Arguments_20"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the reward per token.


<a id="@Returns_21"></a>

### Returns

The reward per token for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token">reward_per_token</a>(gauge_address: <b>address</b>): <a href="">u256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token">reward_per_token</a>(gauge_address: <b>address</b>): <a href="">u256</a> <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal">reward_per_token_internal</a>(gauge)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned"></a>

## Function `earned`

See earned rewards for user.


<a id="@Arguments_22"></a>

### Arguments

* <code>gauge_address</code> - The gauge address.
* <code><a href="">account</a></code> - The address of the user for whom to get the earned rewards.


<a id="@Returns_23"></a>

### Returns

The total earned rewards for the user in the specified gauge.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned">earned</a>(gauge_address: <b>address</b>, <a href="">account</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned">earned</a>(gauge_address: <b>address</b>, <a href="">account</a>: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal">earned_internal</a>(gauge, <a href="">account</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_many"></a>

## Function `earned_many`

See earned rewards for user for multiple gauges.


<a id="@Arguments_24"></a>

### Arguments

* <code>gauge_addresses</code> - The vector of gauge addresses.
* <code><a href="">account</a></code> - The address of the user for whom to get the earned rewards.


<a id="@Returns_25"></a>

### Returns

The total earned rewards for the user across multiple gauges and a vector of individual earned amounts.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_many">earned_many</a>(gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;, <a href="">account</a>: <b>address</b>): (u64, <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_many">earned_many</a>(gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;, <a href="">account</a>: <b>address</b>): (u64, <a href="">vector</a>&lt;u64&gt;) <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>let</b> result = <a href="_empty">vector::empty</a>&lt;u64&gt;();
    <b>let</b> total_reward = 0;
    <a href="_for_each">vector::for_each</a>(gauge_addresses, |gauge_address| {
        <b>let</b> earned_amount = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned">earned</a>(gauge_address, <a href="">account</a>);
        total_reward = total_reward + earned_amount;
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, earned_amount);
    });
    (total_reward, result)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_for_duration"></a>

## Function `reward_for_duration`

Returns the total reward for the duration for the specified DXLP coin.


<a id="@Arguments_26"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the total reward for the duration.


<a id="@Returns_27"></a>

### Returns

The total reward for the duration for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_for_duration">reward_for_duration</a>(gauge_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_for_duration">reward_for_duration</a>(gauge_address: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    (gauge.reward_rate * (gauge.duration <b>as</b> <a href="">u256</a>) / <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a> <b>as</b> u64)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_period_finish"></a>

## Function `period_finish`

Returns the timestamp when the current reward period finishes for the specified DXLP coin.


<a id="@Arguments_28"></a>

### Arguments

* <code>gauge_address</code> - The gauge address to get the period finish time.


<a id="@Returns_29"></a>

### Returns

The timestamp when the current reward period finishes for the specified DXLP coin.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_period_finish">period_finish</a>(gauge_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_period_finish">period_finish</a>(gauge_address: <b>address</b>): u64 <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> gauge = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(gauge_address);

    gauge.period_finish
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address"></a>

## Function `get_dxlp_coin_address`

View address for a DXLP based object address.


<a id="@Arguments_30"></a>

### Arguments

* <code>TypeArgument</code> - The type of DXLP coin


<a id="@Returns_31"></a>

### Returns

* <code><b>address</b></code> - The calculated address derived from the seed.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address">get_dxlp_coin_address</a>&lt;AssetT&gt;(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address">get_dxlp_coin_address</a>&lt;AssetT&gt;(): <b>address</b> {
    <b>assert</b>!(<a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;DXLP&lt;AssetT&gt;&gt;(), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INVALID_COIN_TYPE">ERROR_INVALID_COIN_TYPE</a>);
    <b>let</b> coin_name = <a href="_type_name">type_info::type_name</a>&lt;DXLP&lt;AssetT&gt;&gt;();
    <a href="_create_object_address">object::create_object_address</a>(&<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_SC_ADMIN">SC_ADMIN</a>, *<a href="_bytes">string::bytes</a>(&coin_name))
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_create_gauge"></a>

## Function `create_gauge`

Creates a new GaugePerp for a given DXLP coin.


<a id="@Arguments_32"></a>

### Arguments

* <code>distribution</code> - The address of the distribution contract for this gauge.
* <code>external_bribe</code> - The address of the external bribe contract for this gauge.
* <code><a href="">coin</a></code> - The coin address to create gauge address.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_create_gauge">create_gauge</a>(distribution: <b>address</b>, external_bribe: <b>address</b>, <a href="">coin</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_create_gauge">create_gauge</a>(
    distribution: <b>address</b>,
    external_bribe: <b>address</b>,
    <a href="">coin</a>: <b>address</b>,
): <b>address</b> <b>acquires</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a> {
    <b>let</b> gauge_system_address = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">get_gauge_system_address</a>();

    <b>let</b> seed = <a href="_to_bytes">bcs::to_bytes</a>(&<a href="">coin</a>);
    <b>let</b> new_gauge_address =
        <a href="_create_object_address">object::create_object_address</a>(&gauge_system_address, seed);

    // Check gauge should not exist
    <b>assert</b>!(
        !<b>exists</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>&gt;(new_gauge_address),
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_GAUGE_ALREADY_EXIST">ERROR_GAUGE_ALREADY_EXIST</a>
    );

    <b>let</b> gauge_sys = <b>borrow_global</b>&lt;<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerpSystem">GaugePerpSystem</a>&gt;(gauge_system_address);
    <b>let</b> gauge_sys_signer =
        <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&gauge_sys.extend_ref);
    <b>let</b> new_gauge_contractor_ref =
        <a href="_create_named_object">object::create_named_object</a>(&gauge_sys_signer, seed);
    <b>let</b> new_gauge_extend_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(&new_gauge_contractor_ref);
    <b>let</b> new_gauge_signer =
        &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&new_gauge_extend_ref);

    //dxlyn <a href="">coin</a> metadata
    <b>let</b> new_gauge_address = address_of(new_gauge_signer);
    <b>let</b> dxlyn_coin_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();
    <b>let</b> dxlyn_coin_address = <a href="_object_address">object::object_address</a>(&dxlyn_coin_metadata);

    <b>move_to</b>(
        new_gauge_signer,
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a> {
            <a href="">emergency</a>: <b>false</b>,
            reward_token: dxlyn_coin_address,
            distribution,
            external_bribe,
            duration: <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WEEK">WEEK</a>,
            period_finish: 0,
            reward_rate: 0,
            last_update_time: 0,
            reward_per_token_stored: 0,
            user_reward_per_token_paid: <a href="_new">table::new</a>&lt;<b>address</b>, <a href="">u256</a>&gt;(),
            rewards: <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;(),
            total_supply: 0,
            balances: <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;(),
            extend_ref: new_gauge_extend_ref,
            <a href="">coin</a>,
        }
    );
    new_gauge_address
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin"></a>

## Function `get_gauge_address_from_coin`



<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin">get_gauge_address_from_coin</a>&lt;AssetT&gt;(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>inline <b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address_from_coin">get_gauge_address_from_coin</a>&lt;AssetT&gt;(): <b>address</b> {
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_address">get_gauge_address</a>(<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address">get_dxlp_coin_address</a>&lt;AssetT&gt;())
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal"></a>

## Function `reward_per_token_internal`

Returns the reward per token for the specified gauge.


<a id="@Arguments_33"></a>

### Arguments

* <code>gauge</code> - The gauge for which to calculate the reward per token.


<a id="@Returns_34"></a>

### Returns

The reward per token for the specified gauge.


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal">reward_per_token_internal</a>(gauge: &<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">gauge_perp::GaugePerp</a>): <a href="">u256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal">reward_per_token_internal</a>(gauge: &<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>): <a href="">u256</a> {
    <b>if</b> (gauge.total_supply == 0) {
        gauge.reward_per_token_stored
    } <b>else</b> {
        <b>let</b> last_time_reward_applicable =
            <a href="_min">math64::min</a>(<a href="_now_seconds">timestamp::now_seconds</a>(), gauge.period_finish);

        // Calculate the time difference since the last <b>update</b>
        <b>let</b> time_diff = last_time_reward_applicable - gauge.last_update_time;

        // Compute reward increment <b>with</b> scaled reward_rate
        // Convert <b>to</b> <a href="">u256</a> for precision loss prevention and handel overflow issue
        <b>let</b> reward_increment =
            ((time_diff <b>as</b> <a href="">u256</a>) * gauge.reward_rate * (<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>))
                / ((gauge.total_supply <b>as</b> <a href="">u256</a>) * <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a>);
        gauge.reward_per_token_stored + reward_increment
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward"></a>

## Function `update_reward`

Updates the global and user reward history for a gauge.


<a id="@Arguments_35"></a>

### Arguments

* <code>gauge</code> - The gauge for which to update the reward.
* <code><a href="">account</a></code> - The address of the user for whom to update the reward.


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">gauge_perp::GaugePerp</a>, <a href="">account</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>, <a href="">account</a>: <b>address</b>) {
    gauge.reward_per_token_stored = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal">reward_per_token_internal</a>(gauge);
    gauge.last_update_time = <a href="_min">math64::min</a>(
        <a href="_now_seconds">timestamp::now_seconds</a>(), gauge.period_finish
    );
    <b>if</b> (<a href="">account</a> != @0x0) {
        <b>let</b> earned = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal">earned_internal</a>(gauge, <a href="">account</a>);
        <a href="_upsert">table::upsert</a>(&<b>mut</b> gauge.rewards, <a href="">account</a>, earned);
        <a href="_upsert">table::upsert</a>(
            &<b>mut</b> gauge.user_reward_per_token_paid,
            <a href="">account</a>,
            gauge.reward_per_token_stored
        );
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal"></a>

## Function `earned_internal`

See earned rewards for user (internal)


<a id="@Arguments_36"></a>

### Arguments

* <code>gauge</code> - The gauge for which to calculate the earned rewards.
* <code><a href="">account</a></code> - The address of the user for whom to calculate the earned rewards.


<a id="@Returns_37"></a>

### Returns

The total earned rewards for the user in the specified gauge.


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal">earned_internal</a>(gauge: &<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">gauge_perp::GaugePerp</a>, <a href="">account</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_internal">earned_internal</a>(gauge: &<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>, <a href="">account</a>: <b>address</b>): u64 {
    // Check <b>if</b> the balance not exist
    <b>if</b> (!<a href="_contains">table::contains</a>(&gauge.balances, <a href="">account</a>)) {
        <b>return</b> 0
    };

    <b>let</b> reward = *<a href="_borrow">table::borrow</a>(&gauge.rewards, <a href="">account</a>);
    <b>let</b> balance = *<a href="_borrow">table::borrow</a>(&gauge.balances, <a href="">account</a>);
    <b>let</b> user_reward_per_token_paid =
        *<a href="_borrow">table::borrow</a>(&gauge.user_reward_per_token_paid, <a href="">account</a>);
    <b>let</b> reward_per_token_diff =
        <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_reward_per_token_internal">reward_per_token_internal</a>(gauge) - user_reward_per_token_paid;

    // Normalize by both <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DXLYN_DECIMAL">DXLYN_DECIMAL</a> and <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_PRECISION">PRECISION</a>
    // Convert <b>to</b> <a href="">u256</a> for precision loss prevention and handel overflow issue
    <b>let</b> scaled_reward =
        (reward <b>as</b> <a href="">u256</a>)
            + ((balance <b>as</b> <a href="">u256</a>) * reward_per_token_diff) / ((<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DXLYN_DECIMAL">DXLYN_DECIMAL</a>) <b>as</b> <a href="">u256</a>);
    (scaled_reward <b>as</b> u64)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit_internal"></a>

## Function `deposit_internal`

deposit internal


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit_internal">deposit_internal</a>&lt;AssetT&gt;(gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">gauge_perp::GaugePerp</a>, gauge_addr: <b>address</b>, user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_deposit_internal">deposit_internal</a>&lt;AssetT&gt;(
    gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>,
    gauge_addr: <b>address</b>,
    user: &<a href="">signer</a>,
    amount: u64,
) {
    <b>assert</b>!(amount &gt; 0, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO">ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO</a>);
    <b>assert</b>!(!gauge.<a href="">emergency</a>, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_IN_EMERGENCY_MODE">ERROR_IN_EMERGENCY_MODE</a>);

    <b>let</b> user_address = address_of(user);

    //<b>update</b> <b>global</b> and user reward history
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge, user_address);

    //<b>update</b> user balance
    <b>let</b> balance = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> gauge.balances, user_address, 0);
    *balance = *balance + amount;

    //<b>update</b> total supply
    gauge.total_supply = gauge.total_supply + amount;

    //transfer DXLP <a href="">coin</a> <b>to</b> gauge
    <a href="_transfer_coins">supra_account::transfer_coins</a>&lt;AssetT&gt;(
        user,
        gauge_addr,
        amount
    );

    <a href="_emit">event::emit</a>(<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_DepositEvent">DepositEvent</a> {
        user: user_address,
        amount,
        gauge: gauge_addr,
        <a href="">coin</a>: gauge.<a href="">coin</a>,
        coin_type: <a href="_type_name">type_info::type_name</a>&lt;AssetT&gt;(),
        <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>(),
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw_internal"></a>

## Function `withdraw_internal`

withdraw internal


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw_internal">withdraw_internal</a>&lt;AssetT&gt;(gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">gauge_perp::GaugePerp</a>, user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_withdraw_internal">withdraw_internal</a>&lt;AssetT&gt;(
    gauge: &<b>mut</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_GaugePerp">GaugePerp</a>, user: &<a href="">signer</a>, amount: u64
) {
    <b>assert</b>!(amount &gt; 0, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO">ERROR_AMOUNT_MUST_BE_GREATER_THAN_ZERO</a>);

    <b>let</b> user_address = address_of(user);

    //<b>update</b> <b>global</b> and user reward history
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_update_reward">update_reward</a>(gauge, user_address);

    // Check user <b>exists</b>
    <b>assert</b>!(<a href="_contains">table::contains</a>(&gauge.balances, user_address), <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    // Validate enough balance
    <b>let</b> balance = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> gauge.balances, user_address);
    <b>assert</b>!(*balance &gt;= amount, <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    *balance = *balance - amount;

    //<b>update</b> total supply
    gauge.total_supply = gauge.total_supply - amount;

    <b>let</b> gauge_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&gauge.extend_ref);

    //transfer DXLP <a href="">coin</a> from gauge <b>to</b> user <a href="">account</a>
    <a href="_transfer_coins">supra_account::transfer_coins</a>&lt;AssetT&gt;(
        &gauge_signer,
        user_address,
        amount
    );

    <a href="_emit">event::emit</a>(<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_WithdrawEvent">WithdrawEvent</a> {
        user: user_address,
        amount,
        gauge: address_of(&gauge_signer),
        <a href="">coin</a>: gauge.<a href="">coin</a>,
        coin_type: <a href="_type_name">type_info::type_name</a>&lt;AssetT&gt;(),
        <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>()
    });
}
</code></pre>



</details>
