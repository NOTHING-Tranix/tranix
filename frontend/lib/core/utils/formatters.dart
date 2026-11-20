import 'package:intl/intl.dart';

/// Display formats from docs/ui-guidelines.md (`₹1,250`, `12.5 t`, `18 km`, `20 Nov, 9:30 am`).
abstract final class Fmt {
  static final _money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _oneDecimal = NumberFormat('#,##0.#', 'en_IN');

  static String money(num amountInr) => _money.format(amountInr);

  static String tonnes(num t) => '${_oneDecimal.format(t)} t';

  static String km(num km) => '${_oneDecimal.format(km)} km';

  /// Local time, e.g. `20 Nov, 9:30 am`.
  static String dateTime(DateTime at) {
    final local = at.toLocal();
    return '${DateFormat('d MMM', 'en').format(local)}, ${DateFormat('h:mm', 'en').format(local)} '
        '${local.hour < 12 ? 'am' : 'pm'}';
  }

  /// `dd MMM yyyy, h:mm a` (architecture.md).
  static String fullDateTime(DateTime at) => DateFormat('dd MMM yyyy, h:mm a', 'en').format(at.toLocal());

  /// `20 Nov 2026`.
  static String dateOnly(DateTime d) => DateFormat('d MMM yyyy', 'en').format(d);
}
