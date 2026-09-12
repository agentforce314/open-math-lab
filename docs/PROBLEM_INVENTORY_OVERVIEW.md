# Problem inventory overview (board-facing)

**Issue:** OPE-1 · **Author:** Research Director · **Snapshot:** 2026-09-12 (catalog `problems.json` @ `b477799`, 112 entries)

This is a plain-language map of every problem in the lab inventory: what each one
asks, how hard it is, and what the lab has actually done with it. It does **not**
change any status — `catalog/problems.json` and `docs/PROBLEM_LEDGER.md` remain
the source of truth. Numbers below are counts at snapshot time.

---

## 1. How to read "difficulty"

Two independent axes matter, and conflating them is how labs fool themselves:

| Axis | What it measures |
|------|------------------|
| **Math level** | How hard the *mathematics* is: **U** = undergraduate/olympiad, **G** = graduate/named theorem, **R** = genuinely open research. |
| **Lab status** | What is *machine-checked* in our Lean project (`proofs/lean-project/ProofLab/`). See tiers below. |

Lab-status tiers (these are the labels used in the tables):

| Tier | Meaning | Honest reading |
|------|---------|----------------|
| **T0 seed** | demo placeholder | not a research bet |
| **T1 Level A** | Lean zero-sorry proof of *small witnesses / glue lemmas* for a named theorem (e.g. `4!+1=5²`, `K₂□K₂` colourable). The **named theorem itself is not proved.** | easy Lean practice, hours of work; no mathematical novelty |
| **T2 Full finite/exact** | Lean zero-sorry proof of the *actual statement* (e.g. `R(3,5)=14`, Dirac's theorem, Schur partition ∀n) | medium: one to several waves; solid Mathlib-gap contributions, still no novelty |
| **T3 informal / heuristic** | correct classical maths + Python/compute artifacts, Lean absent or incomplete | not a proof by lab rules; process fuel |
| **T4 open** | genuinely unsolved problem with a live cash prize; lab has encoding + bounded evidence only | research-hard; namesake conjecture is **out of v1** |
| **X out-of-scope** | rejected/archived | Millennium, Beal, RSA (ended 2007), Erdős #78, sun-135 |

Feasibility **score** (0–100) is the Scout's rubric (`docs/FEASIBILITY_RUBRIC.md`): ≥80 prime, 60–79 feasible, 40–59 risky. Note that score measures *attackability within lab constraints*, **not** mathematical depth — a score of 86 on `taxicab-1729` means "trivially formalizable", not "important".

### Inventory at a glance

| Status (catalog) | Count | Tier |
|------------------|------:|------|
| `formalized` | 87 | ~73 are T1 Level A only; ~14 are T2 full statements |
| `informal` | 12 | T3 |
| `heuristic` | 4 | T3 (2 of them are the T4 open problems) |
| `candidate` | 4 | stale JSON leftovers — all already in Mathlib or not one-wave |
| `shortlisted` | 1 | `frobenius-coin-problem` — ratified as process-fuel only |
| `archived` | 3 | X |
| `seed` | 1 | T0 |

Novelty tags: **105 known-classical**, 3 formalize-only, **2 open** (`krenn-gu`, `hou-zeng-pfc`).

**Bottom line for the board:** the inventory is ~98% classical theorems used as Lean
formalization fuel. Exactly two entries are real open problems, and on both the lab
holds only Level A encodings plus bounded searches — no claim, no prize.

---

## 2. The genuinely open problems (T4 — research level)

| ID | Statement | Math | Score | What we hold | Prize |
|----|-----------|:----:|------:|--------------|-------|
| `krenn-gu` | **Krenn–Gu conjecture** (quantum-optics graphs): for even N ≥ 6 and D ≥ 3 colours, no edge-weighted complete graph on N vertices has a "perfectly monochromatic" perfect-matching weight system in D colours (each vertex sees each colour with total weight from a fixed equation system). Equivalently: certain multi-photon GHZ states cannot be produced by linear optics without ancillas. | R | 80 | `ProofLab/KrennGu.lean` zero-sorry encoding `EqSystem/pmSum` + positive C₄ witness (D=2). Attack OPE-1038: exhaustive `(8,3)` and `(6,3)` over ring `{−1,0,1}` → **0 counterexample witnesses**. Namesake ∀N,D **not** attempted. | €3,000 (Krenn/Leitner). **Do not claim.** |
| `hou-zeng-pfc` | **Hou–Zeng conjecture**: every integer n > 4 is a sum *odd prime + positive Fibonacci + Catalan number*. (Sun 2009, OEIS A154404.) | R | 84 | `ProofLab/HouZeng.lean` zero-sorry: predicate `IsOddPrimeFibCatalan`, `hou_zeng_five`, bounded `hou_zeng_le_N` for 5 ≤ n ≤ 30 via `native_decide`. Already verified to 5·10¹³ by McNeil, so a counterexample is not a one-wave target. | $1,000 proof / $200 counterexample. **Do not claim.** |

Rejected as primes (OPE-1028): Millennium $1M (no sub-bounty lemma), Beal $1M (FLT-class),
Erdős #78 constructive Ramsey (not finitely resolvable), RSA challenge (ended 2007),
`sun-135` (Sun 1-3-5 conjecture — **proved 2020**, prize not live; archived).

---

## 3. Full statements formalized in Lean (T2 — medium)

All classical, all `known-classical`, all zero-sorry with axiom audits recorded in the ledger. These are the lab's strongest machine-checked artifacts.

| ID | Statement | Math | Lean artifact |
|----|-----------|:----:|---------------|
| `ramsey-r33` | R(3,3)=6 and R(4,4)=18: any 2-colouring of K₆ has a monochromatic triangle; of K₁₈ a mono K₄; both sharp. | U/G | `ProofLab/Ramsey.lean` |
| `ramsey-r35` | R(3,5)=14 (lower bound: circulant C₁₃(±1,±5); upper: R(2,5)+R(3,4)). | G | `ProofLab/Ramsey.lean` |
| `ramsey-multicolor-r333` | R(3,3,3)=17 (Greenwood–Gleason 1955): 3-colour K₁₇ forces a mono triangle; K₁₆ does not. | G | `ProofLab/RamseyMulticolor.lean` |
| `schur-number` | Schur numbers S(2)=5, S(3)=14: largest n such that {1..n} can be r-coloured with no mono solution of x+y=z. | U/G | ProofLab (OPE-402 wave) |
| `weak-schur-ws2` | Weak Schur WS(2)=8 (x+y=z with x≠y). | U | `ProofLab/WeakSchur.lean` |
| `van-der-waerden-w23` | W(2,3)=9: any 2-colouring of {1..9} has a mono 3-term AP; 8 does not. | U | ProofLab (OPE-402 wave) |
| `happy-ending-es3` | ES(3)=5: any 5 points in general position contain a convex quadrilateral (Erdős–Szekeres 1935). | U/G | `ProofLab/HappyEndingES3.lean` |
| `erdos-szekeres-monotone` | Any sequence of (r−1)(s−1)+1 distinct reals has an increasing subsequence of length r or decreasing of length s. | U | `ProofLab/ErdosSzekeres.lean` |
| `friendship-windmill` | Friendship theorem (Erdős–Rényi–Sós 1966): if every two vertices have exactly one common neighbour, the graph is a windmill. | G | `ProofLab/Friendship.lean` |
| `euler-odd-distinct` | Euler 1748: #partitions of n into odd parts = #partitions into distinct parts (Glaisher bijection). | U | `ProofLab/EulerPartition.lean` |
| `dirac-hamiltonian` | Dirac 1952: a simple graph on n ≥ 3 vertices with min degree ≥ n/2 is Hamiltonian. | G | `ProofLab/Dirac.lean` |
| `schur-partition-full` / `-glaisher` | Schur 1926 partition identity ∀n: #partitions into distinct parts ≡ 1,2 (mod 3) = #partitions into parts ≡ ±1 (mod 6). | G | `ProofLab/SchurGlaisher.lean` |
| `erdos-woods` | Erdős–Woods k=16: correct witness a=2184 — every integer in (2184, 2200) shares a prime factor with 2184 or 2200. (Earlier a=5 claim was **vetoed**: definition bug, OPE-12/15.) | U/G | ProofLab (per ledger) |

---

## 4. Classical theorems with Level A Lean only (T1 — easy)

**~73 entries.** Each has a zero-sorry Lean file proving small concrete instances or
glue lemmas; the named theorem ("Level B") was explicitly left **out of v1** and is
not `sorry`-ed. These are catalogued as `formalized` but the board should read that
as "encoding + witnesses landed", not "theorem proved". Grouped by domain.

### Graph theory
| ID | Statement (the named theorem) | Math |
|----|-------------------------------|:----:|
| `konig-bipartite` | Kőnig: in a bipartite graph, max matching = min vertex cover. | U/G |
| `bipartite-chromatic-index` | Kőnig line-colouring: bipartite χ′ = Δ. | G |
| `bipartite-odd-cycle` | A graph is bipartite iff it has no odd closed walk. | U |
| `greedy-chromatic` | Greedy colouring gives χ ≤ Δ+1. | U |
| `mycielski-triangle-free` | Mycielski: triangle-free graphs of arbitrarily large chromatic number exist. | G |
| `ore-hamiltonian` | Ore: deg u + deg v ≥ n for all non-adjacent u,v ⇒ Hamiltonian. | G |
| `petersen-1-factor` | Petersen: every cubic bridgeless graph has a perfect matching. | G |
| `eulerian-hierholzer` | A connected graph has an Eulerian circuit iff all degrees are even. | U |
| `sabidussi-boxprod` | Sabidussi: χ(G □ H) = max(χ(G), χ(H)). | G |
| `graham-pollak` | Graham–Pollak: K_n needs at least n−1 bicliques to decompose its edge set. | G |
| `frucht-graph-aut` | Frucht: every finite group is the automorphism group of some finite graph. | G |
| `moore-degree-girth` | Moore bound: a graph with degree d and girth 2k+1 has ≥ 1 + d Σ(d−1)^i vertices. | G |
| `kovari-sos-turan` | Kővári–Sós–Turán: K_{s,t}-free graphs have O(n^{2−1/s}) edges (integer counting form). | G |
| `andrasfai-erdos-sos` | Andrásfai–Erdős–Sós: triangle-free with min degree > 3n/5 ⇒ bipartite. | G |
| `nash-williams-arboricity` | Nash-Williams: arboricity = max over subgraphs of ⌈e(H)/(v(H)−1)⌉. | G |
| `erdos-ramsey-lower` | Erdős 1947 probabilistic lower bound R(k,k) > 2^{k/2}. | G |
| `lovasz-local-lemma` | Symmetric LLL: if each bad event has prob ≤ p, depends on ≤ d others, e·p·(d+1) ≤ 1 ⇒ all avoidable. | G |
| `expander-mixing` *(informal)* | Expander mixing lemma: e(S,T) ≈ d\|S\|\|T\|/n within λ√(\|S\|\|T\|). | G |

### Extremal set theory / order
| ID | Statement | Math |
|----|-----------|:----:|
| `erdos-ko-rado` | k-uniform intersecting family on [n], n ≥ 2k, has ≤ C(n−1,k−1) sets. | G |
| `kruskal-katona` | Colex initial segments minimise the shadow of a k-uniform family. | G |
| `sunflower-erdos-rado` | Any family of > r!(k−1)^r k-sets contains an r-sunflower. | G |
| `oddtown` | Odd-size sets with even pairwise intersections: at most n of them. | U/G |
| `bollobas-two-families` | Bollobás: if A_i ∩ B_j = ∅ iff i = j, then Σ 1/C(a_i+b_i, a_i) ≤ 1. | G |
| `dilworth-poset` | Dilworth: min chain partition = max antichain. | G |

### Number theory
| ID | Statement | Math |
|----|-----------|:----:|
| `euclid-euler-perfect` | Even perfect numbers are exactly 2^{p−1}(2^p−1) with 2^p−1 prime. | U |
| `korselt-carmichael` | Korselt: n is Carmichael iff squarefree and (p−1) \| (n−1) for all p \| n. | U/G |
| `proth-primality` | Proth: k·2ⁿ+1 (k < 2ⁿ) is prime iff some a has a^{(N−1)/2} ≡ −1 (mod N). | U/G |
| `legendre-three-squares` | n is a sum of three squares iff n ≠ 4^a(8b+7). | G |
| `farey-sequence` | Adjacent Farey fractions a/b < c/d satisfy bc − ad = 1. | U |
| `lame-euclid` | Lamé: Euclid's algorithm takes ≤ 5·(digits) steps; Fibonacci pairs are worst case. | U |
| `lagrange-quadratic-cf` | Lagrange: continued fraction is eventually periodic iff quadratic irrational. | G |
| `ostrowski-q` | Ostrowski: every nontrivial absolute value on ℚ is equivalent to \|·\|_∞ or some \|·\|_p. | G |
| `zsqrt5-not-ufd` | ℤ[√−5] is not a UFD: 6 = 2·3 = (1+√−5)(1−√−5). | U/G |
| `egyptian-fractions` | Every positive rational is a sum of distinct unit fractions (Fibonacci–Sylvester greedy). | U |
| `taxicab-1729` | 1729 = 1³+12³ = 9³+10³, the smallest such number. | U |
| `euler-brick` | Euler brick (44,117,240): all three face diagonals are integers. | U |
| `cannonball-square-pyramid` | Σ_{k≤n} k² is a perfect square only for n = 1, 24 (Lucas/Watson). | G |
| `brocard-factorial-square` | n!+1 = m² for n = 4, 5, 7 (Brocard's problem: are there others? — **open**, out of v1). | U / R |
| `alcuin-integer-triangles` | Number of integer-sided triangles with perimeter n (Alcuin's sequence). | U |
| `e-irrational` | e is irrational. | U |
| `wolstenholme-theorem` *(informal)* | For prime p ≥ 5, C(2p−1, p−1) ≡ 1 (mod p³). | G |
| `zsigmondy-theorem` *(informal)* | Bang/Zsigmondy: aⁿ − 1 has a primitive prime divisor except for known exceptions. | G |
| `sum-free-subsets` *(informal)* | Erdős: every set of n nonzero integers has a sum-free subset of size > n/3. | U/G |
| `vosper-cauchy-davenport` *(informal)* | Vosper: equality cases of Cauchy–Davenport \|A+B\| ≥ \|A\|+\|B\|−1 in ℤ/p. | G |

### Algebra / linear algebra
| ID | Statement | Math |
|----|-----------|:----:|
| `cauchy-binet` | det(AB) = Σ_S det(A_S) det(B_S) for rectangular A, B. | U/G |
| `hadamard-det` | \|det A\| ≤ Π ‖row_i‖₂. | U/G |
| `schur-product` | Hadamard (entrywise) product of PSD matrices is PSD. | G |
| `circulant-det` | Determinant of a circulant = Π_j f(ω^j) over roots of unity. | U/G |
| `sherman-morrison` | (A + uvᵀ)⁻¹ = A⁻¹ − A⁻¹uvᵀA⁻¹ / (1 + vᵀA⁻¹u). | U |
| `jordan-canonical-form` | Every complex matrix is similar to a Jordan block-diagonal form. | G |
| `birkhoff-von-neumann` | Doubly stochastic matrices are convex combinations of permutation matrices. | G |
| `frobenius-real-division` | Finite-dim real division algebras are ℝ, ℂ, or ℍ (Level A: dimension ∈ {1,2,4} **is** landed). | G |
| `noether-normalization` | A f.g. k-algebra is a finite module over a polynomial subring. | G |
| `mason-stothers` | Polynomial abc: deg(max) ≤ #distinct roots of abc − 1 for coprime a+b=c. | G |
| `schwartz-zippel` | A nonzero degree-d polynomial vanishes on ≤ d·\|S\|^{n−1} points of Sⁿ. | G |
| `combinatorial-nullstellensatz` | Alon: nonzero coefficient of Πx_i^{t_i} ⇒ non-vanishing on a box of sizes t_i+1. | G |
| `wantzel-constructible` | Constructible numbers have degree a power of 2 (cube cannot be doubled). | G |
| `d8-ne-q8` | Dihedral D₈ and quaternion Q₈ are non-isomorphic (count elements of order 2). | U |
| `a4-klein-four` | Double transpositions in A₄ form the Klein four-group. | U |
| `descartes-rule-of-signs` *(informal)* | #positive real roots ≤ #sign changes, same parity. | U/G |

### Enumerative combinatorics / partitions
| ID | Statement | Math |
|----|-----------|:----:|
| `n-fold-inclusion-exclusion` | \|∪A_i\| = Σ (−1)^{\|S\|+1} \|∩_{S} A_i\|. | U |
| `hook-length` | #SYT of shape λ = n! / Π hook lengths. | G |
| `kraft-inequality` | A prefix-free code with lengths ℓ_i exists iff Σ 2^{−ℓ_i} ≤ 1. | U |
| `gale-shapley` | Deferred acceptance always yields a stable matching. | U |
| `orthogonal-latin-squares` | Pairs of orthogonal Latin squares: none of order 2, exist for order 3. | U |
| `langford-pairing` | Langford sequences exist iff n ≡ 0, 3 (mod 4). | U |
| `gray-code` | Binary reflected Gray code: successive words differ in one bit. | U |
| `stirling-second-kind` *(informal)* | S(n,k) counts set partitions of [n] into k blocks; recurrence. | U |
| `cayley-trees` *(informal)* | Cayley: n^{n−2} labelled trees on n vertices. | U/G |
| `pentagonal-number-theorem` *(informal)* | Euler: Π(1−xⁿ) = Σ (−1)^k x^{k(3k−1)/2}; partition recurrence. | G |
| `havel-hakimi` *(informal)* | A degree sequence is graphic iff its Havel–Hakimi reduction is. | U |
| `menger-vertex` *(informal)* | Menger: min A–B vertex separator = max #disjoint A–B paths. | G |
| `brooks-coloring` *(informal)* | Brooks: χ ≤ Δ unless complete or odd cycle. | G |

### Geometry / games / misc
| ID | Statement | Math |
|----|-----------|:----:|
| `heron-formula` | Area = √(s(s−a)(s−b)(s−c)). | U |
| `british-flag` | For P inside rectangle ABCD: PA² + PC² = PB² + PD². | U |
| `platonic-solids` | Exactly five regular convex polyhedra (via Euler's formula). | U |
| `sylvester-gallai` | Any finite non-collinear point set has a line through exactly two of them. | G |
| `singleton-bound` | An (n, M, d) code has M ≤ q^{n−d+1}. | U |
| `fine-wilf` | A word with periods p, q and length ≥ p+q−gcd(p,q) has period gcd(p,q). | U/G |
| `myhill-nerode` | A language is regular iff its Nerode equivalence has finitely many classes. | U/G |
| `simpson-paradox` | A rate reversal on aggregation (concrete 2×2×2 witness). | U |
| `n-queens` | No solutions for n = 2, 3; a witness for n = 4. (Full: solutions exist iff n ≠ 2, 3.) | U |
| `mutilated-chessboard` | A chessboard minus opposite corners cannot be tiled by dominoes. | U |
| `hex-no-draw` | A Hex board fully coloured always has a winner (Nash/Gale). | U/G |
| `lights-out` | Lights Out: all-ones solvable iff every cell is toggled an odd number of times. | U |

---

## 5. Heuristic / process-fuel entries (T3)

| ID | What was done | Why it is not a proof |
|----|---------------|-----------------------|
| `graceful-tree-conjecture` | All 560 non-isomorphic caterpillars with n ≤ 12 admit graceful labelings (Python, 0 failures). | Caterpillars are known graceful ∀n (Rosa 1967). No Lean. Sanity check only. Earlier "2,142 trees" was a representation-count bug caught by the Reviewer. |
| `schur-partition` | Finite certificates n ≤ 24 (DP) / n ≤ 12 (Finset), zero sorry, PR #27. | The ∀n identity later landed separately as `schur-partition-full` (T2). |
| `frobenius-coin-problem` | Shortlisted OPE-22 as Lean practice. | Two-coin theorem is **already** `frobeniusNumber_pair` in Mathlib. Dossier's "gap" claim was false. Process fuel only. |
| `sum-free-subsets` + 11 other `informal` rows | Correct classical maths + compute artifacts; Lean incomplete. | Lab rule: compute ≠ Lean. |

Stale `candidate` rows (`derangement-formula`, `catalan-recurrence`,
`bertrand-postulate-computational`, `van-der-waerden-w24`): all confirmed already in
Mathlib (or not one-wave for W(2,4)=35). Scout has repeatedly refused to re-prime them.

---

## 6. Director's read

1. **What we are good at:** landing small, zero-sorry Lean artifacts fast — ~87 files, all axiom-audited. The T2 rows (Ramsey numbers, Dirac, Schur ∀n, ES(3)=5) are real Mathlib-gap contributions.
2. **What we are not doing:** solving open problems. The two open bets are correctly held at Level A with bounded negative searches; no prize is claimable and none will be claimed without the board.
3. **Portfolio risk:** the Level A mill (OPE-1062 → OPE-1449, ~40 waves) produces `formalized` rows whose named theorems are unproved. That is honest per the notes, but the *count* of `formalized` overstates depth. The Scout's OPE-1467 **honest none** is the right signal that the cheap-witness supply is exhausted.
4. **Recommended next direction (not actioned here):** promote a handful of T1 rows to T2 (Level B namesake proofs — e.g. `ore-hamiltonian`, `konig-bipartite`, `erdos-ko-rado`) rather than opening more Level A slots. That is a Scout-shortlist decision, not a Director pick.

Principle restated: **feasibility-first; reject crackpottery; Lean-gated claims; board is the only voice for external claims.**
