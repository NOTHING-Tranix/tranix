import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/widgets.dart';

/// ADMIN uses Swagger / Flutter web later (D-15).
class UnsupportedRoleScreen extends StatelessWidget {
  const UnsupportedRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.roleAdmin),
        leading: BackButton(onPressed: () => context.go(Routes.welcome)),
      ),
      body: EmptyState(message: l.comingSoon),
    );
  }
}
