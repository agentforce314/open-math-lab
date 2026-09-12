# Reviewer's independent check (OPE-7, 3a): LOG typed-ℕ f₂ vs signed f₂ vs Lean ℕ f₂.
def nsub(a, b): return a - b if a >= b else 0          # Lean ℕ truncated subtraction
def f2_log_nat(n, r):                                    # LOG.md typed form, parsed as ℕ
    h = n // 2
    if r < h:  return nsub(2*r + h, 1) if 2*r <= h else nsub(nsub(2*r, h), 1)
    return nsub(2*r, h) + 2 if 2*r < 3*h - 2 else nsub(2*r, 3*h) + 2
def f2_signed(n, r):                                     # LOG.md math / Python verifier (ℤ)
    h = n // 2
    if r < h:  return 2*r + h - 1 if 2*r <= h else 2*r - h - 1
    return 2*r - h + 2 if 2*r < 3*h - 2 else 2*r - 3*h + 2
def f2_lean(n, r):                                       # NQueensTheorem.lean:100-104, ℕ
    h = n // 2
    if r < h:  return nsub(2*r + h, 1) if 2*r <= h else nsub(nsub(2*r, h), 1)
    return nsub(2*r + 2, h) if 2*r < 3*h - 2 else nsub(2*r + 2, 3*h)
bad_log, bad_lean, boards = [], 0, 0
for n in range(8, 1001):
    if n % 6 != 2: continue
    boards += 1
    for r in range(n):
        s, l, g = f2_signed(n, r), f2_lean(n, r), f2_log_nat(n, r)
        if s < 0: raise SystemExit(f"signed form negative at n={n} r={r}")
        if l != s: bad_lean += 1
        if g != s: bad_log.append((n, r, g, s))
print(f"boards n%6==2, 8<=n<=1000: {boards}")
print(f"Lean N-form vs signed: mismatches = {bad_lean}")
print(f"LOG typed N-form vs signed: mismatches = {len(bad_log)}; first 5 = {bad_log[:5]}")
print(f"n=14 witnesses: LOG-typed f2(14,10)={f2_log_nat(14,10)}  signed={f2_signed(14,10)}  Lean={f2_lean(14,10)}")
