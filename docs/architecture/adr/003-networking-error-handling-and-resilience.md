# ADR-003: Networking and Resilience Boundaries

## Status

Accepted

## Context

The MVP requires the application to handle:

- limited connectivity;
- high network latency;
- partial service unavailability;
- loading;
- retry;
- cache;
- recovery states.

Networking concerns must remain isolated from business rules and presentation.

The project also follows a feature-first architecture in which external packages should not be imported directly by product features.

The reference architecture used by the project already centralizes Dio behind a networking wrapper with shared timeout, retry, interceptor, and connectivity policies.

## Decision

The application will use Dio as its HTTP client.

Dio will be centralized behind a networking wrapper under:

```text
lib/core/network/
```

Features must not import Dio directly.

The initial dependency flow is:

```text
Presentation
     ↓
Use Case
     ↓
Repository Interface
     ↓
Repository Implementation
     ↓
Remote Data Source
     ↓
Network Wrapper
     ↓
Dio
     ↓
External Service
```

Feature-specific infrastructure remains under:

```text
features/<feature>/infrastructure/
```

while cross-cutting HTTP concerns remain under:

```text
core/network/
```

## Network Wrapper

The networking wrapper provides the application boundary around Dio.

Its responsibilities include:

- Dio client configuration;
- base URL and common request configuration;
- connection and receive timeouts;
- interceptors;
- common headers;
- authentication transport concerns where applicable;
- retry policy;
- transport error normalization;
- request cancellation where required.

The wrapper may evolve into multiple narrow abstractions when needed, but features continue to depend on application-defined interfaces rather than Dio directly.

## Dependency Rule

External networking packages are isolated inside `core/network`.

```text
features/
    ↓
feature infrastructure
    ↓
application-defined network abstraction
    ↓
core/network
    ↓
Dio
```

This keeps product features independent from the concrete HTTP client.

The application composition root provides the concrete networking implementation through dependency injection.

## Error Handling

Transport failures are converted at the infrastructure boundary into application-level errors.

The intended flow is:

```text
Dio / transport failure
        ↓
Network wrapper
        ↓
Repository
        ↓
Application error
        ↓
Presentation state
```

Transport-specific exceptions must not leak into presentation code.

User-facing messages remain a presentation concern.

## Resilience

Dio provides transport-level mechanisms required to support resilience, including timeout handling, interceptors, request cancellation, and retry infrastructure.

Application resilience is broader than HTTP transport and therefore remains distributed across the appropriate layers.

### Limited Connectivity

Connectivity-related failures must be recognized when they affect the recovery behavior presented to the user.

Where applicable, previously available data may be preserved through the application's caching strategy.

### High Latency

Requests must use explicit timeout configuration.

The presentation layer must expose an explicit loading state and the application must avoid indefinite waiting.

Retry behavior must be bounded and operation-specific.

### Partial Service Unavailability

A failure in a secondary or optional service must not unnecessarily prevent the core financial journey from remaining usable.

Repositories and feature-level state handling are responsible for preserving this isolation.

### Loading, Retry, Cache and Recovery

The MVP represents relevant asynchronous operations through states such as:

```text
Initial
   ↓
Loading
   ↓
Success

Failure
   ↓
Retry
   ↓
Recovery
```

When cached data is available:

```text
Remote request
      ↓
failure / unavailable
      ↓
cached or stale data
      ↓
degraded presentation
      ↓
recovery
```

Detailed cache policy will be introduced when the corresponding MVP feature requires it.

## Alternatives Considered

### Direct Dio usage in features

Each feature creates or configures Dio independently.

This was rejected because it duplicates cross-cutting concerns and couples business features directly to the external package.

### Generic HTTP client abstraction without a concrete decision

Leaves the networking implementation unspecified and delays decisions that are already established by the project's existing architecture.

### Centralized Dio wrapper

Dio is configured once behind an application-owned boundary and shared through dependency injection.

This provides a concrete implementation while preserving the ability to change the underlying HTTP package later.

## Trade-offs

### Benefits

- Centralized HTTP configuration.
- Consistent timeout and retry policies.
- Centralized interceptors.
- Easier transport error normalization.
- Features remain independent of Dio.
- Test doubles can replace the network boundary.
- Consistent handling across financial features.

### Costs

- Introduces a wrapper abstraction around Dio.
- Requires clear ownership to avoid turning the wrapper into a large business-logic service.
- Some policies still belong to repositories or features rather than the network layer.

## Scope Boundary

This ADR establishes Dio and the centralized networking boundary required to start the MVP.

It does not fully define:

- offline-first synchronization;
- advanced caching;
- dynamic personalization;
- push notifications;
- external micro-application integration;
- production observability.

Those decisions will be documented only when their implementation becomes necessary.