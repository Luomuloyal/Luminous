part of '../main_shell.dart';

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
