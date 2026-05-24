import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_ornaments.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/settings/presentation/settings.dart';
import 'package:luminous/pages/Album/album.dart';
import 'package:luminous/pages/Drug/drug.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Main/controllers/main_controller.dart';
import 'package:luminous/pages/Mine/mine.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/pages/Settings/profile_settings.dart';

// 主页面：底部 Tab 容器
//
// 注意：
// - 这里用 IndexedStack 保持每个 Tab 的状态（避免切换时重复 initState）
// - 不要在这里再包 SafeArea（单页自己负责），否则容易出现双重 padding
/// 主页面底部 Tab 容器。
///
/// 只负责一级页面切换与状态保活，不承担各业务页的数据逻辑。
class MainPage extends StatefulWidget {
  /// 创建主页面 Tab 容器组件。
  const MainPage({super.key, this.controller});

  final MainController? controller;

  /// 创建底部 Tab 主页面对应的状态对象。
  @override
  State<MainPage> createState() => _MainPageState();
}

/// 底部 Tab 容器状态对象。
///
/// 这里只维护当前选中的 Tab 下标，不承载任何业务数据，业务状态由各子页面自己保存。
class _MainPageState extends State<MainPage> {
  late final MainController _controller =
      widget.controller ??
      MainController(
        pageCount: _pages.length,
        secondaryPageCount: _secondaryPages.length,
      );

  /// 底部导航栏配置列表。
  List<_MainTabItem> _tablist(AppLocalizations? l10n) {
    return [
      _MainTabItem(
        icon: 'lib/assets/home.png',
        activeIcon: 'lib/assets/home-full.png',
        text: l10n?.mainTabHome ?? '主页',
      ),
      _MainTabItem(
        icon: 'lib/assets/drug.png',
        activeIcon: 'lib/assets/drug-full.png',
        text: l10n?.mainTabDrug ?? '药品',
      ),
      _MainTabItem(
        icon: 'lib/assets/picture.png',
        activeIcon: 'lib/assets/picture-full.png',
        text: l10n?.mainTabAlbum ?? '相册',
      ),
      _MainTabItem(
        icon: 'lib/assets/mine.png',
        activeIcon: 'lib/assets/mine-full.png',
        text: l10n?.mainTabMine ?? '我的',
      ),
    ];
  }

  /// 与底部 Tab 一一对应的页面实例列表。
  static const List<Widget> _pages = [
    HomeView(),
    DrugView(),
    AlbumView(),
    MineView(),
  ];

  /// 需要在后台预热的二级页面列表。
  static const List<Widget> _secondaryPages = [
    SearchView(),
    SafetyAssistPage(),
    SettingsPage(),
    ProfileSettingsPage(),
  ];

  Widget _buildSecondaryPreloadLayer() {
    return Offstage(
      offstage: true,
      child: TickerMode(
        enabled: false,
        child: Stack(
          fit: StackFit.expand,
          children: List<Widget>.generate(_secondaryPages.length, (index) {
            if (!_controller.shouldPreloadSecondary(index)) {
              return const SizedBox.shrink();
            }
            return KeyedSubtree(
              key: ValueKey<String>('secondary-preload-$index'),
              child: _secondaryPages[index],
            );
          }),
        ),
      ),
    );
  }

  List<Color> _resolvedTabColors(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final colors = <Color>[
      scheme.primary,
      Color.lerp(scheme.secondary, scheme.primary, 0.34)!,
      Color.lerp(scheme.tertiary, scheme.secondary, 0.26)!,
      Color.lerp(scheme.secondary, scheme.tertiary, 0.58)!,
    ];

    return colors
        .map((color) => isDark ? Color.lerp(color, Colors.white, 0.08)! : color)
        .toList();
  }

  Widget _buildTabIcon({required String assetPath, required Color color}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(assetPath, width: 30, height: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: _controller,
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        final tablist = _tablist(l10n);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final tabColors = _resolvedTabColors(theme);
        final currentColor = tabColors[controller.currentIndex];
        final secondaryColor =
            tabColors[(controller.currentIndex + 1) % tabColors.length];
        final tabBarBackground = Color.alphaBlend(
          (isDark ? secondaryColor : currentColor).withValues(
            alpha: isDark ? 0.08 : 0.04,
          ),
          theme.cardTheme.color ?? theme.colorScheme.surface,
        );
        final bottomBedColor = Color.alphaBlend(
          currentColor.withValues(alpha: isDark ? 0.12 : 0.055),
          theme.scaffoldBackgroundColor,
        );
        final systemNavigationBarColor = Color.alphaBlend(
          secondaryColor.withValues(alpha: isDark ? 0.12 : 0.05),
          bottomBedColor,
        );
        final inactiveColor = isDark
            ? const Color(0xFF94A3B8)
            : AppUiConstants.TAB_INACTIVE;
        final overlayStyle =
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: systemNavigationBarColor,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            extendBody: true,
            body: AppCanvas(
              accentColor: currentColor,
              secondaryAccentColor: secondaryColor,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IndexedStack(
                    index: controller.currentIndex,
                    children: List<Widget>.generate(
                      tablist.length,
                      (index) => controller.shouldLoadTab(index)
                          ? _pages[index]
                          : const SizedBox.shrink(),
                    ),
                  ),
                  _buildSecondaryPreloadLayer(),
                ],
              ),
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bottomBedColor.withValues(alpha: isDark ? 0.92 : 0.90),
                    systemNavigationBarColor,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: _MainBottomBar(
                  items: tablist,
                  itemColors: tabColors,
                  currentIndex: controller.currentIndex,
                  backgroundColor: tabBarBackground,
                  inactiveColor: inactiveColor,
                  buildIcon: _buildTabIcon,
                  onTap: controller.selectTab,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({
    required this.items,
    required this.itemColors,
    required this.currentIndex,
    required this.backgroundColor,
    required this.inactiveColor,
    required this.buildIcon,
    required this.onTap,
  });

  final List<_MainTabItem> items;
  final List<Color> itemColors;
  final int currentIndex;
  final Color backgroundColor;
  final Color inactiveColor;
  final Widget Function({required String assetPath, required Color color})
  buildIcon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentColor = itemColors[currentIndex];
    final secondaryColor = itemColors[(currentIndex + 1) % itemColors.length];
    final tabCenterShift = switch (currentIndex) {
      0 => 56.0,
      1 => 22.0,
      2 => -22.0,
      _ => -56.0,
    };
    if (maybeOrnamentContainerOf(context) == null) {
      return _buildBottomBar(
        context,
        isDark: isDark,
        currentColor: currentColor,
        secondaryColor: secondaryColor,
        tabCenterShift: tabCenterShift,
        visibilityFactor: 1,
        layout: kSectionCanopyLayout,
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final ornamentState = ref.watch(ornamentProvider);
        final ornamentNotifier = ref.read(ornamentProvider.notifier);
        final visibilityFactor = ornamentState.visibilityFactor;
        final layout =
            ornamentNotifier.resolveLayout(
              ornamentKey: 'main.bottom-bar',
              family: AppOrnamentFamily.section,
            ) ??
            kSectionCanopyLayout;

        return _buildBottomBar(
          context,
          isDark: isDark,
          currentColor: currentColor,
          secondaryColor: secondaryColor,
          tabCenterShift: tabCenterShift,
          visibilityFactor: visibilityFactor,
          layout: layout,
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context, {
    required bool isDark,
    required Color currentColor,
    required Color secondaryColor,
    required double tabCenterShift,
    required double visibilityFactor,
    required AppOrnamentLayout layout,
  }) {
    final showOrnaments = visibilityFactor > 0;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                currentColor.withValues(alpha: isDark ? 0.18 : 0.11),
                backgroundColor,
              ),
              Color.alphaBlend(
                secondaryColor.withValues(alpha: isDark ? 0.14 : 0.085),
                backgroundColor,
              ),
            ],
          ),
          border: Border.all(
            color: Color.alphaBlend(
              currentColor.withValues(alpha: isDark ? 0.18 : 0.09),
              isDark ? const Color(0xFF24324A) : const Color(0xFFE4EAF3),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.22, 0.72],
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.04 : 0.12),
                        Colors.white.withValues(alpha: isDark ? 0.015 : 0.038),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: RadialGradient(
                      center: const Alignment(-0.72, -0.14),
                      radius: 0.9,
                      colors: [
                        currentColor.withValues(alpha: isDark ? 0.16 : 0.11),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: RadialGradient(
                      center: const Alignment(0.82, 0.18),
                      radius: 0.96,
                      colors: [
                        secondaryColor.withValues(alpha: isDark ? 0.13 : 0.095),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showOrnaments)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    key: ValueKey<String>('${layout.id}-$currentIndex'),
                    fit: StackFit.expand,
                    children: _buildBottomBarOrnaments(
                      layout: layout,
                      accentColor: currentColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                      visibilityFactor: visibilityFactor,
                      globalShiftX: tabCenterShift,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: List<Widget>.generate(items.length, (index) {
                  final item = items[index];
                  final itemColor = itemColors[index];
                  final selected = index == currentIndex;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      itemColor.withValues(
                                        alpha: isDark ? 0.26 : 0.19,
                                      ),
                                      itemColor.withValues(
                                        alpha: isDark ? 0.16 : 0.11,
                                      ),
                                    ],
                                  )
                                : null,
                            color: selected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? itemColor.withValues(
                                      alpha: isDark ? 0.24 : 0.14,
                                    )
                                  : Colors.transparent,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: itemColor.withValues(
                                        alpha: isDark ? 0.16 : 0.12,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildIcon(
                                assetPath: selected
                                    ? item.activeIcon
                                    : item.icon,
                                color: selected ? itemColor : inactiveColor,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: selected ? itemColor : inactiveColor,
                                  height: 1.1,
                                  leadingDistribution:
                                      TextLeadingDistribution.even,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildBottomBarOrnaments({
  required AppOrnamentLayout layout,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
  required double globalShiftX,
}) {
  return layout.nodes
      .map(
        (node) => _BottomBarOrnamentNode(
          node: node,
          globalShiftX: globalShiftX,
          color: _bottomBarNodeColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
            visibilityFactor: visibilityFactor,
          ),
          borderColor: _bottomBarNodeBorderColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
            visibilityFactor: visibilityFactor,
          ),
        ),
      )
      .toList();
}

Color _bottomBarNodeColor({
  required AppOrnamentNodeSpec node,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.20 : 0.13,
    AppOrnamentTone.medium => isDark ? 0.15 : 0.10,
    AppOrnamentTone.light => isDark ? 0.10 : 0.07,
    AppOrnamentTone.spark => isDark ? 0.23 : 0.16,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

Color _bottomBarNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.24 : 0.16,
    AppOrnamentTone.medium => isDark ? 0.20 : 0.13,
    AppOrnamentTone.light => isDark ? 0.16 : 0.10,
    AppOrnamentTone.spark => isDark ? 0.28 : 0.18,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

class _BottomBarOrnamentNode extends StatelessWidget {
  const _BottomBarOrnamentNode({
    required this.node,
    required this.color,
    required this.borderColor,
    required this.globalShiftX,
  });

  final AppOrnamentNodeSpec node;
  final Color color;
  final Color borderColor;
  final double globalShiftX;

  static const double _sizeScale = 0.58;
  static const double _offsetScale = 0.26;

  @override
  Widget build(BuildContext context) {
    final width = node.width * _sizeScale;
    final height = node.height * _sizeScale;
    final child = switch (node.shape) {
      AppOrnamentNodeShape.orb => _BottomBarOrb(size: width, color: color),
      AppOrnamentNodeShape.pill => _BottomBarPill(
        width: width,
        height: height,
        color: color,
      ),
      AppOrnamentNodeShape.ring => _BottomBarRing(
        size: width,
        color: color,
        borderColor: borderColor,
      ),
    };

    return Align(
      alignment: node.alignment,
      child: Transform.translate(
        offset: Offset(
          (node.offset.dx * _offsetScale) + globalShiftX,
          node.offset.dy * _offsetScale,
        ),
        child: Transform.rotate(angle: node.rotation, child: child),
      ),
    );
  }
}

class _BottomBarOrb extends StatelessWidget {
  const _BottomBarOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BottomBarPill extends StatelessWidget {
  const _BottomBarPill({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomBarRing extends StatelessWidget {
  const _BottomBarRing({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1.2),
      ),
    );
  }
}

class _MainTabItem {
  const _MainTabItem({
    required this.icon,
    required this.activeIcon,
    required this.text,
  });

  final String icon;
  final String activeIcon;
  final String text;
}
