// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  id: json['id'] as String,
  type: $enumDecode(
    _$DocumentTypeEnumMap,
    json['type'],
    unknownValue: DocumentType.unknown,
  ),
  numberMasked: json['numberMasked'] as String?,
  expiresOn: json['expiresOn'] as String?,
  status: $enumDecode(
    _$DocumentStatusEnumMap,
    json['status'],
    unknownValue: DocumentStatus.unknown,
  ),
  rejectReason: json['rejectReason'] as String?,
  viewUrl: json['viewUrl'] as String?,
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$DocumentTypeEnumMap[instance.type]!,
  'numberMasked': ?instance.numberMasked,
  'expiresOn': ?instance.expiresOn,
  'status': _$DocumentStatusEnumMap[instance.status]!,
  'rejectReason': ?instance.rejectReason,
  'viewUrl': ?instance.viewUrl,
};

const _$DocumentTypeEnumMap = {
  DocumentType.aadhaarOffline: 'AADHAAR_OFFLINE',
  DocumentType.pan: 'PAN',
  DocumentType.voterId: 'VOTER_ID',
  DocumentType.drivingLicence: 'DRIVING_LICENCE',
  DocumentType.photo: 'PHOTO',
  DocumentType.rc: 'RC',
  DocumentType.insurance: 'INSURANCE',
  DocumentType.nationalPermit: 'NATIONAL_PERMIT',
  DocumentType.fnRegistrationCert: 'FN_REGISTRATION_CERT',
  DocumentType.orgRegistrationCert: 'ORG_REGISTRATION_CERT',
  DocumentType.gstCert: 'GST_CERT',
  DocumentType.unknown: 'UNKNOWN',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.pending: 'PENDING',
  DocumentStatus.approved: 'APPROVED',
  DocumentStatus.rejected: 'REJECTED',
  DocumentStatus.unknown: 'UNKNOWN',
};

_VerificationItem _$VerificationItemFromJson(Map<String, dynamic> json) =>
    _VerificationItem(
      key: json['key'] as String,
      label: json['label'] as String,
      done: json['done'] as bool,
      weight: (json['weight'] as num).toInt(),
    );

Map<String, dynamic> _$VerificationItemToJson(_VerificationItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'done': instance.done,
      'weight': instance.weight,
    };

_VerificationInfo _$VerificationInfoFromJson(Map<String, dynamic> json) =>
    _VerificationInfo(
      status: $enumDecode(
        _$VerificationStatusEnumMap,
        json['status'],
        unknownValue: VerificationStatus.unknown,
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => VerificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <VerificationItem>[],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Document>[],
      estimatedReviewHours: (json['estimatedReviewHours'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VerificationInfoToJson(_VerificationInfo instance) =>
    <String, dynamic>{
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
      'estimatedReviewHours': ?instance.estimatedReviewHours,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.notSubmitted: 'NOT_SUBMITTED',
  VerificationStatus.underReview: 'UNDER_REVIEW',
  VerificationStatus.verified: 'VERIFIED',
  VerificationStatus.notVerified: 'NOT_VERIFIED',
  VerificationStatus.unknown: 'UNKNOWN',
};
