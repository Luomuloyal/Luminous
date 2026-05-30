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
