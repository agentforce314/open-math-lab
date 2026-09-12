# Attack log — n-queens-20260912-180329

**problem:** n-queens — Level B namesake, existence for `n ≥ 4` (OPE-5, Attack Lead)
**strategy:** explicit-construction-0-indexed
**started:** 2026-09-12T18:03:29Z
**budget:** 60,000 tokens
**status: informal** — nothing below is a proof until OPE-6's `lake build` is green with no `sorryAx`.
**Novelty: none.** Classical theorem (Pauls 1874; Hoffman–Loessi–Moore 1969; Bernhardsson 1991). The lab deliverable is the machine-checked artifact, not the mathematics.

## Target (frozen by Director, OPE-4 pin, `ProofLab.NQueensTheorem`)

```lean
def NonAttacking {n : ℕ} (q : Fin n → Fin n) : Prop :=
  Function.Injective q ∧
  ∀ i j : Fin n, i ≠ j →
    (i : ℕ) + (q i : ℕ) ≠ (j : ℕ) + (q j : ℕ) ∧
    (i : ℕ) + (q j : ℕ) ≠ (j : ℕ) + (q i : ℕ)

theorem queens_exists_of_four_le (n : ℕ) (hn : 4 ≤ n) : ∃ q : Fin n → Fin n, NonAttacking q
```

Only `queens_exists_of_four_le` is in scope here. `n = 0, 1, 2, 3` belong to OPE-6.

## Attempts

| timestamp | action | result | tokens |
|-----------|--------|--------|--------|
| 18:00 | Gate 2 released; re-read pin on `origin/ope/4-nqueens-statement-pin`, branch `ope/5-nqueens-attack` from `origin/main` | pin text identical to Director's quote | ~5k |
| 18:03 | Derive 0-indexed forms by hand (E1, E2, odd corner extension); considered and rejected 1-indexed "list surgery" for `n%6=2` and toroidal+corner for odd `n` (dead ends 1, 2) | 3 formulas, 1 side condition | ~15k |
| 18:05 | `verify_construction.py 1000` — clauses evaluated verbatim, all ordered pairs | **PASS** all 997 boards, all 4 checks, first run; no formula slip to log | ~5k |
| 18:10 | Write lemma arguments, Lean-shaped lemma list, hazards | this file | ~15k |

## Indexing convention (read this once)

**Everything below is 0-indexed**: rows `r ∈ {0,…,n−1}`, columns `q r ∈ {0,…,n−1}`, exactly as `Fin n` reads them. The 1-indexed source is Bernhardsson, "Explicit solutions to the N-queens problem for all N", SIGART Bull. 2(2):7 (1991): his formulas are `(i, 2i)`, `(n/2+i, 2i−1)` for `n%6≠2`, and `(i, 1+(2(i−1)+n/2−1) mod n)`, `(n+1−i, n−(2(i−1)+n/2−1) mod n)` for `n%6≠0`, plus "odd `n`: solve `n−1`, add `(n,n)`". That sentence is the only 1-indexed text in this log. Scout's risk R3 (off-by-one in transcription) is discharged by (a) subtracting 1 from row and column of each pair and (b) the brute check below, which evaluates the pin's clauses on the 0-indexed formulas directly.

## The construction (partition: even/`n%6≠2`, even/`n%6=2`, odd)

Three formulas instead of six residue classes. Why: the odd classes `1, 3, 5 mod 6` are all handled by **one** generic lemma (corner extension of the even `n−1` board), which needs only that the even solution has no queen on the main diagonal. That keeps the whole proof in one tactic flavour (`omega` after `split_ifs`) and avoids `ZMod`/`Nat.ModEq` entirely. The `2r % n` "knight" formula for `gcd(n,6)=1` is recorded as an optional alternative (§Alt) — it is also machine-checked — but it needs a second proof technique and still leaves `n%6=3` to the corner extension, so it buys nothing.

Throughout `h := n / 2` (`Nat` division). For even `n`, `n = 2h`.

### E1 — `n` even, `n % 6 ∈ {0, 4}`

```
f₁ n r := if r < h then 2*r + 1 else 2*r - n            -- second branch = 2*(r - h)
```
Values: odd columns `1,3,…,n−1` in rows `0..h−1`; even columns `0,2,…,n−2` in rows `h..n−1`. (`n = 4`: `[1,3,0,2]`, the Level A witness.)

- **`e1_lt`** (`r < n → f₁ n r < n`): `r < h ⇒ 2r+1 ≤ 2h−1 = n−1`; `r ≥ h ⇒ 2r−n ≤ 2(n−1)−n = n−2`. `omega`.
- **`e1_inj`** (`r, s < n → f₁ n r = f₁ n s → r = s`): same half ⇒ `2r+1 = 2s+1` or `2r−n = 2s−n` ⇒ `r = s`. Cross half ⇒ `2r+1 = 2s−n` with `n` even: odd = even, impossible. `omega` (it does parity on literal `2`).
- **`e1_anti`** (`r ≠ s → r + f₁ n r ≠ s + f₁ n s`), needs `n % 3 ≠ 2` i.e. `n % 6 ∈ {0,4}`: same half ⇒ `3r+1 = 3s+1` or `3r−n = 3s−n` ⇒ `r = s`. Cross (`r < h ≤ s`) ⇒ `3r+1 = 3s−n` ⇒ `3(s−r) = n+1` ⇒ `n % 3 = 2`, contradiction. `omega` with hypothesis `n % 6 = 0 ∨ n % 6 = 4`.
  **This is the one place the class restriction is used**; for `n % 6 = 2` E1 genuinely fails (`n = 8`: rows `1` and `4` share anti-diagonal `4`).
- **`e1_main`** (`r ≠ s → r + f₁ n s ≠ s + f₁ n r`): in `ℤ`, `r − f₁ r` is `−r−1` (first half) or `n−r` (second half). Same half ⇒ `r = s`. Cross (`r < h ≤ s`) ⇒ `−r−1 = n−s` ⇒ `s − r = n+1 > n−1 ≥ s`, impossible. `omega` (no class hypothesis needed).
- **`e1_no_fix`** (`r < n → f₁ n r ≠ r`): `2r+1 = r ⇒ r+1 = 0`; `2r−n = r ⇒ r = n`, but `r < n`. `omega`.

### E2 — `n` even, `n % 6 = 2`  (so `h % 3 = 1`, `h ≥ 4`)

Bernhardsson's second formula with the `% n` resolved into explicit branches (the wrap happens exactly when `2r > h`):

```
f₂ n r := if r < h then (if 2*r ≤ h then 2*r + h - 1 else 2*r - h - 1)
                   else (if 2*r < 3*h - 2 then 2*r - h + 2 else 2*r - 3*h + 2)
```
Name the four pieces P1 `(r<h, 2r≤h)`, P2 `(r<h, 2r>h)`, P3 `(r≥h, 2r<3h−2)`, P4 `(r≥h, 2r≥3h−2)`. The second half is the 180° rotation of the first: `f₂(n−1−r) = n−1−f₂(r)` (not needed by the proof; it is how the formula was derived). `n = 8`: `[3,5,7,1,6,0,2,4]`.

Handy table (all linear in `r`):

| piece | `f₂ r` | `r + f₂ r` (anti) | `r − f₂ r` (main, in ℤ) | parity of `f₂ r` |
|---|---|---|---|---|
| P1 | `2r + h − 1` | `3r + h − 1` | `−r − h + 1` | `h − 1` |
| P2 | `2r − h − 1` | `3r − h − 1` | `−r + h + 1` | `h − 1` |
| P3 | `2r − h + 2` | `3r − h + 2` | `−r + h − 2` | `h` |
| P4 | `2r − 3h + 2` | `3r − 3h + 2` | `−r + 3h − 2` | `h` |

- **`e2_lt`**: P1 `≤ h + h − 1 = n−1`; P2 `≤ 2(h−1) − h − 1 = h − 3`; P3 `< (3h−2) − h + 2 = n`; P4 `≤ 2(2h−1) − 3h + 2 = h`. `omega`.
- **`e2_inj`**: within a piece, `2r + c = 2s + c ⇒ r = s`. P1 vs P2: `s − r = h` but `0 ≤ r`, `s < h`. P3 vs P4: `s − r = h` but `h ≤ r`, `s < 2h`. First half vs second half: opposite parity (table), impossible. `omega` (6 cross-cases, all linear; parity via literal `2`).
- **`e2_anti`** (uses `h % 3 = 1`): within a piece `3r + c = 3s + c ⇒ r = s`. Cross-piece differences of the constants are `2h`, `2h−3`, `4h−3`, `3`, `2h−3`, `2h` (for P1P2, P1P3, P1P4, P2P3, P2P4, P3P4): each `3(s−r) = ±const` forces `3 ∣ 2h` or `3 ∣ 4h` (impossible, `h % 3 = 1`) except P2–P3 where `3(s − r) = −3 ⇒ s = r − 1 < h`, contradicting `s ≥ h`. `omega` with `h % 3 = 1`.
- **`e2_main`** (uses `h ≥ 4`): within a piece `−r + c = −s + c ⇒ r = s`. P1P2 and P3P4: `s − r = 2h ≥ n`, impossible. P1P4: `s − r = 4h − 3 ≥ n`. P2P3: `r − s = 3` with `r < h ≤ s`. P1P3: `s − r = 2h − 3` with `s < (3h−2)/2`, so `2h − 3 < 3h/2 − 1 ⇒ h < 4`. P2P4: `s − r = 2h − 3` with `r > h/2`, `s ≤ 2h − 1`, so `2h − 3 ≤ (3h−3)/2 ⇒ h ≤ 3`. `omega` with `4 ≤ h`.
- **`e2_no_fix`**: P1 `r = 1 − h`; P2 `r = h + 1 > h`; P3 `r = h − 2 < h`; P4 `r = 3h − 2 ≥ 2h` (as `h ≥ 2`). Each contradicts the piece's range. `omega`.

### O — `n` odd, `n ≥ 5`: corner extension of `m := n − 1`

```
f n r := if r < n - 1 then f_even (n - 1) r else n - 1        -- f_even = f₂ if (n-1) % 6 = 2 else f₁
```

Generic lemma, parametrised by *any* `g : ℕ → ℕ` that satisfies the five even-board properties on `m` (bound, inj, anti, main, no_fix):

- **`corner_lt`**: `r < m ⇒ g r < m < n`; `r = m ⇒ n − 1 < n`. `omega`.
- **`corner_inj`**: both `< m` ⇒ `g` injective. One is `m`: `g r = m` contradicts `g r < m`. `omega` + hypothesis.
- **`corner_anti`**: both `< m` ⇒ from `g`. One is `m`: `r + g r ≤ (m−1) + (m−1) < 2m = m + (n−1)`. `omega`.
- **`corner_main`**: both `< m` ⇒ from `g`. `i < m = j`: `i + (n−1) ≠ m + g i ⇔ g i ≠ i`, which is `no_fix`. Symmetric case identical. `omega` + hypothesis.

**Why no_fix is load-bearing**: without it the corner queen sits on the main diagonal `r − c = 0` of some `g`-queen. (This is exactly why Dead end 2 below fails.)

### Alt — `n % 6 ∈ {1, 5}` (optional, ZMod flavour, not on the critical path)

`q r := (2*r) % n`. Inj: `2r ≡ 2s (mod n)`, `gcd(2,n)=1` ⇒ `r ≡ s` ⇒ `r = s`. Anti: `r + (2r % n) ≡ 3r`, `gcd(3,n)=1`. Main: `r + (2s % n) ≡ r + 2s`, `s + 2r`, difference `s − r ≡ 0`. All three are `Nat.ModEq.cancel_left_of_coprime` / `ZMod.natCast_self_eq_zero` + `Fin.ext`. Machine-checked too (`verify_output.txt`), but it does not remove any lemma from the E1/E2/O plan, so I recommend against spending a wave on it.

## Machine evidence (not proof)

`verify_construction.py` implements `f₁`, `f₂`, `f` verbatim from this file and evaluates the pin's three clauses as written (bound, `Injective`, `i + q i ≠ j + q j`, `i + q j ≠ j + q i`) over all ordered pairs, `4 ≤ n ≤ 1000`. It also checks the even-board `no_fix` side condition, the Alt formula on `n%6 ∈ {1,5}`, and — as bonus data — `f₂` on `n%6 = 4` (Bernhardsson's "`n%6 ≠ 0`" claim). Output in `verify_output.txt`:

```
range: 4 <= n <= 1000; boards checked per residue class n%6: {0: 166, 1: 166, 2: 166, 3: 166, 4: 167, 5: 166}
primary construction (E1 / E2 / odd corner extension): PASS
even-n no-fixed-point side condition: PASS
alt knight (2r % n) on n%6 in {1,5}: PASS
bonus: E2 formula on n%6 = 4: PASS
```

Slips found by the script: **none** (formulas were derived by hand first, then transcribed; the script passed on the first run). Runtime 26 s (O(n²) pairs × 997 boards, pure Python).

## Dead ends (honest map)

1. **1-indexed "list surgery" for `n%6 ∈ {2,3}`** (Wikipedia/Bernhardsson prose: "swap 1↔3, move 5 to the end"; "move 2 / 1,3 to the end"). Transcribed to 0-indexed it is a 5-piece function with three single-point pieces (`k=0 ↦ 2`, `k=1 ↦ 0`, `k=h−1 ↦ 4`) and the `n%6=3` list is *not* a corner extension of the `n%6=2` list (for `n = 9` the last row holds column `2`, not `8`). Rejected in favour of Bernhardsson's closed formula 2, which has four pieces, all with ranges of positive length, and whose `n%6=3` companion *is* the corner extension. Obstruction: more `omega` cases and no reuse, not a mathematical failure.
2. **Corner-extending a toroidal solution.** Tried to get `n%6 = 3` from `n−1 ≡ 2` the cheap way, or `n%6 ∈ {1,5}` from the knight formula on `n−1`: impossible. Any toroidal (modular) solution `q r = (a r + b) % m` has a queen on every wrapped diagonal, in particular on the unwrapped main diagonal `r = q r` (since `|r − q r| < m` the wrapped class `r − q r ≡ 0` is the actual diagonal). So `no_fix` fails for every such `q` and the corner queen is attacked. Exact obstruction, not a budget stop.
3. **Single `% n` formula for even `n`.** `(2r + c) % n` is never injective for even `n` (`gcd(2, n) = 2`), so no `Nat.ModEq` one-liner exists for even boards; the `if r < h` split is unavoidable. Also `x % n` with variable `n` is outside `omega`'s fragment, which is why E2 is written with the wrap already resolved into branches.

Nothing is left open: all residue classes closed at the informal level, so no partial map is needed.

## Lean-shaped lemma list (dependency order) — for OPE-6

Design principle: **do the whole proof in `ℕ → ℕ` and cross into `Fin n` exactly once.** All `Fin` coercion pain lives in lemma 0.

```lean
namespace ProofLab.NQueensTheorem

/-- 0. Transfer: a ℕ-function with the three properties gives `NonAttacking`. -/
theorem nonAttacking_of_nat {n : ℕ} (f : ℕ → ℕ) (hlt : ∀ r, r < n → f r < n)
    (hinj : ∀ r s, r < n → s < n → f r = f s → r = s)
    (hanti : ∀ r s, r < n → s < n → r ≠ s → r + f r ≠ s + f s)
    (hmain : ∀ r s, r < n → s < n → r ≠ s → r + f s ≠ s + f r) :
    NonAttacking (fun i : Fin n => ⟨f i, hlt i i.isLt⟩)
-- proof shape: refine ⟨fun i j hij => Fin.ext (hinj _ _ i.2 j.2 (by simpa using congrArg Fin.val hij)), fun i j hij => ⟨hanti .., hmain ..⟩⟩
-- with `i ≠ j` turned into `(i:ℕ) ≠ j` by `Fin.val_ne_iff.mpr` / `fun h => hij (Fin.ext h)`.

/-- Bundle of the five even-board facts (the interface between E1/E2 and the corner step). -/
def GoodEven (n : ℕ) (f : ℕ → ℕ) : Prop :=
  (∀ r, r < n → f r < n) ∧ (∀ r s, r < n → s < n → f r = f s → r = s) ∧
  (∀ r s, r < n → s < n → r ≠ s → r + f r ≠ s + f s) ∧
  (∀ r s, r < n → s < n → r ≠ s → r + f s ≠ s + f r) ∧ (∀ r, r < n → f r ≠ r)

def f₁ (n r : ℕ) : ℕ := if r < n / 2 then 2 * r + 1 else 2 * r - n
def f₂ (n r : ℕ) : ℕ :=
  if r < n / 2 then (if 2 * r ≤ n / 2 then 2 * r + n / 2 - 1 else 2 * r - n / 2 - 1)
  else (if 2 * r < 3 * (n / 2) - 2 then 2 * r - n / 2 + 2 else 2 * r - 3 * (n / 2) + 2)

-- 1–5 (E1).  Each: `intro ..; simp only [f₁] at *; split_ifs at * <;> omega`
theorem e1_lt     (n : ℕ) (hn : n % 2 = 0) : ∀ r, r < n → f₁ n r < n
theorem e1_inj    (n : ℕ) (hn : n % 2 = 0) : ∀ r s, r < n → s < n → f₁ n r = f₁ n s → r = s
theorem e1_anti   (n : ℕ) (hn : n % 6 = 0 ∨ n % 6 = 4) : ∀ r s, r < n → s < n → r ≠ s → r + f₁ n r ≠ s + f₁ n s
theorem e1_main   (n : ℕ) (hn : n % 2 = 0) : ∀ r s, r < n → s < n → r ≠ s → r + f₁ n s ≠ s + f₁ n r
theorem e1_no_fix (n : ℕ) (hn : n % 2 = 0) : ∀ r, r < n → f₁ n r ≠ r
theorem goodEven_f₁ (n : ℕ) (hn : n % 6 = 0 ∨ n % 6 = 4) : GoodEven n (f₁ n)

-- 6–10 (E2).  Same shape; hypotheses `n % 6 = 2` and `8 ≤ n` (omega derives h % 3 = 1, 4 ≤ h).
theorem e2_lt     (n : ℕ) (hn : n % 6 = 2) : ∀ r, r < n → f₂ n r < n
theorem e2_inj    (n : ℕ) (hn : n % 6 = 2) : ∀ r s, r < n → s < n → f₂ n r = f₂ n s → r = s
theorem e2_anti   (n : ℕ) (hn : n % 6 = 2) : ∀ r s, r < n → s < n → r ≠ s → r + f₂ n r ≠ s + f₂ n s
theorem e2_main   (n : ℕ) (hn : n % 6 = 2) (h8 : 8 ≤ n) : ∀ r s, r < n → s < n → r ≠ s → r + f₂ n s ≠ s + f₂ n r
theorem e2_no_fix (n : ℕ) (hn : n % 6 = 2) : ∀ r, r < n → f₂ n r ≠ r
theorem goodEven_f₂ (n : ℕ) (hn : n % 6 = 2) (h8 : 8 ≤ n) : GoodEven n (f₂ n)

-- 11. Even boards, n ≥ 4.
theorem goodEven_exists (n : ℕ) (h4 : 4 ≤ n) (he : n % 2 = 0) : ∃ f, GoodEven n f
-- proof: rcases on n % 6 (omega gives ∈ {0,2,4}); n%6=2 ∧ 4 ≤ n ⇒ 8 ≤ n by omega.

-- 12. Corner extension.
def corner (m : ℕ) (g : ℕ → ℕ) (r : ℕ) : ℕ := if r < m then g r else m
theorem corner_lt / corner_inj / corner_anti / corner_main (m : ℕ) (g) (hg : GoodEven m g) : ...  -- for board m + 1
-- each: `intro ..; obtain ⟨h1,h2,h3,h4,h5⟩ := hg; simp only [corner]; split_ifs <;> first | omega | exact ..`
-- the `exact` cases call h2/h3/h4 at the two sub-m indices; the mixed cases are `omega` + h1/h5 instances.

-- 13. Assembly.
theorem queens_exists_of_four_le (n : ℕ) (hn : 4 ≤ n) : ∃ q : Fin n → Fin n, NonAttacking q := by
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩
  · obtain ⟨f, hf⟩ := goodEven_exists (2*k) hn (by omega); exact ⟨_, nonAttacking_of_nat f hf.1 hf.2.1 hf.2.2.1 hf.2.2.2.1⟩
  · obtain ⟨g, hg⟩ := goodEven_exists (2*k) (by omega) (by omega)
    exact ⟨_, nonAttacking_of_nat (corner (2*k) g) (corner_lt ..) (corner_inj ..) (corner_anti ..) (corner_main ..)⟩
end ProofLab.NQueensTheorem
```

(Statements are Lean-shaped but **not compiled** in this ticket; names/binders may need cosmetic adjustment. `f₂` is written with `n / 2` inline so `omega` sees a single `Nat` division by a literal; a `let h := n / 2` would need `simp only` unfolding first.)

### Wave estimate: **1 wave, 2 at most**

- Wave 1: lemma 0 (the only `Fin` lemma), `f₁`/`f₂` defs, lemmas 1–10 (each expected to be `split_ifs <;> omega`, i.e. one line of tactic each), 11, 12, 13. All arithmetic is linear with literal moduli/divisors, squarely inside `omega`.
- Wave 2 (contingency): if `omega` times out on `e2_main`/`e2_anti` (4×4 piece cases × ℕ-subtraction splits), split those two into per-piece-pair lemmas with the piece hypotheses stated explicitly (the table above gives all 16 combinations as one-liners).

### Hazards per lemma and suggested reformulations

| lemma | hazard | mitigation |
|---|---|---|
| 0 `nonAttacking_of_nat` | `Fin` coercions: `Function.Injective` on `Fin`, `i ≠ j` vs `(i:ℕ) ≠ j`, the anonymous-constructor `⟨f i, _⟩` and `Fin.val_mk` | `Fin.ext`, `Fin.ext_iff`, `Fin.val_ne_iff`; `simp only [Fin.val_mk]` — this is the **only** lemma where `Fin` appears; keep it that way |
| `e1_*`, `e2_*` | `Nat` subtraction in `2*r - n`, `2*r - h - 1`, `2*r - 3*h + 2` | `omega` handles truncated subtraction natively but pays a case split per `-`; if it stalls, cast to `ℤ` via `push_cast`/`zify [h_le]` with the branch's inequality, or rewrite `2*r - n` as `2*(r - n/2)` (one fewer subtraction) |
| `e1_anti` | needs `n % 3 ≠ 2`; `omega` must see `n % 6 = 0 ∨ n % 6 = 4` *and* `n / 2` in the same goal | state `hn` as the disjunction, not as `gcd`; `omega` handles `%` and `/` by literals |
| `e2_anti` | divisibility by 3 with `h = n / 2` | `omega` derives `h % 3 = 1` from `n % 6 = 2` — no `Nat.ModEq` needed |
| `e2_main` | needs `h ≥ 4` (fails at `h ≤ 3`) | hypothesis `8 ≤ n` (or derive from `4 ≤ n ∧ n % 6 = 2`) — flagged as **the** arithmetic subtlety of the file |
| `corner_*` | `n − 1` vs `m + 1` off-by-one; goal has `m + 1` where hypotheses have `m` | state everything on board `m + 1` (never `n - 1`), instantiate with `m := 2*k` |
| 13 | `Nat.even_or_odd'` gives `n = 2*k` or `n = 2*k+1`; then `4 ≤ 2*k+1 ⇒ 4 ≤ 2*k` | `omega` |
| general | `if` in defs: `split_ifs` **before** `omega`; `omega` will not look inside `ite` | `simp only [f₁, f₂, corner]; split_ifs at * <;> omega` |
| `ZMod`/`Int` | none required by the primary route; Alt route (`2r % n`) would need `Nat.ModEq.cancel_left_of_coprime` and `Nat.mod_lt` — only if someone insists on it | recommend **not** taking Alt |

## Residual risks (board-facing)

- **Mathematical**: none at the informal level beyond "informal"; every step is linear arithmetic that `verify_construction.py` cross-checks up to 1000. The argument does not depend on the bound, so I expect no surprises at larger `n`, but that expectation is not a proof.
- **Engineering**: `omega` performance on `e2_main` (16 piece-pair cases × subtraction splits) is the only plausible Wave-2 trigger; the per-pair table above is the fallback. `Fin` plumbing is confined to lemma 0.
- **Process**: no Lean was compiled in this ticket (per scope). Lemma statements are hand-typed; binder/coercion typos are possible and are the Formalist's to fix, not a mathematical issue.
