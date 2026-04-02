import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/mine.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/mine.dart';

// 我的页
//
// 设计要点：
// - 页面只负责交互/登录态判断
// - 具体 UI（背景、卡片布局、QuickActions/Menu）拆到 components/mine.dart
// - QuickAction 数据模型放在 viewmodels/mine.dart
/// 我的页。
///
/// 负责登录态相关交互，以及“提醒/搜索/设置”等个人中心入口。
class MineView extends StatefulWidget {
  /// 创建我的页组件。
  const MineView({super.key});

  /// 创建我的页对应的状态对象。
  @override
  State<MineView> createState() => _MineViewState();
}

/// 我的页状态对象。
///
/// 页面主要围绕登录态工作：同一套 UI 会根据是否登录切换为“去登录”或“查看个人中心”。
class _MineViewState extends State<MineView> {
  /// 全局用户控制器。
  ///
  /// 用于判断登录态、读取用户信息、执行退出登录。
  final UserController _userController = Get.find<UserController>();

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  /// 我的页顶部快捷入口配置列表。
  List<MineQuickActionData> get _quickActions {
    final l10n = _l10n;
    return [
      MineQuickActionData(
        icon: Icons.alarm_rounded,
        title: l10n?.mineQuickReminderTitle ?? '今日提醒',
        subtitle: l10n?.mineQuickReminderSubtitle ?? '查看计划',
        color: const Color(0xFF10B981),
        id: 'reminders',
      ),
      MineQuickActionData(
        icon: Icons.search_rounded,
        title: l10n?.mineQuickSearchTitle ?? '手动搜索',
        subtitle: l10n?.mineQuickSearchSubtitle ?? '药品信息',
        color: const Color(0xFF0EA5E9),
        id: 'search',
      ),
      MineQuickActionData(
        icon: Icons.settings_rounded,
        title: l10n?.mineQuickSettingsTitle ?? '设置',
        subtitle: l10n?.mineQuickSettingsSubtitle ?? '偏好选项',
        color: const Color(0xFF6366F1),
        id: 'settings',
      ),
    ];
  }

  /// 点击 Profile 区域（头像/昵称）回调。
  ///
  /// 未登录：跳转登录页；已登录：进入设置页。
  Future<void> _onTapProfile() async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  /// 点击 Profile 右侧按钮回调。
  ///
  /// 未登录：跳转登录页；已登录：进入设置页。
  Future<void> _onTapAction() async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  /// 点击快捷入口卡片回调。
  ///
  /// 根据 id 决定跳转的页面。
  void _onTapQuickAction(String id) {
    final l10n = _l10n;
    if (id == 'search') {
      Navigator.pushNamed(context, '/search');
      return;
    }
    if (id == 'reminders') {
      Navigator.pushNamed(context, '/reminders');
      return;
    }
    if (id == 'settings') {
      Navigator.pushNamed(context, '/settings');
      return;
    }
    ToastUtils.instance.show(context, l10n?.mineDevelopingToast ?? '功能开发中');
  }

  /// 构建我的页 UI。
  ///
  /// 这里用 `Obx` 监听用户对象变化，让 UI 自动响应登录/退出登录。
  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return MinePage(
      headerPalette: SoftBannerPalettes.mineOf(context),
      profileCard: Obx(
        () => MineProfileCard(
          palette: SoftBannerPalettes.mineOf(context),
          user: _userController.user.value,
          onTapProfile: _onTapProfile,
          onTapAction: _onTapAction,
          loggedInActionLabel: l10n?.mineLoggedInActionLabel,
        ),
      ),
      quickActions: _quickActions,
      onTapQuickAction: _onTapQuickAction,
      onTapBrowseHistory: () => ToastUtils.instance.show(
        context,
        l10n?.mineDevelopingToast ?? '功能开发中',
      ),
      onTapSecurity: () => Navigator.pushNamed(context, '/settings'),
      onTapAbout: () => showAboutDialog(
        context: context,
        applicationName: 'Luminous',
        applicationVersion: '3.0.0+33',
        applicationLegalese: l10n?.mineAboutLegalese ?? '健康助手与药品信息辅助应用',
      ),
    );
  }
}
