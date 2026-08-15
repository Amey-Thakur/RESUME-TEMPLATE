<div align="center">

<br>

# Resume Template

**Edit one JSON file. The resume and the cover letter build themselves.**

<br>

A LaTeX resume and cover letter where the content lives in a single JSON file
and no one has to touch the typesetting. A pre-processor writes the LaTeX, and
Tectonic compiles the PDFs. Push to `main` and GitHub Actions publishes them as
a release.

<br>

[Download the latest PDFs](https://github.com/Amey-Thakur/RESUME-TEMPLATE/releases/latest) &nbsp;·&nbsp;
[The data file](#the-data-file) &nbsp;·&nbsp;
[For AI agents](#for-ai-agents) &nbsp;·&nbsp;
[Build it](#build-it-locally) &nbsp;·&nbsp;
[Discussions](https://github.com/Amey-Thakur/RESUME-TEMPLATE/discussions)

<br>

[![Build](https://github.com/Amey-Thakur/RESUME-TEMPLATE/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/Amey-Thakur/RESUME-TEMPLATE/actions/workflows/build.yml)
[![Technology](https://img.shields.io/badge/Technology-LaTeX_%7C_Python-8250DF)](https://tectonic-typesetting.github.io)
[![Type](https://img.shields.io/badge/Type-Template-546E7A)](https://github.com/Amey-Thakur/RESUME-TEMPLATE/generate)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

<br>

<img src=".github/social-preview.png" alt="Resume Template: edit one JSON file, a pre-processor generates the LaTeX sections, Tectonic compiles the PDF, and GitHub Actions publishes it as a release" width="100%">

</div>

---

<br>

## How it works

```mermaid
flowchart LR
    A["resume_data.json<br>all of your content"] --> B["generate_latex.py<br>escapes and writes the sections"]
    B --> C["resume/sections/*.tex"]
    B --> D["metadata.tex<br>_manifest.tex"]
    C --> E(["Tectonic"])
    D --> E
    E --> F["output/*.pdf"]
    F --> G["GitHub Release"]
```

Four properties follow from that shape, and each one is the reason a piece of
this exists.

**Content never touches LaTeX.** You write plain text. The pre-processor escapes
every reserved character, so an ampersand in a company name or a percentage in a
bullet cannot break the build.

**Sections are optional.** `section_order` in the JSON decides which sections
appear and in what order. Leave `publications` out of that list and the heading
does not exist in the PDF. No empty sections, no editing the document to remove
one.

**The output is machine readable.** `\pdfgentounicode=1` and T1 encoding mean the
text layer of the PDF copies and parses correctly, which is what an applicant
tracking system reads.

**One pre-processor, not two.** The shell script, the PowerShell script and CI
all call the same Python file, so the escaping rules cannot drift apart.

<br>

## The data file

Copy the template and fill it in. Your own copy is gitignored, so personal
details never reach a public repository.

```bash
cp resume/configuration/resume_data.template.json resume/configuration/resume_data.json
```

Every field is a bracketed placeholder such as `[YOUR_FULL_NAME]`. Replace them
all, then check nothing was missed:

```bash
python scripts/generate_latex.py --check
```

> [!TIP]
> Write a plain `|` when you want a separator. The pre-processor typesets it.
> Never write LaTeX in the JSON: `&`, `%`, `_`, `#`, `$`, `{`, `}`, `~`, `^` and
> `\` are all escaped for you.

> [!IMPORTANT]
> Bullets are scored on evidence, not duties. The template asks for
> **accomplished X, as measured by Y, by doing Z**. A bullet with no number in
> it describes a job description rather than your work, and it is the first
> thing a reviewer discounts.

<br>

## For AI agents

This repository is built to be filled in by an agent without further
instruction. The content model is one JSON file, and it carries its own
directions in an `_instructions` block that the pre-processor ignores.

1. Read `resume/configuration/resume_data.template.json`.
2. Replace every `[BRACKETED_PLACEHOLDER]` with real content. Follow the
   `bullet_formula` in `_instructions`.
3. Delete any section you cannot fill honestly, and remove its name from
   `section_order`.
4. Write the result to `resume/configuration/resume_data.json`.
5. Run `python scripts/generate_latex.py --check`. It exits non-zero and lists
   what is left while any placeholder remains.
6. Build with `scripts/build.sh` or `scripts/build.ps1`.

The pre-processor handles escaping, separator typesetting, section ordering and
omission, and the PDF filename. There is nothing else to decide.

<br>

## Build it locally

Needs [Python 3](https://www.python.org/downloads/) and
[Tectonic](https://tectonic-typesetting.github.io). Tectonic downloads the TeX
packages it needs on demand, so there is no TeX Live installation.

```bash
./scripts/build.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build.ps1
```

To regenerate the LaTeX without compiling:

```bash
python scripts/generate_latex.py
```

<br>

## What CI does

On every push to `main`, the workflow runs the same pre-processor, compiles both
documents with Tectonic, uploads the PDFs as artefacts for 90 days, and replaces
the `latest` release with the new files.

> [!NOTE]
> With no `resume_data.json` present, the build uses
> [`resume_data.example.json`](resume/configuration/resume_data.example.json), a
> worked example for an invented engineer. That is what the published release
> contains, so the sample PDFs show what the template actually produces rather
> than a page of bracketed placeholders. Your own `resume_data.json` takes
> precedence the moment it exists, and it is gitignored.

<br>

## What is where

| Path | What it holds |
| :--- | :--- |
| [resume/configuration/](resume/configuration/) | [`resume_data.template.json`](resume/configuration/resume_data.template.json), the only file you edit, and [`resume_data.example.json`](resume/configuration/resume_data.example.json), a worked example |
| [resume/templates/](resume/templates/) | [`base.sty`](resume/templates/base.sty) with the shared layout, plus a thin style for each document |
| [resume/source/](resume/source/) | `resume.tex`, the entry point. The cover letter is generated |
| [scripts/](scripts/) | [`generate_latex.py`](scripts/generate_latex.py), the pre-processor, and the two build wrappers |
| [.github/workflows/](.github/workflows/) | Compile and publish |

Rebuilt on every run and gitignored: `resume_data.json`, `metadata.tex`,
`resume/sections/`, `resume/source/cover_letter.tex`, `output/`.

<br>

## Design decisions

| Decision | Why |
| :--- | :--- |
| Content in JSON | Separates data from typesetting, and is safe for a program to edit |
| Bracketed placeholders | Unambiguous, and greppable, so unfilled fields can be detected rather than shipped |
| A single Python pre-processor | Two implementations of the escaping rules drifted, and a separator bug survived in one of them |
| Character-by-character escaping | A substitution cannot be re-processed by a later rule, which is what produced malformed output before |
| `titlesec` and `enumitem` spacing | Declarative spacing holds as content grows. Negative `\vspace` corrections overlap once a section gets dense |
| Shared `base.sty` | The resume and the cover letter cannot drift apart |
| `\pdfgentounicode=1`, T1 | The PDF text layer stays selectable, searchable and parseable |
| Tectonic | Self-contained, fetches packages on demand, no TeX Live |
| `resume_data.json` gitignored | Personal details never reach a public fork |

<br>

---

<div align="center">

Prepared by **[Amey Thakur](https://github.com/Amey-Thakur)** &nbsp;·&nbsp;
ORCID [0000-0001-5644-1575](https://orcid.org/0000-0001-5644-1575)

<sub>Released under the <a href="LICENSE">MIT License</a>, with citation metadata in <a href="CITATION.cff">CITATION.cff</a>.<br>
Use it, fork it, and make it yours.</sub>

</div>
