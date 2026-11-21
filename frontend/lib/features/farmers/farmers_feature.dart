import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../notifications/notifications_feature.dart';
import '../shared_shell/tab_screens.dart';
import '../shipper/application/post_load_draft.dart';

/// Contract §7 `Farmer`.
class Farmer {
  Farmer({required this.id, required this.name, required this.mobile, this.aadhaarLast4, this.landAcres, required this.village, this.active = true});

  factory Farmer.fromJson(Map<String, dynamic> j) => Farmer(
        id: j['id'] as String,
        name: j['name'] as String,
        mobile: j['mobile'] as String,
        aadhaarLast4: j['aadhaarLast4'] as String?,
        landAcres: (j['landAcres'] as num?)?.toDouble(),
        village: j['village'] as String,
        active: j['active'] as bool? ?? true,
      );

  final String id;
  final String name;
  final String mobile;
  final String? aadhaarLast4;
  final double? landAcres;
  final String village;
  final bool active;
}

class FarmersApi {
  FarmersApi(this._dio);

  final Dio _dio;

  Future<Paged<Farmer>> list({String? q, int page = 0}) async => Paged.fromJson(
        (await guardApi(() => _dio.get<Map<String, dynamic>>('/farmers', queryParameters: {'q': ?q, 'page': page, 'size': 100}))).data!,
        Farmer.fromJson,
      );

  Future<Farmer> save(String? id, Map<String, dynamic> body) async => Farmer.fromJson((await guardApi(() => id == null
          ? _dio.post<Map<String, dynamic>>('/farmers', data: body)
          : _dio.put<Map<String, dynamic>>('/farmers/$id', data: body)))
      .data!);

  Future<void> deactivate(String id) => guardApi(() => _dio.post<void>('/farmers/$id/deactivate'));
}

final farmersApiProvider = Provider<FarmersApi>((ref) => FarmersApi(ref.watch(dioProvider)));
final farmersProvider = FutureProvider.autoDispose.family<Paged<Farmer>, String>(
    (ref, q) => ref.watch(farmersApiProvider).list(q: q.isEmpty ? null : q));

/// FN-02 farmers list: search, add, edit, deactivate.
class FarmersScreen extends ConsumerStatefulWidget {
  const FarmersScreen({super.key});

  @override
  ConsumerState<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends ConsumerState<FarmersScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.navFarmers), actions: const [NotificationBell(), ProfileAvatarButton()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFarmerForm(context, ref, null),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l.addFarmer),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            key: const Key('farmer-search'),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: l.searchFarmers),
            onSubmitted: (v) => setState(() => _q = v.trim()),
          ),
        ),
        Expanded(
          child: AsyncView(
            value: ref.watch(farmersProvider(_q)),
            onRetry: () => ref.invalidate(farmersProvider(_q)),
            data: (page) => page.items.isEmpty
                ? EmptyState(icon: Icons.agriculture_outlined, message: l.noFarmers)
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(farmersProvider(_q)),
                    child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 88), children: [
                      for (final f in page.items)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.agriculture_outlined),
                            title: Text(f.name),
                            subtitle: Text([f.village, '+91 ${f.mobile}', if (f.landAcres != null) '${f.landAcres} ac'].join(' · ')),
                            onTap: () => showFarmerForm(context, ref, f),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'post') return startPostForFarmer(context, ref, f);
                                try {
                                  await ref.read(farmersApiProvider).deactivate(f.id);
                                  ref.invalidate(farmersProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(value: 'post', child: Text(l.postForFarmer)),
                                PopupMenuItem(value: 'deactivate', child: Text(l.deactivate)),
                              ],
                            ),
                          ),
                        ),
                    ]),
                  ),
          ),
        ),
      ]),
    );
  }
}

/// FN-03: a new draft whose sender is the farmer (locked), then the normal post-a-load flow.
void startPostForFarmer(BuildContext context, WidgetRef ref, Farmer f) {
  ref.read(loadDraftProvider.notifier).replace(LoadDraft(senderName: f.name, senderMobile: f.mobile, postedForFarmerId: f.id));
  context.push(Routes.postLoad);
}

/// Picker used from the Farmer Network home: choose a farmer, then post for them.
Future<void> pickFarmerAndPost(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final farmer = await showModalBottomSheet<Farmer>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) => Consumer(
      builder: (c, ref, _) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(c).size.height * 0.6,
          child: Column(children: [
            Text(l.chooseFarmer, style: Theme.of(c).textTheme.titleLarge),
            Expanded(
              child: AsyncView(
                value: ref.watch(farmersProvider('')),
                onRetry: () => ref.invalidate(farmersProvider('')),
                data: (page) => page.items.isEmpty
                    ? EmptyState(icon: Icons.agriculture_outlined, message: l.noFarmers)
                    : ListView(children: [
                        for (final f in page.items)
                          ListTile(title: Text(f.name), subtitle: Text(f.village), onTap: () => Navigator.pop(c, f)),
                      ]),
              ),
            ),
          ]),
        ),
      ),
    ),
  );
  if (farmer != null && context.mounted) startPostForFarmer(context, ref, farmer);
}

/// FN-02 add/edit form (consent required for new farmers; Aadhaar last 4 only — hard rule 3).
Future<void> showFarmerForm(BuildContext context, WidgetRef ref, Farmer? farmer) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FarmerForm(farmer: farmer),
  );
}

class _FarmerForm extends ConsumerStatefulWidget {
  const _FarmerForm({this.farmer});

  final Farmer? farmer;

  @override
  ConsumerState<_FarmerForm> createState() => _FarmerFormState();
}

class _FarmerFormState extends ConsumerState<_FarmerForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.farmer?.name);
  late final _mobile = TextEditingController(text: widget.farmer?.mobile);
  late final _aadhaar = TextEditingController(text: widget.farmer?.aadhaarLast4);
  late final _land = TextEditingController(text: widget.farmer?.landAcres?.toString());
  late final _village = TextEditingController(text: widget.farmer?.village);
  late bool _consent = widget.farmer != null;
  bool _busy = false;
  AppException? _error;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _aadhaar, _land, _village]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || !_consent) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(farmersApiProvider).save(widget.farmer?.id, {
        'name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'aadhaarLast4': _aadhaar.text.trim().isEmpty ? null : _aadhaar.text.trim(),
        'landAcres': num.tryParse(_land.text.trim()),
        'village': _village.text.trim(),
        'consent': _consent,
      });
      ref.invalidate(farmersProvider);
      if (mounted) Navigator.pop(context);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String? fe(String f) => _error?.fieldError(f);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(widget.farmer == null ? l.addFarmer : l.editFarmer, style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                key: const Key('f-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.nameLabel, errorText: fe('name')),
                validator: (v) => Validators.name(v) ? null : l.nameInvalid,
              ),
              TextFormField(
                key: const Key('f-mobile'),
                controller: _mobile,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.mobileLabel, prefixText: '+91 ', counterText: '', errorText: fe('mobile')),
                validator: (v) => Validators.mobile(v) ? null : l.mobileInvalid,
              ),
              TextFormField(
                key: const Key('f-village'),
                controller: _village,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.village, errorText: fe('village')),
                validator: (v) => v == null || v.trim().isEmpty ? l.fieldRequired : null,
              ),
              TextFormField(
                key: const Key('f-aadhaar'),
                controller: _aadhaar,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.aadhaarLast4Optional, counterText: '', errorText: fe('aadhaarLast4')),
                validator: (v) => v == null || v.isEmpty || RegExp(r'^[0-9]{4}$').hasMatch(v) ? null : l.aadhaarLast4Invalid,
              ),
              TextFormField(
                key: const Key('f-land'),
                controller: _land,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.landAcresOptional, errorText: fe('landAcres')),
              ),
              if (widget.farmer == null)
                CheckboxListTile(
                  key: const Key('f-consent'),
                  contentPadding: EdgeInsets.zero,
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                  title: Text(l.farmerConsent),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              if (_error != null && _error!.fields.isEmpty)
                Text(errorMessage(l, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              PrimaryButton(label: l.save, loading: _busy, onPressed: _consent ? _save : null),
            ]),
          ),
        ),
      ),
    );
  }
}
