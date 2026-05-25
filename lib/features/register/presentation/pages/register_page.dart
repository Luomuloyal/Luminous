import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/shared/widgets/auth/auth.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/register_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({
    super.key,
    this.authApi = const AuthApi(),
    this.initialIdentifierType = AuthIdentifierType.email,
    this.initialIdentifier = '',
    this.initialCode = '',
  });

  final AuthApi authApi;
  final AuthIdentifierType initialIdentifierType;
  final String initialIdentifier;
  final String initialCode;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final _identifierCtrl = TextEditingController();
  late final _usernameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _identifierType = AuthIdentifierType.email;
  var _agreed = false;
  var _obscurePassword = true;
  var _obscureConfirm = true;
  AuthApi get _authApi => widget.authApi;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() { super.initState(); _identifierCtrl.text = widget.initialIdentifier; _codeCtrl.text = widget.initialCode; ref.read(registerNotifierProvider.notifier).initCodeTarget(widget.initialIdentifier, widget.initialCode); }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _usernameCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // -- labels --

  String _identifierLabel() =>
      _identifierType == AuthIdentifierType.phone ? _l10n.authPhoneLabel : _l10n.authEmailLabel;

  // -- validators --

  String? _identifierValidator(String? value) =>
      ref.read(registerNotifierProvider.notifier).validateIdentifier(value ?? '', _identifierType);

  String? _codeValidator(String? value) =>
      ref.read(registerNotifierProvider.notifier).validateCode(value ?? '');

  String? _usernameValidator(String? value) =>
      ref.read(registerNotifierProvider.notifier).validateUsername(value ?? '');

  String? _passwordValidator(String? value) =>
      ref.read(registerNotifierProvider.notifier).validatePassword(value ?? '');

  String? _confirmValidator(String? value) {
    if ((value ?? '').isEmpty) return '请确认密码';
    if (value != _passwordCtrl.text) return '两次输入不一致';
    return null;
  }

  // -- actions --

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    final id = _identifierCtrl.text.trim();
    final error = _identifierValidator(id);
    if (error != null) { ToastUtils.instance.show(context, error); return; }
    final ok = await ref.read(registerNotifierProvider.notifier).sendCode(
      identifier: id, type: _identifierType, authApi: _authApi,
    );
    if (ok && mounted) ToastUtils.instance.show(context, _l10n.authCodeSentSuccess);
  }

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) { ToastUtils.instance.show(context, '请先同意用户协议和隐私政策'); return; }

    final notifier = ref.read(registerNotifierProvider.notifier);
    final identifier = _identifierCtrl.text.trim();
    if (notifier.codeTarget != identifier) {
      ToastUtils.instance.show(context, '请先对当前账号发送验证码');
      return;
    }
    try {
      await notifier.register(
        type: _identifierType, identifier: identifier,
        username: _usernameCtrl.text, code: _codeCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      ToastUtils.instance.show(context, _l10n.registerSuccess);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.maybePop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastUtils.instance.show(context, e.message.isNotEmpty ? e.message : '注册失败');
    }
  }

  // -- build --

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registerNotifierProvider);
    final l10n = _l10n;

    return AuthPageScaffold(children: [
      _buildTopBar(),
      const SizedBox(height: 10),
      AuthHeroCard(palette: SoftBannerPalettes.authOf(context), icon: Icons.person_add_alt_1_rounded, title: l10n.registerHeroTitle, subtitle: l10n.registerHeroSubtitle(_identifierLabel())),
      const SizedBox(height: 14),
      _buildForm(formState),
      const SizedBox(height: 12),
      AuthAgreementRow(agreed: _agreed, onChanged: (v) => setState(() => _agreed = v), onTapAgreement: () => Navigator.pushNamed(context, '/user-agreement'), onTapPrivacy: () => Navigator.pushNamed(context, '/privacy-policy')),
      const SizedBox(height: 14),
      _buildRegisterButton(formState),
      const SizedBox(height: 8),
      _buildHelperText(),
    ]);
  }

  Widget _buildTopBar() {
    final theme = Theme.of(context); final scheme = theme.colorScheme;
    return Row(children: [
      InkWell(
        onTap: () => Navigator.maybePop(context), borderRadius: BorderRadius.circular(999),
        child: Container(width: 32, height: 32, decoration: BoxDecoration(color: theme.cardTheme.color ?? scheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: scheme.outline)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(_l10n.registerTopTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface))),
    ]);
  }

  Widget _buildForm(RegisterFormState form) {
    return AuthSurfaceCard(ornamentKey: 'auth.register.form', child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Form(key: _formKey, child: Column(children: [
        _buildField(controller: _usernameCtrl, label: _l10n.registerUsernameLabel, hint: _l10n.registerUsernameHint, prefixIcon: Icons.person_outline_rounded, validator: _usernameValidator),
        const SizedBox(height: 14),
        _buildField(controller: _identifierCtrl, label: _identifierLabel(), prefixIcon: _identifierType == AuthIdentifierType.phone ? Icons.phone_android_rounded : Icons.email_outlined, validator: _identifierValidator, onChanged: (v) => ref.read(registerNotifierProvider.notifier).onIdentifierChanged(v)),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildField(controller: _codeCtrl, label: _l10n.authCodeLabel, prefixIcon: Icons.pin_rounded, validator: _codeValidator, keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          FilledButton(onPressed: form.sendingCode || form.codeCountdownSeconds > 0 ? null : _onSendCode, style: FilledButton.styleFrom(minimumSize: const Size(80, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(form.codeCountdownSeconds > 0 ? '${form.codeCountdownSeconds}s' : '发送验证码')),
        ]),
        const SizedBox(height: 14),
        _buildField(controller: _passwordCtrl, label: _l10n.authPasswordLabel, prefixIcon: Icons.lock_outline_rounded, obscureText: _obscurePassword, validator: _passwordValidator, suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded))),
        const SizedBox(height: 14),
        _buildField(controller: _confirmCtrl, label: '确认密码', prefixIcon: Icons.lock_outline_rounded, obscureText: _obscureConfirm, validator: _confirmValidator, suffixIcon: IconButton(onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm), icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded))),
      ])),
    ));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller, obscureText: obscureText, validator: validator,
      onChanged: onChanged, keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, hintText: hint, prefixIcon: Icon(prefixIcon), suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4)),
      ),
    );
  }

  Widget _buildRegisterButton(RegisterFormState form) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(width: double.infinity, child: FilledButton(
      onPressed: form.submitting || !_agreed ? null : _onRegisterPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: form.submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_l10n.registerButton, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    ));
  }

  Widget _buildHelperText() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('已有账号？', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      TextButton(onPressed: () => Navigator.maybePop(context), child: Text(_l10n.loginButton)),
    ]);
  }
}
