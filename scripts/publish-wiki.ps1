<#
.SYNOPSIS
  Publish docs/wiki/*.md to the project's GitHub wiki repository.
.EXAMPLE
  ./scripts/publish-wiki.ps1 -WikiUrl https://github.com/<org>/<repo>.wiki.git -DryRun
  ./scripts/publish-wiki.ps1 -WikiUrl https://github.com/<org>/<repo>.wiki.git
#>
param(
    [Parameter(Mandatory = $true)][string]$WikiUrl,
    [string]$Message = "Update wiki from docs/wiki",
    [switch]$DryRun
)

# Native tools write progress and warnings to stderr; judge success by exit code only.
$ErrorActionPreference = 'Continue'

function Invoke-Git {
    param([string]$Dir, [Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    $out = & git -C $Dir @GitArgs 2>&1 | ForEach-Object { "$_" }
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed:`n$($out -join "`n")" }
    $out
}

$src = Join-Path $PSScriptRoot '..\docs\wiki'
if (-not (Test-Path $src)) { throw "Source folder not found: $src" }
$pages = Get-ChildItem $src -Filter *.md
if ($pages.Count -eq 0) { throw "No .md pages in $src" }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("aiws-wiki-" + [guid]::NewGuid().ToString('N'))
try {
    Write-Host "Cloning $WikiUrl ..."
    & git clone --quiet $WikiUrl $tmp 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not clone the wiki. Enable Wikis in the repo settings and create the first page in the browser; GitHub creates the wiki repository only then."
    }
    Invoke-Git $tmp config core.autocrlf false | Out-Null

    # Replace pages so pages deleted from docs/wiki also disappear from the wiki.
    Get-ChildItem $tmp -Filter *.md | Remove-Item -Force
    Copy-Item $pages.FullName -Destination $tmp

    Invoke-Git $tmp add -A | Out-Null
    $changes = Invoke-Git $tmp status --short
    if (-not $changes) { Write-Host "Wiki is already up to date."; return }
    Write-Host "Changes to publish:"
    $changes | ForEach-Object { Write-Host "  $_" }
    Invoke-Git $tmp commit --quiet -m $Message | Out-Null

    if ($DryRun) {
        Write-Host "`n[dry run] git push --dry-run"
        Invoke-Git $tmp push --dry-run | ForEach-Object { Write-Host "  $_" }
        Write-Host "Nothing was pushed."
    } else {
        Invoke-Git $tmp push | ForEach-Object { Write-Host "  $_" }
        Write-Host "`nPublished $($pages.Count) pages."
    }
} finally {
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
}
