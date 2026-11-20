# Domain Model (backend)

Proposed tables and invariants derived from `product-spec.md`. Claude may refine names while implementing; status values and invariants must stay unless the founder approves a change.

## Tables by module

| Module | Table | Key columns |
| --- | --- | --- |
| identity | `identity_user` | id, mobile (unique), name, role, language, email, photo_file_id, verification_status, profile_completion, trust_score, created_at, suspended_at |
| identity | `identity_otp` | id, mobile, purpose, code_hash, expires_at, attempts, consumed_at, load_id? |
| identity | `identity_refresh_token` | id, user_id, token_hash, device_id, expires_at, revoked_at |
| identity | `identity_device` | user_id, fcm_token, platform |
| identity | `identity_address` | user_id, line, village, district, state, pin |
| identity | `identity_role_profile` | user_id, role-specific JSON or columns (LP/FN/Driver/Org/Receiver) |
| identity | `identity_document` | id, owner_type (USER/TRUCK/FARMER), owner_id, type, number_masked, file_ids, expires_on, status, reject_reason, reviewed_by, reviewed_at |
| identity | `identity_aadhaar_check` | user_or_farmer_id, method (OFFLINE_QR/EKYC/DIGILOCKER), last4, name_on_record, verified_at |
| fleet | `fleet_truck` | id, owner_type (DRIVER/ORG), owner_id, number (unique), vehicle_type, capacity_tonnes, status |
| fleet | `fleet_invitation` | id, org_id, driver_mobile, driver_user_id?, status (PENDING/ACCEPTED/REJECTED) |
| fleet | `fleet_allocation` | id, org_id, driver_id, truck_id, status (ACTIVE/PAUSED/REMOVED); unique active per driver and per truck |
| fleet | `fleet_driver_state` | driver_id, on_duty, last_location, last_trip_ended_at |
| farmers | `farmers_farmer` | id, network_id, name, mobile, aadhaar_last4?, land_acres?, village, consent_at, active |
| loads | `loads_load` | id, code, shipper_id, posted_for_farmer_id?, status, pickup (lat,lng,address,landmark), drop (…), pickup_window_start/end, sender_name/mobile, receiver_name/mobile, receiver_user_id?, goods_type, description, quantity, unit, weight_tonnes, vehicle_type, freight_paid_by, posted_amount_inr, agreed_amount_inr, driver_id?, truck_id?, org_id?, distance_km, drive_minutes, delivery_eta, accepted_at, closed_at, version |
| loads | `loads_timeline` | load_id, status, at, actor_id |
| loads | `loads_cancellation` | load_id, by_role, stage, reason, note, charges_kept, admin_decision, admin_reason |
| loads | `loads_track_token` | token (random 32+ bytes, unique), load_id, audience (RECEIVER/SENDER), expires_at |
| matching | `matching_round` | id, load_id, radius_km, batch_no, created_at |
| matching | `matching_wishlist_entry` | id, shipper_id, target_type (TRUCK/ORGANIZATION), truck_id?, org_id?, note, created_at; unique (shipper, target); max 20 per shipper (setting) |
| matching | `matching_load_audience` | load_id, audience (EVERYONE/WISHLIST_FIRST/WISHLIST_ONLY), entry_ids (subset), wishlist_until, opened_to_everyone_at, notified_at |
| matching | `matching_suggestion` | id, load_id, driver_id, rank, score, shown_at, status (SHOWN/ACCEPTED/REJECTED/TAKEN/EXPIRED), reject_reason |
| trips | `trips_revision` | id, load_id, driver_id, requested_amount_inr, reason, status, created_at, respond_by, responded_at |
| trips | `trips_otp_event` | id, load_id, purpose, type (SENT/ATTEMPT/VERIFIED/RESENT/OVERRIDE), lat, lng, distance_m, at |
| trips | `trips_location_exception` | id, load_id, purpose, distance_m, driver_reason, review_status, admin_note |
| trips | `trips_otp_help` | id, load_id, purpose, lat, lng, note, status, admin_reason |
| trips | `trips_location_point` | load_id, lat, lng, speed, at (purge detail after 90 days) |
| wallet | `wallet_account` | id, owner_type (USER/ORG), owner_id, cached_balance_inr, version |
| wallet | `wallet_entry` | txn_id, account_id, type, direction, amount_inr, load_id?, order_id?, note, created_by, created_at — append-only |
| wallet | `wallet_topup_order` | id, account_id, amount_inr, gateway_order_id, status (CREATED/PAID/FAILED), link_token, created_at |
| payments | `payments_record` | load_id (PK), payer (SHIPPER/RECEIVER), amount_inr, mode, reference, status, paid_at, confirmed_at, dispute_reason, resolved_by |
| trust | `trust_event` | id, user_id, load_id?, event, points, reason, created_at |
| trust | `trust_rating` | load_id, rater_id, ratee_id, stars, tags, comment, created_at |
| trust | `trust_pending_rating` | load_id, rater_id, ratee_id, later_used, created_at |
| engagement | `engagement_notification` | id, user_id, tab, type, title, body, deep_link, read_at, created_at |
| engagement | `engagement_broadcast` | id, audience (ALL/ROLE/DISTRICT/USER), target, title, body, link, send_at, sent_at |
| engagement | `engagement_ticket` | id, user_id, type, other_text, load_id?, status, created_at, closed_at |
| engagement | `engagement_ticket_message` | ticket_id, from (USER/ADMIN), body, file_ids, created_at, read_at |
| admin | `admin_setting` | key, value, type, updated_by, updated_at |
| admin | `admin_map_restriction` | id, kind (ZONE/NO_ENTRY/TOLL), geometry, active_hours, vehicle_types |
| admin | `admin_audit` | id, actor_id, action, entity, entity_id, before, after, reason, at |

## Load status machine

```
NOT_ACCEPTED ──accept (atomic, charges)──▶ ACCEPTED ─(immediately)─▶ WAITING_FOR_PICKUP
WAITING_FOR_PICKUP ──revision request──▶ AMOUNT_NEGOTIATION ──confirm / reject / 15-min expiry──▶ WAITING_FOR_PICKUP
WAITING_FOR_PICKUP ──Reached (pickup)──▶ LOCATION_REACHED ──pickup OTP──▶ PICKED_UP ─(auto)─▶ TRAVELING
TRAVELING ──Reached (drop)──▶ ARRIVED_DESTINATION ──delivery OTP──▶ DELIVERED
NOT_ACCEPTED | WAITING_FOR_PICKUP | AMOUNT_NEGOTIATION | LOCATION_REACHED ──cancel──▶ CANCELLED
after PICKED_UP: cancel only by Admin (via support)
```

Invariants:
- `agreed_amount_inr` = posted amount at acceptance; changes only on a confirmed revision.
- Revisions: count ≤ 5 per load; at most one `PENDING`; allowed only in `WAITING_FOR_PICKUP` (Q-11).
- A driver has at most one load in an active status; a truck at most one.
- Charges at acceptance: `POSTING_CHARGE` debit on shipper account, `TRIP_CHARGE` debit on driver's or Org's account, in the acceptance transaction; both balances re-checked with row locks.
- Trip `closed_at` set when payment `CONFIRMED` or dispute resolved.

## Matching algorithm

1. Eligible set (SQL + Java): verified, on duty, not suspended, no active load, vehicle type compatible (`ANY` matches all), capacity ≥ weight, documents valid on pickup date, wallet ≥ trip charge (own or Org), within radius (Haversine on bounding-box pre-filter), not already suggested/rejected for this load.
2. Score = Σ weight × normalised factor (distance, time fit, trust, capacity fit, return-load potential, idle time); weights from settings.
2a. **Wish list:** entries resolve to drivers — TRUCK → its owner-driver or its allocated Org driver; ORGANIZATION → all eligible drivers of that org. Wish-list drivers use the relaxed radius (100 km, setting).
   - `EVERYONE`: wish-list drivers get a ranking bonus (setting) and are placed first in batch order.
   - `WISHLIST_FIRST`: batches contain only wish-list drivers until `wishlist_until` (posting + 15 min); then the job switches to normal matching (wish-list drivers already shown are not re-suggested).
   - `WISHLIST_ONLY`: only wish-list drivers; at posting + 30 min with no acceptance → notify shipper once; `POST /loads/{id}/open-to-everyone` switches to normal matching.
   - No usable entries at posting → `WISHLIST_EMPTY`.
3. Batch 1 = top 5 → `matching_suggestion` rows (SHOWN) + push. Job every 10 min: next 5; when list exhausted widen radius by step; after max radius → notify shipper.
4. Accept: atomic update on `loads_load` (status + version); others' suggestions → `TAKEN`.

## Trust Score

`trust_score` on user = clamp(70 + Σ points). Points table in settings (product spec §12). Events written by listeners on: delivery (on-time/late), late pickup, cancellation (with fault flag from rules/admin), ratings, verified complaints, payment confirmed/dispute decisions, admin adjustments.

## Route status

For trips in `TRAVELING`: planned = `accepted/pickup time + drive_minutes`; current ETA from maps; `SLOW` if ETA > planned × 1.10, `FAST` if < planned × 0.90, else `NORMAL` (thresholds in settings).
