// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Luminous';

  @override
  String get tabToday => '今日';

  @override
  String get tabRecord => '记录';

  @override
  String get tabMedicine => '用药';

  @override
  String get tabMine => '我的';

  @override
  String get tabMore => '更多';

  @override
  String get recordPageDescription => '日历、时间线与多类型每日记录会从这里生长出来。';

  @override
  String get recordSectionTitle => '每日时间线';

  @override
  String get recordSectionSubtitle => '记录页的第一步先搭结构，不急着恢复旧逻辑。';

  @override
  String get medicinePageDescription => '今日用药计划、依从性、补药状态与安全提醒会在这一栏汇合。';

  @override
  String get medicineSectionTitle => '用药工作区';

  @override
  String get medicineSectionSubtitle => '这里会承接基于 Lucent 重建后的完整用药闭环。';

  @override
  String get minePageDescription => '档案、目标、隐私与账号设置会在这里重建。';

  @override
  String get mineSectionTitle => '个人工作区';

  @override
  String get mineSectionSubtitle => '身份、目标与隐私控制会共享在这一块安静的界面里。';

  @override
  String get morePageDescription => '工具箱、紧急帮助、设备管理和低频但重要的能力归在这里。';

  @override
  String get moreSectionTitle => '功能枢纽';

  @override
  String get moreSectionSubtitle => '这一栏会收纳低频但依然重要的工作流。';

  @override
  String get todaySectionTitle => '今日工作区';

  @override
  String get todaySectionSubtitle => '新的首页会从这里逐步接入提醒、快照、喝水与 Lumi 建议。';

  @override
  String get authLoginBadge => '认证 / 登录';

  @override
  String get authRegisterBadge => '认证 / 注册';

  @override
  String get authLoginTitle => '用更克制的方式登录。';

  @override
  String get authLoginDescription =>
      '使用 Lucent 账号进入新的用药主线，后续再逐步解锁提醒、快照和多语言健康流程。';

  @override
  String get authRegisterTitle => '先把干净版本搭起来。';

  @override
  String get authRegisterDescription =>
      '先完成注册，再在 Lucent 之上逐步生长用药计划、提醒和多语言健康能力。';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authCreateAccount => '创建账号';

  @override
  String get authLoginLead => '先输入邮箱，再选择密码登录或验证码登录。';

  @override
  String get authRegisterLead => '先用邮箱和密码完成账号创建，昵称可选。';

  @override
  String get authModePassword => '密码';

  @override
  String get authModeCode => '验证码';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authPasswordHint => '至少 8 位，建议包含大小写和数字';

  @override
  String get authCodeLabel => '验证码';

  @override
  String get authNicknameLabel => '昵称';

  @override
  String get authNicknameHint => '可选';

  @override
  String get authSendCode => '发送验证码';

  @override
  String get authSignIn => '登录';

  @override
  String get authCreateAccountAction => '创建账号';

  @override
  String authSignedInAs(String email) {
    return '当前已登录：$email';
  }

  @override
  String get authCheckingSession => '正在检查登录状态...';

  @override
  String get authNotSignedIn => '尚未登录。';

  @override
  String get authGoLogin => '去登录';

  @override
  String get authGoRegister => '去注册';

  @override
  String get authSignOut => '退出登录';

  @override
  String get authInfraHint => '安全 token 存储、Lucent 多语言响应与会话恢复能力已经接到这层表单之下。';

  @override
  String get todayHeroTitle => '今日';

  @override
  String get todayHeroDescription =>
      '新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。';

  @override
  String get todayChipWater => '喝水追踪';

  @override
  String get todayChipMedication => '用药提醒';

  @override
  String get todayChipSnapshot => '健康快照';

  @override
  String get todayChipDiet => '饮食建议';

  @override
  String get todayChipEnvironment => '环境提醒';

  @override
  String get todayChipLumi => 'Lumi 建议';

  @override
  String placeholderSoon(String label) {
    return '$label · 即将上线';
  }

  @override
  String get placeholderDescription => '这一栏的结构已经预留完成，下一步会按新的多端设计系统重建。';
}
