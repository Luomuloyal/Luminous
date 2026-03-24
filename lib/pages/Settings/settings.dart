import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';

/// 设置页。
///
/// 当前先放两项：
/// - 暗黑模式；
/// - 退出登录。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final userController = Get.find<UserController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('设置')),
      body: AppCanvas(
        accentColor: scheme.secondary,
        secondaryAccentColor: scheme.primary,
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SettingsSectionCard(
                title: '显示',
                accentColor: const Color(0xFFE6DAFF),
                secondaryColor: const Color(0xFFDDEBFF),
                children: [
                  _DisplayPreferencesSection(themeController: themeController),
                ],
              ),
              const SizedBox(height: 12),
              _SettingsSectionCard(
                title: '账号',
                accentColor: const Color(0xFFF8E5B2),
                secondaryColor: const Color(0xFFFFE3EC),
                children: [
                  Obx(() {
                    final loggedIn = userController.isLoggedIn;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      enabled: loggedIn,
                      leading: Icon(
                        Icons.logout_rounded,
                        color: loggedIn
                            ? scheme.error
                            : scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      title: const Text(
                        '退出登录',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        loggedIn ? '清除当前设备上的登录状态' : '当前还没有登录账号',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: loggedIn
                          ? Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.onSurfaceVariant,
                            )
                          : null,
                      onTap: loggedIn
                          ? () => _confirmLogout(context, userController)
                          : () {
                              ToastUtils.instance.show(context, '当前未登录');
                            },
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    UserController userController,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出当前账号吗？本地登录状态会被清除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await userController.logout();
    if (context.mounted) {
      ToastUtils.instance.show(context, '已退出登录');
      Navigator.maybePop(context);
    }
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.children,
    required this.accentColor,
    required this.secondaryColor,
  });

  final String title;
  final List<Widget> children;
  final Color accentColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DisplayPreferencesSection extends StatelessWidget {
  const _DisplayPreferencesSection({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() {
      final preference = themeController.themePreference.value;
      final selectedStyle = themeController.themeStyle.value;
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                preference == AppThemeModePreference.system
                    ? Icons.brightness_auto_rounded
                    : (resolvedDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded),
                color: scheme.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '主题模式',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeModePreference.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(_themeModeLabel(item)),
                    avatar: Icon(
                      _themeModeIcon(item),
                      size: 18,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    selected: preference == item,
                    onSelected: (_) {
                      themeController.setThemePreference(item);
                    },
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                    side: BorderSide(
                      color: preference == item
                          ? scheme.primary.withValues(alpha: 0.28)
                          : scheme.outline,
                    ),
                    backgroundColor: theme.cardColor.withValues(alpha: 0.45),
                    selectedColor: scheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            preference == AppThemeModePreference.system
                ? '当前跟随系统，系统正在使用${resolvedDark ? '深色' : '浅色'}外观'
                : '当前固定为${resolvedDark ? '深色' : '浅色'}外观',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.palette_outlined, color: scheme.secondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '主题风格',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 360;
              if (vertical) {
                return Column(
                  children: AppThemeStyle.values
                      .map(
                        (style) => Padding(
                          padding: EdgeInsets.only(
                            bottom: style == AppThemeStyle.softGlow ? 10 : 0,
                          ),
                          child: _ThemeStyleCard(
                            style: style,
                            selected: selectedStyle == style,
                            onTap: () => themeController.setThemeStyle(style),
                          ),
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                children: AppThemeStyle.values
                    .map(
                      (style) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: style == AppThemeStyle.softGlow ? 10 : 0,
                          ),
                          child: _ThemeStyleCard(
                            style: style,
                            selected: selectedStyle == style,
                            onTap: () => themeController.setThemeStyle(style),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }
}

class _ThemeStyleCard extends StatelessWidget {
  const _ThemeStyleCard({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppThemeStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preview = _themeStylePreview(
      style,
      theme.brightness == Brightness.dark,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : theme.cardColor.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.34)
                : scheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: preview),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: preview
                        .map(
                          (color) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.92),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _themeStyleLabel(style),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _themeStyleSubtitle(style),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _themeModeLabel(AppThemeModePreference preference) {
  switch (preference) {
    case AppThemeModePreference.system:
      return '跟随系统';
    case AppThemeModePreference.light:
      return '浅色';
    case AppThemeModePreference.dark:
      return '深色';
  }
}

IconData _themeModeIcon(AppThemeModePreference preference) {
  switch (preference) {
    case AppThemeModePreference.system:
      return Icons.brightness_auto_rounded;
    case AppThemeModePreference.light:
      return Icons.light_mode_rounded;
    case AppThemeModePreference.dark:
      return Icons.dark_mode_rounded;
  }
}

String _themeStyleLabel(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return '柔光';
    case AppThemeStyle.moonMist:
      return '月雾';
  }
}

String _themeStyleSubtitle(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return '延续现在这套淡黄、淡紫、淡蓝的柔和气质';
    case AppThemeStyle.moonMist:
      return '更冷静一点，偏月光蓝和雾紫，夜间更安静';
  }
}

List<Color> _themeStylePreview(AppThemeStyle style, bool isDark) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return isDark
          ? const [Color(0xFF112134), Color(0xFF1D3150), Color(0xFF4F5C8C)]
          : const [Color(0xFFEAF7FF), Color(0xFFF9EFD4), Color(0xFFEDE5FF)];
    case AppThemeStyle.moonMist:
      return isDark
          ? const [Color(0xFF0E1827), Color(0xFF17304B), Color(0xFF5B5E91)]
          : const [Color(0xFFEAF6FF), Color(0xFFEFF3FF), Color(0xFFE6E1FF)];
  }
}
