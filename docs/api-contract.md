# Tranix API Contract (v1)

> **The agreement between `backend/` (Spring Boot) and `frontend/` (Flutter).** One copy at `docs/api-contract.md` in the project root.
> Backend implements exactly this; the app calls exactly this. Change it first, then both sides in the same commit, and note behaviour changes in `docs/decisions.md`.
> The backend also publishes OpenAPI at `/v3/api-docs` and Swagger UI at `/swagger-ui.html`; this file is the human-readable plan, OpenAPI is generated truth once built.

## 1. Conventions

- Base URL: `https://<host>/api/v1`. JSON, UTF-8. Field names `camelCase`.
- Auth: `Authorization: Bearer <accessToken>` (JWT, 15 min). Refresh token valid 30 days, rotated on every refresh.
- IDs: UUID strings. Money: integer rupees (`amountInr`). Times: ISO-8601 UTC (`2026-11-20T10:15:00Z`). Coordinates: `{ "lat": 10.95, "lng": 78.08 }`.
- Pagination: `?page=0&size=20` → `{ "items": [...], "page": 0, "size": 20, "total": 134 }`. Newest first unless stated.
- Language: `Accept-Language: en | ta | hi` (server-generated messages and SMS).
- Request ID: every response has `X-Request-Id` (a client-sent `X-Request-Id`, 8-64 chars `[A-Za-z0-9-]`, is reused); quote it to support.
- Rate limits: `/auth/**` and the public link paths (`/public/**`, `/p/track/**`) are limited per client IP per minute (settings in config) → `429 RATE_LIMITED` with `Retry-After: 60`.
- Errors: RFC 7807 Problem JSON with a stable `code`:

```json
{ "type": "about:blank", "title": "Insufficient wallet balance", "status": 409,
  "code": "INSUFFICIENT_BALANCE", "detail": "Posting needs ₹50", "fields": [] }
```

| Code | HTTP | Meaning |
| --- | --- | --- |
| `VALIDATION_FAILED` | 400 | `fields: [{field, message}]` |
| `UNAUTHENTICATED` / `TOKEN_EXPIRED` | 401 | Refresh or sign in again |
| `FORBIDDEN` | 403 | Wrong role or not owner |
| `NOT_VERIFIED` | 403 | Account not `VERIFIED` for this action |
| `NOT_FOUND` | 404 | |
| `OTP_INVALID` / `OTP_EXPIRED` / `OTP_LOCKED` | 400/400/429 | |
| `MOBILE_IN_USE` | 409 | Sign-up with an existing number |
| `INSUFFICIENT_BALANCE` | 409 | Wallet below the required charge |
| `LOAD_TAKEN` | 409 | Another driver accepted first |
| `INVALID_STATE` | 409 | Action not allowed in current status |
| `REVISION_LIMIT_REACHED` | 409 | 5 amount requests already used |
| `REVISION_PENDING` | 409 | A request is already waiting |
| `ALLOCATION_CONFLICT` | 409 | Driver or truck already allocated / on trip |
| `WISHLIST_FULL` | 409 | Wish list limit reached |
| `WISHLIST_EMPTY` | 409 | Posting with WISHLIST_FIRST/ONLY but no usable entries |
| `RATE_LIMITED` | 429 | |
| `LINK_EXPIRED` | 410 | Public tracking link expired (no load data returned) |

## 2. Enums

```
Role: LOAD_PROVIDER | FARMER_NETWORK | DRIVER | ORGANIZATION | RECEIVER | ADMIN
VerificationStatus: NOT_SUBMITTED | UNDER_REVIEW | VERIFIED | NOT_VERIFIED
DocumentType: AADHAAR_OFFLINE | PAN | VOTER_ID | DRIVING_LICENCE | PHOTO | RC | INSURANCE | NATIONAL_PERMIT |
              FN_REGISTRATION_CERT | ORG_REGISTRATION_CERT | GST_CERT
DocumentStatus: PENDING | APPROVED | REJECTED
LoadStatus: NOT_ACCEPTED | ACCEPTED | AMOUNT_NEGOTIATION | WAITING_FOR_PICKUP | LOCATION_REACHED | PICKED_UP |
            TRAVELING | ARRIVED_DESTINATION | DELIVERED | CANCELLED
QuantityUnit: BAGS | CRATES | BOXES | TONNES | LITRES
VehicleType: OPEN_BODY | CLOSED_BODY | CONTAINER | REFRIGERATED | TANKER | ANY
FreightPayer: SHIPPER | RECEIVER
RevisionStatus: PENDING | CONFIRMED | REJECTED | EXPIRED
OtpPurpose: SIGN_UP | SIGN_IN | CHANGE_MOBILE | PICKUP | DELIVERY
PaymentStatus: PENDING | PAID | CONFIRMED | DISPUTED
PaymentMode: CASH | UPI | BANK
TxnType: TOPUP | POSTING_CHARGE | TRIP_CHARGE | REFUND | ADMIN_CREDIT
TxnDirection: CREDIT | DEBIT
SuggestionRejectReason: TOO_FAR | LOW_AMOUNT | WRONG_TRUCK | OTHER
TruckStatus: AVAILABLE | ALLOCATED | ON_TRIP | DOCUMENTS_PENDING | INACTIVE
TicketType: COMPLAINT | FEEDBACK | WALLET | PAYMENT_DISPUTE | OTHERS
TicketStatus: OPEN | CLOSED
NotificationTab: TRIPS | WALLET | TRANIX | ACCOUNT
RouteStatus: NORMAL | SLOW | FAST
LoadAudience: EVERYONE | WISHLIST_FIRST | WISHLIST_ONLY
WishlistTargetType: TRUCK | ORGANIZATION
Language: en | ta | hi
```

## 3. Auth

| Method & path | Body → Response | Notes |
| --- | --- | --- |
| `POST /auth/otp/send` | `{mobile, purpose: SIGN_UP\|SIGN_IN}` → `204` | Always 204 for SIGN_IN (no account enumeration). 30 s resend cooldown |
| `POST /auth/sign-up` | `{mobile, otp, name, role, consent: true, language, deviceId?}` → `AuthTokens` | Role ≠ ADMIN. `MOBILE_IN_USE`. Resend cooldown → `429 RATE_LIMITED` |
| `POST /auth/sign-in` | `{mobile, otp, deviceId}` → `AuthTokens` | |
| `POST /auth/refresh` | `{refreshToken}` → `AuthTokens` | Rotates refresh token |
| `POST /auth/sign-out` | `{refreshToken}` → `204` | |

`AuthTokens = { accessToken, refreshToken, expiresIn, user: Me }`

## 4. Me, profile, documents, verification

| Method & path | Notes |
| --- | --- |
| `GET /me` | `Me = {id, name, mobile, role, language, photoUrl, verificationStatus, profileCompletion (0–100), trustScore, walletBalanceInr?, pendingRatingsCount, unreadNotifications}` |
| `PUT /me` | `{name, email?, language, address{line, village, district, state, pin}}` |
| `POST /me/mobile/change` `{mobile}` → 204 + `POST /me/mobile/verify` `{mobile, otp}` → `Me` | OTP to the new mobile; `MOBILE_IN_USE`; audited |
| `GET /me/address` · `GET /me/role-profile` | Saved address / role-profile fields (to prefill forms) |
| `PUT /me/role-profile` | Role-specific fields (see §4.1) |
| `POST /files` (multipart `file`) | → `{fileId}`; PDF/JPG/PNG ≤ 10 MB (type checked by content) |
| `GET /files/{id}/content?exp=&sig=` | No JWT. The signed `viewUrl` returned with documents/receipts points here; valid 5 min, else `403 FORBIDDEN` |
| `POST /me/documents` | `{type, fileIds[], number?, expiresOn?}` → `Document`. Creates or replaces the one document of that type. Allowed: PHOTO, PAN, VOTER_ID, DRIVING_LICENCE (+ FN/ORG registration cert, GST_CERT by role). Number required for PAN/VOTER_ID/DRIVING_LICENCE/GST_CERT; expiry for DRIVING_LICENCE |
| `PUT /me/documents/{id}` | Replace a rejected/expiring document |
| `GET /me/documents` | `[Document{id, type, numberMasked, expiresOn, status, rejectReason, viewUrl (signed, 5 min)}]` |
| `POST /me/aadhaar/offline` | `{qrPayload \| ekycZip+shareCode}` → `{verified, last4, name}` (provider adapter; see open questions) |
| `GET /me/verification` | `{status, items:[{key, label, done, weight}], documents[], estimatedReviewHours}`. Item keys: NAME, PHOTO, ADDRESS, ID_PROOF, ROLE_PROFILE, FN_REGISTRATION_CERT, DRIVING_LICENCE, ORG_REGISTRATION_CERT |
| `POST /me/verification/submit` | Only at 100% → `UNDER_REVIEW` |
| `POST /me/devices` | `{fcmToken, platform: ANDROID}` |

### 4.1 Role profiles (`PUT /me/role-profile`)
- **LOAD_PROVIDER:** `{accountType: INDIVIDUAL|BUSINESS, businessName?, gstin?}`
- **FARMER_NETWORK:** `{networkName, registrationNumber, idType: CIN|PAN|GSTIN, idNumber, contactPerson, state, district}`
- **DRIVER:** `{licenceNumber, licenceValidUntil, vehicleClasses[], emergencyContact?}`
- **ORGANIZATION:** `{orgName, contactPerson, gstin?, pan?}`
- **RECEIVER:** `{businessName?}`

## 5. Wallet

| Method & path | Notes |
| --- | --- |
| `GET /wallet` | `{balanceInr, postingChargeInr, tripChargeInr, lowBalance}` |
| `GET /wallet/transactions?type=&month=YYYY-MM&page=&size=` | Paged `[{txnId, at, amountInr, direction: CREDIT\|DEBIT, type, loadId?, note?}]` |
| `POST /wallet/topup-link` | `{amountInr}` (₹100–₹50,000, settings) → `{url, expiresAt}` — app opens `url` in the browser (server page `/p/wallet/topup?t=...`, 15 min). `RECEIVER`/`ADMIN` have no wallet → `403 FORBIDDEN` |
| `POST /webhooks/payments` | Gateway webhook, header `X-Razorpay-Signature` (Razorpay, HMAC-SHA256 of the raw body) or `X-Signature` (fake gateway); signature-verified, idempotent by event and order. Not called by the app |
| `GET /p/wallet/topup/done?lang=` | Server page the gateway returns to after checkout ("payment received, return to the app"); the wallet is credited only by the webhook |
| `GET /wallet/statement?month=YYYY-MM` | PDF download (JWT) |

## 6. Loads (shipper side: LOAD_PROVIDER, FARMER_NETWORK)

| Method & path | Notes |
| --- | --- |
| `POST /loads/estimate` | `{pickup:{lat,lng}, drop:{lat,lng}, pickupWindowStart, vehicleType?}` → `{distanceKm, driveMinutes, deliveryEta, suggestedAmountRange?: {minInr, maxInr}}` |
| `POST /loads` | `LoadCreate` → `Load`. Checks `NOT_VERIFIED`, `INSUFFICIENT_BALANCE` |
| `GET /loads?scope=ONGOING\|HISTORY&farmerId=&q=&page=` | `[LoadSummary]` |
| `GET /loads/{id}` | `LoadDetail` |
| `PUT /loads/{id}` | Only `NOT_ACCEPTED` |
| `POST /loads/{id}/cancel` | `{reason, note?}` → `LoadDetail`. `reason` from settings `lists.cancel_reasons_shipper` (note required for OTHER). After pickup → `INVALID_STATE` (support only). `LoadDetail.cancelInfo = {chargesKept, trustScorePenalty, supportOnly}` shows the outcome before confirming |
| `POST /loads/{id}/repost` | → new `Load` |
| `GET /loads/{id}/tracking` | `{driverLocation{lat,lng,at}, etaAt, routeStatus}` (poll 30 s) |
| `GET /loads/{id}/otp` | `{purpose, code, expiresAt}` — only for the sender (pickup) / registered receiver (delivery) while active |
| `POST /loads/{id}/revisions/{revisionId}/confirm` · `/reject` | Shipper answers an amount request |
| `POST /loads/{id}/payment/mark-paid` | `{amountInr, mode, reference?}` (payer = shipper) |
| `POST /loads/{id}/open-to-everyone` | Wish-list load → normal matching now |

```
LoadCreate = { pickupWindowStart, pickupWindowEnd, pickup:{lat,lng,address,landmark?},
  senderName, senderMobile, goodsType, description?, quantity, quantityUnit, weightTonnes,
  vehicleType, drop:{lat,lng,address,landmark?}, receiverName, receiverMobile,
  freightPaidBy, amountInr, postedForFarmerId?,
  audience (default EVERYONE), wishlistEntryIds? (subset; default = whole list) }
LoadSummary = { id, code ("TRX-000123"), status, goodsType, description, quantity, quantityUnit,
  pickupArea, dropArea, pickupWindowStart, agreedAmountInr, paymentStatus?, postedForFarmerName? }
LoadDetail = LoadSummary + { pickup, drop, senderName, senderMobile, receiverName, receiverMobile,
  weightTonnes, vehicleType, freightPaidBy, postedAmountInr, deliveryEta,
  timeline:[{status, at}], driver?:{id, name, photoUrl, mobile, trustScore, truckNumber, vehicleType},
  revisions:[{id, requestedAmountInr, reason, status, createdAt, respondBy}], revisionsUsed,
  payment?:{status, amountInr, mode, reference, paidAt, confirmedAt, disputeReason},
  otpEvents:[...], locationExceptions:[...], canEdit, canCancel, cancelInfo?,
  audience, wishlistUntil?, openedToEveryoneAt? }
```

## 6A. Wish list (LOAD_PROVIDER, FARMER_NETWORK)

| Method & path | Notes |
| --- | --- |
| `GET /wishlist` | `[WishlistEntry{id, targetType, truckNumber?, vehicleType?, capacityTonnes?, driverName?, orgId?, orgName?, trustScore, tripsTogether, note?, available (any eligible now)}]` |
| `POST /wishlist` | `{targetType, truckId? \| orgId?, note?}` → `WishlistEntry`. Truck must come from my past trips (`FORBIDDEN` otherwise); `WISHLIST_FULL` |
| `PUT /wishlist/{id}` | `{note}` |
| `DELETE /wishlist/{id}` | Remove |
| `GET /wishlist/org-search?q=` | Verified Organizations by name or code (≥ 2 chars): `[{orgId, orgName, orgCode ("ORG-1A2B3C"), district, trustScore, trucksCount}]` |
| `GET /wishlist/candidates` | Trucks and Organizations from my past trips not yet in the list: `[{targetType, truckId?, truckNumber?, vehicleType?, driverName?, orgId?, orgName?, tripsTogether, lastTripAt}]` |

## 7. Farmers (FARMER_NETWORK)

`GET /farmers?q=&page=` · `POST /farmers` `{name, mobile, aadhaarLast4?, landAcres?, village, consent:true}` · `PUT /farmers/{id}` · `POST /farmers/{id}/deactivate`

`Farmer = {id, name, mobile, aadhaarLast4?, landAcres?, village, active, createdAt}`; list is paged `{items, page, size, total}` (`includeInactive=true` shows deactivated). POST/PUT need a VERIFIED Farmer Network; duplicate mobile → `VALIDATION_FAILED` on `mobile`; `consent` must be true. Posting with `postedForFarmerId` makes the farmer the locked sender (pickup OTP + `SENDER_TRACKING` SMS at acceptance); charges from the FN wallet; `LoadSummary.postedForFarmerName` is set.

## 8. Driver

| Method & path | Notes |
| --- | --- |
| `PUT /driver/duty` | `{onDuty}` |
| `GET /driver/home` | `{onDuty, truck?, walletBalanceInr?, orgName?, currentLoadId?, suggestionsCount, trustScore, expiringDocuments[]}` |
| `GET/POST/PUT /driver/truck` | Owner-driver only: `{number, vehicleType, capacityTonnes}`; truck documents via `POST /driver/truck/documents {type: RC|INSURANCE|NATIONAL_PERMIT, fileIds, number, expiresOn}`. Truck view `{id, number, vehicleType, capacityTonnes, status, documents[], allocatedDriver?, ownedByMe}` |
| `GET /driver/suggestions?sort=NEAREST\|AMOUNT\|EARLIEST` | `[Suggestion{loadId, goodsType, description, quantity, unit, weightTonnes, pickupArea, dropArea, pickupWindowStart, distanceToPickupKm, minutesToPickup, deliveryEta, amountInr, shipperTrustScore, preferredByShipper}]` (poll 30 s while open). Empty list when off duty, not verified or the payer wallet is below the trip charge |
| `POST /driver/suggestions/{loadId}/accept` | → `LoadDetail` or `LOAD_TAKEN` / `INSUFFICIENT_BALANCE` |
| `POST /driver/suggestions/{loadId}/reject` | `{reason?: TOO_FAR\|LOW_AMOUNT\|WRONG_TRUCK\|OTHER}` |
| `GET /driver/current-trip` | `LoadDetail` with exact locations, contacts; `204` when there is no active trip |
| `POST /driver/trips/{loadId}/revisions` | `{amountInr, reason}` → `REVISION_LIMIT_REACHED`, `REVISION_PENDING`, `INVALID_STATE` after pickup |
| `POST /driver/trips/{loadId}/reached` | `{purpose: PICKUP|DELIVERY, lat, lng, reason?}` → `{distanceM, outsideRadius, otpSentTo}`. Outside 500 m without `reason` → nothing changes and `otpSentTo` is null (send again with a reason). `otpSentTo` is a masked mobile |\|DELIVERY, lat, lng, reason?}` → `{distanceM, outsideRadius, otpSentTo}` |
| `POST /driver/trips/{loadId}/otp/verify` | `{purpose, code, lat, lng, reason?}` → `LoadDetail` |
| `POST /driver/trips/{loadId}/otp/resend` | `{purpose}` |
| `POST /driver/trips/{loadId}/otp/help` | `{purpose, lat, lng, note}` |
| `POST /driver/trips/{loadId}/locations` | `[{lat, lng, speed?, at}]` batch (every 30 s, buffered offline) |
| `POST /driver/trips/{loadId}/cancel` | `{reason, note?}` (before pickup) |
| `POST /driver/trips/{loadId}/payment/confirm` · `/dispute` | `{amountInr}` · `{reason}` |
| `GET /driver/history?month=&page=` | `{summary{trips, agreedTotalInr, confirmedInr, pendingInr}, items[]}` |
| `GET /driver/invitations` · `POST /driver/invitations/{id}/accept` · `/reject` | Organization invites |
| `GET /map/route-services?bbox=&types=` | Petrol bunks, weighbridges, puncture shops, tolls |
| `GET /map/restrictions?bbox=` | Entry restrictions / no-entry timings `[{id, name, lat, lng, radiusKm, noEntryFrom, noEntryTo, vehicleTypes, note}]`. `bbox=minLng,minLat,maxLng,maxLat` (≤ 5°); route services `[{id, type, name, lat, lng}]` |

## 9. Organization

| Method & path | Notes |
| --- | --- |
| `GET /org/dashboard` | Truck/driver counts, active trips, wallet, `preferredByShippersCount` |
| `GET /org/trucks` · `POST /org/trucks` · `PUT /org/trucks/{id}` · `POST /org/trucks/{id}/deactivate` | Truck docs via `POST /org/trucks/{id}/documents` |
| `GET /org/trucks/{id}/location` | Live location if on trip |
| `GET /org/drivers` · `POST /org/drivers` (invite: `{name, mobile}`) · `GET /org/drivers/{id}/performance` | |
| `POST /org/allocations` `{driverId, truckId}` · `GET /org/allocations` · `PUT /org/allocations/{id}` · `DELETE /org/allocations/{id}` | `ALLOCATION_CONFLICT` |
| `GET /org/trips?by=DRIVER\|TRUCK&id=&from=&to=&status=` · `GET /org/trips/export` | CSV |

## 10. Receiver

- App (registered): `GET /receiver/loads?scope=` · `GET /receiver/loads/{id}` · delivery OTP via `GET /loads/{id}/otp` · `POST /receiver/loads/{id}/receipt` · `POST /loads/{id}/payment/mark-paid` (if receiver pays).
- **Public link (no JWT, token in path):** server page `GET /p/track/{token}`; JSON for the page: `GET /api/v1/public/track/{token}`, `POST /api/v1/public/track/{token}/receipt` `{fileIds[], condition: FULL|SHORTAGE_DAMAGE, remarks?}`, `POST .../rating`, `POST .../payment/mark-paid`. Expired → `410` with no load data.
- Public JSON `GET /api/v1/public/track/{token}` → `{code, status, audience: RECEIVER|SENDER, senderName, receiverName, goodsType, description, quantity, quantityUnit, pickupArea, dropArea, timeline[], driver?{name, truckNumber, mobile}, tracking?{driverLocation, etaAt, routeStatus}, deliveryOtpNotice, receipt?{condition, remarks, fileIds, at}, freightPaidBy, payment?, canSubmitReceipt, canRate, canMarkPaid, expiresAt}`. Never contains an OTP. Photos: `POST /api/v1/public/track/{token}/files` (multipart `file`) → `{id}`; receipt `{fileIds[1..5], condition, remarks?}` (remarks required for SHORTAGE_DAMAGE; once per load); rating `{stars, tags?, comment?}` once; SENDER links (farmer) are read-only. Links are sent by SMS at acceptance (`RECEIVER_TRACKING`, `SENDER_TRACKING` with `link`) and expire 7 days (setting) after delivery/cancellation → `410 LINK_EXPIRED`.
- App: `GET /receiver/loads?scope=ONGOING|HISTORY` → `[LoadSummary + deliveryEta]`; `GET /receiver/loads/{id}` → `LoadDetail + {receipt?, canSubmitReceipt}` (payment only when the receiver pays); `POST /receiver/loads/{id}/receipt` same body as the link (files from `POST /files`).

## 11. Ratings, Trust Score, notifications, support

| Method & path | Notes |
| --- | --- |
| `GET /ratings/pending` | `[{loadId, loadCode, rateeUserId, rateeName, rateeRole, laterUsed}]` — app shows pop-up on open |
| `POST /ratings` | `{loadId, rateeUserId, stars 1–5, tags[], comment?}` |
| `POST /ratings/{loadId}/later` | One "Later" per pending rating (second → `INVALID_STATE`) |
| `GET /trust-score` | `{score, updatedAt, trend[]}` |
| `GET /trust-score/events?page=` | `[{at, loadId?, event, points, reason}]` |
| `GET /notifications?tab=&page=` · `POST /notifications/{id}/read` · `POST /notifications/read-all` · `GET /notifications/summary` | Item `{id, tab, type, title, body, route?, read, createdAt}` (paged). Summary `{unreadByTab, latestTranixMessage?, latestTripUpdate?}` (items or null). Push data: `{notificationId, tab, route?}` |
| `GET /tickets` · `POST /tickets` `{type, otherText?, loadId?, description, fileIds[]}` · `GET /tickets/{id}` · `POST /tickets/{id}/messages` `{body, fileIds?}` · `POST /tickets/{id}/reopen` | `Ticket = {id, code ("TKT-000123"), type, otherText?, status, loadId?, loadCode?, description, unread, closeReason?, createdAt, updatedAt, closedAt?}`; detail adds `{fileIds, canReopen, messages:[{id, author: USER|ADMIN|SYSTEM, body, fileIds, at}]}`. `otherText` required for OTHERS, `loadId` required for COMPLAINT / PAYMENT_DISPUTE; ≤ 3 photos; messages only while OPEN; reopen within `support.reopen_days` (7). Payment disputes and receipt shortage/damage open tickets automatically. Opening a ticket clears `unread`. |

## 12. Settings for clients

`GET /settings/public` → `{postingChargeInr, tripChargeInr, topupChips:[500,1000,2000], otpTtlSeconds:300, otpResendSeconds:30, revisionLimit:5, revisionResponseMinutes:15, geofenceMeters:500, wishlistMax:20, wishlistFirstMinutes:15, wishlistOnlyNotifyMinutes:30, goodsTypes[], vehicleTypes[], ticketTypes[], rejectReasons[], supportedLanguages[], ratingTags[], aadhaarEnabled}` — `aadhaarEnabled` hides the Aadhaar option until a provider is set up (Q-04)

## 13. Admin (`/api/v1/admin/**`, role ADMIN)

`/admin/payment-disputes/{loadId}/decide {decision: AGAINST_PAYER|AGAINST_DRIVER|NO_FAULT}` · `/admin/trust-score/{userId}/adjust {points, reason}` · `/admin/dashboard` · `/admin/loads?status=&q=&page=` (10 per page) · `/admin/loads/{id}` (+ `/cancel`, `/otp-override`) · `/admin/fleet?q=&page=` · `/admin/verifications?tab=DRIVER|VEHICLE|FARMER_NETWORK|ORGANIZATION|IDENTITY` · `/admin/documents/{id}/approve|reject` · `/admin/users` (+ `/suspend`, `/reactivate`) · `/admin/wallet/{userId}/credit|refund` · `/admin/cancellations` (+ `/decide`) · `/admin/payment-disputes` (+ `/decide`) · `/admin/location-exceptions` (+ `/review`) · `/admin/tickets?status=` (+ `/{id}`, `/{id}/reply {body, close?}`, `/{id}/ignore {reason}`) · `/admin/trust-score/{userId}/adjust` · `/admin/broadcasts` (`POST {title, body, audience: ALL|ROLE|DISTRICT|USER, role?, district?, userId?, sendAt?}` → inbox "Tranix messages" + push; `GET` list) · `/admin/settings` · `/admin/audit`.

Admin details (M14): lists are paged `{items, page, size, total}` (loads/fleet/users 10 per page, audit 50). `GET /admin/dashboard` → `{openLoads, activeLoads, activeFleet{driversOnDuty, trucks}, pendingVerifications, openSupport, freight{totalInr, pending, paid, confirmed, disputed}, routeStatus{NORMAL, SLOW, FAST}, reminders{cancellationsToReview, locationExceptionsToReview, paymentDisputes, otpHelpRequests}, topupsTodayInr, cancellationsToday}`. `GET /admin/loads?status=&q=` (q = code, area or mobile; default = not finished); `GET /admin/loads/{id}` = LoadDetail + `{tracking, cancellations, locationExceptionsReview, otpHelp}`; `POST /admin/loads/{id}/cancel {reason}` (any status before DELIVERED, charges stay, no penalty); `POST /admin/loads/{id}/otp-override {purpose: PICKUP|DELIVERY, reason}` (only at that step). `POST /admin/users/{id}/suspend|reactivate {reason}` (suspend signs the user out). `GET /admin/cancellations?pending=`, `POST /admin/cancellations/{id}/decide {decision: UPHOLD|REVERSE, reason}` (REVERSE returns the Trust Score points). `GET /admin/location-exceptions?status=`, `POST .../{id}/review {decision: OK|FLAGGED, note?}`. `GET /admin/settings`, `PUT /admin/settings/{key} {value, reason}` (typed; ranking weights must total 100). `GET/POST /admin/map-restrictions`, `PUT /admin/map-restrictions/{id}`, `DELETE` = deactivate. `GET /admin/audit?entity=&actorId=&action=`. Admin sessions end after 30 idle minutes (`TOKEN_EXPIRED` on refresh); only allow-listed mobiles (`ADMIN_MOBILES`) can sign in as admin.
Until the Flutter web admin exists, these are used through Swagger UI with an admin token.

## 14. Legal and account deletion

| Method & path | Notes |
| --- | --- |
| `GET /legal/privacy` · `GET /legal/terms` | No JWT. `{doc, version, status, text}`; `status = DRAFT_PENDING_LEGAL_REVIEW` until Q-08 is closed |
| `POST /me/deletion-request` | `{reason?}` → `Ticket` (type OTHERS, `otherText = "Account deletion"`); Tranix processes it within the legal retention rules |
