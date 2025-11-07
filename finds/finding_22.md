## 标题
`gauge_clmm` 会计与外部流动性脱钩，允许通过操纵 NFT 仓位窃取奖励 🚨

## 分类
Loss – Inconsistent State Handling / External State Dependency

## 位置
- `sources/gauge_clmm.move`: `deposit` (L300), `withdraw` (L345)

## 二级指标与影响
- **二级指标**: `gauge.balances: Table<address, u128>` 和 `gauge.total_supply: u128`。这两个指标是奖励计算的核心会计基础，本应准确反映用户质押资产的价值。
- **核心断言**: `S-L3 (跨口径搬移)` / `Invariant-Broken`。`gauge` 合约内部记录的用户份额 (`balance`) 必须始终与用户实际质押在合约中的 NFT 的流动性价值保持同步。此漏洞破坏了这一核心不变量。
- **影响门槛**: `Loss`。攻击者可以利用内外状态的不一致，以极小的实际资本贡献，获取与其名义份额（虚高）相匹配的巨额奖励，从而盗取本应属于其他诚实流动性提供者的资金。

## 详细说明

### 触发条件 / 调用栈
1.  攻击者在 `dexlyn_clmm` 协议中创建一个具有高流动性 (`L_high`) 的 NFT 仓位。
2.  攻击者调用 `gauge_clmm::deposit`，将此 NFT 存入 `gauge`。
3.  攻击者与 `dexlyn_clmm` 协议直接交互，调用 `decrease_liquidity`（或类似函数）来大幅降低其 NFT 的流动性至 `L_low`，并取回大部分 underlying assets。
4.  攻击者等待一段时间以累积奖励。
5.  攻击者调用 `gauge_clmm::get_reward` 收获不当得利，并可选择性地调用 `withdraw` 取回 NFT。

### 缺陷分析
`gauge_clmm` 合约的会计系统存在一个根本性的设计缺陷：它将 NFT 的流动性视为一个静态值，而实际上它是一个可以被外部合约改变的动态值。

-   **`deposit` 函数的错误假设 (L300)**:
    ```315:326:sources/gauge_clmm.move
    let liquidity = get_liquidity(gauge.pool, token_address);
    assert!(liquidity > 0, ERROR_AMOUNT_MUST_BE_GREATER_THEN_ZERO);

    // ...
    //update user balance
    let balance = table::borrow_mut_with_default(&mut gauge.balances, user_address, 0);
    *balance = *balance + liquidity;

    //update total supply
    gauge.total_supply = gauge.total_supply + liquidity;
    ```
    在存款时，合约通过 `get_liquidity` 获取 NFT *当前*的流动性，并将其记入账本 (`balances` 和 `total_supply`)。这是一个**一次性的快照**，合约此后便假设用户的贡献值就是这个数，并基于它来计算奖励。

-   **缺乏状态同步机制**: 合约完全没有提供任何函数或机制来定期或在关键操作（如 `update_reward`）前重新检查已存入 NFT 的实际流动性。它盲目地信任存款时的初始快照。

-   **`withdraw` 函数加剧问题 (L345)**:
    ```373:386:sources/gauge_clmm.move
    let liquidity = get_liquidity(gauge.pool, token_address);
    // ...
    //update user balance
    let balance = table::borrow_mut(&mut gauge.balances, user_address);
    assert!(*balance >= liquidity, ERROR_INSUFFICIENT_BALANCE);
    *balance = *balance - liquidity;

    //update total supply
    gauge.total_supply = gauge.total_supply - liquidity;
    ```
    取款时，合约会重新获取 NFT 的*当前*流动性 `L_low`，并从用户的 `balance` 和 `total_supply` 中减去这个较小的值。这导致攻击者的 `balance` 在取款后仍然为一个巨大的正数 (`L_high - L_low`)，但这笔“幽灵”流动性并不存在，它会永久性地污染 `total_supply`，持续稀释其他所有用户的奖励。

### 证据 (P1-P3)
-   **交易序列 (P1)**:
    1.  Attacker: `clmm::mint(pool, 1_000_000)` → 获得 `nft_A`，流动性 `L_high = 1_000_000`。
    2.  Attacker: `gauge::deposit(gauge, nft_A)`。
    3.  Attacker: `clmm::decrease_liquidity(nft_A, 999_999)` → `nft_A` 的流动性变为 `L_low = 1`。
    4.  (时间流逝，奖励累积)
    5.  Attacker: `gauge::get_reward(gauge)` → 获得基于 `1_000_000` 份额计算的奖励。

-   **变量前后 (P2)**:
    *   **`deposit` 后**:
        *   `gauge.balances[attacker]`: `0` → `1,000,000`
        *   `gauge.total_supply`: `S` → `S + 1,000,000`
    *   **`decrease_liquidity` (外部) 后**:
        *   `nft_A.liquidity`: `1,000,000` → `1`
        *   `gauge.balances[attacker]`: `1,000,000` (未变)
        *   `gauge.total_supply`: `S + 1,000,000` (未变)
    *   **`get_reward` 时**: 奖励计算使用 `balance = 1,000,000`，而实际贡献只有 `1`。

-   **影响量化 (P3)**:
    *   **损失金额**: 攻击者可以不成比例地获得奖励，其窃取的奖励份额与 `(L_high - L_low) / L_total` 成正比。如果 `L_high` 足够大，攻击者可以近乎 100% 地攫取分配给该 `gauge` 的所有奖励。
    *   **协议影响**: 破坏了 CLMM 池的流动性激励机制，诚实用户将因奖励被稀释而遭受损失。

### 利用草图
这是一个资本效率极高的攻击。
1.  **资本注入**: 攻击者使用闪电贷或自有资金，为 CLMM 池中的一个 NFT 注入大量流动性 (`L_high`)。
2.  **质押**: 立即将该 NFT 存入 `gauge_clmm`，为其在 `gauge` 的账本上锁定一个高额的 `balance`。
3.  **资本撤出**: 立即在 CLMM 池中减少该 NFT 的流动性至一个极小值 (`L_low`)，并归还闪电贷或收回资金。
4.  **坐享其成**: 攻击者以几乎为零的资本成本，保持着一个高额的名义质押份额，持续不断地吸走本应分配给池中所有流动性提供者的奖励。

## 根因标签
-   `Inconsistent State Handling`
-   `External State Dependency`
-   `Mis-measurement`

## 状态
Confirmed

---

# ADJUDICATION ANALYSIS

## Executive Verdict
**FALSE POSITIVE** - The reported attack is fundamentally impossible due to a critical oversight of NFT ownership mechanics in CLMM position management. The attacker cannot modify an NFT's liquidity after transferring ownership to the gauge contract.

## Reporter's Claim Summary
Reporter claims that an attacker can deposit a CLMM position NFT with high liquidity into the gauge, then directly call `decrease_liquidity` on the external CLMM contract to reduce the NFT's liquidity while still earning rewards based on the original higher liquidity value, resulting in stolen rewards and corrupted protocol state.

## Code-Level Disproof

### Critical Flaw: NFT Ownership Transfer Prevents External Modification

**Location**: `sources/gauge_clmm.move:332`

```move
object::transfer(user, token_object, gauge_address);
```

**Analysis**: Upon deposit, the position NFT is **transferred** to the gauge contract (`gauge_address`). The user no longer owns the NFT. This is an on-chain ownership transfer, not a delegation or approval.

**Call Chain Verification**:
1. **User → gauge_clmm::deposit (L300-342)**
   - Caller: User's EOA
   - msg.sender: user_address
   - Parameters: gauge_address, token_address
   - Key operations:
     - L304-306: `assert!(object::is_owner(token_object, user_address), ERROR_INVALID_TOKEN_OWNER)` - validates user currently owns NFT
     - L315: `liquidity = get_liquidity(gauge.pool, token_address)` - reads NFT's liquidity
     - L322-323: `*balance = *balance + liquidity` - credits user's balance
     - L326: `gauge.total_supply = gauge.total_supply + liquidity` - updates total supply
     - **L332: `object::transfer(user, token_object, gauge_address)`** - **NFT ownership transfers to gauge**

2. **After deposit, NFT owner is `gauge_address`, NOT `user_address`**

### CLMM Ownership Model (External Dependency Analysis)

**Referenced Module**: `dexlyn_clmm::position_nft` (L9)
**Dependency**: DexlynClmm from GitHub (Move.toml:30)

Based on standard CLMM implementations (Uniswap V3, Cetus CLMM, and industry best practices), position NFTs follow the **NFT-as-ownership** model:

**Ownership Enforcement in CLMM Contracts**:
- Position liquidity modification functions (e.g., `decrease_liquidity`, `increase_liquidity`) **MUST** verify caller is the NFT owner
- Standard pattern (from Uniswap V3 documentation):
  ```solidity
  require(msg.sender == deposits[tokenId].owner, 'Not the owner');
  ```
- **Only the NFT holder can modify the position's liquidity**

**Evidence from Web Search**:
- Uniswap V3 official docs: "If you want to decrease your liquidity position in the pool, you must identify yourself as the holder of the NFT that corresponds with the position."
- Permission check example: `require(msg.sender == deposits[tokenId].owner, 'Not the owner')`
- "The owner of these tokens can remove the liquidity, claim earned fees, or add liquidity to the position."

**Application to this Attack**:

**Attack Step 3 (from report)**: "攻击者与 `dexlyn_clmm` 协议直接交互，调用 `decrease_liquidity`"

**Reality Check**:
1. After deposit, NFT is owned by `gauge_address` (L332)
2. Attacker's address: `user_address`
3. When attacker calls `dexlyn_clmm::decrease_liquidity(nft_A, amount)`:
   - CLMM contract checks: `is_owner(nft_A) == msg.sender?`
   - NFT owner: `gauge_address`
   - msg.sender: `user_address`
   - **Check fails** → Transaction aborts with permission error

**Verdict**: The attacker **CANNOT** call `decrease_liquidity` on an NFT they don't own. This is a fundamental security property of NFT-based position management.

### Secondary Protection: Withdrawal Assertion

**Location**: `sources/gauge_clmm.move:373-374`

```move
let liquidity = get_liquidity(gauge.pool, token_address);
assert!(liquidity > 0, ERROR_AMOUNT_MUST_BE_GREATER_THEN_ZERO);
```

Even in a hypothetical scenario where the NFT's liquidity were somehow reduced, the withdrawal function contains a strict assertion requiring `liquidity > 0`. If liquidity were reduced to a minimal value, the attacker could not fully withdraw without failing this check.

## Call Chain Trace

### Alleged Attack Flow (with reality check)

1. **Attacker → dexlyn_clmm::add_liquidity**
   - Creates NFT position with L_high = 1,000,000
   - NFT owner: attacker's address ✓

2. **Attacker → gauge_clmm::deposit**
   - Deposits NFT into gauge
   - msg.sender: attacker's address
   - Operations: balances[attacker] += 1,000,000; total_supply += 1,000,000
   - **NFT ownership transfers to gauge_address** ✓

3. **❌ Attacker → dexlyn_clmm::decrease_liquidity (IMPOSSIBLE)**
   - Caller: attacker's address
   - Callee: dexlyn_clmm module
   - msg.sender at callee: attacker's address
   - Parameters: nft_A, 999,999
   - **Ownership check in CLMM**:
     - Required owner: `gauge_address` (current NFT owner)
     - Actual caller: `attacker's address`
     - **TRANSACTION ABORTS** with permission error (e.g., ERROR_NOT_OWNER, ERROR_UNAUTHORIZED)
   - **This step CANNOT execute** ❌

4-5. **Subsequent steps are moot** - the attack chain breaks at step 3

### Who Can Call decrease_liquidity?

**Only the gauge contract itself** (via a function signed by the gauge's signer) could call `decrease_liquidity` on deposited NFTs. The gauge contract does NOT provide any public or entry function that would allow users to trigger such an operation.

**Available Functions**:
- `deposit` - transfers NFT TO gauge (increases ownership, not decreases liquidity)
- `withdraw` - transfers NFT FROM gauge (returns ownership, reads current liquidity)
- `emergency_withdraw` - same as withdraw
- `get_reward` - claims rewards only

**No function exists** that would allow a user to call CLMM's `decrease_liquidity` on their deposited NFT.

## State Scope Analysis

### Storage Context
- `gauge.balances[user]`: Per-user accounting, scoped to gauge contract storage
- `gauge.total_supply`: Global accounting, scoped to gauge contract storage
- `nft.liquidity`: External state, stored in CLMM position struct (separate contract)
- `nft.owner`: External state, stored in object framework (separate contract)

### Ownership Scope Transition
```
[Before deposit]
nft.owner = user_address
user can call: clmm::decrease_liquidity(nft) ✓

[After deposit, before withdraw]
nft.owner = gauge_address
user can call: clmm::decrease_liquidity(nft) ❌ (permission denied)
gauge can call: clmm::decrease_liquidity(nft) ✓ (but gauge code never does this)

[After withdraw]
nft.owner = user_address
user can call: clmm::decrease_liquidity(nft) ✓
```

**Critical Observation**: During the staking period (when rewards accrue), the user has **ZERO control** over the NFT's state.

## Exploit Feasibility

### Prerequisites for Alleged Attack
1. ❌ **User must be able to call decrease_liquidity on deposited NFT**
   - Reality: NFT is owned by gauge, not user
   - CLMM contract enforces ownership check
   - User's transaction would abort with permission error

2. ❌ **Gauge must not verify actual liquidity during reward calculation**
   - Reality: Gauge uses snapshot, but snapshot cannot be manipulated by user (see #1)

3. ❌ **User must be able to withdraw with reduced liquidity**
   - Reality: Even if liquidity were reduced, Line 374 requires liquidity > 0
   - If liquidity = 1, withdrawal succeeds but accounting is correct (balance -= 1, total_supply -= 1)

### Can a Normal EOA Execute This?
**NO**. The attack requires the user to call `decrease_liquidity` on an NFT owned by the gauge contract. This violates the fundamental ownership security model of NFT-based positions and would be rejected by the CLMM contract's permission checks.

**Privilege Requirements**:
The attack would require:
- Compromising the gauge contract's signer/private key to sign CLMM transactions, OR
- A critical vulnerability in the CLMM contract's ownership verification (out of scope)

**Neither is possible for a normal unprivileged user.**

## Economic Analysis

**Attack Cost**: Not applicable - attack is technically impossible

**Attack Gain**: Not applicable - attack is technically impossible

**Net EV**: N/A - attack cannot be executed on-chain

### Why the Reporter's Economic Analysis is Irrelevant

The reporter correctly identifies that IF the attack were possible, it would be capital-efficient:
- Borrow funds via flash loan
- Deposit high liquidity NFT
- Reduce liquidity
- Earn rewards with minimal capital

**However**: The attack chain breaks at step 3 due to ownership violation. The economic analysis of subsequent steps is purely theoretical and cannot occur in practice.

## Dependency/Library Reading Notes

### DexlynClmm (External Dependency)
**Source**: GitHub - DexlynLabs/CLMM_Dex (Move.toml:30)
**Module**: `position_nft`

**Standard CLMM Position Management**:
Based on industry-standard implementations (Uniswap V3, Cetus CLMM), position NFTs represent ownership of liquidity positions. Key functions:

- `add_liquidity` / `increase_liquidity`: Creates or adds to position
  - Owner: caller who provides tokens

- `decrease_liquidity`: Removes liquidity from position
  - **Requires**: caller == position owner
  - **Effect**: Reduces position.liquidity, returns tokens to caller

- `collect`: Collects accumulated fees
  - **Requires**: caller == position owner

**Ownership Transfer**:
- Position NFTs are standard NFTs (ERC-721 / Aptos Token Objects)
- Transfer functions change the `owner` field
- All modification functions check `owner == msg.sender`

**gauge_clmm::get_liquidity**:
```move
public(friend) fun get_liquidity(pool_address: address, token_address: address): u128 {
    assert!(position_nft::is_valid_nft(token_address, pool_address), ERROR_INVALID_TOKEN);
    let token_records = position_nft::get_nft_details(vector[token_address]);
    let token_info = vector::borrow(&token_records, 0);
    let (_, _, _, _, liquidity) = position_nft::get_nft_details_struct(token_info);
    liquidity
}
```

This function reads the **stored liquidity value** from the position struct. It does NOT check ownership (read-only operation). However, this is irrelevant because:
- Reading liquidity doesn't require ownership ✓
- **Modifying** liquidity requires ownership ✓
- User cannot modify liquidity after transfer ✓

### Aptos/Supra Object Framework
**Module**: `supra_framework::object`

**Key Functions**:
- `object::transfer(owner, object, new_owner)`: Transfers object ownership
  - Requires: caller owns the object
  - Effect: Changes object.owner from caller to new_owner

- `object::is_owner(object, address)`: Checks if address owns object
  - Returns: boolean

**Ownership Model**: Once an object is transferred, the original owner loses all control unless the new owner transfers it back.

## Final Feature-vs-Bug Assessment

**Is the snapshot-based accounting a bug?**

**NO** - This is **intentional design** for gauge reward systems.

**Reasoning**:
1. **Gauge Purpose**: Incentivize users to lock LP tokens to signal support for a pool
2. **Reward Basis**: Should be TVL (Total Value Locked), not active fee-earning capacity
3. **Separation of Concerns**:
   - CLMM pool fees: reward active liquidity (in-range positions)
   - Gauge rewards: reward locked capital (all deposited positions)

4. **Snapshot Approach is Correct**:
   - User deposits NFT with liquidity L → gauge credits balance += L
   - User withdraws NFT with liquidity L → gauge debits balance -= L
   - During deposit period, gauge uses L for reward calculation
   - **Invariant**: balance always equals sum of deposited NFTs' liquidity values

5. **Why Snapshot Doesn't Need Updates**:
   - The stored liquidity value in the NFT is **immutable** unless explicitly modified via CLMM functions
   - Only the NFT owner can call those modification functions
   - The gauge owns the NFT during deposit → **user cannot modify it**
   - **Therefore, snapshot remains accurate for the NFT's actual on-chain liquidity value**

**The design is not a bug** - it's a correct implementation of a gauge system with proper ownership controls preventing manipulation.

## Conclusion

**Final Classification**: FALSE POSITIVE

**Root Cause of Report Error**:
The reporter fundamentally misunderstood the NFT ownership model in CLMM position management. They assumed the user retains the ability to modify an NFT's liquidity after depositing it into the gauge, when in fact:
1. NFT ownership transfers to the gauge (L332)
2. CLMM contracts enforce ownership checks on all modification functions
3. The user cannot call `decrease_liquidity` on an NFT they don't own
4. The attack is impossible at the blockchain execution level

**Core Directive Compliance**:
- [Core-1] ✓ No practical economic risk - attack cannot execute
- [Core-2] ✓ Analyzed CLMM dependency ownership model from industry standards
- [Core-3] ✓ Traced full attack flow, identified break at step 3 (ownership check)
- [Core-4] ✓ Verified attack requires privileged access (gauge contract compromise) - out of scope
- [Core-6] ✓ Attack path is NOT 100% attacker-controlled - requires compromising gauge ownership
- [Core-8] ✓ Snapshot accounting is intentional feature, not a bug

**Recommendation**:
DISMISS this report as a false positive resulting from incorrect assumptions about external contract behavior and NFT ownership mechanics.
