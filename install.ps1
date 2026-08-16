param(
    [ValidateSet('cursor', 'claude', 'legacy', 'all')]
    [string]$Tool = 'cursor',
    [string]$Rules = 'core',
    [switch]$WithIndexIgnore
)

# Install only the adapters and scoped rules the target project needs.
$ErrorActionPreference = 'Stop'
$RepoUrl = if ($env:MCC_REPO_URL) { $env:MCC_REPO_URL } else { 'https://github.com/inboxpraveen/Minimize-Cursor-Cost' }
$Target = (Get-Location).Path
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("mcc-" + [guid]::NewGuid().ToString('N'))
$script:Added = 0
$script:Skipped = 0

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git is required but not found.'
    exit 1
}

Write-Host "Installing Minimize-Cursor-Cost ($Tool) into: $Target"

try {
    git clone --depth=1 $RepoUrl $Tmp 2>$null | Out-Null
    $Src = Join-Path $Tmp 'lean-cursor'

    function Copy-IfMissing([string]$Source, [string]$Destination, [string]$Label) {
        if (Test-Path $Destination) {
            $script:Skipped++
            Write-Host "  Skipping existing $Label"
        } else {
            Copy-Item $Source $Destination
            $script:Added++
        }
    }

    function Copy-Rule([string]$Rule) {
        $source = Join-Path $Src ".cursor\rules\$Rule.mdc"
        if (-not (Test-Path $source)) {
            throw "Unknown rule: $Rule"
        }
        $destination = Join-Path $Target ".cursor\rules\$Rule.mdc"
        Copy-IfMissing $source $destination "rule: $Rule.mdc"
    }

    Copy-IfMissing `
        (Join-Path $Src 'PROMPT_TEMPLATES.md') `
        (Join-Path $Target 'PROMPT_TEMPLATES.md') `
        'PROMPT_TEMPLATES.md'

    if ($Tool -in @('claude', 'all')) {
        Copy-IfMissing `
            (Join-Path $Src 'CLAUDE.md') `
            (Join-Path $Target 'CLAUDE.md') `
            'CLAUDE.md (project notes preserved)'
    }

    if ($Tool -in @('legacy', 'all')) {
        Copy-IfMissing `
            (Join-Path $Src '.cursorrules') `
            (Join-Path $Target '.cursorrules') `
            '.cursorrules'
    }

    if ($Tool -in @('cursor', 'all')) {
        $rulesDir = Join-Path $Target '.cursor\rules'
        New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
        Copy-Rule 'core'
        Copy-Rule 'agent-efficiency'

        if ($Rules -eq 'all') {
            Get-ChildItem (Join-Path $Src '.cursor\rules') -Filter '*.mdc' |
                Where-Object { $_.BaseName -notin @('core', 'agent-efficiency') } |
                ForEach-Object { Copy-Rule $_.BaseName }
        } elseif ($Rules -and $Rules -ne 'core') {
            $Rules.Split(',') |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ } |
                ForEach-Object { Copy-Rule $_ }
        }

        if ($WithIndexIgnore) {
            Copy-IfMissing `
                (Join-Path $Src '.cursorindexingignore.example') `
                (Join-Path $Target '.cursorindexingignore') `
                '.cursorindexingignore'
        }
    }

    Write-Host "Installed: $script:Added file(s); skipped existing: $script:Skipped."
    if ($Tool -in @('claude', 'all')) {
        Write-Host 'Next: fill in CLAUDE.md Project-Specific Notes if they are empty.'
    }
}
finally {
    if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp }
}
