import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:luminous/utils/toast_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _submitted = false;
  bool _agreed = false;
  bool _obscurePassword = true;
  late final TapGestureRecognizer _agreementRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  @override
  void initState() {
    super.initState();
    _agreementRecognizer = TapGestureRecognizer()..onTap = _onTapAgreement;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _onTapAgreement;
  }

  @override
  void dispose() {
    _agreementRecognizer.dispose();
    _privacyRecognizer.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _phoneValidator(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) {
      return '请输入手机号';
    }
    if (!_phoneRegExp.hasMatch(phone)) {
      return '手机号格式不正确';
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

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();

    if (!_submitted) {
      setState(() {
        _submitted = true;
      });
    }
    _formKey.currentState?.validate();

    final phoneError = _phoneValidator(_phoneController.text);
    if (phoneError != null) {
      ToastUtils.instance.show(context, phoneError);
      return;
    }

    final passwordError = _passwordValidator(_passwordController.text);
    if (passwordError != null) {
      ToastUtils.instance.show(context, passwordError);
      return;
    }

    if (!_agreed) {
      ToastUtils.instance.show(context, '请先阅读并勾选《用户协议》《隐私政策》');
      return;
    }

    ToastUtils.instance.show(context, '登录成功');
  }

  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 420 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBrand(),
                      const SizedBox(height: 18),
                      _buildFormCard(),
                      const SizedBox(height: 14),
                      _buildAgreementRow(),
                      const SizedBox(height: 18),
                      _buildLoginButton(),
                      const SizedBox(height: 10),
                      _buildHelperText(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0EA5E9),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康助手',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '手机号密码登录',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入11位手机号',
                  prefixIcon: const Icon(Icons.phone_iphone_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: _phoneValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                inputFormatters: [LengthLimitingTextInputFormatter(12)],
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '6-12位字母或数字',
                  prefixIcon: const Icon(Icons.lock_rounded),
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
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: _passwordValidator,
                onFieldSubmitted: (_) => _onLoginPressed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreed,
          onChanged: (v) {
            setState(() {
              _agreed = v ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _agreed = !_agreed;
              });
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: '我已阅读并同意'),
                  TextSpan(
                    text: '《用户协议》',
                    recognizer: _agreementRecognizer,
                    style: const TextStyle(
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私政策》',
                    recognizer: _privacyRecognizer,
                    style: const TextStyle(
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _onLoginPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          '登录',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    return const Text(
      '提示：本页面仅实现本地表单校验与轻提示，不会发起真实登录请求。',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
