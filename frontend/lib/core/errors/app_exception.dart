/// Error codes from docs/api-contract.md §1 (must match exactly).
abstract final class ApiErrorCode {
  static const validationFailed = 'VALIDATION_FAILED';
  static const unauthenticated = 'UNAUTHENTICATED';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const forbidden = 'FORBIDDEN';
  static const notVerified = 'NOT_VERIFIED';
  static const notFound = 'NOT_FOUND';
  static const otpInvalid = 'OTP_INVALID';
  static const otpExpired = 'OTP_EXPIRED';
  static const otpLocked = 'OTP_LOCKED';
  static const mobileInUse = 'MOBILE_IN_USE';
  static const insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const loadTaken = 'LOAD_TAKEN';
  static const invalidState = 'INVALID_STATE';
  static const revisionLimitReached = 'REVISION_LIMIT_REACHED';
  static const revisionPending = 'REVISION_PENDING';
  static const allocationConflict = 'ALLOCATION_CONFLICT';
  static const wishlistFull = 'WISHLIST_FULL';
  static const wishlistEmpty = 'WISHLIST_EMPTY';
  static const rateLimited = 'RATE_LIMITED';

  static const all = <String>[
    validationFailed,
    unauthenticated,
    tokenExpired,
    forbidden,
    notVerified,
    notFound,
    otpInvalid,
    otpExpired,
    otpLocked,
    mobileInUse,
    insufficientBalance,
    loadTaken,
    invalidState,
    revisionLimitReached,
    revisionPending,
    allocationConflict,
    wishlistFull,
    wishlistEmpty,
    rateLimited,
  ];
}

enum AppErrorKind {
  /// The server answered with a problem body (see [AppException.code]).
  server,

  /// No connection / DNS / socket failure.
  network,

  /// Connect, send or receive timeout.
  timeout,

  /// Anything else (bad JSON, programming error).
  unknown,
}

class FieldError {
  const FieldError(this.field, this.message);

  final String field;
  final String message;
}

/// The only error type the UI sees. Built from RFC 7807 problems by `ErrorInterceptor`.
class AppException implements Exception {
  const AppException({
    required this.kind,
    this.code,
    this.status,
    this.detail,
    this.fields = const [],
  });

  factory AppException.fromProblem(int? status, Object? body) {
    if (body is Map) {
      final rawFields = body['fields'];
      return AppException(
        kind: AppErrorKind.server,
        status: status ?? (body['status'] as int?),
        code: body['code'] as String?,
        detail: body['detail'] as String?,
        fields: rawFields is List
            ? rawFields
                .whereType<Map>()
                .map((f) => FieldError('${f['field']}', '${f['message']}'))
                .toList()
            : const [],
      );
    }
    return AppException(kind: AppErrorKind.server, status: status);
  }

  final AppErrorKind kind;
  final String? code;
  final int? status;

  /// Server text in English; shown only when there is no localised message for [code].
  final String? detail;
  final List<FieldError> fields;

  String? fieldError(String field) {
    for (final f in fields) {
      if (f.field == field) return f.message;
    }
    return null;
  }

  @override
  String toString() => 'AppException(kind: $kind, status: $status, code: $code)';
}
