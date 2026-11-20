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
