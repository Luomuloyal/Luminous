import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/stores/session_sync_service.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';

// 登录页
//
// 设计要点：
// - 邮箱登录：只校验邮箱 + 密码（不要求 SVG 验证码）
// - SVG 测试登录：用于联调验证码流程（type=1，需要 uuid + code）
// - 用户态写入：登录成功后写入 UserController 并持久化（shared_preferences）
/// 登录页。
///
/// 支持正式邮箱登录与 SVG 验证码测试登录两种方式。
class LoginPage extends StatefulWidget {
  /// 创建登录页组件。
  const LoginPage({super.key});

  /// 创建登录页对应的状态对象。
  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// 登录页支持的两种方式。
enum _LoginMethod { email, svg }

/// 登录页状态对象。
///
/// 这里集中维护登录方式切换、输入校验、协议勾选以及提交中的禁用状态。
class _LoginPageState extends State<LoginPage> {
  /// 表单 key，用于触发表单校验。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 邮箱输入框控制器。
  final TextEditingController _emailController = TextEditingController();

  /// 密码输入框控制器（邮箱登录与 SVG 登录共用）。
  final TextEditingController _passwordController = TextEditingController();

  /// SVG 测试账号输入框控制器。
  final TextEditingController _svgUserController = TextEditingController();

  /// SVG 验证码输入框控制器。
  final TextEditingController _svgCodeController = TextEditingController();

  /// 全局用户控制器，用于登录成功后写入用户态并持久化。
  final UserController _userController = Get.find<UserController>();

  /// 是否已勾选协议。
  bool _agreed = false;

  /// 密码是否以明文显示。
  bool _obscurePassword = true;

  /// 是否正在加载 SVG 验证码。
  bool _loadingSvg = false;

  /// 是否正在提交登录请求。
  bool _submitting = false;

  /// 当前登录方式。
  _LoginMethod _method = _LoginMethod.email;

  /// SVG 验证码内容字符串。
  String? _svgContent;

  /// SVG 验证码对应的 uuid/id（用于登录请求传参）。
  String? _svgCodeId;

  /// 邮箱格式校验正则。
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// 密码格式校验正则（6-12 位字母或数字）。
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  /// SVG 验证码格式校验正则（4 位数字）。
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');

  /// 释放输入框控制器资源。
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _svgUserController.dispose();
    _svgCodeController.dispose();
    super.dispose();
  }

  /// 邮箱输入校验。
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

  /// 密码输入校验。
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

  /// SVG 测试账号输入校验。
  String? _svgUserValidator(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return '请输入测试账号';
    }
    return null;
  }

  /// SVG 验证码输入校验。
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

  /// 点击协议/隐私政策（当前占位提示）。
  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
  }

  /// 切换登录方式。
  ///
  /// 当切换到 SVG 模式且当前还没有验证码时，会自动触发一次验证码获取。
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

  /// 获取 SVG 验证码。
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

  /// 点击“登录”按钮。
  ///
  /// 该方法会：
  /// 1. 校验表单；
  /// 2. 校验协议勾选与 SVG uuid；
  /// 3. 调用对应登录接口；
  /// 4. 写入用户态并返回上一页。
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

      final loginResult = response.result;
      if (loginResult.token.trim().isNotEmpty) {
        await tokenManager.setToken(loginResult.token.trim());
      } else {
        await tokenManager.deleteToken();
      }

      await _userController.setUser(loginResult.user);
      final syncErrors = await sessionSyncService.syncForUser(
        loginResult.user.id,
      );

      if (!mounted) {
        return;
      }

      ToastUtils.instance.show(
        context,
        syncErrors.isEmpty
            ? (response.msg.isEmpty ? '登录成功' : response.msg)
            : '登录成功，但部分云端数据同步失败',
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

  /// 构建登录页 UI。
  @override
  Widget build(BuildContext context) {
    /// 当前屏幕宽度。
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// 宽屏时加大左右 padding，提升桌面端观感。
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

  /// 构建顶部返回与“注册”入口。
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

  /// 构建表单区域卡片。
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

  /// 统一输入框样式构建方法。
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

  /// 构建“登录”按钮。
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

  /// 构建底部提示文案。
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
