# ADR-002: State Management with Riverpod

## Status

Accepted

## Context

The MVP requires:

- authentication state;
- asynchronous financial data;
- loading and error states;
- retry and recovery states;
- feature-local state;
- testable dependencies.

The solution should support these requirements without unnecessary ceremony.

## Decision

The application will use Riverpod for state management and dependency composition.

Feature state should remain local to the feature that owns it.

Feature dependencies are composed under:

```text
features/<feature>/di/
```

Application-wide dependencies are composed under:

```text
app/di/
```

Business rules remain in the domain layer and are not placed inside widgets or presentation-specific state.

## State Principles

### Local ownership

State belongs to the smallest appropriate feature or application scope.

### Explicit asynchronous states

Relevant operations should represent states such as:

```text
Initial
Loading
Success
Empty
Error
Recovery
```

### Testable dependencies

Riverpod providers must be replaceable or overridable during tests.

### Avoid unnecessary global state

State should only be shared when multiple features genuinely depend on the
same owner.

## Alternatives Considered

### `setState`

Suitable for small ephemeral widget state but insufficient as the primary
application state-management mechanism.

### BLoC / Cubit

Provides explicit state transitions but introduces more ceremony than needed
for the MVP.

### Riverpod

Provides reactive state, dependency composition, test overrides, and feature
isolation with relatively low ceremony.

## Trade-offs

### Benefits

- Combines state management and dependency composition.
- Supports testable providers.
- Keeps feature state isolated.
- Handles asynchronous state naturally.

### Costs

- Introduces Riverpod-specific concepts.
- Requires consistent provider ownership conventions.

## Long-term Impact

Riverpod remains the application state and dependency-composition mechanism
as the MVP evolves.

Providers must not become substitutes for domain entities, use cases, or
repositories.