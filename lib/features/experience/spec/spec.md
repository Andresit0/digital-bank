# Feature: Dynamic Experience

## Purpose

Allow the Home experience to be defined remotely and composed at runtime from a
controlled set of supported sections, without requiring a new application
release to change compatible content or composition.

## Scope

- Obtain a remote experience definition for Home.
- Validate the definition against a controlled schema.
- Render only a supported set of section types.
- Ignore unsupported section types.
- Represent loading, loaded, empty, and failure states.
- Fall back to a static Home experience when no dynamic content is available.
- Express quick-action intents without coupling Experience to navigation.

## Out of Scope

- User-specific personalization, segmentation, eligibility rules, or recommendation engines.
- Feature flags, A/B testing, and experiment analytics.
- A CMS, visual editor, or drag-and-drop authoring.
- Creating experiences from within the application.
- A production backend or a new external service integration.
- ADR-006 (External Service Integration); reserved for a later pull request.

## Actors

- Authenticated customer.

## Functional Requirements

- EXP-001 The application obtains a remote experience definition for Home.
- EXP-002 The experience definition is validated against a controlled schema.
- EXP-003 Only supported section types are rendered: promotion and quick_action.
- EXP-004 An unsupported section type is ignored.
- EXP-005 An empty sections list is a valid state and produces the static fallback.
- EXP-006 An invalid schema, a server error, or a transport failure produces a failure state and the static fallback.
- EXP-007 A quick_action maps to a controlled intent, not to direct navigation.
- EXP-008 Compatible remote content and composition changes are reflected without changing application code or publishing a new application version.

## Experience State

```text
initial
   |
   v
loading
   |
   +--> loaded(ExperienceDefinition)
   |
   +--> empty
   |
   +--> failure(ExperienceError)
```

`empty` is a valid state, not an error. It means the server returned a valid
definition with no dynamic sections.

## Fallback

Fallback is a Presentation decision, not a domain state. Home renders a static
experience when the state is `empty` or `failure`.

## Business Rules

- The schema is controlled and validated before rendering.
- Unsupported section types never crash the renderer; they are ignored.
- If every section is unsupported, the result is `empty`.
- The experience definition does not carry navigation; it carries intents.

## Contract Assumption

The assessment does not define an experience API contract. This feature
establishes an implementation-level contract as an explicit assumption,
isolated behind the repository and data-source boundary so it can be replaced
when an actual backend contract is provided.

The assumed endpoint `GET /experience/home` is an implementation assumption,
not an assessment requirement.

## Dependencies

- `HttpClient` and `network_providers` from the network foundation.
- `shared/error` (`Result`, `AppError`, `guard`).
- `shared/observability` for production event reporting.
- The authenticated session from the auth feature.
- Riverpod for state management and dependency composition.
- go_router for routing (owned by Home, not by Experience).
- No new dependencies.

## Traceability

- REQ-003 Dynamic personalization of experience, content, or functionality
  (primary).
- REQ-009 Loading and error states.
- EC-003 User experience.
- BON-002 Dynamically generated experiences (secondary effect, not the basis
  of the scope).

## Acceptance Criteria

- EXP-001 Home receives its experience definition from a remote source.
- EXP-002 Invalid definitions are rejected by schema validation.
- EXP-003 Supported sections render; unsupported ones are ignored.
- EXP-004 An unsupported section does not break rendering.
- EXP-005 An empty definition shows the static fallback, not an error.
- EXP-006 Invalid schema, server error, and transport failure show the static fallback.
- EXP-007 Quick actions are mapped to controlled intents handled by Home.
- EXP-008 The same application build renders a changed compatible experience definition supplied by the server.
