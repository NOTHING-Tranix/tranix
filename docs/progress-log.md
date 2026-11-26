# Progress Log (whole project)

Newest first. Claude adds an entry at the end of every session and at every milestone checkpoint.

```
## YYYY-MM-DD — <milestone>
- Done: B-…, A-…
- In progress: … (what is left)
- Blocked: … (Q-…)
- Contract changes: …
- Notes: one or two lines for the next session
```

---

## 2026-11-27 — Complete backend test + B-1611
- Complete backend test (all modules): automated 100/100; BE-1 155/159, BE-2 133/140 + intense 114/123, BE-3 130/132, whole backend 27/32 (151 APIs × 6 roles, 2,623 calls), timers OK. Report: Tranix-Backend-Complete-Test-Report.docx.
- Done: B-1611 — ~10+ simultaneous writes used up the 10 database connections (after-commit listeners opened a 2nd connection) → 30 s stall and 500s. Listeners now run on a background pool; pool 20. Live: 20 credits at once 20/20 (was 12/20).
- Behaviour note: notifications, matching, Trust Score events and automatic tickets now happen a fraction of a second after the request (the app polls, so no visible change).
- Open from the report: busy driver still sees suggestions; 4 small 500s (empty location item, upload without file, errors on CSV/PDF downloads, simultaneous same-mobile sign-up); double ticket reopen; drivers can call the shipper estimate. Founder: repost scope, paid before delivery, Q-11.

## 2026-11-27 — BE-3 testing and fixes
- Tested BE-3 (wallet, payments, trust, fleet, receiver): 22/22 automated tests, 128/132 live checks over 3 real trips (test loads in Port Blair); report BE-3-Test-Report.docx.
- Done: B-1607 (suggestion area could show the exact street address), B-1608 (Organization drivers had an unused own wallet they could top up).
- Then also done: B-1609 (vehicle queue shows truck number, type, owner), B-1610 (idle truck location → `{onTrip:false}`).
- Also done: B-1604 (audit entity names UPPERCASE, case-insensitive filter), B-1605 (admin loads status filter → 400 for unknown), B-1606 (unknown legal page → 404).
- Open: A-1201 (hide Wallet menu item when there is no wallet).
- Question for the founder: may freight be marked paid before delivery (now allowed)?

## 2026-11-26 — BE-1 testing and security fixes
- Tested BE-1 (identity, admin, support, engagement): 43/43 automated tests, 151/159 live API checks; 6 bugs found (report: BE-1-Test-Report.docx).
- Done: B-1601 (rate-limit bypass via X-Forwarded-For), B-1602 (mobiles/OTPs in validation warnings), B-1603 (suspended user's access token kept working up to 15 min).
- Open: B-1604–B-1606 (small: audit entity names, admin loads status filter, legal 404).
- Config: new `TRUSTED_PROXIES` (default localhost = the ngrok agent); in production add the load balancer address.
- Also earlier this week: simple admin website at `/admin`; SMS off by default in `tools/backend-dev.ps1` (`-Sms` turns Twilio on).

## 2026-11-21 — Contract sync fixes (after /sync-check)
- Done: B-1501…B-1503, A-1101.
- Contract: repaired four garbled lines from an M6 text replacement (LoadStatus enum, driver suggestions row, reject reasons, wallet transactions); added TxnDirection and SuggestionRejectReason; new §14 legal + account deletion; documented `X-Request-Id`, rate limits, `X-Razorpay-Signature` and the top-up return page.
- App: Privacy policy / Terms screens (`/legal/:doc`, readable signed out, draft notice), "Delete account" in the profile menu → confirmation → deletion request ticket. Fixed: the profile menu overflowed on small phones (now scrolls) and actions launched from it used the closed sheet's context. analyze clean, 63 tests green, debug APK builds. Backend unchanged.
- Demo (mock): Open as Load Provider → avatar → Privacy policy; avatar → Delete account → reason → the request opens as a support ticket.
- Sync status: contract, backend and app in sync (LINK_EXPIRED is only used by the server-rendered link page).

## 2026-11-21 — M16 Hardening and release (code ready; release steps need the founder)
- Done: B-1401, B-1402, B-1403, B-1406, B-1408, A-1001, A-1002, A-1005, A-1008.
- Backend: per-IP rate limits on auth and public link paths (`429 RATE_LIMITED`); `X-Request-Id` on every request and in logs, JSON (ECS) logs in prod; health liveness/readiness + metrics; Dockerfile (built in CI); `tools/db-backup.sh`, `tools/db-restore.sh`, `tools/loadtest/suggestions-tracking.js`; full-lifecycle E2E test; `GET /legal/privacy|terms` (draft) and `POST /me/deletion-request`. 19 unit + 69 integration tests green.
- Frontend: localised app name (prod flavor), brand splash + placeholder adaptive icon, release signing from `android/key.properties` (prod AAB builds), Tamil/Hindi 1.3× layout test on every tab of every role (fixed: wide trailing buttons, long status chips, notifications app bar, suggestions sort, driver history buttons), no-IAP release check, Play disclosures in `docs/play-console.md`. analyze clean, 61 tests green, debug APK builds.
- Blocked `[!]`: B-1404/B-1405/B-1407 (AWS, F-9), A-1003 (Firebase, F-4), A-1004 (real low-end phone), A-1006 (emulator + dev backend run), A-1007 (upload key + Play Console, F-10).

## 2026-11-21 — M15 Real integrations (adapters ready; blocked on founder keys)
- Done: B-1307 (per-environment switches `tranix.integrations.*`, production config from environment variables).
- Built and unit-tested behind switches (default fake): MSG91 Flow SMS with DLT template ids per key/language (B-1301), Razorpay payment links + HMAC webhook check, `X-Razorpay-Signature` accepted (B-1302), FCM HTTP v1 with a service-account JWT and token cache (B-1303), Google Routes with 24 h cache and monthly budget (setting `maps.monthly_route_calls`) falling back to the straight-line estimate (B-1304). Top-up return page `/p/wallet/topup/done`.
- Blocked `[!]`: B-1301…B-1304 need keys (F-4, F-5, F-7, F-8); B-1305 S3 needs AWS (F-9); B-1306 Aadhaar provider (F-3).
- Tests: 18 unit + 67 integration green.

## 2026-11-21 — M14 Admin API complete (done)
- Done: B-1201…B-1212 (B-1205 verification tabs from M2, B-1206 tickets from M13).
- Backend: admin allow-list (`ADMIN_MOBILES`, seeded at start-up; dev = 9000000006) and 30-minute idle timeout on admin refresh; dashboard metrics (open/active loads, fleet on duty, pending verifications, open support, freight and payment split, route status, review reminders, top-ups and cancellations today); loads list (10/page, search by code/area/mobile) + detail with tracking, cancellations, location exceptions, OTP help; admin cancel (also after pickup) and OTP override; fleet list; users search/suspend (signs out)/reactivate; cancellations decide (REVERSE returns points); payment disputes list; location-exception review; typed settings with "weights = 100%" check; map restrictions CRUD; audit query. Every admin write is audited. 67 integration tests green.
- Demo (Swagger, dev): sign in with 9000000006 / OTP 123456 → Authorize → `GET /api/v1/admin/dashboard`, `GET /api/v1/admin/loads?q=TRX`, `PUT /api/v1/admin/settings/support.reopen_days {value:"10", reason}`, `GET /api/v1/admin/audit`.
- New: D-33 (assumed admin rules); founder action F-6 (production admin numbers).

## 2026-11-21 — M13 Support and broadcasts (done)
- Done: B-1103…B-1107, B-1005, A-305…A-307.
- Backend: new `support` module (V15): tickets with codes `TKT-000001`, conversation, unread flags for user/admin, reopen within 7 days (setting), admin `/admin/tickets` list/detail/reply (optionally close)/ignore with reason (audited, user notified); payment disputes and receipt shortage/damage open tickets automatically. Broadcasts in engagement: all/role/district/user, now or scheduled (job every minute) → "Tranix messages" inbox + push. Rating reminders and document-expiry/low-balance notifications confirmed wired. 64 integration tests green.
- Frontend: Support screen (menu → Support): history with unread dot, new request (type, other text, trip picker per role, description, up to 3 photos), conversation thread with reply and Reopen; driver home now shows the latest Tranix message/trip update cards; the trip help button opens Support. analyze clean, 51 tests green, debug APK builds.
- Demo: app → profile menu → Support → New request. Admin (Swagger): `GET /api/v1/admin/tickets`, `POST /api/v1/admin/tickets/{id}/reply {body}`; `POST /api/v1/admin/broadcasts {title, body, audience: ALL}` → appears in every inbox.
- New: D-32 (assumed support details).

## 2026-11-21 — M12 Receiver and public pages (done; B-1005 ticket in M13)
- Done: B-1001…B-1004, B-1006, A-901…A-903.
- Backend: new `receiver` module (V14). Tracking links (random token per load for the receiver, plus the farmer sender on FN loads) are created at acceptance and sent by SMS (`RECEIVER_TRACKING`/`SENDER_TRACKING` with `link`); they expire 7 days after delivery or cancellation (`410 LINK_EXPIRED`, no data). Link page `/p/track/{token}` (en/ta/hi, polls every 30 s) + public JSON; delivery OTP only announced, never returned (tested); after delivery: receipt photos + condition (+ remarks for shortage/damage), rating once, mark paid when the receiver pays. Registered receivers: `GET /receiver/loads`, `/receiver/loads/{id}`, `POST .../receipt`. `ReceiptRecorded` event for B-1005. 61 integration tests green.
- Frontend: receiver Loads/History tabs, load detail with driver, live tracking, delivery OTP card ("share only after checking"), receipt form (camera/gallery, condition, remarks), payment card when the receiver pays; receiver deep links from notifications open the receiver screen. analyze clean, 50 tests green, debug APK builds.
- Demo (backend): accept a load (M6) → fake SMS list shows `RECEIVER_TRACKING` with `link` → open it in a phone browser: status, driver, ETA; after delivery submit a receipt and a rating.
- Demo (mock app): Open as Receiver → TRX-000123 → Delivery receipt form.
- New: D-31 (assumed link/receipt details); error `LINK_EXPIRED` (410).

## 2026-11-21 — M11 Organization app (done)
- Done: A-801…A-805 (backend B-502…B-508 were done in M5).
- Frontend: Org dashboard (wallet + top up, active trips, Shippers who prefer you, truck/driver counts); Trucks (add/edit/deactivate, detail with documents via `POST /org/trucks/{id}/documents` and live location); Drivers (invite, invited list, performance, allocate a free truck, pause/resume/remove with `ALLOCATION_CONFLICT` message); Trips by driver/truck with CSV export (saved through the system file dialog). analyze clean, 48 tests green, debug APK builds.
- Demo (mock): Open as Organization → Dashboard; Trucks → TN38CD5678 → documents + last location; Drivers → Kumar V → Allocate truck → TN38EF9012; Trips → By truck → Export CSV.
- Demo (backend): sign up as ORGANIZATION (verify), `POST /org/trucks`, `POST /org/drivers {name, mobile}` → driver accepts `POST /driver/invitations/{id}/accept` → `POST /org/allocations`; `GET /org/trips/export` downloads CSV.

## 2026-11-21 — M10 Farmer Network (done)
- Done: B-901…B-904, A-701…A-704.
- Backend: `farmers_farmer` (V13) with consent time and Aadhaar last 4 only; `GET/POST/PUT /farmers`, `/deactivate` (verified FN for add/edit, duplicate mobile per network rejected); posting with `postedForFarmerId` locks the farmer as sender (pickup OTP to the farmer), FN wallet pays, `postedForFarmerName` on summaries, farmer gets `SENDER_TRACKING` SMS at acceptance; `GET /loads?farmerId=`. 59 integration tests green.
- Frontend: FN registration checks the ID number against CIN/PAN/GSTIN; Farmers tab (search, add with consent, edit, deactivate, post for this farmer); "Post for a farmer" on the FN home with a farmer picker; locked sender in the post form + "Posted for" on cards/review; farmer filter on tracking/history. analyze clean, 44 tests green, debug APK builds.
- Demo (mock): Open as Farmer Network → Farmers → Add farmer (tick consent) → Save; Home → Post for a farmer → Raman K → sender is locked. Tracking → filter by farmer.
- Demo (backend): sign up as FARMER_NETWORK (verify via admin), `POST /farmers {name, mobile, village, consent:true}`, post a load with `postedForFarmerId`; after a driver accepts, the fake SMS list has `SENDER_TRACKING` for the farmer mobile.
- Notes: the SMS tracking link for the farmer arrives with public pages (M12).

## 2026-11-21 — M9 Wish list (done)
- Done: B-651…B-656, A-408…A-410, A-512.
- Backend: `matching_wishlist_entry` (V12); `GET/POST/PUT/DELETE /wishlist` (trucks only from own finished trips, verified Orgs, limit → `WISHLIST_FULL`); `/wishlist/org-search` (name or `ORG-` code) and `/wishlist/candidates`; posting with `WISHLIST_FIRST`/`WISHLIST_ONLY` (`WISHLIST_EMPTY`); matching restricts to wish-list drivers (relaxed 100 km radius, eligibility unchanged), ranking bonus on EVERYONE loads, preferred push; server job opens WISHLIST_FIRST after 15 min and notifies once for WISHLIST_ONLY after 30 min; `POST /loads/{id}/open-to-everyone`; Org dashboard `preferredByShippersCount`. 57 integration tests green.
- Frontend: Wish list tab (My list with notes/remove and "n of 20", From my trips, Find organization); "Offer to" with Everyone / Wish list first / Wish list only and entry chips on post-a-load (+ Manage wish list link, also for Farmer Networks); wish-list banner with Open to everyone on the load detail; "Add to wish list" on finished loads. analyze clean, 41 tests green, debug APK builds.
- Demo (mock): Open as Load Provider → Wish list → From my trips → ♡ on TN38CD5678; Find organization → "pal" → Palani Roadways. Home → Post a load → Offer to → Wish list first → pick entries.
- Demo (backend): deliver a trip (M7), `GET /wishlist/candidates`, `POST /wishlist {targetType: TRUCK, truckId}`, post a load with `audience: WISHLIST_ONLY` → only that driver gets the suggestion (tag "Preferred by this shipper"); `POST /loads/{id}/open-to-everyone` → others get it on the next batch.
- New: D-30 (assumed: Org code format, bonus 10, window behaviour). Contract: org-search gains `orgCode`; candidates shape defined.

## 2026-11-21 — M8 Payments, ratings, Trust Score (done)
- Done: B-801…B-808, A-407, A-510, A-601…A-603.
- Backend: payment record at acceptance; mark paid (payer) → driver confirm/dispute; admin dispute decision; Trust Score ledger (events with unique (user, load, event), clamp 0–100, Org score from its drivers); ratings with Later once + reminder job; driver history with month summary. 52 integration tests green.
- Frontend: payment card + "Mark as paid" sheet on the shipper load detail; driver History tab (month switcher, agreed/received/pending, confirm/dispute); rating pop-up on app open (Later once); Trust Score screen (score, trend line, events, How it works) from the profile badge or menu. analyze clean, 39 tests green, debug APK builds.
- Demo (mock: `flutter run --dart-define=USE_MOCK=true`): Open as Load Provider → TRX-000123 → Payment → Mark as paid → pick UPI → Mark as paid. Profile → tap the Trust Score badge → events + How it works. Open as Driver → History → Confirm received / Dispute on TRX-000123.
- Demo (backend): accept + deliver a load as in M7, then `POST /loads/{id}/payment/mark-paid` as the shipper, `POST /driver/trips/{id}/payment/confirm` as the driver; `GET /ratings/pending` shows the rating for both; `GET /trust-score/events` shows ON_TIME.
- Contract: `GET /settings/public` gains `ratingTags[]` (setting `lists.rating_tags`).

## 2026-11-21 — M7 Trip execution (done; A-510 history moves to M8 with payments)
- Done: B-701…B-711, B-408; A-405, A-504…A-509, A-511. D-28 assumed (trip OTP storage, late rule).
- Demo (after the M6 demo accept): driver → Current trip shows exact pickup/drop with Call + Navigate → "Request new amount" (1 of 5) → shipper load detail shows the Amount request card → Confirm. Driver taps "Reached pickup" (outside 500 m asks a reason) → shipper detail shows the Pickup OTP (dev OTP 123456) → driver enters it → Traveling; app uploads location every 30 s (foreground notification) → shipper sees Live tracking + route status → "Reached destination" → delivery OTP (SMS to receiver; dev 123456) → Delivered.

## 2026-11-21 — M5 + M6 done (Driver/fleet; Matching and acceptance)
- Done: B-501…B-509, A-501, A-502 (M5); B-601…B-607, A-503, A-404 (M6). D-27 assumed (radius steps, location needed to match).
- Login is role-based: role chosen at sign-up and fixed; JWT carries the role; server checks every endpoint; app opens that role's shell (founder asked 2026-11-21).
- Demo (dev seed): driver 9000000003 is on duty near Oddanchatram with an approved truck. Sign in as 9000000001, top up, post a load from Oddanchatram (pickup within 25 km of 10.50, 77.76) → sign in as 9000000003 → Suggestions shows it (area only) → Accept → confirm → ₹50 + ₹50 charged; shipper's load detail shows the driver with Call. Organization 9000000004: `POST /api/v1/org/drivers` invite, driver accepts in the app (home banner), then `POST /api/v1/org/allocations`.
- Next: M7 trip execution (B-701…B-711, B-408; A-504…A-511, A-405, live map for A-404).

## 2026-11-21 — M5 in progress (backend done, frontend next)
- Done: B-501…B-509 (fleet module: trucks, invitations, allocations with DB uniqueness, duty/home, org dashboard/drivers/trips/CSV, truck location; dev seed trucks for 9000000003 and 9000000004).
- Next: A-501 driver home (duty switch, invitation banner) and A-502 driver profile (licence, own truck form + documents, invitation accept/reject, locker); then M0-style checkpoint, then M6.
- Notes: Spring proxies — never read fields through another @Service bean (inject dependencies directly).

## 2026-11-21 — M4 Post a load (done; B-408 moved to M7)
- Done: B-401…B-407, B-409, A-401…A-403 (+ tracking/history lists and basic load detail with edit/cancel/post again). D-26 assumed.
- Maps: pin picker uses Google Maps only with a key (F-5); otherwise device location + typed address.
- Demo: sign in 9000000001 (verified), top up ≥ ₹50 → Home → Post a load → set date, pickup/drop (Use my current location + address), goods, receiver, amount → Continue → Review shows estimate + "Posting charge ₹50 — charged only when a driver accepts" → Post load → load detail (Not accepted, timeline). Edit or Cancel (shows outcome first); Tracking tab lists it.

## 2026-11-21 — M3 Wallet and notifications basics (done, A-303 [!])
- Done: B-301…B-308, B-1101, B-1102, A-301, A-302, A-304. A-303 push code ready, needs Firebase (F-4). D-25 assumed.
- Contract: wallet transactions paging/month format, top-up limits, webhook `X-Signature`, notification item shape.
- Demo: sign in as 9000000001 → Profile → Wallet → tap ₹500 → browser opens top-up page → Pay now → "Simulate successful payment" → back in app balance shows ₹500 (polls 3×) → bell shows "Wallet topped up". Swagger admin: `POST /api/v1/admin/wallet/{userId}/credit {amountInr, reason}`.

## 2026-11-21 — M2 Profile and verification (done, B-204 [!])
- Done: B-201…B-203, B-205…B-208, A-201…A-207. B-204 Aadhaar: endpoint + storage ready, provider blocked on Q-04 (founder-review F-3).
- Contract: `aadhaarEnabled` in public settings; document rules/item keys documented. D-24 assumed (status derived from document decisions).
- Demo: sign up as Load Provider → Profile: fill name/address, account details, add Photo + PAN → 100% → Submit → Swagger as admin (9000000006): `GET /api/v1/admin/verifications?tab=IDENTITY`, approve each document → app Verification shows Verified. Reject one with a reason → app shows reason + Upload again.

## 2026-11-21 — M1 Sign up and sign in (done)
- Done: B-101…B-112, A-101…A-106. Dev seed users 9000000001–06 (OTP 123456; …06 = ADMIN).
- Contract: sign-up `deviceId?`; mobile change bodies; `GET /me/address`, `GET /me/role-profile`. D-23 assumed (completion weights, OTP limits).
- Demo: backend dev → app `--dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1` → Sign up (any new mobile, OTP 123456) → role shell with "Complete your profile" banner; Profile → Sign out; Sign in again with same mobile.
- Check: `tools/check-all.sh` (backend verify, analyze, test, debug APK).

## 2026-11-21 — M0 Foundations (done)
- Done: B-001…B-010, A-001…A-012.
- Backend: Boot 4.1.2 kept (D-21, pending founder OK); modules + Modulith test; shared (problems with contract codes, JWT security, GeoPoint/Haversine, Clock, contract enums, files with signed URLs, settings); `admin_setting` + defaults; `GET /settings/public`; fake SMS/push/maps/payments/storage, Aadhaar disabled; Swagger with JWT; CI. `mvnw verify`: 31 tests green (Testcontainers).
- Frontend: app id `in.tranix.app`, flavors dev/prod, material_ui (Flutter 3.50), Riverpod + go_router role shells, dio interceptors (language, auth, single-flight refresh, problem→AppException, mock), contract models (freezed), en/ta/hi ARB, shared widgets, mock fixtures, CI. analyze clean, 15 tests green, debug APK builds.
- Contract changes: added `GET /files/{id}/content?exp=&sig=` (target of signed `viewUrl`).
- New: D-21 (Boot 4, base package, settings in shared), Q-13 (goods type list default).
- Notes: dev seed users/trucks deferred into B-101/B-501 (tables don't exist yet). Sign-up/sign-in screens are placeholders until M1.

## 2026-11-21 — setup (machine + monorepo)
- Done: one git repo for the whole project, pushed to private GitHub repo `NOTHING-Tranix/tranix` (fresh history). Folders renamed `tranix-backend` → `backend/`, `tranix-frontend` → `frontend/` to match D-20. Root `.gitignore` covers Java/Maven, Flutter/Dart, Android, IDEs, secrets (merged `.gitignore.additions`).
- Done: Flutter 3.50.1 stable (Dart 3.14) at `C:\Users\shero\dev\flutter`; Android SDK (cmdline-tools, platform-tools, android-35/36, build-tools 36, emulator, AVD `tranix_api36`) at `%LOCALAPPDATA%\Android\Sdk`; licenses accepted; `flutter doctor` clean for Android. User env: `JAVA_HOME` = JDK 21 (`.jdks\openjdk-21.0.2`), `ANDROID_HOME`, PATH entries.
- Done: `flutter create --org in.tranix --project-name tranix_app --platforms android,web` in `frontend/`; `flutter analyze` clean, `flutter test` green, `flutter build apk --debug` OK. Backend `mvnw -DskipTests package` OK.
- Backups: old backend `.git` zipped to `Downloads\backend-git-backup-2026-11-21.zip`; the folder itself moved to `Downloads\backend-old-dotgit-2026-11-21` (delete when no longer needed).
- Pending (founder): delete old repo `NOTHING-Tranix/Tranix-Backend` — needs `gh auth refresh -h github.com -s delete_repo` (browser) then `gh repo delete NOTHING-Tranix/Tranix-Backend --yes`.
- Notes: backend is Spring Boot **4.1.2**, base package `com.nothing.tranix` (docs say Boot 3 / `com.tranix`) → handled in B-001. App id is `in.tranix.tranix_app` → A-001. Old Flyway migrations V1–V16 were removed on purpose before the move.

## 2026-11-20 — setup
- Done: project docs added (root CLAUDE.md, ROADMAP.md, docs/, backend/ and frontend/ CLAUDE.md + TODO.md).
- Notes: Start with `/next-milestone M0`. Wish list added (D-19). Layout: one folder with backend/ and frontend/ (D-20).
