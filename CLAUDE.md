# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Dexlyn tokenomics smart contract system built on Aptos/Supra Move. It implements a ve(3,3) tokenomics model with voting escrow, gauges, emissions, and fee distribution mechanisms.

**Core Components:**
- `DexlynCoin` - Main DXLYN token (fungible asset)
- `DexlynTokenomics` - Main tokenomics package containing voting, gauges, and distribution logic

## Build & Test Commands

### Building
```bash
# Build main tokenomics package
aptos move compile

# Build DexlynCoin separately
cd dexlyn_coin && aptos move compile
```

### Testing
```bash
# Run all tests
aptos move test

# Run specific test file
aptos move test --filter <test_name>

# Run tests with coverage
aptos move test --coverage
```

### Local Development Setup

For local testing, you must add this function to your Supra Framework at `/aptos-move/framework/supra-framework/sources/block.move`:

```move
#[test_only]
public fun update_block_number(new_block_number: u64) acquires BlockResource {
    let block = borrow_global_mut<BlockResource>(@supra_framework);
    block.height = new_block_number;
}
```

## Architecture Overview

### Tokenomics Flow

1. **Voting Escrow (`voting_escrow.move`)**: Users lock DXLYN tokens to receive veNFTs representing voting power. Lock duration (up to 4 years) determines voting power which decays linearly over time.

2. **Voter (`voter.move`)**: Central coordinator managing gauges for three pool types:
   - CPMM (Constant Product Market Maker)
   - CLMM (Concentrated Liquidity Market Maker)
   - DXLP (Perpetual DEX pools)

   Users vote with their veNFTs to direct emissions to different pools.

3. **Emission (`emission.move`)**: Controls token emission schedule with decay rate applied weekly. Emissions are distributed to gauges based on voting weights.

4. **Minter (`minter.move`)**: Handles DXLYN token minting based on emission schedule.

5. **Gauges** (`gauge_cpmm.move`, `gauge_clmm.move`, `gauge_perp.move`): Pool-specific reward distribution contracts. Users stake LP tokens to earn DXLYN rewards proportional to their share.

6. **Bribe (`bribe.move`)**: External parties can add bribe rewards to incentivize votes for specific gauges.

7. **Fee Distributor (`fee_distributor.move`)**: Distributes protocol fees (trading fees) to veNFT holders proportional to their voting power.

8. **Vesting (`vesting.move`)**: Manages token vesting schedules for team/investors with customizable cliffs and durations.

### Key Invariants & Time Constants

- **WEEK**: 604800 seconds (7 days) - fundamental epoch duration
- **MAXTIME**: 126144000 seconds (4 years) - maximum lock duration
- **EPOCH**: Emissions and distributions happen on weekly epochs
- Lock times are always rounded down to nearest week

### Address Configuration

All privileged addresses are configured in `Move.toml`:
- `owner`: Contract owner with admin privileges
- `vesting_admin`: Controls vesting schedules
- `emission_admin`: Manages emission parameters
- `voter_admin`: Manages voter settings
- `voter_governance`: Governance-controlled voter operations
- `voting_escrow_admin`: Voting escrow administrative functions

### Dependencies

**External:**
- SupraFramework (Supra's Aptos fork)
- AptosTokenObjects (NFT functionality for veNFTs)
- dexlyn_swap (CPMM pools)
- DexlynClmm (CLMM pools)
- dexlyn-perp-trade (Perpetual DEX pools)

**Local:**
- DexlynCoin (in `./dexlyn_coin`)
- dexlyn_perp_dex (in `./dexlyn_perp_dex`)

### Critical State Management

**Checkpointing**: The system uses historical checkpointing to track:
- Global voting power over time (`voting_escrow.move`)
- Per-gauge weights over time (`voter.move`)
- Per-user locked balances over time

**Epoch-based Operations**: Most operations are epoch-aware:
- Rewards are calculated per epoch
- Votes can only be changed after vote delay period
- Emissions decay weekly

## Testing Structure

Tests are located in `/tests` and cover:
- Individual module functionality (e.g., `voting_escrow_test.move`)
- Integration scenarios (e.g., `voter_cpmm_test.move`)
- Common test utilities (`voter_common.move`, `test_coins.move`)
- Library tests (`i64_test.move`)

## Security Considerations

This is an audit codebase. When working with this code:

1. **Privileged Operations**: Many functions require specific admin roles. Check address requirements in function assertions.

2. **Friend Modules**: Several modules use `friend` declarations to restrict access (e.g., gauges are friends of voter).

3. **Time Manipulation**: Tests may need to advance block number and timestamp to simulate epoch progression.

4. **Precision & Overflow**: The code uses scaling factors (MULTIPLIER, PRECISION, AMOUNT_SCALE) to maintain precision. Be careful with arithmetic operations.

5. **NFT-based Ownership**: veNFTs represent ownership of locked positions. NFT transfers affect voting power and reward claims.

## Audit Scope

The files under audit are listed in `scope.txt`. Key audit considerations from `.cursor/rules/audit-scope.mdc`:
- Focus on code logic correctness, permission boundaries, state consistency
- Assume attacker has full control of their on-chain account
- Privileged role operations are not vulnerabilities unless they cause unintended loss
- Core invariants must hold during active protocol period
- State transitions during migrations may temporarily violate invariants by design

## Documentation

Module documentation is available in `/doc` directory with detailed API references for each module.
