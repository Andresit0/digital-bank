# Tests: Dynamic Experience

Tests derive from the specification scenarios, not from the implementation.
Unit, widget, integration, and E2E scenarios are defined before implementation.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| EXP-001 | Obtain remote definition | unit, integration, E2E |
| EXP-002 | Schema validation | unit, integration |
| EXP-003 | Supported sections rendered | unit, widget, integration |
| EXP-004 | Unsupported section ignored | unit, integration |
| EXP-005 | Empty sections fallback | unit, widget, integration |
| EXP-006 | Invalid schema / 5xx / transport fallback | unit, widget, integration |
| EXP-007 | Quick action intent | widget, E2E |
| EXP-008 | No release for content changes | E2E |

## Unit Scenarios

| ID | Scenario |
|---|---|
| EXP-001 | Valid ExperienceDefinition can be constructed |
| EXP-002 | Valid sections are mapped correctly |
| EXP-003 | Supported section types map to domain sections |
| EXP-004 | Unsupported section type is ignored |
| EXP-005 | Empty sections produce an empty definition |
| EXP-007 | Quick action maps to controlled QuickActionType |

## Integration Scenarios

| ID | Scenario |
|---|---|
| INT-EXP-001 | Experience loads successfully |
| INT-EXP-002 | Empty sections response |
| INT-EXP-003 | Invalid schema response |
| INT-EXP-004 | Server error (5xx) |
| INT-EXP-005 | Transport failure |

## Widget Scenarios

| ID | Scenario |
|---|---|
| WID-EXP-001 | Renderer shows loading |
| WID-EXP-002 | Renderer displays promotion and quick action |
| WID-EXP-003 | Renderer shows fallback on empty |
| WID-EXP-004 | Renderer shows fallback on failure |
| WID-EXP-005 | Quick action expresses its intent |

## E2E Scenarios

| ID | Scenario |
|---|---|
| E2E-EXP-001 | Login -> Home shows the dynamic experience |
| E2E-EXP-002 | Changing the server definition changes the rendered experience |

## Test Files

```text
test/features/experience/
  domain/entities/experience_definition_test.dart
  domain/errors/experience_error_test.dart
  infrastructure/datasources/experience_remote_data_source_test.dart
  infrastructure/models/experience_definition_model_test.dart
  infrastructure/repositories/experience_repository_impl_test.dart
  presentation/notifiers/experience_notifier_test.dart
  presentation/widgets/experience_renderer_test.dart
  integration/experience_flow_test.dart

integration_test/
  experience/experience_flow_test.dart
```

## Error Mapping Ownership

- `ExperienceRemoteDataSource` parses JSON into models and applies schema
  validation. Transport and server errors surface as `AppError` through
  `guard()`.
- `ExperienceRepositoryImpl` maps infrastructure `Result` to the domain `Result`.
- `ExperienceNotifier` maps `AppError` to `ExperienceError`:
  - transport / timeout / 5xx -> `ExperienceError.network`.
  - schema / parsing / invalid structure -> `ExperienceError.invalidConfiguration`.

## Behavior Coverage

- A valid definition with supported sections produces the loaded state.
- An empty sections list produces the empty state, not a failure.
- Unsupported section types are ignored; if none are supported the state is empty.
- Invalid schema, server error, and transport failure produce the failure state.
- Quick actions are expressed as controlled intents handled by Home.
