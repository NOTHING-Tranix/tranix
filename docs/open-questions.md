# Open Questions

Not yet decided. One copy at `docs/open-questions.md` in the project root. If a task depends on an open item, build the decided part behind a setting or interface, mark the task `[!]` if truly blocked, and ask the founder. When answered → add to `decisions.md`, mark **Closed** here.

| ID | Question | Blocks | Default until decided | Status |
| --- | --- | --- | --- | --- |
| Q-01 | Posting charge and trip charge amounts (₹) | Launch | Settings with placeholder values (e.g. ₹50 / ₹50) | Open |
| Q-02 | Payment gateway (Razorpay preferred) — account, fees, settlement | Real top-up | Fake gateway; admin manual credit for testing | Open |
| Q-03 | SMS provider (MSG91 preferred) + DLT registration of templates in en/ta/hi | Real OTP/SMS | Fake SMS (logs code; dev OTP `123456` only in `dev` profile) | Open |
| Q-04 | Aadhaar offline verification / DigiLocker provider and onboarding | Aadhaar option | Aadhaar option hidden; PAN / Voter ID / licence accepted | Open |
| Q-05 | Maps provider for route ETA and route services (Google Routes/Places) and monthly budget | Delivery estimate, map layers | Fake: straight-line distance × 1.3 at 40 km/h; static sample POIs | Open |
| Q-06 | Source of heavy-vehicle entry restrictions / no-entry timings data | Driver map layer | Admin-entered data for first corridors | Open |
| Q-07 | Google Play billing review for in-app top-up | In-app top-up | Web top-up only (D-13) | Open |
| Q-08 | Legal review: Aadhaar handling, location data retention, privacy policy, terms | Launch | Keep location detail 90 days (setting) | Open |
| Q-09 | Ranking weights, suggestion batch sizes, radius steps, grace time for "late" | Tuning | Values in product spec; all in settings | Open (tune) |
| Q-10 | Vision and mission | Docs | — | Open |
| Q-11 | Can the driver still request a new amount after tapping Reached at pickup (status `LOCATION_REACHED`), or only while `WAITING_FOR_PICKUP`? | B-702, A-509 | Only while `WAITING_FOR_PICKUP` | Open |
| Q-12 | Wish list settings: ranking bonus size, Wish-list-first window (15 min), Wish-list-only notify time (30 min), max entries (20), relaxed radius (100 km) | B-650s, A-408 | Values as listed; all admin settings | Open (tune) |
| Q-13 | Goods type list for the posting dropdown | LP-02, FN-03 | Vegetables, Fruits, Grains, Pulses, Spices, Fertilizer, Building material, FMCG, Other (admin setting `lists.goods_types`) | **Closed** (founder 2026-11-21: keep default list; admin-editable) |
