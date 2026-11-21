import '../../shared/models/enums.dart';

/// Route paths (docs/screens.md). Use these constants, never string literals in widgets.
abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const signUpOtp = '/sign-up/otp';
  static const signInOtp = '/sign-in/otp';
  static const unsupported = '/unsupported';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileRole = '/profile/role';
  static const profileDocument = '/profile/document';
  static const profileMobile = '/profile/mobile';
  static const verification = '/verification';
  static const wallet = '/wallet';
  static const trustScore = '/trust-score';
  static const wishlist = '/wishlist';
  static const notifications = '/notifications';
  static const postLoad = '/post';
  static const postLoadReview = '/post/review';
  static String loadDetail(String id) => '/loads/$id';
  static const driverTruckForm = '/truck';
  static const driverLocker = '/locker';

  static const lp = '/lp';
  static const fn = '/fn';
  static const driver = '/driver';
  static const org = '/org';
  static const receiver = '/receiver';

  /// Pages reachable without signing in.
  static const public = {splash, welcome, signUp, signIn, signUpOtp, signInOtp};

  /// Home of each role's shell; ADMIN has no Android app (D-15).
  static String homeFor(Role role) => switch (role) {
        Role.loadProvider => lp,
        Role.farmerNetwork => fn,
        Role.driver => driver,
        Role.organization => org,
        Role.receiver => receiver,
        Role.admin || Role.unknown => unsupported,
      };

  static bool isInShell(String location, String shell) =>
      location == shell || location.startsWith('$shell/');
}

/// One bottom-navigation tab of a role shell.
class ShellTab {
  const ShellTab(this.path, this.label);

  final String path;

  /// Key resolved through AppLocalizations in the shell scaffold.
  final TabLabel label;
}

enum TabLabel { home, tracking, history, wishlist, profile, farmers, suggestions, currentTrip, dashboard, trucks, drivers, trips, loads, notifications }

/// Bottom navigation per role (docs/screens.md headings).
abstract final class RoleTabs {
  static const lp = [
    ShellTab(Routes.lp, TabLabel.home),
    ShellTab('${Routes.lp}/tracking', TabLabel.tracking),
    ShellTab('${Routes.lp}/history', TabLabel.history),
    ShellTab('${Routes.lp}/wishlist', TabLabel.wishlist),
    ShellTab('${Routes.lp}/profile', TabLabel.profile),
  ];
  static const fn = [
    ShellTab(Routes.fn, TabLabel.home),
    ShellTab('${Routes.fn}/farmers', TabLabel.farmers),
    ShellTab('${Routes.fn}/tracking', TabLabel.tracking),
    ShellTab('${Routes.fn}/history', TabLabel.history),
    ShellTab('${Routes.fn}/profile', TabLabel.profile),
  ];
  static const driver = [
    ShellTab(Routes.driver, TabLabel.home),
    ShellTab('${Routes.driver}/suggestions', TabLabel.suggestions),
    ShellTab('${Routes.driver}/trip', TabLabel.currentTrip),
    ShellTab('${Routes.driver}/history', TabLabel.history),
    ShellTab('${Routes.driver}/profile', TabLabel.profile),
  ];
  static const org = [
    ShellTab(Routes.org, TabLabel.dashboard),
    ShellTab('${Routes.org}/trucks', TabLabel.trucks),
    ShellTab('${Routes.org}/drivers', TabLabel.drivers),
    ShellTab('${Routes.org}/trips', TabLabel.trips),
    ShellTab('${Routes.org}/profile', TabLabel.profile),
  ];
  static const receiver = [
    ShellTab(Routes.receiver, TabLabel.loads),
    ShellTab('${Routes.receiver}/history', TabLabel.history),
    ShellTab('${Routes.receiver}/notifications', TabLabel.notifications),
    ShellTab('${Routes.receiver}/profile', TabLabel.profile),
  ];

  static const byShell = <String, List<ShellTab>>{
    Routes.lp: lp,
    Routes.fn: fn,
    Routes.driver: driver,
    Routes.org: org,
    Routes.receiver: receiver,
  };
}
