# Release v1.0.0 — Formal Audit Release, OpenAI Mathematics Catalogue Family 017

**Tag:** v1.0.0
**Date:** 2026-10-10
**Target anchor:** OpenAI Mathematics Catalogue — Family 017 (`OAI.NumberTheory.PiExponent`)
**Repository:** https://github.com/aidilamrym-ops/the-asymmetric-wager-msaf-family017

## Cryptographic verification payload

| Artifact | SHA-256 |
|---|---|
| `OAI_FAMILY_017_CORE_CERTIFICATE.md` | `07121A536CC5956D7F83673D288A28609711E489B7FB6FCF5EC3237F751AA2E4` |
| `MANIFEST.sha256` (855,315 bytes, 5,252 entries) | `C9FC5684B3E01539F39B86BB316A255ECC804CFB58B807727DD3A1227A56AD38` |

Coverage: 5,252 manifest entries + the manifest file itself + this release note (excluded by construction: it quotes the manifest hash, which forbids mutual inclusion). Total repository objects: 5,254.

Verification:

```powershell
(Get-FileHash -LiteralPath "OAI_FAMILY_017_CORE_CERTIFICATE.md" -Algorithm SHA256).Hash
(Get-FileHash -LiteralPath "MANIFEST.sha256" -Algorithm SHA256).Hash
```

## Content

- 869/869 PiExponent sources, 4,345 compiled proof artifacts, 5,251 staged objects.
- Axiomatic footprint: `[propext, Classical.choice, Quot.sound]` for all three probed entry declarations.
- Escape-token scan: 0 hits across all hazard classes, canary control live.

## Tactical highlight

The 27-layer dynamic dependency tree of the subtree was mapped exclusively through single-process sequential constraint mitigation: one module per process invocation, frontier recomputed from measured `.olean` presence after each step, executed under restricted physical thermal hosting (detached casing). No parallel elaboration contributed to the mapping.

## Known anomalies (disclosed)

- H2 reachability script: third-party indexing produced 149,711 pseudo-orphans; corrected recomputation = 869/869 reachable, 0 orphans.
- H3 axiom script: spurious exit 2 (relative path + pattern mismatch); kernel literals with exit 0 are the Type-B authority.
