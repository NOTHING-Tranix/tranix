# Decisions Log

Final decisions for the Tranix MVP. One copy at `docs/decisions.md` in the project root. **Do not contradict a decision; add a new one that supersedes it.**
This log replaces the earlier v0 decision set (D-001–D-050 from the first backend kit), which is no longer valid.

| ID | Date | Decision |
| --- | --- | --- |
| D-01 | 2026-11-20 | Product spec = "Tranix MVP — Idea, Workflow and Screen-wise Specification" v1.1 (final), summarised in `docs/product-spec.md`. |
| D-02 | 2026-11-20 | Six roles: Load Provider, Farmer Network, Driver, Organization, Receiver, Admin. |
| D-03 | 2026-11-20 | **Aadhaar:** UIDAI offline verification or DigiLocker; store only last 4 digits + result; no Aadhaar photocopies; PAN, Voter ID or driving licence accepted. |
| D-04 | 2026-11-20 | **Sign-in:** mobile + OTP; device session up to 30 days (refresh token); OTP again only on new device, sign-out or expiry. |
| D-05 | 2026-11-20 | **Amount revision:** driver accepts at posted amount; up to 5 requests before pickup; shipper confirms/rejects within 15 min; reject or no reply keeps last amount; trip continues. |
| D-06 | 2026-11-20 | **Suggestions:** eligible drivers ranked; top 5 first, 5 more every 10 min; first accept wins (atomic). |
| D-07 | 2026-11-20 | **Charges:** fixed posting charge (shipper) and trip charge (driver/Organization) deducted at acceptance; amounts set by Admin; 1 credit = ₹1. |
| D-08 | 2026-11-20 | **Phone numbers** and exact locations shown only after acceptance. |
| D-09 | 2026-11-20 | **Freight payer** chosen at posting: shipper or receiver. Freight paid outside Tranix; Tranix records payment status. |
| D-10 | 2026-11-20 | **Trust Score:** 0–100, start 70, event ledger with points as in product spec §12, admin-adjustable. No further clarification. |
| D-11 | 2026-11-20 | **Route status:** Normal within ±10% of planned time; Slow > 10% late; Fast > 10% early. |
| D-12 | 2026-11-20 | **Languages:** English, Tamil, Hindi at launch. |
| D-13 | 2026-11-20 | **Wallet top-up:** web only at launch (server-rendered top-up page opened from the app). Android in-app top-up deferred until Google Play billing rules are verified. |
| D-14 | 2026-11-20 | _(Superseded by D-20.)_ Two separate repos. |
| D-15 | 2026-11-20 | **Platforms:** Android app for all roles first. Flutter web (shipper/Organization web and Admin panel) later from the same Flutter codebase; until then Admin uses Swagger UI. Receiver link page and top-up page are server-rendered by the backend. |
| D-16 | 2026-11-20 | **Flutter stack:** Riverpod, go_router, dio, freezed/json_serializable, flutter_secure_storage, Firebase Cloud Messaging, google_maps_flutter, geolocator (+ background location), flutter_localizations/intl (ARB). |
| D-17 | 2026-11-20 | **Backend stack:** Java 21, Spring Boot 3, Maven, PostgreSQL + Flyway, Spring Security + JWT, Spring Modulith-style modules, Testcontainers, Docker, AWS. Outside services (SMS, push, maps, payment gateway, file storage, Aadhaar provider) behind interfaces with fake implementations first. |
| D-18 | 2026-11-20 | **Real-time:** FCM push for events + polling while a screen is open (suggestions 30 s, tracking 30 s). No WebSockets in the MVP. Geo distance with Haversine (no PostGIS). |
| D-19 | 2026-11-20 | **Wish list:** Load Providers and Farmer Networks keep a wish list (max 20) of preferred **trucks** (from their own past trips) and **Organizations** (search verified orgs). When posting they choose Offer to: Everyone (wish list gets a ranking bonus), Wish list first (15 min, then everyone automatically) or Wish list only (notify shipper after 30 min; shipper can open to everyone). All eligibility rules, first-accept-wins, charges and OTP rules unchanged. Values are admin settings. |
| D-20 | 2026-11-20 | **Project layout (supersedes D-14):** one project folder with `backend/` (Spring Boot) and `frontend/` (Flutter). Shared docs live once in the root `docs/`; root `CLAUDE.md` coordinates both; each subfolder has its own `CLAUDE.md` and `TODO.md`. Claude Code is run from the project root. |
| D-21 | 2026-11-21 | **Backend versions (refines D-17, approved by founder 2026-11-21):** the existing project is Spring Boot **4.1.x** (not 3.x) with base package `com.nothing.tranix`; keep both (Boot 3.5 OSS support has ended). Pairs with Spring Modulith 2.1.x, springdoc 3.x, Testcontainers 2.x, Jackson 3. Settings access lives in the open `shared` module (`shared.settings`) so other modules can read settings without a cycle; the `admin` module owns admin endpoints. |
| D-22 | 2026-11-21 | **Goods types (closes Q-13):** default list Vegetables, Fruits, Grains, Pulses, Spices, Fertilizer, Building material, FMCG, Other in setting `lists.goods_types`; Admin can edit it. |
| D-23 | 2026-11-21 | **Profile completion and OTP limits (assumed by Claude, needs founder review):** completion weights — name 10, photo 10, address 15, ID proof 25; role part 40 (LP/Receiver: account details 40; FN: details 20 + registration cert 20; Driver: licence details 15 + licence photo 25; Org: details 20 + registration cert 20). OTP: max 5 sends per mobile per hour; estimated review time 24 h; licence format `SS00YYYY0000000`. All in settings except weights. |
| D-24 | 2026-11-21 | **Verification flow (assumed by Claude, needs founder review):** the user status is derived from document decisions — when no document is PENDING, any REJECTED → NOT_VERIFIED, else VERIFIED. A NOT_VERIFIED user who re-uploads goes back to UNDER_REVIEW once the profile is 100%. A VERIFIED user who replaces an expiring document stays VERIFIED (the document is PENDING; matching checks document validity per D-03/B-205). One document per type per owner (re-upload replaces it). |
