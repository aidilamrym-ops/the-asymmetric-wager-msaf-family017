# Pull Request Checklist

**This vault is frozen at v1.0.0.** PRs must not modify the audit artifacts.

## Required Confirmations

- [ ] **No vault modifications**: No changes to `lean/`, `proofs/`, `config/`, `harness/`, `MANIFEST.sha256`, `OAI_FAMILY_017_CORE_CERTIFICATE.md`, `RELEASE_v1.0.0.md`
- [ ] **$P_{narrative} = 0$**: No fluff, speculation, or unverified claims added
- [ ] **English only**: All text in English (conversation may be Indonesian)
- [ ] **CI passes**: All workflows green on this branch

## Change Category

- [ ] README/docs clarification (counts, commands, formatting)
- [ ] CI/workflow improvement
- [ ] GitHub repo metadata (topics, description, branch protection via separate PR)
- [ ] New independent verification receipt (additive only)
- [ ] Cross-reference to related work

## Description

<!-- What and why. Link issue if applicable. -->

## Verification

<!-- How you verified the change doesn't break anything.
     For docs: ran Command B from README Section 8.
     For CI: pushed to fork and checked Actions tab. -->