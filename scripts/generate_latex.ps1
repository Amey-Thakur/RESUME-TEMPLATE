<#
    Compatibility shim.

    The pre-processor is generate_latex.py. There was once a second
    implementation in PowerShell, and keeping two copies of the LaTeX escaping
    rules in step is how the pipe-separator bug survived as long as it did.
    This file now forwards to the Python one so there is a single source of
    truth, and any arguments are passed straight through.

        pwsh scripts/generate_latex.ps1
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$Python = "python"
if (Get-Command "py" -ErrorAction SilentlyContinue) { $Python = "py" }
elseif (Get-Command "python3" -ErrorAction SilentlyContinue) { $Python = "python3" }

& $Python (Join-Path $ScriptDir "generate_latex.py") @args
exit $LASTEXITCODE
