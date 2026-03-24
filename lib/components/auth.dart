import 'package:flutter/material.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/soft_banner.dart';

/// 认证页面（登录/注册）可复用的 UI 组件集合。
///
/// 设计目标：
/// - 登录页与注册页共用相同风格的 Hero 卡、方法切换器、验证码卡、协议行；
/// - 页面本身只负责状态与交互，把可复用 UI 抽到 components 层。
class AuthMethodItem {
  /// 选项显示文本（例如“密码登录”“验证码登录”）。
  final String label;

  /// 当前选项是否处于选中状态。
  final bool selected;

  /// 点击该选项时的回调。
  final VoidCallback onTap;

  /// 创建一个方法切换器选项对象。
  const AuthMethodItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

/// 登录/注册共用的页面骨架。
///
/// 重点处理两件事：
/// - 键盘弹出时只平滑抬升滚动内容，避免 `Scaffold` 整页生硬 resize；
/// - 保持移动端/宽屏端一致的内容宽度和滚动行为。
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.children,
    this.backgroundColor,
  });

  final List<Widget> children;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);
    final scaffoldBackground = backgroundColor ?? theme.scaffoldBackgroundColor;
    final authPalette = SoftBannerPalettes.authOf(context);

    return Scaffold(
      backgroundColor: scaffoldBackground,
      resizeToAvoidBottomInset: false,
      body: AppCanvas(
        accentColor: authPalette.accentColor,
        secondaryAccentColor: theme.colorScheme.secondary,
        baseColor: scaffoldBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 420 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    6,
                    horizontalPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 登录页底部的协议提示文本。
class AuthLegalHint extends StatelessWidget {
  const AuthLegalHint({
    super.key,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  final VoidCallback onTapAgreement;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '登录即代表你已阅读并同意',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapAgreement,
          child: const Text(
            '《用户协议》',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF0284C7),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
        Text(
          '和',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapPrivacy,
          child: const Text(
            '《隐私政策》',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF0284C7),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

/// 登录/注册页顶部的 Hero 卡片。
///
/// 用于统一展示页面 icon、标题和副标题。
class AuthHeroCard extends StatelessWidget {
  /// 创建一个 Hero 卡片组件。
  const AuthHeroCard({
    super.key,
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ornamentKey,
  });

  /// Hero 卡片使用的浅色横幅配色。
  final SoftBannerPalette palette;

  /// Hero 左侧图标。
  final IconData icon;

  /// Hero 主标题。
  final String title;

  /// Hero 副标题。
  final String subtitle;
  final String? ornamentKey;

  @override
  Widget build(BuildContext context) {
    return SoftBannerCard(
      palette: palette,
      ornamentKey: ornamentKey ?? 'auth.hero.$title',
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderRadius: BorderRadius.circular(18),
      builder: (context, theme) {
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 认证方式切换器。
///
/// 通常用于“邮箱登录/验证码登录”等切换场景，选中项使用高亮背景。
class AuthMethodSwitcher extends StatelessWidget {
  /// 创建一个方法切换器组件。
  const AuthMethodSwitcher({super.key, required this.items, this.accentColor});

  /// 可选项列表。
  final List<AuthMethodItem> items;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;
    final outerBackground = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.06 : 0.025),
      theme.cardTheme.color ?? theme.colorScheme.surface,
    );
    final outerBorder = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.14 : 0.08),
      scheme.outline,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: outerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outerBorder),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x0C0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: items
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.key == items.length - 1 ? 0 : 8,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: entry.value.onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 36,
                        decoration: BoxDecoration(
                          color: entry.value.selected
                              ? accent
                              : Color.alphaBlend(
                                  accent.withValues(
                                    alpha: isDark ? 0.08 : 0.035,
                                  ),
                                  isDark
                                      ? const Color(0xFF1A2335)
                                      : const Color(0xFFF3F6FA),
                                ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            entry.value.label,
                            style: TextStyle(
                              color: entry.value.selected
                                  ? Colors.white
                                  : (isDark
                                        ? scheme.onSurface
                                        : scheme.onSurface.withValues(
                                            alpha: 0.84,
                                          )),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 协议与隐私政策勾选行。
///
/// 用于登录/注册页底部，统一实现“勾选 + 文本跳转”的交互。
class AuthAgreementRow extends StatelessWidget {
  /// 创建一个协议勾选行组件。
  const AuthAgreementRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  /// 当前是否已勾选同意。
  final bool agreed;

  /// 勾选状态变更回调。
  final ValueChanged<bool> onChanged;

  /// 点击“用户协议”回调。
  final VoidCallback onTapAgreement;

  /// 点击“隐私政策”回调。
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (value) => onChanged(value ?? false),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  '我已阅读并同意',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  '和',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
