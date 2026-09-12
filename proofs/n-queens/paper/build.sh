#!/usr/bin/env bash
# Build proofs/n-queens/paper/main.pdf with tectonic (XeTeX engine, self-contained
# bundle; fonts resolved by filename from the bundle, no system TeX needed).
#
# Toolchain: tectonic 0.17.0, installed user-locally at ~/.local/bin/tectonic on the
# lab Mac (board OK for user-local tooling, OPE-2 2026-09-12). Any tectonic >= 0.15
# should work. The appendices \VerbatimInput the Lean source and the verification
# transcripts from the repository, so run this from anywhere inside the checkout.
set -euo pipefail
cd "$(dirname "$0")"
TECTONIC="${TECTONIC:-$(command -v tectonic || echo "$HOME/.local/bin/tectonic")}"
"$TECTONIC" -X compile --keep-logs main.tex
echo "built $(pwd)/main.pdf"
