# ADR-001: Feature-first Clean Architecture

## Status

Accepted

## Context

The MVP contains multiple financial capabilities that should remain independently understandable and maintainable.

The project also follows Specification-Driven Development (SDD) and Test-Driven Development (TDD), requiring clear boundaries between business rules, infrastructure, presentation, and feature specifications.

A global layer-first structure would group unrelated product capabilities together and make feature boundaries less explicit.

## Decision

The application will use a feature-first structure with Clean Architecture boundaries.

Each feature follows:

```text
feature/
├── di/
├── domain/
├── infrastructure/
├── presentation/
└── spec/
```

The application-level structure is:

```text
lib/
├── app/
├── core/
├── shared/
└── features/
```

### Domain

Contains business rules and contracts.

The domain must not depend on Flutter UI or concrete infrastructure.

### Infrastructure

Contains external and data-access implementations:

- data sources;
- DTOs;
- mappers;
- repository implementations;
- service adapters.

### Presentation

Contains:

- screens;
- widgets;
- presentation state.

Business rules must not be implemented directly in widgets.

### DI

Contains feature-level dependency composition.

### Spec

Contains feature specifications and acceptance scenarios used by the SDD/TDD workflow.

`spec/` is a development artifact, not a runtime architecture layer.

## Dependency Rules

```text
presentation → domain
infrastructure → domain
di → domain + infrastructure
```

In addition:

- features must not depend on `app/`;
- `core/` must not depend on features;
- feature-specific concepts remain inside their owning feature;
- shared abstractions are introduced only when genuinely shared.

## Alternatives Considered

### Layer-first architecture

Groups all presentation, domain, and data code globally.

This is simple initially but weakens feature boundaries as the application grows.

### Feature-first without explicit architectural boundaries

Groups code by feature but allows business rules, UI, and infrastructure to become tightly coupled.

### Feature-first Clean Architecture

Provides feature isolation while preserving separation between business rules, infrastructure, and presentation.

## Trade-offs

### Benefits

- Clear feature boundaries.
- Easier testing through dependency substitution.
- Better separation of business rules.
- Supports adding future financial features.

### Costs

- More structure than a minimal Flutter application.
- Requires discipline around dependency direction.
- Small features may not require every abstraction immediately.

## Long-term Impact

New financial capabilities can be added as new features without reorganizing the entire application.

The architecture will evolve only when actual product requirements require additional abstractions.