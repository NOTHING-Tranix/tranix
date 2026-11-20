// Enums from docs/api-contract.md §2. JSON values are SCREAMING_SNAKE_CASE (FieldRename.screamingSnake),
// except Language (en|ta|hi). Every enum has `unknown` as the fallback for values this app version does not
// know (fields use `@JsonKey(unknownEnumValue: X.unknown)`), so a new server value never crashes the app.
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum Role { loadProvider, farmerNetwork, driver, organization, receiver, admin, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum VerificationStatus { notSubmitted, underReview, verified, notVerified, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DocumentType {
  aadhaarOffline,
  pan,
  voterId,
  drivingLicence,
  photo,
  rc,
  insurance,
  nationalPermit,
  fnRegistrationCert,
  orgRegistrationCert,
  gstCert,
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DocumentStatus { pending, approved, rejected, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum LoadStatus {
  notAccepted,
  accepted,
  amountNegotiation,
  waitingForPickup,
  locationReached,
  pickedUp,
  traveling,
  arrivedDestination,
  delivered,
  cancelled,
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum QuantityUnit { bags, crates, boxes, tonnes, litres, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum VehicleType { openBody, closedBody, container, refrigerated, tanker, any, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum FreightPayer { shipper, receiver, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RevisionStatus { pending, confirmed, rejected, expired, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OtpPurpose { signUp, signIn, changeMobile, pickup, delivery, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentStatus { pending, paid, confirmed, disputed, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentMode { cash, upi, bank, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TxnType { topup, postingCharge, tripCharge, refund, adminCredit, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TxnDirection { credit, debit, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TruckStatus { available, allocated, onTrip, documentsPending, inactive, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TicketType { complaint, feedback, wallet, paymentDispute, others, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TicketStatus { open, closed, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum NotificationTab { trips, wallet, tranix, account, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RouteStatus { normal, slow, fast, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum LoadAudience { everyone, wishlistFirst, wishlistOnly, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum WishlistTargetType { truck, organization, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum SuggestionRejectReason { tooFar, lowAmount, wrongTruck, other, unknown }

/// `Accept-Language` / `language` values (D-12).
@JsonEnum()
enum Language { en, ta, hi }
