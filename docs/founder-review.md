# Founder review

Items Claude could not finish or decided on its own while working in autopilot. Newest at the bottom of each section.

## Assumptions to review (decisions marked "assumed by Claude")

| ID | Summary | Where |
| D-23 | Completion weights, OTP 5 sends/hour, review 24 h, licence format | docs/decisions.md |
| D-24 | User status derived from document decisions; verified users stay verified when replacing a document | docs/decisions.md |
| D-25 | Top-up ₹100–₹50,000, wallets only for LP/FN/Driver/Org, low-balance rule, no SMS for wallet events | docs/decisions.md |
| --- | --- | --- |

## Actions only the founder can do

| # | What | Exact steps |
| --- | --- | --- |
| F-1 | Delete old repo `NOTHING-Tranix/Tranix-Backend` (founder will do it) | `gh auth refresh -h github.com -s delete_repo` then `gh repo delete NOTHING-Tranix/Tranix-Backend --yes` |
| F-2 | Remove local backup folder when no longer needed | Delete `Downloads\backend-old-dotgit-2026-11-21` (zip backup stays) |
| F-3 | Choose an Aadhaar offline/DigiLocker provider (Q-04) | Sign up with the provider, get sandbox + live keys; then Claude implements `AadhaarVerifier` for it and sets `tranix.integrations.aadhaar=<provider>`. Until then the option stays hidden (`aadhaarEnabled=false`). |

## Blocked tasks `[!]`

| Task | Why | What is needed |
| B-204 | Aadhaar provider not chosen (Q-04) | F-3 |
| --- | --- | --- |
