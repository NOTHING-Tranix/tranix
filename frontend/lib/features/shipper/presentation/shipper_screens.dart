
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/location_picker.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/labels.dart';
import '../../../shared/models/models.dart';
import '../../notifications/notifications_feature.dart';
import '../../profile/presentation/profile_screens.dart';
import '../../shared_shell/tab_screens.dart' show ProfileAvatarButton;
import '../../payments/payments_feature.dart';
import '../wishlist_feature.dart';
import '../../farmers/farmers_feature.dart';
import '../application/post_load_draft.dart';
import '../data/loads_api.dart';

/// LP-01 / FN home.
class ShipperHomeScreen extends ConsumerWidget {
  const ShipperHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final me = session is SignedIn ? session.me : null;
    final loads = ref.watch(loadListProvider(true));
    final postingCharge = ref.watch(publicSettingsProvider).value?.postingChargeInr;
    return Scaffold(
      appBar: AppBar(title: Text(l.navHome), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loadListProvider(true));
          ref.invalidate(notificationSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (me?.walletBalanceInr != null)
              Card(
                child: ListTile(
                  title: Text(l.walletBalance),
                  subtitle: MoneyText(me!.walletBalanceInr!, large: true),
                  trailing: FilledButton.tonal(onPressed: () => context.push(Routes.wallet), child: Text(l.topUp)),
                ),
              ),
            if (me != null && me.verificationStatus != VerificationStatus.verified)
              BlockingReasonCard(
                message: l.completeVerificationTitle,
                actionLabel: l.goToProfile,
                onAction: () => context.push(Routes.verification),
              ),
            if (me?.walletBalanceInr != null && postingCharge != null && me!.walletBalanceInr! < postingCharge)
              BlockingReasonCard(
                icon: Icons.account_balance_wallet_outlined,
                message: l.topUpToPost(Fmt.money(postingCharge)),
                actionLabel: l.topUp,
                onAction: () => context.push(Routes.wallet),
              ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: l.postLoad,
              icon: Icons.add,
              onPressed: () {
                // New draft with the sender prefilled from Me (editable).
                ref.read(loadDraftProvider.notifier).replace(LoadDraft(senderName: me?.name ?? '', senderMobile: me?.mobile ?? ''));
                context.push(Routes.postLoad);
              },
            ),
            if (me?.role == Role.farmerNetwork) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('post-for-farmer'),
                onPressed: () => pickFarmerAndPost(context, ref),
                icon: const Icon(Icons.agriculture_outlined),
                label: Text(l.postForFarmer),
              ),
            ],
            const SizedBox(height: 16),
            const HomeNotificationCards(),
            Text(l.ongoingLoads, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AsyncView(
              value: loads,
              onRetry: () => ref.invalidate(loadListProvider(true)),
              data: (page) => page.items.isEmpty
                  ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.noLoads)))
                  : Column(children: [for (final load in page.items) LoadCard(load: load)]),
            ),
          ],
        ),
      ),
    );
  }
}

/// LP-03 Tracking / LP-05 History list (Farmer Networks can filter by farmer, FN-03).
class LoadListScreen extends ConsumerStatefulWidget {
  const LoadListScreen({super.key, required this.ongoing, required this.title});

  final bool ongoing;
  final String title;

  @override
  ConsumerState<LoadListScreen> createState() => _LoadListScreenState();
}

class _LoadListScreenState extends ConsumerState<LoadListScreen> {
  String? _farmerId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final isNetwork = session is SignedIn && session.me.role == Role.farmerNetwork;
    final provider = _farmerId == null ? loadListProvider(widget.ongoing) : farmerLoadListProvider((widget.ongoing, _farmerId!));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: Column(children: [
        if (isNetwork)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownButtonFormField<String?>(
              key: const Key('farmer-filter'),
              initialValue: _farmerId,
              decoration: InputDecoration(labelText: l.navFarmers),
              items: [
                DropdownMenuItem(value: null, child: Text(l.allFarmers)),
                for (final f in ref.watch(farmersProvider('')).value?.items ?? const <Farmer>[])
                  DropdownMenuItem(value: f.id, child: Text(f.name)),
              ],
              onChanged: (v) => setState(() => _farmerId = v),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(provider),
            child: AsyncView(
              value: ref.watch(provider),
              onRetry: () => ref.invalidate(provider),
              data: (page) => page.items.isEmpty
                  ? EmptyState(message: l.noLoads)
                  : ListView(padding: const EdgeInsets.all(16), children: [for (final load in page.items) LoadCard(load: load)]),
            ),
          ),
        ),
      ]),
    );
  }
}

class LoadCard extends StatelessWidget {
  const LoadCard({super.key, required this.load, this.openDetail = true});

  final LoadSummary load;

  /// Org trip lists show the card only (the shipper detail is not theirs).
  final bool openDetail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: openDetail ? () => context.push(Routes.loadDetail(load.id)) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Expanded(child: Text(load.code, style: t.titleMedium)), StatusChip.load(context, load.status)]),
              const SizedBox(height: 8),
              Text('${load.goodsType}${load.description == null ? '' : ' · ${load.description}'}', style: t.bodyLarge),
              Text('${load.quantity} ${unitLabel(l, load.quantityUnit)}'),
              Text('${load.pickupArea} → ${load.dropArea}'),
              if (load.postedForFarmerName != null) Text(l.postedFor(load.postedForFarmerName!)),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: Text(Fmt.dateTime(load.pickupWindowStart))), MoneyText(load.agreedAmountInr)]),
            ],
          ),
        ),
      ),
    );
  }
}

/// LP-02 Post a load (also used to edit while NOT_ACCEPTED).
class PostLoadScreen extends ConsumerStatefulWidget {
  const PostLoadScreen({super.key});

  @override
  ConsumerState<PostLoadScreen> createState() => _PostLoadScreenState();
}

class _PostLoadScreenState extends ConsumerState<PostLoadScreen> {
  final _form = GlobalKey<FormState>();
  bool _submitted = false;
  String? _sectionError;

  LoadDraft get d => ref.read(loadDraftProvider);

  void _set(LoadDraft Function(LoadDraft d) change) => ref.read(loadDraftProvider.notifier).update(change);

  Future<void> _estimate() async {
    final x = d;
    if (x.pickup == null || x.drop == null || x.windowStart == null) return;
    try {
      final e = await ref.read(loadsApiProvider).estimate(
            pickup: GeoPoint(lat: x.pickup!.lat, lng: x.pickup!.lng),
            drop: GeoPoint(lat: x.drop!.lat, lng: x.drop!.lng),
            start: x.windowStart!,
          );
      _set((y) => y.copyWith(estimate: e));
    } catch (_) {
      // Estimate is informative; the server recalculates on posting.
    }
  }

  Future<void> _pickPlace(bool pickup) async {
    final l = AppLocalizations.of(context);
    final place = await Navigator.of(context).push<Place>(MaterialPageRoute(
      builder: (_) => LocationPickerScreen(title: pickup ? l.pickupSection : l.dropSection, initial: pickup ? d.pickup : d.drop),
    ));
    if (place == null) return;
    _set((x) => pickup ? x.copyWith(pickup: place, clearEstimate: true) : x.copyWith(drop: place, clearEstimate: true));
    await _estimate();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: d.date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date != null) {
      _set((x) => x.copyWith(date: date, clearEstimate: true));
      await _estimate();
    }
  }

  Future<void> _pickTime(bool from) async {
    final minutes = from ? d.fromMinutes : d.toMinutes;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
    if (t == null) return;
    final m = t.hour * 60 + t.minute;
    _set((x) => from ? x.copyWith(fromMinutes: m, toMinutes: m >= x.toMinutes ? m + 60 : x.toMinutes) : x.copyWith(toMinutes: m));
  }

  void _next() {
    final l = AppLocalizations.of(context);
    setState(() => _submitted = true);
    final valid = _form.currentState!.validate();
    String? missing;
    if (d.date == null) missing = l.pickupDate;
    if (d.toMinutes <= d.fromMinutes) missing = l.windowTo;
    if (d.pickup == null) missing = l.pickupSection;
    if (d.drop == null) missing = l.dropSection;
    if (d.goodsType == null) missing = l.goodsType;
    setState(() => _sectionError = missing == null ? null : '$missing: ${l.fieldRequired}');
    if (valid && missing == null) context.push(Routes.postLoadReview);
  }

  String _time(int minutes) {
    final h = minutes ~/ 60 % 24;
    final m = minutes % 60;
    return '${h == 0 ? 12 : (h > 12 ? h - 12 : h)}:${m.toString().padLeft(2, '0')} ${h < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final x = ref.watch(loadDraftProvider);
    final settings = ref.watch(publicSettingsProvider).value;
    String? req(String? v) => v == null || v.trim().isEmpty ? l.fieldRequired : null;
    String? positive(String? v) => (num.tryParse(v ?? '') ?? 0) > 0 ? null : l.fieldRequired;
    String? mobile(String? v) => Validators.mobile(v) ? null : l.mobileInvalid;

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        );
    Widget text(String key, String label, String value, void Function(String) onChanged,
            {String? Function(String?)? validator, TextInputType? type, int? maxLength, bool enabled = true}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            key: Key('pl-$key'),
            initialValue: value,
            enabled: enabled,
            keyboardType: type,
            maxLength: maxLength,
            inputFormatters: type == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(labelText: label, counterText: ''),
            onChanged: onChanged,
            validator: validator,
          ),
        );
    Widget placeTile(bool pickup) {
      final p = pickup ? x.pickup : x.drop;
      return Card(
        child: ListTile(
          key: Key(pickup ? 'pl-pickup' : 'pl-drop'),
          leading: Icon(pickup ? Icons.trip_origin : Icons.location_on),
          title: Text(p?.address ?? l.locationNotSet),
          subtitle: p?.landmark == null ? null : Text(p!.landmark!),
          trailing: TextButton(onPressed: () => _pickPlace(pickup), child: Text(l.setLocation)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(x.editingId == null ? l.postLoad : l.editLoad)),
      body: Form(
        key: _form,
        autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            section(l.pickupSection),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('pl-date'),
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(x.date == null ? l.pickupDate : Fmt.dateOnly(x.date!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _pickTime(true), child: Text('${l.windowFrom} ${_time(x.fromMinutes)}'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () => _pickTime(false), child: Text('${l.windowTo} ${_time(x.toMinutes)}'))),
              ],
            ),
            const SizedBox(height: 8),
            placeTile(true),
            const SizedBox(height: 8),
            if (x.postedForFarmerId != null)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(l.senderLockedFarmer)),
            text('senderName', l.senderName, x.senderName, (v) => _set((y) => y.copyWith(senderName: v)),
                validator: req, enabled: x.postedForFarmerId == null),
            text('senderMobile', l.senderMobile, x.senderMobile, (v) => _set((y) => y.copyWith(senderMobile: v)),
                validator: mobile, type: TextInputType.phone, maxLength: 10, enabled: x.postedForFarmerId == null),
            section(l.goodsSection),
            DropdownButtonFormField<String>(
              key: const Key('pl-goods'),
              initialValue: x.goodsType,
              decoration: InputDecoration(labelText: l.goodsType),
              items: [for (final g in settings?.goodsTypes ?? const <String>[]) DropdownMenuItem(value: g, child: Text(g))],
              onChanged: (v) => _set((y) => y.copyWith(goodsType: v)),
              validator: (v) => v == null ? l.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            text('description', l.descriptionOptional, x.description, (v) => _set((y) => y.copyWith(description: v))),
            Row(
              children: [
                Expanded(
                  child: text('quantity', l.quantity, x.quantity, (v) => _set((y) => y.copyWith(quantity: v)),
                      validator: positive, type: const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<QuantityUnit>(
                      initialValue: x.unit,
                      decoration: InputDecoration(labelText: l.unit),
                      items: [
                        for (final u in QuantityUnit.values.where((u) => u != QuantityUnit.unknown))
                          DropdownMenuItem(value: u, child: Text(unitLabel(l, u))),
                      ],
                      onChanged: (v) => _set((y) => y.copyWith(unit: v)),
                    ),
                  ),
                ),
              ],
            ),
            text('weight', l.weightTonnes, x.weight, (v) => _set((y) => y.copyWith(weight: v)),
                validator: positive, type: const TextInputType.numberWithOptions(decimal: true)),
            DropdownButtonFormField<VehicleType>(
              initialValue: x.vehicleType,
              decoration: InputDecoration(labelText: l.vehicleType),
              items: [
                for (final v in VehicleType.values.where((v) => v != VehicleType.unknown))
                  DropdownMenuItem(value: v, child: Text(vehicleLabel(l, v))),
              ],
              onChanged: (v) => _set((y) => y.copyWith(vehicleType: v)),
            ),
            section(l.dropSection),
            placeTile(false),
            section(l.receiverSection),
            text('receiverName', l.receiverName, x.receiverName, (v) => _set((y) => y.copyWith(receiverName: v)), validator: req),
            text('receiverMobile', l.receiverMobile, x.receiverMobile, (v) => _set((y) => y.copyWith(receiverMobile: v)),
                validator: mobile, type: TextInputType.phone, maxLength: 10),
            section(l.paymentSection),
            Text(l.freightPaidBy),
            SegmentedButton<FreightPayer>(
              segments: [
                ButtonSegment(value: FreightPayer.shipper, label: Text(l.paidByMe)),
                ButtonSegment(value: FreightPayer.receiver, label: Text(l.paidByReceiver)),
              ],
              selected: {x.payer},
              onSelectionChanged: (s) => _set((y) => y.copyWith(payer: s.first)),
            ),
            const SizedBox(height: 12),
            text('amount', l.amountInr, x.amount, (v) => _set((y) => y.copyWith(amount: v)),
                validator: positive, type: TextInputType.number),
            if (x.estimate?.suggestedAmountRange != null)
              Text(l.suggestedRange(Fmt.money(x.estimate!.suggestedAmountRange!['minInr'] as num),
                  Fmt.money(x.estimate!.suggestedAmountRange!['maxInr'] as num))),
            if (x.estimate != null) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(l.deliveryEstimate),
                  subtitle: Text(l.estimateLine(Fmt.km(x.estimate!.distanceKm),
                      (x.estimate!.driveMinutes / 60).toStringAsFixed(1), Fmt.dateTime(x.estimate!.deliveryEta))),
                ),
              ),
            ],
            section(l.offerTo),
            // A-409: wish-list options once the shipper has a wish list (LP-07).
            Builder(builder: (context) {
              final list = ref.watch(wishlistProvider).value ?? const <WishlistEntry>[];
              final options = [
                (LoadAudience.everyone, l.offerEveryone),
                if (list.isNotEmpty) (LoadAudience.wishlistFirst, l.offerWishlistFirst),
                if (list.isNotEmpty) (LoadAudience.wishlistOnly, l.offerWishlistOnly),
              ];
              final chosen = x.wishlistEntryIds?.toSet() ?? list.map((e) => e.id).toSet();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final (a, label) in options)
                  ListTile(
                    key: Key('offer-${a.name}'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(x.audience == a ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                    title: Text(label),
                    onTap: () => _set((y) => y.copyWith(audience: a)),
                  ),
                if (x.audience != LoadAudience.everyone && list.isNotEmpty) ...[
                  Text(l.chooseEntries, style: Theme.of(context).textTheme.labelLarge),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final e in list)
                      FilterChip(
                        label: Text(entryTitle(e)),
                        selected: chosen.contains(e.id),
                        onSelected: (on) {
                          final next = {...chosen};
                          on ? next.add(e.id) : next.remove(e.id);
                          _set((y) => next.length == list.length ? y.copyWith(clearEntries: true) : y.copyWith(wishlistEntryIds: next.toList()));
                        },
                      ),
                  ]),
                ],
                TextButton.icon(onPressed: () => context.push(Routes.wishlist), icon: const Icon(Icons.favorite_border), label: Text(l.manageWishlist)),
              ]);
            }),
            if (_sectionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_sectionError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.actionContinue, onPressed: _next),
          ],
        ),
      ),
    );
  }
}

/// LP-02 review → `POST /loads` (or `PUT` when editing).
class ReviewLoadScreen extends ConsumerStatefulWidget {
  const ReviewLoadScreen({super.key});

  @override
  ConsumerState<ReviewLoadScreen> createState() => _ReviewLoadScreenState();
}

class _ReviewLoadScreenState extends ConsumerState<ReviewLoadScreen> {
  bool _busy = false;
  AppException? _error;

  Future<void> _post() async {
    final l = AppLocalizations.of(context);
    final draft = ref.read(loadDraftProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(loadsApiProvider);
      final load = draft.editingId == null
          ? await api.create(draft.toCreate())
          : await api.update(draft.editingId!, draft.toCreate());
      ref.read(loadDraftProvider.notifier).reset();
      ref.invalidate(loadListProvider(true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.posted)));
      context.go(Routes.loadDetail(load.id));
    } on AppException catch (e) {
      setState(() => _error = e);
      if (!mounted) return;
      // Form data stays in loadDraftProvider while the user fixes the cause.
      if (e.code == ApiErrorCode.notVerified) {
        await showCompleteVerificationSheet(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final x = ref.watch(loadDraftProvider);
    final charge = ref.watch(publicSettingsProvider).value?.postingChargeInr ?? 0;
    Widget row(String label, String value) => ListTile(dense: true, title: Text(label), subtitle: Text(value));
    if (x.pickup == null || x.drop == null || x.windowStart == null) {
      return Scaffold(appBar: AppBar(title: Text(l.reviewTitle)), body: const EmptyState());
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          row(l.pickupSection, '${x.pickup!.address}\n${Fmt.dateTime(x.windowStart!)} – ${Fmt.dateTime(x.windowEnd!)}'),
          if (x.postedForFarmerId != null) row(l.navFarmers, l.postedFor(x.senderName)),
          row(l.sender, '${x.senderName} · +91 ${x.senderMobile}'),
          row(l.goodsSection, '${x.goodsType} · ${x.quantity} ${unitLabel(l, x.unit)} · ${x.weight} t · ${vehicleLabel(l, x.vehicleType)}'),
          row(l.dropSection, x.drop!.address),
          row(l.receiver, '${x.receiverName} · +91 ${x.receiverMobile}'),
          row(l.freightPaidBy, x.payer == FreightPayer.shipper ? l.paidByMe : l.paidByReceiver),
          ListTile(dense: true, title: Text(l.amountInr), subtitle: MoneyText(int.tryParse(x.amount) ?? 0, large: true)),
          if (x.estimate != null)
            row(l.deliveryEstimate, l.estimateLine(Fmt.km(x.estimate!.distanceKm),
                (x.estimate!.driveMinutes / 60).toStringAsFixed(1), Fmt.dateTime(x.estimate!.deliveryEta))),
          const Divider(),
          if (x.editingId == null) Text(l.postingChargeNote(Fmt.money(charge))),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(errorMessage(l, _error!), key: const Key('post-error'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_error!.code == ApiErrorCode.insufficientBalance)
              BlockingReasonCard(
                icon: Icons.account_balance_wallet_outlined,
                message: l.topUpToPost(Fmt.money(charge)),
                actionLabel: l.topUp,
                onAction: () => context.push(Routes.wallet),
              ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(label: x.editingId == null ? l.confirmPost : l.saveChanges, loading: _busy, onPressed: _post),
        ],
      ),
    );
  }
}

/// LP-04 Load detail (tracking map, revisions and payment come in M7/M8).
class LoadDetailScreen extends ConsumerWidget {
  const LoadDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(loadDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.code ?? l.loadDetails)),
      body: AsyncView(
        value: detail,
        onRetry: () => ref.invalidate(loadDetailProvider(id)),
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(loadDetailProvider(id)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [Expanded(child: Text(d.code, style: Theme.of(context).textTheme.titleLarge)), StatusChip.load(context, d.status)]),
              const SizedBox(height: 8),
              MoneyText(d.agreedAmountInr, large: true),
              if (d.driver != null) DriverBlock(driver: d.driver!),
              for (final r in d.revisions.where((r) => r.status == RevisionStatus.pending)) AmountRequestCard(load: d, revision: r),
              if (d.status == LoadStatus.locationReached) OtpCodeCard(loadId: d.id, title: l.pickupOtpTitle, hint: l.shareAfterLoading),
              if (d.driver != null && d.status != LoadStatus.delivered && d.status != LoadStatus.cancelled) TrackingCard(loadId: d.id),
              if (d.status == LoadStatus.notAccepted && d.audience != LoadAudience.everyone && d.audience != LoadAudience.unknown)
                WishlistBanner(load: d, onChanged: () => ref.invalidate(loadDetailProvider(d.id))),
              if (d.payment != null) PaymentCard(load: d),
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.trip_origin), title: Text(d.pickup.address),
                  subtitle: Text('${l.sender}: ${d.senderName} · +91 ${d.senderMobile}')),
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on), title: Text(d.drop.address),
                  subtitle: Text('${l.receiver}: ${d.receiverName} · +91 ${d.receiverMobile}')),
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.inventory_2_outlined),
                  title: Text('${d.goodsType} · ${d.quantity} ${unitLabel(l, d.quantityUnit)} · ${d.weightTonnes} t'),
                  subtitle: Text(vehicleLabel(l, d.vehicleType))),
              if (d.deliveryEta != null)
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule), title: Text(l.deliveryEstimate),
                    subtitle: Text(Fmt.dateTime(d.deliveryEta!))),
              const Divider(),
              Text(l.timeline, style: Theme.of(context).textTheme.titleMedium),
              for (final t in d.timeline)
                ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.circle, size: 10),
                    title: StatusChipText(status: t.status), trailing: Text(Fmt.dateTime(t.at))),
              const SizedBox(height: 16),
              if (d.canEdit)
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(loadDraftProvider.notifier).replace(LoadDraft.fromDetail(d));
                    context.push(Routes.postLoad);
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(l.editLoad),
                ),
              if (d.canCancel)
                OutlinedButton.icon(
                  onPressed: () => _cancel(context, ref, d),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l.cancelLoad),
                ),
              if (d.status == LoadStatus.cancelled || d.status == LoadStatus.delivered)
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final copy = await ref.read(loadsApiProvider).repost(d.id);
                      ref.invalidate(loadListProvider(true));
                      if (context.mounted) await context.push(Routes.loadDetail(copy.id));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
                      }
                    }
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(l.postAgain),
                ),
              if ((d.status == LoadStatus.cancelled || d.status == LoadStatus.delivered) && d.driver != null)
                OutlinedButton.icon(
                  onPressed: () => addTripTruckToWishlist(context, ref, d.driver!.truckNumber),
                  icon: const Icon(Icons.favorite_border),
                  label: Text(l.addToWishlist),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, LoadDetail d) async {
    final l = AppLocalizations.of(context);
    final info = d.cancelInfo ?? const {};
    final outcome = info['supportOnly'] == true
        ? l.cancelSupportOnly
        : (info['chargesKept'] == true ? l.cancelOutcomeKept('${info['trustScorePenalty']}') : l.cancelOutcomeFree);
    const reasons = ['PLANS_CHANGED', 'GOODS_NOT_READY', 'FOUND_OTHER_TRUCK', 'DRIVER_NOT_REACHABLE', 'DRIVER_DID_NOT_COME',
        'DRIVER_ASKED_MORE', 'OTHER'];
    String? reason;
    final note = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(c).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.cancelLoad, style: Theme.of(c).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(outcome),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in reasons)
                      ChoiceChip(label: Text(cancelReasonLabel(l, r)), selected: reason == r, onSelected: (_) => setState(() => reason = r)),
                  ],
                ),
                if (reason == 'OTHER') TextField(controller: note, decoration: InputDecoration(labelText: l.noteLabel)),
                const SizedBox(height: 16),
                PrimaryButton(label: l.cancelLoad, onPressed: reason == null ? null : () => Navigator.pop(c, true)),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true || reason == null) return;
    try {
      await ref.read(loadsApiProvider).cancel(d.id, reason!, note.text.trim().isEmpty ? null : note.text.trim());
      ref.invalidate(loadDetailProvider(d.id));
      ref.invalidate(loadListProvider(true));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    } finally {
      note.dispose();
    }
  }
}

/// Status name text (chip without the box) for timelines.
class StatusChipText extends StatelessWidget {
  const StatusChipText({super.key, required this.status});

  final LoadStatus status;

  @override
  Widget build(BuildContext context) {
    final chip = StatusChip.load(context, status);
    return Text(chip.label);
  }
}


/// Driver shown to the shipper after acceptance (LP-04): photo, name, truck, Trust Score, call.
class DriverBlock extends StatelessWidget {
  const DriverBlock({super.key, required this.driver});

  final LoadDriver driver;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: driver.photoUrl == null ? null : NetworkImage(driver.photoUrl!),
          child: driver.photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(driver.name),
        subtitle: Text('${driver.truckNumber} · ${vehicleLabel(l, driver.vehicleType)}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          TrustScoreBadge(score: driver.trustScore),
          IconButton(
            tooltip: l.callAction,
            icon: const Icon(Icons.call),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: driver.mobile)),
          ),
        ]),
      ),
    );
  }
}

/// LP-04 amount request: amount, reason, "x of 5", answer-by time → Confirm / Reject.
class AmountRequestCard extends ConsumerWidget {
  const AmountRequestCard({super.key, required this.load, required this.revision});

  final LoadDetail load;
  final AmountRevision revision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final limit = ref.watch(publicSettingsProvider).value?.revisionLimit ?? 5;
    Future<void> answer(bool confirm) async {
      try {
        await ref.read(loadsApiProvider).answerRevision(load.id, revision.id, confirm);
        ref.invalidate(loadDetailProvider(load.id));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
      }
    }

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(l.amountRequestTitle, style: Theme.of(context).textTheme.titleMedium)),
            Text(l.amountUsed(load.revisionsUsed, limit)),
          ]),
          const SizedBox(height: 8),
          Text(l.amountRequestBody(Fmt.money(revision.requestedAmountInr), revision.reason), style: Theme.of(context).textTheme.bodyLarge),
          Text(l.answerBy(Fmt.dateTime(revision.respondBy))),
          Text(l.rejectKeepsAmount, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => answer(false), child: Text(l.reject))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: () => answer(true), child: Text(l.actionConfirm))),
          ]),
        ]),
      ),
    );
  }
}

/// Pickup OTP for the sender / delivery OTP for the receiver (`GET /loads/{id}/otp`).
class OtpCodeCard extends ConsumerWidget {
  const OtpCodeCard({super.key, required this.loadId, required this.title, required this.hint});

  final String loadId;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otp = ref.watch(loadOtpProvider(loadId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncView(
          value: otp,
          onRetry: () => ref.invalidate(loadOtpProvider(loadId)),
          data: (o) => Column(children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(o.code, key: const Key('otp-code'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 8)),
            Text(hint, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

/// Live tracking (poll 30 s while visible, D-18): last truck position, ETA, route status.
class TrackingCard extends ConsumerStatefulWidget {
  const TrackingCard({super.key, required this.loadId});

  final String loadId;

  @override
  ConsumerState<TrackingCard> createState() => _TrackingCardState();
}

class _TrackingCardState extends ConsumerState<TrackingCard> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ref.invalidate(trackingProvider(widget.loadId));
      ref.invalidate(loadDetailProvider(widget.loadId));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = ref.watch(trackingProvider(widget.loadId)).value;
    if (t == null) return const SizedBox.shrink();
    final c = context.statusColors;
    final (label, color) = switch (t.routeStatus) {
      RouteStatus.slow => (l.routeSlow, c.warning),
      RouteStatus.fast => (l.routeFast, c.info),
      RouteStatus.normal => (l.routeNormal, c.success),
      _ => (null, c.neutral),
    };
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_shipping),
        title: Text(l.liveTracking),
        subtitle: Text([
          if (t.driverLocation != null) l.lastSeen(Fmt.dateTime(t.driverLocation!.at)),
          if (t.etaAt != null) l.etaAt(Fmt.dateTime(t.etaAt!)),
        ].join('\n')),
        trailing: label == null ? null : StatusChip(label: label, color: color),
        onTap: t.driverLocation == null
            ? null
            : () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${t.driverLocation!.lat},${t.driverLocation!.lng}'),
                mode: LaunchMode.externalApplication),
      ),
    );
  }
}
