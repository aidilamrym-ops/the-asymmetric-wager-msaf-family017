# the-asymmetric-wager-msaf — Independent AI Audit Registry

## Core concept

The Asymmetric Wager is a verification methodology: mass-produced
frontier AI mathematical models are pressure-tested with constrained,
predictable local compute. One machine, one process at a time, pinned
toolchain, pinned dependencies. Every claim is reduced to a mechanical
receipt — exit code, artifact count, token scan, kernel-reported axiom
set — recorded before any conclusion is stated. The wager is that
rigor scales down: a small deterministic rig detects defects that
scale alone cannot certify.

## Verification anchor

Family 017 (`OAI.NumberTheory.PiExponent`) build and audit receipt:

`OAI_FAMILY_017_CORE_CERTIFICATE.md`

Locked cryptographic hash (SHA-256) of the certificate file:

```text
07121A536CC5956D7F83673D288A28609711E489B7FB6FCF5EC3237F751AA2E4
```

Verify with:

```powershell
(Get-FileHash -LiteralPath "OAI_FAMILY_017_CORE_CERTIFICATE.md" -Algorithm SHA256).Hash
```

## Mirror layout

| Path | Content |
|---|---|
| `lean/OAI/NumberTheory/PiExponent/` | 869 verified `.lean` sources |
| `proofs/OAI/` | 4,345 compiled artifacts (`.olean` incl. `Main.olean`, plus co-emitted files) |
| `config/` | `lean-toolchain`, `lakefile.lean`, `lake-manifest.json`, `patches/` |
| `harness/` | `H1-EscapeToken.ps1`, `H2-Reachability.ps1`, `H3-CompileAxiom.ps1`, `H4-PatchIntegrity.ps1`, `build_sequential.ps1` |
| `MANIFEST.sha256` | SHA-256 record of every staged file |
| `ANATOMY_OF_AI_PROOFS_REPORT.md` | Scholarly findings report |
| `.gitignore` | Proof-vault ignore rules |

This mirror is a proof vault, not a build tree: third-party
dependency sources (`.lake/packages`) were excluded, so rebuilding
here requires `lake update` first.

## Replication steps

Prerequisites: the full working tree with `.lake/packages` present
and the `leanprover/lean4:v4.34.1` toolchain installed.

1. Escape-token scan with live canary control:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "harness\H1-EscapeToken.ps1" `
  -Root "<project>\OAI\NumberTheory\PiExponent"
```

Expected: canary PASSED, all token classes 0, exit code 0.

2. Manual kernel axiom probe. Write `probe.lean` in the project
   root with exactly this content:

```lean
import OAI.NumberTheory.PiExponent.Main
#print axioms OAI.PiExponent.main
#print axioms OAI.PiExponent.pi_irrationalityExponent_eq_two
#print axioms OAI.PiExponent.flint_hills_summable
```

Then run (absolute project path; the probe must be removed
afterwards so the source tree stays clean):

```powershell
lake env lean probe.lean
```

Expected: exit code 0 and, for each declaration, a dependency
line listing exactly `[propext, Classical.choice, Quot.sound]`.

## Scope

Replication verdicts concern artifacts on disk under the pinned
toolchain and dependency set in `config/`. See the certificate and
the findings report for measured figures and stated limits.
