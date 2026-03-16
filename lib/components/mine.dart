import 'package:flutter/material.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/mine.dart';

/// 我的页（Mine）可复用 UI 组件集合。
///
/// 页面层负责：
/// - 登录态判断；
/// - 点击事件与路由跳转；
/// 这里负责：
/// - 背景装饰；
/// - ProfileCard、QuickActions、Menu 的布局与样式。
class MineProfileCard extends StatelessWidget {
  const MineProfileCard({
    super.key,
    required this.user,
    required this.onTapProfile,
    required this.onTapAction,
  });

  /// 当前登录用户（未登录时为 null）。
  final UserSafe? user;

  /// 点击头像/昵称区域回调。
  final VoidCallback onTapProfile;

  /// 点击右侧按钮回调（登录时为“退出登录”，未登录时为“去登录”）。
  final VoidCallback onTapAction;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user?.hasData ?? false;
    final displayUser = user;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapProfile,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
              ),
              child: Icon(
                isLoggedIn
                    ? Icons.verified_user_rounded
                    : Icons.person_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onTapProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? displayUser!.displayTitle : '立即登录',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? displayUser!.displaySubtitle
                        : '登录后可管理账号信息与同步个人数据',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onTapAction,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              minimumSize: const Size(88, 40),
            ),
            child: Text(isLoggedIn ? '退出登录' : '去登录'),
          ),
        ],
      ),
    );
  }
}

/// 我的页主布局组件。
///
/// 该组件是纯布局/展示组件，所有点击逻辑由页面层通过回调注入。
class MinePage extends StatelessWidget {
  const MinePage({
    super.key,
    required this.user,
    required this.quickActions,
    required this.onTapProfile,
    required this.onTapAction,
    required this.onTapQuickAction,
    required this.onTapBrowseHistory,
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  /// 当前用户对象。
  final UserSafe? user;

  /// 快捷入口列表数据。
  final List<MineQuickActionData> quickActions;

  /// 点击 Profile 区域回调。
  final VoidCallback onTapProfile;

  /// 点击 Profile 右侧按钮回调。
  final VoidCallback onTapAction;

  /// 点击某个快捷入口回调（传入其 id）。
  final ValueChanged<String> onTapQuickAction;

  /// 点击“浏览记录”回调。
  final VoidCallback onTapBrowseHistory;

  /// 点击“账号与安全”回调。
  final VoidCallback onTapSecurity;

  /// 点击“关于”回调。
  final VoidCallback onTapAbout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF3F7FB)),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -120,
              child: _MineDecorCircle(
                size: 260,
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -140,
              child: _MineDecorCircle(
                size: 300,
                color: const Color(0xFF14B8A6).withValues(alpha: 0.10),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                MineProfileCard(
                  user: user,
                  onTapProfile: onTapProfile,
                  onTapAction: onTapAction,
                ),
                const SizedBox(height: 12),
                MineQuickActionsSection(
                  items: quickActions,
                  onTap: (item) => onTapQuickAction(item.id),
                ),
                const SizedBox(height: 12),
                MineMenuCard(
                  onTapBrowseHistory: onTapBrowseHistory,
                  onTapSecurity: onTapSecurity,
                  onTapAbout: onTapAbout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 快捷入口网格区域。
class MineQuickActionsSection extends StatelessWidget {
  const MineQuickActionsSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  /// 快捷入口数据列表。
  final List<MineQuickActionData> items;

  /// 点击某个入口回调。
  final ValueChanged<MineQuickActionData> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 156,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return MineQuickActionCard(data: item, onTap: () => onTap(item));
      },
    );
  }
}

/// 菜单卡片区域。
class MineMenuCard extends StatelessWidget {
  const MineMenuCard({
    super.key,
    required this.onTapBrowseHistory,
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  /// 点击“浏览记录”回调。
  final VoidCallback onTapBrowseHistory;

  /// 点击“账号与安全”回调。
  final VoidCallback onTapSecurity;

  /// 点击“关于”回调。
  final VoidCallback onTapAbout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _MineMenuItem(
            icon: Icons.history_rounded,
            title: '浏览记录',
            subtitle: '你最近查看过的药品',
            onTap: onTapBrowseHistory,
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _MineMenuItem(
            icon: Icons.shield_rounded,
            title: '账号与安全',
            subtitle: '隐私设置与安全选项',
            onTap: onTapSecurity,
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _MineMenuItem(
            icon: Icons.info_rounded,
            title: '关于 Luminous',
            subtitle: '版本信息与使用说明',
            onTap: onTapAbout,
          ),
        ],
      ),
    );
  }
}

class _MineDecorCircle extends StatelessWidget {
  const _MineDecorCircle({required this.size, required this.color});

  /// 圆形直径。
  final double size;

  /// 圆形颜色（通常带透明度用于背景装饰）。
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

class _MineMenuItem extends StatelessWidget {
  const _MineMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// 左侧图标。
  final IconData icon;

  /// 主标题。
  final String title;

  /// 副标题。
  final String subtitle;

  /// 点击回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
