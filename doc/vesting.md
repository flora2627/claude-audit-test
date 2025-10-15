
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::vesting`



-  [Struct `CreateVestingContractEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CreateVestingContractEvent)
-  [Struct `VestEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestEvent)
-  [Struct `AdminWithdrawEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_AdminWithdrawEvent)
-  [Struct `ShareHolderRemovedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ShareHolderRemovedEvent)
-  [Struct `ContributeEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ContributeEvent)
-  [Struct `TerminateEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_TerminateEvent)
-  [Resource `VestingSchedule`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingSchedule)
-  [Struct `VestingRecord`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord)
-  [Resource `VestingStore`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore)
-  [Resource `VestingContract`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_init_module)
-  [Function `contribute`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_contribute)
    -  [Arguments](#@Arguments_1)
-  [Function `create_vesting_contract_with_amounts`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_with_amounts)
    -  [Parameters](#@Parameters_2)
-  [Function `vest`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest)
-  [Function `vest_individual`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_individual)
    -  [Augments](#@Augments_3)
-  [Function `terminate_vesting_contract`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_terminate_vesting_contract)
    -  [Arguments](#@Arguments_4)
-  [Function `admin_withdraw`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_admin_withdraw)
    -  [Arguments](#@Arguments_5)
-  [Function `remove_shareholder`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_remove_shareholder)
    -  [Example](#@Example_6)
    -  [Arguments](#@Arguments_7)
-  [Function `get_vesting_store_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address)
-  [Function `get_vesting_schedule`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_schedule)
    -  [Arguments](#@Arguments_8)
    -  [Returns](#@Returns_9)
-  [Function `get_shareholder_vesting_record`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_shareholder_vesting_record)
    -  [Arguments](#@Arguments_10)
    -  [Returns](#@Returns_11)
-  [Function `get_remaining_grant`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_remaining_grant)
    -  [Arguments](#@Arguments_12)
    -  [Returns](#@Returns_13)
-  [Function `view_shareholders`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_view_shareholders)
    -  [Arguments](#@Arguments_14)
    -  [Returns](#@Returns_15)
-  [Function `validate_args`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_validate_args)
-  [Function `set_terminate_vesting_contract`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract)
-  [Function `assert_admin`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin)
-  [Function `vesting_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal)
-  [Function `create_vesting_contract_account`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_account)
-  [Function `get_beneficiary`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_beneficiary)
-  [Function `vest_transfer`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_transfer)


<pre><code><b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fixed_point32</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::math64</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CreateVestingContractEvent"></a>

## Struct `CreateVestingContractEvent`

Emitted when a new vesting contract is created.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CreateVestingContractEvent">CreateVestingContractEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>grant_amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>withdrawal_address: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_contract: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestEvent"></a>

## Struct `VestEvent`

Emitted when tokens are vested for a shareholder.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestEvent">VestEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>shareholder: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_contract: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>period_vested: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_AdminWithdrawEvent"></a>

## Struct `AdminWithdrawEvent`

Emitted when tokens are withdrawn from the vesting contract.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_AdminWithdrawEvent">AdminWithdrawEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_contract_address: <b>address</b></code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ShareHolderRemovedEvent"></a>

## Struct `ShareHolderRemovedEvent`

Emitted when shareHolder removed from the vesting contract.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ShareHolderRemovedEvent">ShareHolderRemovedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>shareholder: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>beneficiary: <a href="_Option">option::Option</a>&lt;<b>address</b>&gt;</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ContributeEvent"></a>

## Struct `ContributeEvent`

Emitted when a user contribute tokens into the vesting contract.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ContributeEvent">ContributeEvent</a> <b>has</b> drop, store
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
<code>vesting_store: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_TerminateEvent"></a>

## Struct `TerminateEvent`

Emitted when the vesting contract has been terminated by the admin.


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_TerminateEvent">TerminateEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_contract_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingSchedule"></a>

## Resource `VestingSchedule`



<pre><code><b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingSchedule">VestingSchedule</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>schedules: <a href="">vector</a>&lt;<a href="_FixedPoint32">fixed_point32::FixedPoint32</a>&gt;</code>
</dt>
<dd>
 Vesting schedule defined as a list of per-period fractions (e.g., [1/24, 1/24, 1/48]).
</dd>
<dt>
<code>start_timestamp_secs: u64</code>
</dt>
<dd>
 Timestamp when vesting begins.
</dd>
<dt>
<code>period_duration: u64</code>
</dt>
<dd>
 Duration of each vesting period in seconds (e.g., 1 month).
</dd>
<dt>
<code>last_vested_period: u64</code>
</dt>
<dd>
 Last vesting period
</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord"></a>

## Struct `VestingRecord`



<pre><code><b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord">VestingRecord</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>init_amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>left_amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_vested_period: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore"></a>

## Resource `VestingStore`



<pre><code><b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>extendRef: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_contracts: <a href="">vector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>nonce: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract"></a>

## Resource `VestingContract`



<pre><code><b>struct</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>state: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>beneficiaries: <a href="_SimpleMap">simple_map::SimpleMap</a>&lt;<b>address</b>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>shareholders: <a href="_SimpleMap">simple_map::SimpleMap</a>&lt;<b>address</b>, vesting::VestingRecord&gt;</code>
</dt>
<dd>
 <code>[shareholder_address]: <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord">VestingRecord</a></code>
</dd>
<dt>
<code>vesting_schedule: <a href="_VestingSchedule">vesting::VestingSchedule</a></code>
</dt>
<dd>

</dd>
<dt>
<code>withdrawal_address: <b>address</b></code>
</dt>
<dd>
 A address that withdraw back all the funds
 if the admin ends the vesting for a specific
 account or terminates the entire vesting contract.
</dd>
<dt>
<code>extendRef: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INSUFFICIENT_BALANCE"></a>

Insufficient balance


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 116;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_ADMIN"></a>

Caller is not the admin of the contract.


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 114;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CA"></a>

Deployer address


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CA">CA</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE"></a>

It represents contract is in active state


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE">CONTRACT_STATE_ACTIVE</a>: u8 = 1;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_TERMINATED"></a>

It represents contract has been terminated


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_TERMINATED">CONTRACT_STATE_TERMINATED</a>: u8 = 2;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_ADMIN_STORE_EXISTS"></a>

Admin is already exists


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_ADMIN_STORE_EXISTS">ERROR_ADMIN_STORE_EXISTS</a>: u64 = 108;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CLIFF_PERIOD_NOT_REACHED"></a>

Cannot vest before the cliff period has been reached.


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CLIFF_PERIOD_NOT_REACHED">ERROR_CLIFF_PERIOD_NOT_REACHED</a>: u64 = 111;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND"></a>

Contract not found


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>: u64 = 110;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_STILL_ACTIVE"></a>

Contract is not terminated


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_STILL_ACTIVE">ERROR_CONTRACT_STILL_ACTIVE</a>: u64 = 115;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_DENOMINATOR"></a>

Denominator must be greater than or equal to the sum of numerators.


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_DENOMINATOR">ERROR_INVALID_DENOMINATOR</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_GRANT"></a>

Grant must be greater then zero


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_GRANT">ERROR_INVALID_GRANT</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_NUMERATORS"></a>

Vesting numerators are invalid (e.g. empty, zero-valued, or inconsistent).


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_NUMERATORS">ERROR_INVALID_NUMERATORS</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_PERIOD_DURATION"></a>

Vesting period duration must be greater than zero.


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_PERIOD_DURATION">ERROR_INVALID_PERIOD_DURATION</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SCHEDULE_VECTOR"></a>

Vesting schedule vector is invalid (e.g. empty or contains zero values).


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SCHEDULE_VECTOR">ERROR_INVALID_SCHEDULE_VECTOR</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SHAREHOLDER"></a>

Vesting shareholders are invalid (e.g. empty).


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SHAREHOLDER">ERROR_INVALID_SHAREHOLDER</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_START_TIME"></a>

Vesting start time must be greater than the current time


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_START_TIME">ERROR_INVALID_START_TIME</a>: u64 = 117;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_DEPLOYER"></a>

Address is not match with deployer


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_DEPLOYER">ERROR_NOT_DEPLOYER</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NO_DUPLICATE_SHAREHOLDER"></a>

Shareholders must be unique


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NO_DUPLICATE_SHAREHOLDER">ERROR_NO_DUPLICATE_SHAREHOLDER</a>: u64 = 112;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_SHAREHOLDER_NOT_EXISTS"></a>

Shareholder is not exists


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_SHAREHOLDER_NOT_EXISTS">ERROR_SHAREHOLDER_NOT_EXISTS</a>: u64 = 109;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_TERMINATED_CONTRACT"></a>

Contract is terminated


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_TERMINATED_CONTRACT">ERROR_TERMINATED_CONTRACT</a>: u64 = 113;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_ADMIN_SEED"></a>

Vesting Admin seed


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_ADMIN_SEED">VESTING_ADMIN_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [86, 69, 83, 84, 73, 78, 71, 95, 65, 68, 77, 73, 78];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_RESOURCE_SEED"></a>

Vesting resource account creation seed


<pre><code><b>const</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_RESOURCE_SEED">VESTING_RESOURCE_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [86, 69, 83, 84, 73, 78, 71];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_init_module"></a>

## Function `init_module`

Initialize admin store with only developer


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_init_module">init_module</a>(admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_init_module">init_module</a>(admin: &<a href="">signer</a>) {
    <b>let</b> constructorRef = &<a href="_create_named_object">object::create_named_object</a>(admin, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_ADMIN_SEED">VESTING_ADMIN_SEED</a>);
    <b>let</b> extendRef = <a href="_generate_extend_ref">object::generate_extend_ref</a>(constructorRef);
    <b>let</b> obj_signer = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&extendRef);

    <b>move_to</b>(
        obj_signer,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a> {
            admin: address_of(admin),
            nonce: 0,
            extendRef,
            vesting_contracts: <a href="_empty">vector::empty</a>&lt;<b>address</b>&gt;(),
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_contribute"></a>

## Function `contribute`

Allows a user to contribute tokens to the vesting contract.

The contributed tokens are transferred from the user's account
into the vesting store for future allocation or vesting.


<a id="@Arguments_1"></a>

### Arguments

* <code>user</code> - The signer contributing tokens.
* <code>amount</code> - The number of tokens to contribute.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_contribute">contribute</a>(user: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_contribute">contribute</a>(user: &<a href="">signer</a>, amount: u64) {
    <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();
    <b>let</b> user_addr = address_of(user);
    <b>let</b> balance = <a href="_balance">primary_fungible_store::balance</a>(
        user_addr, dxlyn_metadata
    );

    // Must be not zero
    <b>assert</b>!(balance &gt; 0, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);
    <b>let</b> store_addr = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>();

    <a href="_transfer">primary_fungible_store::transfer</a>(
        user,
        dxlyn_metadata,
        store_addr,
        amount
    );

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ContributeEvent">ContributeEvent</a> {
            user: user_addr,
            amount,
            vesting_store: store_addr,
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_with_amounts"></a>

## Function `create_vesting_contract_with_amounts`

Initializes a vesting contract with specified shareholder allocations and a vesting schedule.


<a id="@Parameters_2"></a>

### Parameters

- <code>admin</code>: Signer creating and managing the contract.
- <code>shareholders</code>: List of beneficiary addresses.
- <code>shares</code>: Corresponding share amounts for each beneficiary.
- <code>numerators</code>: Fractions of the total vesting schedule for each period (used with <code>denominator</code>).
- <code>denominator</code>: Common denominator for all vesting fractions.
- <code>start_timestamp_secs</code>: Vesting start time (in seconds since UNIX epoch).
- <code>period_duration</code>: Duration of each vesting period (in seconds).
- <code>withdrawal_address</code>: Address authorized to withdraw vested funds.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_with_amounts">create_vesting_contract_with_amounts</a>(admin: &<a href="">signer</a>, shareholders: <a href="">vector</a>&lt;<b>address</b>&gt;, shares: <a href="">vector</a>&lt;u64&gt;, numerators: <a href="">vector</a>&lt;u64&gt;, denominator: u64, start_timestamp_secs: u64, period_duration: u64, withdrawal_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_with_amounts">create_vesting_contract_with_amounts</a>(
    admin: &<a href="">signer</a>,
    shareholders: <a href="">vector</a>&lt;<b>address</b>&gt;,
    shares: <a href="">vector</a>&lt;u64&gt;,
    numerators: <a href="">vector</a>&lt;u64&gt;,
    denominator: u64,
    start_timestamp_secs: u64,
    period_duration: u64,
    withdrawal_address: <b>address</b>
) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>
{
    // Validate args
    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_validate_args">validate_args</a>(
        period_duration,
        denominator,
        numerators,
        shareholders,
        shares,
        start_timestamp_secs
    );

    <b>let</b> vesting_store_addr = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>();
    <b>let</b> vesting_store = <b>borrow_global_mut</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>&gt;(vesting_store_addr);
    <b>assert</b>!(vesting_store.admin == address_of(admin), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    <b>let</b> store_admin = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&vesting_store.extendRef);

    // Generated the duration ratio
    <b>let</b> schedules = <a href="_map_ref">vector::map_ref</a>(
        &numerators,
        |numerator| { <a href="_create_from_rational">fixed_point32::create_from_rational</a>(*numerator, denominator) }
    );
    <b>assert</b>!(!<a href="_is_empty">vector::is_empty</a>(&schedules), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SCHEDULE_VECTOR">ERROR_INVALID_SCHEDULE_VECTOR</a>);
    <b>assert</b>!(
        <a href="_get_raw_value">fixed_point32::get_raw_value</a>(*<a href="_borrow">vector::borrow</a>(&schedules, 0)) &gt; 0,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SCHEDULE_VECTOR">ERROR_INVALID_SCHEDULE_VECTOR</a>
    );

    <b>let</b> vesting_schedule = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingSchedule">VestingSchedule</a> {
        schedules,
        last_vested_period: 0,
        period_duration,
        start_timestamp_secs
    };

    <b>let</b> grant_amount = 0;
    <b>let</b> shareholders_map = <a href="_create">simple_map::create</a>&lt;<b>address</b>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord">VestingRecord</a>&gt;();

    <a href="_for_each_reverse">vector::for_each_reverse</a>(
        shares,
        |amount| {
            <b>let</b> shareholder = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> shareholders);
            <b>assert</b>!(
                !<a href="_contains_key">simple_map::contains_key</a>(&shareholders_map, &shareholder),
                <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NO_DUPLICATE_SHAREHOLDER">ERROR_NO_DUPLICATE_SHAREHOLDER</a>
            );
            <a href="_upsert">simple_map::upsert</a>(
                &<b>mut</b> shareholders_map,
                shareholder,
                <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord">VestingRecord</a> {
                    init_amount: amount,
                    left_amount: amount,
                    last_vested_period: vesting_schedule.last_vested_period
                }
            );

            grant_amount = grant_amount + amount;
        }
    );

    <b>assert</b>!(grant_amount &gt; 0, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_GRANT">ERROR_INVALID_GRANT</a>);

    <b>let</b> extendRef = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_account">create_vesting_contract_account</a>(store_admin, vesting_store);
    <b>let</b> res_signer = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&extendRef);
    <b>let</b> res_addr = address_of(res_signer);

    // Transfer <a href="">vesting</a> <b>to</b> resource <b>address</b>
    <a href="_transfer">primary_fungible_store::transfer</a>(
        store_admin,
        <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
        res_addr,
        grant_amount
    );

    <a href="_push_back">vector::push_back</a>(&<b>mut</b> vesting_store.vesting_contracts, res_addr);

    <b>let</b> store_admin_addr = address_of(store_admin);
    <b>move_to</b>(
        res_signer,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a> {
            state: <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE">CONTRACT_STATE_ACTIVE</a>,
            admin: store_admin_addr,
            withdrawal_address,
            shareholders: shareholders_map,
            beneficiaries: <a href="_create">simple_map::create</a>&lt;<b>address</b>, <b>address</b>&gt;(),
            extendRef,
            vesting_schedule
        }
    );

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CreateVestingContractEvent">CreateVestingContractEvent</a> {
            grant_amount,
            withdrawal_address,
            vesting_contract: res_addr
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest"></a>

## Function `vest`



<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest">vest</a>(contract_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest">vest</a>(contract_address: <b>address</b>) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>
{
    <b>assert</b>!(<b>exists</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract_address), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>);

    <b>let</b> contract = <b>borrow_global_mut</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract_address);
    <b>assert</b>!(contract.state == <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE">CONTRACT_STATE_ACTIVE</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_TERMINATED_CONTRACT">ERROR_TERMINATED_CONTRACT</a>);

    <b>let</b> vesting_starts_at = contract.vesting_schedule.start_timestamp_secs;
    <b>let</b> vesting_cliff = contract.vesting_schedule.period_duration;

    // Vest only after the current time exceeds vesting_starts_at + vesting_cliff
    <b>if</b> (<a href="_now_seconds">timestamp::now_seconds</a>() &gt;= vesting_starts_at + vesting_cliff) {
        <b>let</b> addresses = <a href="_keys">simple_map::keys</a>(&contract.shareholders);
        <b>while</b> (<a href="_length">vector::length</a>(&addresses) &gt; 0) {
            <b>let</b> addr = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> addresses);
            <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal">vesting_internal</a>(contract_address, contract, addr);
        };

        // Terminate contract once the contract balance became zero.
        <b>let</b> contract_balance = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_balance_of">dxlyn_coin::balance_of</a>(contract_address);
        <b>if</b> (contract_balance == 0) {
            <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract">set_terminate_vesting_contract</a>(contract_address, contract);
        }
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_individual"></a>

## Function `vest_individual`

Vests tokens for a specific shareholder according to the vesting schedule.


<a id="@Augments_3"></a>

### Augments

- <code>contract_address</code>: The address where the <code><a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a></code> resource is stored.
- <code>shareholder_address</code>: The address of the shareholder whose tokens are to be vested.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_individual">vest_individual</a>(contract_address: <b>address</b>, shareholder_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_individual">vest_individual</a>(
    contract_address: <b>address</b>, shareholder_address: <b>address</b>
) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>
{
    <b>assert</b>!(<b>exists</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract_address), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>);

    <b>let</b> contract = <b>borrow_global_mut</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract_address);
    <b>assert</b>!(contract.state == <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE">CONTRACT_STATE_ACTIVE</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_TERMINATED_CONTRACT">ERROR_TERMINATED_CONTRACT</a>);

    <b>let</b> vesting_starts_at = contract.vesting_schedule.start_timestamp_secs;
    <b>let</b> vesting_cliff = contract.vesting_schedule.period_duration;

    // Throws Error <b>if</b> <a href="">vesting</a> hasn't started yet.
    <b>assert</b>!(
        <a href="_now_seconds">timestamp::now_seconds</a>() &gt;= vesting_starts_at + vesting_cliff,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CLIFF_PERIOD_NOT_REACHED">ERROR_CLIFF_PERIOD_NOT_REACHED</a>
    );

    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal">vesting_internal</a>(contract_address, contract, shareholder_address);

    // Terminate contract once the contract balance became zero.
    <b>let</b> contract_balance = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_balance_of">dxlyn_coin::balance_of</a>(contract_address);
    <b>if</b> (contract_balance == 0) {
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract">set_terminate_vesting_contract</a>(contract_address, contract);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_terminate_vesting_contract"></a>

## Function `terminate_vesting_contract`

Terminates the vesting contract and transfers all remaining funds
back to the designated withdrawal address.


<a id="@Arguments_4"></a>

### Arguments

* <code>admin</code> - The signer authorized to terminate the contract.
* <code>contract</code> - The address where the <code><a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a></code> resource is stored.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_terminate_vesting_contract">terminate_vesting_contract</a>(admin: &<a href="">signer</a>, contract: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_terminate_vesting_contract">terminate_vesting_contract</a>(
    admin: &<a href="">signer</a>, contract: <b>address</b>
) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>
{
    // Vest pending amounts before termination
    // Contract must be active before terminate and it already handled in `vest` function
    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest">vest</a>(contract);

    <b>let</b> res = <b>borrow_global_mut</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract);

    // Only admin can terminate the contract
    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin">assert_admin</a>(address_of(admin));

    // Set each shareholder's `left_amount` <b>to</b> 0
    <b>let</b> shareholders_address = <a href="_keys">simple_map::keys</a>(&res.shareholders);
    <a href="_for_each_ref">vector::for_each_ref</a>(
        &shareholders_address,
        |shareholder| {
            <b>let</b> shareholder_amount =
                <a href="_borrow_mut">simple_map::borrow_mut</a>(
                    &<b>mut</b> res.shareholders, shareholder
                );
            shareholder_amount.left_amount = 0;
        },
    );

    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract">set_terminate_vesting_contract</a>(contract, res);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_admin_withdraw"></a>

## Function `admin_withdraw`

Withdraws all remaining funds to the contract's withdrawal address.

This function can only be called after the vesting contract has been terminated.


<a id="@Arguments_5"></a>

### Arguments

* <code>admin</code> - The signer authorized to perform the withdrawal.
* <code>contract</code> - The address where the <code><a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a></code> resource is stored.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_admin_withdraw">admin_withdraw</a>(admin: &<a href="">signer</a>, contract: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_admin_withdraw">admin_withdraw</a>(
    admin: &<a href="">signer</a>,
    contract: <b>address</b>
) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>
{
    <b>let</b> res = <b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract);
    <b>assert</b>!(
        res.state == <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_TERMINATED">CONTRACT_STATE_TERMINATED</a>,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_STILL_ACTIVE">ERROR_CONTRACT_STILL_ACTIVE</a>,
    );

    // Only admin can terminate the contract
    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin">assert_admin</a>(address_of(admin));

    <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();
    <b>let</b> contract_balance = <a href="_balance">primary_fungible_store::balance</a>(
        contract, dxlyn_metadata
    );

    // Balance must be not zero
    <b>assert</b>!(contract_balance &gt; 0, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>);

    <b>let</b> vesting_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&res.extendRef);

    // Transfer store admin
    <a href="_transfer">primary_fungible_store::transfer</a>(
        &vesting_signer,
        dxlyn_metadata,
        res.withdrawal_address,
        contract_balance
    );

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_AdminWithdrawEvent">AdminWithdrawEvent</a> {
            admin: res.admin,
            vesting_contract_address: contract,
            amount: contract_balance
        },
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_remove_shareholder"></a>

## Function `remove_shareholder`

Removes a shareholder from the vesting contract, revoking their allocation.

This function can only be called by the contract admin.


<a id="@Example_6"></a>

### Example

If a shareholder is flagged as suspicious or no longer eligible, the admin can remove them.


<a id="@Arguments_7"></a>

### Arguments

* <code>admin</code> - The signer authorized to perform the removal.
* <code>contract</code> - The address where the <code><a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a></code> resource is stored.
* <code>shareholder</code> - The address of the shareholder to be removed.


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_remove_shareholder">remove_shareholder</a>(admin: &<a href="">signer</a>, contract: <b>address</b>, shareholder: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_remove_shareholder">remove_shareholder</a>(
    admin: &<a href="">signer</a>,
    contract: <b>address</b>,
    shareholder: <b>address</b>
) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>
{
    <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin">assert_admin</a>(address_of(admin));

    <b>let</b> res = <b>borrow_global_mut</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract);
    <b>assert</b>!(res.state == <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_ACTIVE">CONTRACT_STATE_ACTIVE</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_TERMINATED_CONTRACT">ERROR_TERMINATED_CONTRACT</a>);

    <b>let</b> shareholders = &<b>mut</b> res.shareholders;
    <b>assert</b>!(
        <a href="_contains_key">simple_map::contains_key</a>(
            shareholders,
            &shareholder,
        ),
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_SHAREHOLDER_NOT_EXISTS">ERROR_SHAREHOLDER_NOT_EXISTS</a>,
    );

    <b>let</b> shareholder_amount =
        <a href="_borrow">simple_map::borrow</a>(shareholders, &shareholder).left_amount;
    <b>let</b> dxlyn_metadata = <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>();

    <b>let</b> res_signer = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&res.extendRef);
    <a href="_transfer">primary_fungible_store::transfer</a>(
        res_signer,
        dxlyn_metadata,
        res.withdrawal_address,
        shareholder_amount
    );

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_AdminWithdrawEvent">AdminWithdrawEvent</a> {
            admin: res.admin,
            vesting_contract_address: contract,
            amount: shareholder_amount
        },
    );

    // remove `shareholder_address`` from `vesting_contract.shareholders`
    <b>let</b> (_, shareholders_vesting) =
        <a href="_remove">simple_map::remove</a>(shareholders, &shareholder);

    // remove `shareholder_address` from `vesting_contract.beneficiaries`
    <b>let</b> beneficiary = <a href="_none">option::none</a>();
    <b>let</b> shareholder_beneficiaries = &<b>mut</b> res.beneficiaries;

    // Not all shareholders have their beneficiaries, so before removing them, we need <b>to</b> check <b>if</b> the beneficiary <b>exists</b>
    <b>if</b> (<a href="_contains_key">simple_map::contains_key</a>(shareholder_beneficiaries, &shareholder)) {
        <b>let</b> (_, shareholder_beneficiary) =
            <a href="_remove">simple_map::remove</a>(shareholder_beneficiaries, &shareholder);
        beneficiary = <a href="_some">option::some</a>(shareholder_beneficiary);
    };

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ShareHolderRemovedEvent">ShareHolderRemovedEvent</a> {
            shareholder,
            beneficiary,
            amount: shareholders_vesting.left_amount
        },
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address"></a>

## Function `get_vesting_store_address`

Returns the vesting store object address.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CA">CA</a>, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_ADMIN_SEED">VESTING_ADMIN_SEED</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_schedule"></a>

## Function `get_vesting_schedule`

Returns the vesting schedule details of a given contract.


<a id="@Arguments_8"></a>

### Arguments

* <code>contract</code> - The address of the vesting contract.


<a id="@Returns_9"></a>

### Returns

A tuple containing:
* <code>withdrawal_address</code> - Address authorized to withdraw vested tokens.
* <code>admin</code> - Address of the contract administrator.
* <code>period_duration</code> - Duration (in seconds) of each vesting period.
* <code>last_vested_period</code> - The index of the last vested period.
* <code>state</code> - The state of the contract (1 , 2).


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_schedule">get_vesting_schedule</a>(contract: <b>address</b>): (<b>address</b>, <b>address</b>, u64, u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_schedule">get_vesting_schedule</a>(
    contract: <b>address</b>
): (<b>address</b>, <b>address</b>, u64, u64, u8) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>
{
    <b>let</b> contract_data = <b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract);
    <b>let</b> schedule = contract_data.vesting_schedule;
    (
        contract_data.withdrawal_address,
        contract_data.admin,
        schedule.period_duration,
        schedule.last_vested_period,
        contract_data.state,
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_shareholder_vesting_record"></a>

## Function `get_shareholder_vesting_record`

Returns the vesting record of a specific shareholder.


<a id="@Arguments_10"></a>

### Arguments

* <code>contract</code> - The address of the vesting contract.
* <code>shareholder</code> - The address of the shareholder.


<a id="@Returns_11"></a>

### Returns

A tuple containing:
* <code>init_amount</code> - The initial vested amount assigned to the shareholder.
* <code>left_amount</code> - The remaining (unclaimed) vested amount.
* <code>last_vested_period</code> - The last vesting period index for this shareholder.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_shareholder_vesting_record">get_shareholder_vesting_record</a>(contract: <b>address</b>, shareholder: <b>address</b>): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_shareholder_vesting_record">get_shareholder_vesting_record</a>(
    contract: <b>address</b>,
    shareholder: <b>address</b>
): (u64, u64, u64) <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>
{
    <b>assert</b>!(<b>exists</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>);

    <b>let</b> record = <a href="_borrow">simple_map::borrow</a>(
        &<b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract).shareholders,
        &shareholder,
    );
    (
        record.init_amount,
        record.left_amount,
        record.last_vested_period
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_remaining_grant"></a>

## Function `get_remaining_grant`

Returns the remaining unclaimed vesting amount for a given shareholder.


<a id="@Arguments_12"></a>

### Arguments

* <code>contract</code> - The address of the vesting contract.
* <code>shareholder</code> - The address of the shareholder.


<a id="@Returns_13"></a>

### Returns

* <code>left_amount</code> - The remaining grant (unclaimed vested tokens) of the shareholder.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_remaining_grant">get_remaining_grant</a>(contract: <b>address</b>, shareholder: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_remaining_grant">get_remaining_grant</a>(
    contract: <b>address</b>,
    shareholder: <b>address</b>
): u64 <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>
{
    <b>assert</b>!(<b>exists</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>);

    <a href="_borrow">simple_map::borrow</a>(
        &<b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract).shareholders,
        &shareholder,
    ).left_amount
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_view_shareholders"></a>

## Function `view_shareholders`

Returns all shareholder addresses for a given vesting contract.


<a id="@Arguments_14"></a>

### Arguments

* <code>contract</code> - Address of the vesting contract.


<a id="@Returns_15"></a>

### Returns

* <code><a href="">vector</a>&lt;<b>address</b>&gt;</code> - List of shareholder addresses.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_view_shareholders">view_shareholders</a>(contract: <b>address</b>): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_view_shareholders">view_shareholders</a>(
    contract: <b>address</b>,
): <a href="">vector</a>&lt;<b>address</b>&gt; <b>acquires</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a> {
    <b>assert</b>!(<b>exists</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_CONTRACT_NOT_FOUND">ERROR_CONTRACT_NOT_FOUND</a>);
    <b>let</b> shareholders = &<b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>&gt;(contract).shareholders;
    <a href="_keys">simple_map::keys</a>(shareholders)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_validate_args"></a>

## Function `validate_args`



<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_validate_args">validate_args</a>(period_duration: u64, denominator: u64, numerators: <a href="">vector</a>&lt;u64&gt;, shareholders: <a href="">vector</a>&lt;<b>address</b>&gt;, shares: <a href="">vector</a>&lt;u64&gt;, start_timestamp_secs: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>inline <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_validate_args">validate_args</a>(
    period_duration: u64,
    denominator: u64,
    numerators: <a href="">vector</a>&lt;u64&gt;,
    shareholders: <a href="">vector</a>&lt;<b>address</b>&gt;,
    shares: <a href="">vector</a>&lt;u64&gt;,
    start_timestamp_secs: u64
)
{
    <b>assert</b>!(start_timestamp_secs &gt;= <a href="_now_seconds">timestamp::now_seconds</a>(), <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_START_TIME">ERROR_INVALID_START_TIME</a>);
    <b>assert</b>!(period_duration &gt; 0, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_PERIOD_DURATION">ERROR_INVALID_PERIOD_DURATION</a>);
    <b>assert</b>!(denominator &gt; 0, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_DENOMINATOR">ERROR_INVALID_DENOMINATOR</a>);
    <b>let</b> sum = <a href="_fold">vector::fold</a>(
        numerators,
        0,
        |acc, numerator| { acc + numerator },
    );
    <b>assert</b>!(
        sum &gt; 0,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_NUMERATORS">ERROR_INVALID_NUMERATORS</a>
    );
    <b>assert</b>!(
        sum &lt;= denominator,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_NUMERATORS">ERROR_INVALID_NUMERATORS</a>
    );

    <b>let</b> shareholders_len = <a href="_length">vector::length</a>(&shareholders);

    <b>assert</b>!(
        shareholders_len &gt; 0,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SHAREHOLDER">ERROR_INVALID_SHAREHOLDER</a>
    );

    <b>assert</b>!(
        shareholders_len == <a href="_length">vector::length</a>(&shares),
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_SHAREHOLDER">ERROR_INVALID_SHAREHOLDER</a>
    );

    // Numerators must not be empty, and the first and last elements must not be zero
    <b>assert</b>!(
        !<a href="_is_empty">vector::is_empty</a>(&numerators) && *<a href="_borrow">vector::borrow</a>(&numerators, 0) != 0 && *<a href="_borrow">vector::borrow</a>(
            &numerators,
            <a href="_length">vector::length</a>(&numerators) - 1
        ) &gt; 0,
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_INVALID_NUMERATORS">ERROR_INVALID_NUMERATORS</a>
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract"></a>

## Function `set_terminate_vesting_contract`



<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract">set_terminate_vesting_contract</a>(contract_address: <b>address</b>, contract: &<b>mut</b> <a href="_VestingContract">vesting::VestingContract</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>inline <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_set_terminate_vesting_contract">set_terminate_vesting_contract</a>(contract_address: <b>address</b>, contract: &<b>mut</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>)
{
    contract.state = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_CONTRACT_STATE_TERMINATED">CONTRACT_STATE_TERMINATED</a>;
    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_TerminateEvent">TerminateEvent</a> {
            admin: contract.admin,
            vesting_contract_address: contract_address
        },
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin"></a>

## Function `assert_admin`



<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin">assert_admin</a>(admin: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>inline <b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_assert_admin">assert_admin</a>(admin: <b>address</b>)
{
    <b>let</b> vesting_store = <b>borrow_global</b>&lt;<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>&gt;(<a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>());
    <b>assert</b>!(vesting_store.admin == admin, <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal"></a>

## Function `vesting_internal`



<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal">vesting_internal</a>(contract_address: <b>address</b>, contract_state: &<b>mut</b> <a href="_VestingContract">vesting::VestingContract</a>, shareholder_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vesting_internal">vesting_internal</a>(
    contract_address: <b>address</b>,
    contract_state: &<b>mut</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a>,
    shareholder_address: <b>address</b>
)
{
    <b>assert</b>!(
        <a href="_contains_key">simple_map::contains_key</a>(&contract_state.shareholders, &shareholder_address),
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_ERROR_SHAREHOLDER_NOT_EXISTS">ERROR_SHAREHOLDER_NOT_EXISTS</a>
    );

    <b>let</b> vesting_schedule = &contract_state.vesting_schedule;
    <b>let</b> period_duration = vesting_schedule.period_duration;
    <b>let</b> vesting_starts_at = contract_state.vesting_schedule.start_timestamp_secs;

    <b>let</b> beneficiary = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_beneficiary">get_beneficiary</a>(contract_state.beneficiaries, &shareholder_address);
    <b>let</b> vesting_record =
        <a href="_borrow_mut">simple_map::borrow_mut</a>(&<b>mut</b> contract_state.shareholders, &shareholder_address);
    <b>let</b> schedules = &vesting_schedule.schedules;
    <b>let</b> last_period = vesting_record.last_vested_period;
    <b>let</b> next_period = last_period + 1;
    <b>let</b> left_amount = vesting_record.left_amount;

    <b>let</b> completed_periods =
        (<a href="_now_seconds">timestamp::now_seconds</a>() - vesting_starts_at) / period_duration;

    <b>let</b> total_fraction = <a href="_create_from_rational">fixed_point32::create_from_rational</a>(0, 1);

    // Loop through eligible periods from next_period up <b>to</b> completed_periods
    <b>while</b> (completed_periods &gt;= next_period
        && left_amount &gt; 0
        && next_period &lt;= <a href="_length">vector::length</a>(schedules)) {
        <b>let</b> schedule_idx = next_period - 1;
        <b>let</b> fraction = *<a href="_borrow">vector::borrow</a>(schedules, schedule_idx);

        total_fraction = <a href="_add">fixed_point32::add</a>(total_fraction, fraction);

        next_period = next_period + 1;
    };

    // Optional fast-forward calculation <b>if</b> for some reason next_period was skipped
    <b>let</b> period_fast_forward: u64 = 0;

    // Handle corner case <b>where</b> last vested period is greater or equal <b>to</b> next_period
    <b>if</b> (completed_periods &gt;= next_period && left_amount &gt; 0) {
        <b>let</b> final_fraction = *<a href="_borrow">vector::borrow</a>(schedules, <a href="_length">vector::length</a>(schedules)
            - 1);

        // Calculate how many periods were missed and should be fast-forwarded
        period_fast_forward = completed_periods - next_period + 1;

        <b>let</b> add_fraction =
            <a href="_multiply_u64_return_fixpoint32">fixed_point32::multiply_u64_return_fixpoint32</a>(
                period_fast_forward, final_fraction
            );

        total_fraction = <a href="_add">fixed_point32::add</a>(total_fraction, add_fraction);
    };

    <b>let</b> is_transferred =
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_transfer">vest_transfer</a>(
            vesting_record,
            &contract_state.extendRef,
            beneficiary,
            total_fraction
        );

    //If no amount was transferred DO NOT advance last_vested_period in the <a href="">vesting</a> record
    // This check is needed because <b>if</b> the fraction is too low, `vesting_record.init_amount * vesting_fraction`
    // may be 0. By not advancing, we allow for the possibility for `vesting_fraction` <b>to</b> become large enough
    // otherwise, even <b>if</b> <a href="">vesting</a> period passes and shareholder regularly calls `vest_individual`, the shareholder
    // may never receive <a href="">any</a> amount.
    <b>if</b> (!is_transferred) { <b>return</b> };
    next_period = next_period + period_fast_forward;

    <a href="_emit">event::emit</a>(
        <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestEvent">VestEvent</a> {
            admin: contract_state.admin,
            shareholder: shareholder_address,
            vesting_contract: contract_address,
            period_vested: next_period - 1
        }
    );

    // Updating the `last_vested_period`
    vesting_record.last_vested_period = next_period - 1;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_account"></a>

## Function `create_vesting_contract_account`

Create the unique resource account to store <code><a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingContract">VestingContract</a></code>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_account">create_vesting_contract_account</a>(admin: &<a href="">signer</a>, vesting_store: &<b>mut</b> vesting::VestingStore): <a href="_ExtendRef">object::ExtendRef</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_create_vesting_contract_account">create_vesting_contract_account</a>(
    admin: &<a href="">signer</a>,
    vesting_store: &<b>mut</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingStore">VestingStore</a>
): ExtendRef {
    <b>let</b> store_addr = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_vesting_store_address">get_vesting_store_address</a>();
    <b>let</b> seed = <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VESTING_RESOURCE_SEED">VESTING_RESOURCE_SEED</a>;
    <b>let</b> nonce = vesting_store.nonce;

    <a href="_append">vector::append</a>(&<b>mut</b> seed, to_bytes(&store_addr));
    <a href="_append">vector::append</a>(&<b>mut</b> seed, to_bytes(&nonce));
    vesting_store.nonce = nonce + 1;

    <b>let</b> constructorRef = &<a href="_create_named_object">object::create_named_object</a>(admin, seed);
    <a href="_generate_extend_ref">object::generate_extend_ref</a>(constructorRef)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_beneficiary"></a>

## Function `get_beneficiary`

Retries the beneficiary of the shareholder


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_beneficiary">get_beneficiary</a>(beneficiaries: <a href="_SimpleMap">simple_map::SimpleMap</a>&lt;<b>address</b>, <b>address</b>&gt;, addr: &<b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_get_beneficiary">get_beneficiary</a>(
    beneficiaries: SimpleMap&lt;<b>address</b>, <b>address</b>&gt;, addr: &<b>address</b>
): <b>address</b> {
    <b>if</b> (<a href="_contains_key">simple_map::contains_key</a>(&beneficiaries, addr)) {
        *<a href="_borrow">simple_map::borrow</a>(&beneficiaries, addr)
    } <b>else</b> { *addr }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_transfer"></a>

## Function `vest_transfer`

Transfers from the contract to beneficiary <code>vesting_fraction</code> of <code>vesting_record.init_amount</code>
It returns whether any amount was transferred or not.


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_transfer">vest_transfer</a>(vesting_record: &<b>mut</b> vesting::VestingRecord, extendRef: &<a href="_ExtendRef">object::ExtendRef</a>, beneficiary: <b>address</b>, fraction: <a href="_FixedPoint32">fixed_point32::FixedPoint32</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_vest_transfer">vest_transfer</a>(
    vesting_record: &<b>mut</b> <a href="vesting.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_vesting_VestingRecord">VestingRecord</a>,
    extendRef: &ExtendRef,
    beneficiary: <b>address</b>,
    fraction: FixedPoint32
): bool {
    <b>let</b> contract_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(extendRef);
    <b>let</b> amount =
        <b>min</b>(
            vesting_record.left_amount,
            <a href="_multiply_u64">fixed_point32::multiply_u64</a>(vesting_record.init_amount, fraction)
        );

    <b>if</b> (amount &gt; 0) {
        vesting_record.left_amount = vesting_record.left_amount - amount;
        // Transfer <b>to</b> beneficiary
        <a href="_transfer">primary_fungible_store::transfer</a>(
            &contract_signer,
            <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
            beneficiary,
            amount
        );
        <b>true</b>
    } <b>else</b> { <b>false</b> }
}
</code></pre>



</details>
