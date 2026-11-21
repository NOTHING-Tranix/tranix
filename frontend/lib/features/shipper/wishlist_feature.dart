import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/settings_provider.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';

/// `GET /wishlist/org-search` row.
class OrgHit {
  OrgHit(this.orgId, this.orgName, this.orgCode, this.district, this.trustScore, this.trucksCount);

  factory OrgHit.fromJson(Map<String, dynamic> j) => OrgHit(j['orgId'] as String, j['orgName'] as String? ?? '',
      j['orgCode'] as String? ?? '', j['district'] as String?, (j['trustScore'] as num?)?.toDouble() ?? 70, (j['trucksCount'] as num?)?.toInt() ?? 0);

  final String orgId;
  final String orgName;
  final String orgCode;
  final String? district;
  final double trustScore;
  final int trucksCount;
}

/// `GET /wishlist/candidates` row.
class WishlistCandidate {
  WishlistCandidate(this.targetType, this.truckId, this.truckNumber, this.driverName, this.orgId, this.orgName, this.tripsTogether);

  factory WishlistCandidate.fromJson(Map<String, dynamic> j) => WishlistCandidate(
        j['targetType'] == 'TRUCK' ? WishlistTargetType.truck : WishlistTargetType.organization,
        j['truckId'] as String?,
        j['truckNumber'] as String?,
        j['driverName'] as String?,
        j['orgId'] as String?,
        j['orgName'] as String?,
        (j['tripsTogether'] as num?)?.toInt() ?? 0,
      );

  final WishlistTargetType targetType;
  final String? truckId;
  final String? truckNumber;
  final String? driverName;
  final String? orgId;
  final String? orgName;
  final int tripsTogether;
}

/// Contract §6A.
class WishlistApi {
  WishlistApi(this._dio);

  final Dio _dio;

  Future<List<WishlistEntry>> list() async => [
        for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/wishlist'))).data!) WishlistEntry.fromJson(e as Map<String, dynamic>),
      ];

  Future<WishlistEntry> addTruck(String truckId, {String? note}) => _add({'targetType': 'TRUCK', 'truckId': truckId, 'note': ?note});

  Future<WishlistEntry> addOrg(String orgId, {String? note}) => _add({'targetType': 'ORGANIZATION', 'orgId': orgId, 'note': ?note});

  Future<WishlistEntry> _add(Map<String, dynamic> body) async =>
      WishlistEntry.fromJson((await guardApi(() => _dio.post<Map<String, dynamic>>('/wishlist', data: body))).data!);

  Future<WishlistEntry> note(String id, String? note) async =>
      WishlistEntry.fromJson((await guardApi(() => _dio.put<Map<String, dynamic>>('/wishlist/$id', data: {'note': note}))).data!);

  Future<void> remove(String id) => guardApi(() => _dio.delete<void>('/wishlist/$id'));

  Future<List<OrgHit>> orgSearch(String q) async => [
        for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/wishlist/org-search', queryParameters: {'q': q}))).data!)
          OrgHit.fromJson(e as Map<String, dynamic>),
      ];

  Future<List<WishlistCandidate>> candidates() async => [
        for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/wishlist/candidates'))).data!)
          WishlistCandidate.fromJson(e as Map<String, dynamic>),
      ];

  Future<LoadDetail> openToEveryone(String loadId) async =>
      LoadDetail.fromJson((await guardApi(() => _dio.post<Map<String, dynamic>>('/loads/$loadId/open-to-everyone'))).data!);
}

final wishlistApiProvider = Provider<WishlistApi>((ref) => WishlistApi(ref.watch(dioProvider)));
final wishlistProvider = FutureProvider.autoDispose<List<WishlistEntry>>((ref) => ref.watch(wishlistApiProvider).list());
final wishlistCandidatesProvider =
    FutureProvider.autoDispose<List<WishlistCandidate>>((ref) => ref.watch(wishlistApiProvider).candidates());

String entryTitle(WishlistEntry e) =>
    e.targetType == WishlistTargetType.truck ? (e.truckNumber ?? '') : (e.orgName ?? '');

/// LP-07 wish list: my list (notes, remove, limit), from my trips, find organization.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navWishlist),
          actions: actions,
          bottom: TabBar(isScrollable: true, tabs: [Tab(text: l.myList), Tab(text: l.fromMyTrips), Tab(text: l.findOrganization)]),
        ),
        body: const TabBarView(children: [_MyList(), _FromTrips(), _OrgSearch()]),
      ),
    );
  }
}

Future<void> _guard(BuildContext context, Future<void> Function() action, {String? done}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e is StateError ? e.message : errorMessage(l, e))));
  }
}

class _MyList extends ConsumerWidget {
  const _MyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final max = ref.watch(publicSettingsProvider).value?.wishlistMax ?? 20;
    return AsyncView(
      value: ref.watch(wishlistProvider),
      onRetry: () => ref.invalidate(wishlistProvider),
      data: (list) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(wishlistProvider),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(l.wishlistCount(list.length, max), style: Theme.of(context).textTheme.labelLarge),
          if (list.isEmpty) EmptyState(icon: Icons.favorite_border, message: l.wishlistEmptyHint),
          for (final e in list)
            Card(
              child: ListTile(
                leading: Icon(e.targetType == WishlistTargetType.truck ? Icons.local_shipping_outlined : Icons.business),
                title: Text(entryTitle(e)),
                subtitle: Text([
                  if (e.vehicleType != null) vehicleLabel(l, e.vehicleType!),
                  if (e.targetType == WishlistTargetType.truck && e.orgName != null) e.orgName!,
                  if (e.driverName != null) e.driverName!,
                  l.tripsTogether(e.tripsTogether),
                  if (e.available) l.availableNow,
                  if (e.note != null) '“${e.note}”',
                ].join(' · ')),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  TrustScoreBadge(score: e.trustScore),
                  PopupMenuButton<String>(
                    key: Key('entry-${e.id}'),
                    onSelected: (v) => v == 'note' ? _editNote(context, ref, e) : _remove(context, ref, e),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'note', child: Text(l.noteLabel)),
                      PopupMenuItem(value: 'remove', child: Text(l.removeAction)),
                    ],
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, WishlistEntry e) => _guard(context, () async {
        await ref.read(wishlistApiProvider).remove(e.id);
        ref.invalidate(wishlistProvider);
        ref.invalidate(wishlistCandidatesProvider);
      });

  Future<void> _editNote(BuildContext context, WidgetRef ref, WishlistEntry e) async {
    final l = AppLocalizations.of(context);
    var text = e.note ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.noteLabel),
        content: TextFormField(key: const Key('wish-note'), initialValue: text, maxLength: 200, onChanged: (v) => text = v),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.save)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _guard(context, () async {
      await ref.read(wishlistApiProvider).note(e.id, text.trim().isEmpty ? null : text.trim());
      ref.invalidate(wishlistProvider);
    });
  }
}

class _FromTrips extends ConsumerWidget {
  const _FromTrips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AsyncView(
      value: ref.watch(wishlistCandidatesProvider),
      onRetry: () => ref.invalidate(wishlistCandidatesProvider),
      data: (list) => list.isEmpty
          ? EmptyState(icon: Icons.history, message: l.noCandidates)
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final c in list)
                Card(
                  child: ListTile(
                    leading: Icon(c.targetType == WishlistTargetType.truck ? Icons.local_shipping_outlined : Icons.business),
                    title: Text(c.targetType == WishlistTargetType.truck ? (c.truckNumber ?? '') : (c.orgName ?? '')),
                    subtitle: Text([
                      if (c.driverName != null) c.driverName!,
                      if (c.targetType == WishlistTargetType.truck && c.orgName != null) c.orgName!,
                      l.tripsTogether(c.tripsTogether),
                    ].join(' · ')),
                    trailing: IconButton(
                      tooltip: l.addToWishlist,
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => _guard(context, () async {
                        final api = ref.read(wishlistApiProvider);
                        c.targetType == WishlistTargetType.truck ? await api.addTruck(c.truckId!) : await api.addOrg(c.orgId!);
                        ref.invalidate(wishlistProvider);
                        ref.invalidate(wishlistCandidatesProvider);
                      }, done: l.addedToWishlist),
                    ),
                  ),
                ),
            ]),
    );
  }
}

class _OrgSearch extends ConsumerStatefulWidget {
  const _OrgSearch();

  @override
  ConsumerState<_OrgSearch> createState() => _OrgSearchState();
}

class _OrgSearchState extends ConsumerState<_OrgSearch> {
  final _q = TextEditingController();
  Future<List<OrgHit>>? _results;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _search() {
    if (_q.text.trim().length < 2) return;
    final future = ref.read(wishlistApiProvider).orgSearch(_q.text.trim());
    setState(() {
      _results = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextField(
        key: const Key('org-search'),
        controller: _q,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(
          labelText: l.searchOrgHint,
          suffixIcon: IconButton(tooltip: l.searchOrgHint, icon: const Icon(Icons.search), onPressed: _search),
        ),
      ),
      const SizedBox(height: 8),
      if (_results != null)
        FutureBuilder<List<OrgHit>>(
          future: _results,
          builder: (context, snap) {
            if (snap.hasError) return Text(errorMessage(l, snap.error!));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            if (snap.data!.isEmpty) return EmptyState(icon: Icons.search_off, message: l.noResults);
            return Column(children: [
              for (final o in snap.data!)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(o.orgName),
                    subtitle: Text([o.orgCode, if (o.district != null) o.district!, l.trucksCount(o.trucksCount)].join(' · ')),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      TrustScoreBadge(score: o.trustScore),
                      IconButton(
                        tooltip: l.addToWishlist,
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () => _guard(context, () async {
                          await ref.read(wishlistApiProvider).addOrg(o.orgId);
                          ref.invalidate(wishlistProvider);
                        }, done: l.addedToWishlist),
                      ),
                    ]),
                  ),
                ),
            ]);
          },
        ),
    ]);
  }
}

/// A-410 banner on a wish-list load (not accepted yet) with **Open to everyone**.
class WishlistBanner extends ConsumerWidget {
  const WishlistBanner({super.key, required this.load, required this.onChanged});

  final LoadDetail load;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final first = load.audience == LoadAudience.wishlistFirst && load.wishlistUntil != null;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.favorite),
            const SizedBox(width: 8),
            Expanded(child: Text(first ? l.wishlistFirstBanner(Fmt.dateTime(load.wishlistUntil!)) : l.wishlistOnlyBanner)),
          ]),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _guard(context, () async {
                await ref.read(wishlistApiProvider).openToEveryone(load.id);
                onChanged();
              }),
              child: Text(l.openToEveryone),
            ),
          ),
        ]),
      ),
    );
  }
}

/// A-410: "Add to wish list" from a finished trip — adds the trip's truck when it is a candidate.
Future<void> addTripTruckToWishlist(BuildContext context, WidgetRef ref, String truckNumber) {
  final l = AppLocalizations.of(context);
  return _guard(context, () async {
    final api = ref.read(wishlistApiProvider);
    final match = (await api.candidates())
        .where((c) => c.targetType == WishlistTargetType.truck && c.truckNumber == truckNumber)
        .firstOrNull;
    if (match == null) throw StateError(l.noCandidates);
    await api.addTruck(match.truckId!);
    ref.invalidate(wishlistProvider);
  }, done: l.addedToWishlist);
}
