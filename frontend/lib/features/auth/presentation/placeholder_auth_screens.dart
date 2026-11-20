import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/widgets.dart';

/// Placeholders until A-103 / A-104 (M1).
class SignUpPlaceholderScreen extends StatelessWidget {
  const SignUpPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => _Placeholder(title: AppLocalizations.of(context).actionSignUp);
}

class SignInPlaceholderScreen extends StatelessWidget {
  const SignInPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => _Placeholder(title: AppLocalizations.of(context).actionSignIn);
}

/// ADMIN uses Swagger / Flutter web later (D-15).
class UnsupportedRoleScreen extends StatelessWidget {
  const UnsupportedRoleScreen({super.key});

  @override
  Widget build(BuildContext context) => _Placeholder(title: AppLocalizations.of(context).roleAdmin);
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(onPressed: () => context.go(Routes.welcome)),
      ),
      body: EmptyState(message: AppLocalizations.of(context).comingSoon),
    );
  }
}
