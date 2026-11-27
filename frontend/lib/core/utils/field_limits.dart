import 'package:flutter/services.dart';

/// Client-side length limits for text inputs. These are deliberately tighter than the
/// backend's Bean Validation caps; the server still decides what is valid.
abstract final class FieldLimits {
  static const mobile = 10;
  static const otp = 6;
  static const pin = 6;
  static const aadhaarLast4 = 4;
  static const name = 20;
  static const businessName = 40;
  static const email = 50;
  static const address = 100;
  static const landmark = 50;
  static const place = 30; // village, district, state
  static const description = 300;
  static const note = 300; // reasons, remarks, comments, notes
  static const message = 1000;
  static const reference = 30;
  static const truckNumber = 12;
  static const idNumber = 20;
  static const search = 30;
  static const url = 100;

  /// Whole-rupee amounts: at most 9 digits.
  static const amountDigits = 9;

  /// Decimal quantities (tonnes, weight, capacity, land): 6 integer + 2 fraction digits.
  static const decimalIntDigits = 6;
  static const decimalFractionDigits = 2;
}

/// Reusable `inputFormatters` lists. They truncate silently (no counter is shown).
abstract final class Inputs {
  /// Any text, capped at [max] characters.
  static List<TextInputFormatter> text(int max) => [LengthLimitingTextInputFormatter(max)];

  /// Digits only, capped at [max].
  static List<TextInputFormatter> digits(int max) =>
      [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(max)];

  /// Whole-rupee amount, up to [FieldLimits.amountDigits] digits.
  static List<TextInputFormatter> amount() => digits(FieldLimits.amountDigits);

  /// Positive decimal such as 12.5, with capped integer and fraction digits.
  static List<TextInputFormatter> decimal({
    int intDigits = FieldLimits.decimalIntDigits,
    int fractionDigits = FieldLimits.decimalFractionDigits,
  }) =>
      [_DecimalFormatter(intDigits, fractionDigits)];

  /// Upper-case letters and digits only (truck and ID numbers), capped at [max].
  static List<TextInputFormatter> alphanumeric(int max) => [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 \-]')),
        LengthLimitingTextInputFormatter(max),
      ];
}

class _DecimalFormatter extends TextInputFormatter {
  _DecimalFormatter(int intDigits, int fractionDigits)
      : _pattern = RegExp('^[0-9]{0,$intDigits}(\\.[0-9]{0,$fractionDigits})?\$');

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      _pattern.hasMatch(newValue.text) ? newValue : oldValue;
}
