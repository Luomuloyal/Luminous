part of 'auth.dart';

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
    final selectedStart = Color.lerp(accent, scheme.secondary, 0.16)!;
    final selectedEnd = Color.lerp(accent, scheme.tertiary, 0.10)!;
    const segmentSpacing = 8.0;
    final outerBackground = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.07 : 0.032),
      theme.cardTheme.color ?? theme.colorScheme.surface,
    );
    final outerBorder = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.16 : 0.10),
      scheme.outline,
    );
    final selectedIndex = items.indexWhere((item) => item.selected);
    final resolvedSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: outerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outerBorder),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x100F172A),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth =
                (constraints.maxWidth - (items.length - 1) * segmentSpacing) /
                items.length;
            final selectedLeft =
                resolvedSelectedIndex * (segmentWidth + segmentSpacing);

            return SizedBox(
              height: 38,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: selectedLeft,
                    top: 0,
                    width: segmentWidth,
                    height: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [selectedStart, selectedEnd],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                              alpha: isDark ? 0.16 : 0.20,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: items
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right: entry.key == items.length - 1
                                  ? 0
                                  : segmentSpacing,
                            ),
                            child: SizedBox(
                              width: segmentWidth,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(11),
                                  overlayColor:
                                      const WidgetStatePropertyAll<Color>(
                                        Colors.transparent,
                                      ),
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: entry.value.onTap,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      curve: Curves.easeOutCubic,
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
                                      child: Text(entry.value.label),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
