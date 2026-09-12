/-
OPE-7 Adversarial Reviewer scratch file. NOT part of the ProofLab build.
Run from `proofs/lean-project` against the pinned artifact (`8ae158a`):

  export PATH="$HOME/.elan/bin:$PATH"
  lake env lean ../../attacks/n-queens-20260912-180329/review_checks.lean

Purpose: (1) `#print axioms` on both namesake theorems, independently of the
Formalist; (2) negative controls showing each clause of `NonAttacking` is
load-bearing; (3) evidence the diagonal clauses are over ℕ, not mod n.
The Formalist's file is not edited.
-/
import ProofLab.NQueensTheorem

open ProofLab.NQueensTheorem

/-! ## 1. Axioms -/
#print axioms n_queens_exists_iff
#print axioms queens_exists_of_four_le
#print axioms queens_two_none'
#print axioms queens_three_none'

/-! ## 2. Negative controls (each must be REJECTED by `NonAttacking`) -/

-- all four queens on the main diagonal (injective, anti-diagonals distinct)
example : ¬ NonAttacking ![0, 1, 2, 3] := by unfold NonAttacking; decide
-- all four on one anti-diagonal (injective, main diagonals distinct)
example : ¬ NonAttacking ![3, 2, 1, 0] := by unfold NonAttacking; decide
-- Director's non-injective control (also shares an anti-diagonal: rows 1,2)
example : ¬ NonAttacking ![1, 1, 0, 2] := by unfold NonAttacking; decide
-- pure injectivity failure: both diagonal clauses hold for the constant board
example : ¬ NonAttacking ![0, 0, 0, 0] := by unfold NonAttacking; decide
-- pure anti-diagonal failure: injective, all main diagonals distinct
example : ¬ NonAttacking ![1, 3, 2, 0] := by unfold NonAttacking; decide

/-! ## 3. Each clause is load-bearing: drop one clause and the matching
negative control is ACCEPTED. -/

/-- `NonAttacking` without injectivity. -/
def NoInj {n : ℕ} (q : Fin n → Fin n) : Prop :=
  ∀ i j : Fin n, i ≠ j →
    (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ) ∧
    (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)
/-- `NonAttacking` without the anti-diagonal clause. -/
def NoAnti {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j → (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)
/-- `NonAttacking` without the main-diagonal clause. -/
def NoMain {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j → (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ)

example : NoInj  ![0, 0, 0, 0] := by unfold NoInj;  decide
example : NoAnti ![1, 3, 2, 0] := by unfold NoAnti; decide
example : NoMain ![0, 1, 2, 3] := by unfold NoMain; decide

/-! ## 4. Diagonals are compared in ℕ, not mod n.
`![1, 3, 0, 2]` is accepted, yet mod 4 it would be rejected twice:
rows 0,3 have anti sums 1 and 5 (≡ mod 4); rows 1,2 have `1 + q 2 = 1`,
`2 + q 1 = 5` (≡ mod 4). Acceptance ⇒ the clauses are not modular. -/
example : NonAttacking ![1, 3, 0, 2] := by unfold NonAttacking; decide
example : ((0 : Fin 4) : ℕ) + ((1 : Fin 4) : ℕ) = 1 ∧
          ((3 : Fin 4) : ℕ) + ((2 : Fin 4) : ℕ) = 5 := by decide
-- a modular (toroidal) placement that is genuinely non-attacking on n = 5
example : NonAttacking ![0, 2, 4, 1, 3] := by unfold NonAttacking; decide

/-! ## 5. `n = 0` convention and the small cases, restated independently -/
example : NonAttacking (n := 0) (fun i => i) := by unfold NonAttacking; decide
example : ¬ (0 ≠ 2 ∧ 0 ≠ 3) → False := fun h => h ⟨by decide, by decide⟩
example : ¬ ∃ q : Fin 2 → Fin 2, NonAttacking q := (n_queens_exists_iff 2).not.mpr (by decide)
example : ¬ ∃ q : Fin 3 → Fin 3, NonAttacking q := (n_queens_exists_iff 3).not.mpr (by decide)

/-! ## 6. The constructions evaluated at the smallest boards of each class,
compared against independently brute-forced non-attacking boards. -/
example : (List.range 6).map (f₁ 6) = [1, 3, 5, 0, 2, 4] := by decide
example : NonAttacking ![1, 3, 5, 0, 2, 4] := by unfold NonAttacking; decide
-- (row 10 is the truncation row: LOG-typed ℕ-form would give 2, signed/Lean give 1)
example : (List.range 14).map (f₂ 14) = [6, 8, 10, 12, 0, 2, 4, 9, 11, 13, 1, 3, 5, 7] := by decide
example : f₂ 14 10 = 1 := by decide
example : NonAttacking ![6, 8, 10, 12, 0, 2, 4, 9, 11, 13, 1, 3, 5, 7] := by
  unfold NonAttacking; decide
-- corner extension of the n = 4 board to n = 5
example : (List.range 5).map (corner 4 (f₁ 4)) = [1, 3, 0, 2, 4] := by decide
example : NonAttacking ![1, 3, 0, 2, 4] := by unfold NonAttacking; decide
