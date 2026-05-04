# install.ps1 — Drop Minimize-Cursor-Cost rules into the current project.
# Windows PowerShell 5+ / PowerShell 7+
#
# Usage (from project root):
#   irm https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.ps1 | iex
# or:
#   .\install.ps1

$ErrorActionPreference = 'Stop'

$RepoUrl   = 'https://github.com/inboxpraveen/Minimize-Cursor-Cost'
$SrcSubdir = 'lean-cursor'
$Target    = (Get-Location).Path
$Tmp       = Join-Path ([System.IO.Path]::GetTempPath()) ("mcc-" + [guid]::NewGuid().ToString('N'))

# The repo is cloned into a system temp dir. Only the lean-cursor/ subtree is
# copied into your project — top-level repo files (assets/, README.md, LICENSE,
# install.*, CONTRIBUTING.md) never touch your project. The temp clone, including
# the assets/ folder, is wiped by the finally{} block on script exit.

Write-Host "-> Installing Minimize-Cursor-Cost into: $Target"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git is required but not found. Install git and re-run.'
    exit 1
}

try {
    git clone --depth=1 $RepoUrl $Tmp 2>$null | Out-Null
    $Src = Join-Path $Tmp $SrcSubdir

    function Backup-IfExists($relPath) {
        $full = Join-Path $Target $relPath
        if (Test-Path $full) {
            $bak = "$full.bak.$([int][double]::Parse((Get-Date -UFormat %s)))"
            Write-Host "   * Backing up existing $relPath -> $(Split-Path $bak -Leaf)"
            Move-Item $full $bak
        }
    }

    Backup-IfExists 'CLAUDE.md'
    Backup-IfExists '.cursorrules'
    Backup-IfExists 'PROMPT_TEMPLATES.md'

    Copy-Item (Join-Path $Src 'CLAUDE.md')           (Join-Path $Target 'CLAUDE.md')           -Force
    Copy-Item (Join-Path $Src '.cursorrules')        (Join-Path $Target '.cursorrules')        -Force
    Copy-Item (Join-Path $Src 'PROMPT_TEMPLATES.md') (Join-Path $Target 'PROMPT_TEMPLATES.md') -Force

    # Merge .cursor/rules: don't clobber user rules; only add new ones.
    $rulesDir = Join-Path $Target '.cursor\rules'
    New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null

    $added = 0; $skipped = 0
    Get-ChildItem (Join-Path $Src '.cursor\rules') -Filter '*.mdc' | ForEach-Object {
        $dest = Join-Path $rulesDir $_.Name
        if (Test-Path $dest) {
            $skipped++
            Write-Host "   * Skipping existing rule: $($_.Name)"
        } else {
            Copy-Item $_.FullName $dest
            $added++
        }
    }

    Write-Host ''
    Write-Host '+ Installed.'
    Write-Host "   * CLAUDE.md, .cursorrules, PROMPT_TEMPLATES.md -> project root"
    Write-Host "   * $added new rules added to .cursor\rules\   ($skipped existing skipped)"
    Write-Host "   * Temp clone (incl. assets\ and other repo files) will be removed on exit."
    Write-Host ''
    Write-Host "Next: open CLAUDE.md and fill in the 'Project-Specific Notes' section."
    Write-Host '      That single edit is the highest-ROI step.'
}
finally {
    if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp }
}
