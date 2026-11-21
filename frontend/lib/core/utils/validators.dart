/// Form checks mirroring the backend's Bean Validation (the server still decides).
abstract final class Validators {
  static final _mobile = RegExp(r'^[6-9][0-9]{9}$');
  static final _otp = RegExp(r'^[0-9]{6}$');
  static final _pin = RegExp(r'^[1-9][0-9]{5}$');

  static bool mobile(String? v) => v != null && _mobile.hasMatch(v.trim());

  static bool name(String? v) => v != null && v.trim().length >= 2 && v.trim().length <= 60;

  static bool otp(String? v) => v != null && _otp.hasMatch(v);

  static bool pin(String? v) => v != null && _pin.hasMatch(v.trim());

  /// Farmer Network ID number per type (CIN / PAN / GSTIN), same patterns as the backend.
  static bool idNumber(String? type, String? v) {
    if (type == null || v == null) return false;
    final pattern = switch (type) {
      'CIN' => RegExp(r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$'),
      'PAN' => RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
      'GSTIN' => RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$'),
      _ => null,
    };
    return pattern != null && pattern.hasMatch(v.trim().toUpperCase());
  }
}
