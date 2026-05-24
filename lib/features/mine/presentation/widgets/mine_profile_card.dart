import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 我的页 Profile 卡片。
class MineProfileCard extends StatelessWidget {
  const MineProfileCard({
    super.key,
    required this.palette,
    required this.user,
    required this.onTapProfile,
    required this.onTapAction,
    this.loggedInActionLabel,
  });

  final SoftBannerPalette palette;
  final UserSafe? user;
  final VoidCallback onTapProfile;
  final VoidCallback onTapAction;
  final String? loggedInActionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = user?.hasData ?? false;
    final displayUser = user;
    ImageProvider<Object>? avatarProvider;
    if (isLoggedIn) {
      final rawAvatar = displayUser?.avatar.trim() ?? '';
      if (rawAvatar.startsWith('http')) {
        avatarProvider = NetworkImage(rawAvatar);
      } else if (rawAvatar.startsWith('data:image/')) {
        final commaIndex = rawAvatar.indexOf(',');
        if (commaIndex > 0 && commaIndex < rawAvatar.length - 1) {
          try {
            final bytes = base64Decode(rawAvatar.substring(commaIndex + 1));
            avatarProvider = MemoryImage(bytes);
          } catch (_) {
            avatarProvider = null;
          }
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = isCompactLayoutWidth(constraints.maxWidth);

        return SoftBannerCard(
          palette: palette,
          ornamentKey: 'mine.profile',
          padding: EdgeInsets.all(compact ? 16 : 18),
          builder: (context, theme) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onTapProfile,
                      child: Container(
                        width: compact ? 52 : 56,
                        height: compact ? 52 : 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.surfaceColor,
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: ClipOval(
                          child: avatarProvider != null
                              ? Image(
                                  image: avatarProvider,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.verified_user_rounded,
                                      color: theme.accentColor,
                                      size: compact ? 26 : 28,
                                    );
                                  },
                                )
                              : Icon(
                                  isLoggedIn
                                      ? Icons.verified_user_rounded
                                      : Icons.person_outline_rounded,
                                  color: theme.accentColor,
                                  size: compact ? 26 : 28,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 12 : 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: onTapProfile,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn
                                  ? displayUser!.displayTitle
                                  : (l10n?.mineProfileLoginNow ?? '立即登录'),
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: compact ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoggedIn
                                  ? displayUser!.displaySubtitle
                                  : (l10n?.mineProfileLoginHint ??
                                        '登录后可管理账号信息与同步个人数据'),
                              style: TextStyle(
                                color: theme.secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    FilledButton(
                      onPressed: onTapAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.surfaceColor,
                        foregroundColor: theme.surfaceTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: Size(compact ? 72 : 88, compact ? 36 : 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 14 : 16,
                        ),
                      ),
                      child: Text(
                        isLoggedIn
                            ? (loggedInActionLabel ??
                                  l10n?.mineLoggedInActionLabel ??
                                  '设置')
                            : (l10n?.mineProfileLoginAction ?? '去登录'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TintedStatusChip(
                      icon: isLoggedIn
                          ? Icons.cloud_done_rounded
                          : Icons.phone_android_rounded,
                      text: isLoggedIn
                          ? (l10n?.mineProfileChipAccountConnected ?? '账号已连接')
                          : (l10n?.mineProfileChipLocalOnly ?? '当前本地体验'),
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                    TintedStatusChip(
                      icon: Icons.image_outlined,
                      text: l10n?.mineProfileChipImageLocalOnly ?? '原图仅本机保存',
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                    TintedStatusChip(
                      icon: Icons.auto_awesome_rounded,
                      text: isLoggedIn
                          ? (l10n?.mineProfileChipSyncEnabled ?? '可同步轻量结果')
                          : (l10n?.mineProfileChipSyncAfterLogin ?? '登录后开启轻同步'),
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
