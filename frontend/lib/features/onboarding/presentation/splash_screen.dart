import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/widgets.dart';

/// S-01: checks stored tokens; the router moves on when the session state changes. Full flow in A-101.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sessionProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: session is SessionError
            ? ErrorState(error: session.error, onRetry: () => ref.read(sessionProvider.notifier).bootstrap())
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping, size: 72, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(l.appTitle, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    const LoadingView(),
                  ],
                ),
              ),
      ),
    );
  }
}
