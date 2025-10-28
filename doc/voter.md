
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::voter`



-  [Struct `SetVoteDelayEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetVoteDelayEvent)
-  [Struct `EditVotePenaltyEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_EditVotePenaltyEvent)
-  [Struct `SetMinterEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetMinterEvent)
-  [Struct `SetExternalBribeForEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetExternalBribeForEvent)
-  [Struct `WhitelistedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent)
-  [Struct `BlacklistedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_BlacklistedEvent)
-  [Struct `GaugeKilledEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeKilledEvent)
-  [Struct `AbstainedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AbstainedEvent)
-  [Struct `VotedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VotedEvent)
-  [Struct `NotifyRewardEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_NotifyRewardEvent)
-  [Struct `DistributeRewardEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DistributeRewardEvent)
-  [Struct `GaugeCreatedEvent`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeCreatedEvent)
-  [Resource `Voter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_init_module)
-  [Function `set_voter_delay`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_voter_delay)
    -  [Arguments](#@Arguments_1)
    -  [Dev](#@Dev_2)
-  [Function `set_edit_vote_penalty`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_edit_vote_penalty)
    -  [Arguments](#@Arguments_3)
    -  [Dev Notes](#@Dev_Notes_4)
-  [Function `set_minter`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_minter)
    -  [Arguments](#@Arguments_5)
    -  [Dev](#@Dev_6)
-  [Function `set_external_bribe_for_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_external_bribe_for_gauge)
    -  [Arguments](#@Arguments_7)
    -  [Dev](#@Dev_8)
-  [Function `whitelist_perp_pool`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_perp_pool)
    -  [Arguments](#@Arguments_9)
    -  [Dev](#@Dev_10)
-  [Function `whitelist_cpmm_pool`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_cpmm_pool)
    -  [Arguments](#@Arguments_11)
    -  [Dev](#@Dev_12)
-  [Function `whitelist_clmm_pool`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_clmm_pool)
    -  [Arguments](#@Arguments_13)
    -  [Dev](#@Dev_14)
-  [Function `blacklist`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_blacklist)
    -  [Arguments](#@Arguments_15)
    -  [Dev](#@Dev_16)
-  [Function `kill_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_kill_gauge)
    -  [Arguments](#@Arguments_17)
    -  [Dev](#@Dev_18)
-  [Function `revive_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_revive_gauge)
    -  [Arguments](#@Arguments_19)
    -  [Dev](#@Dev_20)
-  [Function `reset`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset)
    -  [Arguments](#@Arguments_21)
    -  [Dev](#@Dev_22)
-  [Function `update_period`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period)
-  [Function `poke`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_poke)
    -  [Arguments](#@Arguments_23)
    -  [Dev](#@Dev_24)
-  [Function `vote`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote)
    -  [Arguments](#@Arguments_25)
    -  [Dev](#@Dev_26)
-  [Function `claim_emission`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_emission)
    -  [Arguments](#@Arguments_27)
-  [Function `claim_bribes`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes)
    -  [Arguments](#@Arguments_28)
    -  [Dev](#@Dev_29)
-  [Function `claim_bribe_for_token`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribe_for_token)
    -  [Arguments](#@Arguments_30)
    -  [Dev](#@Dev_31)
-  [Function `claim_bribes_for_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes_for_address)
    -  [Arguments](#@Arguments_32)
    -  [Dev](#@Dev_33)
-  [Function `create_gauges`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauges)
    -  [Arguments](#@Arguments_34)
    -  [Dev](#@Dev_35)
-  [Function `create_gauge`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge)
    -  [Arguments](#@Arguments_36)
    -  [Dev](#@Dev_37)
-  [Function `notify_reward_amount`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_notify_reward_amount)
    -  [Arguments](#@Arguments_38)
    -  [Dev](#@Dev_39)
-  [Function `distribute_all`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_all)
    -  [Arguments](#@Arguments_40)
-  [Function `distribute_range`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_range)
    -  [Arguments](#@Arguments_41)
    -  [Dev](#@Dev_42)
-  [Function `distribute_gauges`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_gauges)
    -  [Arguments](#@Arguments_43)
    -  [Dev](#@Dev_44)
-  [Function `get_edit_vote_penalty`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_edit_vote_penalty)
    -  [Returns](#@Returns_45)
-  [Function `get_voter_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address)
-  [Function `get_external_bribe_address`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_external_bribe_address)
    -  [Arguments](#@Arguments_46)
    -  [Returns](#@Returns_47)
-  [Function `length`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_length)
    -  [Returns](#@Returns_48)
-  [Function `pool_vote_length`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_pool_vote_length)
    -  [Arguments](#@Arguments_49)
    -  [Returns](#@Returns_50)
-  [Function `weights`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights)
    -  [Arguments](#@Arguments_51)
    -  [Returns](#@Returns_52)
-  [Function `weights_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_at)
    -  [Arguments](#@Arguments_53)
    -  [Returns](#@Returns_54)
-  [Function `total_weight`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight)
    -  [Returns](#@Returns_55)
-  [Function `total_weight_at`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight_at)
    -  [Arguments](#@Arguments_56)
    -  [Returns](#@Returns_57)
-  [Function `epoch_timestamp`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp)
    -  [Returns](#@Returns_58)
-  [Function `earned_all_gauges`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_earned_all_gauges)
    -  [Arguments](#@Arguments_59)
    -  [Returns](#@Returns_60)
-  [Function `total_claimable_rewards`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_claimable_rewards)
    -  [Arguments](#@Arguments_61)
    -  [Returns](#@Returns_62)
-  [Function `estimated_emission_reward_for_pools`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_emission_reward_for_pools)
    -  [Arguments](#@Arguments_63)
    -  [Returns](#@Returns_64)
-  [Function `estimated_rebase`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase)
    -  [Returns](#@Returns_65)
-  [Function `estimated_rebase_for_tokens`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase_for_tokens)
    -  [Arguments](#@Arguments_66)
    -  [Returns](#@Returns_67)
-  [Function `weights_per_epoch_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal)
-  [Function `reset_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal)
    -  [Arguments](#@Arguments_68)
-  [Function `create_gauge_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal)
-  [Function `distribute_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal)
    -  [Arguments](#@Arguments_69)
    -  [Dev](#@Dev_70)
-  [Function `vote_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal)
    -  [Arguments](#@Arguments_71)
-  [Function `update_for_after_distribution`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_for_after_distribution)
    -  [Arguments](#@Arguments_72)
    -  [Dev](#@Dev_73)
-  [Function `get_vote_internal`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal)


<pre><code><b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::smart_vector</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4496a672452b0bf5eff5e1616ebfaf7695e14b02a12ed211dd4f28ac38a5d54c::liquidity_pool</a>;
<b>use</b> <a href="">0x9f1feff9a32d2017ae47ed122d2c6b0ff8cd3143f12ec9211344261e0bcb6cfb::pool</a>;
<b>use</b> <a href="">0xe20ad8ef9e1359af9660da6cc73f5ac092cc2d4e5a5f81101c07e938f33c7893::house_lp</a>;
<b>use</b> <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::bribe</a>;
<b>use</b> <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::dxlyn_coin</a>;
<b>use</b> <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::fee_distributor</a>;
<b>use</b> <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::gauge_clmm</a>;
<b>use</b> <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::gauge_cpmm</a>;
<b>use</b> <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::gauge_perp</a>;
<b>use</b> <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::minter</a>;
<b>use</b> <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow">0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::voting_escrow</a>;
<b>use</b> <a href="">0xf4c4a507aa6ff75e680ebf8a7f65aeb265751a40dcf60bb0275aa0af7338a46e::lp_coin</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetVoteDelayEvent"></a>

## Struct `SetVoteDelayEvent`

Sets the voter delay for voting


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetVoteDelayEvent">SetVoteDelayEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_delay: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>latest_delay: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_EditVotePenaltyEvent"></a>

## Struct `EditVotePenaltyEvent`

Sets the same epoch vote penalty


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_EditVotePenaltyEvent">EditVotePenaltyEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_penalty: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>new_penalty: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetMinterEvent"></a>

## Struct `SetMinterEvent`

Sets the minter


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetMinterEvent">SetMinterEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_minter: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>latest_minter: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetExternalBribeForEvent"></a>

## Struct `SetExternalBribeForEvent`

Sets the external bribe for a gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetExternalBribeForEvent">SetExternalBribeForEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>old_bribe: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>latest_bribe: <b>address</b></code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent"></a>

## Struct `WhitelistedEvent`

Whitelists a pool for gauge creation


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent">WhitelistedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>whitelister: <b>address</b></code>
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
<code>gauge_type: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>asset: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_BlacklistedEvent"></a>

## Struct `BlacklistedEvent`

Blacklists a pool


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_BlacklistedEvent">BlacklistedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>blacklister: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeKilledEvent"></a>

## Struct `GaugeKilledEvent`

Kills a gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeKilledEvent">GaugeKilledEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AbstainedEvent"></a>

## Struct `AbstainedEvent`

Token abstained from voting


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AbstainedEvent">AbstainedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
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
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>weight: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VotedEvent"></a>

## Struct `VotedEvent`

Token voted for a pool


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VotedEvent">VotedEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
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
<code>user: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">token</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>weight: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">timestamp</a>: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_NotifyRewardEvent"></a>

## Struct `NotifyRewardEvent`

Notify rewards to the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_NotifyRewardEvent">NotifyRewardEvent</a> <b>has</b> drop, store
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
<code>reward: <b>address</b></code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DistributeRewardEvent"></a>

## Struct `DistributeRewardEvent`

Distribute rewards to the gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DistributeRewardEvent">DistributeRewardEvent</a> <b>has</b> drop, store
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
<code>gauge: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ecpoh: u64</code>
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

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeCreatedEvent"></a>

## Struct `GaugeCreatedEvent`

Create a gauge


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeCreatedEvent">GaugeCreatedEvent</a> <b>has</b> drop, store
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
<code>creator: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>external_bribe: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">pool</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge_type: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter"></a>

## Resource `Voter`



<pre><code><b>struct</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> <b>has</b> key
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
<code>voter_admin: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>governance: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>pools: <a href="_SmartVector">smart_vector::SmartVector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>index: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>vote_delay: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>supply_index: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>claimable: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>gauges: <a href="_Table">table::Table</a>&lt;<b>address</b>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>gauges_distribution_timestamp: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>pool_for_gauge: <a href="_Table">table::Table</a>&lt;<b>address</b>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>external_bribes: <a href="_Table">table::Table</a>&lt;<b>address</b>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>votes: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>pool_vote: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_SmartVector">smart_vector::SmartVector</a>&lt;<b>address</b>&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>weights_per_epoch: <a href="_Table">table::Table</a>&lt;u64, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_weights_per_epoch: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>last_voted: <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>is_gauge: <a href="_Table">table::Table</a>&lt;<b>address</b>, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>is_whitelisted: <a href="_Table">table::Table</a>&lt;<b>address</b>, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>is_alive: <a href="_Table">table::Table</a>&lt;<b>address</b>, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>extended_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>gauge_to_type: <a href="_Table">table::Table</a>&lt;<b>address</b>, u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>dxlyn_coin_address: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>edit_vote_penalty: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_OWNER"></a>

Caller is not the gauge owner


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 120;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SC_ADMIN"></a>

Creator address of the Voter object account


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SC_ADMIN">SC_ADMIN</a>: <b>address</b> = 0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AMOUNT_SCALE"></a>



<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AMOUNT_SCALE">AMOUNT_SCALE</a>: <a href="">u256</a> = 10000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_INSUFFICIENT_DXLYN_COIN"></a>

Insufficient DXLYN token balance to notify rewards


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_INSUFFICIENT_DXLYN_COIN">ERROR_INSUFFICIENT_DXLYN_COIN</a>: u64 = 118;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_NFT_OWNER"></a>

Caller is not the NFT owner


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_NFT_OWNER">ERROR_NOT_NFT_OWNER</a>: u64 = 124;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_ZERO_ADDRESS"></a>

Address cannot be zero


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>: u64 = 106;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK"></a>

One week in seconds (7 days), used to round lock times


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL"></a>

1 DXLYN_DECIMAL in smallest unit (10^8), for token amount scaling


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a>: u64 = 100000000;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST"></a>

Gauge does not exist


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>: u64 = 104;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_FA_SEED"></a>

Seed for the DXLYN fungible asset, used to create a unique address for the token


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_FA_SEED">DXLYN_FA_SEED</a>: <a href="">vector</a>&lt;u8&gt; = [68, 88, 76, 89, 78];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL"></a>

CLMM (Concentrated Liquidity Market Maker)


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>: u8 = 1;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL"></a>

CPMM (Constant Product Market Maker)


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>: u8 = 0;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DURATION"></a>

One week in seconds (7 days)
rewards are released over 7 days


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DURATION">DURATION</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLP_POOL"></a>

DXLP (Perpetual dex pool)


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLP_POOL">DXLP_POOL</a>: u8 = 2;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH"></a>

Bribes and tokens must have the same length when claiming


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH">ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH</a>: u64 = 116;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALIVE"></a>

Throw the trying to revive a gauge that is alive


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALIVE">ERROR_GAUGE_ALIVE</a>: u64 = 110;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_EXIST_FOR_POOL"></a>

Gauge already exists for the pool


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_EXIST_FOR_POOL">ERROR_GAUGE_ALREADY_EXIST_FOR_POOL</a>: u64 = 121;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_KILLED"></a>

Gauge is already killed


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_KILLED">ERROR_GAUGE_ALREADY_KILLED</a>: u64 = 109;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE"></a>

Caller is not governance


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>: u64 = 105;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MINTER"></a>

Caller is not the minter


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MINTER">ERROR_NOT_MINTER</a>: u64 = 117;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MORE_THEN_MAX_DELAY"></a>

Vote delay exceeds the maximum allowed


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MORE_THEN_MAX_DELAY">ERROR_NOT_MORE_THEN_MAX_DELAY</a>: u64 = 103;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN"></a>

Unauthorized action


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN">ERROR_NOT_VOTER_ADMIN</a>: u64 = 101;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO"></a>

Penalty amount cannot be zero


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO">ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO</a>: u64 = 125;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_ALREADY_WHITELISTED"></a>

Pool is already whitelisted


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_ALREADY_WHITELISTED">ERROR_POOL_ALREADY_WHITELISTED</a>: u64 = 107;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH"></a>

Pool votes and weights must have the same length


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH">ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH</a>: u64 = 113;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_EXISTS"></a>

Cannot whitelist a pool that is not registered


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_EXISTS">ERROR_POOL_NOT_EXISTS</a>: u64 = 123;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_FOUND_FOR_GAUGE"></a>

Pool not found for the gauge


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_FOUND_FOR_GAUGE">ERROR_POOL_NOT_FOUND_FOR_GAUGE</a>: u64 = 122;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_WHITELISTED"></a>

Pool is not whitelisted


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_WHITELISTED">ERROR_POOL_NOT_WHITELISTED</a>: u64 = 108;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO"></a>

Pool weight cannot be zero


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO">ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO</a>: u64 = 115;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_START_MUST_BE_LESS_THEN_FINISH"></a>

Gauge start time cannot be after finish time


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_START_MUST_BE_LESS_THEN_FINISH">ERROR_START_MUST_BE_LESS_THEN_FINISH</a>: u64 = 119;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTES_NOT_FOUND"></a>

Votes not found for the user


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTES_NOT_FOUND">ERROR_VOTES_NOT_FOUND</a>: u64 = 112;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY"></a>

Vote delay has not passed


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY">ERROR_VOTE_DELAY</a>: u64 = 111;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY_ALREADY_SET"></a>

Vote delay is already set


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY_ALREADY_SET">ERROR_VOTE_DELAY_ALREADY_SET</a>: u64 = 102;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_FOUND"></a>

Vote already exists for the user in the pool


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_FOUND">ERROR_VOTE_FOUND</a>: u64 = 114;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_MAX_VOTE_DELAY"></a>

Max vote delay allowed in seconds


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_MAX_VOTE_DELAY">MAX_VOTE_DELAY</a>: u64 = 604800;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VOTER_SEEDS"></a>

Seed for Voter object


<pre><code><b>const</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VOTER_SEEDS">VOTER_SEEDS</a>: <a href="">vector</a>&lt;u8&gt; = [86, 79, 84, 69, 82];
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_init_module"></a>

## Function `init_module`



<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_init_module">init_module</a>(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_init_module">init_module</a>(sender: &<a href="">signer</a>) {
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(sender, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VOTER_SEEDS">VOTER_SEEDS</a>);

    <b>let</b> extended_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref);

    <b>let</b> voter_signer = <a href="_generate_signer">object::generate_signer</a>(&constructor_ref);

    //dxlyn <a href="">coin</a> <b>address</b>
    <b>let</b> dxlyn_coin_address = object_address(&<a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>());

    <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_initialize">minter::initialize</a>(sender);
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_initialize">bribe::initialize</a>(sender);
    <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_initialize">gauge_cpmm::initialize</a>(sender);
    <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_initialize">gauge_clmm::initialize</a>(sender);
    <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_initialize">gauge_perp::initialize</a>(sender);

    <b>move_to</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(
        &voter_signer,
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
            owner: @owner,
            voter_admin: @voter_admin,
            governance: @voter_governance,
            <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: @voter_minter,
            pools: <a href="_empty">smart_vector::empty</a>(),
            index: 0,
            vote_delay: 0,
            supply_index: <a href="_new">table::new</a>(),
            claimable: <a href="_new">table::new</a>(),
            gauges: <a href="_new">table::new</a>(),
            gauges_distribution_timestamp: <a href="_new">table::new</a>(),
            pool_for_gauge: <a href="_new">table::new</a>(),
            external_bribes: <a href="_new">table::new</a>(),
            votes: <a href="_new">table::new</a>(),
            pool_vote: <a href="_new">table::new</a>(),
            weights_per_epoch: <a href="_new">table::new</a>(),
            total_weights_per_epoch: <a href="_new">table::new</a>(),
            last_voted: <a href="_new">table::new</a>(),
            is_gauge: <a href="_new">table::new</a>(),
            is_whitelisted: <a href="_new">table::new</a>(),
            is_alive: <a href="_new">table::new</a>(),
            extended_ref,
            dxlyn_coin_address,
            gauge_to_type: <a href="_new">table::new</a>(),
            edit_vote_penalty: 1 * <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a>
        }
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_voter_delay"></a>

## Function `set_voter_delay`

Sets vote delay for voting


<a id="@Arguments_1"></a>

### Arguments

* <code>voter_admin</code> - The signer with voter admin rights
* <code>delay</code> - The delay in seconds between votes


<a id="@Dev_2"></a>

### Dev

Only the voter admin can set the delay.
The delay must not be more than <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_MAX_VOTE_DELAY">MAX_VOTE_DELAY</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_voter_delay">set_voter_delay</a>(voter_admin: &<a href="">signer</a>, delay: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_voter_delay">set_voter_delay</a>(voter_admin: &<a href="">signer</a>, delay: u64) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>assert</b>!(delay &lt;= <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_MAX_VOTE_DELAY">MAX_VOTE_DELAY</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MORE_THEN_MAX_DELAY">ERROR_NOT_MORE_THEN_MAX_DELAY</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(delay != <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY_ALREADY_SET">ERROR_VOTE_DELAY_ALREADY_SET</a>);
    <b>assert</b>!(address_of(voter_admin) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.voter_admin, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN">ERROR_NOT_VOTER_ADMIN</a>);

    <a href="_emit">event::emit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetVoteDelayEvent">SetVoteDelayEvent</a> { old_delay: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay, latest_delay: delay });

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay = delay;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_edit_vote_penalty"></a>

## Function `set_edit_vote_penalty`

Sets the penalty amount imposed for voting within the same epoch.


<a id="@Arguments_3"></a>

### Arguments

* <code>voter_admin</code> - The signer with voter admin rights.
* <code>new_penalty</code> - The new penalty amount to be applied when a voter votes within the same epoch as their last vote.


<a id="@Dev_Notes_4"></a>

### Dev Notes

Only the voter admin is authorized to set this penalty.
The penalty should be set responsibly to discourage invalid or repeated voting within the same epoch.
Emits a <code>SetChangeVotePenalty</code> event to log the change in penalty amount.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_edit_vote_penalty">set_edit_vote_penalty</a>(voter_admin: &<a href="">signer</a>, new_penalty: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_edit_vote_penalty">set_edit_vote_penalty</a>(voter_admin: &<a href="">signer</a>, new_penalty: u64) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>assert</b>!(new_penalty &gt; 0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO">ERROR_PENALTY_MUST_BE_GRATER_THEN_ZERO</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    // Validate Admin
    <b>assert</b>!(address_of(voter_admin) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.voter_admin, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN">ERROR_NOT_VOTER_ADMIN</a>);

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_EditVotePenaltyEvent">EditVotePenaltyEvent</a> { old_penalty: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.edit_vote_penalty, new_penalty }
    );
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.edit_vote_penalty = new_penalty;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_minter"></a>

## Function `set_minter`

Sets a new minter address.


<a id="@Arguments_5"></a>

### Arguments

* <code>voter_admin</code> - The signer with voter admin rights.
* <code><a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a></code> - The address of the new minter.


<a id="@Dev_6"></a>

### Dev

Only the voter admin can set the minter.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_minter">set_minter</a>(voter_admin: &<a href="">signer</a>, <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_minter">set_minter</a>(voter_admin: &<a href="">signer</a>, <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: <b>address</b>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>assert</b>!(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a> != @0x0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(address_of(voter_admin) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.voter_admin, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN">ERROR_NOT_VOTER_ADMIN</a>);

    <a href="_emit">event::emit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetMinterEvent">SetMinterEvent</a> { old_minter: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>, latest_minter: <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a> });

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a> = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_external_bribe_for_gauge"></a>

## Function `set_external_bribe_for_gauge`

Sets the external bribe for a gauge.


<a id="@Arguments_7"></a>

### Arguments

* <code>voter_admin</code> - The signer with voter admin rights.
* <code>gauge</code> - The address of the gauge.
* <code>external</code> - The address of the external bribe.


<a id="@Dev_8"></a>

### Dev

Only the voter admin can set the external bribe.
The gauge must exist in the voter.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_external_bribe_for_gauge">set_external_bribe_for_gauge</a>(voter_admin: &<a href="">signer</a>, gauge: <b>address</b>, external: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_set_external_bribe_for_gauge">set_external_bribe_for_gauge</a>(
    voter_admin: &<a href="">signer</a>, gauge: <b>address</b>, external: <b>address</b>
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);


    <b>assert</b>!(address_of(voter_admin) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.voter_admin, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_VOTER_ADMIN">ERROR_NOT_VOTER_ADMIN</a>);
    <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> old_bribe = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.external_bribes, gauge);

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SetExternalBribeForEvent">SetExternalBribeForEvent</a> { old_bribe: *old_bribe, latest_bribe: external, gauge }
    );

    *old_bribe = external;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_perp_pool"></a>

## Function `whitelist_perp_pool`

Whitelist a Perpectual DXLP for gauge creation.


<a id="@Arguments_9"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>TypeArgument</code> - The AssetT type.


<a id="@Dev_10"></a>

### Dev

Only governance can whitelist perpectual coin.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_perp_pool">whitelist_perp_pool</a>&lt;AssetT&gt;(governance: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_perp_pool">whitelist_perp_pool</a>&lt;AssetT&gt;(
    governance: &<a href="">signer</a>
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    // Dxlp <a href="">object</a> <b>address</b>
    <b>let</b> <a href="">pool</a> = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_dxlp_coin_address">gauge_perp::get_dxlp_coin_address</a>&lt;AssetT&gt;();

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);


    // Pool should not exist or should be blacklisted
    <b>let</b> is_whitelist = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_whitelisted, <a href="">pool</a>, <b>false</b>);
    <b>assert</b>!(!*is_whitelist, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_ALREADY_WHITELISTED">ERROR_POOL_ALREADY_WHITELISTED</a>);

    <b>let</b> gauge = <a href="_create_object_address">object::create_object_address</a>(&<a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_gauge_system_address">gauge_perp::get_gauge_system_address</a>(), <a href="_to_bytes">bcs::to_bytes</a>(&<a href="">pool</a>));

    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>)) {
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>, gauge);
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLP_POOL">DXLP_POOL</a>);
    };

    // Whitelist <a href="">pool</a>
    *is_whitelist = <b>true</b>;

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent">WhitelistedEvent</a> {
            whitelister: governance_address,
            <a href="">pool</a>,
            gauge,
            gauge_type: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLP_POOL">DXLP_POOL</a>,
            asset: <a href="_type_name">type_info::type_name</a>&lt;DXLP&lt;AssetT&gt;&gt;()
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_cpmm_pool"></a>

## Function `whitelist_cpmm_pool`

Whitelist a CPMM pool for gauge creation.


<a id="@Arguments_11"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>TypeArguments</code> - The pool types <X, Y, Curve>.


<a id="@Dev_12"></a>

### Dev

Only governance can whitelist CPMM pools.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_cpmm_pool">whitelist_cpmm_pool</a>&lt;X, Y, Curve&gt;(governance: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_cpmm_pool">whitelist_cpmm_pool</a>&lt;X, Y, Curve&gt;(
    governance: &<a href="">signer</a>
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    // Validate the <a href="">pool</a> exist
    <b>let</b> option_pool = <a href="_get_pool">liquidity_pool::get_pool</a>&lt;X, Y, Curve&gt;();
    <b>assert</b>!(<a href="_is_some">option::is_some</a>(&option_pool), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_EXISTS">ERROR_POOL_NOT_EXISTS</a>);

    <b>let</b> <a href="">pool</a> = *<a href="_borrow">option::borrow</a>(&option_pool);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);

    // Pool should not exist or should be blacklisted
    <b>let</b> is_whitelist = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_whitelisted, <a href="">pool</a>, <b>false</b>);
    <b>assert</b>!(!*is_whitelist, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_ALREADY_WHITELISTED">ERROR_POOL_ALREADY_WHITELISTED</a>);

    <b>let</b> gauge = <a href="_create_object_address">object::create_object_address</a>(&<a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_get_gauge_system_address">gauge_cpmm::get_gauge_system_address</a>(), <a href="_to_bytes">bcs::to_bytes</a>(&<a href="">pool</a>));

    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>)) {
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>, gauge);
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>);
    };

    // Whitelist <a href="">pool</a>
    *is_whitelist = <b>true</b>;

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent">WhitelistedEvent</a> {
            whitelister: governance_address,
            <a href="">pool</a>,
            gauge,
            gauge_type: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>,
            asset: <a href="_type_name">type_info::type_name</a>&lt;LP&lt;X, Y, Curve&gt;&gt;()
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_clmm_pool"></a>

## Function `whitelist_clmm_pool`

Whitelist CLMM pool for gauge creation.


<a id="@Arguments_13"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>pool_address</code> - The pool address


<a id="@Dev_14"></a>

### Dev

Only the governance can whitelist pools.
Tokens must be sorted


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_clmm_pool">whitelist_clmm_pool</a>(governance: &<a href="">signer</a>, pool_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_whitelist_clmm_pool">whitelist_clmm_pool</a>(
    governance: &<a href="">signer</a>,
    pool_address: <b>address</b>
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    // Check is valid <a href="">pool</a>
    <b>let</b> results = <a href="_is_pool_exists">pool::is_pool_exists</a>(<a href="">vector</a>[pool_address]);
    <b>assert</b>!(*<a href="_borrow">vector::borrow</a>(&results, 0), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_EXISTS">ERROR_POOL_NOT_EXISTS</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);

    // Pool should not exist or should be blacklisted
    <b>let</b> is_whitelisted = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_whitelisted, pool_address, <b>false</b>);
    <b>assert</b>!(!*is_whitelisted, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_ALREADY_WHITELISTED">ERROR_POOL_ALREADY_WHITELISTED</a>);

    <b>let</b> gauge = <a href="_create_object_address">object::create_object_address</a>(
        &<a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_get_gauge_system_address">gauge_clmm::get_gauge_system_address</a>(),
        <a href="_to_bytes">bcs::to_bytes</a>(&pool_address)
    );

    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, pool_address)) {
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, pool_address, gauge);
        <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>);
    };

    // Whitelist <a href="">pool</a>
    *is_whitelisted = <b>true</b>;

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WhitelistedEvent">WhitelistedEvent</a> {
            whitelister: governance_address,
            <a href="">pool</a>: pool_address,
            gauge, gauge_type: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>,
            asset: <a href="_utf8">string::utf8</a>(b"")
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_blacklist"></a>

## Function `blacklist`

Blacklist a malicious pool.


<a id="@Arguments_15"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>pools</code> - The addresses of the pools to blacklist.


<a id="@Dev_16"></a>

### Dev

Only the governance can blacklist pools.
The pool address must not be zero.
The pool must be whitelisted.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_blacklist">blacklist</a>(governance: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_blacklist">blacklist</a>(governance: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);

    <a href="_for_each">vector::for_each</a>(pools, |<a href="">pool</a>| {
        <b>assert</b>!(<a href="">pool</a> != @0x0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_ZERO_ADDRESS">ERROR_ZERO_ADDRESS</a>);

        // Pool should exist or should be whitelisted
        <b>let</b> is_whitelisted = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_whitelisted, <a href="">pool</a>, <b>false</b>);
        <b>assert</b>!(*is_whitelisted, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_WHITELISTED">ERROR_POOL_NOT_WHITELISTED</a>);

        // Blacklist <a href="">pool</a>
        *is_whitelisted = <b>false</b>;

        <a href="_emit">event::emit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_BlacklistedEvent">BlacklistedEvent</a> { blacklister: governance_address, <a href="">pool</a> });
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_kill_gauge"></a>

## Function `kill_gauge`

Kill a malicious gauge.


<a id="@Arguments_17"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>gauge</code> - The address of the gauge to kill.


<a id="@Dev_18"></a>

### Dev

Only the governance can kill a gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_kill_gauge">kill_gauge</a>(governance: &<a href="">signer</a>, gauge: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_kill_gauge">kill_gauge</a>(governance: &<a href="">signer</a>, gauge: <b>address</b>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);

    <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);
    <b>let</b> is_alive = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge);
    <b>assert</b>!(*is_alive, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_KILLED">ERROR_GAUGE_ALREADY_KILLED</a>);
    *is_alive = <b>false</b>;

    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.claimable, gauge, 0);

    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();
    <b>let</b> <a href="">pool</a> = <a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_for_gauge, gauge);
    <b>let</b> weights_per_epoch =
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time, *<a href="">pool</a>);

    <b>let</b> total_weights_per_epoch = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, time, 0);
    *total_weights_per_epoch = *total_weights_per_epoch - weights_per_epoch;

    <a href="_emit">event::emit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeKilledEvent">GaugeKilledEvent</a> { gauge })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_revive_gauge"></a>

## Function `revive_gauge`

Revive a malicious gauge.


<a id="@Arguments_19"></a>

### Arguments

* <code>governance</code> - The signer with governance rights.
* <code>gauge</code> - The address of the gauge to revive.


<a id="@Dev_20"></a>

### Dev

Only the governance can revive a gauge.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_revive_gauge">revive_gauge</a>(governance: &<a href="">signer</a>, gauge: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_revive_gauge">revive_gauge</a>(governance: &<a href="">signer</a>, gauge: <b>address</b>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> governance_address = address_of(governance);
    <b>assert</b>!(governance_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.governance, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_GOVERNANCE">ERROR_NOT_GOVERNANCE</a>);
    <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

    <b>let</b> is_alive = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge);
    <b>assert</b>!(!*is_alive, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALIVE">ERROR_GAUGE_ALIVE</a>);
    *is_alive = <b>true</b>;

    <a href="_emit">event::emit</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeKilledEvent">GaugeKilledEvent</a> { gauge })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset"></a>

## Function `reset`

Resets the votes of the caller.


<a id="@Arguments_21"></a>

### Arguments

* <code>caller</code> - The caller who wants to reset their votes.
* <code><a href="">token</a></code> - The address of the nft token to reset votes for.


<a id="@Dev_22"></a>

### Dev

This function resets the votes of the user and updates the last voted timestamp.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset">reset</a>(caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset">reset</a>(caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> caller_address = address_of(caller);
    // Check <b>if</b> the caller is the owner of the <a href="">token</a> and <b>return</b> the <a href="">token</a> owner
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">voting_escrow::assert_if_not_owner</a>(caller_address, <a href="">token</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(
        <a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTES_NOT_FOUND">ERROR_VOTES_NOT_FOUND</a>
    );

    // Check vote delay
    <b>let</b> last_voted = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>);
    <b>assert</b>!(
        <a href="_now_seconds">timestamp::now_seconds</a>() &gt; *last_voted + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay,
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY">ERROR_VOTE_DELAY</a>
    );

    // Reset votes
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal">reset_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, caller_address, <a href="">token</a>);

    <b>let</b> voter_singer = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
    // Call abstain on voting escrow
    // only <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> can call this function
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_abstain">voting_escrow::abstain</a>(voter_singer, <a href="">token</a>);

    // Update last voted <a href="">timestamp</a>
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + 1);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period"></a>

## Function `update_period`

This function is called every week to calculate the rebase,emission and distribute rewards.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period">update_period</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period">update_period</a>() <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> (rebase, gauge, dxlyn_signer, is_new_week) = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_calculate_rebase_gauge">minter::calculate_rebase_gauge</a>();

    <b>if</b> (is_new_week) {
        <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
        <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
        <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_burn_rebase">fee_distributor::burn_rebase</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, &dxlyn_signer, rebase);
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_token">fee_distributor::checkpoint_token</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>);
        <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_checkpoint_total_supply">fee_distributor::checkpoint_total_supply</a>();

        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_notify_reward_amount">notify_reward_amount</a>(&dxlyn_signer, gauge);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_poke"></a>

## Function `poke`

Recast the saved votes of a nft token.


<a id="@Arguments_23"></a>

### Arguments

* <code>caller</code> - The caller who wants to recast their votes.
* <code><a href="">token</a></code> - The address of the token to recast votes for.


<a id="@Dev_24"></a>

### Dev

This function recasts the votes of the token to the same pools with the same weights.
The token must have voted before, otherwise an error is thrown.
The token must wait for the vote delay before recasting their votes.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_poke">poke</a>(caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_poke">poke</a>(caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> caller_address = address_of(caller);

    // Check <b>if</b> the caller is the owner of the <a href="">token</a> and <b>return</b> the <a href="">token</a> owner
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">voting_escrow::assert_if_not_owner</a>(caller_address, <a href="">token</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(
        <a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTES_NOT_FOUND">ERROR_VOTES_NOT_FOUND</a>
    );

    // Check vote delay
    <b>let</b> last_voted =
        <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, &0);
    <b>assert</b>!(
        <a href="_now_seconds">timestamp::now_seconds</a>() &gt; *last_voted + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay,
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY">ERROR_VOTE_DELAY</a>
    );

    <b>let</b> pool_vote = <a href="_to_vector">smart_vector::to_vector</a>(<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>));
    <b>let</b> weights = <a href="_empty">vector::empty</a>&lt;u64&gt;();

    <a href="_for_each">vector::for_each</a>(pool_vote, |<a href="">pool</a>| {
        //get <a href="">pool</a> votes for <a href="">token</a>
        <b>let</b> weight = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal">get_vote_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="">token</a>, <a href="">pool</a>);
        //add add previous <a href="">pool</a> weights <b>to</b> list
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> weights, weight);
    });

    // Cast vote <b>to</b> same <a href="">pool</a> <b>with</b> same weights
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal">vote_internal</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>,
        caller_address,
        <a href="">token</a>,
        pool_vote,
        weights
    );

    // Update last voted <a href="">timestamp</a>
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + 1);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote"></a>

## Function `vote`

Vote for pools.


<a id="@Arguments_25"></a>

### Arguments

* <code>caller</code> - The caller who wants to vote.
* <code><a href="">token</a></code> - The address of the token from vote will submit (e\.g\., veDXLYN).
* <code>pool_vote</code> - Array of LP pool addresses to vote (e\.g\., \[sAMM usdc-usdt, sAMM busd-usdt, vAMM wbnb-the, ...\]).
* <code>weights</code> - Array of weights for each LP pool (e\.g\., \[10, 90, 45, ...\]).


<a id="@Dev_26"></a>

### Dev

This function allows veDXLYN holders to vote for pools with weights.
The caller must wait for the vote delay before voting.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote">vote</a>(caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, pool_vote: <a href="">vector</a>&lt;<b>address</b>&gt;, weights: <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote">vote</a>(
    caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, pool_vote: <a href="">vector</a>&lt;<b>address</b>&gt;, weights: <a href="">vector</a>&lt;u64&gt;
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    // Check <a href="">pool</a> and weights length match or not
    <b>assert</b>!(
        <a href="_length">vector::length</a>(&pool_vote) == <a href="_length">vector::length</a>(&weights),
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH">ERROR_POOL_AND_WEIGHTS_LENGTH_NOT_MATCH</a>
    );

    <b>let</b> caller_address = address_of(caller);
    // Check <b>if</b> the caller is the owner of the <a href="">token</a> and <b>return</b> the <a href="">token</a> owner
    <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_assert_if_not_owner">voting_escrow::assert_if_not_owner</a>(caller_address, <a href="">token</a>);

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    // Check vote delay
    <b>let</b> last_voted =
        <a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, &0);
    <b>assert</b>!(
        <a href="_now_seconds">timestamp::now_seconds</a>() &gt; *last_voted + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.vote_delay,
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_DELAY">ERROR_VOTE_DELAY</a>
    );

    <b>let</b> week = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>;
    <b>let</b> last_voted_epoch = *last_voted / week * week;
    <b>let</b> current_epoch = <a href="_now_seconds">timestamp::now_seconds</a>() / week * week;

    // If the user attempts <b>to</b> vote within the same epoch <b>as</b> their last vote, <b>apply</b> a penalty
    <b>if</b> (current_epoch == last_voted_epoch) {
        <a href="_transfer">primary_fungible_store::transfer</a>(
            caller,
            <a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_get_dxlyn_asset_metadata">dxlyn_coin::get_dxlyn_asset_metadata</a>(),
            @fee_treasury,
            <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.edit_vote_penalty
        );
    };

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal">vote_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, caller_address, <a href="">token</a>, pool_vote, weights);

    // Update last voted <a href="">timestamp</a>
    <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + 1);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_emission"></a>

## Function `claim_emission`

Claim emission reward for gauges.


<a id="@Arguments_27"></a>

### Arguments

* <code>user</code> - The user who wants to claim rewards.
* <code>gauges</code> - The addresses of the gauges to claim rewards from.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_emission">claim_emission</a>(user: &<a href="">signer</a>, gauges: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_emission">claim_emission</a>(user: &<a href="">signer</a>, gauges: <a href="">vector</a>&lt;<b>address</b>&gt;) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <a href="_for_each">vector::for_each</a>(gauges, |gauge| {
        //fetch <a href="">pool</a> (lp) <b>address</b> for gauge
        <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_for_gauge, gauge), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

        <b>let</b> gauge_type = <a href="_borrow">table::borrow</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge);
        //claim reward from the gauge
        <b>if</b> (*gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>) {
            <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_get_reward">gauge_clmm::get_reward</a>(user, gauge);
        } <b>else</b> <b>if</b> (*gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>) {
            <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_get_reward">gauge_cpmm::get_reward</a>(user, gauge);
        } <b>else</b> {
            <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_get_reward">gauge_perp::get_reward</a>(user, gauge);
        }
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes"></a>

## Function `claim_bribes`

Claims bribes for the user.


<a id="@Arguments_28"></a>

### Arguments

* <code>user</code> - The user who wants to claim bribes.
* <code>pools</code> - The addresses of the pool from which bribes will be claim.
* <code>tokens</code> - The addresses of the tokens to claim bribes for.


<a id="@Dev_29"></a>

### Dev

The length of bribes and tokens must match.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes">claim_bribes</a>(user: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes">claim_bribes</a>(
    user: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;
) {
    <b>let</b> pools_cnt = <a href="_length">vector::length</a>(&pools);
    <b>let</b> tokens_cnt = <a href="_length">vector::length</a>(&tokens);

    <b>assert</b>!(pools_cnt == tokens_cnt, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH">ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH</a>);

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pools, |index, <a href="">pool</a>| {
        <b>let</b> <a href="">token</a> = <a href="_borrow">vector::borrow</a>(&tokens, index);
        // claim the <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> reward by owner
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward">bribe::get_reward</a>(user, *<a href="">pool</a>, *<a href="">token</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribe_for_token"></a>

## Function `claim_bribe_for_token`

Claims bribes for the token owner.


<a id="@Arguments_30"></a>

### Arguments

* <code>caller</code> - The caller signer of transaction.
* <code><a href="">token</a></code> - The address of the nft token.
* <code>pools</code> - The addresses of the pool from which bribes will be claim.
* <code>tokens</code> - The addresses of the reward tokens to claim bribes for.


<a id="@Dev_31"></a>

### Dev

The length of bribes and tokens must match.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribe_for_token">claim_bribe_for_token</a>(_caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribe_for_token">claim_bribe_for_token</a>(
    _caller: &<a href="">signer</a>, <a href="">token</a>: <b>address</b>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;
) {
    <b>let</b> pools_cnt = <a href="_length">vector::length</a>(&pools);
    <b>let</b> tokens_cnt = <a href="_length">vector::length</a>(&tokens);

    <b>assert</b>!(pools_cnt == tokens_cnt, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH">ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH</a>);

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pools, |index, <a href="">pool</a>| {
        <b>let</b> token_i = <a href="_borrow">vector::borrow</a>(&tokens, index);
        // claim the <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> reward for <a href="">token</a> owner
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_token_owner">bribe::get_reward_for_token_owner</a>(_caller, *<a href="">pool</a>, <a href="">token</a>, *token_i);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes_for_address"></a>

## Function `claim_bribes_for_address`

Claims bribes for the user for a specific address.


<a id="@Arguments_32"></a>

### Arguments

* <code>user</code> - The address of the user who wants to claim bribes.
* <code>pools</code> - The addresses of the pool from which bribes will be claim.
* <code>tokens</code> - The addresses of the tokens to claim bribes for.


<a id="@Dev_33"></a>

### Dev

The length of bribes and tokens must match.
This function is used to claim bribes for a specific user address.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes_for_address">claim_bribes_for_address</a>(user: <b>address</b>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_claim_bribes_for_address">claim_bribes_for_address</a>(
    user: <b>address</b>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens: <a href="">vector</a>&lt;<a href="">vector</a>&lt;<b>address</b>&gt;&gt;
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>let</b> pools_cnt = <a href="_length">vector::length</a>(&pools);
    <b>let</b> tokens_cnt = <a href="_length">vector::length</a>(&tokens);

    <b>assert</b>!(pools_cnt == tokens_cnt, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH">ERROR_BRIBES_AND_TOKENS_LENGTH_MISMATCH</a>);

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pools, |index, <a href="">pool</a>| {
        <b>let</b> <a href="">token</a> = <a href="_borrow">vector::borrow</a>(&tokens, index);

        <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
        //Claim the <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> reward for user
        <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_reward_for_address">bribe::get_reward_for_address</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, *<a href="">pool</a>, user, *<a href="">token</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauges"></a>

## Function `create_gauges`

Creates multiple gauges.


<a id="@Arguments_34"></a>

### Arguments

* <code>owner</code> - The owner of the voter .
* <code>pools</code> - The addresses of the pools for which gauges are to be created.


<a id="@Dev_35"></a>

### Dev

The length of <code>pools</code> and <code>gauge_types</code> must match.
Only the owner can create gauges.
The pools must be whitelisted.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauges">create_gauges</a>(owner: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauges">create_gauges</a>(
    owner: &<a href="">signer</a>, pools: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();

    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(address_of(owner) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.owner, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pools, |index, <a href="">pool</a>| {
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal">create_gauge_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, owner, *<a href="">pool</a>);
    });
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge"></a>

## Function `create_gauge`

Creates a gauge.


<a id="@Arguments_36"></a>

### Arguments

* <code>owner</code> - The owner of the voter
* <code><a href="">pool</a></code> - LP address


<a id="@Dev_37"></a>

### Dev

Only the owner can create a gauge.
The pool must be whitelisted.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge">create_gauge</a>(owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge">create_gauge</a>(
    owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>assert</b>!(address_of(owner) == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.owner, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>);
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal">create_gauge_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, owner, <a href="">pool</a>);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_notify_reward_amount"></a>

## Function `notify_reward_amount`

Notifies the reward amount for the gauge.


<a id="@Arguments_38"></a>

### Arguments

* <code><a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a></code> - The signer authorized to notify rewards.
* <code>amount</code> - The amount to distribute.


<a id="@Dev_39"></a>

### Dev

This function is called by the minter each epoch.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_notify_reward_amount">notify_reward_amount</a>(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_notify_reward_amount">notify_reward_amount</a>(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>: &<a href="">signer</a>, amount: u64) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> minter_address = address_of(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>);

    <b>assert</b>!(minter_address == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_NOT_MINTER">ERROR_NOT_MINTER</a>);

    <b>let</b> dxlyn_metadata = address_to_object&lt;Metadata&gt;(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.dxlyn_coin_address);
    <b>let</b> balance = <a href="_balance">primary_fungible_store::balance</a>(minter_address, dxlyn_metadata);
    <b>assert</b>!(balance &gt;= amount, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_INSUFFICIENT_DXLYN_COIN">ERROR_INSUFFICIENT_DXLYN_COIN</a>);

    //transfer dexlyn coins
    <a href="_transfer">primary_fungible_store::transfer</a>(<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a>, dxlyn_metadata, voter_address, amount);

    // <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter">minter</a> call notify after updates active_period, loads votes - 1 week
    <b>let</b> epoch = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() - <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>;
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, epoch)) {
        <b>let</b> total_weight = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, epoch);
        <b>let</b> ratio = 0;

        <b>if</b> (total_weight &gt; 0) {
            // 1e8 adjustment is removed during claim
            // scaled ratio is used <b>to</b> avoid overflow
            <b>let</b> scaled_ratio = (amount <b>as</b> <a href="">u256</a>) * (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>)
                / (total_weight <b>as</b> <a href="">u256</a>);
            // convert scaled ratio <b>to</b> u64
            ratio = (scaled_ratio <b>as</b> u64);
        };

        <b>if</b> (ratio &gt; 0) {
            <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.index = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.index + ratio;
        };
    };

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_NotifyRewardEvent">NotifyRewardEvent</a> {
            sender: minter_address,
            reward: <a href="_object_address">object::object_address</a>(&dxlyn_metadata),
            amount
        }
    );
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_all"></a>

## Function `distribute_all`

Distribute the emission for ALL gauges

<a id="@Arguments_40"></a>

### Arguments

* <code>caller</code> - The user as singer.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_all">distribute_all</a>(_sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_all">distribute_all</a>(_sender: &<a href="">signer</a>) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period">update_period</a>();
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> distribution = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);

    <b>let</b> stop = <a href="_length">smart_vector::length</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pools);

    for (i in 0..stop) {
        <b>let</b> <a href="">pool</a> = *<a href="_borrow">smart_vector::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pools, i);
        <b>let</b> gauge = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>);
        <b>let</b> gauge_type = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge);
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal">distribute_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, distribution, gauge, gauge_type);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_range"></a>

## Function `distribute_range`

Distribute the emission for a range of gauges.


<a id="@Arguments_41"></a>

### Arguments

* <code>_sender</code> - The sender calling the function.
* <code>start</code> - Start index of the pools array.
* <code>finish</code> - Finish index of the pools array.


<a id="@Dev_42"></a>

### Dev

Use this function when there are too many pools and the gas limit may be reached.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_range">distribute_range</a>(_sender: &<a href="">signer</a>, start: u64, finish: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_range">distribute_range</a>(
    _sender: &<a href="">signer</a>, start: u64, finish: u64
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>assert</b>!(start &lt; finish, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_START_MUST_BE_LESS_THEN_FINISH">ERROR_START_MUST_BE_LESS_THEN_FINISH</a>);

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period">update_period</a>();

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> distribution = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);


    for (i in start..finish) {
        <b>let</b> <a href="">pool</a> = *<a href="_borrow">smart_vector::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pools, i);
        <b>let</b> gauge = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>);
        <b>let</b> gauge_type = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge);
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal">distribute_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, distribution, gauge, gauge_type);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_gauges"></a>

## Function `distribute_gauges`

Distributes rewards only for the specified gauges.


<a id="@Arguments_43"></a>

### Arguments

* <code>_sender</code> - The sender calling the function.
* <code>gauges</code> - A vector of addresses representing the gauges to distribute rewards for.

<a id="@Dev_44"></a>

### Dev

This function is used in case some distributions fail.


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_gauges">distribute_gauges</a>(_sender: &<a href="">signer</a>, gauges: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_gauges">distribute_gauges</a>(
    _sender: &<a href="">signer</a>, gauges: <a href="">vector</a>&lt;<b>address</b>&gt;
) <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_period">update_period</a>();

    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global_mut</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> distribution = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);

    <a href="_for_each">vector::for_each</a>(gauges, |gauge| {
        <b>assert</b>!(<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_NOT_EXIST">ERROR_GAUGE_NOT_EXIST</a>);

        <b>let</b> type = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge);
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal">distribute_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, distribution, gauge, type);
    })
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_edit_vote_penalty"></a>

## Function `get_edit_vote_penalty`

View the vote penalty amount applied for voting in the same epoch.


<a id="@Returns_45"></a>

### Returns

The penalty amount imposed when a voter votes within the same epoch as their last vote.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_edit_vote_penalty">get_edit_vote_penalty</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_edit_vote_penalty">get_edit_vote_penalty</a>(): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address).edit_vote_penalty
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address"></a>

## Function `get_voter_address`

View address of the Voter object address.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>(): <b>address</b> {
    <a href="_create_object_address">object::create_object_address</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_SC_ADMIN">SC_ADMIN</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VOTER_SEEDS">VOTER_SEEDS</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_external_bribe_address"></a>

## Function `get_external_bribe_address`

View the external bribe address for a given pool.


<a id="@Arguments_46"></a>

### Arguments

* <code><a href="">pool</a></code> - The address of the pool for which the external bribe address is to be retrieved.


<a id="@Returns_47"></a>

### Returns

The address of the external bribe for the given pool.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_external_bribe_address">get_external_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_external_bribe_address">get_external_bribe_address</a>(<a href="">pool</a>: <b>address</b>): <b>address</b> {
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_get_bribe_address">bribe::get_bribe_address</a>(<a href="">pool</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_length"></a>

## Function `length`

View the total length of the pools.


<a id="@Returns_48"></a>

### Returns

The total number of pools in the Voter.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_length">length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_length">length</a>(): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <a href="_length">smart_vector::length</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pools)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_pool_vote_length"></a>

## Function `pool_vote_length`

View the total number of pools voted by the given token address.


<a id="@Arguments_49"></a>

### Arguments

* <code><a href="">token</a></code> - The address of the nft token.


<a id="@Returns_50"></a>

### Returns

The total number of pools voted by the token.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_pool_vote_length">pool_vote_length</a>(<a href="">token</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_pool_vote_length">pool_vote_length</a>(<a href="">token</a>: <b>address</b>): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>)) {
        <b>let</b> voted_pools = <a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>);
        <a href="_length">smart_vector::length</a>(voted_pools)
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights"></a>

## Function `weights`

View the total weight of a pool.


<a id="@Arguments_51"></a>

### Arguments

* <code><a href="">pool</a></code> - The address of the pool for which the weight is to be retrieved.


<a id="@Returns_52"></a>

### Returns

The total weight of the pool at the current epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights">weights</a>(<a href="">pool</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights">weights</a>(<a href="">pool</a>: <b>address</b>): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time, <a href="">pool</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_at"></a>

## Function `weights_at`

View the total weight of a pool at a specific time.


<a id="@Arguments_53"></a>

### Arguments

* <code><a href="">pool</a></code> - The address of the pool for which the weight is to be retrieved.
* <code>time</code> - The specific time at which the weight is to be retrieved.


<a id="@Returns_54"></a>

### Returns

The total weight of the pool at the specified time.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_at">weights_at</a>(<a href="">pool</a>: <b>address</b>, time: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_at">weights_at</a>(<a href="">pool</a>: <b>address</b>, time: u64): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time, <a href="">pool</a>)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight"></a>

## Function `total_weight`

View the total weight of the current epoch.


<a id="@Returns_55"></a>

### Returns

The total weight of the current epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight">total_weight</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight">total_weight</a>(): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);
    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();

    *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, time, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight_at"></a>

## Function `total_weight_at`

View the total weight of a specific epoch.


<a id="@Arguments_56"></a>

### Arguments

* <code>time</code> - The specific epoch time for which the total weight is to be retrieved.


<a id="@Returns_57"></a>

### Returns

The total weight of the specified epoch.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight_at">total_weight_at</a>(time: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight_at">total_weight_at</a>(time: u64): u64 <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> voter_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_voter_address">get_voter_address</a>();
    <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <b>borrow_global</b>&lt;<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>&gt;(voter_address);

    *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, time, &0)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp"></a>

## Function `epoch_timestamp`

get the current epoch

<a id="@Returns_58"></a>

### Returns

The current epoch timestamp.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>(): u64 {
    <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_active_period">minter::active_period</a>()
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_earned_all_gauges"></a>

## Function `earned_all_gauges`

View the earned rewards for a user across multiple gauges.


<a id="@Arguments_59"></a>

### Arguments

* <code>user_address</code> - The address of the user whose earnings are to be checked.
* <code>cpmm_gauge_addresses</code> - A vector of addresses of CPMM gauges.
* <code>clmm_gauge_addresses</code> - A vector of addresses of CLMM gauges.
* <code>prep_gauge_addresses</code> - A vector of addresses of Perp gauges.


<a id="@Returns_60"></a>

### Returns

A tuple containing:
Total reward for all gauges and vectors of weekly earned rewards for each gauge type.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_earned_all_gauges">earned_all_gauges</a>(user_address: <b>address</b>, cpmm_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;, clmm_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;, perp_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;): (u64, u64, u64, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_earned_all_gauges">earned_all_gauges</a>(
    user_address: <b>address</b>,
    cpmm_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;,
    clmm_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;,
    perp_gauge_addresses: <a href="">vector</a>&lt;<b>address</b>&gt;
): (u64, u64, u64, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;) {
    <b>let</b> (total_reward_cpmm, weekly_earned_cpmm) = <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_earned_many">gauge_cpmm::earned_many</a>(cpmm_gauge_addresses, user_address);
    <b>let</b> (total_reward_clmm, weekly_earned_clmm) = <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_earned_many">gauge_clmm::earned_many</a>(clmm_gauge_addresses, user_address);
    <b>let</b> (total_reward_perp, weekly_earned_perp) = <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_earned_many">gauge_perp::earned_many</a>(perp_gauge_addresses, user_address);

    (total_reward_cpmm, total_reward_clmm, total_reward_perp, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_claimable_rewards"></a>

## Function `total_claimable_rewards`

View the total claimable rewards for a user across multiple gauges, ve rewards, and bribes.


<a id="@Arguments_61"></a>

### Arguments

* <code>user_address</code> - The address of the user whose claimable rewards are to be checked.
* <code>reward_token_for_bribe</code> - The address of the reward token for bribes.
* <code>cpmm_gauge_addresses_for_emission</code> - A vector of addresses of CPMM gauges.
* <code>clmm_gauge_addresses_for_emission</code> - A vector of addresses of CLMM gauges.
* <code>perp_gauge_addresses_for_emission</code> - A vector of addresses of Perp gauges.
* <code>tokens_for_ve_reward</code> - A vector of addresses of tokens for ve rewards.
* <code>pools_for_bribe</code> - A vector of addresses of pools for bribes.


<a id="@Returns_62"></a>

### Returns

A tuple containing:
Total rewards for CPMM, CLMM, Perp gauges, ve rewards, and bribes,
and vectors of weekly earned rewards for each gauge type, ve rewards, and bribes.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_claimable_rewards">total_claimable_rewards</a>(user_address: <b>address</b>, reward_token_for_bribe: <b>address</b>, cpmm_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;, clmm_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;, perp_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;, tokens_for_ve_reward: <a href="">vector</a>&lt;<b>address</b>&gt;, pools_for_bribe: <a href="">vector</a>&lt;<b>address</b>&gt;): (u64, u64, u64, u64, u64, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;u64&gt;, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_WeeklyClaim">fee_distributor::WeeklyClaim</a>&gt;&gt;, <a href="">vector</a>&lt;<a href="">vector</a>&lt;<a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_WeeklyPaidReward">bribe::WeeklyPaidReward</a>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_claimable_rewards">total_claimable_rewards</a>(
    user_address: <b>address</b>,
    reward_token_for_bribe: <b>address</b>,
    cpmm_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;,
    clmm_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;,
    perp_gauge_addresses_for_emission: <a href="">vector</a>&lt;<b>address</b>&gt;,
    tokens_for_ve_reward: <a href="">vector</a>&lt;<b>address</b>&gt;,
    pools_for_bribe: <a href="">vector</a>&lt;<b>address</b>&gt;
): (
    u64, // total_reward_cpmm
    u64, // total_reward_clmm
    u64, // total_reward_perp
    u64, // total_ve_reward
    u64, // total_bribe
    <a href="">vector</a>&lt;u64&gt;, // weekly_earned_cpmm
    <a href="">vector</a>&lt;u64&gt;, // weekly_earned_clmm
    <a href="">vector</a>&lt;u64&gt;, // weekly_earned_perp
    <a href="">vector</a>&lt;<a href="">vector</a>&lt;WeeklyClaim&gt;&gt;, // weekly_ve_reward,
    <a href="">vector</a>&lt;<a href="">vector</a>&lt;WeeklyPaidReward&gt;&gt; // weekly_earned_bribe
) {
    <b>let</b> (total_reward_cpmm, total_reward_clmm, total_reward_perp, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp) = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_earned_all_gauges">earned_all_gauges</a>(
        user_address,
        cpmm_gauge_addresses_for_emission,
        clmm_gauge_addresses_for_emission,
        perp_gauge_addresses_for_emission
    );

    <b>let</b> (total_ve_reward, weekly_ve_reward) = <a href="fee_distributor.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_fee_distributor_claimable_many">fee_distributor::claimable_many</a>(tokens_for_ve_reward);

    <b>let</b> (total_bribe, weekly_earned_bribe) = <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_earned_many">bribe::earned_many</a>(
        pools_for_bribe,
        user_address,
        reward_token_for_bribe
    );

    (total_reward_cpmm, total_reward_clmm, total_reward_perp, total_ve_reward, total_bribe, weekly_earned_cpmm, weekly_earned_clmm, weekly_earned_perp, weekly_ve_reward, weekly_earned_bribe)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_emission_reward_for_pools"></a>

## Function `estimated_emission_reward_for_pools`

Estimate the emission rewards for a list of pools based on their weights.


<a id="@Arguments_63"></a>

### Arguments

* <code>pools</code> - A vector of pool addresses for which to estimate rewards.


<a id="@Returns_64"></a>

### Returns

A vector of estimated rewards for each pool.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_emission_reward_for_pools">estimated_emission_reward_for_pools</a>(pools: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_emission_reward_for_pools">estimated_emission_reward_for_pools</a>(pools: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;u64&gt; <b>acquires</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a> {
    <b>let</b> total_weight = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_total_weight">total_weight</a>();
    <b>let</b> pool_rewards = <a href="_empty">vector::empty</a>&lt;u64&gt;();
    <b>if</b> (total_weight == 0) {
        <b>return</b> pool_rewards
    };

    <b>let</b> gauge = <a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission">minter::get_next_emission</a>() - <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase">estimated_rebase</a>();
    <b>let</b> expected_ratio = (gauge <b>as</b> <a href="">u256</a>) * (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>) / (total_weight <b>as</b> <a href="">u256</a>);

    for_each(pools, |<a href="">pool</a>|{
        // Expected reward for a <a href="">pool</a>
        <a href="_push_back">vector::push_back</a>(
            &<b>mut</b> pool_rewards, ((<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights">weights</a>(<a href="">pool</a>) <b>as</b> <a href="">u256</a>) * expected_ratio / (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>) <b>as</b> u64)
        );
    });

    pool_rewards
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase"></a>

## Function `estimated_rebase`

Estimate the weekly rebase amount based on the epoch end veDXLYN power and total DXLYN supply.


<a id="@Returns_65"></a>

### Returns

The estimated weekly rebase amount.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase">estimated_rebase</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase">estimated_rebase</a>(): u64 {
    // Rebase = weeklyEmissions * (1 - (veDXLYN.totalSupply / DXLYN.totalSupply) )^2 * 0.5
    // Get total DXLYN supply (10^8)
    <b>let</b> dxlyn_supply = (<a href="../dexlyn_coin/doc/dxlyn_coin.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_dxlyn_coin_total_supply">dxlyn_coin::total_supply</a>() <b>as</b> <a href="">u256</a>);

    // Get veDXLYN supply at start of next epoch (10^12)
    <b>let</b> ve_dxlyn_supply = (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply">voting_escrow::total_supply</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>) <b>as</b> <a href="">u256</a>);

    // (1 - veDXLYN/DXLYN), scaled by 10^4
    <b>let</b> diff_scaled = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AMOUNT_SCALE">AMOUNT_SCALE</a> - (ve_dxlyn_supply / dxlyn_supply);

    // ( 10^4 * 10^4 * 10^4 -&gt; 10^12 / 10^4 -&gt; 10^8)
    <b>let</b> factor = ((diff_scaled * diff_scaled) * 5000) / <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AMOUNT_SCALE">AMOUNT_SCALE</a>;

    <b>let</b> emission_amount = (<a href="minter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_minter_get_next_emission">minter::get_next_emission</a>() <b>as</b> <a href="">u256</a>);

    // 10^8 * 10^8 -&gt; 10^16 / 10^8 -&gt; 10^8
    (((emission_amount * factor) / (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>)) <b>as</b> u64)
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase_for_tokens"></a>

## Function `estimated_rebase_for_tokens`

Estimate the rebase rewards for a list of tokens based on their epoch end veDXLYN power.


<a id="@Arguments_66"></a>

### Arguments

* <code>tokens</code> - A vector of token addresses for which to estimate rebase rewards.


<a id="@Returns_67"></a>

### Returns

A vector of estimated rebase rewards for each token.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase_for_tokens">estimated_rebase_for_tokens</a>(tokens: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase_for_tokens">estimated_rebase_for_tokens</a>(tokens: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;u64&gt; {
    // veDXLYN power of the <a href="">token</a> at the start of next epoch
    <b>let</b> ve_dxlyn_supply = (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_total_supply">voting_escrow::total_supply</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>) <b>as</b> <a href="">u256</a>);
    <b>let</b> token_rewards = <a href="_empty">vector::empty</a>&lt;u64&gt;();

    <b>if</b> (ve_dxlyn_supply == 0) {
        <b>return</b> token_rewards
    };

    <b>let</b> estimated_weekly_rebase = (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_estimated_rebase">estimated_rebase</a>() <b>as</b> <a href="">u256</a>);

    for_each(tokens, |<a href="">token</a>|{
        <b>let</b> token_ve_dxlyn_supply = (<a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of">voting_escrow::balance_of</a>(<a href="">token</a>, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() + <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>) <b>as</b> <a href="">u256</a>);
        // Expected reward for a <a href="">pool</a>
        <a href="_push_back">vector::push_back</a>(
            &<b>mut</b> token_rewards, (token_ve_dxlyn_supply * estimated_weekly_rebase / ve_dxlyn_supply <b>as</b> u64)
        );
    });

    token_rewards
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal"></a>

## Function `weights_per_epoch_internal`

Returns the weight for a given pool at a specific epoch.

* <code>weights_per_epoch</code> - Table mapping epoch (u64) to a table of pool addresses and their weights.
* <code>time</code> - The target epoch.
* <code><a href="">pool</a></code> - The pool address to look up the weight for.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(weights_per_epoch: &<a href="_Table">table::Table</a>&lt;u64, <a href="_Table">table::Table</a>&lt;<b>address</b>, u64&gt;&gt;, time: u64, <a href="">pool</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(
    weights_per_epoch: &Table&lt;u64, Table&lt;<b>address</b>, u64&gt;&gt;,
    time: u64,
    <a href="">pool</a>: <b>address</b>
): u64 {
    <b>if</b> (<a href="_contains">table::contains</a>(weights_per_epoch, time)) {
        <b>let</b> epoch_weights = <a href="_borrow">table::borrow</a>(weights_per_epoch, time);
        <b>if</b> (<a href="_contains">table::contains</a>(epoch_weights, <a href="">pool</a>)) {
            *<a href="_borrow">table::borrow</a>(epoch_weights, <a href="">pool</a>)
        } <b>else</b> { 0 }
    } <b>else</b> { 0 }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal"></a>

## Function `reset_internal`

Internal function to reset votes

<a id="@Arguments_68"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The mutable reference to the VoterV3 object.
* <code>user</code> - The address of the user who call function.
* <code><a href="">token</a></code> - The address of the nft token to reset votes for.


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal">reset_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, user: <b>address</b>, <a href="">token</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal">reset_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>, user: <b>address</b>, <a href="">token</a>: <b>address</b>) {
    <b>let</b> pool_vote = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>);
    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();
    <b>let</b> total_weight: u64 = 0;

    <b>let</b> votes_table = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>);

    <a href="_for_each_ref">smart_vector::for_each_ref</a>(pool_vote, |pool_address| {
        <b>let</b> <a href="">pool</a> = *pool_address;
        <b>let</b> votes = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(votes_table, <a href="">pool</a>, 0);
        <b>if</b> (*votes &gt; 0) {
            // <b>if</b> <a href="">token</a> last vote is &lt; than epochTimestamp then votes are 0! IF not underflow occur
            <b>let</b> last_voted = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, &0);
            <b>if</b> (last_voted &gt; time) {
                <b>let</b> epoch_weights =
                    <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time);
                <b>let</b> pool_weight =
                    <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(epoch_weights, <a href="">pool</a>, 0);
                //handel underflow
                *pool_weight =
                    <b>if</b> (*pool_weight &gt; *votes) {
                        *pool_weight - *votes
                    } <b>else</b> { 0 };
            };

            // Withdraw votes from bribes
            <b>let</b> gauge = <a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>);

            // only <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> can call this function
            <b>let</b> voter_singer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_withdraw">bribe::withdraw</a>(
                &voter_singer,
                <a href="">pool</a>,
                <a href="">token</a>,
                *votes
            );

            // <b>if</b> is alive remove _votes, <b>else</b> don't because we already done it in <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_kill_gauge">kill_gauge</a>()
            <b>if</b> (*<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, *gauge)) {
                total_weight = total_weight + *votes;
            };

            // Emit Abstained <a href="">event</a>
            <a href="_emit">event::emit</a>(
                <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_AbstainedEvent">AbstainedEvent</a> {
                    <a href="">pool</a>,
                    gauge: *gauge,
                    user,
                    <a href="">token</a>,
                    weight: *votes,
                    <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>(),
                    epoch: last_voted - 1
                }
            );

            //handel underflow
            *votes = <b>if</b> (*votes &gt; *votes) {
                *votes - *votes
            } <b>else</b> { 0 };
        };
    });

    // <b>if</b> <a href="">token</a> last vote is &lt; than epochTimestamp then _totalWeight is 0! IF not underflow occur
    <b>if</b> (*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.last_voted, <a href="">token</a>, &0) &lt; time) {
        total_weight = 0;
    };

    <b>let</b> total_weights = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, time, 0);
    *total_weights = *total_weights - total_weight;

    // Clear pool_vote
    <a href="_clear">smart_vector::clear</a>(pool_vote);
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal"></a>

## Function `create_gauge_internal`

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code>: Voter resource
* <code>owner</code>: The owner of the voter
* <code><a href="">pool</a></code>: LP address


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal">create_gauge_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, owner: &<a href="">signer</a>, <a href="">pool</a>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_create_gauge_internal">create_gauge_internal</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>,
    owner: &<a href="">signer</a>,
    <a href="">pool</a>: <b>address</b>
) {
    //check <b>if</b> <a href="">pool</a> is whitelisted or not
    //we converted <a href="">token</a> whitelist <b>to</b> <a href="">pool</a> whitelist
    <b>assert</b>!(*<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_whitelisted, <a href="">pool</a>, &<b>false</b>), <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_NOT_WHITELISTED">ERROR_POOL_NOT_WHITELISTED</a>);

    <b>let</b> gauge_i = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, <a href="">pool</a>, &@0x0);
    <b>assert</b>!(
        gauge_i != @0x0 && !<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge_i),
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_GAUGE_ALREADY_EXIST_FOR_POOL">ERROR_GAUGE_ALREADY_EXIST_FOR_POOL</a>
    );
    <b>let</b> owner_address = address_of(owner);

    <b>let</b> voter_signer = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);

    //get the same <b>address</b> which create <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> function generate for external <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> for store in external_bribes
    <b>let</b> expected_external_bribe_address = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_external_bribe_address">get_external_bribe_address</a>(<a href="">pool</a>);

    //created gauge for lp <a href="">pool</a> <b>address</b> assign <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> <b>as</b> a distribution
    <b>let</b> distribution = address_of(&voter_signer);

    <b>let</b> gauge_type = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauge_to_type, gauge_i);

    <b>let</b> gauge: <b>address</b> =
        <b>if</b> (gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>) {
            <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_create_gauge">gauge_clmm::create_gauge</a>(
                distribution,
                expected_external_bribe_address,
                <a href="">pool</a>
            )
        } <b>else</b> <b>if</b> (gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>) {
            <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_create_gauge">gauge_cpmm::create_gauge</a>(
                distribution,
                expected_external_bribe_address,
                <a href="">pool</a>,
            )
        } <b>else</b> {
            <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_create_gauge">gauge_perp::create_gauge</a>(
                distribution,
                expected_external_bribe_address,
                <a href="">pool</a>,
            )
        };

    //create <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> and assign <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> <a href="">signer</a> <b>as</b> a <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> of <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a>
    //TODO:Check need <b>to</b> go <b>with</b> current methodology or user other
    <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_create_bribe">bribe::create_bribe</a>(&voter_signer, address_of(&voter_signer), <a href="">pool</a>, gauge);

    //save data
    //<b>update</b> external <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe">bribe</a> for gauge
    <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.external_bribes, gauge, expected_external_bribe_address);

    //<b>update</b> gauge for <a href="">pool</a>
    <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_for_gauge, gauge, <a href="">pool</a>);

    <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge, <b>true</b>);

    <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge, <b>true</b>);

    // add <a href="">pool</a> <b>to</b> existing <a href="">pool</a> list
    <a href="_push_back">smart_vector::push_back</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pools, <a href="">pool</a>);

    //<b>update</b> index
    // new gauges are set <b>to</b> the default <b>global</b> state

    <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.supply_index, gauge, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.index);

    <a href="_emit">event::emit</a>(
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_GaugeCreatedEvent">GaugeCreatedEvent</a> {
            gauge,
            creator: owner_address,
            <a href="">pool</a>,
            external_bribe: expected_external_bribe_address,
            gauge_type
        }
    )
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal"></a>

## Function `distribute_internal`

Internal function to distribute rewards for a specific gauge


<a id="@Arguments_69"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The Voter resource.
* <code>distribution</code> - The signer authorized to distribute rewards.
* <code>gauge</code> - The address of the gauge for which rewards are to be distributed.
* <code>gauge_type</code> - The gauge tye <code>CPMM = 0 & CLMM = 1</code> .


<a id="@Dev_70"></a>

### Dev

This function is called by the distribute_all, distribute_range, and distribute_gauges functions.


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal">distribute_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, distribution: &<a href="">signer</a>, gauge: <b>address</b>, gauge_type: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_distribute_internal">distribute_internal</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>,
    distribution: &<a href="">signer</a>,
    gauge: <b>address</b>,
    gauge_type: u8
) {
    <b>let</b> last_timestamp =
        *<a href="_borrow_with_default">table::borrow_with_default</a>(
            &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges_distribution_timestamp, gauge, &0
        );

    <b>let</b> current_timestamp = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();

    <b>if</b> (last_timestamp &lt; current_timestamp) {
        // should set claimable <b>to</b> 0 <b>if</b> killed
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_for_after_distribution">update_for_after_distribution</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, gauge);

        <b>let</b> claimable = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.claimable, gauge, 0);
        <b>if</b> (*claimable &lt;= 0) {
            <b>return</b>
        };

        <b>let</b> is_alive = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge);
        // distribute only <b>if</b> claimable is &gt; 0, currentEpoch != last epoch and gauge is alive
        <b>if</b> (*claimable &gt; 0 && is_alive) {
            <a href="_emit">event::emit</a>(
                <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DistributeRewardEvent">DistributeRewardEvent</a> {
                    sender: address_of(distribution),
                    gauge,
                    amount: *claimable,
                    ecpoh: <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() - <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>,
                    <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>()
                }
            );

            // type based gauge notify dxlyn <a href="emission.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_emission">emission</a> reward <b>to</b> gauge
            <b>if</b> (gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CLMM_POOL">CLMM_POOL</a>) {
                <a href="gauge_clmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_clmm_notify_reward_amount">gauge_clmm::notify_reward_amount</a>(distribution, gauge, *claimable);
            } <b>else</b> <b>if</b> (gauge_type == <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_CPMM_POOL">CPMM_POOL</a>) {
                <a href="gauge_cpmm.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_cpmm_notify_reward_amount">gauge_cpmm::notify_reward_amount</a>(distribution, gauge, *claimable);
            } <b>else</b> {
                <a href="gauge_perp.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_gauge_perp_notify_reward_amount">gauge_perp::notify_reward_amount</a>(distribution, gauge, *claimable);
            };

            *claimable = 0;
            <a href="_upsert">table::upsert</a>(
                &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges_distribution_timestamp,
                gauge,
                current_timestamp
            );
        }
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal"></a>

## Function `vote_internal`

Internal function to get the vote for a specific pool

<a id="@Arguments_71"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The mutable reference to the VoterV3 object.
* <code>user</code> - The address of the user who call function.
* <code><a href="">token</a></code> - The address of the token from vote to submit.
* <code><a href="">pool</a></code> - The address of the pool to get the vote for.
* <code>weights</code> - The weights vector to store the weights for each pool.


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal">vote_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, user: <b>address</b>, <a href="">token</a>: <b>address</b>, pool_vote: <a href="">vector</a>&lt;<b>address</b>&gt;, weights: <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_vote_internal">vote_internal</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>,
    user: <b>address</b>,
    <a href="">token</a>: <b>address</b>,
    pool_vote: <a href="">vector</a>&lt;<b>address</b>&gt;,
    weights: <a href="">vector</a>&lt;u64&gt;
) {
    //Rest the previous vote before cast new one
    <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>)) {
        <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_reset_internal">reset_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, user, <a href="">token</a>);
    };
    //get current voting power
    <b>let</b> weight = <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_balance_of">voting_escrow::balance_of</a>(<a href="">token</a>, <a href="_now_seconds">timestamp::now_seconds</a>());
    <b>let</b> total_vote_weight = 0;
    <b>let</b> total_weight = 0;
    <b>let</b> used_weight = 0;
    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>();

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pool_vote, |index, <a href="">pool</a>| {
        <b>let</b> gauge = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, *<a href="">pool</a>);
        <b>let</b> is_alive = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge, &<b>false</b>);
        // Check <b>if</b> the gauge is alive and is a gauge alive add weight <b>to</b> the total vote weight other wise skip
        <b>if</b> (is_alive) {
            <b>let</b> weight_to_pool = *<a href="_borrow">vector::borrow</a>(&weights, index);
            total_vote_weight = total_vote_weight + weight_to_pool;
        }
    });

    <b>assert</b>!(total_vote_weight &gt; 0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO">ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO</a>);

    <a href="_enumerate_ref">vector::enumerate_ref</a>(&pool_vote, |index, <a href="">pool</a>| {
        <b>let</b> gauge = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.gauges, *<a href="">pool</a>);
        <b>let</b> is_gauge = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_gauge, gauge, &<b>false</b>);
        <b>let</b> is_alive = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge, &<b>false</b>);

        <b>if</b> (is_gauge && is_alive) {
            <b>let</b> weight_to_pool = *<a href="_borrow">vector::borrow</a>(&weights, index);

            // Weight <b>to</b> assign <b>to</b> the <a href="">pool</a>
            // used <a href="">u256</a> because of overflow (10^12 * 10^12) / (10^12)
            // case : when user vote and trying <b>to</b> poke same vote <b>to</b> next week that time weight_to_pool and total_vote_weight is in form of 10^12 for it will overflow
            <b>let</b> safe_pool_weight_calc: <a href="">u256</a> =
                (weight_to_pool <b>as</b> <a href="">u256</a>) * (weight <b>as</b> <a href="">u256</a>)
                    / (total_vote_weight <b>as</b> <a href="">u256</a>);
            <b>let</b> pool_weight = (safe_pool_weight_calc <b>as</b> u64);
            <b>assert</b>!(pool_weight &gt; 0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO">ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO</a>);

            //get <a href="">pool</a> votes for caller
            <b>let</b> votes = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal">get_vote_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="">token</a>, *<a href="">pool</a>);

            //<b>if</b> vote found on the <a href="">pool</a> then <b>assert</b> (need <b>to</b> reset first)
            <b>assert</b>!(votes == 0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_VOTE_FOUND">ERROR_VOTE_FOUND</a>);
            <b>assert</b>!(pool_weight &gt; 0, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO">ERROR_POOL_WEIGHT_CAN_NOT_BE_ZERO</a>);

            //add the new <a href="">pool</a> <b>to</b> users pool_vote
            //<b>if</b> <a href="">token</a> <b>has</b> no <a href="">pool</a> vote then add the new <a href="">pool</a>
            <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>)) {
                <b>let</b> pools = <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>);
                <a href="_push_back">smart_vector::push_back</a>(pools, *<a href="">pool</a>);
            } <b>else</b> {
                <b>let</b> pools = <a href="_new">smart_vector::new</a>&lt;<b>address</b>&gt;();
                <a href="_push_back">smart_vector::push_back</a>(&<b>mut</b> pools, *<a href="">pool</a>);
                <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_vote, <a href="">token</a>, pools);
            };

            // Update the weights per epoch
            // <b>if</b> weight not found for time add new time and assign <a href="">pool</a> weight
            <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time)) {
                <b>let</b> weight_per_epochs =
                    <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time);
                <b>let</b> epoch_weight =
                    <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(weight_per_epochs, *<a href="">pool</a>, 0);
                *epoch_weight = *epoch_weight + pool_weight;
            } <b>else</b> {
                <b>let</b> weight_per_epochs = <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;();
                <a href="_add">table::add</a>(&<b>mut</b> weight_per_epochs, *<a href="">pool</a>, pool_weight);
                <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time, weight_per_epochs);
            };

            // Update the <a href="">token</a> <a href="">pool</a> weight
            <b>if</b> (<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>)) {
                <b>let</b> pool_weights =
                    <a href="_borrow_mut">table::borrow_mut</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>);
                <b>let</b> pool_weight_i =
                    <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(pool_weights, *<a href="">pool</a>, 0);
                *pool_weight_i = *pool_weight_i + pool_weight;
            } <b>else</b> {
                <b>let</b> pool_weights = <a href="_new">table::new</a>&lt;<b>address</b>, u64&gt;();
                <a href="_add">table::add</a>(&<b>mut</b> pool_weights, *<a href="">pool</a>, pool_weight);
                <a href="_add">table::add</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>, pool_weights);
            };

            // only <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> can call this function
            <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
            <a href="bribe.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_bribe_deposit">bribe::deposit</a>(
                &<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>,
                *<a href="">pool</a>,
                <a href="">token</a>,
                pool_weight
            );

            used_weight = used_weight + pool_weight;
            total_weight = total_weight + pool_weight;

            <a href="_emit">event::emit</a>(
                <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_VotedEvent">VotedEvent</a> {
                    <a href="">pool</a>: *<a href="">pool</a>,
                    gauge,
                    user,
                    <a href="">token</a>,
                    weight: pool_weight,
                    <a href="">timestamp</a>: <a href="_now_seconds">timestamp::now_seconds</a>(),
                    epoch: time
                }
            );
        }
    });

    <b>if</b> (used_weight &gt; 0) {
        <b>let</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.extended_ref);
        // Call abstain on voting escrow
        // only <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a> can call this function
        <a href="voting_escrow.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voting_escrow_voting">voting_escrow::voting</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>, <a href="">token</a>);
    };

    <b>let</b> total_weights_per_epoch =
        <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.total_weights_per_epoch, time, 0);
    *total_weights_per_epoch = *total_weights_per_epoch + total_weight;
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_for_after_distribution"></a>

## Function `update_for_after_distribution`

Update info for gauges


<a id="@Arguments_72"></a>

### Arguments

* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The Voter resource.
* <code>gauge</code> - The address of the gauge to update.

<a id="@Dev_73"></a>

### Dev

This function track the gauge index to emit the correct DXLYN amount after the distribution


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_for_after_distribution">update_for_after_distribution</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, gauge: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_update_for_after_distribution">update_for_after_distribution</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>, gauge: <b>address</b>
) {
    <b>let</b> <a href="">pool</a> = <a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.pool_for_gauge, gauge);
    <b>let</b> time = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_epoch_timestamp">epoch_timestamp</a>() - <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_WEEK">WEEK</a>;
    <b>let</b> supplied = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_weights_per_epoch_internal">weights_per_epoch_internal</a>(
        &<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.weights_per_epoch, time, *<a href="">pool</a>
    );

    <b>if</b> (supplied &gt; 0) {
        <b>let</b> supply_index = *<a href="_borrow_with_default">table::borrow_with_default</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.supply_index, gauge, &0);
        // get <b>global</b> index0 for accumulated distro
        <b>let</b> index = <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.index;
        // <b>update</b> gauge current position <b>to</b> <b>global</b> position
        <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.supply_index, gauge, index);

        // see <b>if</b> there is <a href="">any</a> difference that need <b>to</b> be accrued
        <b>let</b> delta = index - supply_index;

        <b>if</b> (delta &gt; 0) {
            // add accrued difference for each supplied <a href="">token</a>
            // <b>use</b> <a href="">u256</a> <b>to</b> avoid overflow in case of large numbers
            <b>let</b> share = ((supplied <b>as</b> <a href="">u256</a>) * (delta <b>as</b> <a href="">u256</a>) / (<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_DXLYN_DECIMAL">DXLYN_DECIMAL</a> <b>as</b> <a href="">u256</a>) <b>as</b> u64);

            <b>let</b> is_alive = *<a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.is_alive, gauge);
            <b>if</b> (is_alive) {
                <b>let</b> claimable = <a href="_borrow_mut_with_default">table::borrow_mut_with_default</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.claimable, gauge, 0);
                *claimable = *claimable + share;
            }
        }
    } <b>else</b> {
        // new users are set <b>to</b> the default <b>global</b> state
        <a href="_upsert">table::upsert</a>(&<b>mut</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.supply_index, gauge, <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.index);
    }
}
</code></pre>



</details>

<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal"></a>

## Function `get_vote_internal`

Returns the vote for a given pool.
* <code><a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a></code> - The Voter resource.
* <code>caller_address</code> - The address of the user.
* <code><a href="">pool</a></code> - Address used to identify the vote.


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal">get_vote_internal</a>(<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">voter::Voter</a>, <a href="">token</a>: <b>address</b>, <a href="">pool</a>: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_get_vote_internal">get_vote_internal</a>(
    <a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>: &<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter_Voter">Voter</a>, <a href="">token</a>: <b>address</b>, <a href="">pool</a>: <b>address</b>
): u64 {
    <b>if</b> (!<a href="_contains">table::contains</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>)) {
        <b>return</b> 0
    };

    <b>let</b> votes_table = <a href="_borrow">table::borrow</a>(&<a href="voter.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_voter">voter</a>.votes, <a href="">token</a>);
    *<a href="_borrow_with_default">table::borrow_with_default</a>(votes_table, <a href="">pool</a>, &0)
}
</code></pre>



</details>
