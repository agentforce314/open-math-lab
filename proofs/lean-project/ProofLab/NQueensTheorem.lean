/-
n-queens — Level B namesake **statement pin** (OPE-4, Formalist; stub only).

status: known-classical, formalize-only, **no novelty claim**.
Parent OPE-2 (board-named "solve the n-queens problem"); Scout dossier
OPE-3 (`catalog/problems/n-queens/STATEMENT.md`, "Exact Lean-shaped
statement (Level B pin)"); Director gate released 2026-09-12.

This file pins the definition and the theorem *statement* only. The
`def`/`theorem` text below is copied verbatim from the Scout pin; the
proof is deliberately `sorry` and is owned by **OPE-6**. Nothing in
this file may reach `main` while `sorryAx` is in the axiom list.

Why a new file rather than editing `ProofLab/NQueens.lean`: the Level A
witnesses there (PR #174; `IsNQueens` list encoding, `queens_two_none`,
`queens_three_none`, `queens_four`) are landed, zero-`sorry`, and cited
as prior art. Keeping them untouched keeps that module green and lets
`lake build ProofLab.NQueensTheorem` be the single gate for the
namesake. We import `ProofLab.NQueens` so a later bridge lemma
(`IsNQueens (List.ofFn q) ↔ NonAttacking q`) can live here without
touching the Level A file.

Optional split `queens_exists_of_four_le` is included as a second stub
(so two `sorry`s total). Reason: the `⇐` direction of the iff splits
into `n = 0` / `n = 1` (trivial witnesses) and `n ≥ 4` (the explicit
`mod 6` construction), and the construction is the only hard part;
giving it its own name lets OPE-6 land and review it separately, and
lets `n_queens_exists_iff` be closed from it plus the `n = 2, 3`
nonexistence without re-opening the construction.

Bridge lemma to `IsNQueens` is **deferred** (not stubbed): it needs
`List.getElem_ofFn` / `List.nodup_ofFn` index plumbing, which is real
proof work and would be a third `sorry`; OPE-6 may add it if useful.

Convention (`n = 0`): `NonAttacking` on `Fin 0 → Fin 0` is vacuously
true (the empty placement), so the right-hand side is `n ≠ 2 ∧ n ≠ 3`
and the statement is total in `n`. This is intentional per the Scout
pin, not an oversight.

Expected `#print axioms n_queens_exists_iff` **at this stage**:
`[propext, sorryAx, Classical.choice, Quot.sound]` (or a subset
containing `sorryAx`). Expected when OPE-6 is done: no `sorryAx`.
-/
import Mathlib.Data.Fin.Basic
import Mathlib.Logic.Function.Defs
import Mathlib.Tactic
import ProofLab.NQueens

namespace ProofLab.NQueensTheorem

/-! ## Definition (verbatim from the Scout pin) -/

/-- `q i` is the column of the queen in row `i`. Non-attacking: distinct columns
(`Function.Injective q`, Mathlib `Logic/Function/Defs.lean` L101) and no two queens
on a common anti-diagonal (`i + q i`) or main diagonal (`i - q i`, written
subtraction-free as `i + q j ≠ j + q i`). Both diagonal families are load-bearing. -/
def NonAttacking {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j →
    (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ) ∧
    (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)

/-! ## Statement stubs (proofs owned by OPE-6) -/

/-- Optional split: existence for `n ≥ 4` by the explicit `mod 6` construction
(Hoffman–Loessi–Moore 1969 / Bernhardsson 1991). The hard direction of the
namesake, isolated so it can be landed and reviewed on its own. -/
theorem queens_exists_of_four_le (n : ℕ) (hn : 4 ≤ n) :
    ∃ q : Fin n → Fin n, NonAttacking q := by
  sorry -- STUB: proof in OPE-6

/-- Namesake. Existence iff `n ≠ 2 ∧ n ≠ 3` (n = 0 vacuous, n = 1 trivial,
n ≥ 4 by explicit construction). -/
theorem n_queens_exists_iff (n : ℕ) :
    (∃ q : Fin n → Fin n, NonAttacking q) ↔ (n ≠ 2 ∧ n ≠ 3) := by
  sorry -- STUB: proof in OPE-6

/-! ## Sanity checks (decide-level only; no proof search) -/

/-- The Level A `n = 4` witness `[1, 3, 0, 2]` satisfies the function-encoded
predicate. Confirms the encoding agrees with `ProofLab/NQueens.lean` on the
one concrete board both files know about. -/
example : NonAttacking ![1, 3, 0, 2] := by
  unfold NonAttacking
  decide

end ProofLab.NQueensTheorem
