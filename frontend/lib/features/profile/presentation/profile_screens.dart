import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/files/file_picking.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/settings_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/models/models.dart';
import '../../auth/presentation/auth_screens.dart' show MobileField;
import '../../shared_shell/tab_screens.dart' show roleLabel;
import '../application/profile_providers.dart';
import '../data/profile_api.dart';
import '../../../core/theme/app_theme.dart';
import 'labels.dart';

void _toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

String _err(BuildContext context, Object e) => errorMessage(AppLocalizations.of(context), e);

/// S-05 Profile.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(meProvider);
    final verification = ref.watch(verificationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.navProfile)),
      body: RefreshIndicator(
        onRefresh: () async => refreshProfile(ref),
        child: AsyncView(
          value: me,
          onRetry: () => refreshProfile(ref),
          data: (m) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CompletionRing(percent: m.profileCompletion),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: Theme.of(context).textTheme.titleLarge),
                        Text('${roleLabel(l, m.role)} · +91 ${m.mobile}'),
                        const SizedBox(height: 6),
                        Wrap(spacing: 8, children: [verificationChip(context, m.verificationStatus), TrustScoreBadge(score: m.trustScore)]),
                      ],
                    ),
                  ),
                  _PhotoAvatar(url: m.photoUrl),
                ],
              ),
              const SizedBox(height: 16),
              _tile(context, Icons.person_outline, l.basicDetails, () => context.push(Routes.profileEdit)),
              _tile(context, Icons.badge_outlined, l.roleDetails, () => context.push(Routes.profileRole)),
              _tile(context, Icons.description_outlined, l.documents, () => context.push(Routes.verification)),
              _tile(context, Icons.verified_outlined, l.verificationTitle, () => context.push(Routes.verification),
                  trailing: verificationChip(context, m.verificationStatus)),
              if (m.role == Role.driver) ...[
                _tile(context, Icons.local_shipping_outlined, l.myTruck, () => context.push(Routes.driverTruckForm)),
                _tile(context, Icons.folder_shared_outlined, l.locker, () => context.push(Routes.driverLocker)),
              ],
              _tile(context, Icons.account_balance_wallet_outlined, l.wallet, () => context.push(Routes.wallet)),
              _tile(context, Icons.notifications_none, l.navNotifications, () => context.push(Routes.notifications)),
              _tile(context, Icons.phone_android, l.changeMobile, () => context.push(Routes.profileMobile)),
              _tile(context, Icons.translate, l.language, () => _pickLanguage(context, ref)),
              _tile(context, Icons.logout, l.actionSignOut, () => ref.read(sessionProvider.notifier).signOut()),
              const SizedBox(height: 16),
              if (verification.value != null) _SubmitBox(me: m, info: verification.value!),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  static Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    const names = {Language.en: 'English', Language.ta: 'தமிழ்', Language.hi: 'हिन्दी'};
    final chosen = await showModalBottomSheet<Language>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (final e in names.entries) ListTile(title: Text(e.value), onTap: () => Navigator.pop(c, e.key))],
        ),
      ),
    );
    if (chosen == null) return;
    await ref.read(languageProvider.notifier).set(chosen);
    final session = ref.read(sessionProvider);
    if (session is SignedIn) {
      try {
        await ref.read(profileApiProvider).updateMe(name: session.me.name, language: chosen);
        refreshProfile(ref);
      } catch (_) {
        // Local choice still applies; the server copy is updated next time the profile is saved.
      }
    }
  }
}

class _PhotoAvatar extends ConsumerWidget {
  const _PhotoAvatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.addPhoto,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.push('${Routes.profileDocument}?type=PHOTO'),
        child: CircleAvatar(
          radius: 32,
          backgroundImage: url == null ? null : NetworkImage(url!),
          child: url == null ? const Icon(Icons.add_a_photo_outlined) : null,
        ),
      ),
    );
  }
}

class _SubmitBox extends ConsumerStatefulWidget {
  const _SubmitBox({required this.me, required this.info});

  final Me me;
  final VerificationInfo info;

  @override
  ConsumerState<_SubmitBox> createState() => _SubmitBoxState();
}

class _SubmitBoxState extends ConsumerState<_SubmitBox> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = widget.info.status;
    final canSubmit = widget.me.profileCompletion >= 100 &&
        (status == VerificationStatus.notSubmitted || status == VerificationStatus.notVerified);
    if (!canSubmit) return const SizedBox.shrink();
    return PrimaryButton(
      label: l.submitForVerification,
      loading: _busy,
      onPressed: () async {
        setState(() => _busy = true);
        try {
          await ref.read(profileApiProvider).submit();
          refreshProfile(ref);
          if (context.mounted) unawaited(context.push(Routes.verification));
        } catch (e) {
          if (context.mounted) _toast(context, _err(context, e));
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      },
    );
  }
}

/// Name, email, language and address (`PUT /me`).
class EditBasicsScreen extends ConsumerStatefulWidget {
  const EditBasicsScreen({super.key});

  @override
  ConsumerState<EditBasicsScreen> createState() => _EditBasicsScreenState();
}

class _EditBasicsScreenState extends ConsumerState<EditBasicsScreen> {
  final _form = GlobalKey<FormState>();
  final _c = {for (final k in ['name', 'email', 'line', 'village', 'district', 'state', 'pin']) k: TextEditingController()};
  bool _loaded = false;
  bool _busy = false;
  AppException? _error;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final api = ref.read(profileApiProvider);
    final me = await api.me();
    final a = await api.address();
    _c['name']!.text = me.name;
    if (a != null) {
      _c['line']!.text = a.line;
      _c['village']!.text = a.village;
      _c['district']!.text = a.district;
      _c['state']!.text = a.state;
      _c['pin']!.text = a.pin;
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void initState() {
    super.initState();
    _load().catchError((Object e) {
      if (mounted) setState(() => _error = e is AppException ? e : null);
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(profileApiProvider).updateMe(
            name: _c['name']!.text.trim(),
            email: _c['email']!.text.trim(),
            language: ref.read(languageProvider),
            address: Address(
              line: _c['line']!.text.trim(),
              village: _c['village']!.text.trim(),
              district: _c['district']!.text.trim(),
              state: _c['state']!.text.trim(),
              pin: _c['pin']!.text.trim(),
            ),
          );
      refreshProfile(ref);
      if (mounted) {
        _toast(context, AppLocalizations.of(context).saved);
        context.pop();
      }
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String? req(String? v) => v == null || v.trim().isEmpty ? l.fieldRequired : null;
    Widget field(String key, String label, {String? Function(String?)? validator, TextInputType? type, int? max}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          key: Key('f-$key'),
          controller: _c[key],
          keyboardType: type,
          maxLength: max,
          decoration: InputDecoration(labelText: label, counterText: '', errorText: _error?.fieldError(key == 'name' || key == 'email' ? key : 'address.$key')),
          validator: validator,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.basicDetails)),
      body: !_loaded && _error == null
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  field('name', l.nameLabel, validator: (v) => Validators.name(v) ? null : l.nameInvalid),
                  field('email', l.emailLabel, type: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty || v.contains('@') ? null : l.emailInvalid),
                  Text(l.address, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  field('line', l.addressLine, validator: req),
                  field('village', l.village, validator: req),
                  field('district', l.district, validator: req),
                  field('state', l.state, validator: req),
                  field('pin', l.pinCode, type: TextInputType.number, max: 6,
                      validator: (v) => Validators.pin(v) ? null : l.pinInvalid),
                  if (_error != null && _error!.fields.isEmpty)
                    Text(_err(context, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                  PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
                ],
              ),
            ),
    );
  }
}

/// Role-specific fields (`PUT /me/role-profile`, contract §4.1).
class RoleProfileScreen extends ConsumerStatefulWidget {
  const RoleProfileScreen({super.key});

  @override
  ConsumerState<RoleProfileScreen> createState() => _RoleProfileScreenState();
}

class _RoleProfileScreenState extends ConsumerState<RoleProfileScreen> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _c = {};
  final Map<String, String?> _choice = {};
  DateTime? _date;
  bool _loaded = false;
  bool _busy = false;
  AppException? _error;

  TextEditingController c(String k) => _c.putIfAbsent(k, TextEditingController.new);

  @override
  void initState() {
    super.initState();
    ref.read(profileApiProvider).roleProfile().then((data) {
      data.forEach((k, v) {
        if (v is String && !{'accountType', 'idType', 'licenceValidUntil'}.contains(k)) c(k).text = v;
        if (v is List) c(k).text = v.join(', ');
      });
      _choice['accountType'] = data['accountType'] as String?;
      _choice['idType'] = data['idType'] as String?;
      final d = data['licenceValidUntil'];
      if (d is String) _date = DateTime.tryParse(d);
      if (mounted) setState(() => _loaded = true);
    }).catchError((Object _) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    for (final x in _c.values) {
      x.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _body(Role role) {
    String? t(String k) => _c[k]?.text.trim().isEmpty ?? true ? null : _c[k]!.text.trim();
    return switch (role) {
      Role.loadProvider => {'accountType': _choice['accountType'], 'businessName': t('businessName'), 'gstin': t('gstin')},
      Role.farmerNetwork => {
          'networkName': t('networkName'),
          'registrationNumber': t('registrationNumber'),
          'idType': _choice['idType'],
          'idNumber': t('idNumber'),
          'contactPerson': t('contactPerson'),
          'state': t('state'),
          'district': t('district'),
        },
      Role.driver => {
          'licenceNumber': t('licenceNumber'),
          'licenceValidUntil': _date?.toIso8601String().substring(0, 10),
          'vehicleClasses': (t('vehicleClasses') ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
          'emergencyContact': t('emergencyContact'),
        },
      Role.organization => {'orgName': t('orgName'), 'contactPerson': t('contactPerson'), 'gstin': t('gstin'), 'pan': t('pan')},
      _ => {'businessName': t('businessName')},
    }..removeWhere((_, v) => v == null);
  }

  Future<void> _save(Role role) async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(profileApiProvider).saveRoleProfile(_body(role));
      refreshProfile(ref);
      if (mounted) {
        _toast(context, AppLocalizations.of(context).saved);
        context.pop();
      }
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final role = session is SignedIn ? session.me.role : Role.unknown;
    String? req(String? v) => v == null || v.trim().isEmpty ? l.fieldRequired : null;

    Widget text(String key, String label, {bool required = false, bool caps = false, TextInputType? type}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            key: Key('rp-$key'),
            controller: c(key),
            keyboardType: type,
            textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.words,
            inputFormatters: type == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(labelText: label, errorText: _error?.fieldError(key)),
            validator: required ? req : null,
          ),
        );

    Widget choice(String key, String label, Map<String, String> options) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            key: Key('rp-$key'),
            initialValue: _choice[key],
            decoration: InputDecoration(labelText: label, errorText: _error?.fieldError(key)),
            items: [for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => _choice[key] = v),
            validator: (v) => v == null ? l.fieldRequired : null,
          ),
        );

    final fields = switch (role) {
      Role.loadProvider => [
          choice('accountType', l.accountType, {'INDIVIDUAL': l.individual, 'BUSINESS': l.business}),
          text('businessName', _choice['accountType'] == 'BUSINESS' ? l.businessName : l.businessNameOptional),
          text('gstin', l.gstinOptional, caps: true),
        ],
      Role.farmerNetwork => [
          text('networkName', l.networkName, required: true),
          text('registrationNumber', l.registrationNumber, required: true, caps: true),
          choice('idType', l.idType, {'CIN': 'CIN', 'PAN': 'PAN', 'GSTIN': 'GSTIN'}),
          text('idNumber', l.idNumber, required: true, caps: true),
          text('contactPerson', l.contactPerson, required: true),
          text('state', l.state, required: true),
          text('district', l.district, required: true),
        ],
      Role.driver => [
          text('licenceNumber', l.licenceNumber, required: true, caps: true),
          _DateField(
            label: l.licenceValidUntil,
            value: _date,
            errorText: _error?.fieldError('licenceValidUntil'),
            onChanged: (d) => setState(() => _date = d),
          ),
          text('vehicleClasses', l.vehicleClasses, required: true, caps: true),
          text('emergencyContact', l.emergencyContact, type: TextInputType.phone),
        ],
      Role.organization => [
          text('orgName', l.orgName, required: true),
          text('contactPerson', l.contactPerson, required: true),
          text('gstin', l.gstinOptional, caps: true),
          text('pan', l.panOptional, caps: true),
        ],
      _ => [text('businessName', l.businessNameOptional)],
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.roleDetails)),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...fields,
                  if (_error != null && _error!.fields.isEmpty)
                    Text(_err(context, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                  PrimaryButton(label: l.save, loading: _busy, onPressed: () => _save(role)),
                ],
              ),
            ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onChanged, this.errorText});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final d = await showDatePicker(
            context: context,
            initialDate: value ?? now.add(const Duration(days: 365)),
            firstDate: now,
            lastDate: DateTime(now.year + 30),
          );
          if (d != null) onChanged(d);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, errorText: errorText, suffixIcon: const Icon(Icons.calendar_month)),
          child: Text(value == null ? l.pickDate : Fmt.dateOnly(value!)),
        ),
      ),
    );
  }
}

/// A-202/A-203: add or replace a document (type, number, expiry, files with upload progress).
class DocumentFormScreen extends ConsumerStatefulWidget {
  const DocumentFormScreen({super.key, this.type, this.replaceId, this.truck = false});

  final DocumentType? type;
  final String? replaceId;

  /// Owner-driver truck documents (RC, insurance, permit) via `POST /driver/truck/documents`.
  final bool truck;

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  final _number = TextEditingController();
  DocumentType? _type;
  DateTime? _expires;
  final List<PickedUpload> _files = [];
  double? _progress;
  AppException? _error;

  static const _needsNumber = {DocumentType.pan, DocumentType.voterId, DocumentType.drivingLicence, DocumentType.gstCert,
      DocumentType.rc, DocumentType.insurance, DocumentType.nationalPermit};
  static const _needsExpiry = {DocumentType.drivingLicence, DocumentType.rc, DocumentType.insurance, DocumentType.nationalPermit};

  @override
  void initState() {
    super.initState();
    _type = widget.type;
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  List<DocumentType> _allowed(Role role) => widget.truck
      ? const [DocumentType.rc, DocumentType.insurance, DocumentType.nationalPermit]
      : [
        DocumentType.pan,
        DocumentType.voterId,
        DocumentType.drivingLicence,
        DocumentType.photo,
        if (role == Role.farmerNetwork) DocumentType.fnRegistrationCert,
        if (role == Role.organization) DocumentType.orgRegistrationCert,
        if (role != Role.driver && role != Role.receiver) DocumentType.gstCert,
      ];

  Future<void> _pick(PickSource source) async {
    try {
      final f = await const FilePicking().pick(source);
      if (f != null) setState(() => _files.add(f));
    } catch (_) {
      // Picker closed or permission denied — nothing to do.
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_type == null || _files.isEmpty) {
      setState(() => _error = AppException(
            kind: AppErrorKind.server,
            code: ApiErrorCode.validationFailed,
            fields: [if (_type == null) FieldError('type', l.fieldRequired), if (_files.isEmpty) FieldError('fileIds', l.fieldRequired)],
          ));
      return;
    }
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      final api = ref.read(profileApiProvider);
      final ids = <String>[];
      for (var i = 0; i < _files.length; i++) {
        ids.add(await uploadFile(api.dio, _files[i],
            onProgress: (p) => setState(() => _progress = (i + p) / _files.length)));
      }
      await (widget.truck ? api.saveTruckDocument : api.saveDocument)(
        replaceId: widget.replaceId,
        type: _type!,
        fileIds: ids,
        number: _number.text.trim(),
        expiresOn: _expires,
      );
      refreshProfile(ref);
      if (mounted) {
        _toast(context, l.saved);
        context.pop();
      }
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final role = session is SignedIn ? session.me.role : Role.unknown;
    final busy = _progress != null;
    final isPhoto = _type == DocumentType.photo;
    return Scaffold(
      appBar: AppBar(title: Text(_type == null ? l.addDocument : docTypeLabel(l, _type!))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.type == null)
            DropdownButtonFormField<DocumentType>(
              key: const Key('doc-type'),
              initialValue: _type,
              decoration: InputDecoration(labelText: l.documentType, errorText: _error?.fieldError('type')),
              items: [for (final t in _allowed(role)) DropdownMenuItem(value: t, child: Text(docTypeLabel(l, t)))],
              onChanged: (t) => setState(() => _type = t),
            ),
          if (_type != null && _needsNumber.contains(_type)) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('doc-number'),
              controller: _number,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l.docNumber, errorText: _error?.fieldError('number')),
            ),
          ],
          if (_type != null && _needsExpiry.contains(_type)) ...[
            const SizedBox(height: 12),
            _DateField(label: l.expiresOn, value: _expires, errorText: _error?.fieldError('expiresOn'),
                onChanged: (d) => setState(() => _expires = d)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(onPressed: busy ? null : () => _pick(PickSource.camera), icon: const Icon(Icons.photo_camera), label: Text(l.camera)),
              OutlinedButton.icon(onPressed: busy ? null : () => _pick(PickSource.gallery), icon: const Icon(Icons.photo_library), label: Text(l.gallery)),
              if (!isPhoto)
                OutlinedButton.icon(onPressed: busy ? null : () => _pick(PickSource.pdf), icon: const Icon(Icons.picture_as_pdf), label: Text(l.pdfFile)),
            ],
          ),
          if (_files.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.fileChosen(_files.length))),
          if (_error?.fieldError('fileIds') != null)
            Text(_error!.fieldError('fileIds')!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (busy) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            Text(l.uploading(((_progress ?? 0) * 100).round())),
          ],
          if (_error != null && _error!.fields.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_err(context, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 24),
          PrimaryButton(label: l.save, loading: busy, onPressed: _submit),
        ],
      ),
    );
  }
}

/// S-06 Verification status + documents.
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final info = ref.watch(verificationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.verificationTitle)),
      body: AsyncView(
        value: info,
        onRetry: () => ref.invalidate(verificationProvider),
        data: (v) {
          final message = switch (v.status) {
            VerificationStatus.underReview => l.underReviewInfo(v.estimatedReviewHours ?? 24),
            VerificationStatus.notVerified => l.notVerifiedInfo,
            VerificationStatus.verified => l.verifiedInfo,
            _ => l.notSubmittedInfo,
          };
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(verificationProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [verificationChip(context, v.status)]),
                const SizedBox(height: 8),
                Text(message, style: Theme.of(context).textTheme.bodyLarge),
                if (v.status == VerificationStatus.underReview)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => refreshProfile(ref),
                      icon: const Icon(Icons.refresh),
                      label: Text(l.checkUpdates),
                    ),
                  ),
                const Divider(height: 32),
                for (final item in v.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: item.done ? context.successColor : null),
                    title: Text(verificationItemLabel(l, item.key)),
                    trailing: Text('${item.weight}%'),
                    onTap: item.done ? null : () => _openItem(context, item.key),
                  ),
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(child: Text(l.documents, style: Theme.of(context).textTheme.titleMedium)),
                    TextButton.icon(
                      onPressed: () => context.push(Routes.profileDocument),
                      icon: const Icon(Icons.add),
                      label: Text(l.addDocument),
                    ),
                  ],
                ),
                for (final d in v.documents)
                  Card(
                    child: ListTile(
                      title: Text(docTypeLabel(l, d.type)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (d.numberMasked != null) Text(d.numberMasked!),
                          if (d.expiresOn != null) Text(l.expiresOnDate(d.expiresOn!)),
                          if (d.rejectReason != null)
                            Text(l.rejectedReason(d.rejectReason!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ),
                      trailing: d.status == DocumentStatus.rejected
                          ? TextButton(
                              onPressed: () => context.push('${Routes.profileDocument}?type=${_wire(d.type)}&replace=${d.id}'),
                              child: Text(l.uploadAgain),
                            )
                          : documentChip(context, d.status),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _openItem(BuildContext context, String key) {
    switch (key) {
      case 'NAME':
      case 'ADDRESS':
        context.push(Routes.profileEdit);
      case 'ROLE_PROFILE':
        context.push(Routes.profileRole);
      case 'PHOTO':
        context.push('${Routes.profileDocument}?type=PHOTO');
      case 'ID_PROOF':
        context.push(Routes.profileDocument);
      default:
        context.push('${Routes.profileDocument}?type=$key');
    }
  }
}

String _wire(DocumentType t) => t.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();

/// Parses `?type=` of the document route.
DocumentType? documentTypeFromWire(String? v) {
  if (v == null) return null;
  for (final t in DocumentType.values) {
    if (_wire(t) == v) return t;
  }
  return null;
}

/// A-207: change mobile with OTP to the new number.
class ChangeMobileScreen extends ConsumerStatefulWidget {
  const ChangeMobileScreen({super.key});

  @override
  ConsumerState<ChangeMobileScreen> createState() => _ChangeMobileScreenState();
}

class _ChangeMobileScreenState extends ConsumerState<ChangeMobileScreen> {
  final _form = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;
  AppException? _error;

  @override
  void dispose() {
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = ref.read(profileApiProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.changeMobile)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MobileField(controller: _mobile, errorText: _error?.fieldError('mobile')),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              Text(l.otpSentTo(_mobile.text)),
              const SizedBox(height: 8),
              OtpInput(
                key: const Key('otp'),
                onCompleted: (code) => _run(() async {
                  final me = await api.verifyMobile(_mobile.text.trim(), code);
                  ref.read(sessionProvider.notifier).updateMe(me);
                  refreshProfile(ref);
                  if (context.mounted) {
                    _toast(context, l.mobileChanged);
                    context.pop();
                  }
                }),
              ),
            ],
            if (_error != null && _error!.fields.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_err(context, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 24),
            if (!_otpSent)
              PrimaryButton(
                label: l.sendOtp,
                loading: _busy,
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  _run(() async {
                    await api.changeMobile(_mobile.text.trim());
                    setState(() => _otpSent = true);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// S-07 profile pop-up (from the avatar on home screens).
Future<void> showProfileSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final l = AppLocalizations.of(context);
        final session = ref.watch(sessionProvider);
        if (session is! SignedIn) return const SizedBox.shrink();
        final me = session.me;
        final settings = ref.watch(publicSettingsProvider).value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CompletionRing(percent: me.profileCompletion, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(me.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(roleLabel(l, me.role)),
                        ],
                      ),
                    ),
                    verificationChip(context, me.verificationStatus),
                  ],
                ),
                const SizedBox(height: 16),
                if (me.walletBalanceInr != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.walletBalance),
                    subtitle: MoneyText(me.walletBalanceInr!),
                    trailing: settings == null ? null : const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push(Routes.wallet);
                    },
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.trustScore),
                  trailing: TrustScoreBadge(score: me.trustScore),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(l.navProfile),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push(Routes.profile);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout),
                  title: Text(l.actionSignOut),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ref.read(sessionProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// A-206: shown when an action needs a VERIFIED account (the server still enforces NOT_VERIFIED).
Future<void> showCompleteVerificationSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.completeVerificationTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.completeVerificationBody),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l.goToProfile,
              onPressed: () {
                Navigator.pop(c);
                context.push(Routes.verification);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Use before any action that needs VERIFIED; returns false (and shows the sheet) when not verified.
bool ensureVerified(BuildContext context, WidgetRef ref) {
  final session = ref.read(sessionProvider);
  if (session is SignedIn && session.me.verificationStatus == VerificationStatus.verified) return true;
  showCompleteVerificationSheet(context);
  return false;
}
