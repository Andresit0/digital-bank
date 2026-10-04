# Requirements Traceability

## 1. Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | Requirements Traceability Matrix |
| Version | 1.0 |
| Status | Baseline |
| Source | Technical Assessment — Front-End |
| Assessment Received | 2026-10-02 |
| Submission Deadline | 2026-10-05 23:00 (Ecuador time) |
| Last Updated | 2026-10-03 |

---

## 2. Purpose

This document establishes the traceability baseline for the technical assessment and acts as the project's source of truth for traceability.

It distinguishes between the different kinds of source material so that every traceable item has a precise origin:

- **Source Requirements** — requirements explicitly stated in the assessment that the candidate must satisfy.
- **Constraints** — non-negotiable restrictions on the solution.
- **Assumptions** — decisions made by the candidate to be able to execute.
- **Evaluation Criteria** — the lenses through which the result is judged.
- **Deliverables** — artifacts that must be produced.
- **Bonus Capabilities** — optional capabilities outside the MVP.
- **Derived Security Requirements** — requirements derived from an evaluation criterion.
- **Demonstration Protocol** — the assessment mechanism applied during the functional demonstration.

The traceability chain is:

```text
Source
  ↓
Traceability Item (REQ / SEC / CON / ASM / EC / DEL / BON / DEM)
  ↓
Architecture Decision (when applicable)
  ↓
Implementation / Process / Artifact
  ↓
Verification
  ↓
Documentation
  ↓
Evidence
```

### Traceability identifiers

```text
REQ — Requirement
SEC — Derived Security Requirement
CON — Constraint
ASM — Assumption
EC  — Evaluation Criterion
DEL — Deliverable
BON — Bonus Capability
DEM — Demonstration Protocol
ADR — Architecture Decision Record
```

`ADR` is a decision artifact, not a requirement. ADRs are not matrix rows; they are referenced from the `Traceability` column of the items they address. ADRs are project decisions and never carry a `Source Type`. The chain is always `requirement/criterion → architectural problem → ADR`, never `source material → ADR`.

### Column semantics

| Column | Function |
|---|---|
| Related Areas | Conceptual relation between areas. |
| Technical Direction | Proposed engineering direction for satisfying the item. It is not a source requirement and becomes a finalized architectural decision when documented in the corresponding ADR. |
| Traceability | Concrete engineering chain: origin → decision → implementation → verification → evidence. |
| Source | Exact origin of the item. |
| Source Type | `Explicit` (backed by a concrete phrase in the source assessment material), `Derived` (deduced from a criterion/requirement), `Assumed` (project decision or assumption not stated in the source). |
| Priority | Project-level implementation priority for MVP planning. It is not an assessment-provided classification unless explicitly stated. |
| Status | Lifecycle state, `TBD` during the baseline phase. |
| Implementation / Tests / Documentation / Evidence | Real artifacts, `TBD` at baseline. |

---
> `TBD`: To be determined

## 3. Source Requirements

Requirements taken directly from the assessment. Requirements derived from evaluation criteria are catalogued in Section 6, while derived security requirements are catalogued in Section 9.

### 3.1 Functional

| ID | Requirement |
|---|---|
| REQ-001 | Provide customer onboarding and authentication |
| REQ-002 | Provide account management, balances, and movements |
| REQ-003 | Support dynamic personalization of the customer experience, content, or functionality |
| REQ-004 | Integrate at least one relevant external service or micro-application |
| REQ-005 | Support push notifications |

### 3.2 Resilience

| ID | Requirement |
|---|---|
| REQ-006 | Handle limited connectivity |
| REQ-007 | Handle high network latency |
| REQ-008 | Handle partial service unavailability |
| REQ-009 | Provide loading, retry, cache, and recovery states |

### 3.3 Testing

| ID | Requirement |
|---|---|
| REQ-010 | Include unit tests |
| REQ-011 | Include widget tests |
| REQ-012 | Include at least one critical end-to-end flow |

### 3.4 Operations

| ID | Requirement |
|---|---|
| REQ-013 | Explain how production, operational, and UX issues will be monitored and detected |

### 3.5 Development Process

| ID | Requirement |
|---|---|
| REQ-014 | Use Trunk Based Development |
| REQ-019 | Document AI tool usage during development |
| REQ-020 | Explain AI impact on productivity, quality, documentation, and testing |

### 3.6 Documentation

| ID | Requirement |
|---|---|
| REQ-015 | Document architecture decisions with problem, alternatives, selected option, trade-offs, and long-term impact |
| REQ-016 | Provide component, flow, and dependency diagrams |
| REQ-017 | Document assumptions and technical risks |
| REQ-018 | Document the scalability strategy |

---

## 4. Constraints

| ID | Constraint | Source | Source Type |
|---|---|---|---|
| CON-001 | The application must be built with Flutter. Other technologies are allowed as long as the assessment objectives are achieved. | Important Considerations — Technology | Explicit |
| CON-002 | The assessment values real service interaction or dynamic processing. Solutions based only on simulated/static data are accepted, but are not positively evaluated without evidence of real service interaction or dynamic processing. | Important Considerations — Simulated data | Explicit |

---

## 5. Assumptions

No project-specific assumptions have been established at the requirements-baseline stage.

---

## 6. Evaluation Criteria

These are the lenses used to evaluate the solution, not features to implement.

| ID | Evaluation Criterion | Source | Source Type | Priority |
|---|---|---|---|---|
| EC-001 | Architecture: modularity, scalability, maintainability, justification of decisions, and evolvability | Evaluation Criteria — Architecture | Explicit | High |
| EC-002 | Engineering Quality: patterns, state management, testing, security, and observability | Evaluation Criteria — Engineering Quality | Explicit | Critical |
| EC-003 | User Experience: personalization, consistency, accessibility, and interaction quality | Evaluation Criteria — UX | Explicit | High |
| EC-004 | Documentation: clarity of diagrams, decisions, risks, and trade-offs | Evaluation Criteria — Documentation | Explicit | High |
| EC-005 | Product Thinking: prioritization, value focus, customer experience, degraded scenarios, and scope decisions | Evaluation Criteria — Product Thinking | Explicit | High |
| EC-006 | AI & Automation: effective use of tools to accelerate and improve development | Evaluation Criteria — AI & Automation | Explicit | High |
| EC-007 | Versioning: Trunk Based Development, commit frequency, and history quality | Evaluation Criteria — Versioning | Explicit | High |

### Derived requirements from evaluation criteria

`EC` describes how the solution is evaluated. A derived `REQ` describes the project-level response to that criterion. A derived requirement never replaces its criterion.

| ID | Derived requirement | Derived from | Source Type |
|---|---|---|---|
| REQ-021 | Product thinking and prioritization | EC-005 | Derived |
| REQ-022 | Demonstrate engineering quality including patterns, state management, testing, security, and observability | EC-002 | Derived |
| REQ-023 | Provide a usable and coherent financial application experience | EC-003 | Derived |
| REQ-024 | Effectively use AI and development tools to accelerate and improve development | EC-006 | Derived |
| REQ-025 | Provide an accessible user interface based on the accessibility criterion | EC-003 | Derived |

> Security requirements derived from EC-002 are catalogued in Section 9.

### Demonstration Protocol

The source assessment states that during the demonstration bounded changes may be requested, as well as explanations of decisions, diagnosis of a failure, or adjustment of a test. This is not an evaluation criterion from the criteria table; it is the mechanism applied during the functional demonstration.

| ID | Item | Source | Source Type | Related Deliverable |
|---|---|---|---|---|
| DEM-001 | Demonstration protocol: bounded changes, decision explanation, fault diagnosis, and test adjustment during the demonstration | Demonstration — assessment protocol | Explicit | DEL-005 |

---

## 7. Deliverables

| ID | Deliverable | Source | Source Type | Related Requirement |
|---|---|---|---|---|
| DEL-001 | Complete source code in a repository with development history | Minimum Deliverables | Explicit | — |
| DEL-002 | README with reproducible setup, execution, testing, and collaboration instructions | Minimum Deliverables | Explicit | — |
| DEL-003 | Architecture and technical decisions documentation | Minimum Deliverables | Explicit | REQ-015, REQ-016, REQ-017, REQ-018 |
| DEL-004 | Deployment and operations strategy documentation | Minimum Deliverables | Explicit | REQ-013 |
| DEL-005 | Functional demonstration | Minimum Deliverables | Explicit | — |

> `DEL-005` is the deliverable. `DEM-001` describes the protocol that may be applied **during** the demonstration (e.g. fault diagnosis). They are distinct: the deliverable does not promise that the evaluator's scenario is pre-built.

---

## 8. Bonus Capabilities

| ID | Bonus Capability | Source | Source Type | Related Requirement |
|---|---|---|---|---|
| BON-001 | Advanced personalization or assistant capabilities | Bonus | Explicit | REQ-003 |
| BON-002 | Dynamically generated experiences | Bonus | Explicit | REQ-003 |
| BON-003 | Automation for development, testing, deployment, or documentation | Bonus | Explicit | REQ-024 |

> `REQ-003` (dynamic personalization) is a **required** capability. `BON-002` (dynamically generated experiences) is a distinct **bonus** capability. They are not equivalent.
> `BON-001` extends the required personalization capability; assistant capabilities are bonus-only.

---

## 9. Derived Security Requirements

These requirements are derived from the evaluation criterion **EC-002 (Engineering Quality)**, which explicitly includes security. They are not literal requirements written one by one in the assessment.

```text
EC-002 Engineering Quality
  └── Security
       ├── SEC-001 Credentials/token handling
       ├── SEC-002 Sensitive data protection
       ├── SEC-003 Secrets/config separation
       ├── SEC-004 Secure credential storage
       └── SEC-005 Sensitive data logging protection
```

| ID | Security Requirement | Derived from | Source Type |
|---|---|---|---|
| SEC-001 | Handle credentials and tokens safely | EC-002 | Derived |
| SEC-002 | Protect sensitive financial data | EC-002 | Derived |
| SEC-003 | Separate secrets from configuration | EC-002 | Derived |
| SEC-004 | Store credentials securely | EC-002 | Derived |
| SEC-005 | Do not expose sensitive data in logs | EC-002 | Derived |

---

## 10. Requirements Traceability Matrix

`ADR` items are not rows. They are referenced in the `Traceability` column.

| ID | Type | Requirement / Item | Category | Related Areas | Source | Source Type | Priority | Technical Direction | Traceability | Status | Implementation | Tests | Documentation | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| REQ-001 | Requirement | Customer onboarding and authentication | Functional | Product, Security | Minimum Scope — Onboarding and authentication | Explicit | Critical | Auth feature with session management | REQ-001 → ADR-002 → auth feature → unit/widget tests → evidence | Implemented | `features/auth/` (domain/infrastructure/presentation, login flow, in-memory session) | `test/features/auth/` (domain, infrastructure, presentation, routing) | `features/auth/spec/` | Login flow and guarded routing verified; session persistence not in scope |
| REQ-002 | Requirement | Account management, balances, and movements | Functional | Product, Architecture | Minimum Scope — Accounts, balances and movements | Explicit | Critical | Accounts and movements feature with repository-based data access | REQ-002 → ADR-001, ADR-003 → accounts/movements feature → tests → evidence | Accounts Implemented · Movements Deferred | `features/accounts/` (domain, infrastructure, presentation, DI; accounts + balances; movements deferred) | `test/features/accounts/` + `integration_test/accounts/` | `features/accounts/spec/` | Accounts with type, masked number, and available balance; login → home → accounts flow verified via E2E; movements out of scope |
| REQ-003 | Requirement | Dynamic personalization of experience, content, or functionality | Functional | Product, UX | Minimum Scope — Dynamic personalization | Explicit | High | Remote configuration/content model with controlled schema | REQ-003 → ADR-005 → personalization module → tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-004 | Requirement | Integrate at least one external service or micro-application | Functional | Architecture | Minimum Scope — External service integration | Explicit | High | Repository + adapter integration boundary | REQ-004 → ADR-006 → adapter → integration tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-005 | Requirement | Push notifications | Functional | Product, UX | Minimum Scope — Push notifications | Explicit | High | Notification service isolated from business features | REQ-005 → ADR-007 → notification service → integration test → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-006 | Requirement | Handle limited connectivity | Resilience | Architecture | Minimum Scope — Limited connectivity | Explicit | High | Local cache plus explicit offline/stale states | REQ-006 → ADR-004 → cache/offline → resilience tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-007 | Requirement | Handle high network latency | Resilience | Architecture | Minimum Scope — High latency | Explicit | High | Timeouts plus bounded retry strategy | REQ-007 → ADR-004 → timeout/retry → resilience tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-008 | Requirement | Handle partial service unavailability | Resilience | Architecture | Minimum Scope — Partial service unavailability | Explicit | High | Independent feature/module failure isolation | REQ-008 → ADR-004, ADR-006 → failure isolation → resilience tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-009 | Requirement | Loading, retry, cache, and recovery states | Resilience | UX | Minimum Scope — Degraded behavior | Explicit | High | Explicit presentation states | REQ-009 → ADR-004 → presentation states → widget tests → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-010 | Requirement | Unit tests | Testing | Engineering Quality | Minimum Scope — Unit tests | Explicit | High | Domain/use-case/repository unit tests | REQ-010 → test layer → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-011 | Requirement | Widget tests | Testing | UX, Engineering Quality | Minimum Scope — Widget tests | Explicit | High | Critical UI state and interaction tests | REQ-011 → test layer → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-012 | Requirement | At least one critical end-to-end flow | Testing | Engineering Quality | Minimum Scope — Critical E2E flow | Explicit | High | At least one critical E2E flow, to be defined in the MVP scope | REQ-012 → E2E flow → evidence | Implemented | `integration_test/auth/authentication_flow_test.dart` (INT-AUTH-001..006) | `flutter test` + `flutter test integration_test` on iOS Simulator | `features/auth/spec/tests.md` | E2E critical authentication flow (login, invalid credentials, server error, transport failure, logout, protected route) |
| REQ-013 | Requirement | Monitor and detect production, operational, and UX issues | Operations | Engineering Quality | Minimum Scope — Production monitoring and issue detection | Explicit | High | Crash, network, operational, and UX monitoring strategy | REQ-013 → ADR-009 → monitoring strategy/hooks → operational documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-014 | Requirement | Use Trunk Based Development | Development Process | Versioning | Version Control — Trunk Based Development | Explicit | Critical | `main` trunk plus short-lived branches plus PRs | REQ-014 → process → git history → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-015 | Requirement | Architecture decisions with problem, alternatives, option, trade-offs, and long-term impact | Documentation | Architecture | Documentation Requirements — Architecture decisions | Explicit | Critical | Architecture documentation plus ADRs | REQ-015 → ADRs → architecture documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-016 | Requirement | Component, flow, and dependency diagrams | Documentation | Architecture | Documentation Requirements — Diagrams | Explicit | High | Mermaid architecture and flow diagrams | REQ-016 → diagrams documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-017 | Requirement | Assumptions and technical risks | Documentation | Architecture | Documentation Requirements — Assumptions and risks | Explicit | High | Assumptions and risk register | REQ-017 → architecture documentation → risk register → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-018 | Requirement | Document the scalability strategy | Documentation | Architecture | Documentation Requirements — Scalability | Explicit | High | Modular feature architecture plus scalability strategy | REQ-018 → ADR-001 → scalability documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-019 | Requirement | Document AI usage during development | Development Process | Documentation | Minimum Scope — AI usage documentation | Explicit | High | AI development log and validation process | REQ-019 → AI documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-020 | Requirement | Explain AI impact on productivity, quality, documentation, and testing | Development Process | Documentation | Minimum Scope — AI impact | Explicit | High | AI development documentation plus evidence | REQ-020 → AI documentation → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-021 | Derived Requirement | Product thinking and prioritization | Product | Product, UX | Evaluation Criteria — Product Thinking | Derived | High | MVP scope plus prioritization rationale | REQ-021 ← EC-005 → MVP scope and prioritization rationale → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-022 | Derived Requirement | Engineering quality: patterns, state management, testing, security, observability | Engineering Quality | Engineering Quality, Testing, Security, Operations | Evaluation Criteria — Engineering Quality | Derived | Critical | Engineering practices, automated tests, security controls, and observability evidence | REQ-022 ← EC-002 → SEC-001..005, ADR-008, ADR-009 → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-023 | Derived Requirement | Usable and coherent financial application experience | UX | UX, Product | Evaluation Criteria — UX | Derived | High | Consistent navigation, states, feedback, and visual hierarchy | REQ-023 ← EC-003 → DEL-005 → widget tests and review | TBD | TBD | TBD | TBD | TBD |
| REQ-024 | Derived Requirement | Effective use of AI and development tools | Development Process | Development Process | Evaluation Criteria — AI & Automation | Derived | Medium | AI-assisted development workflows with documented validation | REQ-024 ← EC-006 → AI-assisted workflows → evidence | TBD | TBD | TBD | TBD | TBD |
| REQ-025 | Derived Requirement | Provide an accessible user interface based on the accessibility criterion | UX | UX, Engineering Quality | Evaluation Criteria — UX | Derived | High | Apply accessibility practices appropriate to the implemented UI | REQ-025 ← EC-003 → DEL-005 → accessibility checks | TBD | TBD | TBD | TBD | TBD |
| SEC-001 | Security | Credentials and token handling | Security | Engineering Quality | Evaluation Criteria — Engineering Quality | Derived | High | Safe token lifecycle and handling | SEC-001 ← EC-002 → ADR-008 → verification | Implemented (in memory) | Credentials sent via HTTPS `HttpClient`; `AuthSession` kept in memory only | `test/features/auth/infrastructure/`, `test/features/auth/presentation/` | `features/auth/spec/spec.md` | No client-side password hashing (out of scope); no persistence |
| SEC-002 | Security | Sensitive data protection | Security | Engineering Quality | Evaluation Criteria — Engineering Quality | Derived | High | Minimize and protect sensitive financial data | SEC-002 ← EC-002 → ADR-008 → verification | TBD | TBD | TBD | TBD | TBD |
| SEC-003 | Security | Secrets and configuration separation | Security | Engineering Quality | Evaluation Criteria — Engineering Quality | Derived | High | Keep secrets separate from application source code and non-secret configuration | SEC-003 ← EC-002 → ADR-008 → verification | TBD | TBD | TBD | TBD | TBD |
| SEC-004 | Security | Secure credential storage | Security | Engineering Quality | Evaluation Criteria — Engineering Quality | Derived | High | Platform secure storage for credentials | SEC-004 ← EC-002 → ADR-008 → verification | Deferred | Not implemented in PR9 (no secure storage, no session persistence) | — | `features/auth/spec/spec.md` (out of scope) | Session is memory-only |
| SEC-005 | Security | Sensitive data logging protection | Security | Engineering Quality | Evaluation Criteria — Engineering Quality | Derived | High | Redact sensitive data from logs | SEC-005 ← EC-002 → ADR-008 → verification | TBD | TBD | TBD | TBD | TBD |
| CON-001 | Constraint | Flutter is mandatory for the application | Constraint | Technology, Architecture | Important Considerations — Technology | Explicit | Critical | Flutter application; additional technologies allowed where they help achieve the objectives | CON-001 → project setup → evidence | TBD | TBD | TBD | TBD | TBD |
| CON-002 | Constraint | Real service interaction or dynamic processing valued; simulated/static-only solutions accepted but not positively evaluated without evidence | Constraint | Architecture, Product | Important Considerations — Simulated data | Explicit | High | Real service integration or dynamic processing | CON-002 → ADR-003, ADR-006 → integration evidence | Implemented (controlled scope) | Authentication flow runs through the real `Dio` client and `HttpClient` boundary | `test/features/auth/integration/`, `integration_test/auth/` | `features/auth/spec/tests.md` | The authentication flow is validated through a real Dio client against a controlled local HTTP server implementing the documented contract. Integration with the bank's real backend is Deferred because no backend service/API contract is available within the assessment scope. |
| EC-001 | Evaluation Criterion | Architecture | Evaluation | Architecture | Evaluation Criteria — Architecture | Explicit | High | Evaluation lens | EC-001 → ADR-001..004 → architecture review | TBD | TBD | TBD | TBD | TBD |
| EC-002 | Evaluation Criterion | Engineering Quality | Evaluation | Engineering Quality, Security | Evaluation Criteria — Engineering Quality | Explicit | Critical | Evaluation lens | EC-002 → REQ-022, SEC-001..005, ADR-008, ADR-009 → evidence | TBD | TBD | TBD | TBD | TBD |
| EC-003 | Evaluation Criterion | User Experience | Evaluation | UX | Evaluation Criteria — UX | Explicit | High | Evaluation lens | EC-003 → REQ-023, REQ-025 → DEL-005 | TBD | TBD | TBD | TBD | TBD |
| EC-004 | Evaluation Criterion | Documentation | Evaluation | Documentation | Evaluation Criteria — Documentation | Explicit | High | Evaluation lens | EC-004 → REQ-015..018 → documentation review | TBD | TBD | TBD | TBD | TBD |
| EC-005 | Evaluation Criterion | Product Thinking | Evaluation | Product | Evaluation Criteria — Product Thinking | Explicit | High | Evaluation lens | EC-005 → REQ-021 → MVP scope/prioritization → DEL-005 | TBD | TBD | TBD | TBD | TBD |
| EC-006 | Evaluation Criterion | AI & Automation | Evaluation | Development Process | Evaluation Criteria — AI & Automation | Explicit | High | Evaluation lens | EC-006 → REQ-019, REQ-020, REQ-024 → evidence | TBD | TBD | TBD | TBD | TBD |
| EC-007 | Evaluation Criterion | Versioning | Evaluation | Development Process | Evaluation Criteria — Versioning | Explicit | High | Evaluation lens | EC-007 → REQ-014, DEL-001 → git history | TBD | TBD | TBD | TBD | TBD |
| DEM-001 | Demonstration Protocol | Bounded changes, decision explanation, fault diagnosis, and test adjustment during the demonstration | Demonstration | Product, UX, Engineering Quality | Demonstration — assessment protocol | Explicit | High | Demonstrable application state plus ability to diagnose and adjust | DEL-005 → DEM-001 → demonstration | TBD | TBD | TBD | TBD | TBD |
| DEL-001 | Deliverable | Complete source code and history | Deliverable | Development Process | Minimum Deliverables | Explicit | Critical | Repository with meaningful history | DEL-001 → git history | TBD | TBD | TBD | TBD | TBD |
| DEL-002 | Deliverable | Reproducible README | Deliverable | Documentation | Minimum Deliverables | Explicit | Critical | Setup, run, test, and collaboration instructions | DEL-002 → README | TBD | TBD | TBD | TBD | TBD |
| DEL-003 | Deliverable | Architecture and technical decisions documentation | Deliverable | Architecture, Documentation | Minimum Deliverables | Explicit | High | ADRs plus diagrams | DEL-003 ← REQ-015, REQ-016, REQ-017, REQ-018 → documentation | TBD | TBD | TBD | TBD | TBD |
| DEL-004 | Deliverable | Deployment and operations documentation | Deliverable | Operations | Minimum Deliverables | Explicit | High | Deployment, monitoring, and incident strategy | DEL-004 ← REQ-013 → operations documentation | TBD | TBD | TBD | TBD | TBD |
| DEL-005 | Deliverable | Functional demonstration | Deliverable | Product, UX | Minimum Deliverables | Explicit | High | Demonstrable end-to-end experience | DEL-005 ← EC-003, EC-005, DEM-001 → demonstration | Implemented | login → Home → logout demonstrable flow | `integration_test/auth/authentication_flow_test.dart` | `features/auth/spec/tests.md` | Demonstrable on iOS Simulator; backend real deferred |
| BON-001 | Bonus | Advanced personalization or assistant capabilities | Bonus | Product, UX | Bonus | Explicit | Low | Optional, beyond MVP | BON-001 ← REQ-003 → evidence (if delivered) | TBD | TBD | TBD | TBD | TBD |
| BON-002 | Bonus | Dynamically generated experiences | Bonus | Product | Bonus | Explicit | Low | Optional, distinct from REQ-003 | BON-002 ← REQ-003 → evidence (if delivered) | TBD | TBD | TBD | TBD | TBD |
| BON-003 | Bonus | Development, testing, deployment, or documentation automation | Bonus | Development Process, Operations | Bonus | Explicit | Medium | Optional, beyond MVP | BON-003 ← REQ-024 → pipeline → evidence | TBD | TBD | TBD | TBD | TBD |

---

## 11. Initial Product Scope

The project-level implementation scope is defined and prioritized in:

`docs/product/scope-and-prioritization.md`

The primary MVP journey is:

```text
Onboarding
    ↓
Authentication
    ↓
Home / Dashboard
    ↓
Account Summary
    ↓
Transaction History
    ↓
Transaction Detail
```

The scope is organized into:

- P0 — Core MVP: primary customer journey, resilience, core quality, security baseline, and critical verification.
- P1 — Required Secondary Capabilities: required assessment capabilities implemented after the core journey.
- Deferred: capabilities intentionally excluded from the initial implementation sequence.
- Bonus: optional capabilities that do not displace explicit assessment requirements.

The detailed requirement-to-scope mapping, prioritization rationale, and MVP acceptance criteria are maintained in:

`docs/product/scope-and-prioritization.md`

Product priority is a project decision and must not be interpreted as an assessment-provided classification.

---

## 12. Architecture Implications

| Requirement Area | Architectural Question |
|---|---|
| Multiple financial features | How should features be modularized? |
| State management | How should UI/application state be managed? |
| External APIs | Where should networking and external dependencies live? |
| Limited connectivity | Where should caching and resilience policies be implemented? |
| Personalization | How can content/functionality change without tightly coupling the UI to remote configuration? |
| Dynamic experience delivery | How can new experiences, content, or visual components be introduced without a full app release? |
| External service | How can a third-party service be isolated from the core application? |
| Partial failure | How can optional modules fail without taking down the core experience? |
| Testing | How can dependencies be replaced with test doubles? |
| Scalability | How can additional financial domains be added without creating excessive coupling? |
| Multi-domain evolution | How can the platform evolve into multiple functional domains managed by independent teams? |
| Security | Where should authentication, secrets, and sensitive-data handling be isolated? |
| Observability | How are failures and degraded states detected and surfaced? |

These questions lead to the architecture decisions documented as ADRs.

---

## 13. Planned Architecture Decisions

Each ADR documents: problem, alternatives, selected option, trade-offs, and long-term impact.

ADRs are project decisions, not source requirements. They are driven by one or more requirements or evaluation criteria (`REQ/EC → architectural problem → ADR`) and therefore carry no `Source Type`.

| ADR | Decision Area | Triggered By | Status |
|---|---|---|---|
| ADR-001 | Feature-first Clean Architecture | REQ-002, REQ-018, EC-001 | Planned |
| ADR-002 | State Management | REQ-001, REQ-002, REQ-009, EC-002 | Planned |
| ADR-003 | Networking and Error Handling | REQ-006, REQ-007, REQ-008 | Planned |
| ADR-004 | Resilience and Caching | REQ-006, REQ-007, REQ-008, REQ-009 | Planned |
| ADR-005 | Dynamic Personalization | REQ-003 | Planned |
| ADR-006 | External Service Integration | REQ-004, REQ-008 | Planned |
| ADR-007 | Push Notifications | REQ-005 | Planned |
| ADR-008 | Security and Secrets Handling | SEC-001, SEC-002, SEC-003, SEC-004, SEC-005, EC-002 | Planned |
| ADR-009 | Observability and Monitoring | REQ-013, EC-002 | Planned |

---

## 14. Planned Verification Strategy

| Requirement Type | Planned Verification |
|---|---|
| Functional requirements | Unit + widget + integration/E2E tests |
| Resilience requirements | Unit/integration tests for timeout, offline, retry, stale data, and partial failure |
| Security requirements | Code review + secure-storage verification + log redaction checks |
| Accessibility requirements | Semantic/widget checks + manual review |
| Architecture | Architecture review + dependency validation |
| Scalability | Architecture review + scalability strategy documentation |
| External integration | Integration tests + test doubles for development |
| Personalization | Unit/widget tests for dynamic configurations |
| Push notifications | Integration/manual verification |
| CI/CD | Automated pipeline execution |
| Trunk Based Development | Git history + PR history |
| Monitoring | Operational documentation + configured monitoring hooks |
| Documentation | Repository review |
| AI usage and impact | AI development log + validation + documented impact on productivity, quality, documentation, and testing |
| Product thinking | Review MVP scope, prioritization rationale, and scope decisions |
| UX | Widget/integration tests + manual review |
| Demonstration protocol | Execute bounded change, decision explanation, failure diagnosis, and test adjustment scenarios |

---

## 15. Traceability Status

At version 1.0, the project is in the requirements-baseline phase. The implementation tracking fields are therefore `TBD`. The status vocabulary below is applied as implementation progresses.

| Status | Meaning |
|---|---|
| `TBD` | Not yet determined (baseline) |
| `Planned` | Requirement identified but implementation has not started |
| `In Progress` | Requirement is currently being implemented |
| `Implemented` | Implementation exists |
| `Verified` | Required tests/verification have passed |
| `Documented` | Supporting documentation is complete |
| `Complete` | Implementation, verification, and documentation are complete |

Version 1.0 established the requirements baseline. Implementation has since progressed and is tracked per item in the matrix; the baseline remains as the historical starting point.

Initial state:

```text
Requirements:  Defined
Constraints:   Defined
Assumptions:    None defined
Architecture:  Not yet finalized
Implementation: Not started
Tests:          Not started
Documentation:  Baseline
Evidence:       TBD
```

Current implementation status:

```text
Architecture:  ADR-001/002/003 defined (Accepted)
Implementation: In progress (authentication, accounts)
Tests:          In progress (unit, widget, integration-style, E2E)
Documentation:  In progress
Evidence:       Partial
```

---

## 16. Update Rules

This document is updated whenever an item:

- is implemented;
- results in an architectural decision;
- requires a new test;
- changes the product scope;
- introduces a technical risk;
- requires operational documentation;
- is deferred or excluded from the MVP.

The matrix must remain synchronized with the actual state of the project rather than being completed retrospectively.
