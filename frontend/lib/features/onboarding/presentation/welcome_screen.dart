import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/network/mock_interceptor.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/models/models.dart';
import '../../shared_shell/tab_screens.dart';

/// S-02: language chips + Sign up / Sign in. In mock builds a demo list opens any role shell.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const languageNames = {Language.en: 'English', Language.ta: 'தமிழ்', Language.hi: 'हिन्दी'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final language = ref.watch(languageProvider);
    final useMock = ref.watch(appConfigProvider).useMock;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            Icon(Icons.local_shipping, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(l.appTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            Text(l.tagline, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Text(l.chooseLanguage, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in languageNames.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: language == entry.key,
                    onSelected: (_) => ref.read(languageProvider.notifier).set(entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: l.actionSignUp, onPressed: () => context.go(Routes.signUp)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.go(Routes.signIn), child: Text(l.actionSignIn)),
            if (useMock) ...[
              const SizedBox(height: 32),
              const Divider(),
              Text(l.demoTitle, style: Theme.of(context).textTheme.titleMedium),
              for (final role in const [
                Role.loadProvider,
                Role.farmerNetwork,
                Role.driver,
                Role.organization,
                Role.receiver,
              ])
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: Text(l.demoOpenAs(roleLabel(l, role))),
                  onTap: () => _demoSignIn(context, ref, role),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Mock only: signs in through the mock API as [role].
  Future<void> _demoSignIn(BuildContext context, WidgetRef ref, Role role) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    MockInterceptor.role = _roleValue(role);
    try {
      final session = ref.read(sessionProvider.notifier);
      final dio = ref.read(dioProvider);
      final res = await guardApi(
        () => dio.post<Map<String, dynamic>>(
          '/auth/sign-in',
          data: {'mobile': '9876543210', 'otp': '123456', 'deviceId': 'mock-device'},
        ),
      );
      await session.signedIn(AuthTokens.fromJson(res.data!));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }

  static String _roleValue(Role role) => role.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
}
