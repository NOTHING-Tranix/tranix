import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/error_messages.dart';
import '../../core/files/file_picking.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../organization/org_feature.dart';
import '../payments/payments_feature.dart';
import '../receiver/receiver_feature.dart';
import '../shipper/data/loads_api.dart';

/// Contract §11 ticket (list row / detail).
class Ticket {
  Ticket(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get code => json['code'] as String? ?? '';
  String get type => json['type'] as String? ?? 'OTHERS';
  String get status => json['status'] as String? ?? 'OPEN';
  bool get unread => json['unread'] as bool? ?? false;
  bool get canReopen => json['canReopen'] as bool? ?? false;
  String? get loadCode => json['loadCode'] as String?;
  String? get closeReason => json['closeReason'] as String?;
  String get description => json['description'] as String? ?? '';
  DateTime get updatedAt => DateTime.parse(json['updatedAt'] as String);
  List<Map<String, dynamic>> get messages => [for (final m in (json['messages'] as List<dynamic>? ?? const [])) m as Map<String, dynamic>];
}

class SupportApi {
  SupportApi(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<List<Ticket>> list() async =>
      [for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/tickets'))).data!) Ticket(e as Map<String, dynamic>)];

  Future<Ticket> get(String id) async => Ticket((await guardApi(() => _dio.get<Map<String, dynamic>>('/tickets/$id'))).data!);

  Future<Ticket> create(Map<String, dynamic> body) async =>
      Ticket((await guardApi(() => _dio.post<Map<String, dynamic>>('/tickets', data: body))).data!);

  Future<Ticket> message(String id, String body, List<String> fileIds) async => Ticket(
      (await guardApi(() => _dio.post<Map<String, dynamic>>('/tickets/$id/messages', data: {'body': body, 'fileIds': fileIds}))).data!);

  Future<Ticket> reopen(String id) async => Ticket((await guardApi(() => _dio.post<Map<String, dynamic>>('/tickets/$id/reopen'))).data!);
}

final supportApiProvider = Provider<SupportApi>((ref) => SupportApi(ref.watch(dioProvider)));
final ticketsProvider = FutureProvider.autoDispose<List<Ticket>>((ref) => ref.watch(supportApiProvider).list());
final ticketProvider = FutureProvider.autoDispose.family<Ticket, String>((ref, id) => ref.watch(supportApiProvider).get(id));

/// The user's recent trips for the ticket form, per role: (loadId, code).
final recentTripsProvider = FutureProvider.autoDispose<List<(String, String)>>((ref) async {
  final session = ref.watch(sessionProvider);
  final role = session is SignedIn ? session.me.role : Role.unknown;
  switch (role) {
    case Role.loadProvider || Role.farmerNetwork:
      final api = ref.watch(loadsApiProvider);
      return [for (final ongoing in [true, false]) for (final s in (await api.list(ongoing: ongoing)).items) (s.id, s.code)];
    case Role.driver:
      return [for (final s in (await ref.watch(paymentsApiProvider).driverHistory(monthKey(DateTime.now()))).items) (s.id, s.code)];
    case Role.receiver:
      final api = ref.watch(receiverApiProvider);
      return [for (final ongoing in [true, false]) for (final m in await api.loads(ongoing: ongoing)) ('${m['id']}', '${m['code']}')];
    case Role.organization:
      return [for (final s in await ref.watch(orgApiProvider).trips()) (s.id, s.code)];
    default:
      return const [];
  }
});

String ticketTypeLabel(AppLocalizations l, String t) => switch (t) {
      'COMPLAINT' => l.ticketComplaint,
      'FEEDBACK' => l.ticketFeedback,
      'WALLET' => l.ticketWallet,
      'PAYMENT_DISPUTE' => l.ticketPaymentDispute,
      _ => l.ticketOthers,
    };

/// S-10 support: ticket history with unread dot.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.support)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NewTicketScreen())),
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(l.newTicket),
      ),
      body: AsyncView(
        value: ref.watch(ticketsProvider),
        onRetry: () => ref.invalidate(ticketsProvider),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.support_agent, message: l.noTickets)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(ticketsProvider),
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), children: [
                  for (final t in list)
                    Card(
                      child: ListTile(
                        leading: Badge(isLabelVisible: t.unread, child: const Icon(Icons.support_agent)),
                        title: Text('${t.code} · ${ticketTypeLabel(l, t.type)}'),
                        subtitle: Text([if (t.loadCode != null) t.loadCode!, t.description].join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text(t.status == 'OPEN' ? l.ticketOpen : l.ticketClosed),
                        onTap: () => context.push(Routes.ticket(t.id)),
                      ),
                    ),
                ]),
              ),
      ),
    );
  }
}

/// Help form: type (+ other text), trip, description, up to 3 photos.
class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key, this.loadId});

  final String? loadId;

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _form = GlobalKey<FormState>();
  String _type = 'COMPLAINT';
  late String? _loadId = widget.loadId;
  final _other = TextEditingController();
  final _description = TextEditingController();
  final _photos = <PickedUpload>[];
  bool _busy = false;
  String? _error;

  bool get _tripRequired => _type == 'COMPLAINT' || _type == 'PAYMENT_DISPUTE';

  @override
  void dispose() {
    _other.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final api = ref.read(supportApiProvider);
      final ids = <String>[for (final p in _photos) await uploadFile(api.dio, p)];
      final t = await api.create({
        'type': _type,
        if (_type == 'OTHERS') 'otherText': _other.text.trim(),
        'loadId': ?_loadId,
        'description': _description.text.trim(),
        'fileIds': ids,
      });
      ref.invalidate(ticketsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.ticketCreated)));
      Navigator.of(context).pop();
      await context.push(Routes.ticket(t.id));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trips = ref.watch(recentTripsProvider).value ?? const <(String, String)>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.newTicket)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<String>(
            key: const Key('t-type'),
            initialValue: _type,
            decoration: InputDecoration(labelText: l.ticketType),
            items: [
              for (final t in const ['COMPLAINT', 'FEEDBACK', 'WALLET', 'PAYMENT_DISPUTE', 'OTHERS'])
                DropdownMenuItem(value: t, child: Text(ticketTypeLabel(l, t))),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          if (_type == 'OTHERS')
            TextFormField(
              key: const Key('t-other'),
              controller: _other,
              maxLength: 60,
              decoration: InputDecoration(labelText: l.otherTopic),
              validator: (v) => v == null || v.trim().isEmpty ? l.fieldRequired : null,
            ),
          DropdownButtonFormField<String?>(
            key: ValueKey('t-trip-${trips.length}'),
            initialValue: _loadId,
            decoration: InputDecoration(labelText: _tripRequired ? l.tripRequired : l.tripOptional),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('—')),
              for (final (id, code) in trips) DropdownMenuItem<String?>(value: id, child: Text(code)),
            ],
            onChanged: (v) => setState(() => _loadId = v),
            validator: (v) => _tripRequired && v == null ? l.fieldRequired : null,
          ),
          TextFormField(
            key: const Key('t-description'),
            controller: _description,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(labelText: l.descriptionLabel),
            validator: (v) => v == null || v.trim().isEmpty ? l.fieldRequired : null,
          ),
          Text(l.photosUpTo3),
          Wrap(spacing: 8, children: [
            for (var i = 0; i < _photos.length; i++) InputChip(label: Text(_photos[i].name), onDeleted: () => setState(() => _photos.removeAt(i))),
            if (_photos.length < 3)
              ActionChip(
                avatar: const Icon(Icons.add_a_photo_outlined),
                label: Text(l.addPhoto),
                onPressed: () async {
                  final f = await const FilePicking().pick(PickSource.gallery);
                  if (f != null && mounted) setState(() => _photos.add(f));
                },
              ),
          ]),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 16),
          PrimaryButton(label: l.sendAction, loading: _busy, onPressed: _submit),
        ]),
      ),
    );
  }
}

/// Conversation with Tranix; write while open; reopen within the window.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ticketProvider(widget.id));
      ref.invalidate(ticketsProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(ticketProvider(widget.id));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(value.value?.code ?? l.support)),
      body: AsyncView(
        value: value,
        onRetry: () => ref.invalidate(ticketProvider(widget.id)),
        data: (t) => Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text('${ticketTypeLabel(l, t.type)}${t.loadCode == null ? '' : ' · ${t.loadCode}'}', style: Theme.of(context).textTheme.titleMedium),
              Text(t.description),
              if (t.status == 'CLOSED' && t.closeReason != null)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.closedReason(t.closeReason!), style: TextStyle(color: context.statusColors.neutral))),
              const Divider(),
              for (final m in t.messages)
                Align(
                  alignment: m['author'] == 'USER' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: m['author'] == 'USER' ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m['author'] == 'USER' ? l.youLabel : l.tranixSupport, style: Theme.of(context).textTheme.labelSmall),
                        Text('${m['body']}'),
                        Text(Fmt.dateTime(DateTime.parse('${m['at']}')), style: Theme.of(context).textTheme.labelSmall),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: t.status == 'OPEN'
                  ? Row(children: [
                      Expanded(
                        child: TextField(key: const Key('t-message'), controller: _text, maxLength: 1000,
                            decoration: InputDecoration(labelText: l.writeMessage, counterText: '')),
                      ),
                      IconButton(
                        tooltip: l.sendAction,
                        icon: const Icon(Icons.send),
                        onPressed: _busy
                            ? null
                            : () {
                                final body = _text.text.trim();
                                if (body.isEmpty) return;
                                _run(() async {
                                  await ref.read(supportApiProvider).message(widget.id, body, const []);
                                  _text.clear();
                                });
                              },
                      ),
                    ])
                  : t.canReopen
                      ? PrimaryButton(label: l.reopenAction, loading: _busy, onPressed: () => _run(() => ref.read(supportApiProvider).reopen(widget.id)))
                      : const SizedBox.shrink(),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- A-1101 legal + account deletion (contract §14)

final legalProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, doc) async =>
    (await guardApi(() => ref.watch(dioProvider).get<Map<String, dynamic>>('/legal/$doc'))).data!);

/// Privacy policy / terms (server text; marked as draft until the legal review, Q-08).
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.doc});

  final String doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(doc == 'privacy' ? l.privacyPolicy : l.termsOfUse)),
      body: AsyncView(
        value: ref.watch(legalProvider(doc)),
        onRetry: () => ref.invalidate(legalProvider(doc)),
        data: (d) => ListView(padding: const EdgeInsets.all(16), children: [
          if ('${d['status']}'.startsWith('DRAFT'))
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l.draftNotice, style: TextStyle(color: context.statusColors.warning))),
          Text('${d['text']}'),
        ]),
      ),
    );
  }
}

/// "Delete account": confirmation with an optional reason → `POST /me/deletion-request` (opens a support ticket).
Future<void> requestAccountDeletion(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  var reason = '';
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.deleteAccount),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l.deleteAccountBody),
        TextField(key: const Key('delete-reason'), maxLength: 500, decoration: InputDecoration(labelText: l.deleteReason), onChanged: (v) => reason = v),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.deleteAccount)),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final res = await guardApi(() => ref.read(dioProvider).post<Map<String, dynamic>>('/me/deletion-request',
        data: {if (reason.trim().isNotEmpty) 'reason': reason.trim()}));
    ref.invalidate(ticketsProvider);
    messenger.showSnackBar(SnackBar(content: Text(l.deleteRequested)));
    if (context.mounted) await context.push(Routes.ticket(res.data!['id'] as String));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
  }
}
