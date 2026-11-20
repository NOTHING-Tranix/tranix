import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/models/models.dart';

String docTypeLabel(AppLocalizations l, DocumentType t) => switch (t) {
      DocumentType.pan => l.docPan,
      DocumentType.voterId => l.docVoterId,
      DocumentType.drivingLicence => l.docDrivingLicence,
      DocumentType.photo => l.docPhoto,
      DocumentType.fnRegistrationCert => l.docFnRegistrationCert,
      DocumentType.orgRegistrationCert => l.docOrgRegistrationCert,
      DocumentType.gstCert => l.docGstCert,
      DocumentType.aadhaarOffline => l.docAadhaar,
      DocumentType.rc => l.docRc,
      DocumentType.insurance => l.docInsurance,
      DocumentType.nationalPermit => l.docNationalPermit,
      DocumentType.unknown => l.statusUnknown,
    };

String verificationLabel(AppLocalizations l, VerificationStatus s) => switch (s) {
      VerificationStatus.notSubmitted => l.statusNotSubmitted,
      VerificationStatus.underReview => l.statusUnderReview,
      VerificationStatus.verified => l.statusVerified,
      VerificationStatus.notVerified => l.statusNotVerified,
      VerificationStatus.unknown => l.statusUnknown,
    };

/// Label for a `GET /me/verification` item key (server labels are English only).
String verificationItemLabel(AppLocalizations l, String key) => switch (key) {
      'NAME' => l.nameLabel,
      'PHOTO' => l.photo,
      'ADDRESS' => l.address,
      'ID_PROOF' => l.idProof,
      'ROLE_PROFILE' => l.roleDetails,
      'FN_REGISTRATION_CERT' => l.docFnRegistrationCert,
      'ORG_REGISTRATION_CERT' => l.docOrgRegistrationCert,
      'DRIVING_LICENCE' => l.docDrivingLicence,
      _ => key,
    };

Widget verificationChip(BuildContext context, VerificationStatus s) {
  final c = context.statusColors;
  final color = switch (s) {
    VerificationStatus.verified => c.success,
    VerificationStatus.underReview => c.info,
    VerificationStatus.notVerified => c.error,
    _ => c.neutral,
  };
  return StatusChip(label: verificationLabel(AppLocalizations.of(context), s), color: color);
}

Widget documentChip(BuildContext context, DocumentStatus s) {
  final l = AppLocalizations.of(context);
  final c = context.statusColors;
  return switch (s) {
    DocumentStatus.approved => StatusChip(label: l.docApproved, color: c.success),
    DocumentStatus.rejected => StatusChip(label: l.docRejected, color: c.error),
    DocumentStatus.pending => StatusChip(label: l.docPending, color: c.info),
    DocumentStatus.unknown => StatusChip(label: l.statusUnknown, color: c.neutral),
  };
}
