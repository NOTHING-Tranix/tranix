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
| D-29 | Payment on time = 7 days; dispute outcomes; Org score = avg drivers + own events | docs/decisions.md |
| D-30 | Org code format, ranking bonus 10, wish-list window behaviour | docs/decisions.md |
| D-31 | Link expiry on cancel, link rating, receipt rules, farmer link view-only | docs/decisions.md |
| D-32 | Ticket rules, automatic tickets, broadcast audience | docs/decisions.md |
| D-33 | Admin cancel/override/reverse rules, admin allow-list + 30-min idle | docs/decisions.md |
| --- | --- | --- |

## Actions only the founder can do

| # | What | Exact steps |
| --- | --- | --- |
| F-1 | Delete old repo `NOTHING-Tranix/Tranix-Backend` (founder will do it) | `gh auth refresh -h github.com -s delete_repo` then `gh repo delete NOTHING-Tranix/Tranix-Backend --yes` |
| F-2 | Remove local backup folder when no longer needed | Delete `Downloads\backend-old-dotgit-2026-11-21` (zip backup stays) |
| F-3 | Choose an Aadhaar offline/DigiLocker provider (Q-04) | Sign up with the provider, get sandbox + live keys; then Claude implements `AadhaarVerifier` for it and sets `tranix.integrations.aadhaar=<provider>`. Until then the option stays hidden (`aadhaarEnabled=false`). |
| F-4 | Firebase project for push (FCM) | Create a Firebase project, add Android apps `in.tranix.app` and `in.tranix.app.dev`, download `google-services.json` into `frontend/android/app/` (do not commit prod), add the `com.google.gms.google-services` Gradle plugin, and create a service account key (JSON) for the backend: put it on the server (never in git) and set `PUSH_PROVIDER=fcm`, `FCM_SERVICE_ACCOUNT_FILE=/path/key.json`. The FCM adapter is built and tested (B-1303). |
| F-5 | Google Maps API key (Q-05) | Create a Google Cloud project with Maps SDK for Android (+ Routes/Places when Q-05 is decided), restrict the key to `in.tranix.app`, then build with `-PMAPS_API_KEY=…` (Gradle) and `--dart-define=MAPS_API_KEY=…` (Dart). Without it the app uses the device location + typed address instead of the map pin. Backend: enable the Routes API, create a server key (IP-restricted) and set `MAPS_PROVIDER=google`, `GOOGLE_MAPS_SERVER_KEY=…`; budget = setting `maps.monthly_route_calls` (20 000). |
| F-6 | Admin numbers for production | Set `ADMIN_MOBILES` (comma separated) on the server; those numbers get an ADMIN account at start-up and are the only ones that can sign in as admin. |
| F-7 | SMS provider MSG91 + DLT (Q-03) | Register the entity and the sender ID on a DLT portal, get every SMS template in `Templates`/SMS keys approved in en/ta/hi (OTP_SIGN_UP, OTP_SIGN_IN, OTP_MOBILE_CHANGE, TRIP_OTP_PICKUP, TRIP_OTP_DELIVERY, RECEIVER_TRACKING, SENDER_TRACKING, ORG_INVITE…), create matching MSG91 Flow templates, then set `SMS_PROVIDER=msg91`, `MSG91_AUTH_KEY` and one env var per template id `TRANIX_MSG91_TEMPLATES_<KEY>_<LANG>`. |
| F-8 | Razorpay account (Q-02) | Create the account (KYC), get API key id/secret, add a webhook to `https://<api-host>/api/v1/webhooks/payments` for `payment_link.paid` with a secret; set `PAYMENT_PROVIDER=razorpay`, `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`. Test with Razorpay test keys first. |
| F-9 | AWS account (S3 + RDS + hosting) | Needed for B-1305 (S3 files) and B-1404 (deploy). Create the account, a region (ap-south-1), an IAM user/role for the app; then Claude adds the S3 adapter and the deploy scripts. |

## Blocked tasks `[!]`

| Task | Why | What is needed |
| --- | --- | --- |
| B-204 | Aadhaar provider not chosen (Q-04) | F-3 |
| A-303 | Push needs Firebase config | F-4 |
| B-1301 | MSG91 adapter built + tested; needs DLT templates and key | F-7 |
| B-1302 | Razorpay adapter built + tested; needs account and keys | F-8 |
| B-1303 | FCM adapter built + tested; needs Firebase service account | F-4 |
| B-1304 | Google Routes adapter built + tested (cache + budget); needs a server key | F-5 |
| B-1305 | S3 storage needs an AWS account | F-9 |
| B-1306 | Aadhaar provider not chosen | F-3 |
| B-1404 | AWS deploy (image builds in CI) | F-9 |
| B-1405 | Backup/restore scripts need a database host to run against | F-9 |
| B-1407 | Load test needs a staging environment | F-9 |
