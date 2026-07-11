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

# Standardize output filenames dynamically based on the configured name
$RawResume = Join-Path $OutputDir "resume.pdf"
$RawCover = Join-Path $OutputDir "cover_letter.pdf"

$Data = Get-Content -Raw -Path (Join-Path $PSScriptRoot "..\resume\configuration\resume_data.json") | ConvertFrom-Json
$Name = $Data.personal_info.name
$SafeName = $Name -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_'

if (Test-Path $RawResume) {
    Copy-Item $RawResume (Join-Path $OutputDir "${SafeName}_Resume.pdf") -Force
    $TempResume = Join-Path $OutputDir "temp_resume.pdf"
    Rename-Item $RawResume -NewName "temp_resume.pdf" -Force
    Rename-Item $TempResume -NewName "Resume.pdf" -Force
    Write-Host "Generated: Resume.pdf and ${SafeName}_Resume.pdf" -ForegroundColor Green
}

if (Test-Path $RawCover) {
    Copy-Item $RawCover (Join-Path $OutputDir "${SafeName}_Cover_Letter.pdf") -Force
    $TempCover = Join-Path $OutputDir "temp_cover.pdf"
    Rename-Item $RawCover -NewName "temp_cover.pdf" -Force
    Rename-Item $TempCover -NewName "Cover_Letter.pdf" -Force
    Write-Host "Generated: Cover_Letter.pdf and ${SafeName}_Cover_Letter.pdf" -ForegroundColor Green
}
