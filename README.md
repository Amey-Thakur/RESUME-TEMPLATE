<img width="100%" alt="Resume Template" src="https://capsule-render.vercel.app/api?type=waving&color=0:1e3a8a,100:2563eb&height=210&section=header&text=[YOUR_NAME]&fontColor=ffffff&fontSize=54&fontAlignY=40&desc=[YOUR_TITLE]&descSize=18&descAlignY=62" />

<br>

<h2 align="center">Resume & Cover Letter Template</h2>

<h3 align="center">Modular, Automated, and AI-Ready LaTeX Document pipeline</h3>

<p align="center">
  A professional LaTeX layout decoupled into a structured JSON content store and reusable styling sheets.
</p>

<br>

<p align="center">
  <a href="https://github.com/[YOUR_GITHUB_USERNAME]/[YOUR_REPOSITORY_NAME]/releases/latest/download/[YOUR_NAME_SAFE]_Resume.pdf"><img alt="Download Resume PDF" src="https://img.shields.io/badge/Download%20Resume-2563EB?style=for-the-badge" /></a>
  &nbsp;&nbsp;
  <a href="https://github.com/[YOUR_GITHUB_USERNAME]/[YOUR_REPOSITORY_NAME]/releases/latest/download/[YOUR_NAME_SAFE]_Cover_Letter.pdf"><img alt="Download Cover Letter PDF" src="https://img.shields.io/badge/Download%20Cover%20Letter-1D4ED8?style=for-the-badge" /></a>
  &nbsp;&nbsp;
  <a href="https://[YOUR_PORTFOLIO_URL]"><img alt="Portfolio Website" src="https://img.shields.io/badge/Portfolio-0A66C2?style=for-the-badge" /></a>
  &nbsp;&nbsp;
  <a href="mailto:[YOUR_EMAIL_ADDRESS]"><img alt="Email Me" src="https://img.shields.io/badge/Email-334155?style=for-the-badge" /></a>
</p>

<br>

<p align="center">
  <img alt="Resume views" src="https://komarev.com/ghpvc/?username=[YOUR_GITHUB_USERNAME]&label=Resume%20views&color=2563eb&style=flat-square" />
</p>

<br>

---

## Guide for AI Agents and LLMs

This repository is designed to be fully parseable and editable by AI coding assistants. Decoupling the text content from the LaTeX compile files prevents common compilation errors (e.g. unescaped symbols).

### Editing Content
All content is managed in a single file:
`resume/configuration/resume_data.json`

If the file is not present, running the build script copies it from the template:
`resume/configuration/resume_data.template.json`

To modify the details:
1. Parse [resume_data.template.json](resume/configuration/resume_data.template.json).
2. Replace all bracketed tokens (e.g. `[YOUR_FULL_NAME]`, `[YOUR_EMAIL_ADDRESS]`) with actual details.
3. Save the new parameters to `resume/configuration/resume_data.json`.
4. Run the compilation script.

### Pre-processing Rules
The generator script [generate_latex.ps1](scripts/generate_latex.ps1) handles the following conversions automatically:
- Escapes special LaTeX characters (`&`, `%`, `_`, `#`, `$`) inside text nodes recursively.
- Replaces vertical dividers (`|`) with LaTeX math spacers (`$|$`).
- Extracts the candidate's name dynamically to name the final PDF files.

---

## Directory Structure

```text
Resume/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions workflow for PDF release
├── resume/
│   ├── source/
│   │   ├── resume.tex         # Main LaTeX resume entry point
│   │   └── cover_letter.tex   # Main LaTeX cover letter entry point
│   ├── templates/
│   │   ├── resume.sty         # Layout settings, margins, and custom macros
│   │   └── cover_letter.sty   # Custom styling for cover letters
│   ├── configuration/
│   │   ├── resume_data.json   # Local personal data file (gitignored)
│   │   ├── resume_data.template.json  # Reusable template data with placeholders
│   │   └── metadata.tex       # Generated LaTeX contact variables
│   └── sections/              # Generated LaTeX content sections
│       ├── summary.tex
│       ├── education.tex
│       ├── experience.tex
│       ├── skills.tex
│       └── certifications.tex
├── output/                    # Compiled PDF output files
│   ├── Resume.pdf
│   ├── Cover_Letter.pdf
│   ├── [YOUR_NAME_SAFE]_Resume.pdf
│   └── [YOUR_NAME_SAFE]_Cover_Letter.pdf
├── scripts/
│   ├── generate_latex.ps1     # JSON data pre-processor
│   └── build.ps1              # Local compiler invoker
└── README.md
```

---

## Local Compilation

Compile your resume and cover letter locally on Windows:

1. Open PowerShell.
2. Navigate to the project root directory.
3. Run the compilation script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/build.ps1
   ```

The script will pre-process the JSON configurations, write the `.tex` files, and compile the final PDFs to `output/` using Tectonic.

---

## Automation (GitHub Actions)

On pushing changes to the `main` branch:
1. GitHub Actions runs on an Ubuntu runner.
2. It sets up Tectonic and executes the `generate_latex.ps1` pre-processor script using `pwsh`.
3. It parses the candidate's name via `jq` to name the PDF dynamically.
4. Generates both generic (`Resume.pdf`) and custom named (`[YOUR_NAME_SAFE]_Resume.pdf`) files.
5. Recreates the `latest` GitHub Release with the compiled PDFs.

---

## Standards and Compliance

- **Layout Structure**: Margins are set to a clean `0.5 in` via `resume.sty`. Vertical spacing and bullet indents are formatted to keep content on exactly one page.
- **ATS Parsing**: Uses `\pdfgentounicode=1` to ensure correct Unicode character mapping. All text is fully searchable and selectable.
- **Access**: Badge assets use standard shields endpoints. Email references use the term "Email" directly without hyphenation.

---

<img width="100%" alt="" src="https://capsule-render.vercel.app/api?type=waving&color=0:2563eb,100:1e3a8a&height=120&section=footer" />