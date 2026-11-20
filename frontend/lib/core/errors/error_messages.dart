import '../l10n/generated/app_localizations.dart';
import 'app_exception.dart';

/// The single place that turns an error into a localised message (CLAUDE.md rule 8).
String errorMessage(AppLocalizations l, Object error) {
  if (error is! AppException) return l.errorGeneric;
  switch (error.kind) {
    case AppErrorKind.network:
      return l.errorNetwork;
    case AppErrorKind.timeout:
      return l.errorTimeout;
    case AppErrorKind.unknown:
      return l.errorGeneric;
    case AppErrorKind.server:
      return messageForCode(l, error.code) ?? l.errorGeneric;
  }
}

/// Localised text for a contract error code, or null for codes this app version does not know.
String? messageForCode(AppLocalizations l, String? code) {
  return switch (code) {
    ApiErrorCode.validationFailed => l.errorValidationFailed,
    ApiErrorCode.unauthenticated => l.errorUnauthenticated,
    ApiErrorCode.tokenExpired => l.errorTokenExpired,
    ApiErrorCode.forbidden => l.errorForbidden,
    ApiErrorCode.notVerified => l.errorNotVerified,
    ApiErrorCode.notFound => l.errorNotFound,
    ApiErrorCode.otpInvalid => l.errorOtpInvalid,
    ApiErrorCode.otpExpired => l.errorOtpExpired,
    ApiErrorCode.otpLocked => l.errorOtpLocked,
    ApiErrorCode.mobileInUse => l.errorMobileInUse,
    ApiErrorCode.insufficientBalance => l.errorInsufficientBalance,
    ApiErrorCode.loadTaken => l.errorLoadTaken,
    ApiErrorCode.invalidState => l.errorInvalidState,
    ApiErrorCode.revisionLimitReached => l.errorRevisionLimitReached,
    ApiErrorCode.revisionPending => l.errorRevisionPending,
    ApiErrorCode.allocationConflict => l.errorAllocationConflict,
    ApiErrorCode.wishlistFull => l.errorWishlistFull,
    ApiErrorCode.wishlistEmpty => l.errorWishlistEmpty,
    ApiErrorCode.rateLimited => l.errorRateLimited,
    _ => null,
  };
}
