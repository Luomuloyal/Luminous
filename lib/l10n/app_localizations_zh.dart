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
