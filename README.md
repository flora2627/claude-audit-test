# Dexlyn Tokenomics

## Overview

This repository contains the smart contracts for the Dexlyn tokenomics system, organized into three main components:

## Dexlyn Coin

- [Dxlyn Coin](./dexlyn_coin/doc/dxlyn_coin.md) - The main utility and governance token of the Dexlyn ecosystem

## VeTokenomics

- [Voting Escrow](./dexlyn_tokenomics/doc/voting_escrow.md) - Manages DXLYN token staking and voting power
- [Fee Distributor](./dexlyn_tokenomics/doc/fee_distributor.md) - Distributes DXLYN token fee rewards
- [Base64](./dexlyn_tokenomics/doc/base64.md) - Encodes and decodes base64 strings
- [I64](./dexlyn_tokenomics/doc/i64.md) - Encodes and decodes 64-bit integers

## DexlynTokenomics

- [Voter](./doc/voter.md) - Handles voting and gauge weight management
- [Bribe](./doc/bribe.md) - Manages bribe distribution for gauges
- [Emission](./doc/emission.md) - Controls token emission and distribution
- [Gauge CPMM](./doc/gauge_cpmm.md) - Gauge implementation for Constant Product Market Makers
- [Gauge CLMM](./doc/gauge_clmm.md) - Gauge implementation for Concentrated Liquidity Market Makers
- [Minter](./doc/minter.md) - Handles DEXLYN token minting
- [Vesting](./doc/vesting.md) - Manages token vesting schedules

## Development

### Local Testing

For local testing, add this function to your Supra Framework:

Path: `/aptos-move/framework/supra-framework/sources/block.move`

```move
#[test_only]
public fun update_block_number(new_block_number: u64) acquires BlockResource {
let block = borrow_global_mut<BlockResource>(@supra_framework);
block.height = new_block_number;
}
```

