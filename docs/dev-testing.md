# Dev testing setup (real SMS, push and free maps)

For testing with real phones before launch. Production setup (DLT, AWS, Play Store) is in `founder-review.md`.

| Service | Used for dev testing | Cost |
| --- | --- | --- |
| SMS | **Twilio** (trial) — every SMS can be redirected to one verified number | Trial credit |
| Push | **Firebase Cloud Messaging** | Free |
| Maps in the app | **OpenStreetMap** tiles (flutter_map) | Free (light use) |
| Routes / ETA | **OSRM** public demo server | Free (light use) |
| Address search | **OpenStreetMap Nominatim** (max 1 request/s, cached) | Free (light use) |
| Payments | Fake checkout page | — |
| Admin | `9000000006`, OTP `123456`, in Swagger | — |

The free map services are for testing only. Before launch, use a hosted tile/routing/geocoding service or your own
OSRM/Nominatim server (`MAP_TILE_URL` app define, `tranix.osrm.base-url`, `tranix.nominatim.base-url`).

## One-time: put your settings in `backend.env`

Open `backend.env` in Notepad (create it if missing), copy the lines you need from `backend.env.example`, fill in
your values and save. The file is not in git. `toolsbackend-dev.ps1` reads it every time it starts.

Alternative: Windows user environment variables (the `.env` file wins if both are set):

Run in PowerShell, with your own values. **Never put these in git or in chat.**

```powershell
setx TWILIO_ACCOUNT_SID "AC..."
setx TWILIO_AUTH_TOKEN "your-auth-token"
setx TWILIO_FROM "+1..."                  # your Twilio phone number
setx SMS_REDIRECT_TO "+91XXXXXXXXXX"      # your own verified mobile; every SMS goes here while testing
setx FCM_SERVICE_ACCOUNT_FILE "C:\Users\<you>\secrets\tranix-firebase.json"
```

Open a new PowerShell afterwards. Production: leave `SMS_REDIRECT_TO` unset so SMS go to the real users.

- **Twilio trial:** only verified numbers receive SMS, and every SMS starts with "Sent from your Twilio trial account".
  Indian networks may block SMS from foreign trial numbers without DLT — check Twilio Console → Monitor → Messaging logs.
- **Firebase service-account key:** Firebase console → Project settings → Service accounts → Generate new private key.
  Keep it outside the project folder. (The app's `google-services.json` files are different: they go in
  `frontend/android/app/src/dev/` and `src/prod/`, also not in git.)

## Run

```powershell
powershell -ExecutionPolicy Bypass -File tools\backend-dev.ps1              # fixed OTP 123456, also sent by SMS
powershell -ExecutionPolicy Bypass -File tools\backend-dev.ps1 -RandomOtp   # real random OTPs by SMS only
powershell -ExecutionPolicy Bypass -File tools\run-emulator.ps1 -Backend    # app on the emulator against it
```

The script prints which services are on (Twilio / fake SMS, Firebase / no push, free maps).
