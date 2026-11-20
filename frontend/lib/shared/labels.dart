import '../core/l10n/generated/app_localizations.dart';
import 'models/models.dart';

/// Localised labels for contract enums and setting lists.
String unitLabel(AppLocalizations l, QuantityUnit u) => switch (u) {
      QuantityUnit.bags => l.unitBags,
      QuantityUnit.crates => l.unitCrates,
      QuantityUnit.boxes => l.unitBoxes,
      QuantityUnit.tonnes => l.unitTonnes,
      QuantityUnit.litres => l.unitLitres,
      QuantityUnit.unknown => l.statusUnknown,
    };

String vehicleLabel(AppLocalizations l, VehicleType v) => switch (v) {
      VehicleType.openBody => l.vehOpenBody,
      VehicleType.closedBody => l.vehClosedBody,
      VehicleType.container => l.vehContainer,
      VehicleType.refrigerated => l.vehRefrigerated,
      VehicleType.tanker => l.vehTanker,
      VehicleType.any => l.vehAny,
      VehicleType.unknown => l.statusUnknown,
    };

/// Cancel reason codes come from settings; unknown codes show as-is.
String cancelReasonLabel(AppLocalizations l, String code) => switch (code) {
      'PLANS_CHANGED' => l.crPlansChanged,
      'GOODS_NOT_READY' => l.crGoodsNotReady,
      'FOUND_OTHER_TRUCK' => l.crFoundOtherTruck,
      'DRIVER_NOT_REACHABLE' => l.crDriverNotReachable,
      'DRIVER_DID_NOT_COME' => l.crDriverDidNotCome,
      'DRIVER_ASKED_MORE' => l.crDriverAskedMore,
      'TRUCK_BREAKDOWN' => l.crTruckBreakdown,
      'EMERGENCY' => l.crEmergency,
      'SHIPPER_CHANGED_DETAILS' => l.crShipperChangedDetails,
      'AMOUNT_NOT_AGREED' => l.crAmountNotAgreed,
      'TOO_FAR' => l.crTooFar,
      'OTHER' => l.crOther,
      _ => code,
    };

/// Contract wire value of a Dart enum name (`openBody` → `OPEN_BODY`).
String wireName(Enum e) => e.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
