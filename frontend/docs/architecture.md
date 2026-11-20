# App Architecture

## Layers per feature

```
presentation/  Screens + widgets. Read providers, call controller methods. No dio, no JSON.
application/   Riverpod controllers (AsyncNotifier / Notifier) and derived providers. Orchestrate repositories.
data/          <Feature>Api (dio calls, one method per endpoint) + <Feature>Repository (maps DTOs, caching).
```
Shared DTOs/enums live in `lib/shared/models/` and mirror `../docs/api-contract.md` 1:1.

## Networking

- One `Dio` provider with `baseUrl` from `--dart-define=API_BASE_URL`.
- Interceptors (in order): `LanguageInterceptor` (`Accept-Language`), `AuthInterceptor` (adds access token), `RefreshInterceptor` (on 401 `TOKEN_EXPIRED`: single-flight `POST /auth/refresh`, retry once; on failure → sign out and go to sign-in), `ErrorInterceptor` (maps Problem JSON → `AppException(code, message, fields)`), `MockInterceptor` (only when `USE_MOCK=true`).
- Timeouts: connect 10 s, receive 20 s. Uploads via multipart with progress.
- `core/errors/error_messages.dart` maps every contract `code` to a localised message; field errors shown under form fields.

## Auth and session

- `SessionController` (Riverpod) holds `Me` + tokens; persists tokens in `flutter_secure_storage`.
- App start: splash reads tokens → `POST /auth/refresh` → `GET /me` → route by role and `verificationStatus`.
- `deviceId` generated once (UUID) and stored; sent at sign-in.
- Sign-out clears tokens, FCM token registration, caches.

## Routing (go_router)

- Top-level redirect: not signed in → `/welcome`; signed in → role shell (`/lp`, `/fn`, `/driver`, `/org`, `/receiver`).
- Each role shell is a `StatefulShellRoute` with a bottom navigation bar (see `screens.md`).
- Unverified users can open their role shell; actions that need `VERIFIED` show a "Complete verification" sheet (server still enforces `NOT_VERIFIED`).
- Deep links (`tranix://load/{id}`, notification payload `route`) resolve to the same routes.

## Polling and push

- FCM: register token after sign-in (`POST /me/devices`); foreground messages shown with `flutter_local_notifications`; tap → route from payload; refresh relevant providers.
- Polling only while a screen is visible (`ref.onDispose` cancels timers): suggestions 30 s, load tracking 30 s, current trip 30 s, ticket thread 30 s. Pause when app is in background.

## Location (driver)

- Ask permission with an explanation screen before the first trip; Android needs foreground service notification "Tranix trip in progress".
- During an active trip: capture every 30 s (or 200 m), store in a local queue (shared_preferences/sqflite), upload batches to `POST /driver/trips/{id}/locations`; retry on connectivity change.
- `Reached` and `OTP verify` send current lat/lng; if the server reports `outsideRadius`, ask for a reason and resend.

## Maps

- `google_maps_flutter` for in-app markers (current, pickup, drop) and polyline if provided.
- **Navigate** button: open Google Maps app with `google.navigation:q=<lat>,<lng>&mode=d` (fallback to `https://www.google.com/maps/dir/?api=1&destination=<lat>,<lng>`).
- Map layers (route services, restrictions) fetched by visible bounding box; toggle chips.

## Files and images

- `image_picker` (camera/gallery) and `file_picker` (PDF). Compress images to ≤ 1600 px, JPEG 80%. Upload with `POST /files`, then send `fileIds`.
- Never cache document images to public storage; view via signed URL.

## Localisation

- ARB files `lib/core/l10n/app_en.arb`, `app_ta.arb`, `app_hi.arb`; `flutter gen-l10n`.
- Language chosen at first open and in profile; stored locally and sent to `PUT /me`.
- Numbers/currency via `intl` (`₹1,000`), dates in `dd MMM yyyy, h:mm a` local time.

## Environments

`--dart-define` keys: `API_BASE_URL`, `USE_MOCK`, `ENV` (dev/staging/prod), `MAPS_API_KEY` (Android manifest via Gradle placeholder). Firebase config per flavor (`google-services.json` not committed for prod).

## Testing

- Unit: repositories with mocked dio; controllers with `ProviderContainer` overrides.
- Widget: sign-in, post load form validation, suggestion accept (LOAD_TAKEN), OTP entry, wallet.
- Integration (later): full shipper and driver happy path against the dev backend.
