# H1-ESCAPETOKEN + CANARY: fail-safe escape scan with mandatory positive control.
# Exit 0 = PASS, 1 = TOKEN FOUND, 2 = HARNESS DEAD (canary not detected).
# Any harness that reports "0 tokens" WITHOUT proving it can detect them is trash.
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Root,
  [switch]$NoCanary
)
$ErrorActionPreference = 'Stop'
$patterns = [ordered]@{
  'sorry'         = '\bsorry\b'
  'admit'         = '\badmit\b'
  'axiom_decl'    = '^\s*axiom\s+'
  'postulate'     = '^\s*postulate\b'
  'native_decide' = '\bnative_decide\b'
  'unsafe'        = '\bunsafe\b'
  'partial'       = '^\s*partial\b'
  'implemented_by'= 'implemented_by'
  'sorryAx'       = 'sorryAx'
  'ofReduceBool'  = 'ofReduceBool'
  'of_decide'     = 'of_decide'
  'Float'         = '\bFloat(64)?\b'
}
function Scan([string]$Dir){
  $out = @{}
  foreach($k in $patterns.Keys){
    $h = Get-ChildItem $Dir -Recurse -Filter *.lean -File -ErrorAction SilentlyContinue |
         Select-String -Pattern $patterns[$k] -ErrorAction SilentlyContinue
    $out[$k] = ($h | Measure-Object).Count
  }
  return $out
}
# --- CANARY POSITIVE CONTROL: harness MUST detect these, else harness is dead ---
if(-not $NoCanary){
  $canary = Join-Path $Root '_H1_CANARY.lean'
  try{
    [System.IO.File]::WriteAllText($canary,
      "axiom H1_CANARY_AXIOM : False`ntheorem h1_canary : False := by sorry`nexample : Nat := by native_decide`n",
      (New-Object System.Text.UTF8Encoding($false)))
    $c = Scan $Root
  } finally {
    Remove-Item $canary -Force -ErrorAction SilentlyContinue
  }
  $dead = @()
  foreach($k in @('sorry','axiom_decl','native_decide')){
    if($c[$k] -lt 1){ $dead += $k }
  }
  if($dead.Count -gt 0){
    Write-Host "[!] HARNESS DEAD - canary not detected: $($dead -join ', ')" -ForegroundColor Red
    exit 2
  }
  Write-Host "[i] canary control PASSED (detector alive)"
}
# --- REAL SCAN ---
$r = Scan $Root
$bad = @()
foreach($k in $patterns.Keys){ if($r[$k] -gt 0){ $bad += "$k=$($r[$k])" } }
foreach($k in $patterns.Keys){ "  {0,-16} {1}" -f $k, $r[$k] }
if($bad.Count -gt 0){ Write-Host "[!] TOKEN FOUND: $($bad -join '; ')" -ForegroundColor Red; exit 1 }
Write-Host "[i] ESCAPE SCAN CLEAN" -ForegroundColor Green
exit 0
