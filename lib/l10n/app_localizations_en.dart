// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luminous';

  @override
  String get tabToday => 'Today';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabMedicine => 'Medicine';

  @override
  String get tabMine => 'Mine';

  @override
  String get tabMore => 'More';

  @override
  String get recordPageDescription =>
      'Calendar, timeline, and multi-type daily records will grow here.';

  @override
  String get recordSectionTitle => 'Daily timeline';

  @override
  String get recordSectionSubtitle =>
      'The first rebuild step for Record is structure, not logic.';

  @override
  String get medicinePageDescription =>
      'Today plans, adherence, refill status, and safety will anchor this tab.';

  @override
  String get medicineSectionTitle => 'Medication workspace';

  @override
  String get medicineSectionSubtitle =>
      'This section will host the rebuilt medication flow on top of Lucent.';

  @override
  String get minePageDescription =>
      'Profile, goals, privacy, and account settings will be rebuilt here.';

  @override
  String get mineSectionTitle => 'Personal workspace';

  @override
  String get mineSectionSubtitle =>
      'Identity, goals, and privacy controls will share one calm surface here.';

  @override
  String get morePageDescription =>
      'Utility tools, emergency help, device management, and lower-frequency features belong here.';

  @override
  String get moreSectionTitle => 'Utility hub';

  @override
  String get moreSectionSubtitle =>
      'This tab will gather the lower-frequency but still important workflows.';

  @override
  String get todaySectionTitle => 'Today workspace';

  @override
  String get todaySectionSubtitle =>
      'The new home will gradually attach reminders, snapshots, water tracking, and Lumi guidance here.';

  @override
  String get authLoginBadge => 'AUTH / LOGIN';

  @override
  String get authRegisterBadge => 'AUTH / REGISTER';

  @override
  String get authLoginTitle => 'Sign in with calm, not clutter.';

  @override
  String get authLoginDescription =>
      'Use your Lucent account to enter the rebuilt medication flow, then layer in reminders, snapshots, and multilingual health routines.';

  @override
  String get authRegisterTitle => 'Create the clean version first.';

  @override
  String get authRegisterDescription =>
      'Register once, then grow medication plans, reminders, and multilingual health workflows on top of Lucent.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLoginLead =>
      'Start with email, then choose password or verification code.';

  @override
  String get authRegisterLead =>
      'Verify your email, then set a password. Nickname is optional.';

  @override
  String get authModePassword => 'Password';

  @override
  String get authModeCode => 'Code';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint =>
      'At least 8 characters, ideally with mixed case and numbers';

  @override
  String get authCodeLabel => 'Verification code';

  @override
  String get authNicknameLabel => 'Nickname';

  @override
  String get authNicknameHint => 'Optional';

  @override
  String get authEmailRequiredToast => 'Please enter your email.';

  @override
  String get authCodeRequiredToast => 'Please enter the verification code.';

  @override
  String get authPasswordRequiredToast => 'Please enter your password.';

  @override
  String get authConfirmPasswordRequiredToast =>
      'Please confirm your password.';

  @override
  String get authSendCode => 'Send code';

  @override
  String authSendCodeAgain(int seconds) {
    return 'Send again (${seconds}s)';
  }

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccountAction => 'Create account';

  @override
  String get authForgotPasswordPrompt => 'Forgot your password?';

  @override
  String get authResetPasswordAction => 'Reset password';

  @override
  String get authNeedAccountPrompt => 'Need an account?';

  @override
  String get authRegisterNowAction => 'Register now';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authRememberPasswordPrompt => 'Remember your password?';

  @override
  String get authForgotPasswordBadge => 'AUTH / RESET';

  @override
  String get authForgotPasswordTitle => 'Reset password from your email.';

  @override
  String get authForgotPasswordDescription =>
      'Send a verification code, set a new password, then return to sign in.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordLead =>
      'Use the email attached to your account to receive a reset code.';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authResetPasswordSubmit => 'Reset password';

  @override
  String get authResetPasswordSuccess =>
      'Password updated. Please sign in again.';

  @override
  String get authChangeEmailBadge => 'AUTH / EMAIL';

  @override
  String get authChangeEmailTitle => 'Move account email carefully.';

  @override
  String get authChangeEmailDescription =>
      'Verify the new address before it becomes the account login email.';

  @override
  String get authChangeEmailFormTitle => 'Change email';

  @override
  String authChangeEmailLead(String email) {
    return 'Current email: $email';
  }

  @override
  String get authChangeEmailSignedOutLead =>
      'Sign in before changing the account email.';

  @override
  String get authNewEmailLabel => 'New email';

  @override
  String get authChangeEmailSubmit => 'Update email';

  @override
  String get authChangeEmailSuccess => 'Email updated.';

  @override
  String get authBackHomePrompt => 'Back to home?';

  @override
  String authSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get authCheckingSession => 'Checking session...';

  @override
  String get authNotSignedIn => 'Not signed in yet.';

  @override
  String get authGoLogin => 'Sign in';

  @override
  String get authGoRegister => 'Create account';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authInfraHint =>
      'Secure session storage, Lucent-backed localized responses, and session restore are already wired beneath this form layer.';

  @override
  String get todayHeroTitle => 'Today';

  @override
  String get todayHeroDescription =>
      'The new home starts here: we are rebuilding the responsive visual system first, then layering in water tracking, reminders, health snapshots, and Lumi guidance.';

  @override
  String get todayChipWater => 'Water Tracking';

  @override
  String get todayChipMedication => 'Medication Reminders';

  @override
  String get todayChipSnapshot => 'Health Snapshot';

  @override
  String get todayChipDiet => 'Diet Suggestions';

  @override
  String get todayChipEnvironment => 'Environment Alerts';

  @override
  String get todayChipLumi => 'Lumi Guidance';

  @override
  String get todayNotificationsTooltip => 'Notifications';

  @override
  String get todayGreetingTitleMorning => 'Good morning, the light is perfect';

  @override
  String get todayGreetingTitleAfternoon =>
      'Good afternoon, keep the rhythm steady';

  @override
  String get todayGreetingTitleEvening => 'Good evening, let\'s close gently';

  @override
  String get todayGreetingSubtitleMorning =>
      'You slept fairly well last night. Time to refill with calm energy.';

  @override
  String get todayGreetingSubtitleAfternoon =>
      'Start with water, then bring reminders and status back into sync.';

  @override
  String get todayGreetingSubtitleEvening =>
      'Gather today\'s signals gently and leave room for tomorrow.';

  @override
  String get todayWaterCardTitle => 'Today\'s water';

  @override
  String todayWaterCount(int count) {
    return '$count times';
  }

  @override
  String todayWaterGoalCount(int count) {
    return 'Goal $count times';
  }

  @override
  String todayWaterRemainingCount(int count) {
    return '$count more to go';
  }

  @override
  String get todayMedicationCardTitle => 'Medication reminder';

  @override
  String get todayMedicationAction => 'View';

  @override
  String todayMedicationSummary(int medicineCount, int pendingCount) {
    return '$medicineCount medicines · $pendingCount pending';
  }

  @override
  String todayMedicationNextDose(String time, String medicineName) {
    return 'Next at $time · $medicineName';
  }

  @override
  String get todayMedicationNameAtorvastatin => 'Atorvastatin';

  @override
  String get todayHealthSummaryCardTitle => 'Health summary';

  @override
  String get todayVitalHeartRateLabel => 'Heart rate';

  @override
  String get todayVitalHeartRateUnit => 'bpm';

  @override
  String get todayVitalBloodPressureLabel => 'Blood pressure';

  @override
  String get todayVitalSleepLabel => 'Sleep';

  @override
  String get todayVitalSleepUnit => 'h';

  @override
  String get todayMealCardTitle => 'Today\'s meal suggestion';

  @override
  String get todayMealHighProteinBalancedTitle => 'High-protein balanced bowl';

  @override
  String get todayMealHighProteinBalancedDescription =>
      'Chicken breast, quinoa, and seasonal salad';

  @override
  String get todayMealRefreshAction => 'Refresh';

  @override
  String get todayEnvironmentCardTitle => 'Environment signals';

  @override
  String get todayEnvironmentPollenLabel => 'Pollen';

  @override
  String get todayEnvironmentUvLabel => 'UV';

  @override
  String get todayEnvironmentLevelLow => 'Low';

  @override
  String get todayEnvironmentLevelMedium => 'Medium';

  @override
  String get todayEnvironmentLevelHigh => 'High';

  @override
  String get todayLumiCardTitle => 'Lumi note';

  @override
  String get todayLumiPollenProtectionBody =>
      'Pollen is elevated today. Consider a mask outdoors and reduce respiratory irritation where possible.';

  @override
  String get todayLumiAction => 'View details';

  @override
  String get todayErrorTitle => 'Today did not load this time';

  @override
  String get todayErrorDescription =>
      'The mock provider and page structure are wired up, so try fetching it again.';

  @override
  String get todayRetryAction => 'Retry';

  @override
  String placeholderSoon(String label) {
    return '$label · Coming Soon';
  }

  @override
  String get placeholderDescription =>
      'This area is reserved structurally and will be rebuilt with the new multi-platform design system.';
}
