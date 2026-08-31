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
"$TECTONIC" resume/source/resume_jake.tex --outdir "$OUTPUT_DIR"
"$TECTONIC" resume/source/cover_letter.tex --outdir "$OUTPUT_DIR"

# One implementation of the naming rule, shared with CI.
STEM="$("$PYTHON" scripts/generate_latex.py --name)"
if [ -n "$STEM" ]; then
  mv "$OUTPUT_DIR/resume.pdf" "$OUTPUT_DIR/${STEM}_Resume.pdf"
  mv "$OUTPUT_DIR/resume_jake.pdf" "$OUTPUT_DIR/${STEM}_Resume_Compact.pdf"
  mv "$OUTPUT_DIR/cover_letter.pdf" "$OUTPUT_DIR/${STEM}_Cover_Letter.pdf"
fi

# A resume that quietly runs to a second page is worse than one that fails to
# build, because nobody notices until an employer is holding it. Checked here
# and in CI, so the two cannot disagree.
if command -v pdfinfo >/dev/null 2>&1; then
  echo
  echo "Page counts:"
  fail=0
  for f in "$OUTPUT_DIR"/*.pdf; do
    n=$(pdfinfo "$f" | awk '/^Pages:/ {print $2}')
    printf '  %-44s %s page(s)\n' "$(basename "$f")" "$n"
    [ "$n" = "1" ] || fail=1
  done
  if [ "$fail" != "0" ]; then
    echo "At least one document is not one page. Cut content, do not shrink the font." >&2
    exit 1
  fi
else
  echo
  echo "Install poppler-utils to have the page count checked automatically."
fi

echo
echo "Built:"
ls -1 "$OUTPUT_DIR"/*.pdf
