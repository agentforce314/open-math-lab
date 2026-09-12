#!/usr/bin/env python3
"""OPE-5 machine evidence (NOT proof), status: informal.

Implements *exactly* the 0-indexed closed forms written in LOG.md and checks
*exactly* the three clauses of the frozen Lean predicate (OPE-4 pin,
`ProofLab.NQueensTheorem.NonAttacking`):

    Function.Injective q ∧
    ∀ i j, i ≠ j →  i + q i ≠ j + q j  ∧  i + q j ≠ j + q i

for every 4 ≤ n ≤ N (default 1000).  No "|i-j| ≠ |qi-qj|" shortcut: the
clauses are evaluated as written, over the naturals, for all ordered pairs.

Rows and columns are 0-indexed throughout (Fin n convention).  The literature
source (Bernhardsson 1991, SIGART Bull. 2(2):7, 1-indexed) is cited in LOG.md
once; nothing here is 1-indexed.

Usage: python3 verify_construction.py [N]
"""
import sys


# --- Primary construction (the formulas OPE-6 is meant to formalize) --------

def f_e1(n: int, r: int) -> int:
    """n even, n % 6 in {0, 4}.  h = n/2.
    r < h  -> 2r + 1        (odd columns, ascending)
    r >= h -> 2r - n        (= 2(r - h): even columns, ascending)"""
    h = n // 2
    return 2 * r + 1 if r < h else 2 * r - n


def f_e2(n: int, r: int) -> int:
    """n even, n % 6 = 2.  h = n/2 (so h % 3 = 1, h >= 4).
    Bernhardsson's second formula with the `% n` expanded into branches:
    r < h,  2r <= h      -> 2r + h - 1
    r < h,  2r >  h      -> 2r - h - 1
    r >= h, 2r <  3h - 2 -> 2r - h + 2
    r >= h, 2r >= 3h - 2 -> 2r - 3h + 2
    (Second half is the 180-degree rotation of the first: f(n-1-r) = n-1-f(r).)"""
    h = n // 2
    if r < h:
        return 2 * r + h - 1 if 2 * r <= h else 2 * r - h - 1
    return 2 * r - h + 2 if 2 * r < 3 * h - 2 else 2 * r - 3 * h + 2


def f_even(n: int, r: int) -> int:
    assert n % 2 == 0 and n >= 4
    return f_e2(n, r) if n % 6 == 2 else f_e1(n, r)


def f(n: int, r: int) -> int:
    """All n >= 4.  Odd n: solve n-1 (even) and put the last queen in the corner
    (n-1, n-1).  Requires the even solution to have no queen on the main
    diagonal (f_even(m, r) != r), which is checked separately below."""
    if n % 2 == 0:
        return f_even(n, r)
    m = n - 1
    return f_even(m, r) if r < m else m


# --- Alternative for gcd(n, 6) = 1 (ZMod-flavoured; optional shortcut) ------

def f_alt_knight(n: int, r: int) -> int:
    """n % 6 in {1, 5}: q r = (2 r) % n.  Not the primary route; checked so the
    Formalist may pick it if ZMod cancellation turns out cheaper than the
    corner extension."""
    return (2 * r) % n


# --- The checker: the three NonAttacking clauses, verbatim -------------------

def check_nonattacking(n: int, q):
    """Return None if q : Fin n -> Fin n satisfies NonAttacking, else a witness."""
    cols = [q(n, r) for r in range(n)]
    for r, c in enumerate(cols):
        if not (0 <= c < n):
            return ("bound", r, c)
    # Function.Injective q
    for i in range(n):
        for j in range(n):
            if i != j and cols[i] == cols[j]:
                return ("injective", i, j)
    # ∀ i j, i ≠ j → i + q i ≠ j + q j ∧ i + q j ≠ j + q i
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            if i + cols[i] == j + cols[j]:
                return ("anti_diag", i, j)
            if i + cols[j] == j + cols[i]:
                return ("main_diag", i, j)
    return None


def check_no_fixed_point(n: int) -> bool:
    """Side condition used by the odd-n corner extension (even n only)."""
    return all(f_even(n, r) != r for r in range(n))


def main(N: int) -> int:
    fails = []
    by_class = {k: 0 for k in range(6)}
    for n in range(4, N + 1):
        w = check_nonattacking(n, f)
        if w is not None:
            fails.append((n, "primary", w))
        by_class[n % 6] += 1
        if n % 2 == 0 and not check_no_fixed_point(n):
            fails.append((n, "no_fixed_point", None))
        if n % 6 in (1, 5):
            w = check_nonattacking(n, f_alt_knight)
            if w is not None:
                fails.append((n, "alt_knight", w))
        if n % 6 == 4:  # E2 also claims n % 6 != 0; record as bonus evidence
            w = check_nonattacking(n, f_e2)
            if w is not None:
                fails.append((n, "e2_on_4mod6", w))
    print(f"range: 4 <= n <= {N}; boards checked per residue class n%6: {by_class}")
    print("clauses: bound, Function.Injective, i+q i ≠ j+q j, i+q j ≠ j+q i (all ordered pairs)")
    print("primary construction (E1 / E2 / odd corner extension):",
          "PASS" if not [x for x in fails if x[1] == "primary"] else "FAIL")
    print("even-n no-fixed-point side condition:",
          "PASS" if not [x for x in fails if x[1] == "no_fixed_point"] else "FAIL")
    print("alt knight (2r % n) on n%6 in {1,5}:",
          "PASS" if not [x for x in fails if x[1] == "alt_knight"] else "FAIL")
    print("bonus: E2 formula on n%6 = 4:",
          "PASS" if not [x for x in fails if x[1] == "e2_on_4mod6"] else "FAIL")
    for x in fails[:20]:
        print("  FAIL", x)
    print("sample n=8 (E2):", [f(8, r) for r in range(8)])
    print("sample n=9 (odd, corner ext of n=8):", [f(9, r) for r in range(9)])
    print("sample n=10 (E1):", [f(10, r) for r in range(10)])
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main(int(sys.argv[1]) if len(sys.argv) > 1 else 1000))
