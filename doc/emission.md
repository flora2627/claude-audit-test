
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::emission`



-  [Struct `EmissionEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionEvent)
-  [Struct `EmissionPausedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionPausedEvent)
-  [Struct `EmissionRecord`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord)
-  [Resource `EmissionSchedule`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule)
-  [Constants](#@Constants_0)
-  [Function `set_emission_pause`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_set_emission_pause)
    -  [Arguments](#@Arguments_1)
-  [Function `get_emission_schedule`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_schedule)
    -  [Arguments](#@Arguments_2)
-  [Function `get_emission_record`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_record)
    -  [Arguments](#@Arguments_3)
-  [Function `get_emission_epoch_count`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_epoch_count)
    -  [Arguments](#@Arguments_4)
-  [Function `get_pending_emissions`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_pending_emissions)
    -  [Arguments](#@Arguments_5)
-  [Function `initialized_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_initialized_emission)
    -  [Arguments](#@Arguments_6)
-  [Function `calculate_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission)
    -  [Arguments](#@Arguments_7)
-  [Function `weekly_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_weekly_emission)
    -  [Arguments](#@Arguments_8)
-  [Function `get_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission)
    -  [Arguments](#@Arguments_9)
-  [Function `calculate_with_overflow_check`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check)
    -  [Arguments](#@Arguments_10)
-  [Function `assert_zero_init_supply`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_zero_init_supply)
    -  [Arguments](#@Arguments_11)
-  [Function `assert_rate_bps`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps)
    -  [Arguments](#@Arguments_12)
-  [Function `assert_decay_start_epoch`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_decay_start_epoch)
    -  [Arguments](#@Arguments_13)
-  [Function `assert_emission_schedule_exists`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists)
    -  [Arguments](#@Arguments_14)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionEvent"></a>

## Struct `EmissionEvent`

EmissionEvent is emitted when emissions are calculated for an epoch


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionEvent">EmissionEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>emission_amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>total_emitted: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>emission_rate: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionPausedEvent"></a>

## Struct `EmissionPausedEvent`

EmissionPausedEvent is emitted when emissions are paused or unpaused


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionPausedEvent">EmissionPausedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>paused: bool</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord"></a>

## Struct `EmissionRecord`

Emission record for a specific epoch


<pre><code><b>struct</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord">EmissionRecord</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>emission_amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>emission_rate: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule"></a>

## Resource `EmissionSchedule`

Main emission schedule configuration


<pre><code><b>struct</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>initial_supply: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>initial_rate_bps: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>decay_rate_bps: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>decay_start_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>total_emitted: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>emissions_by_epoch: <a href="_Table">table::Table</a>&lt;u64, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord">emission::EmissionRecord</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_counter: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>created_at: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>last_emission: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>is_paused: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_BPS_DENOMINATOR"></a>

Basis points denominator


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_BPS_DENOMINATOR">BPS_DENOMINATOR</a>: u64 = 100;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_SC_ADMIN"></a>

Creator address of the emission object account


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_NOT_ADMIN"></a>

Calller must be the admin to perform this action


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH"></a>

604800 (Week in seconds)


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_DECAY_START_TOO_EARLY"></a>

Decay must start at 1 or later epoch


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_DECAY_START_TOO_EARLY">ERROR_DECAY_START_TOO_EARLY</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_ALREADY_EXIST"></a>

Emission schedule already setuped


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_ALREADY_EXIST">ERROR_EMISSION_SCHEDULE_ALREADY_EXIST</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_NOT_EXIST"></a>

Emission schedule must be initialized first


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_NOT_EXIST">ERROR_EMISSION_SCHEDULE_NOT_EXIST</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_INVALID_RATE"></a>

Rate basis point is invalid ( it must be > 0 and < 10000 )


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_INVALID_RATE">ERROR_INVALID_RATE</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_ZERO_INITIAL_SUPPLY"></a>

Initial supply must be greater than zero


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_ZERO_INITIAL_SUPPLY">ERROR_ZERO_INITIAL_SUPPLY</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_MINTER_OBJECT_ACCOUNT_SEED"></a>

This should be always same as the minter MINTER_OBJECT_ACCOUNT_SEED


<pre><code><b>const</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_MINTER_OBJECT_ACCOUNT_SEED">MINTER_OBJECT_ACCOUNT_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [77, 73, 78, 84, 69, 82];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_set_emission_pause"></a>

## Function `set_emission_pause`

Pause or unpause emissions (admin only)


<a id="@Arguments_1"></a>

### Arguments

* <code>admin</code> - The current admin signer.
* <code>paused</code> - True to pause emissions, false to unpause


<pre><code><b>public</b> entry <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_set_emission_pause">set_emission_pause</a>(admin: &<a href="">signer</a>, paused: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_set_emission_pause">set_emission_pause</a>(admin: &<a href="">signer</a>, paused: bool) <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <b>let</b> addr = <a href="_create_object_address">object::create_object_address</a>(&<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_SC_ADMIN">SC_ADMIN</a>, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_MINTER_OBJECT_ACCOUNT_SEED">MINTER_OBJECT_ACCOUNT_SEED</a>);

    <b>let</b> schedule = <b>borrow_global_mut</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);

    <b>assert</b>!(address_of(admin) == schedule.admin, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>);

    schedule.is_paused = paused;

    <a href="_emit">event::emit</a>(<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionPausedEvent">EmissionPausedEvent</a> { paused, <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>() });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_schedule"></a>

## Function `get_emission_schedule`

Get comprehensive emission schedule details


<a id="@Arguments_2"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_schedule">get_emission_schedule</a>(addr: <b>address</b>): (u64, u64, u64, u64, u64, u64, bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_schedule">get_emission_schedule</a>(
    addr: <b>address</b>
): (u64, u64, u64, u64, u64, u64, bool, u64) <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <b>let</b> schedule = <b>borrow_global</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);
    (
        schedule.initial_supply,
        schedule.initial_rate_bps,
        schedule.decay_rate_bps,
        schedule.decay_start_epoch,
        schedule.total_emitted,
        schedule.epoch_counter,
        schedule.is_paused,
        schedule.last_emission,
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_record"></a>

## Function `get_emission_record`

Get emission record for specific epoch


<a id="@Arguments_3"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule
* <code>epoch</code> - Epoch number


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_record">get_emission_record</a>(addr: <b>address</b>, epoch: u64): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_record">get_emission_record</a>(addr: <b>address</b>, epoch: u64): (u64, u64, u64) <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <b>let</b> schedule = <b>borrow_global</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);
    <b>if</b> (<a href="_contains">table::contains</a>(&schedule.emissions_by_epoch, epoch)) {
        <b>let</b> record = <a href="_borrow">table::borrow</a>(&schedule.emissions_by_epoch, epoch);
        (record.emission_amount, record.emission_rate, record.<a href="">timestamp</a>)
    } <b>else</b> {
        (0, 0, 0)
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_epoch_count"></a>

## Function `get_emission_epoch_count`

Get number of epochs passed since emission started


<a id="@Arguments_4"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_epoch_count">get_emission_epoch_count</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission_epoch_count">get_emission_epoch_count</a>(addr: <b>address</b>): u64 <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <b>let</b> schedule = <b>borrow_global</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);
    (<a href="_now_seconds">timestamp::now_seconds</a>() - schedule.created_at) / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_pending_emissions"></a>

## Function `get_pending_emissions`

Get total emissions that should be released up to current time


<a id="@Arguments_5"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_pending_emissions">get_pending_emissions</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_pending_emissions">get_pending_emissions</a>(addr: <b>address</b>): u64 <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <b>let</b> schedule = <b>borrow_global</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);
    <b>let</b> current_epoch_offset = (<a href="_now_seconds">timestamp::now_seconds</a>() - schedule.created_at) / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>;

    <b>if</b> (current_epoch_offset &lt;= schedule.epoch_counter) { 0 }
    <b>else</b> {
        current_epoch_offset - schedule.epoch_counter
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_initialized_emission"></a>

## Function `initialized_emission`

Initialize emission schedule with parameter validation


<a id="@Arguments_6"></a>

### Arguments

* <code>dxlyn_obj_signer</code> - Signer of the emission object account
* <code>admin</code> - Admin address of the emission schedule
* <code>initial_supply</code> - Initial supply of the emission schedule
* <code>initial_rate_bps</code> - Initial emission rate in basis points
* <code>decay_rate_bps</code> - Decay rate in basis points
* <code>decay_start_epoch</code> - Epoch at which decay starts


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_initialized_emission">initialized_emission</a>(dxlyn_obj_signer: &<a href="">signer</a>, admin: <b>address</b>, initial_supply: u64, initial_rate_bps: u64, decay_rate_bps: u64, decay_start_epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_initialized_emission">initialized_emission</a>(
    dxlyn_obj_signer: &<a href="">signer</a>,
    admin: <b>address</b>,
    initial_supply: u64,
    initial_rate_bps: u64,
    decay_rate_bps: u64,
    decay_start_epoch: u64
) {
    // Parameter validation
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_zero_init_supply">assert_zero_init_supply</a>(initial_supply);
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps">assert_rate_bps</a>(initial_rate_bps);
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps">assert_rate_bps</a>(decay_rate_bps);
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_decay_start_epoch">assert_decay_start_epoch</a>(decay_start_epoch);

    <b>assert</b>!(
        !<b>exists</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(address_of(dxlyn_obj_signer)),
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_ALREADY_EXIST">ERROR_EMISSION_SCHEDULE_ALREADY_EXIST</a>
    );

    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();
    // adjust time <b>to</b> current epoch
    <b>let</b> current_epoch = current_time / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a> * <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>;

    <b>move_to</b>(
        dxlyn_obj_signer,
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
            initial_supply,
            initial_rate_bps,
            decay_rate_bps,
            decay_start_epoch,
            total_emitted: 0,
            epoch_counter: 0,
            emissions_by_epoch: <a href="_new">table::new</a>&lt;u64, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord">EmissionRecord</a>&gt;(),
            created_at: current_epoch,
            last_emission: 0,
            is_paused: <b>false</b>,
            admin
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission"></a>

## Function `calculate_emission`

Optimized emission calculation with overflow protection


<a id="@Arguments_7"></a>

### Arguments

* <code>last_emission</code> - Last emission amount
* <code>initial_supply</code> - Initial supply of the emission schedule
* <code>initial_rate_bps</code> - Initial emission rate in basis points
* <code>decay_rate_bps</code> - Decay rate in basis points
* <code>decay_start_epoch</code> - Epoch at which decay starts
* <code>current_epoch</code> - Current epoch


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission">calculate_emission</a>(last_emission: u64, initial_supply: u64, initial_rate_bps: u64, decay_rate_bps: u64, decay_start_epoch: u64, current_epoch: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission">calculate_emission</a>(
    last_emission: u64,
    initial_supply: u64,
    initial_rate_bps: u64,
    decay_rate_bps: u64,
    decay_start_epoch: u64,
    current_epoch: u64
): u64 {
    <b>let</b> bps_denominator = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_BPS_DENOMINATOR">BPS_DENOMINATOR</a>;
    <b>if</b> (last_emission == 0) {
        // First <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>: initial_supply * rate / 10000
        <b>let</b> (result, _) = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(initial_supply, initial_rate_bps);
        result / bps_denominator
    } <b>else</b> <b>if</b> (current_epoch &gt;= decay_start_epoch) {
        // Decay phase: last_emission * (10000 - decay_rate) / 10000
        <b>let</b> decay_multiplier = bps_denominator - decay_rate_bps;

        <b>let</b> (result, _) = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(last_emission, decay_multiplier);
        result / bps_denominator
    } <b>else</b> {
        // Growth phase: last_emission * (1 + rate)
        <b>let</b> growth_multiplier = bps_denominator + initial_rate_bps;
        <b>let</b> (result, _) = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(last_emission, growth_multiplier);
        result / bps_denominator
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_weekly_emission"></a>

## Function `weekly_emission`

Calculate the current week emission


<a id="@Arguments_8"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_weekly_emission">weekly_emission</a>(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_weekly_emission">weekly_emission</a>(addr: <b>address</b>): u64 <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists">assert_emission_schedule_exists</a>(&addr);

    <b>let</b> schedule = <b>borrow_global_mut</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);
    <b>let</b> _calculated_emission = 0;
    <b>let</b> current_time = <a href="_now_seconds">timestamp::now_seconds</a>();

    // First <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>
    <b>if</b> (schedule.last_emission == 0) {
        <b>let</b> (result, _) = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(schedule.initial_supply, schedule.initial_rate_bps);

        _calculated_emission = result / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_BPS_DENOMINATOR">BPS_DENOMINATOR</a>;

        schedule.last_emission = _calculated_emission;
    } <b>else</b> {
        <b>let</b> current_epoch = (current_time - schedule.created_at) / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>;

        <b>let</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a> = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission">calculate_emission</a>(
            schedule.last_emission,
            schedule.initial_supply,
            schedule.initial_rate_bps,
            schedule.decay_rate_bps,
            schedule.decay_start_epoch,
            current_epoch
        );
        schedule.total_emitted = schedule.total_emitted + <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>;
        schedule.last_emission = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>;
        _calculated_emission = <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a>;
    };

    // Store <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a> record <b>with</b> <a href="">timestamp</a>
    schedule.total_emitted = schedule.total_emitted + _calculated_emission;
    schedule.epoch_counter = schedule.epoch_counter + 1;

    <b>let</b> emission_rate =
        <b>if</b> (schedule.epoch_counter &gt;= schedule.decay_start_epoch) {
            schedule.decay_rate_bps
        } <b>else</b> {
            schedule.initial_rate_bps
        };

    // Store <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a> record <b>with</b> <a href="">timestamp</a>
    <a href="_upsert">table::upsert</a>(
        &<b>mut</b> schedule.emissions_by_epoch,
        schedule.epoch_counter,
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionRecord">EmissionRecord</a> {
            emission_amount: _calculated_emission,
            emission_rate,
            <a href="">timestamp</a>: current_time
        }
    );

    // Emit <a href="">event</a> for each epoch
    <a href="_emit">event::emit</a>(
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionEvent">EmissionEvent</a> {
            epoch: schedule.epoch_counter,
            emission_amount: _calculated_emission,
            total_emitted: schedule.total_emitted,
            emission_rate,
            <a href="">timestamp</a>: current_time
        }
    );

    _calculated_emission
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission"></a>

## Function `get_emission`

Calculate <code>count</code> + <code><a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a></code> emission


<a id="@Arguments_9"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule
* <code>count</code> - Number of epochs


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission">get_emission</a>(addr: <b>address</b>, count: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_get_emission">get_emission</a>(addr: <b>address</b>, count: u64): u64 <b>acquires</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a> {
    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists">assert_emission_schedule_exists</a>(&addr);

    <b>let</b> schedule = <b>borrow_global</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(addr);

    <b>let</b> current_epoch = ((<a href="_now_seconds">timestamp::now_seconds</a>() - schedule.created_at) / <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EPOCH">EPOCH</a>) + count;

    <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_emission">calculate_emission</a>(
        schedule.last_emission,
        schedule.initial_supply,
        schedule.initial_rate_bps,
        schedule.decay_rate_bps,
        schedule.decay_start_epoch,
        current_epoch
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check"></a>

## Function `calculate_with_overflow_check`

Helper function to check for overflow in multiplication


<a id="@Arguments_10"></a>

### Arguments

* <code>a</code> - First operand
* <code>b</code> - Second operand


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(a: u64, b: u64): (u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_calculate_with_overflow_check">calculate_with_overflow_check</a>(a: u64, b: u64): (u64, bool) {
    <b>let</b> max_u64 = 18446744073709551615u64;
    <b>if</b> (a == 0 || b == 0) {
        <b>return</b> (0, <b>false</b>)
    };

    <b>if</b> (a &gt; max_u64 / b) {
        // Overflow would occur
        (max_u64, <b>true</b>)
    } <b>else</b> {
        (a * b, <b>false</b>)
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_zero_init_supply"></a>

## Function `assert_zero_init_supply`

Assert that initial supply is not zero


<a id="@Arguments_11"></a>

### Arguments

* <code>initial_supply</code> - Initial supply


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_zero_init_supply">assert_zero_init_supply</a>(initial_supply: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_zero_init_supply">assert_zero_init_supply</a>(initial_supply: u64) {
    <b>assert</b>!(initial_supply &gt; 0, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_ZERO_INITIAL_SUPPLY">ERROR_ZERO_INITIAL_SUPPLY</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps"></a>

## Function `assert_rate_bps`

Assert that rate bps is valid


<a id="@Arguments_12"></a>

### Arguments

* <code>rate_bps</code> - Rate bps


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps">assert_rate_bps</a>(rate_bps: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_rate_bps">assert_rate_bps</a>(rate_bps: u64) {
    <b>assert</b>!(
        rate_bps &gt; 0 && rate_bps &lt; <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_BPS_DENOMINATOR">BPS_DENOMINATOR</a>,
        <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_INVALID_RATE">ERROR_INVALID_RATE</a>
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_decay_start_epoch"></a>

## Function `assert_decay_start_epoch`

Assert that decay starts with valid epoch


<a id="@Arguments_13"></a>

### Arguments

* <code>decay_start_epoch</code> - Decay start epoch


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_decay_start_epoch">assert_decay_start_epoch</a>(decay_start_epoch: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_decay_start_epoch">assert_decay_start_epoch</a>(decay_start_epoch: u64) {
    <b>assert</b>!(decay_start_epoch &gt;= 1, <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_DECAY_START_TOO_EARLY">ERROR_DECAY_START_TOO_EARLY</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists"></a>

## Function `assert_emission_schedule_exists`

Assert that emission schedule is exists


<a id="@Arguments_14"></a>

### Arguments

* <code>addr</code> - Address of the emission schedule


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists">assert_emission_schedule_exists</a>(addr: &<b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_assert_emission_schedule_exists">assert_emission_schedule_exists</a>(addr: &<b>address</b>) {
    <b>assert</b>!(<b>exists</b>&lt;<a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_EmissionSchedule">EmissionSchedule</a>&gt;(*addr), <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission_ERROR_EMISSION_SCHEDULE_NOT_EXIST">ERROR_EMISSION_SCHEDULE_NOT_EXIST</a>);
}
</code></pre>



</details>
