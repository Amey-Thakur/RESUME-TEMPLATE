#-------------------------------------------------------------------
# Local Build Script for LaTeX Documents via Tectonic
#-------------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Ensure output directory exists relative to the script location
$OutputDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\output"))
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Run LaTeX generator pre-processor script
Write-Host "Running LaTeX pre-processor..." -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "generate_latex.ps1")

# Resolve Tectonic path
$TectonicPath = "tectonic"
if (-not (Get-Command "tectonic" -ErrorAction SilentlyContinue)) {
    # Check our pre-downloaded workspace bin binary
    $WorkspaceBin = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\bin\tectonic.exe"))
    if (Test-Path $WorkspaceBin) {
        $TectonicPath = $WorkspaceBin
    } else {
        Write-Error "Tectonic LaTeX compiler not found globally or in the workspace binary folder."
    }
}

Write-Host "Using Tectonic compiler at: $TectonicPath" -ForegroundColor Cyan

# Compile Resume.tex
Write-Host "Compiling Resume..." -ForegroundColor Yellow
$ResumeSource = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resume\source\resume.tex"))
& $TectonicPath $ResumeSource --outdir $OutputDir

# Compile cover_letter.tex
Write-Host "Compiling Cover Letter..." -ForegroundColor Yellow
$CoverLetterSource = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resume\source\cover_letter.tex"))
& $TectonicPath $CoverLetterSource --outdir $OutputDir

# Rename output files
$RawResume = Join-Path $OutputDir "resume.pdf"
$RawCover = Join-Path $OutputDir "cover_letter.pdf"

$Data = Get-Content -Raw -Path (Join-Path $PSScriptRoot "..\resume\configuration\resume_data.json") | ConvertFrom-Json
$SafeName = ($Data.personal_info.name -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_').Trim('_')

if (Test-Path $RawResume) {
    Move-Item $RawResume (Join-Path $OutputDir "${SafeName}_Resume.pdf") -Force
    Write-Host "Generated: ${SafeName}_Resume.pdf" -ForegroundColor Green
}

if (Test-Path $RawCover) {
    Move-Item $RawCover (Join-Path $OutputDir "${SafeName}_Cover_Letter.pdf") -Force
    Write-Host "Generated: ${SafeName}_Cover_Letter.pdf" -ForegroundColor Green
}

