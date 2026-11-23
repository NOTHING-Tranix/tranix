# Testing Tranix with friends (APK + ngrok tunnel)

Everyone uses their own Android phone, anywhere. The server runs on the host's PC and is reachable through a fixed
ngrok address.

## Host (the PC owner) — one time

1. `backend\.env` has `NGROK_AUTHTOKEN=…` and `NGROK_DOMAIN=…ngrok-free.dev` (plus the Twilio lines).
2. Build the APK (about 5 minutes) — it lands in `Downloads\Tranix-test.apk`:
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\Users\shero\Downloads\Tranix\tools\build-test-apk.ps1
   ```
3. Send `Tranix-test.apk` to the testers (WhatsApp as a *document*, or Google Drive).

## Host — every testing session (two windows, keep both open, PC must stay on)

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\shero\Downloads\Tranix\tools\backend-dev.ps1
```
wait for "Started TranixApplication", then:
```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\shero\Downloads\Tranix\tools\tunnel.ps1
```
Close both windows (Ctrl+C) when testing is over — while they run, anyone with the app can reach the server.

## Testers

1. Open `Tranix-test.apk`, allow "Install unknown apps", install, open **Tranix Dev**.
2. Tap **Sign in**, enter your number from the table, tap Send OTP, enter **123456**.
   (The real SMS goes to the host's phone while testing — 123456 always works.)
3. Allow location when asked (needed for pickup pins and for drivers).

| Tester | Number | Role | What to try |
| --- | --- | --- | --- |
| Host | 9000000001 | Load Provider | Post a load, accept an amount request, share the pickup OTP, mark paid, rate |
| Friend 1 | 9000000002 | Farmer Network | Add a farmer, post a load for the farmer |
| Friend 2 | 9000000003 | Driver (has a truck) | Go **On duty**, accept a suggestion, Reached → OTP, deliver, confirm payment |
| Friend 3 | 9000000004 | Organization | Add a truck, invite a driver, allocate, watch trips |
| Friend 4 | 9000000005 | Receiver | Track the load, see the delivery OTP, upload a receipt |
| Host (browser) | 9000000006 | Admin | `https://<NGROK_DOMAIN>/swagger-ui.html` → sign in → approve users, settings |

Want to use your real number instead? Tap **Sign up** with it (OTP 123456), fill the profile and submit
verification; the host approves you as admin in Swagger (`GET /api/v1/admin/verifications`, then
`POST /api/v1/admin/documents/{id}/approve`). A new driver also needs a truck and documents.

## Making a trip happen between people in different cities

Drivers only get loads near them: the search starts at 25 km from the pickup and widens to 100 km. So:
- The **driver goes On duty** (the app sends their current location), then
- the **shipper posts a load with the pickup near the driver** (search the driver's town in the pickup map).

Or, for testing, the admin widens the search in Swagger:
`PUT /api/v1/admin/settings/matching.initial_radius_km` with `{"value":"3000","reason":"remote testing"}`
(and `matching.max_radius_km` the same) — every on-duty driver in India then sees every load.

## If something does not work

- **"Network error" in the app:** the host's backend or tunnel is not running, or the address changed.
  On the Welcome screen tap **Server** and enter the address from the tunnel window (e.g. `…ngrok-free.dev`).
- **No suggestions for the driver:** the driver is not On duty, the truck type/capacity does not match the load, or
  the pickup is too far (see above).
- **Tracking link from SMS shows an ngrok warning page:** tap "Visit Site" — it is a one-time ngrok notice.
