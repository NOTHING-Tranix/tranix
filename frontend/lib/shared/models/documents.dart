import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'documents.freezed.dart';
part 'documents.g.dart';

/// `Document{id, type, numberMasked, expiresOn, status, rejectReason, viewUrl}` (contract §4).
@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    @JsonKey(unknownEnumValue: DocumentType.unknown) required DocumentType type,
    String? numberMasked,
    String? expiresOn,
    @JsonKey(unknownEnumValue: DocumentStatus.unknown) required DocumentStatus status,
    String? rejectReason,
    String? viewUrl,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}

@freezed
abstract class VerificationItem with _$VerificationItem {
  const factory VerificationItem({
    required String key,
    required String label,
    required bool done,
    required int weight,
  }) = _VerificationItem;

  factory VerificationItem.fromJson(Map<String, dynamic> json) => _$VerificationItemFromJson(json);
}

/// `GET /me/verification`.
@freezed
abstract class VerificationInfo with _$VerificationInfo {
  const factory VerificationInfo({
    @JsonKey(unknownEnumValue: VerificationStatus.unknown) required VerificationStatus status,
    @Default(<VerificationItem>[]) List<VerificationItem> items,
    @Default(<Document>[]) List<Document> documents,
    int? estimatedReviewHours,
  }) = _VerificationInfo;

  factory VerificationInfo.fromJson(Map<String, dynamic> json) => _$VerificationInfoFromJson(json);
}
