import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/widgets.dart';

/// Bottom-navigation scaffold of a role (`StatefulShellRoute`), with the offline banner on top.
class RoleShell extends StatelessWidget {
  const RoleShell({super.key, required this.tabs, required this.navigationShell});

  final List<ShellTab> tabs;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tabIcon(tab.label)), label: tabLabel(l, tab.label)),
        ],
      ),
    );
  }
}

String tabLabel(AppLocalizations l, TabLabel label) => switch (label) {
      TabLabel.home => l.navHome,
      TabLabel.tracking => l.navTracking,
      TabLabel.history => l.navHistory,
      TabLabel.wishlist => l.navWishlist,
      TabLabel.profile => l.navProfile,
      TabLabel.farmers => l.navFarmers,
      TabLabel.suggestions => l.navSuggestions,
      TabLabel.currentTrip => l.navCurrentTrip,
      TabLabel.dashboard => l.navDashboard,
      TabLabel.trucks => l.navTrucks,
      TabLabel.drivers => l.navDrivers,
      TabLabel.trips => l.navTrips,
      TabLabel.loads => l.navLoads,
      TabLabel.notifications => l.navNotifications,
    };

IconData tabIcon(TabLabel label) => switch (label) {
      TabLabel.home => Icons.home_outlined,
      TabLabel.tracking => Icons.local_shipping_outlined,
      TabLabel.history => Icons.history,
      TabLabel.wishlist => Icons.favorite_border,
      TabLabel.profile => Icons.person_outline,
      TabLabel.farmers => Icons.agriculture_outlined,
      TabLabel.suggestions => Icons.list_alt,
      TabLabel.currentTrip => Icons.route_outlined,
      TabLabel.dashboard => Icons.dashboard_outlined,
      TabLabel.trucks => Icons.fire_truck_outlined,
      TabLabel.drivers => Icons.badge_outlined,
      TabLabel.trips => Icons.map_outlined,
      TabLabel.loads => Icons.inventory_2_outlined,
      TabLabel.notifications => Icons.notifications_none,
    };
