import 'package:material_ui/material_ui.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/widgets/widgets.dart';

/// Screen planned for a later milestone.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: EmptyState(message: AppLocalizations.of(context).comingSoon));
  }
}
