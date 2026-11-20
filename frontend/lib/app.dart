import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/providers.dart';
import 'core/push/push_service.dart';
import 'core/session/session_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class TranixApp extends ConsumerWidget {
  const TranixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final router = ref.watch(routerProvider);
    // A-303: push after sign-in; tapping a notification opens its route.
    ref.listen(sessionProvider, (_, next) {
      if (next is SignedIn) {
        final push = ref.read(pushServiceProvider)..onOpenRoute = router.push;
        push.start();
      }
    });
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: Locale(language.name),
      supportedLocales: AppLocalizations.supportedLocales,
      // material_ui's own delegates (flutter_localizations targets the deprecated flutter/material types).
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      routerConfig: router,
      builder: (context, child) {
        // Support system font scaling up to 1.3× (ui-guidelines).
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: 1.3)),
          child: child!,
        );
      },
    );
  }
}
