import 'package:flutter/material.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 注册页。
///
/// 支持手机号/邮箱双栈注册，并要求业务验证码 + SVG 验证码双校验。
class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    this.authApi = const AuthApi(),
    this.initialIdentifierType = AuthIdentifierType.phone,
    this.initialIdentifier = '',
    this.initialCode = '',
    this.initialCodeId = '',
  });

  final AuthApi authApi;
  final AuthIdentifierType initialIdentifierType;
  final String initialIdentifier;
  final String initialCode;
  final String initialCodeId;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _svgCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  AuthIdentifierType _identifierType = AuthIdentifierType.phone;
  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _sendingCode = false;
  bool _loadingSvg = false;
  bool _submitting = false;
  String _codeId = '';
  String _codeTarget = '';
  String? _svgContent;
  String _svgCodeId = '';

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  @override
  void initState() {
    super.initState();
    _identifierType = widget.initialIdentifierType;
    _identifierController.text = widget.initialIdentifier;
    _codeController.text = widget.initialCode;
    _codeId = widget.initialCodeId.trim();
    _codeTarget = widget.initialIdentifier.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFetchSvg();
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _svgCodeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
  }

  String? _identifierValidator(String? value) {
    final identifier = (value ?? '').trim();
    if (identifier.isEmpty) {
      return _identifierType == AuthIdentifierType.phone ? '请输入手机号' : '请输入邮箱';
    }
    if (_identifierType == AuthIdentifierType.phone &&
        !_phoneRegExp.hasMatch(identifier)) {
      return '手机号格式不正确';
    }
    if (_identifierType == AuthIdentifierType.email &&
        !_emailRegExp.hasMatch(identifier)) {
      return '邮箱格式不正确';
    }
    return null;
  }

  String? _codeValidator(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return '请输入验证码';
    }
    if (!_codeRegExp.hasMatch(code)) {
      return '验证码应为6位数字';
    }
    return null;
  }

  String? _svgCodeValidator(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return '请输入SVG验证码';
    }
    if (!_svgCodeRegExp.hasMatch(code)) {
      return 'SVG验证码应为4位数字';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final pwd = value ?? '';
    if (pwd.isEmpty) {
      return '请输入密码';
    }
    if (!_passwordRegExp.hasMatch(pwd)) {
      return '密码需为6-12位字母或数字';
    }
    return null;
  }

  String? _confirmValidator(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) {
      return '请再次输入密码';
    }
    if (confirm != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  void _toggleIdentifierType(AuthIdentifierType type) {
    if (_identifierType == type) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _identifierType = type;
      _clearCodeSession(clearInput: true);
    });
  }

  void _clearCodeSession({required bool clearInput}) {
    _codeId = '';
    _codeTarget = '';
    if (clearInput) {
      _codeController.clear();
    }
  }

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    if (_sendingCode) {
      return;
    }

    final identifier = _identifierController.text.trim();
    final error = _identifierValidator(identifier);
    if (error != null) {
      ToastUtils.instance.show(context, error);
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await widget.authApi.sendPhoneCode(
              phone: identifier,
              scene: AuthCodeScene.register,
            )
          : await widget.authApi.sendEmailCode(
              email: identifier,
              scene: AuthCodeScene.register,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _codeId = response.result.id.trim();
        _codeTarget = identifier;
      });
      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? '验证码发送成功' : response.msg,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _sendingCode = false;
        });
      }
    }
  }

  Future<void> _onFetchSvg() async {
    FocusScope.of(context).unfocus();
    if (_loadingSvg) {
      return;
    }

    setState(() {
      _loadingSvg = true;
    });

    try {
      final response = await widget.authApi.fetchSvgCode();
      final result = response.result;

      if (!mounted) {
        return;
      }

      if (result.svg.isEmpty || result.id.isEmpty) {
        ToastUtils.instance.show(context, 'SVG验证码获取失败');
        return;
      }

      setState(() {
        _svgContent = result.svg;
        _svgCodeId = result.id.trim();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loadingSvg = false;
        });
      }
    }
  }

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    if (_submitting) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final identifier = _identifierController.text.trim();
    if (_codeId.isEmpty || _codeTarget != identifier) {
      ToastUtils.instance.show(context, '请先获取当前账号的验证码');
      return;
    }
    if (_svgCodeId.isEmpty) {
      ToastUtils.instance.show(context, '请先获取SVG验证码');
      return;
    }
    if (!_agreed) {
      ToastUtils.instance.show(context, '请先阅读并勾选《用户协议》《隐私政策》');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await widget.authApi.registerWithPhone(
              phone: identifier,
              code: _codeController.text.trim(),
              codeId: _codeId,
              svgCode: _svgCodeController.text.trim(),
              svgId: _svgCodeId,
              password: _passwordController.text,
            )
          : await widget.authApi.registerWithEmail(
              email: identifier,
              code: _codeController.text.trim(),
              codeId: _codeId,
              svgCode: _svgCodeController.text.trim(),
              svgId: _svgCodeId,
              password: _passwordController.text,
            );

      if (!mounted) {
        return;
      }

      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? '注册成功' : response.msg,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.maybePop(context);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      children: [
        _buildTopBar(),
        const SizedBox(height: 14),
        AuthHeroCard(
          palette: SoftBannerPalettes.auth,
          icon: Icons.person_add_alt_1_rounded,
          title: '创建账号',
          subtitle: '${_identifierType.label}验证码注册 + SVG 校验',
        ),
        const SizedBox(height: 12),
        AuthMethodSwitcher(
          items: [
            AuthMethodItem(
              label: AuthIdentifierType.phone.registerLabel,
              selected: _identifierType == AuthIdentifierType.phone,
              onTap: () => _toggleIdentifierType(AuthIdentifierType.phone),
            ),
            AuthMethodItem(
              label: AuthIdentifierType.email.registerLabel,
              selected: _identifierType == AuthIdentifierType.email,
              onTap: () => _toggleIdentifierType(AuthIdentifierType.email),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildFormCard(),
        const SizedBox(height: 14),
        AuthAgreementRow(
          agreed: _agreed,
          onChanged: (value) {
            setState(() {
              _agreed = value;
            });
          },
          onTapAgreement: _onTapAgreement,
          onTapPrivacy: _onTapAgreement,
        ),
        const SizedBox(height: 18),
        _buildRegisterButton(),
        const SizedBox(height: 10),
        _buildHelperText(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            '注册',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _identifierController,
                keyboardType: _identifierType == AuthIdentifierType.phone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: _identifierType.label,
                  hintText: _identifierType == AuthIdentifierType.phone
                      ? '请输入手机号'
                      : '请输入邮箱地址',
                  prefixIcon: _identifierType == AuthIdentifierType.phone
                      ? Icons.phone_iphone_rounded
                      : Icons.email_outlined,
                ),
                validator: _identifierValidator,
                onChanged: (value) {
                  final identifier = value.trim();
                  final hasActiveCodeSession =
                      _codeId.isNotEmpty || _codeTarget.isNotEmpty;
                  if (hasActiveCodeSession && identifier != _codeTarget) {
                    setState(() {
                      _clearCodeSession(clearInput: false);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildCodeRow(),
              const SizedBox(height: 12),
              AuthSvgCaptchaCard(
                isLoading: _loadingSvg,
                onRefresh: _onFetchSvg,
                svgContent: _svgContent,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _svgCodeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: 'SVG验证码',
                  hintText: '请输入4位SVG验证码',
                  prefixIcon: Icons.shield_outlined,
                ),
                validator: _svgCodeValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: '密码',
                  hintText: '6-12位字母或数字',
                  prefixIcon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                decoration: _buildInputDecoration(
                  labelText: '确认密码',
                  hintText: '请再次输入密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: _confirmValidator,
                onFieldSubmitted: (_) => _onRegisterPressed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: _buildInputDecoration(
              labelText: '验证码',
              hintText: '请输入6位验证码',
              prefixIcon: Icons.verified_user_rounded,
            ),
            validator: _codeValidator,
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: _sendingCode ? null : _onSendCode,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            minimumSize: const Size(96, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _sendingCode
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('发送验证码'),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _submitting ? null : _onRegisterPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '注册',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Text(
      _identifierType == AuthIdentifierType.phone
          ? '手机号注册会先校验短信认证验证码，再校验 SVG 验证码。'
          : '邮箱注册会先校验邮件验证码，再校验 SVG 验证码。',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
