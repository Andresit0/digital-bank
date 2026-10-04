# Digital Bank API

REST API built with [NestJS](https://nestjs.com/) that backs the
[digital_bank client](..). It implements JWT
authentication, accounts, movements and a dynamic experience configurable from
the backend, on top of PostgreSQL + TypeORM.

Default port: **3000**. No route prefix (the client consumes `/auth/login`,
`/accounts`, etc.).

---

## Architecture

```text
                ┌─────────────────────┐
                │      Flutter        │
                └──────────┬──────────┘
                           │ HTTP (Dio)
                           ▼
                ┌─────────────────────┐
                │     NestJS API      │
                ├─────────────────────┤
                │ Auth                │
                │ Accounts            │
                │ Movements           │
                │ Experience          │
                └──────────┬──────────┘
                           │ TypeORM
                           ▼
                ┌─────────────────────┐
                │      PostgreSQL     │
                └─────────────────────┘
```

The `Experience` module models dynamic sections (`promotion`, `quick_action`)
stored as `jsonb`, so new sections can be added without changing the API or
republishing the application.

## Endpoints

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/auth/login` | Public | Obtain the JWT (`{ "accessToken": "..." }`) |
| GET | `/auth/me` | JWT (Bearer) | Demonstrate real authentication (JwtStrategy + UserRoleGuard) |
| GET | `/accounts` | JWT (Bearer) | List accounts and available balances |
| GET | `/accounts/:accountId/movements` | JWT (Bearer) | List the movements of an account |
| GET | `/experience/home` | JWT (Bearer) | Get the dynamic experience definition |
| PUT | `/experience/home` | JWT (Bearer) | Update the experience (dynamic demo) |
| GET | `/seed/createExamples` | Dev only | Reload the example dataset (reset + reload) |

Example contracts:

```jsonc
// POST /auth/login  ->  200
{ "accessToken": "<jwt>" }

// GET /accounts  ->  200
[
  { "id": "acc-1", "type": "savings", "displayName": "Savings Account", "maskedNumber": "****1234", "availableBalance": 1500.5 },
  { "id": "acc-2", "type": "checking", "displayName": "Checking Account", "maskedNumber": "****5678", "availableBalance": 20.0 }
]

// GET /accounts/acc-1/movements  ->  200
[
  { "id": "mov-1", "accountId": "acc-1", "type": "credit", "amount": 500.0, "currency": "USD", "description": "Salary", "occurredAt": "2026-10-01T09:30:00.000Z" }
]

// GET /experience/home  ->  200
{
  "experience": "account_home",
  "version": 1,
  "sections": [
    { "type": "promotion", "title": "Save more this month", "description": "Discover our latest promotion" },
    { "type": "quick_action", "label": "View movements", "action": "view_movements" }
  ]
}
```

### Error codes

- `400` invalid payload (validation with `class-validator`).
- `401` invalid credentials or missing/invalid token.
- `403` authenticated without enough role/permission (reserved; does not apply
  to a non-existing account).
- `404` non-existing account in `/accounts/:accountId/movements`.
- `5xx` unexpected error.

Every error responds with `{ statusCode, message, error }`. The Flutter client
only relies on the status code.

---

## Example seed (development)

The seed loads an example dataset (`initialData`, same pattern as the reference
`api` repository) with **reset + reload**: when executed it deletes the existing
examples and re-inserts them, leaving the database in a known state.

| Field | Value |
|---|---|
| email | `customer@example.com` |
| password | `secret` |

Dataset (`src/seed/data/seed-data.ts`):

- **Accounts (3)**: `acc-1` savings 1500.50, `acc-2` checking 20.00,
  `acc-3` savings 4200.00 (no movements, to exercise the empty list).
- **Movements (8)**: 5 in `acc-1` (salary, card purchase, utility bill,
  transfer received, ATM withdrawal) and 3 in `acc-2` (payroll, rent, streaming).
- **Experience**: `account_home` v1 with one `promotion` and two `quick_action`
  (`view_movements`, `view_accounts`).

How it is loaded:

- **Automatically on startup** (`OnModuleInit`) only outside production.
  `SEED_ON_START=false` disables it.
- **Manually**: `GET /seed/createExamples` (development only; `404` in
  production) reloads the examples on demand.

The seed is decoupled into per-domain services under `src/seed/seed_service/`
(`user`, `account`, `movement`, `experience`) orchestrated by
`SeedRunnerService`.

---

## Running with Docker (recommended)

Build the API image (multi-stage build, `npm ci` + `nest build`):

```bash
docker build -t digital-bank-api:latest .
```

Bring up the full stack (API + PostgreSQL). Compose builds the API image from
the current directory:

```bash
docker compose up --build
```

It brings up PostgreSQL (with the `digital_bank` database and `digital_bank_test`
for tests) and the API at `http://localhost:3000`. The API waits until Postgres
is healthy (`pg_isready`).

Stop it:

```bash
docker compose down          # keeps data
docker compose down -v       # WARNING: removes the Postgres volume (data loss)
```

## Running locally

Requirements: Node 20+, PostgreSQL 16.

```bash
cp .env.example .env
npm install
npm run start:dev
```

Swagger (only outside production): `http://localhost:3000/docs`.

---

## Flutter integration

The client receives the base URL through `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

> Integration note: every data endpoint (`/accounts`, `/movements`,
> `/experience/home`, `/experience/home` PUT and `/auth/me`) requires a valid
> `Authorization: Bearer <token>` obtained from `POST /auth/login`. The Flutter
> client must attach the access token to each request (for example, through a Dio
> interceptor) or it will receive `401`. The token is issued by `POST /auth/login`
> and validated by `JwtStrategy` + `UserRoleGuard`.

---

## Tests

Tests are separated by level (suites using mocks are not called E2E):

```bash
npm test                 # Unit: services with mocked repositories
npm run test:integration # Integration: HTTP -> Controller -> Service -> PostgreSQL
npm run test:e2e         # Critical E2E: HTTP -> Nest -> Auth -> Service -> PostgreSQL
```

`test:integration` and `test:e2e` require PostgreSQL with the
`digital_bank_test` database (created by the `postgres` container in compose).
Just bringing up the database is enough:

```bash
docker compose up -d postgres
```

The critical E2E goes through: `POST /auth/login` → JWT → `GET /auth/me` →
authenticated user, against a real PostgreSQL.

---

## Environment variables

| Variable | Description | Default |
|---|---|---|
| `STAGE` | `dev` / `production`. Controls Swagger, `synchronize` and the seed | `dev` |
| `PORT` | HTTP port | `3000` |
| `DB_HOST` / `DB_PORT` | PostgreSQL host/port | `localhost` / `5432` |
| `DB_NAME` | Database name | `digital_bank` |
| `DB_USERNAME` / `DB_PASSWORD` | Database credentials | `postgres` / `postgres` |
| `DB_SSL` | `true` for TLS connections | `false` |
| `JWT_SECRET` | JWT signing secret | `llaveSecretaDigitalBank` |
| `JWT_EXPIRES_IN` | Token expiration | `2h` |
| `SEED_ON_START` | Run the seed on startup (dev) | `true` |

---

## Design decisions (MVP)

- **`double precision`** for amounts: keeps the JSON as a number (what the
  client expects) and avoids `numeric` being serialized as a string. This is a
  conscious demo simplification; a production banking system should use a more
  rigorous money strategy (e.g. `numeric`/decimal plus explicit handling of
  currency and minor units).
- **`synchronize` conditioned by `STAGE`**: enabled outside production for
  immediate reproducibility; in production the schema is managed with
  migrations.
- **Example seed, dev only**: `GET /seed/createExamples` resets and reloads and
  responds `404` outside `dev`; the startup seed is skipped in production.
- **JWT with `bcryptjs`**: mirrors the pattern of the reference `api` repository
  (`@nestjs/jwt` + `passport-jwt`, `JwtStrategy`, `@Auth()` with roles).
  `bcryptjs` avoids native compilation, which keeps the Docker build
  reproducible on Alpine.
- **`404` vs `403`**: a non-existing account is a missing resource → `404`.
  `403` is reserved for "authenticated without permission".

## Structure

```text
src/
  auth/         # login, JWT, strategy, guards, decorators, User entity
  accounts/     # GET /accounts
  movements/    # GET /accounts/:accountId/movements
  experience/   # GET/PUT /experience/home (dynamic sections)
  seed/         # example dataset, per-domain services and runner (dev only)
  common/       # Swagger decorators and global exception filter
test/
  e2e/          # Critical E2E (real PostgreSQL)
  integration/  # per-module integration (real PostgreSQL)
  support/      # test app bootstrap
```

## Scripts

| Script | Action |
|---|---|
| `npm run start:dev` | Development with watch |
| `npm run build` | Compile to `dist/` |
| `npm run start:prod` | Run `dist/main` |
| `npm run lint` | ESLint with `--fix` |
| `npm test` | Unit tests |
| `npm run test:integration` | Integration tests |
| `npm run test:e2e` | Critical E2E |
