# Domain: Dynamic Experience

## Entities

### ExperienceDefinition

- experience: String
- version: int
- sections: List<ExperienceSection>

`ExperienceDefinition` is pure Dart. It does not depend on Flutter, Dio, or any
transport type.

### ExperienceSection

```text
sealed class ExperienceSection
  PromotionSection
  QuickActionSection
```

### PromotionSection

- title: String
- description: String?

### QuickActionSection

- label: String
- action: QuickActionType

## Enums

### QuickActionType

```text
QuickActionType
  viewMovements
  viewAccounts
```

`QuickActionType` represents an intent. It does not navigate and does not
reference routes, `go_router`, or other features.

## Repository Contract

```dart
abstract interface class ExperienceRepository {
  Future<Result<ExperienceDefinition>> fetchHomeExperience();
}
```

`ExperienceRepository` is the domain entry point for the experience definition.
It depends on `shared/error` (`Result`, `AppError`). No use cases are introduced
because the only domain behavior is fetching the definition.

## Domain Errors

```text
sealed class ExperienceError
  ExperienceNetwork
  ExperienceInvalidConfiguration
```

Mapping:

```text
transport / timeout / 5xx -> ExperienceNetwork
schema / parsing / invalid structure -> ExperienceInvalidConfiguration
```

`ExperienceError` is the feature-level failure abstraction exposed to
Presentation. It does not contain transport-specific types and does not
replace `AppError` as the infrastructure error model.

Chain:

```text
HTTP / Dio
    ↓
AppError
    ↓
ExperienceRepository
    ↓
ExperienceError
    ↓
ExperienceState
```

## Presentation State

`ExperienceState` belongs to Presentation, not to Domain:

```text
sealed class ExperienceState
  ExperienceInitial
  ExperienceLoading
  ExperienceLoaded(ExperienceDefinition)
  ExperienceEmpty
  ExperienceFailure(ExperienceError)
```

`ExperienceEmpty` is a valid state. A valid definition without dynamic sections
is not an error.

## Rules

- The domain does not import Flutter and does not import go_router.
- The domain does not import `HttpResponse` or any transport contract.
- HTTP-to-domain mapping belongs to infrastructure.
- There are no use cases in this feature: the only domain behavior is fetching
  the home experience.
- Selection personalization (which experience corresponds to which user) is out
  of scope and is not modeled here.
