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
      'Email and password are enough to start. Nickname is optional.';

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
  String get authSendCode => 'Send code';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccountAction => 'Create account';

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
  String placeholderSoon(String label) {
    return '$label · Coming Soon';
  }

  @override
  String get placeholderDescription =>
      'This area is reserved structurally and will be rebuilt with the new multi-platform design system.';
}
