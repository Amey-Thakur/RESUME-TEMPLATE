#!/usr/bin/env bash
set -e

# Change to the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$SCRIPT_DIR/.."

OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

echo "Running LaTeX pre-processor (Python)..."
python3 scripts/generate_latex.py

TECTONIC_CMD="tectonic"
if ! command -v tectonic &> /dev/null; then
    if [ -f "../bin/tectonic" ]; then
        TECTONIC_CMD="../bin/tectonic"
    else
        echo "Error: Tectonic LaTeX compiler not found globally or in the workspace binary folder."
        exit 1
    fi
fi

echo "Using Tectonic compiler at: $TECTONIC_CMD"

echo "Compiling Resume..."
$TECTONIC_CMD resume/source/resume.tex --outdir "$OUTPUT_DIR"

echo "Compiling Cover Letter..."
$TECTONIC_CMD resume/source/cover_letter.tex --outdir "$OUTPUT_DIR"

# Rename output files
RAW_RESUME="$OUTPUT_DIR/resume.pdf"
RAW_COVER="$OUTPUT_DIR/cover_letter.pdf"

# Extract name using Python since it's already used for pre-processing
SAFE_NAME=$(python3 -c "import json, re; print(re.sub(r'[^a-zA-Z0-9\s]', '', json.load(open('resume/configuration/resume_data.json'))['personal_info']['name']).strip().replace(' ', '_'))")

if [ -f "$RAW_RESUME" ]; then
    mv "$RAW_RESUME" "$OUTPUT_DIR/${SAFE_NAME}_Resume.pdf"
    echo "Generated: ${SAFE_NAME}_Resume.pdf"
fi

if [ -f "$RAW_COVER" ]; then
    mv "$RAW_COVER" "$OUTPUT_DIR/${SAFE_NAME}_Cover_Letter.pdf"
    echo "Generated: ${SAFE_NAME}_Cover_Letter.pdf"
fi
