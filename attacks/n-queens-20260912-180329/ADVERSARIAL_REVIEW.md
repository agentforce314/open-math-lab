# Adversarial review — n-queens namesake (OPE-7)

**Reviewer:** Adversarial Reviewer (Paperclip agent). **Date:** 2026-09-12.
**Artifact under review:** `origin/ope/6-nqueens-proof` @ `8ae158a` (branch had not moved at review time),
file `proofs/lean-project/ProofLab/NQueensTheorem.lean`, namespace `ProofLab.NQueensTheorem`,
theorems `n_queens_exists_iff` and `queens_exists_of_four_le`.
**Companion:** `review_checks.lean` (this directory) — my scratch file; the Formalist's file was not edited.

## Verdict: **APPROVE WITH RESIDUALS**

The Lean statement says n-queens, the build is green from a cold rebuild of the module, there is no
`sorry`/`admit`/stub axiom, the axiom set is standard, every negative control is rejected, and the
Formalist's two reported deviations from the attack log are both confirmed as correct fixes. No
defect found in the proof. The residuals below are scope/trust boundaries, not defects; one of them
is an **erratum in `LOG.md`** that the close-out must record.

Claim posture: **no claim**. This is a classical theorem (Pauls 1874; Hoffman–Loessi–Moore 1969;
Bernhardsson 1991). The deliverable is the machine-checked artifact.

---

## 1. Fresh rebuild and axioms (my own, not the Formalist's)

`git checkout 8ae158a`; deleted `.lake/build/lib/ProofLab/NQueensTheorem.{olean,ilean,trace,*.hash}`
(confirmed absent before build); `lake build ProofLab.NQueensTheorem`:

```
Lean (version 4.10.0, arm64-apple-darwin23.5.0, commit c375e19f6b65, Release)
✔ [2240/2240] Built ProofLab.NQueensTheorem
Build completed successfully.
lake build ProofLab.NQueensTheorem  7.04s user 3.53s system 67% cpu 15.593 total
exit=0
```

`Built`, not `Replayed`. `lake env lean review_checks.lean` (full output, exit 0):

```
'ProofLab.NQueensTheorem.n_queens_exists_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'ProofLab.NQueensTheorem.queens_exists_of_four_le' depends on axioms: [propext, Quot.sound]
'ProofLab.NQueensTheorem.queens_two_none'' depends on axioms: [propext, Classical.choice, Quot.sound]
'ProofLab.NQueensTheorem.queens_three_none'' depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`, no `Lean.ofReduceBool`. `Classical.choice` enters through Mathlib's `Fintype`
decidability instances used by kernel `decide` on `Fin 2 → Fin 2` / `Fin 3 → Fin 3`, which is
standard and expected.

**Keyword grep** (`sorry|admit|axiom|native_decide|implemented_by|extern|unsafe|partial|decide`):

| line | hit | judgement |
|---|---|---|
| 22, 48–49, 231, 235, 257 | `decide` / `axioms` in comments | prose only |
| 233, 237 | `unfold NonAttacking; decide` on `Fin 2`, `Fin 3` function spaces | kernel `decide`, 4 resp. 27 functions — fine, and confirmed by the axiom list |
| 251–252 | `decide` on `Fin 0`, `Fin 1` boards with `q = id` | trivial |
| 264, 267, 270 | `decide` on concrete `n = 4`, `n = 8` lists | sanity examples, not load-bearing |

No `sorry`, `admit`, `axiom` declaration, `native_decide`, `implemented_by`, `extern`, `unsafe`,
or `partial` anywhere in the file. `set_option linter.unusedVariables false` (line 114) is a linter
switch, not a soundness switch; the justification in the comment (`omega` consumes `hr`/`hs`
without a syntactic reference) is correct.

## 2. Statement fidelity (read cold, `NQueensTheorem.lean:65-69`)

```lean
def NonAttacking {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j →
    (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ) ∧
    (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)
```

- **Rows** = the function domain `Fin n`: exactly one queen per row, `n` queens total. ✔
- **Columns** = the codomain `Fin n`. ✔
- **Distinct columns** = `Function.Injective q`. ✔
- **Anti-diagonals**: `i + q i` is the anti-diagonal index; the clause says two distinct rows never
  share it. ✔
- **Main diagonals**: `i − q i = j − q j` rewritten subtraction-free as `i + q j = j + q i`; the
  clause forbids it for `i ≠ j`. ✔ Both coercions `(i : ℕ)` happen *before* `+`, so the sums are in
  **ℕ, not `Fin n` (mod n)**. Independent evidence in `review_checks.lean` §4: `![1, 3, 0, 2]` is
  accepted although mod 4 it would fail twice (anti sums 1 ≡ 5 for rows 0,3; `1 + q 2 = 1 ≡ 5 = 2 + q 1`
  for rows 1,2).
- **Not vacuous, not over-strong**: `queens_two_none'`/`queens_three_none'` prove the predicate is
  unsatisfiable at `n = 2, 3` (so it is not trivially satisfiable), and concrete boards for
  `n = 4, 5, 6, 8, 14` are accepted by `decide` (so it is not unsatisfiable).
- **Frozen text**: `def NonAttacking`, both theorem statements are byte-identical to
  `catalog/problems/n-queens/STATEMENT.md` (checked with `diff` on the pinned checkout).
- **`n = 0` convention**: `Fin 0 → Fin 0` is vacuously `NonAttacking`, so the RHS is
  `n ≠ 2 ∧ n ≠ 3` rather than "`n = 1 ∨ n ≥ 4`". Stated in `STATEMENT.md` ("Convention note
  (definition risk #1)", and again at line 208 on the Scout branch), in the Lean header (lines 43–46),
  and in the theorem docstring. Intended, consistent across all three, and mathematically the same
  theorem for `n ≥ 1`.
- **Hypothesis of `queens_exists_of_four_le`** is `4 ≤ n` — exactly the classical existence range;
  nothing silently stronger. The namesake itself has no hypothesis.

**Negative controls** (`review_checks.lean` §2–3, all checked by kernel `decide`, exit 0):

| board | fails only | `NonAttacking` | weakened predicate accepts it |
|---|---|---|---|
| `![0, 1, 2, 3]` | main diagonal | rejected ✔ | `NoMain` ✔ |
| `![3, 2, 1, 0]` | anti-diagonal | rejected ✔ | — |
| `![1, 3, 2, 0]` | anti-diagonal | rejected ✔ | `NoAnti` ✔ |
| `![0, 0, 0, 0]` | injectivity | rejected ✔ | `NoInj` ✔ |
| `![1, 1, 0, 2]` (Director's) | injectivity **and** anti (rows 1,2 sum to 2) | rejected ✔ | not a single-clause control; replaced by `![0,0,0,0]` above |

Each of the three clauses is load-bearing: dropping it admits a board the full predicate rejects.
A brute-force enumeration of all 256 `Fin 4 → Fin 4` functions (Python, during review) was used to
pick boards failing exactly one clause (the enumeration also confirms that exactly two of the 256
functions are accepted, `![1, 3, 0, 2]` and `![2, 0, 3, 1]`, the two classical `n = 4` solutions).

## 3. The Formalist's two reported deviations

**(a) `f₂` P3/P4 — CONFIRMED, and it is an erratum for `LOG.md`.** The LOG's typed Lean
(`LOG.md`, "Lean-shaped lemma list") writes P4 as `2 * r - 3 * (n / 2) + 2`, which in ℕ parses as
`(2r − 3h) + 2` and truncates whenever `2r ∈ {3h − 2, 3h − 1}`. That row exists on **every** board
of the class (`2r` even, so one of `3h−2`, `3h−1` is hit with `h ≤ r < 2h`). My own check
(independent Python, `n ≡ 2 (mod 6)`, `8 ≤ n ≤ 1000`, all `r < n`):

```
boards n%6==2, 8<=n<=1000: 166
Lean N-form vs signed: mismatches = 0
LOG typed N-form vs signed: mismatches = 166; first 5 = [(8, 5, 2, 0), (14, 10, 2, 1), (20, 14, 2, 0), (26, 19, 2, 1), (32, 23, 2, 0)]
n=14 witnesses: LOG-typed f2(14,10)=2  signed=1  Lean=1
```

The Lean form `2 * r + 2 - 3 * (n / 2)` (line 104) agrees with the signed formula on all 166 boards;
the LOG's typed ℕ-form disagrees on exactly one row per board and would have made `e2_inj` false
(e.g. `n = 8`: row 5 would get column 2, colliding with row 6). The P3 rewrite (`2r − h + 2` →
`2r + 2 − h`) is cosmetic: with `r ≥ h` it never truncates. The LOG's *mathematics* and its Python
verifier (signed ints, `verify_construction.py:43-44`) were correct; only the typed-Lean transcription
was wrong. **Erratum to record in `LOG.md`:** the `f₂` block under "Lean-shaped lemma list" must read
`2 * r + 2 - n / 2` / `2 * r + 2 - 3 * (n / 2)`, and the sentence "`verify_construction.py` implements
`f₁`, `f₂`, `f` verbatim from this file" should say "the signed forms of".

**(b) `e2_no_fix` needs `4 ≤ n` — CONFIRMED.** LOG: "P4 `r = 3h − 2 ≥ 2h` (as `h ≥ 2`)" with no
hypothesis supplying `h ≥ 2`. Under `n % 6 = 2` alone, `n = 2` is a counterexample (`f₂ 2 0 = 0`,
`f₂ 2 1 = 1`, both fixed points). The landed lemma (line 159) adds `(h4 : 4 ≤ n)`; the assembly
`goodEven_f₂` (line 163) discharges it with `by omega` from its own `8 ≤ n`, which `goodEven_exists`
(line 171) supplies from `4 ≤ n ∧ n % 6 = 2`. Nothing is lost downstream.

**Hypothesis diff, LOG typed list vs landed file** (every declaration):

| declaration | LOG hypotheses | landed hypotheses | delta |
|---|---|---|---|
| `nonAttacking_of_nat` | `hlt hinj hanti hmain` | same | none |
| `GoodEven`, `f₁`, `corner` | — | same text | none |
| `f₂` | typed ℕ-form (truncating) | `2*r+2-h`, `2*r+2-3h` | body fix, see (a) |
| `e1_lt`, `e1_inj`, `e1_main`, `e1_no_fix` | `n % 2 = 0` | same | none |
| `e1_anti`, `goodEven_f₁` | `n % 6 = 0 ∨ n % 6 = 4` | same | none |
| `e2_lt`, `e2_inj`, `e2_anti` | `n % 6 = 2` | same | none |
| `e2_main`, `goodEven_f₂` | `n % 6 = 2`, `8 ≤ n` | same | none |
| `e2_no_fix` | `n % 6 = 2` | `n % 6 = 2`, **`4 ≤ n`** | **+ `4 ≤ n`** (needed, see (b)) |
| `goodEven_exists` | `4 ≤ n`, `n % 2 = 0` | same | none |
| `corner_lt/inj/anti/main` | sketched "`(hg : GoodEven m g)` … for board `m + 1`" | `∀ r s, r < m+1 → s < m+1 → …` | none (sketch made concrete) |
| `queens_exists_of_four_le` | `4 ≤ n` | same (frozen) | none |
| `queens_two_none'`, `queens_three_none'`, `n_queens_exists_iff` | not in LOG (assigned to OPE-6) | landed | new, in scope per LOG "Target" |

No hypothesis was weakened; the only addition is the one the Formalist reported.

## 4. Attack log vs. formalization

- Every case in `LOG.md` is formalized by the route the LOG describes: E1 (`n%6 ∈ {0,4}`), E2
  (`n%6 = 2`, `n ≥ 8`), corner extension for odd `n ≥ 5` via the `GoodEven` interface with the
  no-fixed-point clause used exactly in `corner_main` (line 213–214). The LOG's "Alt" knight route was
  not used, as recommended.
- Nothing in the Lean file is proved by a route the LOG does not describe, except the small cases
  `n = 0, 1` (`q = id`, `decide`) and `n = 2, 3` (kernel `decide`), which the LOG explicitly delegated
  to OPE-6.
- **No case rests on `verify_construction.py`.** The Lean file does not reference it; the only
  computation in the proof is kernel `decide` on `Fin 0..3` and on three concrete lists. The Python
  brute check remains evidence for the informal log only.

## 5. Scope and claim posture

Checked `STATEMENT.md` (PR #3, plus the appended pin section from PR #4 as carried on `8ae158a`),
`LOG.md` (PR #5), the Lean header, and PR bodies #3/#4/#5/#6:

- `expected: known-classical`, "formalize-only", "no novelty claim", "default no claim" appear in
  each artifact. PR #3: "Claim status: none … nothing solved." PR #5: "no Lean compiled, no novelty
  claim." PR #6: "known-classical, formalize-only, no novelty claim … the proof is only as good as the
  pin." Nothing reads as novelty or "AI solved n-queens".
- Readings **(b)** counting `Q(n)`, **(c)** Simkin asymptotics, **(d)** completion NP-completeness,
  **(e)** toroidal/Pólya are each listed in `STATEMENT.md` "Out of scope (do not expand this id)"
  with (c)/(d) marked **refuse** and (e) "a different theorem". The Lean file proves only reading (a).
- Novelty pre-screen: the dossier's "ZERO named n-queens theorem" is against the **local** Mathlib
  pin `a719ba5c31` (v4.10.0) only, and is phrased that way. This is a Mathlib-gap statement, not a
  priority claim, and must not be upgraded to one (see residuals).
- Process nit: the ticket suggested `python3 bin/mathforge review n-queens`; no `review` subcommand
  exists (`status|catalog|score|problem|attack|claim`). `docs/REVIEW_CHECKLIST.md` was used instead;
  all nine mechanical items pass, none of the crackpot flags apply.

## 6. Machine-trust boundary (for the board)

"Lean checked it" here means: the Lean 4.10.0 kernel accepted a term of type
`∀ n, (∃ q : Fin n → Fin n, NonAttacking q) ↔ (n ≠ 2 ∧ n ≠ 3)` using only the three standard
axioms (`propext`, `Classical.choice`, `Quot.sound`) plus the Mathlib pin's own definitions. This
certifies that the *formal* proposition follows from those axioms, modulo trusting the Lean kernel,
the `elan`-installed toolchain binary, the Mathlib `.olean` cache on this Mac, and the `lake` build
graph. It does **not** certify that `NonAttacking` is the right predicate — that is a human judgement,
and it is mine (section 2): I read it cold, matched each clause to the chess rule, and exercised it
with boards that fail exactly one clause. It also does not certify anything about counting,
asymptotics, completion, or toroidal queens, nor does it connect to the Level A list encoding in
`ProofLab/NQueens.lean`. Kernel `decide` on 4 and 27 functions is ordinary reduction inside the
trusted kernel; no `native_decide`/`ofReduceBool` shortcut was used anywhere.

## Residual risks (non-empty, honest)

1. **Encoding bridge missing.** There is no Lean lemma relating `NonAttacking q` to the Level A
   `IsNQueens (List.ofFn q)` encoding (PR #4 deferred it). Two independent encodings of "n-queens"
   coexist in the repo; they agree on the one board both know (`[1,3,0,2]`, line 262) and on the
   nonexistence at `n = 2, 3` (proved separately in each), but equivalence is unproved.
2. **Scope.** Only reading (a) is proved. Counting `Q(n)`, asymptotics, completion, toroidal queens
   are out of scope and unproved; nothing here should be read as progress on them.
3. **Definition fidelity is a human judgement** (section 2). I consider it sound; a second reader is
   cheap and appropriate before any board-facing summary.
4. **Toolchain trust.** Lean 4.10.0, Mathlib pin `a719ba5c31`, user-local `elan` install, prebuilt
   Mathlib `.olean` cache. No independent re-check on a second machine or with a separate checker
   (e.g. `lean4checker`).
5. **Literature priority.** None claimed and none should be; the result is 150 years old. The
   "no named theorem in Mathlib" screen is local-pin-only and may be stale against upstream Mathlib.
6. **`LOG.md` erratum** (section 3a): the typed `f₂` in the attack log is not the function that was
   proved. Until the log is corrected, the informal artifact and the formal artifact disagree on one
   row per `n ≡ 2 (mod 6)` board. Owner: OPE-5 close-out / Director.
7. **`n = 0` convention.** The theorem is stated as `n ≠ 2 ∧ n ≠ 3`, which includes the vacuous
   `n = 0` board. Any prose that says "`n = 1` or `n ≥ 4`" is equivalent only for `n ≥ 1`; keep the
   two phrasings from being conflated in a claim packet.
8. **Unused import.** `import ProofLab.NQueens` (line 55) is not used by any proof. Harmless, but it
   means the namesake module's build depends on the Level A module staying green; `#print axioms`
   (not the build) is the actual gate.

## Recommendation to Director

Merge PR #6 after PRs #3/#4/#5 (or in any order — only one Lean file changed and the `STATEMENT.md`
hunks are the same as #4's). Fix the `LOG.md` erratum at close-out. **No claim packet** beyond the
internal ledger entry: known-classical, machine-checked, no novelty.
