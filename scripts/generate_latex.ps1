#-------------------------------------------------------------------
# LaTeX Pre-processor: Dynamic Content Generator from JSON
#-------------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Resolve directories relative to the script location
$ConfigDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resume\configuration"))
$SectionsDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resume\sections"))
$SourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resume\source"))

$JsonPath = Join-Path $ConfigDir "resume_data.json"
$TemplatePath = Join-Path $ConfigDir "resume_data.template.json"

# Check if target data JSON exists; fallback to template if missing
if (-not (Test-Path $JsonPath)) {
    Write-Host "Local resume_data.json not found. Copying template..." -ForegroundColor Yellow
    Copy-Item $TemplatePath $JsonPath -Force
}

Write-Host "Reading data from $JsonPath..." -ForegroundColor Cyan
$rawData = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json

# Helper to escape special LaTeX characters to prevent compilation errors
function Escape-LaTeX ($val) {
    if ($null -eq $val) { return "" }
    $text = $val.ToString()
    
    # 1. Escape LaTeX reserved character symbols
    # We replace backslashes first, then others, to avoid double-escaping
    $text = $text.Replace('&', '\&')
    $text = $text.Replace('%', '\%')
    $text = $text.Replace('_', '\_')
    $text = $text.Replace('#', '\#')
    $text = $text.Replace('$', '\$')
    
    # 2. Normalize vertical pipe separator character to standard LaTeX vertical spacer
    $text = $text.Replace(' \$|\$ ', ' $|$ ')
    $text = $text.Replace(' | ', ' $|$ ')
    $text = $text.Replace('|', ' $|$ ')
    
    return $text
}

# Recursive processor to find all string nodes in arrays and objects
function Escape-Object ($obj) {
    if ($null -eq $obj) { return $null }
    if ($obj -is [string]) {
        return Escape-LaTeX $obj
    }
    if ($obj -is [array]) {
        $arr = @()
        foreach ($item in $obj) {
            $arr += Escape-Object $item
        }
        return $arr
    }
    if ($obj -is [PSCustomObject]) {
        $newObj = [PSCustomObject]@{ }
        foreach ($prop in $obj.psobject.Properties) {
            $newObj | Add-Member -MemberType NoteProperty -Name $prop.Name -Value (Escape-Object $prop.Value) -Force
        }
        return $newObj
    }
    return $obj
}

# Escape the parsed JSON structure
Write-Host "Escaping JSON strings for LaTeX compatibility..." -ForegroundColor Cyan
$data = Escape-Object $rawData

# Create folders if missing
if (-not (Test-Path $SectionsDir)) { New-Item -ItemType Directory -Path $SectionsDir -Force | Out-Null }
if (-not (Test-Path $SourceDir)) { New-Item -ItemType Directory -Path $SourceDir -Force | Out-Null }

# 1. Generate resume/configuration/metadata.tex
Write-Host "Generating: resume/configuration/metadata.tex" -ForegroundColor Yellow
$metadata = @"
%-------------------------
% Personal Details and Links Configuration
%-------------------------
\newcommand{\myName}{$($data.personal_info.name)}
\newcommand{\myPhone}{$($data.personal_info.phone)}
\newcommand{\myEmail}{$($data.personal_info.email)}
\newcommand{\myLinkedIn}{$($data.personal_info.linkedin)}
\newcommand{\myLinkedInUrl}{$($data.personal_info.linkedin_url)}
\newcommand{\myGitHub}{$($data.personal_info.github)}
\newcommand{\myGitHubUrl}{$($data.personal_info.github_url)}
\newcommand{\myLocation}{$($data.personal_info.location)}
"@
Set-Content -Path (Join-Path $ConfigDir "metadata.tex") -Value $metadata -Encoding UTF8

# 2. Generate resume/sections/summary.tex
Write-Host "Generating: resume/sections/summary.tex" -ForegroundColor Yellow
$summary = @"
%-------------------------
% Professional Summary Section
%-------------------------
\section{Summary}
\small{$($data.resume.summary)}
"@
Set-Content -Path (Join-Path $SectionsDir "summary.tex") -Value $summary -Encoding UTF8

# 3. Generate resume/sections/education.tex
Write-Host "Generating: resume/sections/education.tex" -ForegroundColor Yellow
$edu_items = @()
foreach ($edu in $data.resume.education) {
    $edu_items += "  \resumeSubheading"
    $edu_items += "    {$($edu.institution)}{$($edu.location)}"
    $edu_items += "    {$($edu.degree)}{$($edu.date)}"
}
$education = @"
%-------------------------
% Education Section
%-------------------------
\section{Education}
\resumeSubHeadingListStart
$($edu_items -join "`n")
\resumeSubHeadingListEnd
"@
Set-Content -Path (Join-Path $SectionsDir "education.tex") -Value $education -Encoding UTF8

# 4. Generate resume/sections/experience.tex
Write-Host "Generating: resume/sections/experience.tex" -ForegroundColor Yellow
$exp_items = @()
foreach ($job in $data.resume.experience) {
    $exp_items += "  \resumeSubheading"
    $exp_items += "    {$($job.role)}{$($job.date)}"
    $exp_items += "    {$($job.company)}{$($job.location)}"
    $exp_items += "    \resumeItemListStart"
    foreach ($bullet in $job.bullets) {
        $exp_items += "      \resumeItem{$bullet}"
    }
    $exp_items += "    \resumeItemListEnd"
    $exp_items += ""
}
$experience = @"
%-------------------------
% Professional Experience Section
%-------------------------
\section{Professional Experience}
\resumeSubHeadingListStart

$($exp_items -join "`n")
\resumeSubHeadingListEnd
"@
Set-Content -Path (Join-Path $SectionsDir "experience.tex") -Value $experience -Encoding UTF8

# 5. Generate resume/sections/skills.tex
Write-Host "Generating: resume/sections/skills.tex" -ForegroundColor Yellow
$skills_items = @()
foreach ($skill_cat in $data.resume.skills) {
    $skills_items += "  \small \item \textbf{$($skill_cat.category)}{: $($skill_cat.items)}"
}
$skills = @"
%-------------------------
% Technical Skills Section
%-------------------------
\section{Technical Skills}
\begin{itemize}[leftmargin=0.15in, label={}, itemsep=3pt]
$($skills_items -join "`n")
\end{itemize}
"@
Set-Content -Path (Join-Path $SectionsDir "skills.tex") -Value $skills -Encoding UTF8

# 6. Generate resume/sections/certifications.tex
Write-Host "Generating: resume/sections/certifications.tex" -ForegroundColor Yellow
$cert_items = @()
foreach ($cert in $data.resume.certifications) {
    $cert_items += "  \small \item \textbf{$($cert.category)}{: $($cert.items)}"
}
$certifications = @"
%-------------------------
% Certifications & Distinctions Section
%-------------------------
\section{Certifications \& Distinctions}
\begin{itemize}[leftmargin=0.15in, label={}, itemsep=3pt]
$($cert_items -join "`n")
\end{itemize}
"@
Set-Content -Path (Join-Path $SectionsDir "certifications.tex") -Value $certifications -Encoding UTF8

# 7. Generate resume/source/cover_letter.tex
Write-Host "Generating: resume/source/cover_letter.tex" -ForegroundColor Yellow
$paragraphs = @()
foreach ($p in $data.cover_letter.paragraphs) {
    $paragraphs += "\noindent $p`n`n\vspace{1em}"
}
$cover_letter = @"
%-------------------------
% Main Cover Letter Entry Point
%-------------------------
\documentclass[letterpaper,11pt]{article}

\usepackage{../templates/cover_letter}
\input{../configuration/metadata}

\begin{document}

\makeHeader

\vspace{2em}

\today

\vspace{1em}
\noindent\textbf{$($data.cover_letter.recipient.name)} \newline
$($data.cover_letter.recipient.company) \newline
$($data.cover_letter.recipient.address)

\vspace{2em}

\noindent\textbf{$($data.cover_letter.subject)}

\vspace{1em}

\noindent Dear $($data.cover_letter.recipient.name),

\vspace{1em}

$($paragraphs -join "`n")

\vspace{1em}

\noindent Sincerely,

\vspace{1.5em}

\noindent \textbf{\myName}

\end{document}
"@
Set-Content -Path (Join-Path $SourceDir "cover_letter.tex") -Value $cover_letter -Encoding UTF8

Write-Host "All LaTeX source files updated from JSON data." -ForegroundColor Green
