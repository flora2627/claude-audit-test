
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::minter`



-  [Struct `SetOwnerEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SetOwnerEvent)
-  [Resource `DxlynInfo`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_initialize)
-  [Function `first_mint`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_first_mint)
    -  [Arguments](#@Arguments_1)
-  [Function `set_owner`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_owner)
    -  [Arguments](#@Arguments_2)
-  [Function `active_period`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period)
    -  [Returns](#@Returns_3)
-  [Function `get_next_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission)
    -  [Returns](#@Returns_4)
-  [Function `get_previous_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_previous_emission)
    -  [Returns](#@Returns_5)
-  [Function `get_minter_object_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address)
    -  [Returns](#@Returns_6)
-  [Function `set_active_period`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_active_period)
    -  [Arguments](#@Arguments_7)
-  [Function `calculate_rebase_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_calculate_rebase_gauge)
    -  [Returns:](#@Returns:_8)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
<b>use</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::emission</a>;
<b>use</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::voting_escrow</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SetOwnerEvent"></a>

## Struct `SetOwnerEvent`

Event emitted when owner changed


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SetOwnerEvent">SetOwnerEvent</a> <b>has</b> drop, store
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo"></a>

## Resource `DxlynInfo`



<pre><code><b>struct</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>extend_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>period: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>vesting_admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>is_initialized: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>asset_object_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_INSUFFICIENT_BALANCE"></a>

Insufficient DXLYN balance to perform the operation


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_NOT_OWNER"></a>

Caller must be the owner to perform this operation


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_SUPPLY"></a>

Initial supply of DXLYN token


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_SUPPLY">INITIAL_SUPPLY</a>: u64 = 100000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SC_ADMIN"></a>

Creator address of the minter object account


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_AMOUNT_SCALE"></a>

Amount scale for calculations


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_AMOUNT_SCALE">AMOUNT_SCALE</a>: <a href="">u256</a> = 10000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK"></a>

Week in seconds


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_MINTER_OBJECT_ACCOUNT_SEED"></a>

The seed used to create the minter object account


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_MINTER_OBJECT_ACCOUNT_SEED">MINTER_OBJECT_ACCOUNT_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [77, 73, 78, 84, 69, 82];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_RATE_BPS"></a>

Decay rate in basis points (bps) for the DXLYN token emission


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_RATE_BPS">DECAY_RATE_BPS</a>: u64 = 1;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_START_EPOCH"></a>

The epoch at which the decay starts


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_START_EPOCH">DECAY_START_EPOCH</a>: u64 = 13;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DXLYN_DECIMAL"></a>

The number of decimals in a DXLYN token (10^8)


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DXLYN_DECIMAL">DXLYN_DECIMAL</a>: u64 = 100000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND"></a>

DXLYN info not set up yet


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_RATE_BPS"></a>

Initial rate in basis points (bps) for the DXLYN token emission


<pre><code><b>const</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_RATE_BPS">INITIAL_RATE_BPS</a>: u64 = 2;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_initialize"></a>

## Function `initialize`

Initialize module - as initialize dxlyn token


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_initialize">initialize</a>(token_admin: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_initialize">initialize</a>(token_admin: &<a href="">signer</a>) {
    <b>let</b> constructor_ref =
        &<a href="_create_named_object">object::create_named_object</a>(token_admin, <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_MINTER_OBJECT_ACCOUNT_SEED">MINTER_OBJECT_ACCOUNT_SEED</a>);

    <b>let</b> extend_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(constructor_ref);

    <b>let</b> minter_obj_signer = <a href="_generate_signer">object::generate_signer</a>(constructor_ref);
    <b>let</b> active_period = ((<a href="_now_seconds">timestamp::now_seconds</a>(
    ) + (2 * <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>)) / <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>) * <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>; // Mimics MinterUpgradeable.initialize

    // Initialize <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_initialized_emission">emission::initialized_emission</a>(
        &minter_obj_signer,
        @emission_admin,
        <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_SUPPLY">INITIAL_SUPPLY</a> * <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DXLYN_DECIMAL">DXLYN_DECIMAL</a>,
        <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_INITIAL_RATE_BPS">INITIAL_RATE_BPS</a>,
        <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_RATE_BPS">DECAY_RATE_BPS</a>,
        <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DECAY_START_EPOCH">DECAY_START_EPOCH</a>,
    );

    <b>move_to</b>(
        &minter_obj_signer,
        <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
            extend_ref,
            period: active_period,
            owner: @owner,
            vesting_admin: @vesting_admin,
            asset_object_address: object_address(&<a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>()),
            is_initialized: <b>false</b>
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_first_mint"></a>

## Function `first_mint`

Perform the first mint of tokens (owner only)


<a id="@Arguments_1"></a>

### Arguments

* <code>deployer</code> - Reference to the signer initiating the first mint (must be the contract owner)


<pre><code><b>public</b> entry <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_first_mint">first_mint</a>(deployer: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_first_mint">first_mint</a>(deployer: &<a href="">signer</a>) <b>acquires</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
    <b>let</b> object_add = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>assert</b>!(<b>exists</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(object_add), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>);

    <b>let</b> dxlyn_info = <b>borrow_global_mut</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(object_add);
    <b>assert</b>!(dxlyn_info.owner == address_of(deployer), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <b>if</b> (!dxlyn_info.is_initialized) {
        dxlyn_info.period = (<a href="_now_seconds">timestamp::now_seconds</a>() / <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>) * <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>;
        dxlyn_info.is_initialized = <b>true</b>
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_owner"></a>

## Function `set_owner`

Set owner


<a id="@Arguments_2"></a>

### Arguments

* <code>owner</code> - Reference to the current owner's signer
* <code>new_owner</code> - Address of the new owner to be assigned


<pre><code><b>public</b> entry <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_owner">set_owner</a>(owner: &<a href="">signer</a>, new_owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_owner">set_owner</a>(owner: &<a href="">signer</a>, new_owner: <b>address</b>) <b>acquires</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
    <b>let</b> dxlyn_obj_addr = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>assert</b>!(<b>exists</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_obj_addr), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>);

    <b>let</b> dxlyn_info = <b>borrow_global_mut</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_obj_addr);
    <b>let</b> owner_addr = address_of(owner);
    <b>assert</b>!(dxlyn_info.owner == owner_addr, <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_emit">event::emit</a>(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SetOwnerEvent">SetOwnerEvent</a> {
        old_owner: owner_addr,
        new_owner
    });

    dxlyn_info.owner = new_owner;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period"></a>

## Function `active_period`

Get current active emission period


<a id="@Returns_3"></a>

### Returns

* <code>u64</code> - The current active period timestamp


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">active_period</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">active_period</a>(): u64 <b>acquires</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
    <b>let</b> dxlyn_addr = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>assert</b>!(<b>exists</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_addr), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>);
    <b>let</b> active_period = <b>borrow_global_mut</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_addr);
    active_period.period
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission"></a>

## Function `get_next_emission`

Get next week's projected emission amount


<a id="@Returns_4"></a>

### Returns

* <code>u64</code> - Projected emission amount for the next week (epoch offset = 1)


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission">get_next_emission</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission">get_next_emission</a>(): u64 {
    <b>let</b> dxlyn_coin_address = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission">emission::get_emission</a>(dxlyn_coin_address, 1) // For next week <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_previous_emission"></a>

## Function `get_previous_emission`

Get last recorded emission amount


<a id="@Returns_5"></a>

### Returns

* <code>u64</code> - Last recorded emission amount from the emission schedule


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_previous_emission">get_previous_emission</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_previous_emission">get_previous_emission</a>(): u64 {
    <b>let</b> dxlyn_coin_address = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>let</b> (_, _, _, _, _, _, _, last_emission) =
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_schedule">emission::get_emission_schedule</a>(dxlyn_coin_address);
    last_emission
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address"></a>

## Function `get_minter_object_address`

Create and get the minter object address


<a id="@Returns_6"></a>

### Returns

* <code><b>address</b></code> - The address of the <code><a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a></code> minter object


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_SC_ADMIN">SC_ADMIN</a>, <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_MINTER_OBJECT_ACCOUNT_SEED">MINTER_OBJECT_ACCOUNT_SEED</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_active_period"></a>

## Function `set_active_period`

Set active period


<a id="@Arguments_7"></a>

### Arguments

* <code>period</code> - The new active period (typically a timestamp aligned to weekly boundaries)


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_active_period">set_active_period</a>(period: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_set_active_period">set_active_period</a>(period: u64) <b>acquires</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
    <b>let</b> dxlyn_addr = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>assert</b>!(<b>exists</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_addr), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>);

    <b>let</b> active_period = <b>borrow_global_mut</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_addr);
    active_period.period = period;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_calculate_rebase_gauge"></a>

## Function `calculate_rebase_gauge`

Calculate the rebase and gauge

<a id="@Returns:_8"></a>

### Returns:

- (rebase: u64, gauge: u64, dxlyn_signer: signer)


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_calculate_rebase_gauge">calculate_rebase_gauge</a>(): (u64, u64, <a href="">signer</a>, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_calculate_rebase_gauge">calculate_rebase_gauge</a>(): (u64, u64, <a href="">signer</a>, bool) <b>acquires</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a> {
    <b>let</b> dxlyn_obj_addr = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_minter_object_address">get_minter_object_address</a>();
    <b>assert</b>!(<b>exists</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_obj_addr), <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_ERROR_DXLYN_INFO_NOT_FOUND">ERROR_DXLYN_INFO_NOT_FOUND</a>);

    <b>let</b> dxlyn_info = <b>borrow_global_mut</b>&lt;<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DxlynInfo">DxlynInfo</a>&gt;(dxlyn_obj_addr);
    <b>let</b> dxlyn_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&dxlyn_info.extend_ref);
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();

    <b>if</b> (current_time &gt;= dxlyn_info.period + <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a> && dxlyn_info.is_initialized) {
        dxlyn_info.period = (current_time / <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>) * <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_WEEK">WEEK</a>;

        <b>let</b> weekly_emission = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_weekly_emission">emission::weekly_emission</a>(dxlyn_obj_addr);

        <b>let</b> ve_supply = (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply">voting_escrow::total_supply</a>(<a href="_now_seconds">timestamp::now_seconds</a>()) <b>as</b> <a href="">u256</a>);
        <b>let</b> dxlyn_supply = (<a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_total_supply">dxlyn_coin::total_supply</a>() <b>as</b> <a href="">u256</a>);

        <b>let</b> rebase = <b>if</b> (ve_supply &lt;= 0 || dxlyn_supply &lt;= 0) {
            0
        }<b>else</b> {
            // Rebase = weeklyEmissions * (1 - (veDXLYN.totalSupply / DXLYN.totalSupply) )^2 * 0.5
            // (1 - veDXLYN/DXLYN), scaled by 10^4
            <b>let</b> diff_scaled = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_AMOUNT_SCALE">AMOUNT_SCALE</a> - (ve_supply / dxlyn_supply);

            // ( 10^4 * 10^4 * 10^4 -&gt; 10^12 / 10^4 -&gt; 10^8)
            <b>let</b> factor = ((diff_scaled * diff_scaled) * 5000) / <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_AMOUNT_SCALE">AMOUNT_SCALE</a>;

            // 10^8 * 10^8 -&gt; 10^16 / 10^8 -&gt; 10^8
            ((((weekly_emission <b>as</b> <a href="">u256</a>) * factor) / (<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>)) <b>as</b> u64)
        };

        <b>let</b> gauge = weekly_emission - rebase;

        // Mint weekly <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a> and rebase amount
        <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint">dxlyn_coin::mint</a>(&dxlyn_signer, dxlyn_obj_addr, weekly_emission);

        (rebase, gauge, dxlyn_signer, <b>true</b>)
    } <b>else</b> {
        (0, 0, dxlyn_signer, <b>false</b>)
    }
}
</code></pre>



</details>
