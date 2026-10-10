# Sequential convergence driver for the Family 017 Lean build.
# Root cause (previous session, proven): 4 concurrent lean.exe processes commit
# ~7.6 GiB each and hit the 36 GiB commit ceiling -> mmap fails -> Lean reports
# "failed to read file". This driver rebuilds the failed targets ONE PER LAKE
# INVOCATION so at most one elaborator runs at a time, then re-runs the full
# target. Exit 0 only when `lake build OAI.NumberTheory.PiExponent.Main` exits 0.
param(
  [string]$ProjectRoot = "D:\THE ASYMMETRIC WAGER\informasi mentah\math-main\lean",
  [string]$LogPath = "D:\THE ASYMMETRIC WAGER\harness\build_attempt6.log",
  [int]$MaxRounds = 8
)
$ErrorActionPreference = 'Continue'
$Target = 'OAI.NumberTheory.PiExponent.Main'
$out = New-Object System.Collections.Generic.List[string]
$out.Add("SEQUENTIAL DRIVER start $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$out.Add("project=$ProjectRoot target=$Target")
Set-Location -LiteralPath $ProjectRoot

function Get-CommitState {
  $m = Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory
  return ("commit {0:N1}/{1:N1} GiB" -f ($m.CommittedBytes / 1GB), ($m.CommitLimit / 1GB))
}

function Invoke-Lake([string[]]$CmdArgs) {
  $o = & lake @CmdArgs 2>&1 | Out-String
  return @{ ec = $LASTEXITCODE; out = $o }
}

for ($round = 1; $round -le $MaxRounds; $round++) {
  $out.Add("")
  $out.Add("=== ROUND $round === $(Get-Date -Format 'HH:mm:ss') $(Get-CommitState)")
  $r = Invoke-Lake @('build', $Target)
  $out.Add("round=$round full-build exit=$($r.ec)")
  Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
  if ($r.ec -eq 0) {
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot '.lake\build\lib\lean\OAI\NumberTheory\PiExponent\Main.olean'))) {
      $out.Add("GUARD: exit=0 but Main.olean missing - treating as failure")
      Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
      continue
    }
    $out.Add("FINALEXIT=0")
    $out.Add("SEQUENTIAL DRIVER done $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
    exit 0
  }
  $failed = @()
  foreach ($line in ($r.out -split "`r?`n")) {
    if ($line -match '^\s*-\s+(OAI\.[A-Za-z0-9_.]+)\s*$') { $failed += $Matches[1] }
  }
  $failed = $failed | Sort-Object -Unique
  $out.Add("failed targets round=$round count=$($failed.Count)")
  if ($failed.Count -eq 0) {
    $out.Add("NO_TARGET_LISTED - full error block follows")
    $out.Add(($r.out -split "`r?`n" | Where-Object { $_ -match 'error:' } | Select-Object -First 20) -join "`r`n")
    break
  }
  $ok = 0; $bad = 0
  foreach ($m in $failed) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $one = Invoke-Lake @('build', $m)
    $secs = [math]::Round($sw.Elapsed.TotalSeconds, 1)
    if ($one.ec -eq 0) { $ok++ } else {
      $bad++
      $errs = ($one.out -split "`r?`n" | Where-Object { $_ -match 'error:' } | Select-Object -First 3)
      $out.Add("  RETRY-FAIL $m exit=$($one.ec) ${secs}s")
      foreach ($e in $errs) { $out.Add("    " + $e.Trim()) }
    }
    $out.Add("  seq build exit=$($one.ec) ${secs}s  $m")
    Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
  }
  $out.Add("round=$round sequential ok=$ok bad=$bad $(Get-CommitState)")
  Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
}

$out.Add("FINALEXIT=1")
$out.Add("SEQUENTIAL DRIVER exhausted rounds $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
Set-Content -LiteralPath $LogPath -Value ($out -join "`r`n") -Encoding UTF8
exit 1
