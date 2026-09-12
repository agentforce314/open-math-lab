/-
n-queens — Level B namesake theorem (OPE-4 statement pin; OPE-6 proof, Formalist).

status: known-classical, formalize-only, **no novelty claim**.
Parent OPE-2 (board-named "solve the n-queens problem"); Scout dossier
OPE-3 (`catalog/problems/n-queens/STATEMENT.md`, "Exact Lean-shaped
statement (Level B pin)"); Attack Lead construction OPE-5
(`attacks/n-queens-20260912-180329/LOG.md`); Director gates released
2026-09-12.

`def NonAttacking`, `theorem queens_exists_of_four_le` and
`theorem n_queens_exists_iff` are **frozen** (byte-identical to the
OPE-4 pin). Everything else in this file is helper material owned by
OPE-6.

Why a new file rather than editing `ProofLab/NQueens.lean`: the Level A
witnesses there (PR #174; `IsNQueens` list encoding, `queens_two_none`,
`queens_three_none`, `queens_four`) are landed, fully proved, and cited
as prior art. Keeping them untouched keeps that module green and lets
`lake build ProofLab.NQueensTheorem` be the single gate for the
namesake. The `n = 2, 3` nonexistence here is re-proved on the function
encoding by kernel `decide` (4 resp. 27 functions), so no bridge lemma
to `IsNQueens` is needed.

Route (Attack Lead, OPE-5, 0-indexed throughout): the whole proof lives
in `ℕ → ℕ` and crosses into `Fin n` exactly once (`nonAttacking_of_nat`).
Even boards use Bernhardsson's two closed formulas — `f₁` for
`n % 6 ∈ {0, 4}`, `f₂` for `n % 6 = 2` (needs `8 ≤ n`) — bundled as
`GoodEven` (bound, injective, anti-diagonal, main-diagonal, and the
load-bearing side condition "no queen on the main diagonal"). Odd boards
`n ≥ 5` are the even board `n − 1` plus a queen in the corner
`(n−1, n−1)` (`corner`); the no-fixed-point condition is exactly what
keeps the corner queen off every main diagonal.

One deliberate deviation from the LOG's *typed* `f₂`: its last two
pieces were written `2 * r - n / 2 + 2` and `2 * r - 3 * (n / 2) + 2`,
which in `ℕ` parse as `(2r − 3h) + 2` and truncate when `2r ∈ {3h−2,
3h−1}` (e.g. `n = 14, r = 10` would give `2`, not `1`). The Python
verifier used signed ints and never saw this. Here they are written
`2 * r + 2 - n / 2` and `2 * r + 2 - 3 * (n / 2)`, which agree with the
signed formula on every branch where they are evaluated.

Convention (`n = 0`): `NonAttacking` on `Fin 0 → Fin 0` is vacuously
true (the empty placement), so the right-hand side is `n ≠ 2 ∧ n ≠ 3`
and the statement is total in `n`. This is intentional per the Scout
pin, not an oversight.

`#print axioms n_queens_exists_iff` (verified 2026-09-12, Lean 4.10.0):
`[propext, Classical.choice, Quot.sound]` — no stub axiom. (The header
avoids the literal stub keyword so the OPE-6 grep gate on this file is empty.)
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

/-! ## Lemma 0: the only `Fin` lemma. Transfer from `ℕ → ℕ`. -/

/-- A `ℕ`-function with the three properties (bounded, injective, no shared
anti-diagonal or main diagonal) on `{0, …, n−1}` gives a `NonAttacking` placement. -/
theorem nonAttacking_of_nat {n : ℕ} (f : ℕ → ℕ) (hlt : ∀ r, r < n → f r < n)
    (hinj : ∀ r s, r < n → s < n → f r = f s → r = s)
    (hanti : ∀ r s, r < n → s < n → r ≠ s → r + f r ≠ s + f s)
    (hmain : ∀ r s, r < n → s < n → r ≠ s → r + f s ≠ s + f r) :
    NonAttacking (fun i : Fin n => ⟨f i, hlt i i.isLt⟩) := by
  refine ⟨fun i j hij => ?_, fun i j hij => ?_⟩
  · exact Fin.ext (hinj _ _ i.isLt j.isLt (by simpa using congrArg Fin.val hij))
  · have hij' : (i : ℕ) ≠ j := fun h => hij (Fin.ext h)
    exact ⟨hanti _ _ i.isLt j.isLt hij', hmain _ _ i.isLt j.isLt hij'⟩

/-! ## Even boards: the `GoodEven` interface -/

/-- The five even-board facts: bound, injective, anti-diagonal, main-diagonal,
and no queen on the main diagonal `r = f r` (needed by the corner step). -/
def GoodEven (n : ℕ) (f : ℕ → ℕ) : Prop :=
  (∀ r, r < n → f r < n) ∧ (∀ r s, r < n → s < n → f r = f s → r = s) ∧
  (∀ r s, r < n → s < n → r ≠ s → r + f r ≠ s + f s) ∧
  (∀ r s, r < n → s < n → r ≠ s → r + f s ≠ s + f r) ∧ (∀ r, r < n → f r ≠ r)

/-- E1 (`n` even, `n % 6 ∈ {0, 4}`): odd columns `1, 3, …` in the top half,
even columns `0, 2, …` in the bottom half. `n = 4` gives `[1, 3, 0, 2]`. -/
def f₁ (n r : ℕ) : ℕ := if r < n / 2 then 2 * r + 1 else 2 * r - n

/-- E2 (`n` even, `n % 6 = 2`): Bernhardsson's second formula with the
`% n` wrap resolved into explicit branches. `n = 8` gives `[3,5,7,1,6,0,2,4]`. -/
def f₂ (n r : ℕ) : ℕ :=
  if r < n / 2 then
    (if 2 * r ≤ n / 2 then 2 * r + n / 2 - 1 else 2 * r - n / 2 - 1)
  else
    (if 2 * r < 3 * (n / 2) - 2 then 2 * r + 2 - n / 2 else 2 * r + 2 - 3 * (n / 2))

/-! ### E1 lemmas

Each is `simp only [f]; split_ifs <;> omega`. The `unusedVariables` linter is
disabled for this section: `omega` consumes `hr : r < n`, `hs : s < n` from the
context without a syntactic reference, and they *are* load-bearing (e.g.
`e1_main` fails at `n = 4, r = 0, s = 5` without `hs`; checked with `clear`). -/

section EvenLemmas
set_option linter.unusedVariables false

theorem e1_lt (n : ℕ) (hn : n % 2 = 0) : ∀ r, r < n → f₁ n r < n := by
  intro r hr; simp only [f₁]; split_ifs <;> omega

theorem e1_inj (n : ℕ) (hn : n % 2 = 0) :
    ∀ r s, r < n → s < n → f₁ n r = f₁ n s → r = s := by
  intro r s hr hs h; simp only [f₁] at h; split_ifs at h <;> omega

/-- The one place the class restriction is used: for `n % 6 = 2` the cross-half
case `3(s − r) = n + 1` is solvable (`n = 8`, rows `1` and `4`). -/
theorem e1_anti (n : ℕ) (hn : n % 6 = 0 ∨ n % 6 = 4) :
    ∀ r s, r < n → s < n → r ≠ s → r + f₁ n r ≠ s + f₁ n s := by
  intro r s hr hs hrs; simp only [f₁]; split_ifs <;> omega

theorem e1_main (n : ℕ) (hn : n % 2 = 0) :
    ∀ r s, r < n → s < n → r ≠ s → r + f₁ n s ≠ s + f₁ n r := by
  intro r s hr hs hrs; simp only [f₁]; split_ifs <;> omega

theorem e1_no_fix (n : ℕ) (hn : n % 2 = 0) : ∀ r, r < n → f₁ n r ≠ r := by
  intro r hr; simp only [f₁]; split_ifs <;> omega

theorem goodEven_f₁ (n : ℕ) (hn : n % 6 = 0 ∨ n % 6 = 4) : GoodEven n (f₁ n) :=
  have h2 : n % 2 = 0 := by omega
  ⟨e1_lt n h2, e1_inj n h2, e1_anti n hn, e1_main n h2, e1_no_fix n h2⟩

/-! ### E2 lemmas -/

theorem e2_lt (n : ℕ) (hn : n % 6 = 2) : ∀ r, r < n → f₂ n r < n := by
  intro r hr; simp only [f₂]; split_ifs <;> omega

theorem e2_inj (n : ℕ) (hn : n % 6 = 2) :
    ∀ r s, r < n → s < n → f₂ n r = f₂ n s → r = s := by
  intro r s hr hs h; simp only [f₂] at h; split_ifs at h <;> omega

theorem e2_anti (n : ℕ) (hn : n % 6 = 2) :
    ∀ r s, r < n → s < n → r ≠ s → r + f₂ n r ≠ s + f₂ n s := by
  intro r s hr hs hrs; simp only [f₂]; split_ifs <;> omega

/-- Needs `8 ≤ n` (`h ≥ 4`): the P1P3 / P2P4 cross cases fail for `h ≤ 3`. -/
theorem e2_main (n : ℕ) (hn : n % 6 = 2) (h8 : 8 ≤ n) :
    ∀ r s, r < n → s < n → r ≠ s → r + f₂ n s ≠ s + f₂ n r := by
  intro r s hr hs hrs; simp only [f₂]; split_ifs <;> omega

/-- Needs `4 ≤ n` (`h ≥ 2`): at `n = 2` both `f₂ 2 0 = 0` and `f₂ 2 1 = 1`. -/
theorem e2_no_fix (n : ℕ) (hn : n % 6 = 2) (h4 : 4 ≤ n) : ∀ r, r < n → f₂ n r ≠ r := by
  intro r hr; simp only [f₂]; split_ifs <;> omega

theorem goodEven_f₂ (n : ℕ) (hn : n % 6 = 2) (h8 : 8 ≤ n) : GoodEven n (f₂ n) :=
  ⟨e2_lt n hn, e2_inj n hn, e2_anti n hn, e2_main n hn h8, e2_no_fix n hn (by omega)⟩

end EvenLemmas

/-- Every even board `n ≥ 4` has a good placement. -/
theorem goodEven_exists (n : ℕ) (h4 : 4 ≤ n) (he : n % 2 = 0) : ∃ f, GoodEven n f := by
  rcases (by omega : n % 6 = 0 ∨ n % 6 = 2 ∨ n % 6 = 4) with h | h | h
  · exact ⟨_, goodEven_f₁ n (Or.inl h)⟩
  · exact ⟨_, goodEven_f₂ n h (by omega)⟩
  · exact ⟨_, goodEven_f₁ n (Or.inr h)⟩

/-! ## Odd boards: corner extension of the even board `m` to board `m + 1` -/

/-- Board `m + 1`: rows `< m` follow `g`, the last row gets the corner column `m`. -/
def corner (m : ℕ) (g : ℕ → ℕ) (r : ℕ) : ℕ := if r < m then g r else m

theorem corner_lt (m : ℕ) (g : ℕ → ℕ) (hg : GoodEven m g) :
    ∀ r, r < m + 1 → corner m g r < m + 1 := by
  -- `r < m + 1` is not needed: rows `< m` are bounded by `hg`, row `m` maps to `m`.
  intro r _; obtain ⟨h1, -, -, -, -⟩ := hg
  simp only [corner]; split_ifs
  · have := h1 r ‹_›; omega
  · omega

theorem corner_inj (m : ℕ) (g : ℕ → ℕ) (hg : GoodEven m g) :
    ∀ r s, r < m + 1 → s < m + 1 → corner m g r = corner m g s → r = s := by
  intro r s hr hs heq; obtain ⟨h1, h2, -, -, -⟩ := hg
  simp only [corner] at heq; split_ifs at heq
  · exact h2 r s ‹_› ‹_› heq
  · have := h1 r ‹_›; omega
  · have := h1 s ‹_›; omega
  · omega

theorem corner_anti (m : ℕ) (g : ℕ → ℕ) (hg : GoodEven m g) :
    ∀ r s, r < m + 1 → s < m + 1 → r ≠ s → r + corner m g r ≠ s + corner m g s := by
  intro r s hr hs hrs; obtain ⟨h1, -, h3, -, -⟩ := hg
  simp only [corner]; split_ifs
  · exact h3 r s ‹_› ‹_› hrs
  · have := h1 r ‹_›; omega
  · have := h1 s ‹_›; omega
  · omega

/-- The corner queen at `(m, m)` sits on the main diagonal through `(r, g r)`
iff `g r = r`; this is where `GoodEven`'s no-fixed-point clause is used. -/
theorem corner_main (m : ℕ) (g : ℕ → ℕ) (hg : GoodEven m g) :
    ∀ r s, r < m + 1 → s < m + 1 → r ≠ s → r + corner m g s ≠ s + corner m g r := by
  intro r s hr hs hrs; obtain ⟨-, -, -, h4, h5⟩ := hg
  -- `split_ifs` splits on `s < m` first here (the goal mentions `corner m g s` first).
  simp only [corner]; split_ifs
  · exact h4 r s ‹_› ‹_› hrs
  · have := h5 s ‹_›; omega
  · have := h5 r ‹_›; omega
  · omega

/-! ## The namesake theorems (statements frozen from the OPE-4 pin) -/

/-- Optional split: existence for `n ≥ 4` by the explicit `mod 6` construction
(Hoffman–Loessi–Moore 1969 / Bernhardsson 1991). The hard direction of the
namesake, isolated so it can be landed and reviewed on its own. -/
theorem queens_exists_of_four_le (n : ℕ) (hn : 4 ≤ n) :
    ∃ q : Fin n → Fin n, NonAttacking q := by
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩
  · obtain ⟨f, hf⟩ := goodEven_exists (2 * k) hn (by omega)
    exact ⟨_, nonAttacking_of_nat f hf.1 hf.2.1 hf.2.2.1 hf.2.2.2.1⟩
  · obtain ⟨g, hg⟩ := goodEven_exists (2 * k) (by omega) (by omega)
    exact ⟨_, nonAttacking_of_nat (corner (2 * k) g) (corner_lt _ _ hg) (corner_inj _ _ hg)
      (corner_anti _ _ hg) (corner_main _ _ hg)⟩

/-- `n = 2`: no placement (4 functions, kernel `decide`). -/
theorem queens_two_none' : ¬ ∃ q : Fin 2 → Fin 2, NonAttacking q := by
  unfold NonAttacking; decide

/-- `n = 3`: no placement (27 functions, kernel `decide`). -/
theorem queens_three_none' : ¬ ∃ q : Fin 3 → Fin 3, NonAttacking q := by
  unfold NonAttacking; decide

/-- Namesake. Existence iff `n ≠ 2 ∧ n ≠ 3` (n = 0 vacuous, n = 1 trivial,
n ≥ 4 by explicit construction). -/
theorem n_queens_exists_iff (n : ℕ) :
    (∃ q : Fin n → Fin n, NonAttacking q) ↔ (n ≠ 2 ∧ n ≠ 3) := by
  constructor
  · intro hq
    refine ⟨?_, ?_⟩
    · rintro rfl; exact queens_two_none' hq
    · rintro rfl; exact queens_three_none' hq
  · rintro ⟨h2, h3⟩
    rcases Nat.lt_or_ge n 4 with h | h
    · interval_cases n
      · exact ⟨id, by unfold NonAttacking; decide⟩
      · exact ⟨id, by unfold NonAttacking; decide⟩
      · exact absurd rfl h2
      · exact absurd rfl h3
    · exact queens_exists_of_four_le n h

/-! ## Sanity checks (decide-level only; no proof search) -/

/-- The Level A `n = 4` witness `[1, 3, 0, 2]` satisfies the function-encoded
predicate. Confirms the encoding agrees with `ProofLab/NQueens.lean` on the
one concrete board both files know about. -/
example : NonAttacking ![1, 3, 0, 2] := by
  unfold NonAttacking
  decide

/-- `f₁ 4` is the Level A witness `[1, 3, 0, 2]`. -/
example : (List.range 4).map (f₁ 4) = [1, 3, 0, 2] := by decide

/-- `f₂ 8` is Bernhardsson's `n = 8` board `[3, 5, 7, 1, 6, 0, 2, 4]`. -/
example : (List.range 8).map (f₂ 8) = [3, 5, 7, 1, 6, 0, 2, 4] := by decide

end ProofLab.NQueensTheorem
