part of '../main_shell.dart';

class _MainNavigationRail extends StatelessWidget {
  const _MainNavigationRail({
    required this.items,
    required this.itemColors,
    required this.currentIndex,
    required this.backgroundColor,
    required this.inactiveColor,
    required this.extended,
    required this.buildIcon,
    required this.onTap,
  });

  final List<_MainTabItem> items;
  final List<Color> itemColors;
  final int currentIndex;
  final Color backgroundColor;
  final Color inactiveColor;
  final bool extended;
  final Widget Function({required String assetPath, required Color color})
  buildIcon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentColor = itemColors[currentIndex];
    final width = extended ? 228.0 : 92.0;
    final railBackground = Color.alphaBlend(
      currentColor.withValues(alpha: isDark ? 0.10 : 0.055),
      backgroundColor,
    );

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: railBackground,
          border: Border(
            right: BorderSide(
              color: Color.alphaBlend(
                currentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                theme.colorScheme.outline,
              ),
            ),
          ),
        ),
        child: SafeArea(
          right: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              selectedIndex: currentIndex,
              extended: extended,
              minExtendedWidth: width,
              minWidth: width,
              groupAlignment: -0.82,
              labelType: extended ? null : NavigationRailLabelType.all,
              selectedLabelTextStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: currentColor,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: inactiveColor,
              ),
              indicatorColor: currentColor.withValues(
                alpha: isDark ? 0.24 : 0.14,
              ),
              onDestinationSelected: onTap,
              destinations: List<NavigationRailDestination>.generate(
                items.length,
                (index) {
                  final item = items[index];
                  final itemColor = itemColors[index];
                  return NavigationRailDestination(
                    icon: buildIcon(assetPath: item.icon, color: inactiveColor),
                    selectedIcon: buildIcon(
                      assetPath: item.activeIcon,
                      color: itemColor,
                    ),
                    label: Text(item.text),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
