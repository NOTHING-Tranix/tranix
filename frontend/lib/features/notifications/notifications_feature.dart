import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/session/session_controller.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../profile/application/profile_providers.dart';

/// Contract §11 (notifications).
class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<Paged<AppNotification>> list(NotificationTab tab, {int page = 0}) async {
    final res = await guardApi(() => _dio.get<Map<String, dynamic>>('/notifications',
        queryParameters: {'tab': tab.name.toUpperCase(), 'page': page}));
    return Paged.fromJson(res.data!, AppNotification.fromJson);
  }

  Future<NotificationSummary> summary() async => NotificationSummary.fromJson(
        (await guardApi(() => _dio.get<Map<String, dynamic>>('/notifications/summary'))).data!,
      );

  Future<void> read(String id) => guardApi(() => _dio.post<void>('/notifications/$id/read'));

  Future<void> readAll() => guardApi(() => _dio.post<void>('/notifications/read-all'));
}

final notificationsApiProvider = Provider<NotificationsApi>((ref) => NotificationsApi(ref.watch(dioProvider)));

final notificationSummaryProvider = FutureProvider.autoDispose<NotificationSummary>(
  (ref) => ref.watch(notificationsApiProvider).summary(),
);

final notificationsProvider = FutureProvider.autoDispose.family<Paged<AppNotification>, NotificationTab>(
  (ref, tab) => ref.watch(notificationsApiProvider).list(tab),
);

const _tabs = [NotificationTab.trips, NotificationTab.wallet, NotificationTab.tranix, NotificationTab.account];

String _tabLabel(AppLocalizations l, NotificationTab t) => switch (t) {
      NotificationTab.trips => l.tabTrips,
      NotificationTab.wallet => l.tabWallet,
      NotificationTab.tranix => l.tabTranix,
      _ => l.tabAccount,
    };

/// S-09 Notifications with tabs and unread counts.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final unread = ref.watch(notificationSummaryProvider).value?.unreadByTab ?? const {};
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navNotifications),
          actions: [
            TextButton(
              onPressed: () async {
                await ref.read(notificationsApiProvider).readAll();
                _refreshAll(ref);
              },
              child: Text(l.markAllRead),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final t in _tabs)
                Tab(
                  child: Badge(
                    isLabelVisible: (unread[t.name.toUpperCase()] ?? 0) > 0,
                    label: Text('${unread[t.name.toUpperCase()] ?? 0}'),
                    child: Padding(padding: const EdgeInsets.only(right: 8), child: Text(_tabLabel(l, t))),
                  ),
                ),
            ],
          ),
        ),
        body: TabBarView(children: [for (final t in _tabs) _NotificationList(tab: t)]),
      ),
    );
  }
}

void _refreshAll(WidgetRef ref) {
  ref.invalidate(notificationSummaryProvider);
  for (final t in _tabs) {
    ref.invalidate(notificationsProvider(t));
  }
  ref.invalidate(meProvider);
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.tab});

  final NotificationTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async => _refreshAll(ref),
      child: AsyncView(
        value: ref.watch(notificationsProvider(tab)),
        onRetry: () => ref.invalidate(notificationsProvider(tab)),
        data: (page) => page.items.isEmpty
            ? EmptyState(icon: Icons.notifications_none, message: l.noNotifications)
            : ListView.separated(
                itemCount: page.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = page.items[i];
                  return ListTile(
                    leading: Icon(n.read ? Icons.notifications_none : Icons.notifications_active,
                        color: n.read ? null : Theme.of(context).colorScheme.primary),
                    title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text('${n.body}\n${Fmt.dateTime(n.createdAt)}'),
                    isThreeLine: true,
                    onTap: () async {
                      if (!n.read) {
                        await ref.read(notificationsApiProvider).read(n.id);
                        _refreshAll(ref);
                      }
                      if (n.route != null && context.mounted) await context.push(n.route!);
                    },
                  );
                },
              ),
      ),
    );
  }
}

/// Bell with unread badge for home app bars.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final count = session is SignedIn ? session.me.unreadNotifications : 0;
    return IconButton(
      tooltip: AppLocalizations.of(context).navNotifications,
      onPressed: () => context.push(Routes.notifications),
      icon: Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.notifications_none)),
    );
  }
}

/// Home cards: latest Tranix message and latest trip update (A-304 / A-306).
class HomeNotificationCards extends ConsumerWidget {
  const HomeNotificationCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(notificationSummaryProvider).value;
    if (s == null) return const SizedBox.shrink();
    Widget card(String label, AppNotification n) => Card(
          child: ListTile(
            title: Text(label, style: Theme.of(context).textTheme.labelMedium),
            subtitle: Text('${n.title}\n${n.body}'),
            isThreeLine: true,
            onTap: n.route == null ? null : () => context.push(n.route!),
          ),
        );
    return Column(
      children: [
        if (s.latestTripUpdate != null) card(l.latestTripUpdate, s.latestTripUpdate!),
        if (s.latestTranixMessage != null) card(l.latestTranixMessage, s.latestTranixMessage!),
      ],
    );
  }
}
