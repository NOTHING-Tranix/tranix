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
import '../../../core/settings_provider.dart';
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
    ref.watch(publicSettingsProvider); // warm up: OTP timer and forms need it
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
            if (!ref.watch(appConfigProvider).isProd && !useMock) ...[
              const SizedBox(height: 16),
              // Testing builds: point the app at another server (e.g. an ngrok tunnel) without reinstalling.
              TextButton.icon(
                key: const Key('server-address'),
                onPressed: () => _editServer(context, ref),
                icon: const Icon(Icons.dns_outlined, size: 18),
                label: Text('${l.serverAddress}: ${Uri.tryParse(ref.watch(serverUrlProvider))?.host ?? ''}'),
              ),
            ],
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

  /// Testing builds only: set the server address (host like `abc.ngrok-free.dev` or a full URL); empty = default.
  Future<void> _editServer(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    var text = Uri.tryParse(ref.read(serverUrlProvider))?.host ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.serverAddress),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.serverAddressHint),
          TextFormField(
            key: const Key('server-input'),
            initialValue: text,
            keyboardType: TextInputType.url,
            autocorrect: false,
            onChanged: (v) => text = v,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.save)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(serverUrlProvider.notifier).set(text);
    ref.invalidate(publicSettingsProvider);
  }
}
