import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/models/enums.dart';
import '../l10n/generated/app_localizations.dart';
import '../router/routes.dart';
import '../session/session_controller.dart';

/// App-bar action that returns to the signed-in role's home (`Routes.homeFor`).
/// Hidden for Receiver and Admin, whose navigation stays unchanged.
class HomeButton extends ConsumerWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session is! SignedIn) return const SizedBox.shrink();
    final role = session.me.role;
    if (role == Role.receiver || role == Role.admin || role == Role.unknown) return const SizedBox.shrink();
    return IconButton(
      key: const Key('home-button'),
      tooltip: AppLocalizations.of(context).navHome,
      icon: const Icon(Icons.home_outlined),
      onPressed: () => context.go(Routes.homeFor(role)),
    );
  }
}
