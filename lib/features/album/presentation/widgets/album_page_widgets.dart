import 'package:flutter/material.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/viewmodels/album.dart';

import 'album_slivers.dart';
import 'album_card.dart';

/// 相册页（Album）的大块 UI 组件集合。
class AlbumPageLayout extends StatelessWidget {
  const AlbumPageLayout({
    super.key,
    required this.headerPalette,
    required this.loading,
    required this.isLoggedIn,
    required this.error,
    required this.entries,
    required this.onRefresh,
    required this.onTapLogin,
    required this.onTapEntry,
  });

  final SoftBannerPalette headerPalette;
  final bool loading;
  final bool isLoggedIn;
  final String? error;
  final List<AlbumEntry> entries;
  final Future<void> Function() onRefresh;
  final VoidCallback onTapLogin;
  final ValueChanged<AlbumEntry> onTapEntry;

  @override
  Widget build(BuildContext context) {
    final originalCount = entries
        .where((entry) => entry.hasOriginalImage)
        .length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AlbumHeaderSliver(
              palette: headerPalette,
              loading: loading,
              entryCount: entries.length,
              originalCount: originalCount,
              isLoggedIn: isLoggedIn,
            ),
            if (!isLoggedIn) AlbumLoginBannerSliver(onTapLogin: onTapLogin),
            if (error != null) AlbumErrorBannerSliver(text: error!),
            if (entries.isEmpty && !loading)
              const AlbumEmptySliver()
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final textScaleFactor = MediaQuery.textScalerOf(
                        context,
                      ).scale(1);
                      final baseCrossAxisCount = width >= 1100
                          ? 4
                          : (width >= 760 ? 3 : 2);
                      final crossAxisCount =
                          textScaleFactor > 1.2 && baseCrossAxisCount > 2
                          ? baseCrossAxisCount - 1
                          : baseCrossAxisCount;
                      final spacing = width >= 760 ? 12.0 : 10.0;
                      final itemWidth =
                          ((width - (spacing * (crossAxisCount - 1))) /
                                  crossAxisCount)
                              .clamp(0.0, double.infinity)
                              .toDouble();

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final entry in entries)
                            SizedBox(
                              width: itemWidth,
                              child: AlbumCard(
                                entry: entry,
                                onTap: () => onTapEntry(entry),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }
}

String pickByCurrentLocale(
  BuildContext context, {
  required String zh,
  required String en,
}) {
  final languageCode = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase();
  return languageCode.startsWith('zh') ? zh : en;
}

Color themeChipColor(BuildContext context, Color accent) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(alpha: theme.brightness == Brightness.dark ? 0.16 : 0.10),
    theme.cardTheme.color ?? theme.colorScheme.surface,
  );
}

String formatAlbumDate(int takenAt) {
  final date = DateTime.fromMillisecondsSinceEpoch(takenAt);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day';
}

class AlbumInfoChip extends StatelessWidget {
  const AlbumInfoChip({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      icon: icon,
      text: text,
      color: foregroundColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      iconSize: 16,
      fontSize: 12.3,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
    );
  }
}

class AlbumOverlayBadge extends StatelessWidget {
  const AlbumOverlayBadge({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      icon: icon,
      text: text,
      color: Colors.white,
      backgroundColor: Colors.black.withValues(alpha: 0.34),
      showBorder: false,
      iconSize: 13,
      iconTextSpacing: 4,
      fontSize: 11.3,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
    );
  }
}
