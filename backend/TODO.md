# TODO — backend/ (Spring Boot)

Markers: `[ ]` todo · `[~]` doing · `[x]` done · `[!]` blocked · `[-]` dropped. Add the date when done: `[x] B-001 … (2026-11-25)`.
The app team needs endpoints in this order: **Phase 1 → 2 → 3 → 4** unblock the first app screens. See `../ROADMAP.md` for the order across backend and frontend.

| Phase | Tasks | Done |
| --- | --- | --- |
| 0 Foundation | 10 | 10 |
| 1 Auth and profile | 12 | 12 |
| 2 Verification and documents | 8 | 7 |
| 3 Wallet | 8 | 8 |
| 4 Loads (shipper) | 9 | 0 |
| 5 Fleet and driver setup | 9 | 0 |
| 6 Matching and acceptance | 7 | 0 |
| 6A Wish list | 6 | 0 |
| 7 Trip execution | 11 | 0 |
| 8 Payments, ratings, Trust Score | 8 | 0 |
| 9 Farmer Network | 4 | 0 |
| 10 Receiver and public pages | 6 | 0 |
| 11 Notifications and support | 7 | 2 |
| 12 Admin API | 12 | 0 |
| 13 Real integrations | 7 | 0 |
| 14 Hardening and release | 8 | 0 |

## Phase 0 — Foundation
- [x] **B-001** Verify the existing Spring Boot project against CLAUDE.md (Java 21, Boot 3, base package, Maven wrapper); fix differences or update CLAUDE.md. (2026-11-21)
- [x] **B-002** Dependencies: web, validation, security, data-jpa, postgresql, flyway, actuator, springdoc-openapi, thymeleaf, spring-modulith, testcontainers, jjwt (or spring-security-oauth2-resource-server for JWT). (2026-11-21)
- [x] **B-003** `docker-compose.yml` (PostgreSQL 16); profiles `dev`, `test`, `prod`; `application-local.yml` git-ignored. (2026-11-21)
- [x] **B-004** Module packages from CLAUDE.md §5 + Spring Modulith verification test. (2026-11-21)
- [x] **B-005** `shared`: base entity (UUID, timestamps, version), `Clock` bean, `GeoPoint` + Haversine util with tests, ProblemDetail handler with error codes from the contract. (2026-11-21)
- [x] **B-006** `admin_setting` table + `SettingsService` (typed getters, cache) seeded with all defaults from product spec (incl. wish-list settings); `GET /settings/public`. (2026-11-21)
- [x] **B-007** Fake adapters: `SmsSender`, `PushSender`, `MapsService`, `PaymentGateway`, `FileStorage` (local), `AadhaarVerifier` (disabled). (2026-11-21)
- [x] **B-008** `POST /files` upload (type/size checks, private storage, signed short-lived view URLs). (2026-11-21)
- [x] **B-009** GitHub Actions: `./mvnw verify` with Testcontainers on every push/PR. (2026-11-21)
- [x] **B-010** Swagger UI with JWT "Authorize" button; dev seed data (one user per role, sample trucks). (2026-11-21) — Swagger + JWT Authorize done; `db/dev` seed location ready, rows added with B-101 (users) and B-501 (trucks)

## Phase 1 — Auth and profile
- [x] **B-101** `identity_user`, roles, verification status, profile completion columns. Also add dev seed users (one per role) in `db/dev` (from B-010). (2026-11-21)
- [x] **B-102** OTP service: 6 digits, hashed, 5 min TTL, 5 attempts, 30 s resend cooldown, rate limits; dev code `123456` only in `dev`. (2026-11-21)
- [x] **B-103** `POST /auth/otp/send` (SIGN_UP/SIGN_IN, no enumeration). (2026-11-21)
- [x] **B-104** `POST /auth/sign-up` (mobile, otp, name, role ≠ ADMIN, consent, language). (2026-11-21)
- [x] **B-105** `POST /auth/sign-in` → JWT access (15 min) + refresh (30 days) with device id. (2026-11-21)
- [x] **B-106** `POST /auth/refresh` (rotation, reuse detection) and `/auth/sign-out`. (2026-11-21)
- [x] **B-107** Security config: role-based access, `NOT_VERIFIED` guard annotation/aspect for business actions. (2026-11-21)
- [x] **B-108** `GET/PUT /me`, address, language. (2026-11-21)
- [x] **B-109** Change mobile with OTP (`/me/mobile/change`, `/me/mobile/verify`), audited. (2026-11-21)
- [x] **B-110** `PUT /me/role-profile` for all five roles (validation: CIN/PAN/GSTIN formats, licence). (2026-11-21)
- [x] **B-111** Profile completion calculator per role (weighted items) + `GET /me/verification`. (2026-11-21)
- [x] **B-112** `POST /me/devices` (FCM token). (2026-11-21)

## Phase 2 — Verification and documents
- [x] **B-201** `identity_document` + `POST/PUT/GET /me/documents` with masked numbers and expiry. (2026-11-21)
- [x] **B-202** `POST /me/verification/submit` (only at 100%) → `UNDER_REVIEW`. (2026-11-21)
- [x] **B-203** Admin verification queue by tab + approve/reject per document with reason → user `VERIFIED` / `NOT_VERIFIED`. (2026-11-21)
- [!] **B-204** Aadhaar: `AadhaarVerifier` interface + `POST /me/aadhaar/offline` storing last 4 + result only (real provider in Phase 13, Q-04). (2026-11-21) — endpoint + storage done; real provider needs Q-04 (see founder-review F-3)
- [x] **B-205** Document expiry job: reminders 30/7/1 days; expired → pause matching for driver/truck. (2026-11-21)
- [x] **B-206** Re-upload flow: `PUT /me/documents/{id}` returns user to `UNDER_REVIEW`. (2026-11-21)
- [x] **B-207** Notification events for verification results (consumed in Phase 11). (2026-11-21)
- [x] **B-208** Tests: profile completion per role, guard blocks unverified users. (2026-11-21)

## Phase 3 — Wallet
- [x] **B-301** `wallet_account`, append-only `wallet_entry`, cached balance with row lock. (2026-11-21)
- [x] **B-302** `GET /wallet`, `GET /wallet/transactions` (filters), statement PDF (simple). (2026-11-21)
- [x] **B-303** `POST /wallet/topup-link` → signed token (15 min) → `/p/wallet/topup?t=` page (Thymeleaf) → gateway checkout (fake in dev). (2026-11-21)
- [x] **B-304** `POST /webhooks/payments`: signature check, idempotent by gateway payment id, `TOPUP` entry, push notification. (2026-11-21)
- [x] **B-305** `WalletApi.hasBalance(account, chargeType)` and `WalletApi.charge(...)` (idempotent per load + type). (2026-11-21)
- [x] **B-306** Admin credit/refund with reason (audited). (2026-11-21)
- [x] **B-307** Low-balance notification. (2026-11-21)
- [x] **B-308** Concurrency tests: two charges at once can't overdraw. (2026-11-21)

## Phase 4 — Loads (shipper)
- [ ] **B-401** `loads_load`, `loads_timeline`, load code generator (`TRX-000123`).
- [ ] **B-402** `POST /loads/estimate` via `MapsService` (distance, drive time, ETA with loading buffer; suggested range when history exists).
- [ ] **B-403** `POST /loads` with validation, verified guard, balance check (no deduction), receiver user link if mobile registered.
- [ ] **B-404** `GET /loads?scope=ONGOING|HISTORY` and `GET /loads/{id}` (fields per contract; driver block only after acceptance).
- [ ] **B-405** `PUT /loads/{id}` only `NOT_ACCEPTED`.
- [ ] **B-406** Cancel per rules table (before/after acceptance, charges kept, cancellation case, Trust Score event) + repost.
- [ ] **B-407** Status machine in one domain method with allowed transitions + timeline rows.
- [ ] **B-408** `GET /loads/{id}/otp` for sender/registered receiver while active.
- [ ] **B-409** Tests for transitions and cancellation outcomes.

## Phase 5 — Fleet and driver setup
- [ ] **B-501** `fleet_truck` + owner-driver `POST/PUT /driver/truck` (one truck only) + truck documents. Also add dev seed trucks in `db/dev` (from B-010).
- [ ] **B-502** Org trucks CRUD, deactivate, documents, status.
- [ ] **B-503** Org driver invitation by mobile (SMS) + `GET/POST /driver/invitations/{id}/accept|reject`.
- [ ] **B-504** Allocation create/update/remove with DB unique constraints and `ALLOCATION_CONFLICT`; no change during active trip.
- [ ] **B-505** `PUT /driver/duty`, `GET /driver/home`.
- [ ] **B-506** Org dashboard, drivers list, driver performance.
- [ ] **B-507** Org trips by driver/truck + CSV export.
- [ ] **B-508** `GET /org/trucks/{id}/location`.
- [ ] **B-509** Tests: allocation rules, one-truck rule for owner-drivers.

## Phase 6 — Matching and acceptance
- [ ] **B-601** Eligibility query (see domain model) with Haversine + bounding box.
- [ ] **B-602** Ranking with weights from settings; deterministic tests with fixed clock.
- [ ] **B-603** Batch job: top 5 at posting, +5 every 10 min, radius widening, "no driver" notification to shipper.
- [ ] **B-604** `GET /driver/suggestions` (area-only data, sorting).
- [ ] **B-605** `POST /driver/suggestions/{loadId}/accept`: atomic status update + both charges in one transaction; others → `TAKEN`; notifications; tracking SMS to receiver.
- [ ] **B-606** Reject with reason.
- [ ] **B-607** Concurrency test: 10 drivers accept at once → exactly one wins.

## Phase 6A — Wish list (D-19)
- [ ] **B-651** `matching_wishlist_entry` + `GET/POST/PUT/DELETE /wishlist` (limit, truck only from own past trips, `WISHLIST_FULL`).
- [ ] **B-652** `GET /wishlist/org-search` (verified orgs by name/code) and `GET /wishlist/candidates`.
- [ ] **B-653** Load `audience` + `wishlistEntryIds` on `POST /loads`; `WISHLIST_EMPTY`; `audience` fields in `LoadDetail`.
- [ ] **B-654** Matching: resolve entries → drivers, relaxed radius, ranking bonus (EVERYONE), wish-list-only batches, `WISHLIST_FIRST` switch job, `WISHLIST_ONLY` notify job, `POST /loads/{id}/open-to-everyone`.
- [ ] **B-655** `preferredByShipper` on suggestions, preferred-shipper push to drivers, `preferredByShippersCount` on org dashboard.
- [ ] **B-656** Tests: eligibility still enforced, window switch timing, notify once, open-to-everyone.

## Phase 7 — Trip execution
- [ ] **B-701** `GET /driver/current-trip` with exact details and contacts.
- [ ] **B-702** Amount revision request (limit 5, one pending, before pickup), shipper confirm/reject, 15-min expiry job, notifications, timeline.
- [ ] **B-703** `POST /driver/trips/{id}/reached` (PICKUP/DELIVERY): distance check, status change, OTP generation + SMS + in-app.
- [ ] **B-704** OTP verify: attempts, expiry, location exception > 500 m with reason; PICKED_UP → TRAVELING automatically; DELIVERED.
- [ ] **B-705** OTP resend and "Can't get OTP" help requests.
- [ ] **B-706** Location batch upload, latest position, 90-day purge job.
- [ ] **B-707** ETA recalculation and late detection (notify shipper/receiver); route status NORMAL/SLOW/FAST.
- [ ] **B-708** Driver cancel before pickup (rules, Trust Score).
- [ ] **B-709** `GET /loads/{id}/tracking`.
- [ ] **B-710** Map layers: `GET /map/route-services`, `GET /map/restrictions` (admin data).
- [ ] **B-711** Tests: full trip happy path; OTP failures; revision limits.

## Phase 8 — Payments, ratings, Trust Score
- [ ] **B-801** Payment record created at acceptance (payer from load); mark paid (shipper or receiver).
- [ ] **B-802** Driver confirm / dispute (dispute opens a ticket); trip `closed_at`.
- [ ] **B-803** Pending ratings created at DELIVERED; `GET /ratings/pending`, `POST /ratings`, `/later`.
- [ ] **B-804** Trust events ledger + listeners for all events in the points table; clamp 0–100.
- [ ] **B-805** `GET /trust-score`, `/trust-score/events`.
- [ ] **B-806** Org score from drivers' performance and own cancellations.
- [ ] **B-807** Driver history summary (earnings: agreed, confirmed, pending).
- [ ] **B-808** Tests for score calculations.

## Phase 9 — Farmer Network
- [ ] **B-901** `farmers_farmer` CRUD with consent and Aadhaar last 4 only.
- [ ] **B-902** Post for a farmer (`postedForFarmerId`): farmer is sender, FN wallet pays.
- [ ] **B-903** Farmer receives SMS link (SENDER token) and pickup OTP.
- [ ] **B-904** Filters by farmer in `GET /loads`.

## Phase 10 — Receiver and public pages
- [ ] **B-1001** Tracking tokens (random, audience RECEIVER/SENDER, expire 7 days after delivery).
- [ ] **B-1002** Thymeleaf `/p/track/{token}` (mobile-first, en/ta/hi, polling JSON every 30 s) + `GET /api/v1/public/track/{token}`; expired → 410, no data.
- [ ] **B-1003** Public receipt upload, condition, rating, mark paid.
- [ ] **B-1004** Registered receiver endpoints (`/receiver/loads`) and delivery OTP in app.
- [ ] **B-1005** Shortage/damage auto-opens a ticket.
- [ ] **B-1006** Link page never shows the delivery OTP (test).

## Phase 11 — Notifications and support
- [x] **B-1101** Notification inbox with tabs + `summary` (latest Tranix message, latest trip update). (2026-11-21)
- [x] **B-1102** Event → template (en/ta/hi) → FCM push and/or SMS router. (2026-11-21)
- [ ] **B-1103** Broadcasts (all/role/district/user; scheduled) → inbox + push.
- [ ] **B-1104** Tickets: create, list, detail, messages, reopen within 7 days.
- [ ] **B-1105** Unread reply indicators.
- [ ] **B-1106** Pending-rating reminder notifications.
- [ ] **B-1107** Document expiry and low-balance notifications wired.

## Phase 12 — Admin API (used via Swagger until Flutter web admin)
- [ ] **B-1201** Admin seeding, allow-listed mobiles, 30-min idle timeout.
- [ ] **B-1202** Dashboard metrics (active loads, fleet, pending verifications, open support, freight total, route status, reminders).
- [ ] **B-1203** Active loads (10/page, search) + detail + cancel + OTP override.
- [ ] **B-1204** Active fleet.
- [ ] **B-1205** Verification tabs (driver, vehicle, FN, org, identity).
- [ ] **B-1206** Tickets reply/ignore (reason).
- [ ] **B-1207** Users: search, suspend, reactivate.
- [ ] **B-1208** Wallet credit/refund; cancellations decide; payment disputes decide.
- [ ] **B-1209** Location exceptions review; Trust Score adjust.
- [ ] **B-1210** Settings CRUD with validation (weights sum to 100%).
- [ ] **B-1211** Map restrictions CRUD.
- [ ] **B-1212** Audit log for every admin action + query.

## Phase 13 — Real integrations
- [ ] **B-1301** SMS provider (MSG91, DLT templates en/ta/hi) — Q-03.
- [ ] **B-1302** Payment gateway (Razorpay) checkout + webhook — Q-02.
- [ ] **B-1303** FCM push with service account.
- [ ] **B-1304** Maps (routes, ETA, places) with caching and budget guard — Q-05.
- [ ] **B-1305** S3 storage with signed URLs.
- [ ] **B-1306** Aadhaar offline verification / DigiLocker — Q-04.
- [ ] **B-1307** Per-environment switches fake ↔ real.

## Phase 14 — Hardening and release
- [ ] **B-1401** Rate limits (OTP, sign-in, public tokens).
- [ ] **B-1402** Structured logs with request IDs; PII masking.
- [ ] **B-1403** Actuator health/metrics; alerts.
- [ ] **B-1404** Dockerfile; AWS deploy (RDS PostgreSQL, S3, secrets).
- [ ] **B-1405** Backups and restore test.
- [ ] **B-1406** End-to-end test of the full lifecycle (post → accept → revision → OTPs → delivered → paid → rated).
- [ ] **B-1407** Load test of suggestions and tracking polling.
- [ ] **B-1408** Privacy policy/terms endpoints and data deletion request flow — Q-08.
