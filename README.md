# Flutter Digital Bank

Flutter implementation for the Senior Front-End Technical Assessment.

## Project Status

Current phase: Core product features

Authentication, Accounts (accounts, available balances), Movements
(transaction history and detail), and Dynamic Experience (remotely configured,
schema-controlled experience composed on Home) are implemented and integrated
into the application. Shared error handling, development logging, and production
observability are implemented as cross-cutting foundations. The Flutter
application consumes the NestJS backend through a shared API client with
centralized in-memory session management and Bearer authentication. Additional
core product features are being developed incrementally using
Specification-Driven Development (SDD) and Test-Driven Development (TDD).

Implemented customer journey:

```text
Login -> Home -> Dynamic Experience -> Accounts -> Movements
```

The customer journey runs against the NestJS backend. Login obtains a JWT that
is stored in an in-memory session; a shared Dio interceptor attaches
`Authorization: Bearer <token>` to protected requests. A `401` clears the
session and returns the user to login.

## Requirements

- Flutter 3.47.4
- Dart 3.13.3

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the application:
```bash
flutter run
```

The API base URL is provided at build time and defaults to no value:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

`API_BASE_URL` points to the NestJS backend. The backend is not required to run
the unit and widget test suite.

## Engineering Approach

The project is developed incrementally using a requirement-driven and decision-oriented approach.

The implementation follows this progression:

1. Technical requirements
2. MVP scope and prioritization
3. Application architecture
4. Application foundation
5. Core product features
6. Resilience and degraded-state handling
7. Personalization and dynamic experiences
8. External service integration
9. Testing and quality validation
10. Observability and operations
11. Final validation and documentation

Development follows Specification-Driven Development (SDD) and Test-Driven Development (TDD), with AI used as an engineering assistant throughout the development lifecycle.

Each feature starts with an explicit specification covering requirements, contracts, scenarios, and tasks. Implementation then follows TDD through domain, infrastructure, presentation, integration, and end-to-end validation.

Each significant change is specified, implemented, tested, and validated before being integrated into the trunk.

Architectural decisions and significant technical trade-offs are documented as Architecture Decision Records (ADRs).

## Documentation

### Product

- [Requirements Traceability](docs/product/requirements-traceability.md)  
  Maps the technical assessment requirements to product scope, architecture decisions, implementation, tests, documentation, and verification evidence.

- [MVP Scope and Prioritization](docs/product/scope-and-prioritization.md)  
  Defines the MVP journey, implementation priorities, scope boundaries, deferred capabilities, and requirement-to-scope mapping.

### Features

Feature specifications are maintained alongside each feature under
`lib/features/<feature>/spec/`.

- `lib/features/auth/spec/`
- `lib/features/accounts/spec/`
- `lib/features/movements/spec/`
- `lib/features/experience/spec/`

Documentation will be added progressively as the corresponding engineering decisions and implementation work are completed.

### Architecture

- [Architecture](docs/architecture/README.md)
  Defines the application structure, dependency boundaries, SDD/TDD workflow,
  and initial architectural decisions.

- [ADR-005 — Dynamic Personalization](docs/architecture/adr/005-dynamic-personalization.md)
  Defines the remotely configured, schema-controlled experience composed at
  runtime on Home (supported sections, controlled intents, and scope boundaries).

- [PR12 — Error Handling and Development Logging](docs/architecture/pr12-error-handling-and-development-logging.md)
  Defines the shared error model, `Result<T>`, the error mapping boundary, the
  development logging seam, sensitive-data logging constraints, and the
  Auth/Accounts migration.

- [PR14 — Production Observability](docs/architecture/pr14-production-observability.md)
  Defines the provider-agnostic observability seam (`IObservability`), the event
  taxonomy, the sensitive-data policy, and the Auth/Accounts reporting migration.

- [PR18 — Flutter to NestJS API Integration](docs/architecture/pr18-api-integration.md)
  Defines the in-memory session, the centralized Bearer authentication, the 401
  handling, and the validated integration against the NestJS backend.

Additional documentation will be added progressively as the corresponding engineering decisions and implementation work.

### Operations

- [Operations](docs/operations/README.md)
  Defines the CI quality gate and the operational observability and monitoring
  strategy.

### Testing

Run the unit, widget, and integration-style tests:

```bash
flutter test
```

Run the end-to-end tests on a device or simulator:

```bash
flutter test integration_test/auth/authentication_flow_test.dart
flutter test integration_test/accounts/accounts_navigation_test.dart
flutter test integration_test/accounts/accounts_display_test.dart
flutter test integration_test/movements/movements_flow_test.dart
flutter test integration_test/experience/experience_flow_test.dart
```

If multiple devices or simulators are available, specify the target with `-d <device-id>`.

The deterministic end-to-end tests run against a controlled local HTTP server and
cover the full journey (Login -> Accounts -> Movements -> Experience). They do not
require the NestJS backend.

An optional end-to-end test runs against the real NestJS backend and is skipped
unless a backend is reachable:

```bash
flutter test integration_test/api/real_backend_flow_test.dart \
  --dart-define=API_BASE_URL=http://localhost:3000
```

The test probes `API_BASE_URL` (default `http://localhost:3000`). When the backend
is not reachable the test skips; when it is reachable it runs the real
Login -> Home -> Accounts flow.

To require the real backend and fail instead of skipping, force it with a Dart
compile-time define (not a process environment variable):

```bash
flutter test integration_test/api/real_backend_flow_test.dart \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=RUN_REAL_API_E2E=true
```

### AI

Documentation of AI-assisted development, usage, impact, and validation will be added as the project progresses.