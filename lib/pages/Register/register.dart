import 'package:flutter/material.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/utils/toast_utils.dart';

// 注册页
//
// 设计要点：
// - 邮箱注册：send-code(type=2) 发送 6 位验证码，再 register-user(type=2)
// - SVG 注册：send-code(type=1) 获取 4 位 SVG 验证码，再 register-user(type=1)
// - 可复用组件抽取到 components/auth.dart（协议行、切换器、SVG验证码卡、Hero 卡）
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  /// 创建注册页对应的状态对象。
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

/// 注册页支持的两种方式。
enum _RegisterMethod { email, svg }

class _RegisterViewState extends State<RegisterView> {
  /// 表单 key，用于触发表单校验。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 邮箱输入框控制器。
  final TextEditingController _emailController = TextEditingController();

  /// 邮箱验证码输入框控制器。
  final TextEditingController _emailCodeController = TextEditingController();

  /// SVG 测试账号输入框控制器。
  final TextEditingController _svgUserController = TextEditingController();

  /// SVG 验证码输入框控制器。
  final TextEditingController _svgCodeController = TextEditingController();

  /// 密码输入框控制器。
  final TextEditingController _passwordController = TextEditingController();

  /// 确认密码输入框控制器。
  final TextEditingController _confirmController = TextEditingController();

  /// 当前注册方式。
  _RegisterMethod _method = _RegisterMethod.email;

  /// 是否已勾选协议。
  bool _agreed = false;

  /// 密码是否明文显示。
  bool _obscurePassword = true;

  /// 确认密码是否明文显示。
  bool _obscureConfirm = true;

  /// 是否正在发送邮箱验证码。
  bool _sendingCode = false;

  /// 是否正在加载 SVG 验证码。
  bool _loadingSvg = false;

  /// 是否正在提交注册请求。
  bool _submitting = false;

  /// SVG 验证码内容字符串。
  String? _svgContent;

  /// SVG 验证码对应的 uuid/id。
  String? _svgCodeId;

  /// 邮箱格式校验正则。
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// 邮箱验证码格式校验正则（6 位数字）。
  static final RegExp _emailCodeRegExp = RegExp(r'^\d{6}$');

  /// SVG 验证码格式校验正则（4 位数字）。
  static final RegExp _svgCodeRegExp = RegExp(r'^\d{4}$');

  /// 密码格式校验正则（6-12 位字母或数字）。
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  /// 释放输入框控制器资源。
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

  /// 点击协议/隐私政策（当前为占位提示）。
  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
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

  /// 邮箱验证码输入校验。
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

  /// 确认密码输入校验。
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

  /// 切换注册方式。
  ///
  /// 切换到 SVG 模式时，如果当前还没有验证码，会自动刷新一次 SVG 验证码。
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

  /// 发送邮箱验证码。
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

  /// 点击“注册”按钮。
  ///
  /// 该方法会：
  /// 1. 校验表单；
  /// 2. 校验协议勾选与 SVG uuid；
  /// 3. 调用对应注册接口；
  /// 4. 成功后返回上一页。
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

  /// 构建注册页 UI。
  @override
  Widget build(BuildContext context) {
    /// 当前屏幕宽度。
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// 宽屏时使用更大的左右 padding。
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

  /// 构建顶部返回栏。
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

  /// 构建“注册”按钮。
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

  /// 构建底部帮助文案。
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
