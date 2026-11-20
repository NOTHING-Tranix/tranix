# ROADMAP — build order across backend and frontend

Each milestone is a **vertical slice**: backend tasks first, then the frontend tasks for the same feature, ending with something the founder can try on a phone.
Status: `[ ]` not started · `[~]` in progress · `[x]` done. Claude updates this file at each milestone checkpoint.

| # | Milestone | Backend tasks | Frontend tasks | Demo at the end | Status |
| --- | --- | --- | --- | --- | --- |
| M0 | Foundations | B-001 – B-010 | A-001 – A-012 | Both projects build; CI green; app opens with mock data | [x] |
| M1 | Sign up and sign in | B-101 – B-112 | A-101 – A-106 | Sign up with OTP on the phone, stay signed in, sign out | [x] |
| M2 | Profile and verification | B-201 – B-208 | A-201 – A-207 | Fill profile to 100%, submit; approve in Swagger; app shows Verified | [x] |
| M3 | Wallet and notifications basics | B-301 – B-308, B-1101, B-1102 | A-301 – A-304 | Top up via browser page (fake gateway), see balance and notification | [x] |
| M4 | Post a load | B-401 – B-409 | A-401 – A-403 | Load Provider posts a load with estimate; sees it in Tracking | [x] |
| M5 | Driver and fleet setup (backend) + driver profile | B-501 – B-509 | A-501, A-502 | Driver adds own truck, goes on duty; org invite accepted | [ ] |
| M6 | Matching and acceptance | B-601 – B-607 | A-503, A-404 | Driver sees suggestion, accepts; shipper sees driver details | [ ] |
| M7 | Trip execution | B-701 – B-711 | A-504 – A-511, A-405, A-406 | Full trip: amount request, Reached, pickup OTP, live map, delivery OTP | [ ] |
| M8 | Payments, ratings, Trust Score | B-801 – B-808 | A-407, A-601 – A-603 | Mark paid → confirm; rating pop-up; Trust Score history | [ ] |
| M9 | Wish list | B-651 – B-656 | A-408 – A-410, A-512 | Add truck/org to wish list; post "Wish list first"; preferred driver accepts | [ ] |
| M10 | Farmer Network | B-901 – B-904 | A-701 – A-704 | FN registers, adds farmer, posts for farmer; farmer gets SMS (fake) | [ ] |
| M11 | Organization app | (B-502 – B-508 done in M5) | A-801 – A-805 | Org adds trucks/drivers, allocates, watches trips | [ ] |
| M12 | Receiver and public pages | B-1001 – B-1006 | A-901 – A-903 | Receiver tracks by SMS link page and in app; uploads receipt | [ ] |
| M13 | Support and broadcasts | B-1103 – B-1107 | A-305 – A-307 | Raise ticket, admin replies (Swagger), broadcast appears | [ ] |
| M14 | Admin API complete | B-1201 – B-1212 | — | All admin actions possible in Swagger | [ ] |
| M15 | Real integrations | B-1301 – B-1307 | (config only) | Real SMS OTP, real test payment, real maps ETA | [ ] |
| M16 | Hardening and release | B-1401 – B-1408 | A-1001 – A-1008 | Signed AAB on Play internal testing; backend on AWS | [ ] |
| Later | Flutter web + Admin panel | — | A-1101 – A-1103 | Admin panel in browser | [ ] |

**Before M15:** the founder must settle Q-01 (charge amounts), Q-02 (payment gateway), Q-03 (SMS + DLT), Q-04 (Aadhaar provider), Q-05 (maps budget). **Before M16:** Q-07 and Q-08.
