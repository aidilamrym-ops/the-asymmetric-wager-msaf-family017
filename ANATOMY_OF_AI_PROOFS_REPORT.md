# Anatomy of AI Mathematical Proofs: Axiomatic Footprint of OpenAI's PiExponent Family

## Abstract

The `OAI.NumberTheory.PiExponent` subtree (OpenAI mathematics catalogue,
Family 017: the irrationality exponent of pi) was re-elaborated from
source under a pinned toolchain (`leanprover/lean4:v4.34.1`) on a single
local machine. Result: 869 of 869 source files compiled to `.olean`
artifacts with zero missing modules. The recovery run executed 393
consecutive module builds under a single-process sequential model with
zero failures, scheduled against the machine's observed commit limit of
28.9 GiB. Kernel probes over the three entry declarations report an
identical axiomatic footprint of `[propext, Classical.choice,
Quot.sound]`: the standard classical foundation, with no additional
postulate admitted.

## 1. Introduction

Automated theorem generation produces formal text at a scale that
exceeds manual review. A generated proof is a claim about a derivation;
without an independent elaboration, the claim rests on the authority of
the generator. Decentralized verification replaces that authority with
a reproducible mechanical act: a second party, on separate hardware,
replays the derivation with a pinned toolchain and pinned dependencies
and records the kernel's answer. This report documents one such replay
for Family 017. The object under test is the source tree, not the
model. The verdicts concern artifacts on disk: exit codes, artifact
counts, token scans, and kernel-reported axiom sets.

## 2. Topographical Methodology

The build environment imposed a hard commit ceiling (28.9 GiB
observed). Parallel elaboration with four concurrent processes
exhausted it and failed with memory-mapping errors of the form
`failed to read file '... .olean.private'`. Those failures were
indistinguishable by module: any subset of in-flight targets could
collapse, so fault attribution was impossible.

The response was a topological scheduler. From the measured import
graph, a module is eligible for elaboration only when every one of
its intra-subtree imports already exists as a compiled `.olean`
artifact. The initial computation over the 307-module remainder
resolved 27 dependency strata, narrowing to a single-module frontier
at the apex. Each eligible module was then built by exactly one
invocation, verified by exit code plus artifact existence and size,
with zero residual processes required before the next step.

Sequential tracking is superior for cascade isolation for one reason:
the unit of failure equals the unit of execution. A failure names its
module and prints the kernel's exact error. No parallel interleaving
exists to distribute blame. Across 393 consecutive executions, no
failure occurred; had one occurred, the frontier computation would
have re-resolved around it and the report would name it.

## 3. Findings

### 3.1 Type-A: zero-hazard canary status

An escape-token scan with a live positive control over all 869
sources returned zero in every hazard class:

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

The Anti-Circularity Gate `lean` scan independently reports
`FAIL=0 NOT_RUN=0`, verdict PASS.

### 3.2 Type-B: literal kernel responses

```lean
'OAI.PiExponent.main' depends on axioms: [propext, Classical.choice, Quot.sound]
'OAI.PiExponent.pi_irrationalityExponent_eq_two' depends on axioms: [propext, Classical.choice, Quot.sound]
'OAI.PiExponent.flint_hills_summable' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The three entry declarations elaborate under the kernel with exit
code 0 and depend on exactly the standard classical axioms.

### 3.3 Harness anomalies disclosed

Two defects in the audit tooling itself were measured and are
recorded so that no verdict above is overstated. First, the
reachability script indexed third-party dependency directories and
reported 149,711 pseudo-orphan modules; recomputation restricted to
the 869 subtree sources shows 869 of 869 reachable with zero
structural orphans. Second, the axiom-extraction script returned a
spurious exit code 2, caused by a relative project path combined
with a directory change and by a pattern that does not match the
kernel's `axioms: [...]` output format; the verbatim kernel
literals above, obtained with exit code 0, are the authority for
the Type-B verdict.

### 3.4 Limits

These findings describe artifacts on one disk under one pinned
toolchain and dependency set. They do not assert correctness of any
analytic argument beyond what is formalized in the checked sources,
and they do not transfer to other toolchains or dependency
revisions. The full numeric receipt is locked in
`OAI_FAMILY_017_CORE_CERTIFICATE.md`.
