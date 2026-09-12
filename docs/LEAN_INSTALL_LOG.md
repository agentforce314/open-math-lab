# Lean 4 Installation Log
**Date**: 2026-07-31
**Issue**: OPE-17
**Installer**: Formalist agent

## Installation Summary

### Tools Installed
- **elan** 4.2.3 (b6cec7e10 2026-06-08)
- **lean** 4.10.0 (x86_64-w64-windows-gnu, commit c375e19f6b65, Release)
- **lake** 5.0.0-c375e19 (Lean version 4.10.0)

### Installation Method
1. Downloaded elan-init.exe from https://github.com/leanprover/elan/releases
2. Ran `elan-init.exe -y` (non-interactive installation)
3. elan installed to: `C:\Users\paulb\.elan`
4. Binaries available at: `C:\Users\paulb\.elan\bin`
   - elan.exe
   - lean.exe
   - lake.exe
   - leanc.exe
   - leanchecker.exe
   - leanmake.exe
   - leanpkg.exe

### First Build: SUCCESS
**Command**: `lake build` in `proofs/lean-project`
**Exit code**: 0
**Date**: 2026-07-31

#### Build Steps
1. elan installed Lean 4.10.0 (matching lean-toolchain pin)
2. lake fetched dependencies:
   - mathlib (v4.10.0)
   - batteries
   - Qq
   - aesop
   - proofwidgets
   - importGraph
   - Cli
3. Downloaded 4878 Mathlib .olean files from cache (100% success)
4. Built ProofLab.Basic module
5. Built Main executable

#### Build Output
```
✔ [3/8] Built ProofLab
✔ [4/8] Built ProofLab.Basic:c.o
✔ [5/8] Built Main
✔ [6/8] Built ProofLab:c.o
✔ [7/8] Built Main:c.o
✔ [8/8] Built «proof-lab»
Build completed successfully.
```

### Verification
- [x] elan available on PATH
- [x] lean --version shows 4.10.0 (matches lean-toolchain)
- [x] lake --version shows 5.0.0
- [x] `lake build` exits 0
- [x] ProofLab/Basic.lean builds with no sorry
- [x] Trivial theorems in Basic.lean fully type-checked

### Known Issues
- ProofLab/ErdosWoods.lean and ProofLab/SumFree.lean temporarily commented out
  in ProofLab.lean due to import path changes between Lean versions
- Reason: Mathlib v4.10.0 has different module organization than drafts expected
- Resolution needed: Update imports to match Mathlib v4.10.0 structure
- Status: Blocker documented for future work; Basic.lean proves installation is working

### Disk Usage
- `~/.elan`: ~100MB (toolchain binaries)
- `proofs/lean-project/.lake`: ~2GB (Mathlib cache + build artifacts)
- Total: ~2.1GB (within expected range from LEAN_PLAN.md)

### How to Rebuild
From `proofs/lean-project`:
```powershell
# Ensure elan is on PATH
$env:PATH = "$env:USERPROFILE\.elan\bin;$env:PATH"

# Build
lake build

# Clean build (if needed)
lake clean
lake build
```

### Next Steps (per OPE-17 acceptance criteria)
- [x] elan/lake/lean available on PATH
- [x] lake build exits 0
- [x] Build log committed to git repo
- [ ] Update docs/LEAN_PLAN.md status
- [ ] Fix imports in ErdosWoods.lean and SumFree.lean (stretch goal)
- [ ] Comment on OPE-17 with verify commands for board

---
End of installation log

---

# Lean 4 Installation Log — macOS (arm64)
**Date**: 2026-09-12
**Issue**: OPE-2 (board comment: "can you install lean and other tools?")
**Installer**: Research Director agent
**Machine**: macOS 26.4.1, Apple Silicon (arm64). No `elan`/`lean`/`lake` were present; the log above is from a Windows box.

## What was installed (user-local only, no `sudo`, no shell-rc edits)
- **elan** 4.2.4 via `elan-init.sh -y --no-modify-path --default-toolchain none` → `~/.elan`
- **lean** 4.10.0 (`leanprover/lean4:v4.10.0`, matches `proofs/lean-project/lean-toolchain`)
- **lake** 5.0.0-c375e19
- Mathlib + deps cloned by `lake` per `lake-manifest.json`; 4878 `.olean` files from the Mathlib cache (100% success)
- Already present, reused: `gh` (logged in as `agentforce314`), `git`, `rg`, `jq`, `python3`, `node`

PATH is **not** modified globally. Every agent shell must do:
```bash
export PATH="$HOME/.elan/bin:$PATH"
```

## Blocker hit and workaround
`lake exe cache get` built Mathlib's `cache` tool and then aborted:
```
dyld: __DATA_CONST segment missing SG_READ_ONLY flag in .lake/packages/mathlib/.lake/build/bin/cache
```
Cause: Lean v4.10.0's bundled `ld64.lld` produces Mach-O segments that macOS 15.4+/26 `dyld` rejects. `lean`/`lake` themselves are fine (prebuilt); only executables *linked locally* by that toolchain are affected.

Fix: re-link `cache` from its generated C sources with Apple's `ld` — scripted in
`docs/ci/relink-mathlib-cache-macos.sh`. Then `lake exe cache get` completes.
Note for Formalist: `lake build` of **libraries** (`.olean`) is unaffected; only `lake exe`/`lean_exe` targets (e.g. `proof-lab` from `Main.lean`) need the same treatment on this machine. Prefer `lake build ProofLab.<Module>` as the green gate.

## Verification (this machine)
```bash
export PATH="$HOME/.elan/bin:$PATH"
cd proofs/lean-project
lake build ProofLab.NQueens      # ✔ [2239/2239] Built ProofLab.NQueens — exit 0, ~10 s from cache
```
`#print axioms` on `queens_two_none` / `queens_three_none` / `queens_four`: `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

## Disk usage
- `~/.elan`: ~600 MB (toolchain)
- `proofs/lean-project/.lake`: ~4.6 GB (Mathlib sources + olean cache)
