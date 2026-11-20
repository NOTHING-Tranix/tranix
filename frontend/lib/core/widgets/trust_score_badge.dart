import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// Trust Score (0–100) with label; colour band is decoration only — the number is always shown.
class TrustScoreBadge extends StatelessWidget {
  const TrustScoreBadge({super.key, required this.score});

  final num score;

  @override
  Widget build(BuildContext context) {
    final c = context.statusColors;
    final color = score >= 70 ? c.success : (score >= 50 ? c.warning : c.error);
    return Semantics(
      label: '${AppLocalizations.of(context).trustScore} ${score.round()}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, size: 18, color: color),
          const SizedBox(width: 4),
          Text('${score.round()}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
