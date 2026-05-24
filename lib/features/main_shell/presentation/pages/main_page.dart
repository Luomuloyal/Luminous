part of '../main_shell.dart';

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
    HomePage(),
    DrugView(),
    AlbumView(),
    MineView(),
  ];

  /// 需要在后台预热的二级页面列表。
  static const List<Widget> _secondaryPages = [
    SearchPage(),
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
