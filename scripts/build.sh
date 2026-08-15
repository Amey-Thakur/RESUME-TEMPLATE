#!/usr/bin/env bash
#
# Build the resume and the cover letter.
#
#   ./scripts/build.sh
#
# Needs Python 3 for the pre-processor and Tectonic for the compile step.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR/.."

OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

PYTHON="${PYTHON:-python3}"
command -v "$PYTHON" >/dev/null 2>&1 || PYTHON=python

echo "Pre-processing JSON into LaTeX"
"$PYTHON" scripts/generate_latex.py

TECTONIC="tectonic"
if ! command -v tectonic &>/dev/null; then
  if [ -x "bin/tectonic" ]; then
    TECTONIC="bin/tectonic"
  else
    echo "Tectonic was not found. Install it from https://tectonic-typesetting.github.io" >&2
    exit 1
  fi
fi

echo "Compiling with $TECTONIC"
"$TECTONIC" resume/source/resume.tex --outdir "$OUTPUT_DIR"
"$TECTONIC" resume/source/cover_letter.tex --outdir "$OUTPUT_DIR"

# One implementation of the naming rule, shared with CI.
STEM="$("$PYTHON" scripts/generate_latex.py --name)"
if [ -n "$STEM" ]; then
  mv "$OUTPUT_DIR/resume.pdf" "$OUTPUT_DIR/${STEM}_Resume.pdf"
  mv "$OUTPUT_DIR/cover_letter.pdf" "$OUTPUT_DIR/${STEM}_Cover_Letter.pdf"
fi

echo
echo "Built:"
ls -1 "$OUTPUT_DIR"/*.pdf
