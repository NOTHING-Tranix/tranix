import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/settings_provider.dart';
import '../../../core/utils/field_limits.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/models/models.dart';
import '../../shared_shell/tab_screens.dart';
import '../application/auth_flow.dart';

/// Fixed +91 prefix, 10 digits, numeric keyboard (ui-guidelines "Forms").
class MobileField extends StatelessWidget {
  const MobileField({super.key, required this.controller, this.errorText});

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextFormField(
      key: const Key('mobile'),
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: l.mobileLabel, prefixText: '+91 ', counterText: '', errorText: errorText),
      validator: (v) => Validators.mobile(v) ? null : l.mobileInvalid,
    );
  }
}

/// S-03 page 1: mobile, name, role, consent → send SIGN_UP OTP.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  final _name = TextEditingController();
  Role? _role;
  bool _consent = false;
  bool _submitted = false;
  bool _busy = false;
  AppException? _error;

  static const roles = [Role.loadProvider, Role.farmerNetwork, Role.organization, Role.driver, Role.receiver];

  @override
  void dispose() {
    _mobile.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final valid = _form.currentState!.validate();
    if (!valid || _role == null || !_consent) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authFlowProvider.notifier).start(
            AuthDraft(mode: AuthMode.signUp, mobile: _mobile.text.trim(), name: _name.text.trim(), role: _role),
          );
      if (mounted) unawaited(context.push(Routes.signUpOtp));
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.actionSignUp), leading: BackButton(onPressed: () => context.go(Routes.welcome))),
      body: SafeArea(
        child: Form(
          key: _form,
          autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              MobileField(controller: _mobile, errorText: _error?.fieldError('mobile')),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                inputFormatters: Inputs.text(FieldLimits.name),
                decoration: InputDecoration(labelText: l.nameLabel, errorText: _error?.fieldError('name')),
                validator: (v) => Validators.name(v) ? null : l.nameInvalid,
              ),
              const SizedBox(height: 24),
              Text(l.roleQuestion, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in roles)
                    ChoiceChip(
                      key: Key('role-${r.name}'),
                      label: Text(roleLabel(l, r)),
                      selected: _role == r,
                      onSelected: (_) => setState(() => _role = r),
                    ),
                ],
              ),
              if (_submitted && _role == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l.roleRequired, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              CheckboxListTile(
                key: const Key('consent'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: Text(l.consentText),
                subtitle: _submitted && !_consent
                    ? Text(l.consentRequired, style: TextStyle(color: Theme.of(context).colorScheme.error))
                    : null,
              ),
              if (_error != null && _error!.fields.isEmpty) _ErrorText(error: _error!),
              const SizedBox(height: 24),
              PrimaryButton(label: l.sendOtp, loading: _busy, onPressed: _submit),
              TextButton(onPressed: () => context.go(Routes.signIn), child: Text(l.signInInstead)),
            ],
          ),
        ),
      ),
    );
  }
}

/// S-04 page 1: mobile → send SIGN_IN OTP.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  bool _busy = false;
  AppException? _error;

  @override
  void dispose() {
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authFlowProvider.notifier).start(AuthDraft(mode: AuthMode.signIn, mobile: _mobile.text.trim()));
      if (mounted) unawaited(context.push(Routes.signInOtp));
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.actionSignIn), leading: BackButton(onPressed: () => context.go(Routes.welcome))),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              MobileField(controller: _mobile),
              if (_error != null) _ErrorText(error: _error!),
              const SizedBox(height: 24),
              PrimaryButton(label: l.sendOtp, loading: _busy, onPressed: _submit),
              TextButton(onPressed: () => context.go(Routes.signUp), child: Text(l.noAccount)),
            ],
          ),
        ),
      ),
    );
  }
}

/// S-03 / S-04 page 2: 6-digit OTP with resend timer from settings.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  Timer? _timer;
  int _secondsLeft = 30;
  bool _busy = false;
  AppException? _error;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final settings = ref.read(publicSettingsProvider).value;
    _secondsLeft = settings?.otpResendSeconds ?? 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0);
      if (_secondsLeft == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!Validators.otp(_code)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authFlowProvider.notifier).verify(_code);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authFlowProvider.notifier).resend();
      messenger.showSnackBar(SnackBar(content: Text(l.otpSent)));
      setState(_startTimer);
    } on AppException catch (e) {
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final draft = ref.watch(authFlowProvider);
    if (draft == null) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.otpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.otpSentTo(draft.mobile), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            OtpInput(
              key: const Key('otp'),
              onCompleted: (v) {
                _code = v;
                _verify();
              },
            ),
            if (_error != null) _ErrorText(error: _error!),
            if (_error?.code == ApiErrorCode.mobileInUse)
              TextButton(onPressed: () => context.go(Routes.signIn), child: Text(l.signInInstead)),
            const SizedBox(height: 24),
            PrimaryButton(label: l.verify, loading: _busy, onPressed: _verify),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _secondsLeft > 0 ? null : _resend,
              child: Text(_secondsLeft > 0 ? l.resendIn(_secondsLeft) : l.resendOtp),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        errorMessage(AppLocalizations.of(context), error),
        key: const Key('auth-error'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
