# TODO — frontend/ (Flutter, Android first)

Markers: `[ ]` todo · `[~]` doing · `[x]` done · `[!]` blocked · `[-]` dropped. Add the date when done.
"Needs" = backend task that must exist (or use `USE_MOCK=true` fixtures until it does). Order across both sides: `../ROADMAP.md`.

| Phase | Tasks | Done |
| --- | --- | --- |
| 0 Foundation | 12 | 12 |
| 1 Auth and onboarding | 6 | 6 |
| 2 Profile and verification | 7 | 7 |
| 3 Wallet, notifications, support | 7 | 0 |
| 4 Load Provider | 10 | 0 |
| 5 Driver | 12 | 0 |
| 6 Ratings and Trust Score | 3 | 0 |
| 7 Farmer Network | 4 | 0 |
| 8 Organization | 5 | 0 |
| 9 Receiver | 3 | 0 |
| 10 Release | 8 | 0 |
| 11 Later: Flutter web + Admin | 3 | 0 |

## Phase 0 — Foundation
- [x] **A-001** Verify the existing Flutter project (Dart 3, Android minSdk 23+, package name `in.tranix.app` or chosen id); update CLAUDE.md if different. (2026-11-21) — app id `in.tranix.app` (+ `.dev` for the dev flavor), minSdk ≥ 23
- [x] **A-002** Add packages from CLAUDE.md §4; analysis_options with flutter_lints. (2026-11-21)
- [x] **A-003** Folder structure from CLAUDE.md §5 with empty feature folders. (2026-11-21)
- [x] **A-004** Env config via `--dart-define` (API_BASE_URL, USE_MOCK, ENV); flavors dev/prod. (2026-11-21) — Gradle flavors dev (default via pubspec `default-flavor`) / prod; dev allows http to 10.0.2.2
- [x] **A-005** Theme (Material 3 tokens from ui-guidelines) + shared widgets skeletons. (2026-11-21)
- [x] **A-006** Localisation: ARB en/ta/hi, `flutter gen-l10n`, language provider. (2026-11-21)
- [x] **A-007** Dio provider + interceptors (language, auth, refresh single-flight, error → AppException, mock). (2026-11-21)
- [x] **A-008** `shared/models`: all enums + DTOs from `api-contract.md` (freezed/json) with unknown-enum fallback; unit tests for parsing. (2026-11-21)
- [x] **A-009** Error code → localised message map; `ErrorState`, `OfflineBanner` (connectivity_plus). (2026-11-21)
- [x] **A-010** go_router with role shells and redirects; route constants. (2026-11-21) — tabs are placeholders; LP/FN home lists ongoing loads (mock)
- [x] **A-011** Mock fixtures in `assets/mock/` for auth, me, wallet, loads, suggestions. (2026-11-21)
- [x] **A-012** CI: GitHub Actions running `flutter analyze` and `flutter test`. (2026-11-21)

## Phase 1 — Auth and onboarding (needs B-102…B-106)
- [x] **A-101** Splash (S-01) with refresh + `GET /me` routing. (2026-11-21)
- [x] **A-102** Welcome + language (S-02). (2026-11-21)
- [x] **A-103** Sign up pages + OTP input with SMS autofill (S-03). (2026-11-21)
- [x] **A-104** Sign in + OTP (S-04); lockout message. (2026-11-21)
- [x] **A-105** Secure token storage, deviceId, sign-out. (2026-11-21)
- [x] **A-106** Widget tests for sign-up/sign-in validation. (2026-11-21)

## Phase 2 — Profile and verification (needs B-108…B-111, B-201…B-206)
- [x] **A-201** Profile screen (S-05) with completion ring and common fields. (2026-11-21)
- [x] **A-202** File/photo pick, compress, upload (`POST /files`) with progress. (2026-11-21)
- [x] **A-203** Documents (ID proof options; Aadhaar option hidden until enabled by settings) + role-profile sections. (2026-11-21)
- [x] **A-204** Submit for verification; verification status screen (S-06). (2026-11-21)
- [x] **A-205** Profile pop-up sheet (S-07). (2026-11-21)
- [x] **A-206** "Complete verification" blocking sheet reused across features. (2026-11-21)
- [x] **A-207** Change mobile with OTP. (2026-11-21)

## Phase 3 — Wallet, notifications, support (needs B-301…B-304, B-1101…B-1104)
- [ ] **A-301** Wallet screen (S-08) + transactions with filters.
- [ ] **A-302** Top-up via external browser link; refresh on resume.
- [ ] **A-303** FCM setup, token registration, foreground notifications, tap routing.
- [ ] **A-304** Notifications screen with tabs (S-09) + home cards.
- [ ] **A-305** Support new ticket, list, thread, reopen (S-10).
- [ ] **A-306** Home cards: latest Tranix message and trip update.
- [ ] **A-307** Low-balance and verification banners on homes.

## Phase 4 — Load Provider (needs B-401…B-409, B-702, B-801)
- [ ] **A-401** LP home (LP-01).
- [ ] **A-402** Post a load form with map pin picker and estimate (LP-02).
- [ ] **A-403** Review + post; insufficient balance / not verified sheets keeping form data.
- [ ] **A-404** Tracking list + load detail with timeline, live map polling, driver block, call (LP-03/04).
- [ ] **A-405** Amount request card confirm/reject; pickup OTP card.
- [ ] **A-406** Edit (not accepted), cancel with rule preview, repost.
- [ ] **A-407** History (LP-05) and payment mark-paid (LP-06).
- [ ] **A-408** Wish list screen with "From my trips" and "Find organization" tabs, notes, remove, limit (LP-07) — needs B-651, B-652.
- [ ] **A-409** "Offer to" section in post-a-load with entry selection; `WISHLIST_EMPTY` handling — needs B-653.
- [ ] **A-410** Wish-list status banner and **Open to everyone** on load detail; "Add to wish list" from history — needs B-654.

## Phase 5 — Driver (needs B-501…B-505, B-601…B-711, B-802)
- [ ] **A-501** Driver home with duty switch, invitation banner (DR-01).
- [ ] **A-502** Driver profile: licence, selfie, own truck form, Org invitation accept/reject, Locker (DR-02).
- [ ] **A-503** Suggestions list with sort, polling, accept (LOAD_TAKEN handling), reject reasons (DR-03).
- [ ] **A-504** Location permission explainer + Android foreground service + background location.
- [ ] **A-505** Offline location queue + batch upload.
- [ ] **A-506** Current trip screen with status-driven step button (DR-04).
- [ ] **A-507** Map with markers, Navigate intent, layer chips (route services, restrictions).
- [ ] **A-508** Reached flow with outside-radius reason; OTP sheet with resend and help (DR-05).
- [ ] **A-509** Amount revision request (x of 5, pending state) and cancel before pickup.
- [ ] **A-510** History with earnings summary; payment confirm/dispute (DR-06).
- [ ] **A-511** Widget tests: accept race, OTP sheet, step button per status.
- [ ] **A-512** "Preferred by this shipper" tag on suggestions and preferred-load push routing — needs B-655.

## Phase 6 — Ratings and Trust Score (needs B-803…B-805)
- [ ] **A-601** Rating pop-up on app open with Later once (S-11).
- [ ] **A-602** Trust Score screen with events (S-12).
- [ ] **A-603** Trust Score badges on cards (suggestions, driver block).

## Phase 7 — Farmer Network (needs B-110, B-901…B-904)
- [ ] **A-701** FN registration form with per-type ID validation (FN-01).
- [ ] **A-702** Farmers list/add/edit (FN-02).
- [ ] **A-703** Post for a farmer (FN-03) + "Posted for" and farmer filter.
- [ ] **A-704** FN bottom navigation and home.

## Phase 8 — Organization (needs B-502…B-508)
- [ ] **A-801** Org dashboard (OR-01) incl. "Shippers who prefer you".
- [ ] **A-802** Trucks list/detail/add/documents/track (OR-02).
- [ ] **A-803** Drivers add/list/performance (OR-03).
- [ ] **A-804** Allocation flows with conflict handling (OR-04).
- [ ] **A-805** Trips by driver/truck + CSV export link (OR-05).

## Phase 9 — Receiver (needs B-1004)
- [ ] **A-901** Receiver incoming loads (RC-01).
- [ ] **A-902** Load detail with delivery OTP card, receipt upload, mark paid, rating (RC-02).
- [ ] **A-903** Receiver navigation and notifications.

## Phase 10 — Release
- [ ] **A-1001** App icon, splash, app name in 3 languages.
- [ ] **A-1002** Permissions copy and privacy disclosures (location, camera, notifications) for Play Console.
- [ ] **A-1003** Crash reporting (Firebase Crashlytics) and basic analytics events.
- [ ] **A-1004** Performance pass on low-end device (startup, map screens, list scrolling).
- [ ] **A-1005** Tamil/Hindi layout review; font scaling 1.3×.
- [ ] **A-1006** Integration tests: shipper and driver happy paths against dev backend.
- [ ] **A-1007** Signed release build (AAB), Play internal testing track.
- [ ] **A-1008** Confirm no in-app purchase code paths (D-13).

## Phase 11 — Later: Flutter web + Admin
- [ ] **A-1101** Make shared code web-safe; web build for shipper and Organization.
- [ ] **A-1102** Admin panel routes (`/admin/**`) using admin API.
- [ ] **A-1103** Web deployment.
