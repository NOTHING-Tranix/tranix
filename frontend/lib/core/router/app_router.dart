import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/placeholder_auth_screens.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/profile/presentation/profile_screens.dart';
import '../../features/driver/driver_feature.dart';
import '../../features/notifications/notifications_feature.dart';
import '../../features/wallet/wallet_feature.dart';
import '../../features/shipper/presentation/shipper_screens.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/shared_shell/role_shell.dart';
import '../../features/shared_shell/tab_screens.dart';
import '../session/session_controller.dart';
import 'routes.dart';

/// Decides where a location should go for the current session (pure, unit-tested).
String? redirectFor(SessionState session, String location) {
  switch (session) {
    case SessionUnknown():
    case SessionError():
      return location == Routes.splash ? null : Routes.splash;
    case SignedOut():
      if (Routes.public.contains(location) && location != Routes.splash) return null;
      return Routes.welcome;
    case SignedIn(:final me):
      final home = Routes.homeFor(me.role);
      if (Routes.public.contains(location)) return home;
      if (home == Routes.unsupported) return location == Routes.unsupported ? null : Routes.unsupported;
      // Stay inside the own role's shell (e.g. a driver can't open /lp).
      for (final shell in RoleTabs.byShell.keys) {
        if (Routes.isInShell(location, shell) && shell != home) return home;
      }
      return null;
  }
}

/// Bridges Riverpod session changes to go_router's refreshListenable.
class _SessionListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable();
  ref.listen(sessionProvider, (_, _) => refresh.notify());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: Routes.signUpOtp, builder: (_, _) => const OtpScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.signInOtp, builder: (_, _) => const OtpScreen()),
      GoRoute(path: Routes.unsupported, builder: (_, _) => const UnsupportedRoleScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: Routes.profileEdit, builder: (_, _) => const EditBasicsScreen()),
      GoRoute(path: Routes.profileRole, builder: (_, _) => const RoleProfileScreen()),
      GoRoute(
        path: Routes.profileDocument,
        builder: (_, s) => DocumentFormScreen(
          type: documentTypeFromWire(s.uri.queryParameters['type']),
          replaceId: s.uri.queryParameters['replace'],
          truck: s.uri.queryParameters['truck'] == '1',
        ),
      ),
      GoRoute(path: Routes.profileMobile, builder: (_, _) => const ChangeMobileScreen()),
      GoRoute(path: Routes.verification, builder: (_, _) => const VerificationScreen()),
      GoRoute(path: Routes.wallet, builder: (_, _) => const WalletScreen()),
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: Routes.driverTruckForm, builder: (_, _) => const TruckFormScreen()),
      GoRoute(path: Routes.driverLocker, builder: (_, _) => const LockerScreen()),
      GoRoute(path: Routes.postLoad, builder: (_, _) => const PostLoadScreen()),
      GoRoute(path: Routes.postLoadReview, builder: (_, _) => const ReviewLoadScreen()),
      GoRoute(path: '/loads/:id', builder: (_, s) => LoadDetailScreen(id: s.pathParameters['id']!)),
      for (final entry in RoleTabs.byShell.entries) _shell(entry.value),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellRoute _shell(List<ShellTab> tabs) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => RoleShell(tabs: tabs, navigationShell: navigationShell),
    branches: [
      for (final tab in tabs)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: tab.path,
              builder: (context, state) => tabScreenFor(tab),
            ),
          ],
        ),
    ],
  );
}

@visibleForTesting
List<RouteBase> debugShellRoutes() => [for (final t in RoleTabs.byShell.values) _shell(t)];
