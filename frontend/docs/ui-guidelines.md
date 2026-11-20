# UI Guidelines

Users include truck drivers and farmers with mid-range Android phones, patchy networks and varied literacy. Design for clarity first.

## Principles
- **One primary action per screen**, large (min 48 dp tall), at the bottom (thumb reach).
- Plain words, short labels, icons with text (never icon-only for important actions).
- Show money as `₹1,250`, weight as `12.5 t`, distance as `18 km`, times as `20 Nov, 9:30 am`.
- Status always as a coloured chip + text (never colour alone).
- Confirm before anything that costs money or can't be undone (accept trip, cancel, post).
- Explain *why* something is blocked ("Top up ₹50 to post", "Complete verification to accept trips") with a button to fix it.

## Theme (Material 3)
- Seed colour: Tranix blue `#1F4E79`; secondary amber `#F2A900` for highlights (on-duty, pending actions).
- Status colours: success `#2E7D32`, warning `#ED6C02`, error `#C62828`, info `#0277BD`, neutral grey.
- Typography: system font (Roboto/Noto Sans Tamil/Devanagari for scripts). Body 16 sp minimum for drivers' screens; numbers (amount, OTP) 20–28 sp bold.
- Light theme at launch; keep tokens ready for dark mode.

## Status chips
| Status | Colour |
| --- | --- |
| Not accepted | grey |
| Accepted / Waiting for pickup | info |
| Amount negotiation | warning |
| Location reached · Picked up · Traveling · Arrived | info (filled) |
| Delivered | success |
| Cancelled | error |
| Payment Pending / Paid / Confirmed / Disputed | grey / info / success / error |

## Shared widgets (`core/widgets`)
`PrimaryButton`, `StatusChip`, `MoneyText`, `OtpInput` (6 boxes, autofill), `CompletionRing`, `TrustScoreBadge`, `EmptyState`, `ErrorState` (retry), `OfflineBanner`, `DocumentTile` (status + expiry), `TimelineList`, `MapPreview`, `ConfirmSheet`, `BlockingReasonCard`.

## Forms
- Validate on blur and on submit; error text under the field (localised); scroll to first error.
- Mobile fields fixed +91 prefix, numeric keyboard. Dates via pickers, not typing.
- Keep entered data when sending the user to top-up or verification and returning.

## Accessibility and languages
- All strings in ARB (en, ta, hi); test Tamil and Hindi layouts for overflow (longer words).
- Content descriptions for icons and map buttons; contrast ≥ 4.5:1.
- Support system font scaling up to 1.3× without breaking layouts.

## Driver-specific
- Current trip screen readable at arm's length: big step button, big ETA, high contrast.
- Never require typing while the vehicle is moving; amount request and reasons use chips where possible.
- Foreground notification during trips: "Tranix trip TRX-… in progress".
