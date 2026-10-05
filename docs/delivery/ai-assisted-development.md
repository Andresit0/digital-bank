# AI-assisted Development

## 1. Purpose

This document describes how AI was used as an engineering assistant in this
project: where it contributed, how its output was reviewed, its qualitative
impact, and its limits and risks. It describes what actually happened in the
repository rather than a hypothetical process.

It relates to REQ-019 (document AI usage), REQ-020 (explain AI impact on
productivity, quality, documentation, and testing), and REQ-024 (effective use
of AI and development tools).

## 2. Operating Model

AI was used as an assistant, not as an autonomous author. The engineer remained
the decision-maker and the only actor able to authorize a commit. Every change
followed the same path:

```text
Specification -> Tests -> Implementation -> Validation -> Human review -> Commit
```

AI produced drafts and proposals; the engineer reviewed, corrected, approved, or
rejected them. No commit was created without explicit human authorization.

## 3. SDD, TDD, and Validation Workflow

The project follows Specification-Driven Development (SDD) and Test-Driven
Development (TDD). Each feature has its specification under
`lib/features/<feature>/spec/` (`spec.md`, `domain.md`, `contracts.md`,
`tests.md`, `tasks.md`, `bdd.feature`). The observed progression per feature is:

```text
Requirement
    |
    v
Specification (SDD)
    |
    v
Acceptance scenarios and tests (TDD, RED)
    |
    v
Implementation (GREEN)
    |
    v
Validation (flutter analyze, flutter test, integration tests)
    |
    v
Human review and authorized commit
```

The commit history reflects this order: for example, onboarding starts with
`docs(onboarding): define onboarding policy`, then
`test(onboarding): define onboarding contracts`, and only then the implementation
commits.

## 4. Where AI Assisted

| Area | AI assistance | Human responsibility | Artifact |
|---|---|---|---|
| Requirements and scope | Structuring requirements, criteria, and scope into traceable items | Deciding scope, priorities, and what is out of scope | `docs/product/requirements-traceability.md`, `docs/product/scope-and-prioritization.md` |
| Architecture decisions | Drafting ADR problems, alternatives, and trade-offs | Selecting and approving the decision | `docs/architecture/adr/` |
| Feature specifications | Drafting spec, contracts, scenarios, and tasks | Freezing contracts and accepting the spec | `lib/features/<feature>/spec/` |
| Test design | Proposing unit, widget, routing, and E2E cases | Approving coverage and asserting real evidence | `test/`, `integration_test/` |
| Implementation | Generating code within the frozen contracts | Reviewing correctness, patterns, and security | `lib/` |
| Validation and CI | Wiring `flutter analyze`, tests, and workflows | Accepting the quality gate | `.github/workflows/flutter-ci.yml`, `.github/workflows/api-ci.yml` |
| Documentation | Drafting PR docs, README, and traceability updates | Verifying statements against real evidence | `docs/`, `README.md` |

## 5. Code Assistance

AI contributed to the implementation across the layered architecture
(domain, infrastructure, presentation, and DI) while respecting the established
boundaries: repositories return `Result<T>`, the error boundary uses
`guard(...)`, and observability is reported by notifiers rather than by
repositories. AI proposals that deviated from these conventions were corrected
during review.

## 6. Test Assistance

AI assisted in designing and writing tests at each level:

- unit tests for domain, data sources, repositories, and notifiers;
- widget tests for screen states and interactions;
- routing tests for guarded navigation;
- deterministic integration and end-to-end tests, including the onboarding
  persistence flow (`integration_test/onboarding/onboarding_flow_test.dart`).

Tests were reviewed for real assertions rather than for the appearance of
coverage; deterministic tests avoid depending on external services unless a test
explicitly targets the real backend.

## 7. Documentation and ADR Assistance

AI assisted in producing the architecture documentation, the ADRs, the per-PR
specifications, and the requirements traceability matrix. The engineer verified
every statement against the actual implementation, tests, and history, and
removed or corrected claims that were not backed by evidence. This document
itself follows the rule that no claim of automation, metrics, or behavior is
made unless it is real.

## 8. Human Review

Human review was systematic, not incidental. Each commit was preceded by a
review of the change, its diff, and its validation output, and required explicit
authorization. Two examples from the project:

- The onboarding feature was first drafted with a non-conforming contract
  (`Future<bool>` / `Future<void>` with repository-owned observability). Human
  review rejected it and the work was reworked to the project contract
  (`Future<Result<bool>>` / `Future<Result<void>>`, `guard(...)` in the
  repository, observability in the notifier) before being committed.
- Documentation claims were pruned where they would have stated behavior that
  did not exist yet (for example, deferred deployment or automation).

This review loop is the main quality control on AI output.

## 9. Impact (Qualitative)

No productivity, time-saving, or defect-reduction percentages are claimed.
The project was not instrumented to measure them, so quoting such figures would
not be evidence-backed. The observable impact is qualitative:

| Dimension | Observed impact |
|---|---|
| Productivity | Faster drafting of specifications, tests, code, and documentation, allowing more iterations within the assessment period |
| Quality | Convention deviations were caught by review; the `Result`/`guard` boundary and the routing gate were applied consistently |
| Documentation | Broader and more granular documentation (ADRs, per-PR specs, traceability) than would likely have been produced manually in the same time |
| Testing | Layer-specific tests were produced consistently; the deterministic suite and the onboarding E2E exist as evidence |
| Risk | AI could produce plausible but incorrect output, which required strict review (Section 8) |

## 10. Limits and Risks

- **Plausible but incorrect output.** AI can generate code or architecture that
  looks correct but violates the project contract; this occurred and was caught
  only by review.
- **Requirement invention.** AI can introduce assumptions not present in the
  source; requirements were taken from the assessment and tracked explicitly to
  avoid this.
- **Over-engineering.** AI may propose abstractions the MVP does not need; the
  project rule is to add an abstraction only when required.
- **Stale or inaccurate documentation.** Claims must be verified against the
  repository; speculative documentation is removed.
- **Security and privacy.** Secrets and sensitive data must never be introduced
  or logged; the project keeps credentials out of the repository and enforces a
  sensitive-data policy in observability.
- **Automation overstatement.** The existence of a capability (for example,
  GitHub Actions artifacts) does not mean the project uses it; documentation
  distinguishes implemented capabilities from documented strategy.

## 11. Traceability

```text
REQ-019  Document AI usage during development
         -> This document.
REQ-020  Explain AI impact on productivity, quality, documentation, and testing
         -> Sections 8 and 9 (qualitative, evidence-based).
REQ-024  Effective use of AI and development tools
         -> SDD/TDD workflow (Section 3), review loop (Section 8), and CI
            quality gate (`.github/workflows/`).
```

## 12. Boundaries

This document does not claim autonomous commits, deployed automation, metric
instrumentation, or tool benchmarking. Screenshot automation and CI artifacts are
a strategy for later work, not a current capability.
