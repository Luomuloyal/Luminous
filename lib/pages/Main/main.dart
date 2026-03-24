import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_ornaments.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/pages/Album/album.dart';
import 'package:luminous/pages/Drug/drug.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/pages/Mine/mine.dart';
import 'package:luminous/stores/ornament_controller.dart';

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
  const MainPage({super.key});

  /// 创建底部 Tab 主页面对应的状态对象。
  @override
  State<MainPage> createState() => _MainPageState();
}

/// 底部 Tab 容器状态对象。
///
/// 这里只维护当前选中的 Tab 下标，不承载任何业务数据，业务状态由各子页面自己保存。
class _MainPageState extends State<MainPage> {
  /// 底部导航栏配置列表。
  final List<_MainTabItem> _tablist = const [
    _MainTabItem(
      icon: 'lib/assets/home.png',
      activeIcon: 'lib/assets/home-full.png',
      text: '主页',
      color: Color(0xFF0EA5E9),
    ),
    _MainTabItem(
      icon: 'lib/assets/drug.png',
      activeIcon: 'lib/assets/drug-full.png',
      text: '药品',
      color: Color(0xFF10B981),
    ),
    _MainTabItem(
      icon: 'lib/assets/picture.png',
      activeIcon: 'lib/assets/picture-full.png',
      text: '相册',
      color: Color(0xFFF59E0B),
    ),
    _MainTabItem(
      icon: 'lib/assets/mine.png',
      activeIcon: 'lib/assets/mine-full.png',
      text: '我的',
      color: Color(0xFFE77AA6),
    ),
  ];

  /// 与底部 Tab 一一对应的页面实例列表。
  static const List<Widget> _pages = [
    HomeView(),
    DrugView(),
    AlbumView(),
    MineView(),
  ];

  /// 已经真正挂载过的 Tab 下标。
  final Set<int> _loadedIndexes = <int>{0};

  /// 当前选中的底部 Tab 下标。
  int _currentIndex = 0;

  Widget _buildTabIcon({required String assetPath, required Color color}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(assetPath, width: 30, height: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _tablist[_currentIndex].color;
    final secondaryColor =
        _tablist[(_currentIndex + 1) % _tablist.length].color;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tabBarBackground = isDark
        ? const Color(0xFF111C2E)
        : AppUiConstants.TAB_BAR_BACKGROUND;
    final inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : AppUiConstants.TAB_INACTIVE;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AppCanvas(
        accentColor: currentColor,
        secondaryAccentColor: secondaryColor,
        child: IndexedStack(
          index: _currentIndex,
          children: List<Widget>.generate(
            _tablist.length,
            (index) => _loadedIndexes.contains(index)
                ? _pages[index]
                : const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _MainBottomBar(
          items: _tablist,
          currentIndex: _currentIndex,
          backgroundColor: tabBarBackground,
          inactiveColor: inactiveColor,
          buildIcon: _buildTabIcon,
          onTap: (index) {
            setState(() {
              _loadedIndexes.add(index);
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({
    required this.items,
    required this.currentIndex,
    required this.backgroundColor,
    required this.inactiveColor,
    required this.buildIcon,
    required this.onTap,
  });

  final List<_MainTabItem> items;
  final int currentIndex;
  final Color backgroundColor;
  final Color inactiveColor;
  final Widget Function({required String assetPath, required Color color})
  buildIcon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ornamentController = Get.find<OrnamentController>();
    final currentColor = items[currentIndex].color;
    final secondaryColor = items[(currentIndex + 1) % items.length].color;

    return Obx(() {
      ornamentController.revision.value;
      final layout =
          ornamentController.resolveLayout(
            ornamentKey: 'main.bottom-bar',
            family: AppOrnamentFamily.section,
          ) ??
          kSectionCanopyLayout;

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
          ),
          child: Stack(
            children: [
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
                          secondaryColor.withValues(
                            alpha: isDark ? 0.13 : 0.095,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Stack(
                      key: ValueKey<String>(layout.id),
                      fit: StackFit.expand,
                      children: _buildBottomBarOrnaments(
                        layout: layout,
                        accentColor: currentColor,
                        secondaryColor: secondaryColor,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  children: List<Widget>.generate(items.length, (index) {
                    final item = items[index];
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
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? item.color.withValues(
                                      alpha: isDark ? 0.24 : 0.16,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildIcon(
                                  assetPath: selected
                                      ? item.activeIcon
                                      : item.icon,
                                  color: selected ? item.color : inactiveColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.text,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    color: selected
                                        ? item.color
                                        : inactiveColor,
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
    });
  }
}

List<Widget> _buildBottomBarOrnaments({
  required AppOrnamentLayout layout,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
}) {
  return layout.nodes
      .map(
        (node) => _BottomBarOrnamentNode(
          node: node,
          color: _bottomBarNodeColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
          borderColor: _bottomBarNodeBorderColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
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
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final alpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.20 : 0.13,
    AppOrnamentTone.medium => isDark ? 0.15 : 0.10,
    AppOrnamentTone.light => isDark ? 0.10 : 0.07,
    AppOrnamentTone.spark => isDark ? 0.23 : 0.16,
  };
  return base.withValues(alpha: alpha);
}

Color _bottomBarNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final alpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.24 : 0.16,
    AppOrnamentTone.medium => isDark ? 0.20 : 0.13,
    AppOrnamentTone.light => isDark ? 0.16 : 0.10,
    AppOrnamentTone.spark => isDark ? 0.28 : 0.18,
  };
  return base.withValues(alpha: alpha);
}

class _BottomBarOrnamentNode extends StatelessWidget {
  const _BottomBarOrnamentNode({
    required this.node,
    required this.color,
    required this.borderColor,
  });

  final AppOrnamentNodeSpec node;
  final Color color;
  final Color borderColor;

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
          node.offset.dx * _offsetScale,
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
    required this.color,
  });

  final String icon;
  final String activeIcon;
  final String text;
  final Color color;
}
