# Screens (Android app)

Each screen: **route** · data shown · actions → API (see `../../docs/api-contract.md`) · states. Every screen also has loading, empty, error-with-retry and offline states (CLAUDE.md rule 7). Bottom navigation per role is listed under each role.

## 1. Common

### S-01 Splash · `/`
Read tokens → `POST /auth/refresh` → `GET /me` → role shell; no/invalid token → `/welcome`. Offline → retry button.

### S-02 Welcome + language · `/welcome`
First open: language chips (English, தமிழ், हिन्दी) → stored + used for `Accept-Language`. Buttons: Sign up, Sign in.

### S-03 Sign up · `/sign-up` → `/sign-up/otp`
Page 1: mobile (+91, 10 digits, starts 6–9), name (2–60 chars), role (Load Provider, Farmer Network, Organization, Driver, Receiver), consent checkbox → `POST /auth/otp/send {SIGN_UP}`.
Page 2: 6-box OTP, 30 s resend timer, Android SMS autofill → `POST /auth/sign-up`. `MOBILE_IN_USE` → offer Sign in.
→ role shell with banner "Complete your profile to start".

### S-04 Sign in · `/sign-in` → `/sign-in/otp`
Mobile → `POST /auth/otp/send {SIGN_IN}` → OTP → `POST /auth/sign-in`. `OTP_LOCKED` → "Try again in 15 minutes".

### S-05 Profile · `/profile`
Completion circle (`profileCompletion`), verification badge, name, photo (camera), mobile (change → OTP flow), email (optional), ID proof (Aadhaar offline check when enabled — shows last 4 only; or PAN / Voter ID / licence upload), address (line, village/town, district, state, PIN), role section (see role screens), links: Wallet, Trust Score, Language, Support, Logout. **Submit for verification** button at 100% → `POST /me/verification/submit`.
APIs: `GET /me`, `PUT /me`, `GET /me/verification`, `POST /files`, `POST/PUT /me/documents`, `PUT /me/role-profile`.

### S-06 Verification status · `/verification`
Under review (estimated time, submitted items with tags Logged / Attached / OTP validated, **Check updates**) · Not verified (issues per document + Upload again) · Verified (what's next). `GET /me/verification`.

### S-07 Profile pop-up (sheet from avatar)
Completion circle, name, role, badge, wallet balance + **Top up**, Trust Score, Profile, Logout.

### S-08 Wallet · `/wallet`
Balance, role's charge (`GET /wallet`), low-balance warning. **Top up**: chips from settings (₹500/1,000/2,000) or custom → `POST /wallet/topup-link` → open URL in external browser → on return, refresh balance (and poll `GET /wallet` 3× every 5 s). Transactions list with filters (month, type): txn ID, time, amount, credit/debit, type, trip ID (tap → load). Download statement.

### S-09 Notifications · `/notifications`
Tabs Trips · Wallet · Tranix · Account with unread counts (`GET /notifications/summary`). List newest first; tap → `POST /notifications/{id}/read` + navigate to `route`. Mark all read.

### S-10 Support · `/support`, `/support/new`, `/support/{id}`
New: type (Complaint, Feedback, Wallet, Payment dispute, Others + text), trip (dropdown of my loads; optional for Feedback/Others), description (20–2000), up to 3 photos → `POST /tickets`. History list with status chip and unread dot. Thread: messages, reply box, reopen (≤ 7 days after close).

### S-11 Rating pop-up (dialog on app open)
If `GET /ratings/pending` not empty: one dialog per pending item — ratee name/role, 1–5 stars (required), tags, comment → `POST /ratings`; **Later** once → `POST /ratings/{loadId}/later`.

### S-12 Trust Score · `/trust-score`
Score, updated date, small trend line (`GET /trust-score`); event list (date, trip, event, ±points, reason) (`GET /trust-score/events`); "How it works".

### Home cards (all roles)
Latest Tranix message and latest trip update from `GET /notifications/summary`.

## 2. Load Provider (`/lp`) — bottom nav: Home · Tracking · History · Wish list · Profile (Wallet from the profile pop-up and home)

### LP-01 Home · `/lp`
Wallet balance, **Post a load**, ongoing load cards (status chip), Tranix message card, pending rating banner, verification banner if not verified.

### LP-02 Post a load · `/lp/post` → `/lp/post/review`
Sections: Pickup (date + time window, map pin + address + landmark, sender name/mobile prefilled) · Goods (type dropdown, description, quantity + unit, weight t, vehicle type) · Drop (map pin + address) · Receiver (name, mobile) · Payment (freight paid by: Me / Receiver; amount ₹ with suggested range if returned) · **Offer to**: Everyone (default) / Wish list first (15 min, then everyone) / Wish list only — with "Choose from wish list" (all ticked by default; shows which entries are available now). Hidden if the wish list is empty, with link "Build your wish list".
On pins set → `POST /loads/estimate` → show distance, drive time, delivery estimate.
Review page: summary + "Posting charge ₹X — charged only when a driver accepts" → `POST /loads`. `INSUFFICIENT_BALANCE` → top-up sheet, keep form data. `WISHLIST_EMPTY` → switch to Everyone or edit selection. `NOT_VERIFIED` → verification sheet.

### LP-03 Tracking list · `/lp/tracking`
Ongoing loads: code, status chip, goods, description, quantity, pickup → drop area, pickup date (`GET /loads?scope=ONGOING`).

### LP-04 Load detail · `/lp/loads/{id}`
Full details, status timeline with times, live map (driver location, poll `GET /loads/{id}/tracking` 30 s), current ETA, route status.
After acceptance: driver name, photo, truck number/type, Trust Score, phone (copy / call via `tel:`).
**Amount request card** (when a revision is PENDING): amount, reason, "2 of 5", countdown → Confirm / Reject (`/revisions/{rid}/confirm|reject`). Note: "Rejecting keeps the current amount; the trip continues."
**Pickup OTP card** when status `LOCATION_REACHED` and I am the sender (`GET /loads/{id}/otp`).
Wish-list loads show "Offered to your wish list until 10:45" or "Wish list only — no one has accepted yet" with **Open to everyone** (`POST /loads/{id}/open-to-everyone`).
Actions: Edit (only `NOT_ACCEPTED` → LP-02 prefilled, `PUT /loads/{id}`), Cancel (shows rule outcome first → `POST /loads/{id}/cancel`), Report a problem (support), Payment section (LP-06).

### LP-05 History · `/lp/history`
Trust Score card → S-12; month summary (trips, total freight, avg rating given); list of completed/cancelled loads → detail (read-only, route path, revisions, payment, receipt, ratings) with **Post again** (`POST /loads/{id}/repost`) and **Add truck / organization to wish list** (`POST /wishlist`).

### LP-07 Wish list · `/lp/wishlist`
List of entries: truck number + vehicle type + capacity + driver name (truck), or Organization name + district + trucks count; Trust Score; trips together; note; "Available now" dot (`GET /wishlist`).
**Add**: tab "From my trips" (`GET /wishlist/candidates`) and tab "Find organization" (search by name or code, `GET /wishlist/org-search`). Edit note, remove (confirm). Limit message at 20 (`WISHLIST_FULL`). Empty state explains the benefit and links to history.

### LP-06 Payment (inside load detail)
If freight paid by me: **Mark as paid** (amount, mode, reference) → `POST /loads/{id}/payment/mark-paid`. Shows driver confirmation or dispute.

## 3. Farmer Network (`/fn`) — bottom nav: Home · Farmers · Tracking · History · Profile
Same as Load Provider (including Wish list LP-07, reached from Home and Profile) plus:

### FN-01 Registration · `/fn/registration`
Network name, registration number, ID type (CIN/PAN/GSTIN) + number (format check per type), contact person, mobile (prefilled), state, district (filtered), registration certificate (PDF/JPG ≤ 10 MB), certification checkbox. Invalid fields highlighted; Submit disabled until valid → `PUT /me/role-profile`, `POST /me/documents`, `POST /me/verification/submit` → S-06.

### FN-02 Farmers · `/fn/farmers`, `/fn/farmers/new`, `/fn/farmers/{id}`
Search list (name, village, loads, last load). Add/edit: name, mobile, Aadhaar last 4 / offline check (optional), land acres (optional), village, consent → `POST/PUT /farmers`. After save: "Add another" or "Post a load for this farmer".

### FN-03 Post a load
First choice: For our network / For a farmer (pick or add). For a farmer, sender = farmer (locked). Same form as LP-02 with `postedForFarmerId`. Tracking/history show "Posted for" and a farmer filter.

## 4. Driver (`/driver`) — bottom nav: Home · Suggestions · Current trip · History · Profile

### DR-01 Home · `/driver`
On/Off duty switch (`PUT /driver/duty`), truck card, wallet balance or Org name, current trip card, suggestions count, Trust Score, document expiry warnings (`GET /driver/home`). Organization invitation banner (`GET /driver/invitations`).

### DR-02 Driver profile additions (in S-05)
Licence (number, valid until, classes, front/back photos), live selfie photo, ID proof, **Organization**: invitation Accept/Reject, **Truck**: own truck form (number, vehicle type, capacity t, RC, insurance + expiry, national permit + expiry) for owner-drivers; read-only assigned truck for Org drivers. **Locker** `/driver/locker`: documents with status/expiry, replace.

### DR-03 Trip suggestions · `/driver/suggestions`
Only when verified + on duty + enough wallet (else message: "Top up to see trips" / "Go on duty"). Cards: goods, description, pickup date/time, pickup area, quantity/weight, drop area, distance + minutes to pickup, delivery estimate, amount, shipper Trust Score, **"Preferred by this shipper"** tag when `preferredByShipper`. Sort: nearest / amount / earliest. Poll 30 s.
**Accept** → confirm dialog (amount, trip charge) → `POST /driver/suggestions/{loadId}/accept` → DR-04. `LOAD_TAKEN` → snackbar "Taken by another driver" + remove card. **Reject** → reason chips.

### DR-04 Current trip · `/driver/trip`
Details: trip code, goods, description, load provider name + phone (call), receiver name + phone, pickup date/time, exact pickup + drop, quantity, distance/time to pickup, delivery estimate, agreed amount (`GET /driver/current-trip`).
Map: current position, pickup, drop markers, ETA to next point; **Navigate** → Google Maps intent. Layer chips: Petrol · Weighbridge · Puncture · Toll · Restrictions (`GET /map/route-services`, `/map/restrictions`).
Step button (one primary action by status):
- `WAITING_FOR_PICKUP` → **Reached pickup** → `POST /driver/trips/{id}/reached {PICKUP, lat, lng}`; if `outsideRadius` → reason dialog → resend with reason.
- `LOCATION_REACHED` → **Enter pickup OTP** (DR-05).
- `TRAVELING` → **Reached destination**.
- `ARRIVED_DESTINATION` → **Enter delivery OTP**.
- `DELIVERED` → summary, payment section (confirm/dispute), rate.
Secondary: **Request new amount** (until pickup; "x of 5 used"; amount + reason; disabled while one is pending) · **Cancel trip** (before pickup; shows Trust Score impact) · **Report a problem** (after pickup → support).
Background location service runs from acceptance to delivery.

### DR-05 OTP entry (sheet)
"Ask the sender/receiver for the 6-digit code", 6 boxes, expiry countdown (5 min), attempts left, Resend, "Can't get OTP?" (note → `POST /otp/help`). Verify → `POST /driver/trips/{id}/otp/verify` with lat/lng (+ reason if outside radius).

### DR-06 History · `/driver/history`
Trust Score card; month summary (trips, agreed total, confirmed received, pending); trips list (code, date, route, goods, amount, payment status, rating). Detail: timeline, route map, revisions, OTP times, payment **Confirm received / Dispute** (`/payment/confirm|dispute`), ratings.

## 5. Organization (`/org`) — bottom nav: Dashboard · Trucks · Drivers · Trips · Profile

### OR-01 Dashboard · `/org`
Trucks (total, on trip, idle, documents expiring), drivers (on duty, on trip, unallocated), active trips, wallet balance, "Shippers who prefer you" count, Tranix message (`GET /org/dashboard`).

### OR-02 Trucks · `/org/trucks`, `/org/trucks/new`, `/org/trucks/{id}`
List with status chips. Detail: documents (RC, insurance, permit + expiry), trips completed, edit/update documents, deactivate, **Track location** (on trip). Add: number, vehicle type, capacity t, RC, insurance, permit → admin verifies.

### OR-03 Drivers · `/org/drivers`, `/org/drivers/new`, `/org/drivers/{id}`
Add (name, mobile → invitation; driver completes ID and licence in their own app). List: name, contact, allocation status, on duty, Trust Score. Detail: performance (trips, on-time %, earned, confirmed vs pending, rating, cancellations), assign truck.

### OR-04 Allocation · `/org/allocations`
Allocate: select verified unallocated driver → select verified available truck → Confirm. Manage: view, change driver/truck, pause, remove. `ALLOCATION_CONFLICT` → explain. No change during active trip.

### OR-05 Trips · `/org/trips`
Toggle By driver / By truck, filters (date, status), list → load detail (read-only, live location). Export CSV (download via browser link).

## 6. Receiver (`/receiver`, registered) — bottom nav: Loads · History · Notifications · Profile

### RC-01 Incoming loads · `/receiver`
Cards with status and ETA (`GET /receiver/loads?scope=ONGOING`).

### RC-02 Load detail · `/receiver/loads/{id}`
Timeline, live location, driver name/truck/phone. When `ARRIVED_DESTINATION`: **Delivery OTP card** (`GET /loads/{id}/otp`) with "Share only after checking the goods". After delivery: receipt photos + condition (full / shortage-damage + remarks) → `POST /receiver/loads/{id}/receipt`; mark paid if receiver pays; rating.

_(Unregistered receivers use the backend's SMS link page — not part of the app.)_

## 7. Admin (later, Flutter web)

Not in the Android build. Planned routes under `/admin` (dashboard, loads, fleet, verifications, support, users, wallet, cancellations, disputes, location exceptions, broadcasts, settings, audit) using `/api/v1/admin/**`. Until then the admin uses Swagger UI.
