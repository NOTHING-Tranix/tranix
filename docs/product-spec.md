# Tranix MVP — Product Specification

> **Source of truth for business rules.** Derived from "Tranix MVP — Idea, Workflow and Screen-wise Specification" v1.1 (final, 20 Nov 2026).
> Lives once at `docs/product-spec.md` in the project root (shared by `backend/` and `frontend/`).

## 1. What Tranix is

A verified road-freight platform for India. **Load Providers** and **Farmer Networks** post a load with the amount they will pay. Tranix suggests it to suitable, verified **Drivers** nearby; **the first driver to accept gets the trip**. Pickup and delivery are confirmed by OTP. **Receivers** track by app or SMS link. **Organizations** manage trucks and drivers. The **Admin** verifies everyone and handles support.

**Revenue:** prepaid wallet. Posting and accepting need enough balance; a fixed charge is deducted from both sides when a driver accepts. Freight money is paid outside Tranix; Tranix records payment status only.

## 2. Roles and platforms (build plan)

| Role | Code | Main jobs | Platform now | Later |
| --- | --- | --- | --- | --- |
| Load Provider | `LOAD_PROVIDER` | Post loads, wish list of trucks/organizations, answer amount requests, track, mark payment, rate | Android app | Flutter web |
| Farmer Network | `FARMER_NETWORK` | Load Provider features + register farmers and post for them (agent); wish list | Android app | Flutter web |
| Driver | `DRIVER` | Suggestions, accept, amount revision, navigate, OTPs, documents | Android app | — |
| Organization | `ORGANIZATION` | Trucks, drivers, allocation (1 driver ↔ 1 truck), monitoring | Android app | Flutter web |
| Receiver | `RECEIVER` | Track, delivery OTP, receipt, rating, mark paid | SMS link page (server-rendered) + optional app account | — |
| Admin | `ADMIN` | Verification, monitoring, support, refunds, broadcast, settings | Swagger UI / API until the admin panel exists | Flutter web admin |

Two **server-rendered public pages** are part of the backend in the MVP: the **receiver tracking link page** and the **wallet top-up page** (top-up is web-only at launch).

## 3. Accounts and verification

- **Sign up:** mobile (+91, 10 digits), name, role, consent → 6-digit OTP → account created → role home.
- **Sign in:** mobile → OTP. The device stays signed in up to **30 days** (refresh token). OTP again only on a new device, after sign-out or expiry. Too many wrong OTPs → wait 15 min.
- **Profile completion %:** weighted share of the role's required items. At 100% the user taps **Submit for verification**.
- **Verification states:** `NOT_SUBMITTED` → `UNDER_REVIEW` → `VERIFIED` or `NOT_VERIFIED` (per-document reasons, re-upload).
- **What unlocks at `VERIFIED`:** posting (LP, FN), receiving suggestions (Driver), allocating (Org). Before that users can browse and top up.
- **Document expiry:** licence, insurance, permit, RC dates tracked; reminders 30/7/1 days before; an expired document pauses suggestions for that driver/truck until a new one is verified.

### Identity proof (Aadhaar) — confirmed
- Aadhaar verified via **UIDAI offline verification (QR / paperless e-KYC) or DigiLocker**; store only name, verification result and **last 4 digits**.
- **Never** store the full Aadhaar number or an unmasked Aadhaar image. No photocopies.
- **PAN, Voter ID or driving licence** accepted as alternatives (image upload + number, admin-verified).
- Same rule for farmers added by a Farmer Network.

## 4. Wallet and charges — confirmed

- Wallet for LP, FN, owner-driver and Organization. **1 credit = ₹1.**
- **Top-up is web-only at launch:** the app opens a signed, short-lived link to the server-rendered top-up page (payment gateway, UPI/cards). Balance changes only after the gateway's verified webhook. **In-app (Android) top-up is deferred** until Google Play billing rules are verified.
- **Posting** requires balance ≥ posting charge (otherwise → top-up). Nothing is deducted at posting.
- **Suggestions** are shown only to drivers whose wallet (own, or Organization's for Org drivers) covers the trip charge.
- **At acceptance:** fixed posting charge deducted from the shipper and fixed trip charge from the driver/Organization. Amounts set by Admin.
- Transactions: Transaction ID, timestamp, amount, credit/debit, type (`TOPUP`, `POSTING_CHARGE`, `TRIP_CHARGE`, `REFUND`, `ADMIN_CREDIT`), trip ID.
- Wallet money is a prepaid platform balance: not transferable, not withdrawable in the MVP.

## 5. Posting a load

Fields: pickup date + time window; pickup location (map pin + address); sender name + mobile (pre-filled, editable; gets pickup OTP); goods type; description (optional); quantity + unit (bags, crates, boxes, tonnes, litres); approximate weight (tonnes); vehicle type (open, closed, container, refrigerated, tanker, any); drop location (pin + address); receiver name + mobile; **freight paid by** (`SHIPPER` / `RECEIVER`); amount (₹); **offer to** (`EVERYONE` / `WISHLIST_FIRST` / `WISHLIST_ONLY`, see §6A).
- **Delivery estimate** calculated by the server (route distance and drive time from the maps service + loading buffer) and shown before posting.
- Optional: suggested amount range from past trips on similar routes (when data exists).
- Edit only while `NOT_ACCEPTED`.

## 6. Matching and suggestions — confirmed

- **Eligible drivers:** verified, on duty, no active trip, vehicle type and capacity suitable, documents valid, enough wallet, within search radius (start **25 km** from pickup, widen in steps).
- **Ranking weights (starting, admin-adjustable):** distance to pickup 30%, time fit 20%, Trust Score 20%, capacity fit 15%, return-load potential 10%, idle time 5%.
- **Top 5** ranked drivers see it in Trip Suggestions; **5 more added every 10 minutes** if nobody accepts.
- **First driver to tap Accept wins** (single atomic DB operation). Others see "Taken by another driver".
- Suggestion cards show **area/district only**; exact pins, names and **phone numbers are shared only after acceptance**.
- If nobody accepts by the widest radius: shipper is notified → raise amount, change pickup time, keep waiting, or cancel free.

## 6A. Wish list — preferred trucks and organizations (D-19)

Load Providers and Farmer Networks can keep a **wish list** of trucks and Organizations they trust and offer loads to them first.

- **What can be added:** a **truck** (owner-driver's truck or an Organization's truck) or an **Organization** (all its eligible trucks/drivers).
- **How to add:** from a completed or cancelled trip ("Add truck / organization to wish list"), or by searching **verified Organizations** by name or Organization code. Individual trucks can be added only from the shipper's own past trips (no public truck search — privacy). Optional note per entry (e.g. "good with vegetables").
- **Limit:** up to 20 entries (setting). Remove any time. The truck owner / Organization is never told who removed them.
- **When posting, "Offer to":**
  - `EVERYONE` (default) — normal matching (§6). Wish-list drivers who are eligible get a small ranking bonus and appear first in the batch order.
  - `WISHLIST_FIRST` — the load is suggested **only to eligible wish-list trucks/organizations for 15 minutes** (setting); if nobody accepts, it opens to everyone automatically.
  - `WISHLIST_ONLY` — suggested only to the wish list. If nobody accepts within 30 minutes (setting), the shipper is notified and can **Open to everyone**, wait, edit or cancel free.
- The shipper may pick a subset of the wish list for a load (default: whole list).
- **All eligibility rules still apply** (verified, on duty, no active trip, vehicle type, capacity, valid documents, enough wallet). Distance radius is relaxed for wish-list entries up to 100 km from pickup (setting).
- **First accept wins** and all other rules (charges, amount revision, OTP) are unchanged.
- Drivers see a **"Preferred by this shipper"** tag on such suggestions and get a push "A shipper who prefers you posted a load". Organizations see "Shippers who prefer you" count on their dashboard.
- Wish-list status does **not** change Trust Score.

## 7. Amount revision — confirmed

1. Driver accepts at the **posted amount**; trip is locked to that driver.
2. Until pickup, the driver may send an **amount revision request** (amount + reason). **Max 5 per trip.** One pending request at a time.
3. Shipper **Confirms** or **Rejects** within **15 minutes**.
4. Confirm → new agreed amount. Reject or no reply → last agreed amount stays. **The trip continues either way.**
5. A driver who won't continue may cancel before pickup (Section 11).
6. All requests and answers are kept in history.

## 8. Trip statuses

| Status | Code | Set when |
| --- | --- | --- |
| Not accepted | `NOT_ACCEPTED` | Load posted |
| Accepted by driver | `ACCEPTED` | First driver accepts (charges deducted). Logged as a timeline event; the trip moves straight to `WAITING_FOR_PICKUP` |
| Amount negotiation | `AMOUNT_NEGOTIATION` | Revision request pending; returns to `WAITING_FOR_PICKUP` on confirm/reject/timeout |
| Waiting for pickup | `WAITING_FOR_PICKUP` | Trip confirmed; driver going to pickup |
| Location reached | `LOCATION_REACHED` | Driver taps Reached at pickup (pickup OTP sent) |
| Picked up | `PICKED_UP` | Pickup OTP verified |
| Traveling | `TRAVELING` | Automatically right after pickup; live location + ETA |
| Arrived destination | `ARRIVED_DESTINATION` | Driver taps Reached at drop (delivery OTP sent) |
| Delivered | `DELIVERED` | Delivery OTP verified |
| Cancelled | `CANCELLED` | See Section 11 |

Every status change is stored with its time (timeline). A trip is **closed** (`closedAt`) when its payment is `CONFIRMED` or a dispute is resolved.

## 9. OTP at pickup and delivery

- Driver taps **Reached**; server computes distance to the pin (Haversine).
- 6-digit OTP → **pickup**: sender (load provider, or farmer for FN-on-behalf loads) by SMS + in app; **delivery**: receiver by SMS + in app (registered receivers) — **never shown on the SMS link page**.
- Valid **5 min**, **5 attempts**, resend available (old code invalidated).
- Correct OTP **more than 500 m** from the pin → **accepted**, driver must give a reason, event flagged for Admin review (no automatic penalty).
- "Can't get OTP" → help request → Admin may approve an override after checking.

## 10. Payment status — confirmed

- Freight paid outside Tranix. One payment record per trip: payer = `SHIPPER` or `RECEIVER` (chosen at posting), payee = driver.
- `PENDING` → `PAID` (payer marks: amount, mode cash/UPI/bank, optional reference) → `CONFIRMED` (driver) or `DISPUTED` (driver, reason; opens a support ticket).

## 11. Cancellation rules

| Who | When | Charges | Trust Score |
| --- | --- | --- | --- |
| Shipper | Before acceptance | None | No change |
| Shipper | After acceptance, before pickup | Kept; Admin may refund | −5 unless driver at fault |
| Driver | After acceptance, before pickup | Kept; Admin may refund | −5 unless shipper changed details or emergency |
| Anyone | After pickup | Only through Support; Admin decides | Admin decides |

Cancelled loads can be **reposted** with one tap.

## 12. Trust Score and ratings — confirmed (no change)

- Score **0–100** for Drivers, Load Providers, Farmer Networks, Organizations. **Starts at 70.** Stored as an **event ledger**; every change shows trip + reason. Values adjustable by Admin.

| Event | Driver | LP / FN |
| --- | --- | --- |
| Trip completed on time | +2 | +1 |
| Late delivery (beyond ETA + grace) | −2 | — |
| Late pickup by driver | −1 | — |
| Cancelled after acceptance (own fault) | −5 | −5 |
| Rating received 5 / 4 stars | +1 / +0.5 | +1 / +0.5 |
| Rating received 2 / 1 stars | −1 / −2 | −1 / −2 |
| Verified complaint against user | −5 | −5 |
| Payment confirmed on time | — | +1 |
| Payment dispute decided against user | −5 | −5 |
| Admin adjustment (reason required) | ± | ± |

- Score is clamped to 0–100. Organization score derives from its drivers' performance and its own cancellations.
- **Ratings:** after `DELIVERED`, each party gets a **pending rating**; a pop-up asks on the next app open (1–5 stars, quick tags, optional comment). One "Later" allowed, then a reminder in Notifications. Shipper and receiver rate the driver; the driver rates shipper and receiver.

## 13. Notifications

Tabs: **Trips · Wallet · Tranix messages · Account**. Push (FCM) for urgent items; all items listed in the page; home shows latest Tranix message and latest trip update.

| Tab | Examples |
| --- | --- |
| Trips | load accepted; amount request; wish-list load opened to everyone / no response from wish list (shipper); preferred-shipper load posted (driver); driver reached; picked up; running late; delivered; payment marked/confirmed; new suggestion (driver); allocation invite (driver) |
| Wallet | top-up success/failure; charge deducted; refund; low balance |
| Tranix messages | admin broadcasts; support replies |
| Account | verification result; document rejected; document expiry; pending rating reminder |

## 14. Support

- Help form: type (`COMPLAINT`, `FEEDBACK`, `WALLET`, `PAYMENT_DISPUTE`, `OTHERS` + text), trip ID (optional for feedback/others), description, up to 3 photos.
- Ticket history with status `OPEN`/`CLOSED`, unread-reply dot, conversation with Tranix; reopen within 7 days.
- Admin can reply or **ignore** (reason required, closes ticket).

## 15. Farmer Network

- **Registration:** network name, registration number, ID type (CIN/PAN/GSTIN) + number (format-checked), contact person, mobile, state, district, registration certificate (PDF/JPG ≤ 10 MB), certification checkbox. Invalid fields highlighted; submit disabled until valid.
- **Verification page:** Under review (estimated time, submitted items: date Logged, certificate Attached, contact OTP validated, Check updates) · Not verified (issues + Upload documents) · Verified (Next: Farmer details).
- **Farmers:** name, mobile, Aadhaar (offline check or last 4, optional), land holding acres (optional), village, consent. List/search/edit/deactivate.
- **Post for a farmer:** farmer is the sender (gets pickup OTP + SMS link). Charges from the FN wallet. "Posted for" label and farmer filter in tracking/history.

## 16. Driver specifics

- One truck only for owner-drivers (number, type, capacity, RC, insurance+expiry, national permit+expiry). Organization drivers get the truck assigned (read-only).
- Organization invitations: driver can only **Accept** or **Reject**.
- **On duty / Off duty** switch; only on-duty drivers get suggestions.
- **Current trip:** details, in-app map with pickup/drop markers and route ETA, **Navigate** opens Google Maps turn-by-turn, advanced map layers (petrol bunks, weighbridges, puncture shops, toll plazas, heavy-vehicle entry restrictions/no-entry timings), step buttons (Reached pickup → pickup OTP → [Traveling auto] → Reached destination → delivery OTP), amount request (x of 5), cancel before pickup, report problem after pickup.
- Background location during trips; offline buffering.
- History: Trust Score, monthly earnings (trips, agreed total, confirmed received, pending), trips with payment status and ratings.

## 17. Organization specifics

- Trucks: list (status `AVAILABLE`, `ALLOCATED`, `ON_TRIP`, `DOCUMENTS_PENDING`, `INACTIVE`), detail, add (admin verifies), track location.
- Drivers: add (name, mobile, ID proof, licence) → invitation → driver accepts → admin verifies; list; performance (trips, on-time %, earned, payments, rating, cancellations).
- Allocation rules: one driver ↔ one truck; only verified + available; no change during an active trip.
- Trips by driver / by truck; CSV export. Organization wallet pays its drivers' trip charges.

## 18. Receiver

- **SMS link page** (no account): load ID, sender, goods, quantity, timeline, live location + ETA, driver name, truck number, phone; delivery-OTP notice (code sent by SMS, never shown); after delivery: receipt photo, condition (full / shortage-damage), rating, mark paid (if receiver pays). Link expires **7 days after delivery**.
- **Registered receiver (app):** incoming loads, delivery OTP shown in app, history, pending ratings.

## 19. Admin

Dashboard (active loads, active fleet, pending verifications, open support, total freight with status split, **route status Normal / Slow / Fast = ETA within ±10% / >10% late / >10% early**, reminders, top-ups today, cancellations and location exceptions to review) · Active loads (10 per page, "See more", search) · Active fleet · Pending verifications (tabs: driver, vehicle, Farmer Network, Organization, LP/receiver IDs; approve / not approved with reason) · Feedback & support · Users · Wallet & refunds · Cancellations & disputes · Broadcast messages (all / role / district / one user; now or scheduled) · Settings · Audit log · OTP overrides and location exceptions.
Admin sign-in: mobile + OTP for allow-listed numbers; 30-min inactivity timeout; authenticator 2FA before launch.

## 20. Languages

English, Tamil, Hindi at launch (all app strings and SMS templates).

## 21. Out of MVP

Part loads; freight payment/escrow; percentage charges; in-app chat; masked calls; e-way bill; government APIs for licence/RC; multiple admin roles; FN staff logins; in-app Android top-up (until billing verified).
