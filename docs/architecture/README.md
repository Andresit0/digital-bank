# Architecture

This document defines the initial architecture required to implement the MVP of the Flutter Digital Bank technical assessment.

The architecture follows the project's existing feature-first Clean Architecture approach and supports Specification-Driven Development (SDD) and Test-Driven Development (TDD).

The architecture is intentionally limited to the boundaries required by the MVP. Additional abstractions will be introduced only when required by the product or assessment scope.

## 1. Application Structure

```text
lib/
├── app/
│   ├── di/
│   └── router/
│
├── core/
│   ├── config/
│   ├── network/
│   └── utils/
│
├── shared/
│   ├── error/
│   ├── exceptions/
│   └── interfaces/
│
└── features/
    ├── auth/
    │   ├── di/
    │   ├── domain/
    │   ├── infrastructure/
    │   ├── presentation/
    │   └── spec/
    │
    ├── home/
    │   ├── di/
    │   ├── domain/
    │   ├── infrastructure/
    │   ├── presentation/
    │   └── spec/
    │
    ├── accounts/
    │   ├── di/
    │   ├── domain/
    │   ├── infrastructure/
    │   ├── presentation/
    │   └── spec/
    │
    └── transactions/
        ├── di/
        ├── domain/
        ├── infrastructure/
        ├── presentation/
        └── spec/
```

## 2. Responsibilities

### `app/`

Application-level composition and routing.

### `core/`

Infrastructure shared across features, such as networking and configuration.

### `shared/`

Small abstractions genuinely shared by multiple features, such as common errors or interfaces.

`shared/` must not become a general-purpose storage area for feature-specific code.

### `features/`

Product capabilities are isolated by feature.

Each feature contains:

- `domain/` — business rules and contracts.
- `infrastructure/` — data sources, DTOs, mappers, repository implementations, and external service adapters.
- `presentation/` — screens, widgets, and presentation state.
- `di/` — feature dependency composition.
- `spec/` — feature specifications and acceptance scenarios.

`spec/` is part of the development workflow and is not a runtime layer.

## 3. Dependency Direction

The intended dependency direction is:

```text
Presentation
     ↓
   Domain
     ↑
Infrastructure
```

Dependency composition is handled through `di/`.

The main boundaries are:

```text
presentation → domain
infrastructure → domain
di → domain + infrastructure
features → must not depend on app
core → must not depend on features
```

Business rules must not depend on Flutter widgets or concrete external services.

## 4. SDD and TDD Workflow

Feature development follows:

```text
Requirement
    ↓
Specification
    ↓
Acceptance scenarios
    ↓
Tests
    ↓
Implementation
    ↓
Verification
```

A feature specification lives under:

```text
features/<feature>/spec/
```

The specification defines expected behavior before or alongside implementation. Tests verify that behavior and implementation is kept aligned with both.

## 5. Initial Architectural Decisions

| ADR | Decision | Status |
|---|---|---|
| ADR-001 | Feature-first Clean Architecture | Accepted |
| ADR-002 | Riverpod for state management | Accepted |
| ADR-003 | Networking, error handling, and resilience boundaries | Accepted |

Additional architectural decisions will be documented only when required by
implementation.

## 6. Scope

This architecture is the minimum structure required to begin implementation of the MVP.

It intentionally does not introduce separate architectural modules for capabilities that are not yet required by the MVP.