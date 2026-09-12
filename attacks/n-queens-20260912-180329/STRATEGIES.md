# Strategies — n-queens-20260912-180329

## Planned approaches

1. **Explicit construction, 0-indexed, omega-shaped** (chosen). Bernhardsson 1991 formulas transcribed to `Fin n`
   indexing, `% n` resolved into `if` branches, odd `n` via corner extension of the even `n−1` board.
   Partition: even/`n%6∈{0,4}` (E1), even/`n%6=2` (E2), odd (corner). Details and lemma list in `LOG.md`.
2. Knight formula `2r % n` for `gcd(n,6)=1` via `ZMod` (kept as optional Alt; machine-checked; not recommended).

## Dead ends

- 1-indexed list surgery for `n%6∈{2,3}` — 5-piece function, no reuse between classes (LOG.md §Dead ends 1).
- Corner extension of a toroidal solution — always has a main-diagonal queen, so the corner is attacked (§2).
- Single `% n` formula for even `n` — not injective (`gcd(2,n)=2`), and variable-modulus `%` is outside `omega` (§3).
