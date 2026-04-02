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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Luminous'**
  String get appName;

  /// No description provided for @mainTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainTabHome;

  /// No description provided for @mainTabDrug.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get mainTabDrug;

  /// No description provided for @mainTabAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get mainTabAlbum;

  /// No description provided for @mainTabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mainTabMine;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralTitle;

  /// No description provided for @settingsGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter each module to configure preferences. More options will be added.'**
  String get settingsGeneralSubtitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust mode and style for global UI.'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeEnter.
  ///
  /// In en, this message translates to:
  /// **'Open theme settings'**
  String get settingsThemeEnter;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match system language automatically, or set app language manually.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageEnter.
  ///
  /// In en, this message translates to:
  /// **'Open language settings'**
  String get settingsLanguageEnter;

  /// No description provided for @languagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePageTitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get languageSectionTitle;

  /// No description provided for @languageSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Follow System for automatic switching, or lock a language manually.'**
  String get languageSectionSubtitle;

  /// No description provided for @languageFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get languageFollowSystem;

  /// No description provided for @languageFollowSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically uses your device language'**
  String get languageFollowSystemSubtitle;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChinese;

  /// No description provided for @languageChineseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Chinese for app text'**
  String get languageChineseSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use English for app text'**
  String get languageEnglishSubtitle;

  /// No description provided for @languageCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current language: {language}'**
  String languageCurrentLabel(Object language);

  /// No description provided for @languageSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected: {language}'**
  String languageSelectedLabel(Object language);

  /// No description provided for @languageHeroHintSystem.
  ///
  /// In en, this message translates to:
  /// **'App language follows device language automatically'**
  String get languageHeroHintSystem;

  /// No description provided for @languageHeroHintChinese.
  ///
  /// In en, this message translates to:
  /// **'Interface text is fixed to Simplified Chinese'**
  String get languageHeroHintChinese;

  /// No description provided for @languageHeroHintEnglish.
  ///
  /// In en, this message translates to:
  /// **'Interface text is fixed to English'**
  String get languageHeroHintEnglish;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'When Follow System is enabled, changing your device language will apply automatically the next time you open the app (and also while app is running when system locale updates).'**
  String get languageNote;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authPhoneLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLoginMode.
  ///
  /// In en, this message translates to:
  /// **'Password Login'**
  String get authPasswordLoginMode;

  /// No description provided for @authCodeLoginMode.
  ///
  /// In en, this message translates to:
  /// **'Code Login'**
  String get authCodeLoginMode;

  /// No description provided for @authPhoneRegisterMethod.
  ///
  /// In en, this message translates to:
  /// **'Phone Registration'**
  String get authPhoneRegisterMethod;

  /// No description provided for @authEmailRegisterMethod.
  ///
  /// In en, this message translates to:
  /// **'Email Registration'**
  String get authEmailRegisterMethod;

  /// No description provided for @authSwitchToEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Email Login'**
  String get authSwitchToEmailLogin;

  /// No description provided for @authSwitchToPhoneLogin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Phone Login'**
  String get authSwitchToPhoneLogin;

  /// No description provided for @authUserAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get authUserAgreementTitle;

  /// No description provided for @authPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicyTitle;

  /// No description provided for @authLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to the '**
  String get authLegalPrefix;

  /// No description provided for @authLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authLegalAnd;

  /// No description provided for @authAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get authAgreementPrefix;

  /// No description provided for @authValidationEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get authValidationEnterPhone;

  /// No description provided for @authValidationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get authValidationEnterEmail;

  /// No description provided for @authValidationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number format is invalid'**
  String get authValidationInvalidPhone;

  /// No description provided for @authValidationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Email format is invalid'**
  String get authValidationInvalidEmail;

  /// No description provided for @authValidationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get authValidationEnterPassword;

  /// No description provided for @authValidationPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6-12 letters or numbers'**
  String get authValidationPasswordRule;

  /// No description provided for @authValidationEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get authValidationEnterCode;

  /// No description provided for @authValidationCodeRule.
  ///
  /// In en, this message translates to:
  /// **'Verification code must be 6 digits'**
  String get authValidationCodeRule;

  /// No description provided for @authValidationEnterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password again'**
  String get authValidationEnterConfirmPassword;

  /// No description provided for @authValidationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authValidationPasswordMismatch;

  /// No description provided for @authCodeSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get authCodeSentSuccess;

  /// No description provided for @authErrorCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Incorrect verification code. Please try again'**
  String get authErrorCodeInvalid;

  /// No description provided for @authErrorCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code has expired. Please request a new one'**
  String get authErrorCodeExpired;

  /// No description provided for @authErrorCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get authErrorCodeRequired;

  /// No description provided for @authErrorIdentifierExistsLogin.
  ///
  /// In en, this message translates to:
  /// **'This account is already registered. Please log in directly'**
  String get authErrorIdentifierExistsLogin;

  /// No description provided for @authErrorIdentifierExistsPhoneRegistered.
  ///
  /// In en, this message translates to:
  /// **'Phone number is already registered'**
  String get authErrorIdentifierExistsPhoneRegistered;

  /// No description provided for @authErrorIdentifierExistsEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email is already registered'**
  String get authErrorIdentifierExistsEmailRegistered;

  /// No description provided for @authErrorTooFrequent.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get authErrorTooFrequent;

  /// No description provided for @authErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number format is invalid'**
  String get authErrorInvalidPhone;

  /// No description provided for @authErrorInvalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Email format is invalid'**
  String get authErrorInvalidEmailFormat;

  /// No description provided for @authErrorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Please try again later'**
  String get authErrorRequestFailed;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'6-12 letters or numbers'**
  String get authPasswordHint;

  /// No description provided for @authCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get authCodeLabel;

  /// No description provided for @authCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get authCodeHint;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password again'**
  String get authConfirmPasswordHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get authSendCode;

  /// No description provided for @loginHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Assistant'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{identifier} {mode}'**
  String loginHeroSubtitle(Object identifier, Object mode);

  /// No description provided for @loginForgotPasswordPending.
  ///
  /// In en, this message translates to:
  /// **'Password recovery will be added later. You can register a new account or contact support for now.'**
  String get loginForgotPasswordPending;

  /// No description provided for @loginNeedCodeForCurrentAccount.
  ///
  /// In en, this message translates to:
  /// **'Please request a verification code for the current account first'**
  String get loginNeedCodeForCurrentAccount;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginSuccessPartialSync.
  ///
  /// In en, this message translates to:
  /// **'Login successful, but part of cloud data sync failed'**
  String get loginSuccessPartialSync;

  /// No description provided for @loginAutoRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Not Registered'**
  String get loginAutoRegisterTitle;

  /// No description provided for @loginAutoRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'This account is not registered yet. Go to registration?'**
  String get loginAutoRegisterPrompt;

  /// No description provided for @loginAutoRegisterCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loginAutoRegisterCancel;

  /// No description provided for @loginAutoRegisterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginAutoRegisterConfirm;

  /// No description provided for @loginRegisterAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegisterAction;

  /// No description provided for @loginIdentifierHintPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get loginIdentifierHintPhone;

  /// No description provided for @loginIdentifierHintEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get loginIdentifierHintEmail;

  /// No description provided for @loginForgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get loginForgotPasswordAction;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loginHelperPassword.
  ///
  /// In en, this message translates to:
  /// **'Supports phone or email with password login.'**
  String get loginHelperPassword;

  /// No description provided for @loginHelperCode.
  ///
  /// In en, this message translates to:
  /// **'Supports phone or email code login. If unregistered, go register directly.'**
  String get loginHelperCode;

  /// No description provided for @registerTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTopTitle;

  /// No description provided for @registerHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerHeroTitle;

  /// No description provided for @registerHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{identifier} code registration'**
  String registerHeroSubtitle(Object identifier);

  /// No description provided for @registerNeedCodeForCurrentAccount.
  ///
  /// In en, this message translates to:
  /// **'Please request a verification code for the current account first'**
  String get registerNeedCodeForCurrentAccount;

  /// No description provided for @registerNeedAgreement.
  ///
  /// In en, this message translates to:
  /// **'Please read and check User Agreement and Privacy Policy first'**
  String get registerNeedAgreement;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerHelperPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone registration only needs SMS code and password confirmation.'**
  String get registerHelperPhone;

  /// No description provided for @registerHelperEmail.
  ///
  /// In en, this message translates to:
  /// **'Email registration only needs email code and password confirmation.'**
  String get registerHelperEmail;

  /// No description provided for @homeFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Common Features'**
  String get homeFeaturesTitle;

  /// No description provided for @homeFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access to core health services'**
  String get homeFeaturesSubtitle;

  /// No description provided for @homeReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reminders'**
  String get homeReminderTitle;

  /// No description provided for @homeStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get homeStatusSyncing;

  /// No description provided for @homeStatusRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Light day'**
  String get homeStatusRelaxed;

  /// No description provided for @homeStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get homeStatusReady;

  /// No description provided for @homePillLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading reminders...'**
  String get homePillLoading;

  /// No description provided for @homePillCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders today'**
  String homePillCount(int count);

  /// No description provided for @homePillTips.
  ///
  /// In en, this message translates to:
  /// **'Health Tips'**
  String get homePillTips;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Assistant'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroIntro.
  ///
  /// In en, this message translates to:
  /// **'Here is your plan for today'**
  String get homeHeroIntro;

  /// No description provided for @homeSummaryTitleLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing reminders'**
  String get homeSummaryTitleLoading;

  /// No description provided for @homeSummaryTitleNone.
  ///
  /// In en, this message translates to:
  /// **'Today\'s status'**
  String get homeSummaryTitleNone;

  /// No description provided for @homeSummaryTitleNext.
  ///
  /// In en, this message translates to:
  /// **'Next reminder'**
  String get homeSummaryTitleNext;

  /// No description provided for @homeSummaryDetailLoading.
  ///
  /// In en, this message translates to:
  /// **'Syncing today\'s reminder schedule. Please wait a moment'**
  String get homeSummaryDetailLoading;

  /// No description provided for @homeSummaryDetailNone.
  ///
  /// In en, this message translates to:
  /// **'No pending reminders today. Keep your current rhythm'**
  String get homeSummaryDetailNone;

  /// No description provided for @homeSummaryBadgeLoading.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get homeSummaryBadgeLoading;

  /// No description provided for @homeSummaryBadgeRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Easy day'**
  String get homeSummaryBadgeRelaxed;

  /// No description provided for @homeSummaryBadgeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled'**
  String homeSummaryBadgeCount(int count);

  /// No description provided for @homeNoReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get homeNoReminder;

  /// No description provided for @homeNextReminderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Next reminder: {title} · {subtitle}'**
  String homeNextReminderPrefix(Object title, Object subtitle);

  /// No description provided for @homeFeatureDrugScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Scan'**
  String get homeFeatureDrugScanTitle;

  /// No description provided for @homeFeatureDrugScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan medicine by camera'**
  String get homeFeatureDrugScanSubtitle;

  /// No description provided for @homeFeatureManualSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Search'**
  String get homeFeatureManualSearchTitle;

  /// No description provided for @homeFeatureManualSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by keywords'**
  String get homeFeatureManualSearchSubtitle;

  /// No description provided for @homeFeatureReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get homeFeatureReminderTitle;

  /// No description provided for @homeFeatureReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-time notifications'**
  String get homeFeatureReminderSubtitle;

  /// No description provided for @homeFeatureCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Check-in'**
  String get homeFeatureCheckInTitle;

  /// No description provided for @homeFeatureCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record intake status'**
  String get homeFeatureCheckInSubtitle;

  /// No description provided for @homeFeatureDrugInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Info'**
  String get homeFeatureDrugInfoTitle;

  /// No description provided for @homeFeatureDrugInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients and cautions'**
  String get homeFeatureDrugInfoSubtitle;

  /// No description provided for @homeFeatureSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Assist'**
  String get homeFeatureSafetyTitle;

  /// No description provided for @homeFeatureSafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Risk alerts'**
  String get homeFeatureSafetySubtitle;

  /// No description provided for @homeFeatureDevelopingToast.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get homeFeatureDevelopingToast;

  /// No description provided for @homeMedicinePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select medicine'**
  String get homeMedicinePickerTitle;

  /// No description provided for @homeTipsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'All Health Tips'**
  String get homeTipsSheetTitle;

  /// No description provided for @homeTipsSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any tip to replace the Home tip text'**
  String get homeTipsSheetSubtitle;

  /// No description provided for @homeTip1.
  ///
  /// In en, this message translates to:
  /// **'Take medicine on time; don\'t skip or double dose'**
  String get homeTip1;

  /// No description provided for @homeTip2.
  ///
  /// In en, this message translates to:
  /// **'Follow instructions for before or after meals'**
  String get homeTip2;

  /// No description provided for @homeTip3.
  ///
  /// In en, this message translates to:
  /// **'Ask a pharmacist before combining medicines'**
  String get homeTip3;

  /// No description provided for @homeTip4.
  ///
  /// In en, this message translates to:
  /// **'Do not double dose after missing one; consult first'**
  String get homeTip4;

  /// No description provided for @homeTip5.
  ///
  /// In en, this message translates to:
  /// **'Seek medical care promptly if discomfort appears'**
  String get homeTip5;

  /// No description provided for @homeTip6.
  ///
  /// In en, this message translates to:
  /// **'Finish antibiotic courses; don\'t stop early'**
  String get homeTip6;

  /// No description provided for @homeTip7.
  ///
  /// In en, this message translates to:
  /// **'Store medicines away from light, moisture, and heat'**
  String get homeTip7;

  /// No description provided for @homeTip8.
  ///
  /// In en, this message translates to:
  /// **'Clean out expired medicines regularly'**
  String get homeTip8;

  /// No description provided for @homeTip9.
  ///
  /// In en, this message translates to:
  /// **'Check contraindications and interactions before use'**
  String get homeTip9;

  /// No description provided for @homeTip10.
  ///
  /// In en, this message translates to:
  /// **'Regular rest helps stabilize medication effect'**
  String get homeTip10;

  /// No description provided for @homeFallbackReminder1Title.
  ///
  /// In en, this message translates to:
  /// **'08:30 Vitamin D'**
  String get homeFallbackReminder1Title;

  /// No description provided for @homeFallbackReminder1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take 1 capsule after breakfast'**
  String get homeFallbackReminder1Subtitle;

  /// No description provided for @homeFallbackReminder2Title.
  ///
  /// In en, this message translates to:
  /// **'19:30 Amoxicillin'**
  String get homeFallbackReminder2Title;

  /// No description provided for @homeFallbackReminder2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take 1 capsule after dinner'**
  String get homeFallbackReminder2Subtitle;

  /// No description provided for @homeFallbackReminder3Title.
  ///
  /// In en, this message translates to:
  /// **'22:00 Blood Pressure Log'**
  String get homeFallbackReminder3Title;

  /// No description provided for @homeFallbackReminder3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record and upload before sleep'**
  String get homeFallbackReminder3Subtitle;

  /// No description provided for @reminderListTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get reminderListTitle;

  /// No description provided for @reminderAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get reminderAddButton;

  /// No description provided for @reminderNeedLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get reminderNeedLoginTitle;

  /// No description provided for @reminderNeedLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After login, your reminder plans can be synced and delivered as system notifications on time.'**
  String get reminderNeedLoginSubtitle;

  /// No description provided for @reminderNeedLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get reminderNeedLoginAction;

  /// No description provided for @reminderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get reminderEmptyTitle;

  /// No description provided for @reminderEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Reminder at the bottom-right to get started'**
  String get reminderEmptySubtitle;

  /// No description provided for @reminderDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get reminderDeleteDialogTitle;

  /// No description provided for @reminderDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{productName} {time}\"?'**
  String reminderDeleteDialogContent(Object productName, Object time);

  /// No description provided for @reminderDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reminderDeleteCancel;

  /// No description provided for @reminderDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reminderDeleteConfirm;

  /// No description provided for @reminderDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get reminderDeletedToast;

  /// No description provided for @reminderSystemNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System notification reminder'**
  String get reminderSystemNotificationSubtitle;

  /// No description provided for @reminderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get reminderEditTitle;

  /// No description provided for @reminderCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Reminder'**
  String get reminderCreateTitle;

  /// No description provided for @reminderEditSectionDrugTime.
  ///
  /// In en, this message translates to:
  /// **'Medicine & Time'**
  String get reminderEditSectionDrugTime;

  /// No description provided for @reminderEditSelectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Select medicine'**
  String get reminderEditSelectMedicine;

  /// No description provided for @reminderEditSelectMedicineHint.
  ///
  /// In en, this message translates to:
  /// **'Choose from My Medicines or Search Library'**
  String get reminderEditSelectMedicineHint;

  /// No description provided for @reminderEditSelectedIdentity.
  ///
  /// In en, this message translates to:
  /// **'Drug Code: {drugCode}  Approval No.: {approvalNo}'**
  String reminderEditSelectedIdentity(Object drugCode, Object approvalNo);

  /// No description provided for @reminderEditTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time: {time}'**
  String reminderEditTimeTitle(Object time);

  /// No description provided for @reminderEditTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a system notification at this time every day'**
  String get reminderEditTimeSubtitle;

  /// No description provided for @reminderEditSectionEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date'**
  String get reminderEditSectionEffectiveDate;

  /// No description provided for @reminderDateUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get reminderDateUnlimited;

  /// No description provided for @reminderEditStartDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Date: {value}'**
  String reminderEditStartDateTitle(Object value);

  /// No description provided for @reminderEditEndDateTitle.
  ///
  /// In en, this message translates to:
  /// **'End Date: {value}'**
  String reminderEditEndDateTitle(Object value);

  /// No description provided for @reminderEditStartDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to remove start date limit'**
  String get reminderEditStartDateSubtitle;

  /// No description provided for @reminderEditEndDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to remove end date limit'**
  String get reminderEditEndDateSubtitle;

  /// No description provided for @reminderEditDateBadgeUnset.
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get reminderEditDateBadgeUnset;

  /// No description provided for @reminderEditDateBadgeSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get reminderEditDateBadgeSet;

  /// No description provided for @reminderEditClearDateLimit.
  ///
  /// In en, this message translates to:
  /// **'Clear date limits'**
  String get reminderEditClearDateLimit;

  /// No description provided for @reminderEditStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get reminderEditStatusEnabled;

  /// No description provided for @reminderEditStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get reminderEditStatusDisabled;

  /// No description provided for @reminderEditStatusBoundMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine linked'**
  String get reminderEditStatusBoundMedicine;

  /// No description provided for @reminderEditStatusManualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get reminderEditStatusManualInput;

  /// No description provided for @reminderEditDateRangeInvalidToast.
  ///
  /// In en, this message translates to:
  /// **'Start date cannot be later than end date'**
  String get reminderEditDateRangeInvalidToast;

  /// No description provided for @reminderDateRangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get reminderDateRangeAllTime;

  /// No description provided for @reminderDateRangeBetweenShort.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String reminderDateRangeBetweenShort(Object start, Object end);

  /// No description provided for @reminderDateRangeFromShort.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String reminderDateRangeFromShort(Object date);

  /// No description provided for @reminderDateRangeUntilShort.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String reminderDateRangeUntilShort(Object date);

  /// No description provided for @reminderEditSectionContent.
  ///
  /// In en, this message translates to:
  /// **'Reminder Content'**
  String get reminderEditSectionContent;

  /// No description provided for @reminderEditNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name (required)'**
  String get reminderEditNameLabel;

  /// No description provided for @reminderEditSubtitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get reminderEditSubtitleLabel;

  /// No description provided for @reminderEditSubtitleHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Take 1 capsule after breakfast'**
  String get reminderEditSubtitleHint;

  /// No description provided for @reminderEditSectionSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get reminderEditSectionSwitch;

  /// No description provided for @reminderEditEnableSwitch.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get reminderEditEnableSwitch;

  /// No description provided for @reminderEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reminderEditSave;

  /// No description provided for @reminderEditTip.
  ///
  /// In en, this message translates to:
  /// **'Note: Reminder information is for assistance only and cannot replace medical prescriptions. Seek medical care promptly if you feel unwell.'**
  String get reminderEditTip;

  /// No description provided for @reminderEditPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Reminder Medicine'**
  String get reminderEditPickerTitle;

  /// No description provided for @reminderEditNeedLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get reminderEditNeedLogin;

  /// No description provided for @reminderEditNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medicine name cannot be empty'**
  String get reminderEditNameRequired;

  /// No description provided for @checkInPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Check-in'**
  String get checkInPageTitle;

  /// No description provided for @checkInNeedLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get checkInNeedLoginTitle;

  /// No description provided for @checkInNeedLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After login, your plans on this device can be loaded and today\'s check-in status will be stored locally.'**
  String get checkInNeedLoginSubtitle;

  /// No description provided for @checkInNeedLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get checkInNeedLoginAction;

  /// No description provided for @checkInEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders today'**
  String get checkInEmptyTitle;

  /// No description provided for @checkInEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Medication Reminders to add a plan first'**
  String get checkInEmptySubtitle;

  /// No description provided for @checkInMissingIdMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Missing reminder id. Unable to check in'**
  String get checkInMissingIdMarkDone;

  /// No description provided for @checkInMarkedDoneToast.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get checkInMarkedDoneToast;

  /// No description provided for @checkInMissingIdMarkUndone.
  ///
  /// In en, this message translates to:
  /// **'Missing reminder id. Unable to switch status'**
  String get checkInMissingIdMarkUndone;

  /// No description provided for @checkInUndoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo Local Check-in'**
  String get checkInUndoDialogTitle;

  /// No description provided for @checkInUndoDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Check-in data is stored on this device only. Undoing will immediately update what you see on this device. Continue?'**
  String get checkInUndoDialogContent;

  /// No description provided for @checkInUndoDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get checkInUndoDialogCancel;

  /// No description provided for @checkInUndoDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo Local Check-in'**
  String get checkInUndoDialogConfirm;

  /// No description provided for @checkInMarkedUndoneToast.
  ///
  /// In en, this message translates to:
  /// **'Marked as not checked in'**
  String get checkInMarkedUndoneToast;

  /// No description provided for @checkInDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get checkInDefaultTitle;

  /// No description provided for @checkInCardDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please complete on time'**
  String get checkInCardDefaultSubtitle;

  /// No description provided for @checkInActionDone.
  ///
  /// In en, this message translates to:
  /// **'Undo Check-in'**
  String get checkInActionDone;

  /// No description provided for @checkInActionUndone.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkInActionUndone;

  /// No description provided for @mineQuickReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reminders'**
  String get mineQuickReminderTitle;

  /// No description provided for @mineQuickReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get mineQuickReminderSubtitle;

  /// No description provided for @mineQuickSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Search'**
  String get mineQuickSearchTitle;

  /// No description provided for @mineQuickSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drug info'**
  String get mineQuickSearchSubtitle;

  /// No description provided for @mineQuickSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mineQuickSettingsTitle;

  /// No description provided for @mineQuickSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get mineQuickSettingsSubtitle;

  /// No description provided for @mineDevelopingToast.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get mineDevelopingToast;

  /// No description provided for @mineLoggedInActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mineLoggedInActionLabel;

  /// No description provided for @mineAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Health assistant and medicine information companion app'**
  String get mineAboutLegalese;

  /// No description provided for @mineProfileLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Log in now'**
  String get mineProfileLoginNow;

  /// No description provided for @mineProfileLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your account and sync personal data'**
  String get mineProfileLoginHint;

  /// No description provided for @mineProfileLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get mineProfileLoginAction;

  /// No description provided for @mineProfileChipAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get mineProfileChipAccountConnected;

  /// No description provided for @mineProfileChipLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local experience now'**
  String get mineProfileChipLocalOnly;

  /// No description provided for @mineProfileChipImageLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Original images stay on this device'**
  String get mineProfileChipImageLocalOnly;

  /// No description provided for @mineProfileChipSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Lightweight sync available'**
  String get mineProfileChipSyncEnabled;

  /// No description provided for @mineProfileChipSyncAfterLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable lightweight sync after login'**
  String get mineProfileChipSyncAfterLogin;

  /// No description provided for @mineQuickSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get mineQuickSectionTitle;

  /// No description provided for @mineQuickSectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String mineQuickSectionCount(int count);

  /// No description provided for @mineQuickSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep account, sync, and device-related entries together'**
  String get mineQuickSectionSubtitle;

  /// No description provided for @mineMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'More Settings'**
  String get mineMenuTitle;

  /// No description provided for @mineMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect history, account security, and version info in one place'**
  String get mineMenuSubtitle;

  /// No description provided for @mineMenuHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse History'**
  String get mineMenuHistoryTitle;

  /// No description provided for @mineMenuHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medicines you viewed recently'**
  String get mineMenuHistorySubtitle;

  /// No description provided for @mineMenuSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get mineMenuSecurityTitle;

  /// No description provided for @mineMenuSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings and security options'**
  String get mineMenuSecuritySubtitle;

  /// No description provided for @mineMenuAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Luminous'**
  String get mineMenuAboutTitle;

  /// No description provided for @mineMenuAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version info and usage guide'**
  String get mineMenuAboutSubtitle;

  /// No description provided for @searchTitlePicker.
  ///
  /// In en, this message translates to:
  /// **'Select Medicine'**
  String get searchTitlePicker;

  /// No description provided for @searchTitleManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Search'**
  String get searchTitleManual;

  /// No description provided for @searchBadgePicker.
  ///
  /// In en, this message translates to:
  /// **'Medicine Library'**
  String get searchBadgePicker;

  /// No description provided for @searchBadgeManual.
  ///
  /// In en, this message translates to:
  /// **'Keyword Search'**
  String get searchBadgeManual;

  /// No description provided for @searchHeaderSubtitlePicker.
  ///
  /// In en, this message translates to:
  /// **'Search and select from backend medicine library'**
  String get searchHeaderSubtitlePicker;

  /// No description provided for @searchHeaderSubtitleManual.
  ///
  /// In en, this message translates to:
  /// **'Search by product name, approval number, or manufacturer'**
  String get searchHeaderSubtitleManual;

  /// No description provided for @searchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Product Name / Approval No. / Manufacturer'**
  String get searchInputHint;

  /// No description provided for @searchActionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchActionSearch;

  /// No description provided for @searchQueryModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Query Mode'**
  String get searchQueryModeTitle;

  /// No description provided for @searchQueryModeDetecting.
  ///
  /// In en, this message translates to:
  /// **'Checking network...'**
  String get searchQueryModeDetecting;

  /// No description provided for @searchQueryModeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current: {mode}'**
  String searchQueryModeCurrent(Object mode);

  /// No description provided for @searchQueryModeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get searchQueryModeOnline;

  /// No description provided for @searchQueryModeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get searchQueryModeLocal;

  /// No description provided for @searchDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get searchDatabaseTitle;

  /// No description provided for @searchDatabaseSourceNmpa.
  ///
  /// In en, this message translates to:
  /// **'NMPA'**
  String get searchDatabaseSourceNmpa;

  /// No description provided for @searchDatabaseSourceDrugbank.
  ///
  /// In en, this message translates to:
  /// **'Drugbank'**
  String get searchDatabaseSourceDrugbank;

  /// No description provided for @searchDatabaseCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'Current database: {database}. Drugbank is not connected yet. Online queries still use NMPA (MySQL).'**
  String searchDatabaseCurrentHint(Object database);

  /// No description provided for @searchDatabaseNotConnectedToast.
  ///
  /// In en, this message translates to:
  /// **'Drugbank is not connected yet. NMPA is still used.'**
  String get searchDatabaseNotConnectedToast;

  /// No description provided for @searchModeTagOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get searchModeTagOnline;

  /// No description provided for @searchModeTagLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get searchModeTagLocal;

  /// No description provided for @searchQuickTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get searchQuickTagsTitle;

  /// No description provided for @searchQuickTagAmoxicillin.
  ///
  /// In en, this message translates to:
  /// **'Amoxicillin'**
  String get searchQuickTagAmoxicillin;

  /// No description provided for @searchQuickTagIbuprofen.
  ///
  /// In en, this message translates to:
  /// **'Ibuprofen'**
  String get searchQuickTagIbuprofen;

  /// No description provided for @searchQuickTagVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get searchQuickTagVitaminD;

  /// No description provided for @searchQuickTagCephalosporin.
  ///
  /// In en, this message translates to:
  /// **'Cephalosporin'**
  String get searchQuickTagCephalosporin;

  /// No description provided for @searchQuickTagAntibiotic.
  ///
  /// In en, this message translates to:
  /// **'Antibiotic'**
  String get searchQuickTagAntibiotic;

  /// No description provided for @searchQuickTagGastroMedicine.
  ///
  /// In en, this message translates to:
  /// **'Stomach Medicine'**
  String get searchQuickTagGastroMedicine;

  /// No description provided for @searchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchHistoryTitle;

  /// No description provided for @searchHistoryClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchHistoryClearAction;

  /// No description provided for @searchHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No search history'**
  String get searchHistoryEmpty;

  /// No description provided for @searchResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResultTitle;

  /// No description provided for @searchGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Tips'**
  String get searchGuideTitle;

  /// No description provided for @searchGuideTipProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get searchGuideTipProductNameLabel;

  /// No description provided for @searchGuideTipProductNameExample.
  ///
  /// In en, this message translates to:
  /// **'Amoxicillin Capsules, Ibuprofen Tablets'**
  String get searchGuideTipProductNameExample;

  /// No description provided for @searchGuideTipApprovalNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Approval No.'**
  String get searchGuideTipApprovalNoLabel;

  /// No description provided for @searchGuideTipApprovalNoExample.
  ///
  /// In en, this message translates to:
  /// **'NMPA H20013191'**
  String get searchGuideTipApprovalNoExample;

  /// No description provided for @searchGuideTipManufacturerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get searchGuideTipManufacturerLabel;

  /// No description provided for @searchGuideTipManufacturerExample.
  ///
  /// In en, this message translates to:
  /// **'CSPC Group, CR Sanjiu'**
  String get searchGuideTipManufacturerExample;

  /// No description provided for @searchGuideTipDrugCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug Code'**
  String get searchGuideTipDrugCodeLabel;

  /// No description provided for @searchGuideTipDrugCodeExample.
  ///
  /// In en, this message translates to:
  /// **'86901000000000 (national code)'**
  String get searchGuideTipDrugCodeExample;

  /// No description provided for @searchReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Press \"Search\" or Enter to query the medicine database'**
  String get searchReadyHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try searching again with product name, approval number, or manufacturer'**
  String get searchEmptySubtitle;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Failed'**
  String get searchErrorTitle;

  /// No description provided for @searchRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetryAction;

  /// No description provided for @searchCommitEmptyToast.
  ///
  /// In en, this message translates to:
  /// **'Please enter product name, approval number, or manufacturer before searching'**
  String get searchCommitEmptyToast;

  /// No description provided for @searchHistoryClearedToast.
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get searchHistoryClearedToast;

  /// No description provided for @searchApprovalNoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Approval No.: {approvalNo}'**
  String searchApprovalNoPrefix(Object approvalNo);

  /// No description provided for @searchAlreadyAddedToast.
  ///
  /// In en, this message translates to:
  /// **'This medicine is already in My Medicines'**
  String get searchAlreadyAddedToast;

  /// No description provided for @searchAddedPendingSyncToast.
  ///
  /// In en, this message translates to:
  /// **'Added to My Medicines. Pending cloud sync'**
  String get searchAddedPendingSyncToast;

  /// No description provided for @searchAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Added to My Medicines'**
  String get searchAddedToast;

  /// No description provided for @searchAddFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Add failed. Please try again'**
  String get searchAddFailedToast;

  /// No description provided for @searchResultAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get searchResultAddedLabel;

  /// No description provided for @searchResultAddActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to My Medicines'**
  String get searchResultAddActionLabel;

  /// No description provided for @reminderListCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders'**
  String reminderListCountLabel(int count);

  /// No description provided for @reminderListEnabledCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} enabled'**
  String reminderListEnabledCountLabel(int count);

  /// No description provided for @reminderListDisabledCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} disabled'**
  String reminderListDisabledCountLabel(int count);

  /// No description provided for @reminderRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Effective range: {range}'**
  String reminderRangeLabel(Object range);

  /// No description provided for @reminderRangeUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get reminderRangeUnlimited;

  /// No description provided for @reminderRangeBetween.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String reminderRangeBetween(Object start, Object end);

  /// No description provided for @reminderRangeFrom.
  ///
  /// In en, this message translates to:
  /// **'From {start}'**
  String reminderRangeFrom(Object start);

  /// No description provided for @reminderRangeUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {end}'**
  String reminderRangeUntil(Object end);

  /// No description provided for @splashTitleMain.
  ///
  /// In en, this message translates to:
  /// **'Smart Medication'**
  String get splashTitleMain;

  /// No description provided for @splashTitleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luminous · Health Guard'**
  String get splashTitleSubtitle;

  /// No description provided for @splashBadgeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get splashBadgeScan;

  /// No description provided for @splashBadgeReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get splashBadgeReminder;

  /// No description provided for @splashFooterBrand.
  ///
  /// In en, this message translates to:
  /// **'Luminous Smart Medication Assistant'**
  String get splashFooterBrand;

  /// No description provided for @splashFooterSlogan.
  ///
  /// In en, this message translates to:
  /// **'Safe · Convenient · Smart'**
  String get splashFooterSlogan;

  /// No description provided for @scanSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get scanSourceCamera;

  /// No description provided for @scanSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Album'**
  String get scanSourceGallery;

  /// No description provided for @scanSourceCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scanSourceCancel;

  /// No description provided for @scanCameraPermissionDeniedToast.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Please allow it and try again'**
  String get scanCameraPermissionDeniedToast;

  /// No description provided for @scanReadImageFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Failed to read image. Please try again'**
  String get scanReadImageFailedToast;

  /// No description provided for @scanPageTitleActions.
  ///
  /// In en, this message translates to:
  /// **'Medicine Scan'**
  String get scanPageTitleActions;

  /// No description provided for @scanPageTitleResult.
  ///
  /// In en, this message translates to:
  /// **'Scan Result'**
  String get scanPageTitleResult;

  /// No description provided for @scanPhotoPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan medicine'**
  String get scanPhotoPlaceholderTitle;

  /// No description provided for @scanHeaderSubtitleScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning, please wait...'**
  String get scanHeaderSubtitleScanning;

  /// No description provided for @scanHeaderSubtitleNoResult.
  ///
  /// In en, this message translates to:
  /// **'Upload an image and Doubao vision model will identify medicine information'**
  String get scanHeaderSubtitleNoResult;

  /// No description provided for @scanHeaderSubtitleResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} candidates identified'**
  String scanHeaderSubtitleResultCount(int count);

  /// No description provided for @scanRetakeAction.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanRetakeAction;

  /// No description provided for @scanInfoNoResult.
  ///
  /// In en, this message translates to:
  /// **'Choose a medicine box or package image, then the backend will send it to Doubao vision model for recognition.\nIf multiple candidates are found, select the closest one first before taking further actions.'**
  String get scanInfoNoResult;

  /// No description provided for @scanInfoNoCandidate.
  ///
  /// In en, this message translates to:
  /// **'No valid result identified. Please try again with a clearer image.'**
  String get scanInfoNoCandidate;

  /// No description provided for @scanResultSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition Results'**
  String get scanResultSectionTitle;

  /// No description provided for @scanApprovalNoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Approval No.: {approvalNo}'**
  String scanApprovalNoPrefix(Object approvalNo);

  /// No description provided for @scanActionRescanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanActionRescanLabel;

  /// No description provided for @scanActionRescanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retake or choose another image'**
  String get scanActionRescanSubtitle;

  /// No description provided for @scanActionSaveAlbumLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to Album'**
  String get scanActionSaveAlbumLabel;

  /// No description provided for @scanActionSaveAlbumSavingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get scanActionSaveAlbumSavingSubtitle;

  /// No description provided for @scanActionSaveAlbumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save to in-app album list'**
  String get scanActionSaveAlbumSubtitle;

  /// No description provided for @scanActionSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search This Medicine'**
  String get scanActionSearchLabel;

  /// No description provided for @scanActionSearchNoKeywordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Selected candidate has no searchable fields'**
  String get scanActionSearchNoKeywordSubtitle;

  /// No description provided for @scanActionSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open Search page and query automatically'**
  String get scanActionSearchSubtitle;

  /// No description provided for @scanActionCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scanActionCancelLabel;

  /// No description provided for @scanActionCancelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close current recognition page'**
  String get scanActionCancelSubtitle;

  /// No description provided for @scanSavedToAlbumToast.
  ///
  /// In en, this message translates to:
  /// **'Added to in-app album'**
  String get scanSavedToAlbumToast;

  /// No description provided for @scanSaveToAlbumFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to album'**
  String get scanSaveToAlbumFailedToast;

  /// No description provided for @scanSearchMissingKeywordToast.
  ///
  /// In en, this message translates to:
  /// **'Selected candidate has no searchable fields'**
  String get scanSearchMissingKeywordToast;

  /// No description provided for @settingsDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplayTitle;

  /// No description provided for @settingsDisplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme mode and style will affect Home, Medicines, Album, and overlays together'**
  String get settingsDisplaySubtitle;

  /// No description provided for @settingsOrnamentFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere Ornaments'**
  String get settingsOrnamentFieldTitle;

  /// No description provided for @settingsOrnamentFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supports transparency 0%, 25%, 50%, 75%, and 100% (100% means hidden)'**
  String get settingsOrnamentFieldSubtitle;

  /// No description provided for @settingsOrnamentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get settingsOrnamentPreviewTitle;

  /// No description provided for @settingsOrnamentPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The gradient block above updates instantly with your ornament intensity'**
  String get settingsOrnamentPreviewSubtitle;

  /// No description provided for @settingsOrnamentPresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Preset Levels'**
  String get settingsOrnamentPresetTitle;

  /// No description provided for @settingsOrnamentPresetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch common transparency presets quickly for immediate visual tuning'**
  String get settingsOrnamentPresetSubtitle;

  /// No description provided for @settingsOrnamentSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Transparency'**
  String get settingsOrnamentSliderTitle;

  /// No description provided for @settingsOrnamentSliderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust from 0%-100% (5% steps) for fine-grained control per device'**
  String get settingsOrnamentSliderSubtitle;

  /// No description provided for @settingsOrnamentSliderMinLabel.
  ///
  /// In en, this message translates to:
  /// **'0% (Most Visible)'**
  String get settingsOrnamentSliderMinLabel;

  /// No description provided for @settingsOrnamentSliderMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'100% (Hidden)'**
  String get settingsOrnamentSliderMaxLabel;

  /// No description provided for @settingsOrnamentCurrentPercent.
  ///
  /// In en, this message translates to:
  /// **'Current ornament transparency: {percent}%'**
  String settingsOrnamentCurrentPercent(Object percent);

  /// No description provided for @settingsOrnamentOptionTransparency0.
  ///
  /// In en, this message translates to:
  /// **'Transparency 0%'**
  String get settingsOrnamentOptionTransparency0;

  /// No description provided for @settingsOrnamentOptionTransparency25.
  ///
  /// In en, this message translates to:
  /// **'Transparency 25%'**
  String get settingsOrnamentOptionTransparency25;

  /// No description provided for @settingsOrnamentOptionTransparency50.
  ///
  /// In en, this message translates to:
  /// **'Transparency 50%'**
  String get settingsOrnamentOptionTransparency50;

  /// No description provided for @settingsOrnamentOptionTransparency75.
  ///
  /// In en, this message translates to:
  /// **'Transparency 75%'**
  String get settingsOrnamentOptionTransparency75;

  /// No description provided for @settingsOrnamentOptionTransparency100.
  ///
  /// In en, this message translates to:
  /// **'Transparency 100% (Hidden)'**
  String get settingsOrnamentOptionTransparency100;

  /// No description provided for @settingsOrnamentCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current atmosphere ornaments: {option}'**
  String settingsOrnamentCurrent(Object option);

  /// No description provided for @settingsHubHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Preference Settings'**
  String get settingsHubHeroTitle;

  /// No description provided for @settingsHubHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter theme and language settings here. More modules like notifications and privacy can be added later.'**
  String get settingsHubHeroSubtitle;

  /// No description provided for @settingsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Preferences'**
  String get settingsHeroTitle;

  /// No description provided for @settingsHeroMoodDark.
  ///
  /// In en, this message translates to:
  /// **'Night-friendly visuals are active now, and pages follow the current dark rhythm.'**
  String get settingsHeroMoodDark;

  /// No description provided for @settingsHeroMoodLight.
  ///
  /// In en, this message translates to:
  /// **'Light visuals are active now, keeping pages clear and softly layered.'**
  String get settingsHeroMoodLight;

  /// No description provided for @settingsHeroAccountLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get settingsHeroAccountLoggedIn;

  /// No description provided for @settingsHeroAccountLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get settingsHeroAccountLoggedOut;

  /// No description provided for @settingsHeroLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Local mode'**
  String get settingsHeroLocalMode;

  /// No description provided for @settingsHeroLoggedInHint.
  ///
  /// In en, this message translates to:
  /// **'You can keep adjusting theme styles. Account status stays on this device.'**
  String get settingsHeroLoggedInHint;

  /// No description provided for @settingsHeroLoggedOutHint.
  ///
  /// In en, this message translates to:
  /// **'The app works normally now. Login only enables extra lightweight sync.'**
  String get settingsHeroLoggedOutHint;

  /// No description provided for @settingsThemeModeFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeModeFieldTitle;

  /// No description provided for @settingsThemeModeFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow system, force light, or force dark'**
  String get settingsThemeModeFieldSubtitle;

  /// No description provided for @settingsThemeModeOptionSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get settingsThemeModeOptionSystem;

  /// No description provided for @settingsThemeModeOptionLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeOptionLight;

  /// No description provided for @settingsThemeModeOptionDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeOptionDark;

  /// No description provided for @settingsThemeModeCurrentSystem.
  ///
  /// In en, this message translates to:
  /// **'Following system. System is using {appearance} mode'**
  String settingsThemeModeCurrentSystem(Object appearance);

  /// No description provided for @settingsThemeModeCurrentFixed.
  ///
  /// In en, this message translates to:
  /// **'Currently fixed to {appearance} mode'**
  String settingsThemeModeCurrentFixed(Object appearance);

  /// No description provided for @settingsThemeStyleFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Style'**
  String get settingsThemeStyleFieldTitle;

  /// No description provided for @settingsThemeStyleFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soft Glow, Moon Mist, Divine Tree, Illusion, and Light Sand affect ambient, banner, and section visuals together'**
  String get settingsThemeStyleFieldSubtitle;

  /// No description provided for @settingsThemeStyleInUseBadge.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get settingsThemeStyleInUseBadge;

  /// No description provided for @settingsThemeStyleOptionSoftGlow.
  ///
  /// In en, this message translates to:
  /// **'Soft Glow'**
  String get settingsThemeStyleOptionSoftGlow;

  /// No description provided for @settingsThemeStyleOptionMoonMist.
  ///
  /// In en, this message translates to:
  /// **'Moon Mist'**
  String get settingsThemeStyleOptionMoonMist;

  /// No description provided for @settingsThemeStyleOptionDivineTree.
  ///
  /// In en, this message translates to:
  /// **'Divine Tree'**
  String get settingsThemeStyleOptionDivineTree;

  /// No description provided for @settingsThemeStyleOptionIllusion.
  ///
  /// In en, this message translates to:
  /// **'Illusion'**
  String get settingsThemeStyleOptionIllusion;

  /// No description provided for @settingsThemeStyleOptionLightSand.
  ///
  /// In en, this message translates to:
  /// **'Light Sand'**
  String get settingsThemeStyleOptionLightSand;

  /// No description provided for @settingsThemeStyleOptionSoftGlowDesc.
  ///
  /// In en, this message translates to:
  /// **'Soft blue, pale violet, and warm gold together. Bright but gentle.'**
  String get settingsThemeStyleOptionSoftGlowDesc;

  /// No description provided for @settingsThemeStyleOptionMoonMistDesc.
  ///
  /// In en, this message translates to:
  /// **'A blue base infused with subtle violet haze, like moonlit cool veils.'**
  String get settingsThemeStyleOptionMoonMistDesc;

  /// No description provided for @settingsThemeStyleOptionDivineTreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Yellow-green with soft gold accents, like sunlight through leaves.'**
  String get settingsThemeStyleOptionDivineTreeDesc;

  /// No description provided for @settingsThemeStyleOptionIllusionDesc.
  ///
  /// In en, this message translates to:
  /// **'Purple-led palette with hints of blue glow, like neon edges in night mist.'**
  String get settingsThemeStyleOptionIllusionDesc;

  /// No description provided for @settingsThemeStyleOptionLightSandDesc.
  ///
  /// In en, this message translates to:
  /// **'Tea, dusty rose, and clay tones. Warm and restrained like dry sandstone and old fabric.'**
  String get settingsThemeStyleOptionLightSandDesc;

  /// No description provided for @medicineDetailAiNoContentToast.
  ///
  /// In en, this message translates to:
  /// **'AI returned no content'**
  String get medicineDetailAiNoContentToast;

  /// No description provided for @medicineDetailAiNetworkErrorToast.
  ///
  /// In en, this message translates to:
  /// **'Network request failed. Please check your connection and try again.'**
  String get medicineDetailAiNetworkErrorToast;

  /// No description provided for @medicineDetailPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Details'**
  String get medicineDetailPageTitle;

  /// No description provided for @medicineDetailHeaderRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get medicineDetailHeaderRefreshing;

  /// No description provided for @medicineDetailHeaderRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get medicineDetailHeaderRefresh;

  /// No description provided for @medicineDetailLabelApprovalNo.
  ///
  /// In en, this message translates to:
  /// **'Approval No.'**
  String get medicineDetailLabelApprovalNo;

  /// No description provided for @medicineDetailLabelDrugCode.
  ///
  /// In en, this message translates to:
  /// **'Drug Code'**
  String get medicineDetailLabelDrugCode;

  /// No description provided for @medicineDetailHeaderBadge.
  ///
  /// In en, this message translates to:
  /// **'Medicine Info'**
  String get medicineDetailHeaderBadge;

  /// No description provided for @medicineDetailInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get medicineDetailInfoTitle;

  /// No description provided for @medicineDetailLabelProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get medicineDetailLabelProductName;

  /// No description provided for @medicineDetailLabelDosageForm.
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get medicineDetailLabelDosageForm;

  /// No description provided for @medicineDetailLabelSpecification.
  ///
  /// In en, this message translates to:
  /// **'Specification'**
  String get medicineDetailLabelSpecification;

  /// No description provided for @medicineDetailLabelMarketingAuthorizationHolder.
  ///
  /// In en, this message translates to:
  /// **'Marketing Authorization Holder'**
  String get medicineDetailLabelMarketingAuthorizationHolder;

  /// No description provided for @medicineDetailLabelManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get medicineDetailLabelManufacturer;

  /// No description provided for @medicineDetailLabelDrugCodeRemark.
  ///
  /// In en, this message translates to:
  /// **'Drug Code Remark'**
  String get medicineDetailLabelDrugCodeRemark;

  /// No description provided for @medicineDetailAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get medicineDetailAiTitle;

  /// No description provided for @medicineDetailAiRefetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch Again'**
  String get medicineDetailAiRefetch;

  /// No description provided for @medicineDetailAiFetch.
  ///
  /// In en, this message translates to:
  /// **'Get More Details'**
  String get medicineDetailAiFetch;

  /// No description provided for @medicineDetailAiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Get More Details\" and the backend will use AI to supplement leaflet information not stored in the database, such as ingredients, contraindications, and precautions.'**
  String get medicineDetailAiPlaceholder;

  /// No description provided for @medicineDetailSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Notice'**
  String get medicineDetailSafetyTitle;

  /// No description provided for @medicineDetailSafetyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Information in this app is for health education and reference only, and cannot replace a doctor\'s diagnosis or prescription. If you feel unwell or are taking medication, follow medical advice and consult professionals.'**
  String get medicineDetailSafetyDisclaimer;

  /// No description provided for @drugLoadFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Failed to load My Medicines'**
  String get drugLoadFailedToast;

  /// No description provided for @drugDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Removed from My Medicines'**
  String get drugDeletedToast;

  /// No description provided for @drugDeleteFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get drugDeleteFailedToast;

  /// No description provided for @drugPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select medicine'**
  String get drugPickerTitle;

  /// No description provided for @drugQuickEntrySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Search'**
  String get drugQuickEntrySearchTitle;

  /// No description provided for @drugQuickEntrySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name / Approval No.'**
  String get drugQuickEntrySearchSubtitle;

  /// No description provided for @drugQuickEntryScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Scan'**
  String get drugQuickEntryScanTitle;

  /// No description provided for @drugQuickEntryScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Recognition'**
  String get drugQuickEntryScanSubtitle;

  /// No description provided for @drugQuickEntryAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get drugQuickEntryAiTitle;

  /// No description provided for @drugQuickEntryAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Usage & Warnings'**
  String get drugQuickEntryAiSubtitle;

  /// No description provided for @drugSearchEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Medicines'**
  String get drugSearchEntryTitle;

  /// No description provided for @drugSearchEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supports product name / approval number / manufacturer'**
  String get drugSearchEntrySubtitle;

  /// No description provided for @drugQuickSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get drugQuickSectionTitle;

  /// No description provided for @drugQuickSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep frequent actions together for a lighter, smoother page flow'**
  String get drugQuickSectionSubtitle;

  /// No description provided for @drugMyMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get drugMyMedicinesTitle;

  /// No description provided for @drugEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get drugEmptyTitle;

  /// No description provided for @drugEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use \"Manual Search\" or \"Drug Scan\"\nto add medicines here'**
  String get drugEmptySubtitle;

  /// No description provided for @drugUnknownMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Unknown medicine'**
  String get drugUnknownMedicineName;

  /// No description provided for @drugApprovalNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Approval No.'**
  String get drugApprovalNoLabel;

  /// No description provided for @drugSourceScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo Recognition'**
  String get drugSourceScanLabel;

  /// No description provided for @drugSourceManualLabel.
  ///
  /// In en, this message translates to:
  /// **'Manual Search'**
  String get drugSourceManualLabel;

  /// No description provided for @legalUserAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get legalUserAgreementTitle;

  /// No description provided for @legalUserAgreementSummary.
  ///
  /// In en, this message translates to:
  /// **'Before using Luminous Health Assistant, please review account rules, service boundaries, and usage requirements.'**
  String get legalUserAgreementSummary;

  /// No description provided for @legalUserAgreementSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Scope of this agreement'**
  String get legalUserAgreementSection1Title;

  /// No description provided for @legalUserAgreementSection1Body.
  ///
  /// In en, this message translates to:
  /// **'This agreement applies to your use of Luminous Health Assistant features, including health records, medicine lookup, AI-assisted analysis, and reminder management. By registering, logging in, or continuing to use the app, you are deemed to have read and agreed to this agreement.'**
  String get legalUserAgreementSection1Body;

  /// No description provided for @legalUserAgreementSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Service description'**
  String get legalUserAgreementSection2Title;

  /// No description provided for @legalUserAgreementSection2Body.
  ///
  /// In en, this message translates to:
  /// **'This app provides health information organization and reference support only. It does not constitute diagnosis, prescription, or medical advice. For high-risk matters such as medication use, allergies, pregnancy, or chronic disease management, always follow doctors, pharmacists, and official package instructions.'**
  String get legalUserAgreementSection2Body;

  /// No description provided for @legalUserAgreementSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Account and security'**
  String get legalUserAgreementSection3Title;

  /// No description provided for @legalUserAgreementSection3Body.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for safeguarding your login credentials and must not lend, rent, or transfer your account. Risks caused by credential disclosure, sign-in on insecure devices, or failure to sign out are your responsibility.'**
  String get legalUserAgreementSection3Body;

  /// No description provided for @legalUserAgreementSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Acceptable use'**
  String get legalUserAgreementSection4Title;

  /// No description provided for @legalUserAgreementSection4Body.
  ///
  /// In en, this message translates to:
  /// **'You must not use this app for unlawful or non-compliant activities, including but not limited to identity forgery, malicious uploads, bulk API scraping, service interference, or dissemination of false medical information. We reserve the right to limit features when abnormal use is detected.'**
  String get legalUserAgreementSection4Body;

  /// No description provided for @legalUserAgreementSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. AI content notice'**
  String get legalUserAgreementSection5Title;

  /// No description provided for @legalUserAgreementSection5Body.
  ///
  /// In en, this message translates to:
  /// **'AI interpretations, recognition results, and safety-assist content may be affected by model capability, input image quality, and completeness of medicine information, and may contain bias, omissions, or inapplicable suggestions. You should make independent judgments with package instructions and professional advice.'**
  String get legalUserAgreementSection5Body;

  /// No description provided for @legalUserAgreementSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Disclaimer'**
  String get legalUserAgreementSection6Title;

  /// No description provided for @legalUserAgreementSection6Body.
  ///
  /// In en, this message translates to:
  /// **'For service interruptions, result deviations, or data delays caused by network outages, third-party service failures, user input errors, device compatibility issues, or force majeure, we will try our best to recover services but do not assume medical liability for direct or indirect losses arising therefrom.'**
  String get legalUserAgreementSection6Body;

  /// No description provided for @legalUserAgreementSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Agreement updates'**
  String get legalUserAgreementSection7Title;

  /// No description provided for @legalUserAgreementSection7Body.
  ///
  /// In en, this message translates to:
  /// **'This agreement may be updated as features evolve. Updated terms will be presented in-app. Continued use of the app means acceptance of the updated agreement. If you disagree with updates, you should stop using related services.'**
  String get legalUserAgreementSection7Body;

  /// No description provided for @legalPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicyTitle;

  /// No description provided for @legalPrivacyPolicySummary.
  ///
  /// In en, this message translates to:
  /// **'This page explains what information we collect, how we use it, and how you can manage it.'**
  String get legalPrivacyPolicySummary;

  /// No description provided for @legalPrivacyPolicySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information we collect'**
  String get legalPrivacyPolicySection1Title;

  /// No description provided for @legalPrivacyPolicySection1Body.
  ///
  /// In en, this message translates to:
  /// **'When you use account, medicine recognition, reminder plans, and health record features, we may collect information you provide, such as phone number, email, nickname, medicine names, reminder plans, scan images, and necessary device basics.'**
  String get legalPrivacyPolicySection1Body;

  /// No description provided for @legalPrivacyPolicySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How information is used'**
  String get legalPrivacyPolicySection2Title;

  /// No description provided for @legalPrivacyPolicySection2Body.
  ///
  /// In en, this message translates to:
  /// **'Information is mainly used for account identification, personal data sync, medicine search and AI analysis, reminder generation, incident troubleshooting, and product optimization. We do not use your personal health data for unrelated marketing.'**
  String get legalPrivacyPolicySection2Body;

  /// No description provided for @legalPrivacyPolicySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Images and AI requests'**
  String get legalPrivacyPolicySection3Title;

  /// No description provided for @legalPrivacyPolicySection3Body.
  ///
  /// In en, this message translates to:
  /// **'When you actively use scan recognition, AI medicine interpretation, or safety assist, related images, text, and structured parameters are sent to backend and model services for processing. Avoid uploading images containing unrelated sensitive information such as ID cards, bank cards, or home addresses.'**
  String get legalPrivacyPolicySection3Body;

  /// No description provided for @legalPrivacyPolicySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Local storage'**
  String get legalPrivacyPolicySection4Title;

  /// No description provided for @legalPrivacyPolicySection4Body.
  ///
  /// In en, this message translates to:
  /// **'To reduce repeated sign-ins and improve experience, the app securely caches necessary local data, such as login state, profile summary, part of business records, and theme preferences. Login-state data is cleared when you sign out.'**
  String get legalPrivacyPolicySection4Body;

  /// No description provided for @legalPrivacyPolicySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Information sharing'**
  String get legalPrivacyPolicySection5Title;

  /// No description provided for @legalPrivacyPolicySection5Body.
  ///
  /// In en, this message translates to:
  /// **'Except when required by law, necessary for fulfilling services you request, or required for security protection, we do not sell or publicly disclose your personal information to unrelated third parties. If third-party cloud services are involved, processing is limited to the minimum necessary scope.'**
  String get legalPrivacyPolicySection5Body;

  /// No description provided for @legalPrivacyPolicySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Your rights'**
  String get legalPrivacyPolicySection6Title;

  /// No description provided for @legalPrivacyPolicySection6Body.
  ///
  /// In en, this message translates to:
  /// **'You can manage your information through in-app login, logout, profile updates, and local-data deletion. As more data-management capabilities are introduced, we will gradually support export, deletion, and finer-grained authorization controls.'**
  String get legalPrivacyPolicySection6Body;

  /// No description provided for @legalPrivacyPolicySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Contact and updates'**
  String get legalPrivacyPolicySection7Title;

  /// No description provided for @legalPrivacyPolicySection7Body.
  ///
  /// In en, this message translates to:
  /// **'If this privacy policy is materially updated, we will provide updated notices in-app. Continued use of related features means you have been informed of and accept the updated policy.'**
  String get legalPrivacyPolicySection7Body;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Assist'**
  String get safetyTitle;

  /// No description provided for @safetyHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize single-medicine guidance and two-medicine interaction alerts in a gentler way'**
  String get safetyHeroSubtitle;

  /// No description provided for @safetyModePair.
  ///
  /// In en, this message translates to:
  /// **'Two-medicine interaction'**
  String get safetyModePair;

  /// No description provided for @safetyModeSingle.
  ///
  /// In en, this message translates to:
  /// **'Single-medicine guidance'**
  String get safetyModeSingle;

  /// No description provided for @safetySelectedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for medicine selection'**
  String get safetySelectedWaiting;

  /// No description provided for @safetySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} medicines selected'**
  String safetySelectedCount(int count);

  /// No description provided for @safetyCloudWithContext.
  ///
  /// In en, this message translates to:
  /// **'Can include account context'**
  String get safetyCloudWithContext;

  /// No description provided for @safetyCloudQuery.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI query'**
  String get safetyCloudQuery;

  /// No description provided for @safetyModeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Query Mode'**
  String get safetyModeCardTitle;

  /// No description provided for @safetyPickCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Medicines'**
  String get safetyPickCardTitle;

  /// No description provided for @safetyPickPlaceholderA.
  ///
  /// In en, this message translates to:
  /// **'Please select Medicine A'**
  String get safetyPickPlaceholderA;

  /// No description provided for @safetyPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select from My Medicines or search library'**
  String get safetyPickSubtitle;

  /// No description provided for @safetyPickBadgeA.
  ///
  /// In en, this message translates to:
  /// **'Medicine A'**
  String get safetyPickBadgeA;

  /// No description provided for @safetyPickPlaceholderB.
  ///
  /// In en, this message translates to:
  /// **'Please select Medicine B'**
  String get safetyPickPlaceholderB;

  /// No description provided for @safetyPickBadgeB.
  ///
  /// In en, this message translates to:
  /// **'Medicine B'**
  String get safetyPickBadgeB;

  /// No description provided for @safetyActionCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Query'**
  String get safetyActionCardTitle;

  /// No description provided for @safetyActionQueryPair.
  ///
  /// In en, this message translates to:
  /// **'Check Two-medicine Interaction'**
  String get safetyActionQueryPair;

  /// No description provided for @safetyActionQuerySingle.
  ///
  /// In en, this message translates to:
  /// **'Check Medication Advice'**
  String get safetyActionQuerySingle;

  /// No description provided for @safetyResultCardTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Result'**
  String get safetyResultCardTitle;

  /// No description provided for @safetyResultPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'After selecting medicines, tap \"Start Query\" and the backend will call AI to return medication advice or interaction alerts.'**
  String get safetyResultPlaceholder;

  /// No description provided for @safetyPickerTitleA.
  ///
  /// In en, this message translates to:
  /// **'Select Medicine A'**
  String get safetyPickerTitleA;

  /// No description provided for @safetyPickerTitleB.
  ///
  /// In en, this message translates to:
  /// **'Select Medicine B'**
  String get safetyPickerTitleB;

  /// No description provided for @safetyToastSelectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Please select a medicine first'**
  String get safetyToastSelectMedicine;

  /// No description provided for @safetyToastSelectSecondMedicine.
  ///
  /// In en, this message translates to:
  /// **'Please select one more medicine'**
  String get safetyToastSelectSecondMedicine;

  /// No description provided for @safetyToastAiNoContent.
  ///
  /// In en, this message translates to:
  /// **'AI returned no content'**
  String get safetyToastAiNoContent;

  /// No description provided for @safetyDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Notice'**
  String get safetyDisclaimerTitle;

  /// No description provided for @safetyDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This feature uses AI-generated content for health education and reference only, and cannot replace a doctor\'s diagnosis or prescription. If you feel unwell or are taking medication, follow medical advice and consult professionals.'**
  String get safetyDisclaimerText;

  /// No description provided for @pickerLoadFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Failed to load My Medicines'**
  String get pickerLoadFailedToast;

  /// No description provided for @pickerHintLocalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Local medicine library is currently empty'**
  String get pickerHintLocalEmpty;

  /// No description provided for @pickerHintLocalCount.
  ///
  /// In en, this message translates to:
  /// **'Local library has {count} items'**
  String pickerHintLocalCount(int count);

  /// No description provided for @pickerHintLocalPriority.
  ///
  /// In en, this message translates to:
  /// **'Prefer local selection'**
  String get pickerHintLocalPriority;

  /// No description provided for @pickerHintCloudFallback.
  ///
  /// In en, this message translates to:
  /// **'Use cloud lookup when needed'**
  String get pickerHintCloudFallback;

  /// No description provided for @pickerSearchBadge.
  ///
  /// In en, this message translates to:
  /// **'Cloud Medicine Library'**
  String get pickerSearchBadge;

  /// No description provided for @pickerSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Manually Search Library'**
  String get pickerSearchTitle;

  /// No description provided for @pickerSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search in cloud and bring the result back to this flow directly, useful for quick lookup before local save.'**
  String get pickerSearchSubtitle;

  /// No description provided for @pickerMyMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get pickerMyMedicinesTitle;

  /// No description provided for @pickerCount.
  ///
  /// In en, this message translates to:
  /// **'Total {count} items'**
  String pickerCount(int count);

  /// No description provided for @pickerSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get pickerSyncing;

  /// No description provided for @pickerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No local medicine records yet'**
  String get pickerEmptyTitle;

  /// No description provided for @pickerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can first search in the cloud medicine library, or save frequently used medicines here later.'**
  String get pickerEmptySubtitle;

  /// No description provided for @albumHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition Album'**
  String get albumHeaderTitle;

  /// No description provided for @albumHeaderSubtitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'New recognition records will be archived here automatically'**
  String get albumHeaderSubtitleEmpty;

  /// No description provided for @albumHeaderSubtitleNonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Original images stay local. Only thumbnails and recognition results sync to cloud'**
  String get albumHeaderSubtitleNonEmpty;

  /// No description provided for @albumHeaderChipWaitingFirstRecord.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first record'**
  String get albumHeaderChipWaitingFirstRecord;

  /// No description provided for @albumHeaderChipRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String albumHeaderChipRecordCount(int count);

  /// No description provided for @albumHeaderChipNoOriginal.
  ///
  /// In en, this message translates to:
  /// **'No original image archives'**
  String get albumHeaderChipNoOriginal;

  /// No description provided for @albumHeaderChipOriginalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} originals'**
  String albumHeaderChipOriginalCount(int count);

  /// No description provided for @albumHeaderChipCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Lightweight cloud sync'**
  String get albumHeaderChipCloudSync;

  /// No description provided for @albumHeaderChipLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local-only storage'**
  String get albumHeaderChipLocalOnly;

  /// No description provided for @albumErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while syncing album'**
  String get albumErrorTitle;

  /// No description provided for @albumErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try loading local records again'**
  String get albumErrorHint;

  /// No description provided for @albumEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get albumEmptyTitle;

  /// No description provided for @albumEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo in \"Medicine Scan\" and it will be saved here automatically'**
  String get albumEmptySubtitle;

  /// No description provided for @albumEmptyChipAutoArchive.
  ///
  /// In en, this message translates to:
  /// **'Auto-archived after scan'**
  String get albumEmptyChipAutoArchive;

  /// No description provided for @albumEmptyChipLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Original images stay on this device'**
  String get albumEmptyChipLocalOnly;

  /// No description provided for @albumLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable lightweight sync'**
  String get albumLoginTitle;

  /// No description provided for @albumLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After login, thumbnails and recognition results can sync to cloud while original images remain on this device'**
  String get albumLoginSubtitle;

  /// No description provided for @albumLoginChipNoUpload.
  ///
  /// In en, this message translates to:
  /// **'Original images not uploaded'**
  String get albumLoginChipNoUpload;

  /// No description provided for @albumLoginChipLightweightSync.
  ///
  /// In en, this message translates to:
  /// **'Sync lightweight results only'**
  String get albumLoginChipLightweightSync;

  /// No description provided for @albumLoginActionSyncAfterLogin.
  ///
  /// In en, this message translates to:
  /// **'Sync after login'**
  String get albumLoginActionSyncAfterLogin;

  /// No description provided for @albumLoginActionLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get albumLoginActionLogin;

  /// No description provided for @albumCardStatusLocalOriginal.
  ///
  /// In en, this message translates to:
  /// **'Local original'**
  String get albumCardStatusLocalOriginal;

  /// No description provided for @albumCardStatusThumbnailOnly.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail only'**
  String get albumCardStatusThumbnailOnly;

  /// No description provided for @albumCardSubtitleTapForDetail.
  ///
  /// In en, this message translates to:
  /// **'Tap to view recognition result and medicine details'**
  String get albumCardSubtitleTapForDetail;

  /// No description provided for @albumApprovalNoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Approval No.: {approvalNo}'**
  String albumApprovalNoPrefix(Object approvalNo);

  /// No description provided for @albumCardTagRescannable.
  ///
  /// In en, this message translates to:
  /// **'Rescannable'**
  String get albumCardTagRescannable;

  /// No description provided for @albumCardTagLightRecord.
  ///
  /// In en, this message translates to:
  /// **'Lightweight record'**
  String get albumCardTagLightRecord;

  /// No description provided for @albumPreviewNoApprovalNo.
  ///
  /// In en, this message translates to:
  /// **'No approval number'**
  String get albumPreviewNoApprovalNo;

  /// No description provided for @albumPreviewTagOriginalRescannable.
  ///
  /// In en, this message translates to:
  /// **'Local original can be rescanned'**
  String get albumPreviewTagOriginalRescannable;

  /// No description provided for @albumPreviewTagThumbnailOnly.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail only'**
  String get albumPreviewTagThumbnailOnly;

  /// No description provided for @albumPreviewTagRecordedAt.
  ///
  /// In en, this message translates to:
  /// **'Recorded on {date}'**
  String albumPreviewTagRecordedAt(Object date);

  /// No description provided for @albumPreviewLowQualityNotice.
  ///
  /// In en, this message translates to:
  /// **'This record only keeps a thumbnail, so high-quality rescanning is unavailable.'**
  String get albumPreviewLowQualityNotice;

  /// No description provided for @albumPreviewOpenDetailAction.
  ///
  /// In en, this message translates to:
  /// **'View Medicine Details'**
  String get albumPreviewOpenDetailAction;

  /// No description provided for @albumPreviewRescanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get albumPreviewRescanAction;

  /// No description provided for @albumDetailMissingIdentityToast.
  ///
  /// In en, this message translates to:
  /// **'This record is missing drugCode/approvalNo, cannot open details'**
  String get albumDetailMissingIdentityToast;

  /// No description provided for @albumRescanThumbnailOnlyToast.
  ///
  /// In en, this message translates to:
  /// **'This record only keeps a thumbnail, so high-quality rescanning is unavailable'**
  String get albumRescanThumbnailOnlyToast;

  /// No description provided for @albumRescanReadOriginalFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Failed to read original image, cannot rescan'**
  String get albumRescanReadOriginalFailedToast;
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
