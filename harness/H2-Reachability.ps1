# H2-REACHABILITY: build import graph from the declared entry module, report orphans.
# Fail-safe: an orphan OR a broken index = exit 1. Cannot silently pass.
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Root,
  [string]$Entry = 'OAI.NumberTheory.PiExponent.Main',
  [string]$Prefix = 'OAI.NumberTheory.PiExponent'
)
$ErrorActionPreference = 'Stop'
$map = @{}
$files = Get-ChildItem $Root -Recurse -Filter *.lean -File
foreach($f in $files){
  $rel = ($f.FullName -replace [regex]::Escape($Root),'').TrimStart('\') -replace '\\','.' -replace '\.lean$',''
  if($rel -notlike "$Prefix.*"){ $mod = "$Prefix.$rel" } else { $mod = $rel }
  if($mod -like '*_H1_CANARY*' -or $mod -like '*_CANARY*'){ continue }
  if(-not $map.ContainsKey($mod)){ $map[$mod] = @() }
  $imps = Select-String -Path $f.FullName -Pattern '^import\s+(\S+)' -ErrorAction SilentlyContinue |
          ForEach-Object { $_.Matches[0].Groups[1].Value }
  $map[$mod] = @($map[$mod]) + @($imps)
}
"modules indexed : $($map.Count)"
if($map.Count -eq 0){ Write-Host "[!] INDEX EMPTY - harness cannot verify" -ForegroundColor Red; exit 2 }
if(-not $map.ContainsKey($Entry)){ Write-Host "[!] ENTRY MISSING: $Entry" -ForegroundColor Red; exit 2 }
$reach = New-Object System.Collections.Generic.HashSet[string]
$stack = New-Object System.Collections.Generic.Stack[string]
$stack.Push($Entry)
while($stack.Count -gt 0){
  $cur = $stack.Pop()
  if(-not $reach.Add($cur)){ continue }
  if($map.ContainsKey($cur)){ foreach($i in $map[$cur]){ $stack.Push($i) } }
}
$orph = $map.Keys | Where-Object { -not $reach.Contains($_) } | Sort-Object
"reachable from entry : $($reach.Count)"
"orphans              : $($orph.Count)"
if($orph.Count -gt 0){
  Write-Host "[!] ORPHAN MODULES (not on proof path):" -ForegroundColor Yellow
  $orph | ForEach-Object { "    $_" }
  exit 1
}
Write-Host "[i] IMPORT GRAPH CLOSED - every module reachable" -ForegroundColor Green
exit 0
