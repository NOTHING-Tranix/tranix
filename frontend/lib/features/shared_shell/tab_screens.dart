import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../profile/presentation/profile_screens.dart';
import '../driver/driver_feature.dart';
import '../driver/suggestions_screen.dart';
import '../driver/trip_feature.dart';
import '../notifications/notifications_feature.dart';
import '../payments/payments_feature.dart';
import '../shipper/presentation/shipper_screens.dart';
import '../shipper/wishlist_feature.dart';
import 'role_shell.dart';

/// M0: every tab is a placeholder; real screens replace these per milestone (screens.md).
Widget tabScreenFor(ShellTab tab) => switch (tab.label) {
      TabLabel.profile => const ProfileScreen(),
      TabLabel.notifications => const NotificationsScreen(),
      TabLabel.home when tab.path == Routes.lp || tab.path == Routes.fn => const ShipperHomeScreen(),
      TabLabel.home when tab.path == Routes.driver => const DriverHomeScreen(),
      TabLabel.suggestions => const SuggestionsScreen(),
      TabLabel.wishlist => const WishlistScreen(actions: [NotificationBell(), ProfileAvatarButton()]),
      TabLabel.currentTrip => const CurrentTripScreen(),
      TabLabel.tracking => const _LoadsTab(ongoing: true),
      TabLabel.history when tab.path.startsWith(Routes.lp) || tab.path.startsWith(Routes.fn) => const _LoadsTab(ongoing: false),
      TabLabel.history when tab.path.startsWith(Routes.driver) => const DriverHistoryScreen(),
      _ => PlaceholderTab(tab: tab),
    };

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.tab});

  final ShellTab tab;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tabLabel(l, tab.label)), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: EmptyState(icon: tabIcon(tab.label), message: l.comingSoon),
    );
  }
}

String roleLabel(AppLocalizations l, Role role) => switch (role) {
      Role.loadProvider => l.roleLoadProvider,
      Role.farmerNetwork => l.roleFarmerNetwork,
      Role.driver => l.roleDriver,
      Role.organization => l.roleOrganization,
      Role.receiver => l.roleReceiver,
      Role.admin => l.roleAdmin,
      Role.unknown => l.statusUnknown,
    };

/// Avatar in home app bars → S-07 profile pop-up.
class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context).navProfile,
      icon: const Icon(Icons.account_circle_outlined),
      onPressed: () => showProfileSheet(context, ref),
    );
  }
}

class _LoadsTab extends StatelessWidget {
  const _LoadsTab({required this.ongoing});

  final bool ongoing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LoadListScreen(ongoing: ongoing, title: ongoing ? l.navTracking : l.navHistory);
  }
}
