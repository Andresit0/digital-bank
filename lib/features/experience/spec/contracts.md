# Contracts: Dynamic Experience

## Internal Boundary

```text
HomeScreen
    |
    v
ExperienceRenderer
    |
    v
experienceProvider
    |
    v
ExperienceNotifier
    |
    v
ExperienceRepository
    |
    v
ExperienceRemoteDataSource
    |
    v
HttpClient
    |
    v
configured backend
```

Dependency direction:

```text
presentation   -> domain
infrastructure -> domain
infrastructure -> core/network + shared/error
home           -> experience (UI composition only)
experience     -> must NOT depend on home, accounts, or movements
```

Experience expresses intents through `onAction(QuickActionType)`; Home resolves
navigation. Experience never imports go_router.

## Assumed HTTP Contract

```text
GET /experience/home

Response 200:
{
  "experience": "account_home",
  "version": 3,
  "sections": [
    {
      "type": "promotion",
      "title": "Save more this month",
      "description": "Discover our latest promotion"
    },
    {
      "type": "quick_action",
      "label": "View movements",
      "action": "view_movements"
    }
  ]
}

Response 200 with no sections:
{
  "experience": "account_home",
  "version": 3,
  "sections": []
}

Response 5xx:
server failure

timeout / connection failure:
transport failure
```

This HTTP contract is an implementation assumption. It is isolated behind the
data-source and repository boundary so it can be replaced when a real backend
contract is provided.

## Endpoint Ownership

`/experience/home` is knowledge specific to the experience infrastructure. It is
a private constant of `ExperienceRemoteDataSource`, not part of global
configuration.

## Layer Responsibilities

```text
ExperienceRemoteDataSource
  Result<ExperienceDefinitionModel, AppError>
             |
             v
ExperienceRepositoryImpl
  Result<ExperienceDefinition, AppError>
             |
             v
ExperienceNotifier
  ExperienceState
```

`ExperienceRemoteDataSource` performs the HTTP request and parses the response
into models, applying schema validation. It does not know experience business
rules.
`ExperienceRepositoryImpl` transforms `ExperienceDefinitionModel` into
`ExperienceDefinition`, preserving the `AppError`. `ExperienceNotifier` maps
`AppError` to `ExperienceError` and exposes `ExperienceState`.

## ExperienceRemoteDataSource

```dart
abstract interface class ExperienceRemoteDataSource {
  Future<Result<ExperienceDefinitionModel>> fetchHomeExperience();
}
```

## ExperienceDefinitionModel

- experience: String
- version: int
- sections: List<ExperienceSectionModel>
- Defined in infrastructure.
- Created from JSON via a `fromJson` factory.
- Mapped to `ExperienceDefinition` by the repository implementation.

## Validation Rules

```text
valid definition with supported sections      -> loaded
valid definition with sections: []            -> empty
unsupported section type                      -> ignored
all sections unsupported                      -> empty
invalid schema / unparsable structure         -> invalidConfiguration
transport / timeout / 5xx                     -> network
```

## Error Mapping

The mapping is performed through `guard()`, producing `Result<..., AppError>` in
infrastructure, and translated to `ExperienceError` in the notifier:

```text
transport / timeout / 5xx            -> ExperienceNetwork
schema / parsing / invalid structure -> ExperienceInvalidConfiguration
```

`DioException` never crosses into the domain or presentation.

## Configuration

```text
--dart-define=API_BASE_URL=...
          |
          v
       AppConfig
          |
          v
      dioProvider
          |
          v
       HttpClient
          |
          v
  ExperienceRemoteDataSource
```

`AppConfig` exposes only `apiBaseUrl`. The experience endpoint path is owned by
the experience infrastructure.

## Home Integration

Home mounts `ExperienceRenderer`. The renderer reads `experienceProvider` and
renders supported sections. When Home receives `onAction(QuickActionType)`, Home
resolves the navigation target:

```text
QuickActionType.viewMovements -> navigate to movements
QuickActionType.viewAccounts  -> navigate to accounts
```

This keeps Experience independent from Accounts and Movements.

## Authentication

Protected endpoint.
Requires `Authorization: Bearer <accessToken>`.
The token is attached centrally by the shared API client; the feature never
reads or builds it. See `docs/architecture/pr18-api-integration.md`.
