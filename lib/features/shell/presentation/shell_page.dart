import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/responsive_content_frame.dart';
import 'package:luminous/core/widgets/placeholder_page.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  static const _pages = <Widget>[
    TodayPage(),
    PlaceholderPage(label: '记录'),
    PlaceholderPage(label: '用药'),
    PlaceholderPage(label: '我的'),
    PlaceholderPage(label: '更多'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellProvider).currentIndex;
    final notifier = ref.read(shellProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
    final typography = width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    final destinations = ShellTab.values
        .map(
          (tab) => NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: tab.label(l10n),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: isDesktop
          ? SafeArea(
              child: ResponsiveContentFrame(
                expand: true,
                child: Row(
                  children: [
                    NavigationRail(
                      backgroundColor: surface.canvas,
                      selectedIndex: currentIndex,
                      onDestinationSelected: notifier.selectTab,
                      labelType: NavigationRailLabelType.all,
                      indicatorColor: surface.canvasSoft2,
                      groupAlignment: -0.8,
                      destinations: destinations
                          .map(
                            (item) => NavigationRailDestination(
                              icon: item.icon,
                              selectedIcon: item.selectedIcon,
                              label: Text(item.label),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    VerticalDivider(color: surface.hairline, width: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.lg,
                        ),
                        child: IndexedStack(
                          index: currentIndex,
                          children: _pages,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              backgroundColor: surface.canvas.withValues(alpha: 0.96),
              surfaceTintColor: Colors.transparent,
              indicatorColor: surface.canvasSoft2,
              height: width < 600 ? 70 : 76,
              labelTextStyle: WidgetStatePropertyAll<TextStyle>(
                typography.caption,
              ),
              selectedIndex: currentIndex,
              onDestinationSelected: notifier.selectTab,
              destinations: destinations,
            ),
    );
  }
}
