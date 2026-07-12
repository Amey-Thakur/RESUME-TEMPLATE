<img width="100%" alt="Resume Template" src="https://capsule-render.vercel.app/api?type=waving&color=0:1e3a8a,100:2563eb&height=210&section=header&text=Resume%20Template&fontColor=ffffff&fontSize=54&fontAlignY=40&desc=Modular%20LaTeX%20Resume%20%C2%B7%20JSON%20Configuration%20%C2%B7%20Automated%20PDF%20Builds&descSize=16&descAlignY=62" />

<h2 align="center">Resume and Cover Letter Template</h2>

<p align="center">
  A modular LaTeX resume system. Content lives in a single JSON file. A pre-processor generates the LaTeX sections. Tectonic compiles the PDF. GitHub Actions publishes it as a release.
</p>

<p align="center">
  <a href="https://github.com/Amey-Thakur/RESUME-TEMPLATE/releases/latest"><img alt="Download Resume" src="https://img.shields.io/badge/Download%20Resume-2563EB?style=for-the-badge" /></a>
  &nbsp;&nbsp;
  <a href="https://github.com/Amey-Thakur/RESUME-TEMPLATE/actions/workflows/build.yml"><img alt="Build Status" src="https://github.com/Amey-Thakur/RESUME-TEMPLATE/actions/workflows/build.yml/badge.svg?branch=main" /></a>
</p>

<p align="center">
  <img alt="Views" src="https://komarev.com/ghpvc/?username=Amey-Thakur-RESUME-TEMPLATE&label=Views&color=2563eb&style=flat-square" />
</p>

---

## How It Works

1. Edit `resume/configuration/resume_data.json` (or copy it from `resume_data.template.json`).
2. Run `scripts/build.ps1`. The pre-processor reads the JSON, escapes LaTeX characters, and writes the `.tex` section files.
3. Tectonic compiles `resume/source/resume.tex` and `resume/source/cover_letter.tex` into PDFs in `output/`.
4. On push to `main`, GitHub Actions runs the same pipeline and publishes the PDFs as a release.

---

## Repository Structure

```
├── .github/workflows/build.yml       # CI/CD: compile and release PDFs
├── resume/
│   ├── configuration/
│   │   └── resume_data.template.json  # Template with bracketed placeholders
│   ├── source/
│   │   └── resume.tex                 # Main resume entry point
│   └── templates/
│       ├── resume.sty                 # Page layout, margins, custom commands
│       └── cover_letter.sty           # Cover letter layout
├── scripts/
│   ├── generate_latex.ps1             # JSON to LaTeX pre-processor
│   └── build.ps1                      # Full build: pre-process + compile
└── README.md
```

Files generated at build time (gitignored):
- `resume/configuration/resume_data.json` — your personal data
- `resume/configuration/metadata.tex` — LaTeX contact variables
- `resume/sections/*.tex` — section content files
- `resume/source/cover_letter.tex` — cover letter document
- `output/*.pdf` — compiled PDFs

---

## For AI Agents

This repository separates content from formatting. All resume data lives in one JSON file with bracketed placeholders.

**To populate the template:**
1. Read `resume/configuration/resume_data.template.json`.
2. Replace every `[BRACKETED_PLACEHOLDER]` with real data.
3. Write the result to `resume/configuration/resume_data.json`.
4. Run `scripts/build.ps1`.

**Pre-processor handles automatically:**
- Escaping LaTeX reserved characters (`&`, `%`, `_`, `#`, `$`)
- Converting `|` to LaTeX math-mode `$|$`
- Deriving the PDF filename from `personal_info.name`

---

## Local Build

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build.ps1
```

Requires [Tectonic](https://tectonic-typesetting.github.io) installed globally or placed at `../bin/tectonic.exe` relative to the repository root.

---

## Automation

On every push to `main`, GitHub Actions:
1. Runs `generate_latex.ps1` via `pwsh` to populate the LaTeX files from JSON.
2. Compiles both documents with Tectonic.
3. Uploads PDFs as build artifacts (90-day retention).
4. Publishes a `latest` GitHub Release with the compiled PDFs.

---

## Design Decisions

| Decision | Rationale |
|---|---|
| JSON content store | Separates data from formatting. Safe for automated editing. |
| Bracketed placeholders | Unambiguous tokens. Easy to search and replace programmatically. |
| PowerShell pre-processor | Cross-platform via `pwsh`. Runs natively on Windows and in GitHub Actions. |
| Tectonic compiler | Self-contained. Downloads packages on demand. No TeX Live installation required. |
| `resume_data.json` gitignored | Prevents personal information from being committed to public repositories. |
| `\pdfgentounicode=1` | Ensures ATS-compatible, selectable, searchable text in the output PDF. |
| 0.5-inch margins | Standard professional resume margins. Maximizes content area. |

<img width="100%" alt="" src="https://capsule-render.vercel.app/api?type=waving&color=0:2563eb,100:1e3a8a&height=120&section=footer" />