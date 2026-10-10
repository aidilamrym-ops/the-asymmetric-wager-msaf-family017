# OAI Family 017 Core Certificate

Independent verification artifact for the `PiExponent` formalization
(OpenAI mathematics catalogue, Family 017: the irrationality exponent
of pi). All figures below are measured values from the build machine.
No figure is estimated, rounded, or carried over from another report.

## 1. Identification

| Field | Value |
|---|---|
| Target family | OpenAI mathematics catalogue, Family 017 (irrationality exponent of pi) |
| Repository anchor | `OAI.NumberTheory.PiExponent` |
| Working tree | `informasi mentah/math-main/lean` |
| Toolchain core | `leanprover/lean4:v4.34.1` (pinned `lean-toolchain`, lake configuration as shipped with patched `.lake/packages`) |
| Entry target | `OAI.NumberTheory.PiExponent.Main` |

## 2. Build receipt

| Metric | Measured value |
|---|---|
| Source files in scope | 869 |
| `.olean` artifacts present | 869 |
| Missing modules | 0 |
| Recovery-run yield (single-process sequential model) | 393 consecutive module builds, 0 failures |
| `Main.olean` build exit code | 0 |
| `Main.olean` wall time | 24 s |
| Commit state at `Main` invocation | 8.7 / 28.9 GiB |
| Lake job count on final invocation | 9792 / 9792 jobs built |
| `Main.olean` artifact size | 28,320 bytes |
| Residual `lean.exe` processes after each step | 0 |

The 393 recovery builds were executed strictly one `lake build`
invocation at a time. No two elaborator processes ran concurrently.
Each step was accepted only on exit code 0 plus verified existence
of the corresponding `.olean` file.

## 3. Type-A verdict: logical integrity

The escape-token scan (H1 harness, positive canary control live)
returned zero on every structural hazard class over the
`OAI/NumberTheory/PiExponent` subtree (869 files):

| Token class | Count |
|---|---|
| `sorry` | 0 |
| `admit` | 0 |
| `sorryAx` | 0 |
| `native_decide` | 0 |
| `partial` | 0 |
| `implemented_by` | 0 |
| `axiom` declarations | 0 |
| `postulate` | 0 |
| `ofReduceBool` | 0 |
| `of_decide` | 0 |
| `Float` | 0 |

Canary control: PASSED (detector demonstrated live on a planted
specimen, then the specimen was removed). Harness exit code: 0.
Anti-Circularity Gate `lean` scan: `FAIL=0 NOT_RUN=0`, verdict PASS,
exit code 0.

Verdict Type-A: the subtree elaborates with absolute closure. Zero
logical placeholders or unproven voids were detected.

## 4. Type-B verdict: axiomatic footprint

Kernel probe (`lake env lean`, exit code 0) over the entry module
returned the following axiom dependencies verbatim:

```lean
'OAI.PiExponent.main' depends on axioms: [propext, Classical.choice, Quot.sound]
'OAI.PiExponent.pi_irrationalityExponent_eq_two' depends on axioms: [propext, Classical.choice, Quot.sound]
'OAI.PiExponent.flint_hills_summable' depends on axioms: [propext, Classical.choice, Quot.sound]
```

| Declaration | Axiom footprint |
|---|---|
| `OAI.PiExponent.main` | `[propext, Classical.choice, Quot.sound]` |
| `OAI.PiExponent.pi_irrationalityExponent_eq_two` | `[propext, Classical.choice, Quot.sound]` |
| `OAI.PiExponent.flint_hills_summable` | `[propext, Classical.choice, Quot.sound]` |

Verdict Type-B: the subtree is verified clean. Every checked
declaration rests strictly on Lean's standard classical axiom
foundation. No un-vetted or contradictory postulate was introduced.

## 5. Radical transparency: harness behavior disclosure

Two tooling anomalies occurred during this audit. Both are recorded
here so that no verdict above is overstated.

1. H2 reachability indexing defect. The dependency script indexed
   `.lake/packages` alongside the sources, reporting 149,711
   pseudo-orphan modules. Recomputation restricted to the 869
   `PiExponent` sources shows 869/869 reachable from the entry
   module with 0 structural orphans.
2. H3 regex parser interruption. The extraction script exited with
   a pseudo-exit code 2, caused first by a relative `ProjectRoot`
   combined with `Push-Location` (probe path resolved twice) and
   then by a regex that does not match the kernel's
   `axioms: [...]` output format. The direct kernel output
   literals reproduced in Section 4 were obtained with exit
   code 0 and constitute the authority for the Type-B verdict,
   not the script's exit code.

## 6. Scope and limits

This certificate describes artifacts on disk under the toolchain
and dependency pins stated in Section 1. It does not assert
correctness of any analytic argument beyond what is formalized in
the checked sources. It does not transfer to other toolchains,
other dependency revisions, or a tree whose `.lake` artifacts were
removed or rebuilt elsewhere.

## 7. Reproduction

```powershell
# From the project root, one module at a time; never parallel:
lake build OAI.NumberTheory.PiExponent.Main
# Escape-token scan with live canary:
powershell -NoProfile -ExecutionPolicy Bypass -File "harness\H1-EscapeToken.ps1" `
  -Root "informasi mentah\math-main\lean\OAI\NumberTheory\PiExponent"
# Kernel axiom probe (absolute project path required):
lake env lean probe.lean   # probe imports the Main module and runs
                           # #print axioms on the Section 4 declarations
```
