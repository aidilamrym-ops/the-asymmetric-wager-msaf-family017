# H4-PATCH: manifest-based hard-gate integrity. Encoding-proof (no lakefile tokenizing).
# preResolutionPatchNames is the HARD gate in lakefile.lean (throws if .patch missing).
# Fail-safe: any manifest entry without a .patch file = exit 1. Parse cannot silently skew.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ProjectRoot)
$ErrorActionPreference = 'Stop'

# Hard manifest: the 11 labels in preResolutionPatchNames (lakefile.lean L161-163).
$Manifest = @(
  'iut','tate-curves-theta','genl','heights','pi1','orbicurve-cores','oka',
  'tempered-fundamental-groups','elliptic-curves','formal-schemes','belyi'
)
$lake = Join-Path $ProjectRoot 'lakefile.lean'
if(-not (Test-Path $lake)){ Write-Host "[!] lakefile.lean MISSING" -ForegroundColor Red; exit 1 }
$raw = [System.IO.File]::ReadAllText($lake, [System.Text.Encoding]::UTF8)

# 1) Every manifest label must actually appear in the lakefile (guards against stale manifest).
$missingInLake = @()
foreach($m in $Manifest){ if($raw -notmatch [regex]::Escape($m)){ $missingInLake += $m } }
if($missingInLake.Count -gt 0){
  Write-Host "[!] MANIFEST STALE - not in lakefile: $($missingInLake -join ', ')" -ForegroundColor Red
  exit 1
}

# 2) Every manifest label must have a .patch file.
$pd = Join-Path $ProjectRoot 'patches'
if(-not (Test-Path $pd)){ Write-Host "[!] patches/ MISSING" -ForegroundColor Red; exit 1 }
$have = (Get-ChildItem $pd -Filter *.patch).BaseName -replace '-lean4341$',''
$missingPatch = @()
foreach($m in $Manifest){ if($have -notcontains $m){ $missingPatch += $m } }
if($missingPatch.Count -gt 0){
  Write-Host "[!] HARD GATE BROKEN - no .patch for: $($missingPatch -join ', ')" -ForegroundColor Red
  exit 1
}

# 3) Detect manifest drift: lakefile lists MORE backtick names than we track.
$block = ($raw -split 'preResolutionPatchNames',2)[1]
if($block.Length -gt 0){ $block = ($block -split "`n")[0..3] -join ' ' }
$lakeNames = [regex]::Matches($block,'`[^A-Za-z0-9]*([A-Za-z0-9][A-Za-z0-9_\-]+)') |
             ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$drift = $lakeNames | Where-Object { $Manifest -notcontains $_ }
if($drift.Count -gt 0){
  Write-Host "[!] DRIFT - in lakefile preRes but not in manifest: $($drift -join ', ')" -ForegroundColor Red
  exit 1
}

"manifest labels : $($Manifest.Count)"
"patch files     : $($have.Count)"
"lake preRes hits: $($lakeNames.Count)"
Write-Host "[i] HARD-GATE PATCH MANIFEST INTACT" -ForegroundColor Green
exit 0
