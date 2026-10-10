# Guinand–Weil Integration Bridge — Dual-Core Audit Architecture

## Repositories

| Core | Repository |
|---|---|
| A — formal (this vault) | https://github.com/aidilamrym-ops/the-asymmetric-wager-msaf |
| B — numeric | https://github.com/aidilamrym-ops/guinand-weil-rigorous-numerics |

## Scope

The two repositories form the dual-core architecture of the
independent audit framework:

- **Core A (formal):** machine-checked boundaries in Lean 4 over
  `OAI.NumberTheory.PiExponent`, certified in
  `OAI_FAMILY_017_CORE_CERTIFICATE.md`.
- **Core B (numeric):** Arb ball-arithmetic evaluation over
  outward-rounded intervals.

## Mathematical justification

The theoretical boundaries verified in Core A — the formal statement
`pi_irrationalityExponent_eq_two` and its dependency footprint
`[propext, Classical.choice, Quot.sound]` — are the input contract for
Core B. The Lean-verified bounds are encoded as exact rational
endpoints and fed into the Arb ball arithmetic engine of
`guinand-weil-rigorous-numerics`, which propagates them as
outward-rounded intervals while pressure-testing the analytic bounds
of the irrationality exponent of pi against the Sylvester-interval
LDL^T matrix test sequence (Stieltjes/Sturm chain evaluation of the
associated moment matrices under interval arithmetic).

No Core B number is accepted unless the enclosure contains the value
determined by Core A's theorem statement; no Core A statement is
reported as numerically stress-tested without a Core B interval
recomputation. Each core is run independently; agreement is checked,
not assumed.

## Files binding the cores

| Artifact | Role |
|---|---|
| `OAI_FAMILY_017_CORE_CERTIFICATE.md` | Core A verdict + locked hash |
| `proofs/OAI/**` (4,345 objects) | Core A elaboration receipt |
| `lean/OAI/NumberTheory/PiExponent/**` (869 files) | Core A sources under test |
| `guinand-weil-rigorous-numerics` (separate repo) | Core B Arb engine + LDL^T tests |
