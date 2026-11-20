# CLAUDE.md — backend/ (Spring Boot)

> Also read the root `../CLAUDE.md` (project-wide rules and workflow). This file adds backend-specific rules.

Read this at the start of every session and follow it exactly.

## 1. Project

Backend (REST API, scheduled jobs, two server-rendered public pages) for **Tranix**, a verified road-freight platform for India.
Clients: the Flutter Android app in `../frontend/` now; Flutter web (shipper/Organization web + Admin panel) later.

## 2. Source of truth — read before coding

| File | Use |
| --- | --- |
| `../docs/product-spec.md` | Business rules. **Authoritative.** |
| `../docs/api-contract.md` | Endpoints, payloads, enums, error codes. Shared with the app — **must match exactly** |
| `../docs/decisions.md` | Final decisions. Never contradict; propose a new decision instead |
| `../docs/open-questions.md` | Undecided items and their safe defaults |
| `docs/domain-model.md` | Tables, status machines, invariants (backend only) |
| `TODO.md` | Backend task list and status |
| `../docs/progress-log.md` | One entry per session (whole project) |

Precedence: `decisions.md` > `product-spec.md` > `api-contract.md` > `domain-model.md` > code.
**Never invent business rules.** If something is missing, ask the founder and record the answer.
**Changing the API contract:** edit `../docs/api-contract.md` first, then the backend code, and add a frontend task in `../frontend/TODO.md` if the app must change. Log it under "Contract changes".

## 3. Hard rules

1. Nothing business-critical works until the account is `VERIFIED` (post, accept, allocate).
2. **First accept wins:** acceptance is one atomic DB operation (`UPDATE loads SET status='ACCEPTED', driver_id=? ... WHERE id=? AND status='NOT_ACCEPTED'` → 0 rows = `LOAD_TAKEN`). Charges deducted in the same transaction.
3. **Wallet = append-only ledger.** Balance = sum of entries (cached balance updated in the same transaction with row lock). Never edit or delete entries.
4. Top-up credits only after a **signature-verified, idempotent** gateway webhook.
5. **Amount revision:** max 5 per trip, one pending at a time, only before `PICKED_UP`, 15-min expiry job; rejection/expiry never cancels the trip.
6. **OTP:** 6 digits, hashed at rest, 5 min, 5 attempts, resend invalidates old; correct OTP > 500 m from pin is accepted and creates a location exception with the driver's reason. Delivery OTP is never returned by public link endpoints.
7. Exact pickup/drop pins, names and phone numbers are returned to a driver **only after acceptance**; suggestions expose area/district only.
8. **Aadhaar:** never store the full number or image; store last 4 + verification result only.
9. Every Trust Score change is a ledger event with reason; score clamped 0–100.
10. Timers run on the server (suggestion batches every 10 min, revision expiry, OTP expiry, document expiry, route status), never on the phone.
11. All tunable values live in the `settings` table (charges, weights, radius, limits, points), never hard-coded.
12. Every admin action is written to the audit log with a reason where required.
13. **Wish list:** wish-list entries never bypass eligibility; `WISHLIST_FIRST` window and `WISHLIST_ONLY` notify time are server jobs; truck entries only from the shipper's own past trips.
14. No secrets in git. No personal data (mobile, OTP, names) in logs — mask them.

## 4. Stack

Java 21 · Spring Boot 3.x · Maven wrapper · PostgreSQL 16 + Flyway · Spring Security + JWT (access 15 min, refresh 30 days rotated) · Spring Data JPA · Bean Validation · springdoc-openapi · Thymeleaf (only for `/p/**` public pages) · Spring Modulith (module boundary tests) · JUnit 5, Mockito, Testcontainers · Docker / docker-compose · AWS later.
Outside services behind interfaces, **fake implementations first** (selected by profile/property): `SmsSender`, `PushSender` (FCM), `MapsService`, `PaymentGateway`, `FileStorage` (local disk → S3), `AadhaarVerifier`.

## 5. Modules (package `com.tranix`; adjust if the project uses another base package)

```
com.tranix
├── shared        ids, Money, GeoPoint + Haversine, Clock, ProblemDetail errors, audit base, settings access
├── identity      users, roles, OTP, JWT, devices, profile, role profiles, documents, verification, Aadhaar adapter
├── fleet         trucks, organization drivers, invitations, allocations, driver duty
├── farmers       Farmer Network farmers
├── loads         posting, estimate, edit, cancel, repost, timeline, public tracking tokens
├── matching      eligibility, ranking, suggestion batches, accept/reject (atomic), wish list + audience windows
├── trips         amount revisions, reached/OTP, location exceptions, OTP help, locations, ETA, route status
├── wallet        ledger, charges, top-up links, gateway webhook, statements
├── payments      freight payment records (mark paid, confirm, dispute)
├── trust         trust events, score, ratings, pending ratings
├── engagement    notifications (FCM + inbox), broadcasts, support tickets
├── admin         admin endpoints, verification queue, decisions, audit log, dashboard, settings
└── web           Thymeleaf public pages: /p/track/{token}, /p/wallet/topup
```
Each module: `api/` (public service interfaces + DTOs), `internal/` (entities, repositories, services), `web/` (controllers). Modules use each other only via `api/` or Spring application events. Table names prefixed by module (`loads_load`, `wallet_entry`).

## 6. Conventions

- REST under `/api/v1`, admin under `/api/v1/admin`, public JSON under `/api/v1/public`, pages under `/p`.
- DTOs are Java records; never return entities. Validate with Jakarta Validation; errors as RFC 7807 with `code` (see contract).
- Money: `long amountInr`. Time: `Instant`/`timestamptz` UTC; inject `Clock`.
- Status changes only through one domain method per aggregate that checks allowed transitions and writes a timeline row.
- Every new table/column = new Flyway migration `V<n>__<desc>.sql`; never edit an applied migration.
- Tests with every feature: unit tests for rules; Testcontainers integration tests for repositories and controllers; concurrency test for acceptance and wallet.
- Commit message: `feat(<module>): B-xxx <title>`.

## 7. Workflow for Claude

1. Start: read `TODO.md` and the latest `../docs/progress-log.md` entry.
2. Pick the task the user names, or the first `[ ]` whose dependencies are done. Mark `[~]`.
3. For anything non-trivial, show a plan (migrations, entities, endpoints, tests) and wait for approval.
4. Implement in small steps. `./mvnw verify` must pass.
5. Mark `[x] (YYYY-MM-DD)`, update the phase count, add a line to `../docs/progress-log.md`, commit.
6. Blocked by an open question → mark `[!]`, note the question ID, tell the user.

Status markers: `[ ]` todo · `[~]` doing · `[x]` done · `[!]` blocked · `[-]` dropped.

## 8. Commands

```bash
docker compose up -d                 # PostgreSQL
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
./mvnw verify                        # must pass before a task is done
```
Dev profile: fake SMS logs OTPs and accepts `123456`; fake gateway has `POST /dev/payments/{orderId}/succeed`; seed data via `dev` Flyway location.
