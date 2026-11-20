import 'package:material_ui/material_ui.dart';

import '../utils/formatters.dart';

/// `₹1,250` in bold; [large] for amounts that matter (20–28 sp).
class MoneyText extends StatelessWidget {
  const MoneyText(this.amountInr, {super.key, this.large = false, this.color});

  final num amountInr;
  final bool large;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final style = (large ? t.headlineSmall : t.titleMedium)?.copyWith(fontWeight: FontWeight.bold, color: color);
    return Text(Fmt.money(amountInr), style: style);
  }
}
