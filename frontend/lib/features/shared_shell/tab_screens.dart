import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../profile/presentation/profile_screens.dart';
import '../notifications/notifications_feature.dart';
import 'role_shell.dart';

/// M0: every tab is a placeholder; real screens replace these per milestone (screens.md).
Widget tabScreenFor(ShellTab tab) => switch (tab.label) {
      TabLabel.profile => const ProfileScreen(),
      TabLabel.notifications => const NotificationsScreen(),
      TabLabel.home when tab.path == Routes.lp || tab.path == Routes.fn => HomeWithLoadsPlaceholder(tab: tab),
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

/// Ongoing loads from `GET /loads?scope=ONGOING` — proves dio + mock + models + chips end to end.
final ongoingLoadsProvider = FutureProvider.autoDispose<Paged<LoadSummary>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await guardApi(
    () => dio.get<Map<String, dynamic>>('/loads', queryParameters: {'scope': 'ONGOING', 'page': 0}),
  );
  return Paged.fromJson(res.data!, LoadSummary.fromJson);
});

class HomeWithLoadsPlaceholder extends ConsumerWidget {
  const HomeWithLoadsPlaceholder({super.key, required this.tab});

  final ShellTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final loads = ref.watch(ongoingLoadsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(tabLabel(l, tab.label)), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ongoingLoadsProvider.future),
        child: AsyncView(
          value: loads,
          onRetry: () => ref.invalidate(ongoingLoadsProvider),
          data: (page) => page.items.isEmpty
              ? const EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => i == 0 ? const HomeNotificationCards() : _LoadCard(load: page.items[i - 1]),
                ),
        ),
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  const _LoadCard({required this.load});

  final LoadSummary load;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(load.code, style: t.titleMedium)),
                StatusChip.load(context, load.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('${load.goodsType} · ${load.quantity} ${load.quantityUnit.name}', style: t.bodyLarge),
            Text('${load.pickupArea} → ${load.dropArea}', style: t.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(Fmt.dateTime(load.pickupWindowStart))),
                MoneyText(load.agreedAmountInr),
              ],
            ),
          ],
        ),
      ),
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
