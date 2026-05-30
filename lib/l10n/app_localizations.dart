import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Luminous'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In zh, this message translates to:
  /// **'今日'**
  String get tabToday;

  /// No description provided for @tabRecord.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get tabRecord;

  /// No description provided for @tabMedicine.
  ///
  /// In zh, this message translates to:
  /// **'用药'**
  String get tabMedicine;

  /// No description provided for @tabMine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMine;

  /// No description provided for @tabMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get tabMore;

  /// No description provided for @recordPageDescription.
  ///
  /// In zh, this message translates to:
  /// **'日历、时间线与多类型每日记录会从这里生长出来。'**
  String get recordPageDescription;

  /// No description provided for @recordSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'每日时间线'**
  String get recordSectionTitle;

  /// No description provided for @recordSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录页的第一步先搭结构，不急着恢复旧逻辑。'**
  String get recordSectionSubtitle;

  /// No description provided for @medicinePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'今日用药计划、依从性、补药状态与安全提醒会在这一栏汇合。'**
  String get medicinePageDescription;

  /// No description provided for @medicineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药工作区'**
  String get medicineSectionTitle;

  /// No description provided for @medicineSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'这里会承接基于 Lucent 重建后的完整用药闭环。'**
  String get medicineSectionSubtitle;

  /// No description provided for @minePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'档案、目标、隐私与账号设置会在这里重建。'**
  String get minePageDescription;

  /// No description provided for @mineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人工作区'**
  String get mineSectionTitle;

  /// No description provided for @mineSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'身份、目标与隐私控制会共享在这一块安静的界面里。'**
  String get mineSectionSubtitle;

  /// No description provided for @morePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'工具箱、紧急帮助、设备管理和低频但重要的能力归在这里。'**
  String get morePageDescription;

  /// No description provided for @moreSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'功能枢纽'**
  String get moreSectionTitle;

  /// No description provided for @moreSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'这一栏会收纳低频但依然重要的工作流。'**
  String get moreSectionSubtitle;

  /// No description provided for @todaySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日工作区'**
  String get todaySectionTitle;

  /// No description provided for @todaySectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'新的首页会从这里逐步接入提醒、快照、喝水与 Lumi 建议。'**
  String get todaySectionSubtitle;

  /// No description provided for @authLoginBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 登录'**
  String get authLoginBadge;

  /// No description provided for @authRegisterBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 注册'**
  String get authRegisterBadge;

  /// No description provided for @authLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'用更克制的方式登录。'**
  String get authLoginTitle;

  /// No description provided for @authLoginDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用 Lucent 账号进入新的用药主线，后续再逐步解锁提醒、快照和多语言健康流程。'**
  String get authLoginDescription;

  /// No description provided for @authRegisterTitle.
  ///
  /// In zh, this message translates to:
  /// **'先把干净版本搭起来。'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterDescription.
  ///
  /// In zh, this message translates to:
  /// **'先完成注册，再在 Lucent 之上逐步生长用药计划、提醒和多语言健康能力。'**
  String get authRegisterDescription;

  /// No description provided for @authWelcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get authCreateAccount;

  /// No description provided for @authLoginLead.
  ///
  /// In zh, this message translates to:
  /// **'先输入邮箱，再选择密码登录或验证码登录。'**
  String get authLoginLead;

  /// No description provided for @authRegisterLead.
  ///
  /// In zh, this message translates to:
  /// **'先验证邮箱，再设置密码。昵称可选。'**
  String get authRegisterLead;

  /// No description provided for @authModePassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authModePassword;

  /// No description provided for @authModeCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get authModeCode;

  /// No description provided for @authEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'至少 8 位，建议包含大小写和数字'**
  String get authPasswordHint;

  /// No description provided for @authCodeLabel.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get authCodeLabel;

  /// No description provided for @authNicknameLabel.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get authNicknameLabel;

  /// No description provided for @authNicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get authNicknameHint;

  /// No description provided for @authEmailRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写邮箱。'**
  String get authEmailRequiredToast;

  /// No description provided for @authCodeRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写验证码。'**
  String get authCodeRequiredToast;

  /// No description provided for @authPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写密码。'**
  String get authPasswordRequiredToast;

  /// No description provided for @authConfirmPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先确认密码。'**
  String get authConfirmPasswordRequiredToast;

  /// No description provided for @authSendCode.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码'**
  String get authSendCode;

  /// No description provided for @authSendCodeAgain.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒后重发'**
  String authSendCodeAgain(int seconds);

  /// No description provided for @authSignIn.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get authSignIn;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get authCreateAccountAction;

  /// No description provided for @authForgotPasswordPrompt.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码？'**
  String get authForgotPasswordPrompt;

  /// No description provided for @authResetPasswordAction.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordAction;

  /// No description provided for @authNeedAccountPrompt.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号？'**
  String get authNeedAccountPrompt;

  /// No description provided for @authRegisterNowAction.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get authRegisterNowAction;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In zh, this message translates to:
  /// **'已经有账号？'**
  String get authHaveAccountPrompt;

  /// No description provided for @authRememberPasswordPrompt.
  ///
  /// In zh, this message translates to:
  /// **'想起密码了？'**
  String get authRememberPasswordPrompt;

  /// No description provided for @authForgotPasswordBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 重置'**
  String get authForgotPasswordBadge;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'通过邮箱重置密码。'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordDescription.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码，设置新密码，然后回到登录页重新登录。'**
  String get authForgotPasswordDescription;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordLead.
  ///
  /// In zh, this message translates to:
  /// **'使用账号绑定的邮箱接收重置验证码。'**
  String get authResetPasswordLead;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get authNewPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致。'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authResetPasswordSubmit.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordSubmit;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码已更新，请重新登录。'**
  String get authResetPasswordSuccess;

  /// No description provided for @authChangeEmailBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 邮箱'**
  String get authChangeEmailBadge;

  /// No description provided for @authChangeEmailTitle.
  ///
  /// In zh, this message translates to:
  /// **'谨慎更换账号邮箱。'**
  String get authChangeEmailTitle;

  /// No description provided for @authChangeEmailDescription.
  ///
  /// In zh, this message translates to:
  /// **'先验证新邮箱，再把它设为账号登录邮箱。'**
  String get authChangeEmailDescription;

  /// No description provided for @authChangeEmailFormTitle.
  ///
  /// In zh, this message translates to:
  /// **'更换邮箱'**
  String get authChangeEmailFormTitle;

  /// No description provided for @authChangeEmailLead.
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱：{email}'**
  String authChangeEmailLead(String email);

  /// No description provided for @authChangeEmailSignedOutLead.
  ///
  /// In zh, this message translates to:
  /// **'请先登录，再更换账号邮箱。'**
  String get authChangeEmailSignedOutLead;

  /// No description provided for @authNewEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'新邮箱'**
  String get authNewEmailLabel;

  /// No description provided for @authChangeEmailSubmit.
  ///
  /// In zh, this message translates to:
  /// **'更新邮箱'**
  String get authChangeEmailSubmit;

  /// No description provided for @authChangeEmailSuccess.
  ///
  /// In zh, this message translates to:
  /// **'邮箱已更新。'**
  String get authChangeEmailSuccess;

  /// No description provided for @authBackHomePrompt.
  ///
  /// In zh, this message translates to:
  /// **'返回首页？'**
  String get authBackHomePrompt;

  /// No description provided for @authSignedInAs.
  ///
  /// In zh, this message translates to:
  /// **'当前已登录：{email}'**
  String authSignedInAs(String email);

  /// No description provided for @authCheckingSession.
  ///
  /// In zh, this message translates to:
  /// **'正在检查登录状态...'**
  String get authCheckingSession;

  /// No description provided for @authNotSignedIn.
  ///
  /// In zh, this message translates to:
  /// **'尚未登录。'**
  String get authNotSignedIn;

  /// No description provided for @authGoLogin.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get authGoLogin;

  /// No description provided for @authGoRegister.
  ///
  /// In zh, this message translates to:
  /// **'去注册'**
  String get authGoRegister;

  /// No description provided for @authSignOut.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get authSignOut;

  /// No description provided for @authInfraHint.
  ///
  /// In zh, this message translates to:
  /// **'安全 token 存储、Lucent 多语言响应与会话恢复能力已经接到这层表单之下。'**
  String get authInfraHint;

  /// No description provided for @todayHeroTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日'**
  String get todayHeroTitle;

  /// No description provided for @todayHeroDescription.
  ///
  /// In zh, this message translates to:
  /// **'新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。'**
  String get todayHeroDescription;

  /// No description provided for @todayChipWater.
  ///
  /// In zh, this message translates to:
  /// **'喝水追踪'**
  String get todayChipWater;

  /// No description provided for @todayChipMedication.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get todayChipMedication;

  /// No description provided for @todayChipSnapshot.
  ///
  /// In zh, this message translates to:
  /// **'健康快照'**
  String get todayChipSnapshot;

  /// No description provided for @todayChipDiet.
  ///
  /// In zh, this message translates to:
  /// **'饮食建议'**
  String get todayChipDiet;

  /// No description provided for @todayChipEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'环境提醒'**
  String get todayChipEnvironment;

  /// No description provided for @todayChipLumi.
  ///
  /// In zh, this message translates to:
  /// **'Lumi 建议'**
  String get todayChipLumi;

  /// No description provided for @placeholderSoon.
  ///
  /// In zh, this message translates to:
  /// **'{label} · 即将上线'**
  String placeholderSoon(String label);

  /// No description provided for @placeholderDescription.
  ///
  /// In zh, this message translates to:
  /// **'这一栏的结构已经预留完成，下一步会按新的多端设计系统重建。'**
  String get placeholderDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
