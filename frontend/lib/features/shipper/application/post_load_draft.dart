import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/models.dart';

/// Everything typed on LP-02. Kept in a provider so it survives going to top-up or verification and back
/// (ui-guidelines "Keep entered data").
class LoadDraft {
  LoadDraft({
    this.editingId,
    this.date,
    this.fromMinutes = 8 * 60,
    this.toMinutes = 11 * 60,
    this.pickup,
    this.drop,
    this.senderName = '',
    this.senderMobile = '',
    this.goodsType,
    this.description = '',
    this.quantity = '',
    this.unit = QuantityUnit.bags,
    this.weight = '',
    this.vehicleType = VehicleType.any,
    this.receiverName = '',
    this.receiverMobile = '',
    this.payer = FreightPayer.shipper,
    this.amount = '',
    this.audience = LoadAudience.everyone,
    this.wishlistEntryIds,
    this.postedForFarmerId,
    this.estimate,
  });

  final String? editingId;
  final DateTime? date;
  final int fromMinutes;
  final int toMinutes;
  final Place? pickup;
  final Place? drop;
  final String senderName;
  final String senderMobile;
  final String? goodsType;
  final String description;
  final String quantity;
  final QuantityUnit unit;
  final String weight;
  final VehicleType vehicleType;
  final String receiverName;
  final String receiverMobile;
  final FreightPayer payer;
  final String amount;
  final LoadAudience audience;

  /// Chosen subset of the wish list (null = whole list).
  final List<String>? wishlistEntryIds;
  final String? postedForFarmerId;
  final LoadEstimate? estimate;

  DateTime? get windowStart => date == null ? null : DateTime(date!.year, date!.month, date!.day).add(Duration(minutes: fromMinutes));

  DateTime? get windowEnd => date == null ? null : DateTime(date!.year, date!.month, date!.day).add(Duration(minutes: toMinutes));

  LoadDraft copyWith({
    DateTime? date,
    int? fromMinutes,
    int? toMinutes,
    Place? pickup,
    Place? drop,
    String? senderName,
    String? senderMobile,
    String? goodsType,
    String? description,
    String? quantity,
    QuantityUnit? unit,
    String? weight,
    VehicleType? vehicleType,
    String? receiverName,
    String? receiverMobile,
    FreightPayer? payer,
    String? amount,
    LoadAudience? audience,
    List<String>? wishlistEntryIds,
    bool clearEntries = false,
    LoadEstimate? estimate,
    bool clearEstimate = false,
  }) {
    return LoadDraft(
      editingId: editingId,
      date: date ?? this.date,
      fromMinutes: fromMinutes ?? this.fromMinutes,
      toMinutes: toMinutes ?? this.toMinutes,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      senderName: senderName ?? this.senderName,
      senderMobile: senderMobile ?? this.senderMobile,
      goodsType: goodsType ?? this.goodsType,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      vehicleType: vehicleType ?? this.vehicleType,
      receiverName: receiverName ?? this.receiverName,
      receiverMobile: receiverMobile ?? this.receiverMobile,
      payer: payer ?? this.payer,
      amount: amount ?? this.amount,
      audience: audience ?? this.audience,
      wishlistEntryIds: clearEntries ? null : (wishlistEntryIds ?? this.wishlistEntryIds),
      postedForFarmerId: postedForFarmerId,
      estimate: clearEstimate ? null : (estimate ?? this.estimate),
    );
  }

  /// Body for `POST /loads` / `PUT /loads/{id}`.
  LoadCreate toCreate() => LoadCreate(
        pickupWindowStart: windowStart!.toUtc(),
        pickupWindowEnd: windowEnd!.toUtc(),
        pickup: pickup!,
        senderName: senderName.trim(),
        senderMobile: senderMobile.trim(),
        goodsType: goodsType!,
        description: description.trim().isEmpty ? null : description.trim(),
        quantity: num.parse(quantity),
        quantityUnit: unit,
        weightTonnes: num.parse(weight),
        vehicleType: vehicleType,
        drop: drop!,
        receiverName: receiverName.trim(),
        receiverMobile: receiverMobile.trim(),
        freightPaidBy: payer,
        amountInr: int.parse(amount),
        postedForFarmerId: postedForFarmerId,
        audience: audience,
        wishlistEntryIds: audience == LoadAudience.everyone ? null : wishlistEntryIds,
      );

  static LoadDraft fromDetail(LoadDetail d) {
    final start = d.pickupWindowStart.toLocal();
    return LoadDraft(
      editingId: d.id,
      date: DateTime(start.year, start.month, start.day),
      fromMinutes: start.hour * 60 + start.minute,
      toMinutes: start.hour * 60 + start.minute + 180,
      pickup: d.pickup,
      drop: d.drop,
      senderName: d.senderName,
      senderMobile: d.senderMobile,
      goodsType: d.goodsType,
      description: d.description ?? '',
      quantity: '${d.quantity}',
      unit: d.quantityUnit,
      weight: '${d.weightTonnes}',
      vehicleType: d.vehicleType,
      receiverName: d.receiverName,
      receiverMobile: d.receiverMobile,
      payer: d.freightPaidBy,
      amount: '${d.postedAmountInr}',
      audience: d.audience,
    );
  }
}

class LoadDraftController extends Notifier<LoadDraft> {
  @override
  LoadDraft build() => LoadDraft();

  void update(LoadDraft Function(LoadDraft d) change) => state = change(state);

  void replace(LoadDraft d) => state = d;

  void reset() => state = LoadDraft();
}

final loadDraftProvider = NotifierProvider<LoadDraftController, LoadDraft>(LoadDraftController.new);
