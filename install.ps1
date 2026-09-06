param(
    [ValidateSet('cursor', 'claude', 'agents', 'legacy', 'all')]
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

if (($Tool -in @('agents', 'legacy')) -and $Rules -ne 'core') {
    Write-Warning "-Rules is ignored for -Tool $Tool."
}
if ($WithIndexIgnore -and $Tool -notin @('cursor', 'all')) {
    Write-Warning "-WithIndexIgnore is ignored for -Tool $Tool."
}

Write-Host "Installing Minimize-Cursor-Cost ($Tool) into: $Target"

try {
    # Windows PowerShell 5.1 turns a native command's stderr into terminating
    # errors under $ErrorActionPreference = 'Stop', so relax it for the clone
    # and check the exit code instead.
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git clone --depth=1 --quiet $RepoUrl $Tmp 2>&1 | Out-Null
    $cloneExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($cloneExit -ne 0) {
        throw "git clone failed (exit $cloneExit) for $RepoUrl"
    }
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

    function Copy-Rule([string]$Rule, [string]$Flavor) {
        if ($Flavor -eq 'claude') {
            $source = Join-Path $Src ".claude/rules/$Rule.md"
            $destination = Join-Path $Target ".claude/rules/$Rule.md"
        } else {
            $source = Join-Path $Src ".cursor/rules/$Rule.mdc"
            $destination = Join-Path $Target ".cursor/rules/$Rule.mdc"
        }
        if (-not (Test-Path $source)) {
            throw "Unknown rule for ${Flavor}: $Rule"
        }
        Copy-IfMissing $source $destination "$Flavor rule: $(Split-Path $source -Leaf)"
    }

    function Install-ScopedRules([string]$Flavor) {
        if ($Flavor -eq 'claude') {
            $dir = Join-Path $Src '.claude/rules'; $filter = '*.md'
        } else {
            $dir = Join-Path $Src '.cursor/rules'; $filter = '*.mdc'
        }

        if ($Rules -eq 'all') {
            Get-ChildItem $dir -Filter $filter |
                Where-Object { $_.BaseName -notin @('core', 'agent-efficiency') } |
                ForEach-Object { Copy-Rule $_.BaseName $Flavor }
        } elseif ($Rules -and $Rules -ne 'core') {
            $Rules.Split(',') |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ } |
                ForEach-Object { Copy-Rule $_ $Flavor }
        }
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

        if ($Rules -ne 'core') {
            New-Item -ItemType Directory -Path (Join-Path $Target '.claude/rules') -Force | Out-Null
            Install-ScopedRules 'claude'
        }
    }

    if ($Tool -in @('agents', 'all')) {
        Copy-IfMissing `
            (Join-Path $Src 'AGENTS.md') `
            (Join-Path $Target 'AGENTS.md') `
            'AGENTS.md (project notes preserved)'
    }

    if ($Tool -in @('legacy', 'all')) {
        Copy-IfMissing `
            (Join-Path $Src '.cursorrules') `
            (Join-Path $Target '.cursorrules') `
            '.cursorrules'
    }

    if ($Tool -in @('cursor', 'all')) {
        $rulesDir = Join-Path $Target '.cursor/rules'
        New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
        Copy-Rule 'core' 'cursor'
        Copy-Rule 'agent-efficiency' 'cursor'
        Install-ScopedRules 'cursor'

        if ($WithIndexIgnore) {
            Copy-IfMissing `
                (Join-Path $Src '.cursorindexingignore.example') `
                (Join-Path $Target '.cursorindexingignore') `
                '.cursorindexingignore'
        }
    }

    Write-Host "Installed: $script:Added file(s); skipped existing: $script:Skipped."
    if ($Tool -in @('claude', 'agents', 'all')) {
        Write-Host 'Next: fill in the Project-Specific Notes section if it is empty.'
    }
}
finally {
    if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp }
}
