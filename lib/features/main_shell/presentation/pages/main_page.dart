part of '../main_shell.dart';

// 主页面：底部 Tab 容器
//
// 注意：
// - 这里用 IndexedStack 保持每个 Tab 的状态（避免切换时重复 initState）
// - 不要在这里再包 SafeArea（单页自己负责），否则容易出现双重 padding

/// 主页面底部 Tab 容器。
///
/// 只负责一级页面切换与状态保活，不承担各业务页的数据逻辑。
/// 状态由 [mainShellProvider]（Riverpod）管理，替代旧 GetX `MainController`。
class MainPage extends ConsumerWidget {
  /// 创建主页面 Tab 容器组件。
  const MainPage({super.key});

  /// 与底部 Tab 一一对应的页面实例列表。
  static const List<Widget> _pages = [
    HomePage(),
    DrugPage(),
    AlbumPage(),
    MinePage(),
  ];

  /// 需要在后台预热的二级页面列表。
  static const List<Widget> _secondaryPages = [
    SearchPage(),
    SafetyAssistPage(),
    SettingsPage(),
    ProfileSettingsPage(),
  ];

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

  Widget _buildSecondaryPreloadLayer(Set<int> preloadedIndexes) {
    return Offstage(
      offstage: true,
      child: TickerMode(
        enabled: false,
        child: Stack(
          fit: StackFit.expand,
          children: List<Widget>.generate(_secondaryPages.length, (index) {
            if (!preloadedIndexes.contains(index)) {
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
        .map(
          (color) =>
              isDark ? Color.lerp(color, Colors.white, 0.08)! : color,
        )
        .toList();
  }

  Widget _buildTabIcon({required String assetPath, required Color color}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(assetPath, width: 30, height: 30),
    );
  }

  Widget _buildPageStack(
    MainShellState shellState,
    List<_MainTabItem> tabs,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IndexedStack(
          index: shellState.currentIndex,
          children: List<Widget>.generate(
            tabs.length,
            (index) => shellState.loadedIndexes.contains(index)
                ? _pages[index]
                : const SizedBox.shrink(),
          ),
        ),
        _buildSecondaryPreloadLayer(shellState.preloadedSecondaryIndexes),
      ],
    );
  }

  // ignore: long-method
  Widget _buildCompactBottomNavigation({
    required ThemeData theme,
    required bool isDark,
    required List<_MainTabItem> tablist,
    required List<Color> tabColors,
    required Color currentColor,
    required Color tabBarBackground,
    required Color systemNavigationBarColor,
    required int currentIndex,
    required Color inactiveColor,
    required void Function(int) onSelectTab,
  }) {
    final bottomBedColor = Color.alphaBlend(
      currentColor.withValues(alpha: isDark ? 0.12 : 0.055),
      theme.scaffoldBackgroundColor,
    );
    return DecoratedBox(
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
          currentIndex: currentIndex,
          backgroundColor: tabBarBackground,
          inactiveColor: inactiveColor,
          buildIcon: _buildTabIcon,
          onTap: onSelectTab,
        ),
      ),
    );
  }

  // ignore: long-method
  Widget _buildWideNavigationPane({
    required AppWindowClass windowClass,
    required List<_MainTabItem> tablist,
    required List<Color> tabColors,
    required Color backgroundColor,
    required int currentIndex,
    required Color inactiveColor,
    required void Function(int) onSelectTab,
  }) {
    return _MainNavigationRail(
      items: tablist,
      itemColors: tabColors,
      currentIndex: currentIndex,
      backgroundColor: backgroundColor,
      inactiveColor: inactiveColor,
      extended: windowClass.usesExtendedNavigation,
      buildIcon: _buildTabIcon,
      onTap: onSelectTab,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shellState = ref.watch(mainShellProvider);
    final notifier = ref.read(mainShellProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);
        final l10n = AppLocalizations.of(context);
        final tablist = _tablist(l10n);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final tabColors = _resolvedTabColors(theme);
        final currentIndex = shellState.currentIndex;
        final currentColor = tabColors[currentIndex];
        final secondaryColor =
            tabColors[(currentIndex + 1) % tabColors.length];
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
        final compactSystemNavigationBarColor = Color.alphaBlend(
          secondaryColor.withValues(alpha: isDark ? 0.12 : 0.05),
          bottomBedColor,
        );
        final systemNavigationBarColor = windowClass.usesBottomNavigation
            ? compactSystemNavigationBarColor
            : theme.scaffoldBackgroundColor;
        final inactiveColor = isDark
            ? const Color(0xFF94A3B8)
            : AppUiConstants.TAB_INACTIVE;
        final overlayStyle =
            (isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: systemNavigationBarColor,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness:
                      isDark ? Brightness.dark : Brightness.light,
                  systemNavigationBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: AppAdaptiveScaffold(
            windowClass: windowClass,
            backgroundColor: theme.scaffoldBackgroundColor,
            compactBottomNavigationBar: _buildCompactBottomNavigation(
              theme: theme,
              isDark: isDark,
              tablist: tablist,
              tabColors: tabColors,
              currentColor: currentColor,
              tabBarBackground: tabBarBackground,
              systemNavigationBarColor: compactSystemNavigationBarColor,
              currentIndex: currentIndex,
              inactiveColor: inactiveColor,
              onSelectTab: notifier.selectTab,
            ),
            wideNavigationPane: _buildWideNavigationPane(
              windowClass: windowClass,
              tablist: tablist,
              tabColors: tabColors,
              backgroundColor: theme.scaffoldBackgroundColor,
              currentIndex: currentIndex,
              inactiveColor: inactiveColor,
              onSelectTab: notifier.selectTab,
            ),
            body: AppCanvas(
              accentColor: currentColor,
              secondaryAccentColor: secondaryColor,
              child: _buildPageStack(shellState, tablist),
            ),
          ),
        );
      },
    );
  }
}
