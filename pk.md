# Prior Knowledge Base — Compact (先验知识库·精简版)

> 目标：作为 AI 在 **审计前** 的“一次性加载”先验，覆盖语言/会计/单位语义/升级与治理/提交准入门槛等 **必需知识**。保留过往误报中提炼出的 **正确规则与方法**（Knowledge Updates & Checkpoints），去除冗长案例叙述与重复论证。

---

## 🔄 Recent False Positive Analysis (2025-11-07)

### Finding 10 - "Unbounded Loop DoS"
🔁 **False Positive Reflection:**
- **Wrong prior:** "255 iterations in a loop = must cause gas exhaustion and DoS"
- **Why it failed:** Made severity claim without quantitative gas analysis; missed public recovery function `checkpoint()`; characterized developer-acknowledged design limitation as critical vulnerability

🧠 **Prior Knowledge Update:**
- **Rule 17:** Gas DoS claims REQUIRE actual gas calculations, not iteration count heuristics
  - Example: 255 iterations × (reads + writes + arithmetic) = 648K gas vs 1-2M block limit = NO DoS
- **Rule 18:** Before claiming "permanent DoS", check for recovery mechanisms (public/permissionless functions)
- **Rule 19:** Developer comments acknowledging limitations + fallback behavior = intentional design tradeoff, NOT vulnerability

📍 **Checkpoint for Future:**
- When seeing loop limits: Calculate actual gas → Check for recovery functions → Verify if limitation acknowledged in comments → Classify as design choice vs bug

---

### Finding 11 - "CLMM Liquidity Manipulation"
🔁 **False Positive Reflection:**
- **Wrong prior:** "Out-of-range CLMM position = liquidity becomes 0"
- **Why it failed:** Confused **stored liquidity value** (constant in position struct) with **active fee-earning liquidity** (dynamic based on price); missed critical assertion `assert!(liquidity > 0)`

🧠 **Prior Knowledge Update:**
- **Rule 20:** CLMM Position Mechanics Distinction
  - **Stored liquidity:** Position struct field, constant until explicit modification (decrease_liquidity)
  - **Active liquidity:** Whether position earns fees, changes when price moves in/out of range
  - `get_liquidity()` reads stored value, NOT active status
- **Rule 21:** NEVER skip over assertions - they are on-chain guards that invalidate entire attack paths
- **Rule 22:** When claiming "user can modify X while deposited", verify NFT ownership transfer

📍 **Checkpoint for Future:**
- For CLMM/AMM issues: Distinguish stored values vs computed values → Check what function actually reads → Verify all assertions in code path → Consider ownership model

---

### Finding 12 - "Binary Search Inconsistency"
🔁 **False Positive Reflection:**
- **Wrong prior:** "Similar but slightly different code = inconsistency vulnerability"; "Non-atomic updates = exploitable race condition"
- **Why it failed:** Both functions actually use identical formula `(min+max+2)/2`; didn't trace temporal selection logic (`ts ≤ target_week`); non-atomicity irrelevant when both paths use same temporal criterion

🧠 **Prior Knowledge Update:**
- **Rule 23:** Temporal Selection Systems (snapshots, epochs, checkpoints)
  - Non-atomic updates OK if all code paths select data by same temporal criterion
  - Example: `balance_of` and `ve_supply` both use "largest epoch with ts ≤ week_start"
  - Verify WHEN data is selected, not just THAT it's selected
- **Rule 24:** Binary search "inconsistency" requires proof that different inputs → divergent outputs for SAME query

📍 **Checkpoint for Future:**
- For snapshot/epoch systems: Map all data reads → Identify temporal selection criterion for each → Verify criterion is consistent → Test if mid-period updates can cause divergence

---

### Finding 13 - "Ghost Weight in Epoch Accounting"
🔁 **False Positive Reflection:**
- **Wrong prior:** "Accounting discrepancy = exploitable vulnerability"; "Inflated denominator = ongoing impact"
- **Why it failed:** Historical epoch data is immutable after use; rewards use PREVIOUS epoch (frozen snapshot); `is_alive` check has explicit comment explaining intentional double-subtraction prevention

🧠 **Prior Knowledge Update:**
- **Rule 25:** Immutable Historical Data Pattern
  - Distinguish operational state (affects current/future ops) vs archival state (historical record)
  - If discrepancy is in historical epoch never consulted again → cosmetic only, no impact
  - Example: `total_weights_per_epoch[E0]` used once at E0→E1 transition, then frozen
- **Rule 26:** Epoch-Based Accounting
  - Check: Does "inflated past value" affect future calculations? If NO → not a vulnerability
  - Rewards typically use snapshot from PREVIOUS epoch (immutable when accessed)
- **Rule 27:** Explicit Code Comments on Behavior
  - Comment saying "don't subtract because already done in kill_gauge()" = INTENTIONAL design
  - Don't report as bug when code explicitly explains the logic

📍 **Checkpoint for Future:**
- For epoch/accounting issues: Identify if state is historical vs operational → Trace if past discrepancy affects future ops → Check code comments for intentionality → Classify impact

---

### Finding 15 - "Double Division Precision Loss"
🔁 **False Positive Reflection:**
- **Wrong prior:** "Any precision loss = vulnerability"; "Dust accumulation = permanent freeze"; "Loop iteration limit = DoS"
- **Why it failed:** Standard integer arithmetic limitation (<0.01% in realistic scenarios); recovery functions exist (`recover_and_update_data`, `emergency_recover`); 50-week limit with checkpoint advancement = pagination, not freeze; explicitly acknowledged in code comments

🧠 **Prior Knowledge Update:**
- **Rule 28:** Precision Loss Severity Assessment
  - Calculate actual magnitude: typical case vs worst case
  - Example: (reward × MULTIPLIER) / total_supply → second division → cumulative loss < 0.01% = negligible
  - Check for dust recovery mechanisms (admin sweep, emergency withdraw)
  - If loss < 0.1% AND recoverable → informational, not vulnerability
- **Rule 29:** Loop Limits vs DoS
  - Loop limit WITH checkpoint/pagination = multi-transaction access (feature)
  - Loop limit WITHOUT progress saving = hard cap (potential issue)
  - Check: Does state update allow resumption? Example: `user_last_time` advances each claim
- **Rule 30:** Intentional Design Tradeoffs
  - Code comments saying "calculation may lose precision in some case" = acknowledged
  - Gas optimization vs precision = common DeFi pattern (e.g., Synthetix StakingRewards)
  - Don't report as vulnerability when explicitly documented as design choice

📍 **Checkpoint for Future:**
- For precision issues: Calculate actual loss percentage → Check recovery mechanisms → Verify if acknowledged in comments → Assess if standard DeFi pattern → Classify severity

---

## ⚠️ Common False Positive Patterns - Pre-Submission Checklist

Before submitting Medium+ findings, verify you haven't fallen into these traps:

- [ ] **Assertion Blindness** - Did you skip over `assert!()` statements that invalidate the attack?
- [ ] **Storage vs Computed Confusion** - Are you confusing stored values with dynamically computed values?
- [ ] **No Quantitative Analysis** - Are you claiming gas/economic impact without actual calculations?
- [ ] **Ignored Explicit Comments** - Does code comment explicitly explain the behavior you're reporting?
- [ ] **Historical vs Operational State** - Is the "discrepancy" in frozen historical data never used again?
- [ ] **Missed Recovery Mechanisms** - Did you check for admin/public recovery functions?
- [ ] **Feature vs Bug** - Is this an intentional design tradeoff documented in code/comments?
- [ ] **Temporal Selection Logic** - For snapshot systems, did you trace WHEN data is selected, not just WHAT?

---

## I. 核心审计目标与分层

- 仅在满足 **资金损失 / 资产冻结 / 协议级 DoS / 欺诈性会计失衡** 时输出 Finding。  
- 错误分层：
  | 层级 | 类型 | 能否部署 | 风险 |
  |---|---|---|---|
  | 1 | 编译错误 | 否 | 无链上风险 |
  | 2 | 运行时 panic | 是 | DoS 风险 |
  | 3 | 可检测的逻辑错误 | 是 | 中风险（可对账发现） |
  | 4 | 静默错误 | 是 | 高风险（账面平衡但价值流失） |

---

## II. 语言与类型系统（Move/Rust/Solidity）

### Update #1 — 强类型系统的编译时防护（保留）
- **原则**：已部署=已通过语法与类型检查。若“错误”会导致类型不匹配→不可能通过编译。
- **流程**：
  1) 枚举表达式的可能解析；2) 逐个类型推导；3) 若某解析触发类型错且代码已部署→排除；4) 仅剩唯一合法解析→无歧义，若风格问题→降级为代码质量建议。

### 编译器版本/差异评估（保留）
- 先查规范与版本锁定；若差异只会“编译失败”而非“静默改变语义”，不构成漏洞。

### Checkpoint #1 — 类型/优先级验证（保留）
- 步骤：识别语言→枚举解析→类型推导→编译验证→反证法。

---

## III. 会计不变量与状态转换

### Update #9 — 会计恒等式需在“状态链”验证（保留）
- **恒等式**：资产 = 负债 + 权益（或资产余额 ≥ sum(应付/承诺)）。
- **方法**：识别资产/负债变量→绘制状态转换（含前置条件）→在各状态节点逐一验平→判断负债减少是否合法（支付、放弃、终止/撤销）。
- **证据优先**：实际代码行为 > 测试用例 > 最新注释 > 过时注释。

### Update #10 — 特权功能 vs 协议漏洞（保留）
- **非漏洞**：正常管理操作（暂停/恢复、迁移/终止、参数调整、回收未分配）。
- **漏洞**：绕过不变量、剥夺**确定权利**、破坏账务平衡。  
- **输出**：若非漏洞但存在信任/治理问题→标注“中心化风险/设计特性”。

### Checkpoint — 会计恒等式验证（保留）
- 识别变量 → 追踪 state 变迁 → 节点逐一验平 → 合法性判断 → 查测试/文档 → 给出结论。

---

## IV. 单位与语义一致性

### Update #5 — “语义优先于单位”的验证（保留）
- **四步**：1) 语义确认（是否同一物理量） 2) 追溯计算来源（是否含 SCALE/MULTIPLIER）  
  3) 三场景数值验证（边界/典型/满额） 4) 反证法（若真错会出现的可观测异常）。

### Update #6 — Voting Power 语义模式（保留）
- 通式：`voting_power = base_amount * time_factor * scaling_factor`。**与原始代币数量不同维度**。

### Update #7 — 精度管理验证（保留）
- 列全变量与精度 → 追溯高精度来源（SCALE 链）→ 构建单位传播链 → 3 场景数值验证 → 维度分析。

### Update #8 — 注释的可信度评估（保留）
- 注释可能过时/错误，**以代码与测试为准**。

---

## V. 升级能力与治理语境（Move 特性）

### Update #13 — upgrade_policy 判定（保留）
- `immutable`：不可升级→永久性问题可定性为高危。  
- `compatible`：可**新增函数**（不可改现有结构/签名）→缺失功能属**可修复**设计缺口。  
- `arbitrary`/未设：任意升级→更偏向“信息性/设计缺口”。

### Update #14 — 设计缺口 vs 安全漏洞（保留）
- 安全漏洞=可利用 + 经济动机 + 违反设计 + 难修复（全部成立）。
- 设计缺口=不可利用 + 无人获利 + 可通过升级/配置修复。

### Update #15 — 协议/运营/中心化风险划分（保留）
- 协议风险（代码缺陷）/运营风险（密钥管理、外部依赖）/中心化风险（信任治理）。
- 审计报告应**正确分类与定级**。

### Update #16 — 已知/文档化问题的处理（保留）
- 文档/注释/设计书已记录→审计应“确认其仍存在与可修复性”，严重性相应下调；避免将“已知问题”描述为“未发现的高危漏洞”。

---

## VI. 提交前强制清单（Gate for Findings）

在提交任何 **Medium+** 之前，必须全部满足：
- [ ] 反证法闭环已完成（若真存在，会出现何种可观测后果？与现实是否矛盾）。
- [ ] 类型系统检查完成（已部署代码不可能包含编译期错误）。
- [ ] 语义追溯完成（变量来源、SCALE 链）。
- [ ] 数值验证 ≥ 3 场景（边界、典型、满额）。
- [ ] 状态转换链梳理完毕（含前置条件）。
- [ ] 测试/文档已查阅并用于解释设计意图。
- [ ] 特权操作已分类（设计/中心化风险 vs 漏洞）。
- [ ] 严重性与“可利用性/经济动机/可修复性”矩阵一致。

---

## VII. 快速判定矩阵

| 可利用性 | 经济动机 | 可修复性 | 结论 |
|---|---|---|---|
| ✅ | ✅ | 难 | 严重漏洞 |
| ✅ | ✅ | 易 | 中风险 |
| ❌ | ❌ | 易 | 设计缺口（信息性） |
| ❌ | ❌ | 难 | 运营/治理问题 |

---

## VIII. 术语与典型映射（速查）

- **locked_amount** → 负债（未来承诺）  
- **ve_supply / voting power** → 时间加权权益（含 SCALE）  
- **admin_withdraw（终止后）** → 结清残余资产（需先清零负债/或业务允许撤销）  
- **rebase/ratio** → 常含维度缩放（10^k）

---

## IX. 保留的“知识更新来源”索引（非冗余）

> 下列条目仅作为**知识来源索引**，其详细案例叙述已移除；保留的都是从中提炼出的 **规则/流程**：  
- Update #1（强类型编译防护）  
- Update #2（错误层级表）  
- Update #5-#8（单位与语义/注释可信度）  
- Update #9-#12（会计恒等式/特权判定/测试与业务意图）  
- Update #13-#16（升级能力/设计缺口/风险分类/已知问题处理）

> 若需回溯具体案例，请在原始 `pk.md` 中按“Update #x”或“Checkpoint #x”检索。此精简版用于**加载先验**与**流程执法**，而非留存故事。

