import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    this.backgroundColor = const Color(0xFFF3F7FB),
  });

  final List<Widget> children;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
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
                  24,
                  horizontalPadding,
                  20,
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
  });

  /// Hero 卡片使用的浅色横幅配色。
  final SoftBannerPalette palette;

  /// Hero 左侧图标。
  final IconData icon;

  /// Hero 主标题。
  final String title;

  /// Hero 副标题。
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftBannerCard(
      palette: palette,
      borderRadius: BorderRadius.circular(18),
      builder: (context, theme) {
        return Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(icon, color: theme.accentColor, size: 26),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 13,
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
  const AuthMethodSwitcher({super.key, required this.items});

  /// 可选项列表。
  final List<AuthMethodItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
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
                        height: 38,
                        decoration: BoxDecoration(
                          color: entry.value.selected
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            entry.value.label,
                            style: TextStyle(
                              color: entry.value.selected
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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

/// SVG 验证码展示卡。
///
/// 支持三种状态：
/// - loading：展示进度圈；
/// - empty：展示引导文案；
/// - 有 svgContent：渲染 SVG 图像。
class AuthSvgCaptchaCard extends StatelessWidget {
  /// 创建一个 SVG 验证码卡片。
  const AuthSvgCaptchaCard({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.svgContent,
    this.emptyText = '点击右侧刷新获取SVG验证码',
  });

  /// 是否处于加载中。
  final bool isLoading;

  /// 点击“刷新”按钮回调。
  final VoidCallback onRefresh;

  /// SVG 原始字符串内容（来自后端）。
  final String? svgContent;

  /// 没有 SVG 内容时的提示文案。
  final String emptyText;

  @override
  Widget build(BuildContext context) {
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
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : svgContent == null || svgContent!.isEmpty
                    ? Text(
                        emptyText,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : SvgPicture.string(svgContent!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: isLoading ? null : onRefresh,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (value) => onChanged(value ?? false),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: const Text(
                  '我已阅读并同意',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: const Text(
                  '和',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
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
