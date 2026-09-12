#!/usr/bin/env bash
# Re-link Mathlib's `cache` executable with Apple's system linker.
#
# Why: Lean v4.10.0 ships an old bundled `ld64.lld`. On macOS 15.4+/26 the
# binaries it links abort at load with
#   dyld: __DATA_CONST segment missing SG_READ_ONLY flag
# so `lake exe cache get` dies right after building `cache`. The .o inputs are
# fine; only the final link step needs the system `ld`. This script recompiles
# the four generated C files with `leanc` (correct include paths) and links
# them with /usr/bin/clang, then drops the result over the broken binary.
#
# Usage (from proofs/lean-project, after `lake exe cache get` has failed once
# so that .lake/packages/mathlib/.lake/build/ir/Cache/*.c exist):
#   export PATH="$HOME/.elan/bin:$PATH"
#   bash ../../docs/ci/relink-mathlib-cache-macos.sh
#   lake exe cache get
set -euo pipefail

PROJ="${1:-$(pwd)}"
MATHLIB="$PROJ/.lake/packages/mathlib"
IR="$MATHLIB/.lake/build/ir/Cache"
BIN="$MATHLIB/.lake/build/bin"
TOOLCHAIN="$(cd "$PROJ" && lean --print-prefix)"
WORK="$(mktemp -d)"

[ -d "$IR" ] || { echo "no $IR — run 'lake exe cache get' once first" >&2; exit 1; }

for f in IO Hashing Main Requests; do
  leanc -c -O3 -DNDEBUG -o "$WORK/$f.o" "$IR/$f.c"
done

/usr/bin/clang -o "$WORK/cache" "$WORK"/IO.o "$WORK"/Hashing.o "$WORK"/Main.o "$WORK"/Requests.o \
  -L "$TOOLCHAIN/lib/lean" -L "$TOOLCHAIN/lib" \
  -lleancpp -lInit -lLean -lleanrt -lc++ -lStd -lLake -lgmp

mkdir -p "$BIN"
[ -f "$BIN/cache" ] && cp "$BIN/cache" "$BIN/cache.lld-broken"
cp "$WORK/cache" "$BIN/cache"
rm -rf "$WORK"
echo "re-linked $BIN/cache with system ld; now run: lake exe cache get"
