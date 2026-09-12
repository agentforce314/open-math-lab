# n-queens — existence theorem (board-named, full-process run)

**id:** `n-queens`
**ticket:** OPE-3 Scout fresh dossier (parent OPE-2, board-named: "solve the
n-queens problem end to end using the whole process; assume the problem is new to you")
**expected:** `known-classical` — **formalize-only, no novelty claim, default no claim**
**recommended target:** **(a) existence** — for which `n` does a non-attacking
placement of `n` queens on an `n × n` board exist. Classical answer: **iff `n ≠ 2` and
`n ≠ 3`** (i.e. `n = 1` or `n ≥ 4`, plus the vacuous `n = 0`; see convention note).

## Disambiguation (which "n-queens problem" is the target)

Five things are called "the n-queens problem" in the literature. Scored on
`docs/FEASIBILITY_RUBRIC.md` (five axes × 0–20) in `DOSSIER.json`. Summary:

| # | Reading | Status in literature | Score | Verdict for the lab |
|---|---------|----------------------|------:|---------------------|
| **(a)** | **Existence:** placement exists ⇔ `n ∉ {2,3}` | settled (Pauls 1874; explicit constructions Hoffman–Loessi–Moore 1969, Bernhardsson 1991) | **88** | **TARGET.** `known-classical`, formalize-only: a full Lean proof of the namesake theorem is the deliverable |
| (b) | Counting `Q(n)` (OEIS A000170; `Q(8) = 92`) | no closed form known; terms known to `n = 27` | 54 | risky; "closed form" is not a well-posed target; `Q(8)=92` is at most a finite Level-A-style compute check — **out of scope** |
| (c) | Asymptotics `Q(n) = ((1±o(1)) n e^{-α})^n`, `α ≈ 1.942` (Simkin 2021) | settled at leading order; refinements open | 28 | long shot; entropy/absorption methods, nothing in Mathlib — **refuse** |
| (d) | Completion is NP-complete (Gent–Jefferson–Nightingale 2017) | settled | 36 | long shot; Mathlib has no NP-completeness framework — **refuse** |
| (e) | Toroidal/modular queens exist ⇔ `gcd(n,6) = 1` (Pólya 1918) | settled | 80 | prime-range but a **different theorem**, not the board-named namesake; candidate for a separate id `toroidal-queens` later — **out of scope here** |

Exactly one target: **(a)**. Reasons: it is the theorem people mean by "the n-queens
problem is solved"; it is finite-combinatorial with a clean `Fin n → Fin n` encoding;
it has a real reduction ladder (nonexistence for `n=2,3` by `decide`, existence for
`n ≥ 4` by an explicit construction split on `n mod 6`); Mathlib v4.10.0 has **no** named
n-queens theorem (see pre-screen), so a zero-`sorry` proof is a genuine ProofLab gap.
It is **not** open mathematics — nothing here is a research claim.

## Exact informal statement (target (a))

Let `n ∈ ℕ`. A *placement* is a function `q : {0,…,n−1} → {0,…,n−1}` (row `i` holds
one queen in column `q(i)`; one queen per row is built into the encoding). It is
*non-attacking* if

1. (columns) `q` is injective;
2. (anti-diagonals) for all `i ≠ j`, `i + q(i) ≠ j + q(j)`;
3. (main diagonals) for all `i ≠ j`, `i − q(i) ≠ j − q(j)` (as integers).

**Theorem (n-queens existence).** A non-attacking placement exists **iff** `n ≠ 2` and
`n ≠ 3`.

Convention note (**definition risk #1**): under this encoding `n = 0` has the empty
placement, so the right-hand side is `n ≠ 2 ∧ n ≠ 3` rather than the textbook
"`n = 1` or `n ≥ 4`". Both are the same theorem for `n ≥ 1`; the pin below fixes
the `n ≠ 2 ∧ n ≠ 3` form so the Lean statement is total in `n`.

## Exact Lean-shaped statement (Level B pin)

Function encoding, `Fin n → Fin n`, row ↦ column. Condition 3 is written **without
natural-number subtraction** as `i + q j ≠ j + q i` (equivalent to `i − q i ≠ j − q j`
over `ℤ`; this is the same trick as the landed list encoding in
`proofs/lean-project/ProofLab/NQueens.lean`).

```lean
import Mathlib.Data.Fin.Basic
import Mathlib.Logic.Function.Defs
import Mathlib.Tactic

namespace ProofLab.NQueensTheorem

/-- `q i` is the column of the queen in row `i`. Non-attacking: distinct columns
(`Function.Injective q`, Mathlib `Logic/Function/Defs.lean` L101) and no two queens
on a common anti-diagonal (`i + q i`) or main diagonal (`i - q i`, written
subtraction-free as `i + q j ≠ j + q i`). Both diagonal families are load-bearing. -/
def NonAttacking {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j →
    (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ) ∧
    (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)

/-- Namesake. Existence iff `n ≠ 2 ∧ n ≠ 3` (n = 0 vacuous, n = 1 trivial,
n ≥ 4 by explicit construction). -/
theorem n_queens_exists_iff (n : ℕ) :
    (∃ q : Fin n → Fin n, NonAttacking q) ↔ (n ≠ 2 ∧ n ≠ 3) := by
  sorry -- NOT to be landed as sorry; this is the pin, not a proof.

end ProofLab.NQueensTheorem
```

Hypotheses: none beyond `n : ℕ`. No `Decidable` instance is required for the statement
(the `∀ i j : Fin n` body is decidable for concrete `n`, which is how the `n = 2, 3`
direction is expected to go).

### Suggested proof ladder (for Director / Formalist planning — Scout does not solve)

- **B1 (⇒):** `n = 2` and `n = 3` have no placement. `Fin 2 → Fin 2` has 4 functions,
  `Fin 3 → Fin 3` has 27; `decide` / `fin_cases` on the function is expected to close it.
  Reusing PR #174's `queens_two_none` / `queens_three_none` through a bridge is
  **optional**, not required.
- **B2 (⇐):** for `n ≥ 4` exhibit a placement. Literature construction
  (Hoffman–Loessi–Moore 1969; Bernhardsson 1991; Wikipedia "Eight queens puzzle →
  Explicit solutions", stated **1-indexed**):
  1. if `n mod 6 ∉ {2, 3}`: columns `[2, 4, 6, …] ++ [1, 3, 5, …]` (even list then odd list, each `≤ n`);
  2. if `n mod 6 = 2`: even list, then odd list with `1, 3` swapped and `5` moved to the end;
  3. if `n mod 6 = 3`: even list with `2` moved to the end, odd list with `1, 3` moved to the end.

  Row `i` takes the `i`-th entry. Case 1 alone covers `n ≡ 0, 1, 4, 5 (mod 6)`; cases 2
  and 3 are the fiddly ones. Diagonal checks are linear inequalities with a `mod 6`
  side condition, so `omega` after unfolding is the expected engine.
- **Bridge (optional glue, Level C, not required for done):**
  `IsNQueens (List.ofFn q) ↔ NonAttacking q`. Recommendation: **leave
  `ProofLab/NQueens.lean` untouched**; land the namesake in a new file
  (`ProofLab/NQueensTheorem.lean` or similar) so PR #174's Level A stays green and
  citable as prior art.

## What counts as done

1. `lake build` of the new file exits 0 with `n_queens_exists_iff` **exactly** as
   pinned (name may vary; statement may not).
2. `#print axioms n_queens_exists_iff` shows only `propext` / `Classical.choice` /
   `Quot.sound` — **no `sorryAx`**.
3. Adversarial Reviewer written approval of the **definition** `NonAttacking`
   (injectivity present; both diagonal families present; subtraction-free encoding
   checked equivalent to `i − q i ≠ j − q j`; `n = 0` convention stated).
4. Ledger + catalog row updated to `formalized (Level B)`; **no claim packet** — the
   theorem is classical and this is a formalization exercise.

Honest partial (e.g. B1 + B2 case 1 only, `n ≡ 2, 3 (mod 6)` residual) is allowed
**if commented as residual, never `sorry`-ed**.

## Out of scope (do not expand this id)

- (b) `Q(n)` counting / `Q(8) = 92` / OEIS A000170 — not part of the namesake;
  `Q(8)=92` by kernel `decide` is likely too slow and `native_decide` is not an
  accepted gate.
- (c) Simkin asymptotics; (d) NP-completeness of completion; (e) toroidal/modular
  queens (Pólya) — separate theorems, separate ids if ever wanted.
- Uniqueness up to symmetry, fundamental solutions (A002562), superqueens, 3-D queens,
  Latin-square / Langford / Gray-code / Lights-Out / mutilated-chessboard bridges
  (consumed #157/#160/#163/#181/#177 — different theorems).
- Any "AI discovers a pattern" framing. Everything here is a transcription of a
  published construction into Lean.

## Prior art inside this repo (cite, do not hide)

- `proofs/lean-project/ProofLab/NQueens.lean` — **Level A**, PR #174 (Scout OPE-1419,
  Director OPE-1423, Formalist OPE-1424): list encoding `IsNQueens : List (Fin n) → Prop`;
  `queens_two_none`, `queens_three_none`, `queens_four ([1,3,0,2])`, `queens_four_alt
  ([2,0,3,1])`; zero `sorry`. The namesake was explicitly left as residual there.
  Reusable: the diagonal-inequality encoding and the `n = 4` witness (which equals
  construction case 1 for `n = 4`: `[2,4,1,3]` 1-indexed = `[1,3,0,2]` 0-indexed).

## Literature handles

- Bezzel 1848 (8-queens puzzle posed); Nauck 1850 (92 solutions); Gauss–Schumacher
  correspondence 1850 (8×8 count only — **not** the general-`n` theorem).
- **Pauls 1874** — first proof of existence for all `n ≥ 4` (Deutsche Schachzeitung).
- Ahrens 1910, *Mathematische Unterhaltungen und Spiele* — textbook treatment.
- **Hoffman, Loessi, Moore 1969**, "Constructions for the solution of the m queens
  problem", *Math. Magazine* 42(2), 66–72 — explicit `mod 6` construction.
- **Bernhardsson 1991**, "Explicit solutions to the N-queens problem for all N",
  *SIGART Bull.* 2(2), 7 — one-page explicit construction (the one transcribed above).
- **Bell & Stevens 2009**, "A survey of known results and research areas for n-queens",
  *Discrete Math.* 309(1), 1–31 — survey; confirms (a) settled, (b) open-ended, (e) Pólya.
- Pólya 1918 (toroidal, in Ahrens); Simkin 2021 arXiv:2107.13460 (asymptotics);
  Gent, Jefferson, Nightingale 2017 *JAIR* 59, 815–848 (completion NP-complete).
- OEIS: A000170 (`Q(n)`), A002562 (fundamental solutions), A051906 (toroidal).

## Novelty pre-screen (local Mathlib pin only, OPE-25)

Pin: `proofs/lean-project/.lake/packages/mathlib` @ `a719ba5c31` (Lean `v4.10.0`).

```
rg -n -i 'nqueens|n_queens|eightqueens|eight_queens|isqueens|queens_problem|queensproblem|non.?attacking' Mathlib Archive Counterexamples
→ no hits (exit 1)
rg -n -i '\bqueens?\b' Mathlib Archive Counterexamples
→ Mathlib/GroupTheory/PushoutI.lean:36  "from Queen Mary University"   (comment only)
```

Negative control: `isTuranMaximal_iff_nonempty_iso_turanGraph` at
`Mathlib/Combinatorics/SimpleGraph/Turan.lean:300` — grep is sound.
Infra HIT (use, do not re-prove): `Function.Injective` (`Logic/Function/Defs.lean:101`),
`Fin`, `Nat.ModEq` (`Data/Nat/ModEq.lean`), `omega`, `decide`, `fin_cases`.
In-repo: `ProofLab/NQueens.lean` Level A only (above). **Verdict: genuine ProofLab
gap for the namesake; `expected: known-classical`.**
