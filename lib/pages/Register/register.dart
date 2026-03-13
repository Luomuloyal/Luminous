import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luminous/apis/auth_api.dart';
import 'package:luminous/utils/toast_utils.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

enum _RegisterMethod { email, svg }

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _svgUserController = TextEditingController();
  final TextEditingController _svgCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  _RegisterMethod _method = _RegisterMethod.email;

  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _sendingCode = false;
  bool _loadingSvg = false;
  bool _submitting = false;

  String? _svgContent;
  String? _svgCodeId;

  late final TapGestureRecognizer _agreementRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _emailCodeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');
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
    _emailController.dispose();
    _emailCodeController.dispose();
    _svgUserController.dispose();
    _svgCodeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return '请输入邮箱';
    }
    if (!_emailRegExp.hasMatch(email)) {
      return '邮箱格式不正确';
    }
    return null;
  }

  String? _emailCodeValidator(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return '请输入邮箱验证码';
    }
    if (!_emailCodeRegExp.hasMatch(code)) {
      return '邮箱验证码应为6位数字';
    }
    return null;
  }

  String? _svgUserValidator(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return '请输入测试账号';
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

  void _onMethodChanged(_RegisterMethod method) {
    FocusScope.of(context).unfocus();
    setState(() {
      _method = method;
    });
    if (method == _RegisterMethod.svg && _svgContent == null) {
      _onFetchSvg();
    }
  }

  Future<void> _onSendEmailCode() async {
    FocusScope.of(context).unfocus();
    if (_sendingCode) {
      return;
    }

    final emailError = _emailValidator(_emailController.text);
    if (emailError != null) {
      ToastUtils.instance.show(context, emailError);
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    try {
      final response = await AuthApi.sendEmailCode(
        _emailController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        response['msg']?.toString() ?? '验证码发送成功',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
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
      final response = await AuthApi.fetchSvgCode();
      final dynamic data = response['data'];
      final svg = data is Map<String, dynamic> ? data['svg']?.toString() : null;
      final codeId = data is Map<String, dynamic>
          ? data['id']?.toString()
          : null;
      if (!mounted) {
        return;
      }
      if (svg == null || svg.isEmpty) {
        ToastUtils.instance.show(context, 'SVG验证码获取失败');
        return;
      }
      setState(() {
        _svgContent = svg;
        _svgCodeId = codeId;
      });
      ToastUtils.instance.show(context, 'SVG验证码已刷新');
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
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

    _formKey.currentState?.validate();

    final email = _emailController.text.trim();
    final emailCode = _emailCodeController.text.trim();
    final svgUser = _svgUserController.text.trim();
    final svgCode = _svgCodeController.text.trim();
    final password = _passwordController.text;

    if (_method == _RegisterMethod.email) {
      final emailError = _emailValidator(email);
      if (emailError != null) {
        ToastUtils.instance.show(context, emailError);
        return;
      }
      final codeError = _emailCodeValidator(emailCode);
      if (codeError != null) {
        ToastUtils.instance.show(context, codeError);
        return;
      }
    } else {
      final userError = _svgUserValidator(svgUser);
      if (userError != null) {
        ToastUtils.instance.show(context, userError);
        return;
      }
      final codeError = _svgCodeValidator(svgCode);
      if (codeError != null) {
        ToastUtils.instance.show(context, codeError);
        return;
      }
      if (_svgCodeId == null || _svgCodeId!.isEmpty) {
        ToastUtils.instance.show(context, '请先获取SVG验证码');
        return;
      }
    }

    final passwordError = _passwordValidator(_passwordController.text);
    if (passwordError != null) {
      ToastUtils.instance.show(context, passwordError);
      return;
    }

    final confirmError = _confirmValidator(_confirmController.text);
    if (confirmError != null) {
      ToastUtils.instance.show(context, confirmError);
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
      final response = _method == _RegisterMethod.email
          ? await AuthApi.registerWithEmail(
              email: email,
              password: password,
              code: emailCode,
            )
          : await AuthApi.registerWithSvg(
              username: svgUser,
              password: password,
              code: svgCode,
              uuid: _svgCodeId!,
            );
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(context, response['msg']?.toString() ?? '注册成功');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.maybePop(context);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 420 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 14),
                      _buildBrand(),
                      const SizedBox(height: 12),
                      _buildMethodSelector(),
                      const SizedBox(height: 18),
                      _buildFormCard(),
                      const SizedBox(height: 14),
                      _buildAgreementRow(),
                      const SizedBox(height: 18),
                      _buildRegisterButton(),
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
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '创建账号',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _method == _RegisterMethod.email ? '邮箱验证码注册' : 'SVG验证码测试注册',
                  style: const TextStyle(
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

  Widget _buildMethodSelector() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _buildMethodButton(
                label: '邮箱注册',
                selected: _method == _RegisterMethod.email,
                onTap: () => _onMethodChanged(_RegisterMethod.email),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMethodButton(
                label: 'SVG注册',
                selected: _method == _RegisterMethod.svg,
                onTap: () => _onMethodChanged(_RegisterMethod.svg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0EA5E9) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
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
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              if (_method == _RegisterMethod.email) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入邮箱地址',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: _emailValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCodeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '邮箱验证码',
                          hintText: '请输入6位验证码',
                          prefixIcon: const Icon(Icons.verified_user_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: _emailCodeValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _sendingCode ? null : _onSendEmailCode,
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
                ),
              ] else ...[
                TextFormField(
                  controller: _svgUserController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '测试账号',
                    hintText: '请输入测试账号名',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: _svgUserValidator,
                ),
                const SizedBox(height: 12),
                _buildSvgCard(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _svgCodeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'SVG验证码',
                    hintText: '请输入4位验证码',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: _svgCodeValidator,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
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
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  hintText: '请再次输入密码',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: _confirmValidator,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSvgCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: Center(
                child: _loadingSvg
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _svgContent == null
                    ? const Text(
                        '点击右侧刷新获取SVG验证码',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : SvgPicture.string(_svgContent!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: _loadingSvg ? null : _onFetchSvg,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('刷新'),
            style: FilledButton.styleFrom(
              foregroundColor: const Color(0xFF0369A1),
              backgroundColor: const Color(0xFFE0F2FE),
              minimumSize: const Size(80, 42),
            ),
          ),
        ],
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
      _method == _RegisterMethod.email
          ? '提示：邮箱注册会调用 send-code(type=2) 和 register-user(codeType=2)。'
          : '提示：SVG注册会调用 send-code(type=1) 和 register-user(codeType=1)。',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
