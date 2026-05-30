import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
    final typography = width < 600
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onSurface);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: surface.canvas.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        indicatorColor: surface.canvasSoft2,
        height: width < 600 ? 70 : 76,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(typography.caption),
        selectedIndex: currentIndex,
        onDestinationSelected: notifier.selectTab,
        destinations: ShellTab.values.map((tab) {
          final selected = tab.index == currentIndex;
          return NavigationDestination(
            icon: Icon(selected ? tab.activeIcon : tab.icon),
            label: tab.label(l10n),
          );
        }).toList(),
      ),
    );
  }
}
