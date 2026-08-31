<#
    Build the resume and the cover letter.

        powershell -ExecutionPolicy Bypass -File scripts/build.ps1

    Needs Python 3 for the pre-processor and Tectonic for the compile step.
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $ScriptDir "..")

$OutputDir = "output"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$Python = "python"
if (Get-Command "py" -ErrorAction SilentlyContinue) { $Python = "py" }
elseif (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
    Write-Error "Python 3 was not found. Install it from https://www.python.org/downloads/"
}

Write-Host "Pre-processing JSON into LaTeX"
& $Python scripts/generate_latex.py
if ($LASTEXITCODE -ne 0) { Write-Error "The pre-processor failed." }

$Tectonic = "tectonic"
if (-not (Get-Command "tectonic" -ErrorAction SilentlyContinue)) {
    if (Test-Path "bin/tectonic.exe") { $Tectonic = "bin/tectonic.exe" }
    else { Write-Error "Tectonic was not found. Install it from https://tectonic-typesetting.github.io" }
}

Write-Host "Compiling with $Tectonic"
& $Tectonic resume/source/resume.tex --outdir $OutputDir
if ($LASTEXITCODE -ne 0) { Write-Error "The resume failed to compile." }
& $Tectonic resume/source/cover_letter.tex --outdir $OutputDir
if ($LASTEXITCODE -ne 0) { Write-Error "The cover letter failed to compile." }

# One implementation of the naming rule, shared with CI.
$Stem = (& $Python scripts/generate_latex.py --name).Trim()
if ($Stem) {
    Move-Item -Force (Join-Path $OutputDir "resume.pdf")       (Join-Path $OutputDir "$($Stem)_Resume.pdf")
    Move-Item -Force (Join-Path $OutputDir "cover_letter.pdf") (Join-Path $OutputDir "$($Stem)_Cover_Letter.pdf")
}

Write-Host ""
Write-Host "Built:"
Get-ChildItem (Join-Path $OutputDir "*.pdf") | ForEach-Object { Write-Host "  $($_.Name)" }
