# Founder review

Items Claude could not finish or decided on its own while working in autopilot. Newest at the bottom of each section.

## Assumptions to review (decisions marked "assumed by Claude")

| ID | Summary | Where |
| D-23 | Completion weights, OTP 5 sends/hour, review 24 h, licence format | docs/decisions.md |
| D-24 | User status derived from document decisions; verified users stay verified when replacing a document | docs/decisions.md |
| D-25 | Top-up ₹100–₹50,000, wallets only for LP/FN/Driver/Org, low-balance rule, no SMS for wallet events | docs/decisions.md |
| D-26 | ETA buffer 60 min, max 60 t, cancel reasons + fault list, ongoing definition, repost window | docs/decisions.md |
| D-27 | Radius step 25 km → max 100 km, location needed to match, neutral return-load factor | docs/decisions.md |
| D-28 | Trip OTP stored hashed + encrypted copy for display; late = ETA + 30 min; pending revision ends at Reached | docs/decisions.md |
| --- | --- | --- |

## Actions only the founder can do

| # | What | Exact steps |
| --- | --- | --- |
| F-1 | Delete old repo `NOTHING-Tranix/Tranix-Backend` (founder will do it) | `gh auth refresh -h github.com -s delete_repo` then `gh repo delete NOTHING-Tranix/Tranix-Backend --yes` |
| F-2 | Remove local backup folder when no longer needed | Delete `Downloads\backend-old-dotgit-2026-11-21` (zip backup stays) |
| F-3 | Choose an Aadhaar offline/DigiLocker provider (Q-04) | Sign up with the provider, get sandbox + live keys; then Claude implements `AadhaarVerifier` for it and sets `tranix.integrations.aadhaar=<provider>`. Until then the option stays hidden (`aadhaarEnabled=false`). |
| F-4 | Firebase project for push (FCM) | Create a Firebase project, add Android apps `in.tranix.app` and `in.tranix.app.dev`, download `google-services.json` into `frontend/android/app/` (do not commit prod), add the `com.google.gms.google-services` Gradle plugin, and create a service account key for the backend `PushSender` (set `tranix.integrations.push=fcm` once implemented in M15). |
| F-5 | Google Maps API key (Q-05) | Create a Google Cloud project with Maps SDK for Android (+ Routes/Places when Q-05 is decided), restrict the key to `in.tranix.app`, then build with `-PMAPS_API_KEY=…` (Gradle) and `--dart-define=MAPS_API_KEY=…` (Dart). Without it the app uses the device location + typed address instead of the map pin. |

## Blocked tasks `[!]`

| Task | Why | What is needed |
| B-204 | Aadhaar provider not chosen (Q-04) | F-3 |
| A-303 | Push needs Firebase config | F-4 |
| --- | --- | --- |
