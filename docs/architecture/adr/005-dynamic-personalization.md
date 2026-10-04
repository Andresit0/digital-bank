# ADR-005: Dynamic Personalization

## Status

Accepted

## Context

The MVP must support dynamic personalization of the customer experience,
content, or functionality (REQ-003). The Home experience should be able to
change — content and composition of supported UI sections — without requiring a
new application release.

The evaluation criterion EC-003 values a coherent and personalized user
experience, and CON-002 values dynamic processing over static/simulated output.

A full personalization platform (segmentation, eligibility rules, a decision
engine, ML/recommendations, feature flags, A/B testing, a CMS) is far beyond the
scope of the assessment and would be premature. The feature needs a minimal,
controlled mechanism that demonstrates dynamic composition, not a decision
engine.

The application already follows feature-first Clean Architecture (ADR-001),
Riverpod for state and dependency composition (ADR-002), and the networking,
error-handling, and resilience boundaries (ADR-003). Experience must reuse those
foundations rather than introduce a parallel stack.

## Decision

A remotely defined, schema-controlled experience can be composed at runtime from
an explicit set of supported section types, without a new application release
for compatible content or composition changes.

```text
configured backend
      |  GET /experience/home
      v
ExperienceRemoteDataSource -> guard() -> Result<ExperienceDefinitionModel, AppError>
      |  (schema validation)
      v
ExperienceRepositoryImpl   -> Result<ExperienceDefinition, AppError> (domain)
      v
ExperienceNotifier         -> ExperienceState (initial/loading/loaded/empty/failure)
      v
ExperienceRenderer         -> PromotionSection | QuickActionSection
      v
HomeScreen
```

- The experience is obtained through the application-owned `HttpClient` and
  isolated behind the repository/data-source boundary.
- The contract uses a controlled schema. Supported section types are
  `promotion` and `quick_action`; an unsupported section type is ignored.
- `quick_action` maps to a controlled intent (`QuickActionType.viewMovements`,
  `QuickActionType.viewAccounts`), not to direct navigation. The renderer
  expresses the intent through `onAction`; Home resolves navigation.
- The experience endpoint is an implementation assumption, isolated in the data
  source, replaceable when a real backend contract is provided.
- No navigation framework or other feature is referenced by Experience.

## Alternatives Considered

### Full personalization engine

Segmentation, eligibility rules, decision engine, ML recommendations.

Rejected: disproportionate to the assessment and not required by REQ-003.

### Static, hard-coded Home content

Rejected: does not demonstrate dynamic composition and conflicts with the
dynamic-processing intent valued by CON-002.

### Client-side authored experiences (CMS/visual editor)

Rejected: out of scope; authoring is a backend concern.

### Remote, schema-controlled definition composed at runtime

Chosen: minimal, testable, provider-agnostic, and it demonstrates REQ-003 with
real HTTP interaction against a controlled server.

## Trade-offs

### Benefits

- Content and composition change without an application release.
- The schema is controlled; unsupported sections degrade gracefully.
- Experience stays independent of navigation and other features.
- Reuses existing networking, error, state, and observability foundations.
- Testable at unit, widget, integration, and E2E levels.

### Costs

- Introduces an assumed remote contract that must be replaced by a real one.
- Requires a renderer that maps a bounded set of section types.
- Only a limited set of section types is supported for the MVP.

## Scope Boundary

This ADR does not define:

- user-specific personalization, segmentation, eligibility, or recommendations;
- a decision engine;
- feature flags, A/B testing, or experiment analytics;
- a CMS or visual editor;
- a production backend or a new external service integration (ADR-006).

BON-002 (dynamically generated experiences) is a secondary effect of this
capability, not the basis of its scope.

## Long-term Impact

Additional experience sections and content can be added behind the same
controlled schema without restructuring Home. A decision engine or user-specific
personalization can be introduced later without changing the composition and
rendering boundary established here.
