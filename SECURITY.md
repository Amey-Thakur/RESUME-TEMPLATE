# Security Policy

## Project status

This repository is a finished LaTeX resume and cover letter template. It has
reached a stable, usable state and is no longer under active development. It is
kept available because it works, not because it is being extended.

## What is in scope

The repository ships no service and stores no data. The parts worth reporting
against are:

- the GitHub Actions workflow in `.github/workflows/`
- the build scripts and the pre-processor in `scripts/`
- the LaTeX packages in `resume/templates/`

Your own `resume_data.json` is gitignored and never leaves your machine, so
personal details are not part of this repository's surface.

## Supported version

| Version | Supported |
| ------- | --------- |
| 1.0.0   | Yes       |

## Reporting

Open an issue on the repository:

**[github.com/Amey-Thakur/RESUME-TEMPLATE/issues](https://github.com/Amey-Thakur/RESUME-TEMPLATE/issues)**

Please include:

1. What the problem is.
2. How to reproduce it, if it can be reproduced.
3. What you expected against what happened.
4. What it could affect.

Reports are read and, where a fix is warranted, addressed as time allows.
Because the project is no longer actively developed, no response time is
promised. If you need a change immediately, the licence permits forking, and a
pull request is welcome.

## Handling your own copy

Two habits matter more than anything in this repository:

- Keep `resume_data.json` out of version control. It is already in
  `.gitignore`; check before your first commit if you have restructured things.
- Review the published release before sharing a link. The workflow publishes
  whatever is in the data file at the time of the build.
