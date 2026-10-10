# H3-COMPILE: kernel type-check of a single module + axiom footprint of the target decl.
# Requires the toolchain declared in lean-toolchain to be installed AND .lake/packages present.
# Exit 0=PASS 1=TYPECHECK FAIL 2=ENV BLOCKED (toolchain/deps missing) 3=AXIOM SET CONTAMINATED.
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ProjectRoot,
  [string]$Module = 'OAI.NumberTheory.PiExponent.Main',
  [string]$Decl   = 'OAI.PiExponent.main',
  [string[]]$AllowedAxioms = @('propext','Quot.sound','Classical.choice')
)
$ErrorActionPreference = 'Continue'

# ---- FIRST-LINE ENFORCEMENT: verify toolchain alignment BEFORE any claim ----
$declared = (Get-Content (Join-Path $ProjectRoot 'lean-toolchain') -Raw).Trim()
$id = $declared -replace '^leanprover/lean4:',''
$tcDir = Join-Path $env:USERPROFILE ('.elan\toolchains\leanprover--lean4---' + $id)
if(-not (Test-Path $tcDir)){
  Write-Host "[!] ENV BLOCKED : declared=$declared but $tcDir absent" -ForegroundColor Red
  Write-Host "[!] installed   : $((Get-ChildItem (Join-Path $env:USERPROFILE '.elan\toolchains') -ErrorAction SilentlyContinue).Name -join ', ')"
  exit 2
}
if(-not (Test-Path (Join-Path $ProjectRoot '.lake\packages'))){
  Write-Host "[!] ENV BLOCKED : .lake/packages absent - deps not fetched (lake update required)" -ForegroundColor Red
  exit 2
}
Write-Host "[i] toolchain aligned: $declared"

# ---- Stage 1: type-check the target module ----
$probe = Join-Path $ProjectRoot '_H3_AXIOM.olean'
$src   = Join-Path $ProjectRoot '_H3_AXIOM.lean'
[System.IO.File]::WriteAllText($src,
  "import $Module`n#print axioms $Decl`n",
  (New-Object System.Text.UTF8Encoding($false)))
Push-Location $ProjectRoot
$out = & lake env lean $src 2>&1 | Out-String
$ec  = $LASTEXITCODE
Pop-Location
Remove-Item $src -Force -ErrorAction SilentlyContinue
if($ec -ne 0){
  Write-Host "[!] TYPECHECK FAIL (exit=$ec)" -ForegroundColor Red
  Write-Host $out
  exit 1
}
Write-Host "[i] type-check PASS" -ForegroundColor Green

# ---- Stage 2: axiom footprint ----
$m = [regex]::Match($out, 'axioms\s+([\w\.\'']+)')
if(-not $m.Success){
  Write-Host "[!] NO AXIOM FOOTPRINT in kernel output - harness cannot verify" -ForegroundColor Red
  Write-Host $out
  exit 2
}
$found = $m.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() }
"    declared axioms : $($found -join ', ')"
$extra = $found | Where-Object { $AllowedAxioms -notcontains $_ }
if($extra.Count -gt 0){
  Write-Host "[!] AXIOM CONTAMINATION: $($extra -join ', ')" -ForegroundColor Red
  exit 3
}
Write-Host "[i] axiom footprint CLEAN" -ForegroundColor Green
exit 0
