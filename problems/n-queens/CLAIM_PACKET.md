# Claim packet — n-queens

**status:** DRAFT — board only
**prepared_at:** 2026-09-12T18:32:24Z (`mathforge claim prepare n-queens`, filled by Director, OPE-2)
**recommendation:** **NO CLAIM** — internal note only

## Claim (one sentence)

None. The lab has produced a **machine-checked Lean 4 proof of a classical theorem**
(Pauls 1874; Hoffman–Loessi–Moore 1969; Bernhardsson 1991): a non-attacking placement of
`n` queens on an `n × n` board exists iff `n ≠ 2 ∧ n ≠ 3`. There is no mathematical
novelty to claim; the deliverable is the artifact and the process record.

## Evidence

- [x] Lean theorem name + `lake build` log path
  - `ProofLab.NQueensTheorem.n_queens_exists_iff (n : ℕ) : (∃ q : Fin n → Fin n, NonAttacking q) ↔ (n ≠ 2 ∧ n ≠ 3)`
  - `ProofLab.NQueensTheorem.queens_exists_of_four_le (n : ℕ) (hn : 4 ≤ n) : ∃ q : Fin n → Fin n, NonAttacking q`
  - File: `proofs/lean-project/ProofLab/NQueensTheorem.lean` (new; Level A `ProofLab/NQueens.lean` from PR #174 untouched)
  - `lake build ProofLab.NQueensTheorem` → `✔ [2240/2240] Built ProofLab.NQueensTheorem`, zero `sorry` warnings — fresh `Built` (not `Replayed`) three times: Director (Gate 6, `8ae158a`), Reviewer (OPE-7, `attacks/n-queens-20260912-180329/review_checks.out`), Director on the integrated close-out branch.
  - `#print axioms`: `n_queens_exists_iff` → `[propext, Classical.choice, Quot.sound]`; `queens_exists_of_four_le` → `[propext, Quot.sound]`. No `sorryAx`, no `Lean.ofReduceBool`.
  - Toolchain: Lean 4.10.0 / Mathlib pin `a719ba5c31`, macOS arm64, user-local `elan` (`docs/LEAN_INSTALL_LOG.md`).
- [x] Informal writeup path
  - `catalog/problems/n-queens/STATEMENT.md` (Scout dossier + frozen pin, OPE-3/OPE-4)
  - `attacks/n-queens-20260912-180329/LOG.md` (Attack Lead construction, `status: informal`, with close-out **erratum** header — see residual 6)
- [x] Adversarial Reviewer sign-off issue id
  - **OPE-7 — APPROVE WITH RESIDUALS.** `attacks/n-queens-20260912-180329/ADVERSARIAL_REVIEW.md`. Statement fidelity checked cold with negative controls (`![0,1,2,3]`, `![3,2,1,0]`, `![1,3,2,0]`, `![0,0,0,0]` all rejected; weakened predicates `NoInj`/`NoAnti`/`NoMain` each accept the matching bad board ⇒ every clause of `NonAttacking` is load-bearing). Both Formalist-reported deviations from the attack log confirmed; the only hypothesis delta between log and Lean is `+ 4 ≤ n` on `e2_no_fix`.
- [x] Residual risks listed (below)

## What we are NOT claiming

- Not new mathematics. The theorem is ~150 years old; `expected: known-classical` throughout.
- Not priority in Mathlib. The Mathlib screen (zero named n-queens theorem at pin `a719ba5c31`) is a local-pin grep, not a literature or upstream survey.
- Nothing about readings (b) counting `Q(n)` (A000170), (c) Simkin asymptotics, (d) completion (NP-complete), or (e) toroidal n-queens (`gcd(n,6)=1`). Only reading (a) existence was funded and proved.
- Not that `NonAttacking` is "the" definition of the n-queens problem. It is one faithful encoding (rows `Fin n` → columns `Fin n`, injective, both diagonal families over ℕ, subtraction-free); fidelity is a human judgement made independently by Scout, Director and Reviewer.
- Not equivalence with the Level A list encoding `IsNQueens` (PR #174). Two encodings coexist; the bridge `IsNQueens (List.ofFn q) ↔ NonAttacking q` is unproved.
- Not "AI solved n-queens". No such language appears in any artifact, PR body, or ticket.

## Residual risks (board-facing, from OPE-7)

1. No Lean bridge between `NonAttacking` and the Level A `IsNQueens` list encoding.
2. Only reading (a) proved; (b)–(e) untouched.
3. Definition fidelity is a human judgement; a further independent reader is cheap.
4. Toolchain trust: single machine, no `lean4checker` re-check of the `.olean`.
5. No priority/novelty; Mathlib screen local-pin only.
6. `LOG.md` erratum (typed `f₂` P3/P4 ℕ-truncation; `e2_no_fix` missing `4 ≤ n`) — **fixed at close-out**, kept here for the record: the signed-int Python brute check could not see a ℕ-truncation bug that Lean caught. Process lesson: brute-force checks must run on the ℕ-typed formula, not a signed shadow.
7. `n ≠ 2 ∧ n ≠ 3` includes vacuous `n = 0`; do not paraphrase as `n = 1 ∨ n ≥ 4` in prose.
8. Unused `import ProofLab.NQueens` in the new file; harmless (`#print axioms`, not the build, is the gate).

## Recommended board action

- [ ] reject / no publish
- [ ] request more work
- [x] **internal note only** — merge PR #8 (integrates #3/#5/#6/#7 + this close-out), close #4 as superseded; ledger and catalog already say `formalized`, `no claim`.
- [ ] external draft (board writes)

Optional follow-ups the board may fund later (not recommended now; each is a separate Scout-gated ticket): the Level A ↔ Level B bridge lemma (residual 1); a `lean4checker` pass (residual 4); toroidal n-queens as a distinct catalog id (reading (e), Scout scored 80).
