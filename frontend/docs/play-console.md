# Play Console disclosures (A-1002)

Draft answers for the Play Console "App content" section. Final text needs the legal review (Q-08).

## Permissions and why

| Permission | Used for | Shown to the user |
| --- | --- | --- |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | Pickup/drop pins when posting; the driver's location **only during an active trip** so the shipper/receiver can track the truck | In-app explanation before the system dialog ("Share your location during trips") |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `WAKE_LOCK` | Keep trip tracking running while the driver navigates; a notification is always visible while on | Ongoing notification "Tranix is sharing your location for trip …" |
| `CAMERA` | Photos of documents, receipts and support attachments | System dialog when the user taps Camera |
| `POST_NOTIFICATIONS` | Trip, wallet and support updates | System dialog after sign-in |
| `INTERNET` | API | — |

No background location outside an active trip. No contacts, SMS or call-log access.

## Data safety (collected → purpose)

- Name, mobile number: account, sign-in by OTP, shown to the other party **after acceptance** only.
- Approximate/precise location: posting addresses; driver location during trips (kept 90 days, setting).
- Photos/files: verification documents, receipts, support photos (stored privately; short-lived signed links).
- Government ID: Aadhaar **last 4 digits** and verification result only; PAN/licence numbers masked in responses.
- Payments: no card data in the app — top-up opens the gateway page in the browser (D-13).
- Deletion: Profile → Support (or `POST /me/deletion-request`) opens a deletion request.

## Monetisation

No in-app purchases. Wallet top-up is on the web (D-13); a test in `test/release_checks_test.dart` fails if billing code appears.
