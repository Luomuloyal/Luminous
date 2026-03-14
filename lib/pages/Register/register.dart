import 'package:flutter/material.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
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

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _emailCodeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  @override
  void dispose() {
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
    if (method == _RegisterMethod.svg &&
        (_svgContent == null || _svgCodeId == null)) {
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
        response.msg.isEmpty ? '验证码发送成功' : response.msg,
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
        _svgCodeId = result.id;
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

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (!_agreed) {
      ToastUtils.instance.show(context, '请先阅读并勾选《用户协议》《隐私政策》');
      return;
    }

    if (_method == _RegisterMethod.svg &&
        (_svgCodeId == null || _svgCodeId!.isEmpty)) {
      ToastUtils.instance.show(context, '请先获取SVG验证码');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response = _method == _RegisterMethod.email
          ? await AuthApi.registerWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              code: _emailCodeController.text.trim(),
            )
          : await AuthApi.registerWithSvg(
              username: _svgUserController.text.trim(),
              password: _passwordController.text,
              code: _svgCodeController.text.trim(),
              uuid: _svgCodeId!,
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
                      AuthHeroCard(
                        icon: Icons.person_add_alt_1_rounded,
                        title: '创建账号',
                        subtitle: _method == _RegisterMethod.email
                            ? '邮箱验证码注册'
                            : 'SVG验证码测试注册',
                      ),
                      const SizedBox(height: 12),
                      AuthMethodSwitcher(
                        items: [
                          AuthMethodItem(
                            label: '邮箱注册',
                            selected: _method == _RegisterMethod.email,
                            onTap: () =>
                                _onMethodChanged(_RegisterMethod.email),
                          ),
                          AuthMethodItem(
                            label: 'SVG注册',
                            selected: _method == _RegisterMethod.svg,
                            onTap: () => _onMethodChanged(_RegisterMethod.svg),
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
              if (_method == _RegisterMethod.email) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _buildInputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入邮箱地址',
                    prefixIcon: Icons.email_outlined,
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
                        decoration: _buildInputDecoration(
                          labelText: '邮箱验证码',
                          hintText: '请输入6位验证码',
                          prefixIcon: Icons.verified_user_rounded,
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
                  decoration: _buildInputDecoration(
                    labelText: '测试账号',
                    hintText: '请输入测试账号名',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: _svgUserValidator,
                ),
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
                    hintText: '请输入4位验证码',
                    prefixIcon: Icons.tag_rounded,
                  ),
                  validator: _svgCodeValidator,
                ),
              ],
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
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
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
      _method == _RegisterMethod.email
          ? '提示：邮箱注册会调用 send-code(type=2) 和 register-user(type=2)。'
          : '提示：SVG注册会校验 send-code(type=1) 返回的验证码。',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
