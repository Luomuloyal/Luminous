import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';

// 登录页
//
// 设计要点：
// - 邮箱登录：只校验邮箱 + 密码（不要求 SVG 验证码）
// - SVG 测试登录：用于联调验证码流程（type=1，需要 uuid + code）
// - 用户态写入：登录成功后写入 UserController 并持久化（shared_preferences）
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum _LoginMethod { email, svg }

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _svgUserController = TextEditingController();
  final TextEditingController _svgCodeController = TextEditingController();

  final UserController _userController = Get.find<UserController>();

  bool _agreed = false;
  bool _obscurePassword = true;
  bool _loadingSvg = false;
  bool _submitting = false;
  _LoginMethod _method = _LoginMethod.email;

  String? _svgContent;
  String? _svgCodeId;

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _svgUserController.dispose();
    _svgCodeController.dispose();
    super.dispose();
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

  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
  }

  void _onMethodChanged(_LoginMethod method) {
    FocusScope.of(context).unfocus();
    setState(() {
      _method = method;
    });
    if (method == _LoginMethod.svg &&
        (_svgContent == null || _svgCodeId == null)) {
      _onFetchSvg();
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

  Future<void> _onLoginPressed() async {
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

    if (_method == _LoginMethod.svg &&
        (_svgCodeId == null || _svgCodeId!.isEmpty)) {
      ToastUtils.instance.show(context, '请先获取SVG验证码');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response = _method == _LoginMethod.email
          ? await AuthApi.loginWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await AuthApi.loginWithSvg(
              username: _svgUserController.text.trim(),
              password: _passwordController.text,
              code: _svgCodeController.text.trim(),
              uuid: _svgCodeId!,
            );

      await _userController.setUser(response.result);

      if (!mounted) {
        return;
      }

      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? '登录成功' : response.msg,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
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
      if (_method == _LoginMethod.svg) {
        _svgCodeController.clear();
        _onFetchSvg();
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
                        icon: Icons.health_and_safety_rounded,
                        title: '健康助手',
                        subtitle: _method == _LoginMethod.email
                            ? '邮箱密码登录'
                            : 'SVG验证码测试登录',
                      ),
                      const SizedBox(height: 12),
                      AuthMethodSwitcher(
                        items: [
                          AuthMethodItem(
                            label: '邮箱登录',
                            selected: _method == _LoginMethod.email,
                            onTap: () => _onMethodChanged(_LoginMethod.email),
                          ),
                          AuthMethodItem(
                            label: 'SVG测试',
                            selected: _method == _LoginMethod.svg,
                            onTap: () => _onMethodChanged(_LoginMethod.svg),
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
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(56, 34),
            foregroundColor: const Color(0xFF0369A1),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('注册'),
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
              if (_method == _LoginMethod.email) ...[
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
                    prefixIcon: Icons.verified_rounded,
                  ),
                  validator: _svgCodeValidator,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
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

  Widget _buildLoginButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _submitting ? null : _onLoginPressed,
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
                '登录',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Text(
      _method == _LoginMethod.email
          ? '提示：邮箱登录只校验邮箱和密码。'
          : '提示：SVG测试登录会校验 send-code(type=1) 返回的验证码。',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
