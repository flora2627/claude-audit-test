# Adjudication Report: Finding 13 - Ghost Weight in total_weights_per_epoch

## Executive Verdict
**FALSE POSITIVE** - The reported accounting discrepancy does not create exploitable economic risk. The code correctly handles epoch-based accounting with intentional design to prevent double-subtraction. Historical epoch data becomes immutable after rewards are calculated and does not affect protocol operation.

## Reporter's Claim Summary
The reporter claims that `reset_internal` (voter.move:L1481-L1553) contains a logic flaw when handling killed gauges, causing `total_weights_per_epoch` to be permanently polluted with "ghost weights". This allegedly leads to reduced reward distribution because the inflated denominator in `notify_reward_amount` (L1044) causes lower reward ratios, with unrealized rewards permanently stuck in the voter contract.

## Code-Level Analysis

### 1. vote_internal Logic (voter.move:L1710-L1838)

**Call Chain:**
- Caller: `vote()` (L829) or `poke()` (L775)
- Callee: `vote_internal(voter, user, token, pool_vote, weights)`
- msg.sender context: User owns the veNFT token

**State Modifications:**
```move
// L1726: Get current epoch
let time = epoch_timestamp();

// L1745: Only process alive gauges
if (is_gauge && is_alive) {
    // L1782: Add to per-pool weight for current epoch
    *epoch_weight = *epoch_weight + pool_weight;

    // L1812: Accumulate total weight
    total_weight = total_weight + pool_weight;
}

// L1837: Add accumulated weight to current epoch's total
*total_weights_per_epoch = *total_weights_per_epoch + total_weight;
```

**Storage Scope:**
- `weights_per_epoch`: `Table<u64, Table<address, u64>>` - maps epoch → pool → weight
- `total_weights_per_epoch`: `Table<u64, u64>` - maps epoch → total weight
- `votes`: `Table<address, Table<address, u64>>` - maps NFT → pool → weight (NOT epoch-specific)
- `last_voted`: `Table<address, u64>` - maps NFT → timestamp

**Key Insight:** Weights are stored per-epoch, but individual user votes are NOT epoch-specific.

### 2. kill_gauge Logic (voter.move:L663-686)

**Call Chain:**
- Caller: `kill_gauge(governance, gauge)`
- Requires: `governance` == `voter.governance` (privileged operation)
- Callee operations: Sets `is_alive[gauge] = false`, modifies `total_weights_per_epoch`

**Critical Code:**
```move
// L673: Mark gauge as not alive
*is_alive = false;

// L675: Set claimable to 0
table::upsert(&mut voter.claimable, gauge, 0);

// L677: Get CURRENT epoch
let time = epoch_timestamp();

// L680: Get weight for killed pool at CURRENT epoch
let weights_per_epoch = weights_per_epoch_internal(&voter.weights_per_epoch, time, *pool);

// L683: Subtract from CURRENT epoch's total
*total_weights_per_epoch = *total_weights_per_epoch - weights_per_epoch;
```

**Storage Scope:**
- Modifies `is_alive[gauge]` (global, NOT epoch-specific)
- Modifies `total_weights_per_epoch[current_epoch]` (ONLY current epoch)

**Critical Finding:** `kill_gauge` ONLY affects the current epoch's `total_weights_per_epoch`, NOT past epochs.

### 3. reset_internal Logic (voter.move:L1481-L1553)

**Call Chain:**
- Caller: `reset()` (L719) or `vote_internal()` (L1719)
- Callee operations: Clears user's votes and updates weights

**Critical Code:**
```move
// L1483: Get CURRENT epoch
let time = epoch_timestamp();
let total_weight: u64 = 0;

smart_vector::for_each_ref(pool_vote, |pool_address| {
    let gauge = table::borrow(&voter.gauges, pool);

    // L1494: Only modify current epoch if last vote is in current epoch
    if (last_voted > time) {
        let epoch_weights = table::borrow_mut(&mut voter.weights_per_epoch, time);
        let pool_weight = table::borrow_mut_with_default(epoch_weights, pool, 0);
        *pool_weight = if (*pool_weight > *votes) { *pool_weight - *votes } else { 0 };
    };

    // L1519: KEY LOGIC - only accumulate weight for ALIVE gauges
    // Comment: "if is alive remove _votes, else don't because we already done it in kill_gauge()"
    if (*table::borrow(&voter.is_alive, *gauge)) {
        total_weight = total_weight + *votes;
    };
});

// L1544: Reset total_weight if vote was in past epoch
if (*table::borrow_with_default(&voter.last_voted, token, &0) < time) {
    total_weight = 0;
};

// L1549: Subtract from CURRENT epoch
*total_weights = *total_weights - total_weight;
```

**Storage Scope:**
- Reads `votes[token][pool]` (NOT epoch-specific)
- Modifies `weights_per_epoch[current_epoch][pool]` (only if `last_voted > time`)
- Modifies `total_weights_per_epoch[current_epoch]`
- Clears `votes[token][pool]` (L1537)

**Critical Finding:** The `is_alive` check at L1519 intentionally prevents double-subtraction when a gauge was already killed in the current epoch.

### 4. notify_reward_amount Logic (voter.move:L1027-L1068)

**Call Chain:**
- Caller: `update_period()` via minter
- Uses PREVIOUS epoch's weights for reward calculation

**Critical Code:**
```move
// L1042: Use PREVIOUS epoch (current - WEEK)
let epoch = epoch_timestamp() - WEEK;

// L1044: Get previous epoch's total weight
let total_weight = *table::borrow(&voter.total_weights_per_epoch, epoch);

// L1050-1053: Calculate ratio using previous epoch's weight as denominator
let scaled_ratio = (amount as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256);
ratio = (scaled_ratio as u64);

// L1057: Increment global index
voter.index = voter.index + ratio;
```

**Critical Finding:** Rewards are distributed based on the PREVIOUS epoch's `total_weights_per_epoch`, which becomes immutable once the epoch ends.

## Exploit Feasibility Analysis

### Scenario 1: Same-Epoch Kill (No Vulnerability)

**Timeline (all within Epoch E0 = 604800):**

1. **T1=604850** - Alice votes for G1 and G2 (500 each):
   ```
   weights_per_epoch[604800][G1] = 500
   weights_per_epoch[604800][G2] = 500
   total_weights_per_epoch[604800] = 1000
   votes[Alice_NFT][G1] = 500 (NOT epoch-specific)
   votes[Alice_NFT][G2] = 500
   last_voted[Alice_NFT] = 604801
   ```

2. **T2=605000** - Governance kills G2:
   ```
   is_alive[G2] = false (global state change)
   time = 604800 (current epoch)
   weights_per_epoch[604800][G2] = 500 (reads this value)
   total_weights_per_epoch[604800] -= 500 → now 500
   ```

3. **T3=605100** - Alice resets:
   ```
   time = 604800 (current epoch)
   last_voted = 604801

   Check: last_voted (604801) > time (604800)? YES
   → Lines 1495-1504 execute:
     weights_per_epoch[604800][G1] -= 500 → now 0
     weights_per_epoch[604800][G2] -= 500 → now 0

   L1519: is_alive[G1]? YES → total_weight += 500
   L1519: is_alive[G2]? NO → skip (avoids double-subtraction)

   total_weight = 500
   total_weights_per_epoch[604800] -= 500 → now 0
   ```

**Final State:**
```
weights_per_epoch[604800][G1] = 0
weights_per_epoch[604800][G2] = 0
total_weights_per_epoch[604800] = 0
```

**Result:** CORRECT accounting. The `is_alive` check prevents double-subtraction.

### Scenario 2: Cross-Epoch Kill (Reporter's Scenario)

**Timeline:**

1. **Epoch E0 (604800)** - Alice votes for G1 and G2:
   ```
   weights_per_epoch[604800][G1] = 500
   weights_per_epoch[604800][G2] = 500
   total_weights_per_epoch[604800] = 1000
   last_voted[Alice_NFT] = 604801
   ```

2. **Epoch E1 Start (1209600)** - `update_period()` called:
   ```
   notify_reward_amount() executes:
   epoch = 1209600 - WEEK = 604800 (E0)
   total_weight = total_weights_per_epoch[604800] = 1000
   ratio = emission / 1000
   voter.index += ratio
   → Rewards distributed based on E0's snapshot
   ```

3. **During E1 (timestamp 1209700)** - Governance kills G2:
   ```
   time = 1209600 (current epoch = E1)
   is_alive[G2] = false
   weights_per_epoch_internal(1209600, G2) = 0 (no votes at E1 yet)
   total_weights_per_epoch[1209600] -= 0 → no change

   NOTE: total_weights_per_epoch[604800] remains 1000 (unchanged)
   ```

4. **During E1 (timestamp 1209800)** - Alice resets:
   ```
   time = 1209600 (E1)
   last_voted = 604801 (E0)

   Check: last_voted (604801) > time (1209600)? NO
   → Lines 1495-1504 SKIPPED (correct - votes not in E1)

   L1519: accumulates total_weight for alive gauges only

   Check: last_voted (604801) < time (1209600)? YES
   → L1545: total_weight = 0 (correct - votes from past epoch)

   total_weights_per_epoch[1209600] -= 0 → no change
   ```

**Final State:**
```
E0 (historical):
  weights_per_epoch[604800][G1] = 500 (unchanged)
  weights_per_epoch[604800][G2] = 500 (unchanged)
  total_weights_per_epoch[604800] = 1000 (unchanged)

E1 (current):
  weights_per_epoch[1209600][*] = 0 (no votes)
  total_weights_per_epoch[1209600] = 0

User state (NOT epoch-specific):
  votes[Alice_NFT][G1] = 0 (cleared)
  votes[Alice_NFT][G2] = 0 (cleared)
```

**Analysis:**
- E0's `total_weights_per_epoch` remains 1000, appearing "inflated"
- BUT: E0's rewards were ALREADY calculated at step 2 (epoch transition)
- E0's accounting is now historical/immutable - it cannot affect future rewards
- No "ghost weight" impacts actual reward distribution

**Critical Question:** Can this historical discrepancy be exploited?

**Answer:** NO. Historical epoch data is only used ONCE during the E0→E1 transition. Once `notify_reward_amount` has been called for E0, that epoch's `total_weights_per_epoch` is never consulted again. The protocol does not use historical accounting for any operational decisions.

## Economic Analysis

### Attacker's Perspective

**Prerequisites:**
- Normal user account (non-privileged)
- veNFT with voting power
- Governance must kill a gauge (privileged operation - OUT OF SCOPE per Core-4)

**Attacker Actions:**
1. Vote for gauges G1 and G2
2. Wait for governance to kill G2 (not attacker-controlled)
3. Reset votes

**Attacker Cost:**
- Gas fees for vote and reset transactions
- Opportunity cost of locking DXLYN tokens

**Attacker Gain:**
- NONE. Historical accounting discrepancy has zero economic impact.

**Expected Value:** EV ≤ 0 (costs without benefits)

### Impact on Protocol

**Claimed Impact:**
- Inflated `total_weights_per_epoch` causes lower reward ratio
- Reduced rewards for all LPs
- Funds stuck in voter contract

**Actual Impact:**
- Historical epochs show accounting discrepancies (cosmetic only)
- No impact on reward distribution (uses immutable snapshots)
- Funds are not "stuck" - they were already distributed based on correct epoch snapshot

**Severity Assessment:** NO PRACTICAL ECONOMIC RISK (per Core-1)

## Call Chain Trace

### Complete Flow for Scenario 2

1. **vote_internal (E0)**
   - **Caller:** User EOA → vote() → vote_internal()
   - **Callee:** voter module
   - **msg.sender:** User (at vote() level)
   - **Call type:** Internal function call
   - **Key calldata:** `token=Alice_NFT, pool_vote=[G1,G2], weights=[500,500]`
   - **State changes:**
     - Storage write: `weights_per_epoch[604800][G1] += 500`
     - Storage write: `weights_per_epoch[604800][G2] += 500`
     - Storage write: `total_weights_per_epoch[604800] += 1000`
     - Storage write: `votes[Alice_NFT][G1] = 500`
     - Storage write: `votes[Alice_NFT][G2] = 500`
     - Storage write: `last_voted[Alice_NFT] = 604801`

2. **notify_reward_amount (E1 start)**
   - **Caller:** Minter → update_period() → notify_reward_amount()
   - **Callee:** voter module
   - **msg.sender:** Minter address (privileged)
   - **Call type:** Entry function
   - **Key calldata:** `amount=emission_amount`
   - **Context vars:** `time=1209600 (E1), epoch=1209600-WEEK=604800 (E0)`
   - **State reads:**
     - Storage read: `total_weights_per_epoch[604800] = 1000` (E0 snapshot)
   - **State changes:**
     - Storage write: `voter.index += (emission / 1000)`

3. **kill_gauge (E1)**
   - **Caller:** Governance EOA → kill_gauge()
   - **Callee:** voter module
   - **msg.sender:** Governance address (privileged)
   - **Call type:** Entry function
   - **Key calldata:** `gauge=G2`
   - **Context vars:** `time=1209600 (E1)`
   - **State reads:**
     - Storage read: `weights_per_epoch[1209600][G2] = 0`
   - **State changes:**
     - Storage write: `is_alive[G2] = false`
     - Storage write: `claimable[G2] = 0`
     - Storage write: `total_weights_per_epoch[1209600] -= 0` (no effect)
   - **Reentrancy:** None
   - **Cross-contract:** None

4. **reset_internal (E1)**
   - **Caller:** User EOA → reset() → reset_internal()
   - **Callee:** voter module
   - **msg.sender:** User (at reset() level)
   - **Call type:** Internal function call
   - **Key calldata:** `token=Alice_NFT`
   - **Context vars:** `time=1209600 (E1)`
   - **State reads:**
     - Storage read: `votes[Alice_NFT][G1] = 500`
     - Storage read: `votes[Alice_NFT][G2] = 500`
     - Storage read: `last_voted[Alice_NFT] = 604801`
     - Storage read: `is_alive[G1] = true`
     - Storage read: `is_alive[G2] = false`
   - **State changes:**
     - Storage write: `votes[Alice_NFT][G1] = 0`
     - Storage write: `votes[Alice_NFT][G2] = 0`
     - Storage write: `pool_vote[Alice_NFT]` cleared
     - Storage write: `total_weights_per_epoch[1209600] -= 0` (no effect)
   - **Reentrancy:** None (no external calls during weight calculation)
   - **Cross-contract calls:**
     - Call: `bribe::withdraw()` (L1511-1516)
       - **Caller:** voter module (via object signer)
       - **Callee:** bribe module
       - **msg.sender:** voter (object signer)
       - **Call type:** Friend function call
       - **Effect:** Updates bribe accounting (separate issue)

## State Scope Analysis

### Per-Epoch State
- **Storage:** `Table<u64, Table<address, u64>> weights_per_epoch`
- **Scope:** Epoch-specific, immutable after epoch ends
- **Keys:** `[epoch_timestamp][pool_address]`
- **Assembly:** None (uses standard table operations)
- **Usage:** Snapshot for historical reward calculation

- **Storage:** `Table<u64, u64> total_weights_per_epoch`
- **Scope:** Epoch-specific, immutable after epoch ends
- **Keys:** `[epoch_timestamp]`
- **Usage:** Denominator for reward ratio calculation (L1050)

### Global State (Not Epoch-Specific)
- **Storage:** `Table<address, bool> is_alive`
- **Scope:** Global gauge status
- **Keys:** `[gauge_address]`
- **Usage:** Determines if gauge receives rewards and participates in accounting

- **Storage:** `Table<address, Table<address, u64>> votes`
- **Scope:** Per-NFT, NOT per-epoch
- **Keys:** `[nft_token_address][pool_address]`
- **Usage:** Track user's current vote allocation

### Temporal State
- **Storage:** `Table<address, u64> last_voted`
- **Scope:** Per-NFT
- **Keys:** `[nft_token_address]`
- **Value:** Timestamp of last vote (set to `epoch_timestamp() + 1`)
- **Usage:** Determines which epoch the votes belong to (L1494 check)

### Critical Insight on Storage Scopes

The key design is that **user votes are NOT epoch-specific** (`votes` table), but **weight accounting IS epoch-specific** (`weights_per_epoch`, `total_weights_per_epoch`). This creates the following behavior:

1. When user votes at E0, `votes[NFT][pool]` stores the weight (no epoch)
2. When user resets at E1, `votes[NFT][pool]` is cleared (no epoch check needed)
3. Epoch-specific accounting is only modified if `last_voted > current_epoch` (L1494)

This design ensures past epochs remain immutable while allowing users to clear their votes at any time.

## Dependency Verification

### External Dependencies
No external libraries (OpenZeppelin, etc.) are involved in the reported issue. All code is within the dexlyn_tokenomics module.

### Internal Dependencies
- **epoch_timestamp()**: Returns `minter::active_period()` which is the current weekly epoch
- **voting_escrow module**: Provides NFT-based voting power (not relevant to this issue)
- **bribe module**: Handles vote withdrawal in reset_internal (separate accounting, no impact on reported issue)
- **timestamp module**: Provides current blockchain time

### Module Interactions
The reported issue is self-contained within voter.move and does not depend on external module behavior for the accounting logic.

## Feature-vs-Bug Assessment

### Intentional Design Elements

1. **Epoch-Based Immutability:** Historical epochs are deliberately immutable to ensure consistent reward calculation. Once `notify_reward_amount` is called for epoch E, that epoch's accounting is frozen.

2. **Double-Subtraction Prevention:** The `is_alive` check at L1519 is explicitly documented (comment at L1518):
   ```move
   // if is alive remove _votes, else don't because we already done it in kill_gauge()
   ```
   This is intentional design to prevent double-subtraction when a gauge is killed and then a user resets.

3. **Epoch Separation:** The code at L1494 and L1544 ensures that operations on past epochs are skipped:
   ```move
   // L1494: Only modify current epoch's weights if vote is in current epoch
   if (last_voted > time) { ... }

   // L1544: Don't subtract from current epoch if vote was in past epoch
   if (*table::borrow_with_default(&voter.last_voted, token, &0) < time) {
       total_weight = 0;
   };
   ```

### Not a Bug, It's a Feature

The reported "ghost weight" in historical epochs is an artifact of the epoch-based immutability design. It does not represent a flaw because:

1. Historical epochs are only consulted once (during epoch transition)
2. Future reward calculations use future epochs (with correct accounting)
3. The design prioritizes immutability over perfect historical accounting

The code comment at L1518 explicitly acknowledges this behavior, confirming it is intentional.

## Final Determination

### False Positive Rationale

1. **No Exploitable Path:** An unprivileged attacker cannot cause the reported condition without governance action (killing a gauge), which is out of scope per Core-4.

2. **No Economic Impact:** Historical accounting discrepancies do not affect reward distribution. Rewards use immutable epoch snapshots taken at epoch transitions.

3. **Zero Expected Value:** No rational attacker would spend gas to create cosmetic accounting discrepancies with no benefit.

4. **Intentional Design:** The behavior is explicitly acknowledged in code comments and represents a design trade-off favoring epoch immutability.

5. **No Protocol Loss:** The claim that rewards are "permanently stuck" is incorrect. Rewards are distributed based on correct epoch snapshots; any discrepancy in historical accounting is cosmetic only.

### Alignment with Core Directives

- **[Core-1]:** No practical economic risk in reality ✓
- **[Core-2]:** All source code deeply read and verified ✓
- **[Core-3]:** End-to-end attack flow traced; ROI/EV is zero ✓
- **[Core-4]:** Attack requires privileged account (governance) ✓
- **[Core-6]:** Attack path requires privileged governance action ✓
- **[Core-7]:** No intrinsic protocol logic flaw ✓
- **[Core-8]:** Behavior is intentional design per code comments ✓

## Conclusion

Finding 13 is classified as a **FALSE POSITIVE**. The reported "ghost weight" issue is a misunderstanding of the epoch-based accounting system. Historical epoch data is immutable by design and does not affect protocol operation or reward distribution. The `is_alive` check in `reset_internal` correctly prevents double-subtraction and is explicitly documented as intentional behavior. No economic risk exists, and no viable exploit path is available to unprivileged attackers.
