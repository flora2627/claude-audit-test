
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin`



-  [Struct `CommitOwnershipEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitOwnershipEvent)
-  [Struct `ApplyOwnershipEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyOwnershipEvent)
-  [Struct `CommitMinterEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitMinterEvent)
-  [Struct `ApplyMinterEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyMinterEvent)
-  [Struct `PauseEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_PauseEvent)
-  [Struct `UnPauseEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_UnPauseEvent)
-  [Resource `DxlynInfo`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DxlynInfo)
-  [Struct `DXLYN`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DXLYN)
-  [Resource `CoinCaps`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CoinCaps)
-  [Resource `InitialSupply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_InitialSupply)
-  [Constants](#@Constants_0)
-  [Function `commit_transfer_ownership`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_ownership)
    -  [Arguments](#@Arguments_1)
    -  [Dev](#@Dev_2)
-  [Function `apply_transfer_ownership`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_ownership)
    -  [Arguments](#@Arguments_3)
    -  [Dev](#@Dev_4)
-  [Function `commit_transfer_minter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_minter)
    -  [Arguments](#@Arguments_5)
    -  [Dev](#@Dev_6)
-  [Function `apply_transfer_minter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_minter)
    -  [Arguments](#@Arguments_7)
    -  [Dev](#@Dev_8)
-  [Function `pause`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_pause)
    -  [Arguments](#@Arguments_9)
    -  [Dev](#@Dev_10)
-  [Function `unpause`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unpause)
    -  [Arguments](#@Arguments_11)
    -  [Dev](#@Dev_12)
-  [Function `mint`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint)
    -  [Arguments](#@Arguments_13)
-  [Function `mint_to_community`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint_to_community)
    -  [Arguments](#@Arguments_14)
-  [Function `transfer`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_transfer)
    -  [Arguments](#@Arguments_15)
-  [Function `burn_from`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_burn_from)
    -  [Arguments](#@Arguments_16)
-  [Function `freeze_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_freeze_token)
    -  [Arguments](#@Arguments_17)
-  [Function `unfreeze_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unfreeze_token)
    -  [Arguments](#@Arguments_18)
-  [Function `balance_of`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_balance_of)
    -  [Arguments](#@Arguments_19)
    -  [Returns](#@Returns_20)
-  [Function `total_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_total_supply)
    -  [Returns](#@Returns_21)
-  [Function `get_dxlyn_asset_metadata`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata)
    -  [Returns](#@Returns_22)
-  [Function `get_dxlyn_asset_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_address)
    -  [Returns](#@Returns_23)
-  [Function `get_dxlyn_object_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_object_address)
    -  [Returns](#@Returns_24)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::supra_account</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitOwnershipEvent"></a>

## Struct `CommitOwnershipEvent`

Represents the commitment to transfer ownership of the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitOwnershipEvent">CommitOwnershipEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyOwnershipEvent"></a>

## Struct `ApplyOwnershipEvent`

Represents the application of ownership transfer in the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyOwnershipEvent">ApplyOwnershipEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitMinterEvent"></a>

## Struct `CommitMinterEvent`

Represents the commitment to transfer minter of the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CommitMinterEvent">CommitMinterEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyMinterEvent"></a>

## Struct `ApplyMinterEvent`

Represents the application of minter transfer in the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ApplyMinterEvent">ApplyMinterEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_PauseEvent"></a>

## Struct `PauseEvent`

Pauses the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_PauseEvent">PauseEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_UnPauseEvent"></a>

## Struct `UnPauseEvent`

Unpauses the DXLYN contract


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_UnPauseEvent">UnPauseEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DxlynInfo"></a>

## Resource `DxlynInfo`

DxlynInfo holds the information about the dxlyn token


<pre><code><b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DxlynInfo">DxlynInfo</a> <b>has</b> key
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DXLYN"></a>

## Struct `DXLYN`

DXLYN legacy coin


<pre><code><b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DXLYN">DXLYN</a>
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CoinCaps"></a>

## Resource `CoinCaps`

Store legacy coin capabilities


<pre><code><b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_CoinCaps">CoinCaps</a> <b>has</b> key
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_InitialSupply"></a>

## Resource `InitialSupply`

Token Generation Event


<pre><code><b>struct</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_InitialSupply">InitialSupply</a> <b>has</b> key
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DXLYN_OBJECT_ACCOUNT_SEED"></a>

The seed used to create the DXLYN object account


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_DXLYN_OBJECT_ACCOUNT_SEED">DXLYN_OBJECT_ACCOUNT_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [68, 88, 76, 89, 78];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_ALREADY_PAUSED"></a>

Try to pause the contract when it is already paused


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_ALREADY_PAUSED">ERROR_ALREADY_PAUSED</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_FUTURE_MINTER_NOT_SET"></a>

Apply transfer minter without setting future minter


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_FUTURE_MINTER_NOT_SET">ERROR_FUTURE_MINTER_NOT_SET</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_FUTURE_OWNER_NOT_SET"></a>

Apply transfer ownership without setting future owner


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_FUTURE_OWNER_NOT_SET">ERROR_FUTURE_OWNER_NOT_SET</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_INSUFFICIENT_BALANCE"></a>

User has insufficient DXLYN balance


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_NOT_OWNER"></a>

Caller is not the owner of the dxlyn system


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_NOT_PAUSED"></a>

Try to unpause the contract when it is not paused


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_NOT_PAUSED">ERROR_NOT_PAUSED</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_PAUSED"></a>

Try to mint when the contract is paused


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_ERROR_PAUSED">ERROR_PAUSED</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_INITIAL_SUPPLY"></a>

DXLYN Initial supply


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_INITIAL_SUPPLY">INITIAL_SUPPLY</a>: u64 = 10000000000000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_SC_ADMIN"></a>

Creator address of the DXLYN object account


<pre><code><b>const</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_ownership"></a>

## Function `commit_transfer_ownership`

Commit transfer ownership of dxlyn token


<a id="@Arguments_1"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.
* <code>future_owner</code>: The address of the future owner to whom ownership will be transferred.


<a id="@Dev_2"></a>

### Dev

* This function can only be called by the current owner of the dxlyn token.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_ownership">commit_transfer_ownership</a>(owner: &<a href="">signer</a>, future_owner: <b>address</b>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_ownership"></a>

## Function `apply_transfer_ownership`

Apply transfer ownership of dxlyn token


<a id="@Arguments_3"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.


<a id="@Dev_4"></a>

### Dev

* This function can only be called after <code>commit_transfer_ownership</code> has been called


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_ownership">apply_transfer_ownership</a>(owner: &<a href="">signer</a>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_minter"></a>

## Function `commit_transfer_minter`

Commit transfer minter of dxlyn token


<a id="@Arguments_5"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.
* <code>future_minter</code>: The address of the future minter to whom minting rights will be transferred.


<a id="@Dev_6"></a>

### Dev

* This function can only be called by the current owner of the dxlyn token.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_commit_transfer_minter">commit_transfer_minter</a>(owner: &<a href="">signer</a>, future_minter: <b>address</b>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_minter"></a>

## Function `apply_transfer_minter`

Apply transfer minter of dxlyn token


<a id="@Arguments_7"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.


<a id="@Dev_8"></a>

### Dev

* This function can only be called after <code>commit_transfer_minter</code> has been called


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_apply_transfer_minter">apply_transfer_minter</a>(owner: &<a href="">signer</a>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_pause"></a>

## Function `pause`

Pause dxlyn token


<a id="@Arguments_9"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.


<a id="@Dev_10"></a>

### Dev

* This function can only be called by the current owner of the dxlyn token.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_pause">pause</a>(owner: &<a href="">signer</a>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unpause"></a>

## Function `unpause`

Unpause dxlyn token


<a id="@Arguments_11"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner of the dxlyn token.


<a id="@Dev_12"></a>

### Dev

* This function can only be called by the current owner of the dxlyn token.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unpause">unpause</a>(owner: &<a href="">signer</a>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint"></a>

## Function `mint`

Mint dxlyn token


<a id="@Arguments_13"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner or minter of the dxlyn token.
* <code><b>to</b></code>: The address to which the minted tokens will be sent.
* <code>amount</code>: The amount of dxlyn tokens to mint.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint">mint</a>(owner: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint_to_community"></a>

## Function `mint_to_community`

Mint dxlyn token for community


<a id="@Arguments_14"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, representing the current owner or minter of the dxlyn token.
* <code><b>to</b></code>: The address to which the minted tokens will be sent.
* <code>amount</code>: The amount of dxlyn tokens to mint.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_mint_to_community">mint_to_community</a>(owner: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_transfer"></a>

## Function `transfer`

Transfer dxlyn token


<a id="@Arguments_15"></a>

### Arguments

* <code><a href="">account</a></code>: The signer of the transaction, representing the account from which the tokens will be transferred.
* <code><b>to</b></code>: The address to which the tokens will be transferred.
* <code>amount</code>: The amount of dxlyn tokens to transfer.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_transfer">transfer</a>(<a href="">account</a>: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_burn_from"></a>

## Function `burn_from`

Burn dxlyn token from


<a id="@Arguments_16"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, the owner of the system.
* <code>from</code>: The address from which the tokens will be burned.
* <code>amount</code>: The amount of dxlyn tokens to burn.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_burn_from">burn_from</a>(owner: &<a href="">signer</a>, from: <b>address</b>, amount: u64)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_freeze_token"></a>

## Function `freeze_token`

Freeze dxlyn token to user account


<a id="@Arguments_17"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, the owner of the system.
* <code>user</code>: The address to which the tokens will be freezed.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_freeze_token">freeze_token</a>(owner: &<a href="">signer</a>, user: <b>address</b>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unfreeze_token"></a>

## Function `unfreeze_token`

Unfreeze dxlyn token from user account


<a id="@Arguments_18"></a>

### Arguments

* <code>owner</code>: The signer of the transaction, the owner of the system.
* <code>user</code>: The address to which the tokens will be transferred.


<pre><code><b>public</b> entry <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_unfreeze_token">unfreeze_token</a>(owner: &<a href="">signer</a>, user: <b>address</b>)
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_balance_of"></a>

## Function `balance_of`

Get the dxlyn coin balance of a user


<a id="@Arguments_19"></a>

### Arguments

* <code>user_addr</code>: The address of the user whose dxlyn balance is to be retrieved.


<a id="@Returns_20"></a>

### Returns

* The balance of dxlyn tokens held by the user.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_balance_of">balance_of</a>(user_addr: <b>address</b>): u64
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_total_supply"></a>

## Function `total_supply`

Get the dxlyn coin supply


<a id="@Returns_21"></a>

### Returns

* The total supply of dxlyn tokens.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_total_supply">total_supply</a>(): u128
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata"></a>

## Function `get_dxlyn_asset_metadata`

Get dxlyn asset metadata


<a id="@Returns_22"></a>

### Returns

* The metadata of the dxlyn asset.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">get_dxlyn_asset_metadata</a>(): <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_address"></a>

## Function `get_dxlyn_asset_address`

Get dxlyn asset address


<a id="@Returns_23"></a>

### Returns

* The address of the dxlyn asset.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_address">get_dxlyn_asset_address</a>(): <b>address</b>
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_object_address"></a>

## Function `get_dxlyn_object_address`

Get dxlyn object address


<a id="@Returns_24"></a>

### Returns

* The address of the dxlyn object.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_object_address">get_dxlyn_object_address</a>(): <b>address</b>
</code></pre>
