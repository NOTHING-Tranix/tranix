# CLAUDE.md — frontend/ (Flutter)

> Also read the root `../CLAUDE.md` (project-wide rules and workflow). This file adds Flutter-specific rules.

Read this at the start of every session and follow it exactly.

## 1. Project

Flutter app for **Tranix**, a verified road-freight platform for India. **Android first** for all roles (Load Provider, Farmer Network, Driver, Organization, Receiver). Flutter **web** (shipper/Organization web + Admin panel) comes later from this same codebase — keep code web-compatible where it costs nothing (no `dart:io` in shared code, platform checks behind services).
Backend: `../backend/` (Spring Boot) — the app talks to it only through `../docs/api-contract.md`.

## 2. Source of truth — read before coding

| File | Use |
| --- | --- |
| `../docs/product-spec.md` | Business rules. **Authoritative.** |
| `../docs/api-contract.md` | Endpoints, payloads, enums, error codes. **Must match the backend exactly** |
| `docs/screens.md` | Every screen: route, data, actions, API calls, states |
| `docs/architecture.md` | Folder structure, Riverpod patterns, networking, storage, location, push |
| `docs/ui-guidelines.md` | Theme, components, languages, accessibility |
| `../docs/decisions.md` / `../docs/open-questions.md` | Final decisions / undecided items with defaults |
| `TODO.md` · `../docs/progress-log.md` | Frontend tasks · session log (whole project) |

Precedence: `decisions.md` > `product-spec.md` > `api-contract.md` > `screens.md` > code. **Never invent business rules or endpoints.** If the contract lacks something, update `../docs/api-contract.md` first and add the backend task to `../backend/TODO.md` (or ask).

## 3. Hard rules

1. Never compute business outcomes on the phone (charges, eligibility, Trust Score, status changes). The app shows what the server returns and sends user intent.
2. Show exact pickup/drop locations, names and phone numbers to drivers **only from `current-trip`** (after acceptance). Suggestion cards show area/district only.
3. Never display or store a full Aadhaar number. Show last 4 only.
4. Tokens only in `flutter_secure_storage`. Never log tokens, OTPs or phone numbers.
5. Wallet top-up opens the server link in the external browser (`url_launcher`, `LaunchMode.externalApplication`). **No in-app purchase** (D-13).
6. Every user-visible string is localised (en, ta, hi) via ARB files — no hard-coded text in widgets.
7. Every screen handles loading, empty, error (with retry) and offline states.
8. Map error codes from the contract to localised messages in one place (`core/errors`).
9. Driver location upload only during an active trip, with clear permission explanation; buffer offline and upload in batches.
10. Values like charges, OTP timers, revision limit and dropdown lists come from `GET /settings/public` — never hard-coded.

## 4. Stack (D-16)

Flutter stable (Dart 3) · flutter_riverpod + riverpod_annotation/generator · go_router · dio (+ interceptors) · freezed + json_serializable · flutter_secure_storage · shared_preferences (non-secret prefs) · firebase_core + firebase_messaging + flutter_local_notifications · google_maps_flutter · geolocator + a background-location solution (foreground service on Android) · url_launcher · image_picker + file_picker · intl + flutter_localizations (ARB) · connectivity_plus · cached_network_image · mocktail + flutter_test (+ integration_test).

## 5. Folder structure (feature-first)

```
lib/
├── main.dart, app.dart               # ProviderScope, MaterialApp.router, theme, l10n
├── core/                             # config (env), router, theme, l10n, network (dio, interceptors), errors,
│                                     # storage, location, push, widgets (shared UI), utils (formatters, validators)
├── shared/models/                    # enums + DTOs from the API contract (freezed)
└── features/
    ├── auth/  onboarding/  profile/  verification/  wallet/  notifications/  support/  ratings/  trust_score/
    ├── shipper/      # Load Provider + Farmer Network: post load, wish list, tracking, history, payment
    ├── farmers/      # Farmer Network only
    ├── driver/       # home, suggestions, current trip, history, truck, invitations, locker, map layers
    ├── organization/ # dashboard, trucks, drivers, allocation, trips
    └── receiver/
       each feature: data/ (api + repository) · application/ (providers, controllers) · presentation/ (screens, widgets)
```

## 6. Conventions

- Riverpod: repositories as providers; `AsyncNotifier` controllers for screens; no business logic in widgets.
- Models: freezed, `fromJson` generated; enums with `@JsonValue` matching the contract exactly; unknown enum → fallback value, never crash.
- Routes: named constants in `core/router/routes.dart`; role-based redirect after sign-in; deep links from notifications use the same routes.
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`.
- Formatting: `dart format .`; lints: `flutter analyze` must be clean.
- Tests: unit tests for repositories/controllers (mock dio), widget tests for key screens, golden tests optional.
- Commit message: `feat(<feature>): A-xxx <title>`.

## 7. Workflow for Claude

1. Start: read `TODO.md` and the latest `../docs/progress-log.md` entry.
2. Pick the task the user names, or the first `[ ]` whose dependencies are done (check that backend endpoints exist or use the mock API). Mark `[~]`.
3. For non-trivial tasks show a plan (files, providers, routes, API calls, tests) and wait for approval.
4. Implement; `flutter analyze` clean and `flutter test` green.
5. Mark `[x] (YYYY-MM-DD)`, update counts, add a line to `../docs/progress-log.md`, commit.
6. Blocked → `[!]` with reason (e.g. "backend B-605 not ready").

**Mock API:** until an endpoint exists, use `MockInterceptor` fixtures (`assets/mock/*.json`) behind `--dart-define=USE_MOCK=true`. Fixtures must follow the contract exactly.

## 8. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1      # Android emulator → local backend
flutter run --dart-define=USE_MOCK=true
flutter analyze && flutter test
```
