import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/session/session_controller.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import 'role_shell.dart';

/// M0: every tab is a placeholder; real screens replace these per milestone (screens.md).
Widget tabScreenFor(ShellTab tab) => switch (tab.label) {
      TabLabel.profile => const ProfileTabPlaceholder(),
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
      appBar: AppBar(title: Text(tabLabel(l, tab.label))),
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
      appBar: AppBar(title: Text(tabLabel(l, tab.label))),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ongoingLoadsProvider.future),
        child: AsyncView(
          value: loads,
          onRetry: () => ref.invalidate(ongoingLoadsProvider),
          data: (page) => page.items.isEmpty
              ? const EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _LoadCard(load: page.items[i]),
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

class ProfileTabPlaceholder extends ConsumerWidget {
  const ProfileTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final me = session is SignedIn ? session.me : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (me != null) ...[
            Row(
              children: [
                CompletionRing(percent: me.profileCompletion),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(roleLabel(l, me.role)),
                      const SizedBox(height: 4),
                      TrustScoreBadge(score: me.trustScore),
                    ],
                  ),
                ),
              ],
            ),
            if (me.walletBalanceInr != null) ...[
              const SizedBox(height: 24),
              Text(l.walletBalance),
              MoneyText(me.walletBalanceInr!, large: true),
            ],
            if (me.verificationStatus != VerificationStatus.verified) ...[
              const SizedBox(height: 24),
              Text(l.verificationBanner, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l.actionSignOut),
          ),
        ],
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
