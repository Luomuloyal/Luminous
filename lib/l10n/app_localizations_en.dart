// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Luminous';

  @override
  String get mainTabHome => 'Home';

  @override
  String get mainTabDrug => 'Medicines';

  @override
  String get mainTabAlbum => 'Album';

  @override
  String get mainTabMine => 'Mine';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneralTitle => 'General';

  @override
  String get settingsProfileTitle => 'Personal Settings';

  @override
  String get settingsProfileSubtitle =>
      'Set up your avatar, nickname, gender, birthday, and profession';

  @override
  String get settingsGeneralSubtitle =>
      'Enter each module to configure preferences. More options will be added.';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Adjust mode and style for global UI.';

  @override
  String get settingsThemeEnter => 'Open theme settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle =>
      'Match system language automatically, or set app language manually.';

  @override
  String get settingsLanguageEnter => 'Open language settings';

  @override
  String get languagePageTitle => 'Language';

  @override
  String get languageSectionTitle => 'App Language';

  @override
  String get languageSectionSubtitle =>
      'Choose Follow System for automatic switching, or lock a language manually.';

  @override
  String get languageFollowSystem => 'Follow System';

  @override
  String get languageFollowSystemSubtitle =>
      'Automatically uses your device language';

  @override
  String get languageChinese => 'Chinese (Simplified)';

  @override
  String get languageChineseSubtitle => 'Use Chinese for app text';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'Use English for app text';

  @override
  String languageCurrentLabel(Object language) {
    return 'Current language: $language';
  }

  @override
  String languageSelectedLabel(Object language) {
    return 'Selected: $language';
  }

  @override
  String get languageHeroHintSystem =>
      'App language follows device language automatically';

  @override
  String get languageHeroHintChinese =>
      'Interface text is fixed to Simplified Chinese';

  @override
  String get languageHeroHintEnglish => 'Interface text is fixed to English';

  @override
  String get languageNote =>
      'When Follow System is enabled, changing your device language will apply automatically the next time you open the app (and also while app is running when system locale updates).';

  @override
  String get authPhoneLabel => 'Phone';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLoginMode => 'Password Login';

  @override
  String get authCodeLoginMode => 'Code Login';

  @override
  String get authPhoneRegisterMethod => 'Phone Registration';

  @override
  String get authEmailRegisterMethod => 'Email Registration';

  @override
  String get authSwitchToEmailLogin => 'Switch to Email Login';

  @override
  String get authSwitchToPhoneLogin => 'Switch to Phone Login';

  @override
  String get authUserAgreementTitle => 'User Agreement';

  @override
  String get authPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get authLegalPrefix => 'By logging in, you agree to the ';

  @override
  String get authLegalAnd => ' and ';

  @override
  String get authAgreementPrefix => 'I have read and agree to the ';

  @override
  String get authValidationEnterPhone => 'Please enter phone number';

  @override
  String get authValidationEnterEmail => 'Please enter email';

  @override
  String get authValidationInvalidPhone => 'Phone number format is invalid';

  @override
  String get authValidationInvalidEmail => 'Email format is invalid';

  @override
  String get authValidationEnterPassword => 'Please enter password';

  @override
  String get authValidationPasswordRule =>
      'Password must be 6-12 letters or numbers';

  @override
  String get authValidationEnterCode => 'Please enter verification code';

  @override
  String get authValidationCodeRule => 'Verification code must be 6 digits';

  @override
  String get authValidationEnterConfirmPassword =>
      'Please enter password again';

  @override
  String get authValidationPasswordMismatch => 'Passwords do not match';

  @override
  String get authCodeSentSuccess => 'Verification code sent';

  @override
  String get authErrorCodeInvalid =>
      'Incorrect verification code. Please try again';

  @override
  String get authErrorCodeExpired =>
      'Verification code has expired. Please request a new one';

  @override
  String get authErrorCodeRequired => 'Please enter verification code';

  @override
  String get authErrorIdentifierExistsLogin =>
      'This account is already registered. Please log in directly';

  @override
  String get authErrorIdentifierExistsPhoneRegistered =>
      'Phone number is already registered';

  @override
  String get authErrorIdentifierExistsEmailRegistered =>
      'Email is already registered';

  @override
  String get authErrorTooFrequent =>
      'Too many requests. Please try again later';

  @override
  String get authErrorInvalidPhone => 'Phone number format is invalid';

  @override
  String get authErrorInvalidEmailFormat => 'Email format is invalid';

  @override
  String get authErrorRequestFailed => 'Request failed. Please try again later';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '6-12 letters or numbers';

  @override
  String get authCodeLabel => 'Verification Code';

  @override
  String get authCodeHint => 'Enter 6-digit code';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Enter password again';

  @override
  String get authSendCode => 'Send';

  @override
  String get loginHeroTitle => 'Health Assistant';

  @override
  String loginHeroSubtitle(Object identifier, Object mode) {
    return '$identifier $mode';
  }

  @override
  String get loginForgotPasswordPending =>
      'Password recovery will be added later. You can register a new account or contact support for now.';

  @override
  String get loginNeedCodeForCurrentAccount =>
      'Please request a verification code for the current account first';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginSuccessPartialSync =>
      'Login successful, but part of cloud data sync failed';

  @override
  String get loginAutoRegisterTitle => 'Account Not Registered';

  @override
  String get loginAutoRegisterPrompt =>
      'This account is not registered yet. Go to registration?';

  @override
  String get loginAutoRegisterCancel => 'Cancel';

  @override
  String get loginAutoRegisterConfirm => 'Register';

  @override
  String get loginRegisterAction => 'Register';

  @override
  String get loginIdentifierHintPhone => 'Enter phone number';

  @override
  String get loginIdentifierHintEmail => 'Enter email address';

  @override
  String get loginForgotPasswordAction => 'Forgot password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginHelperPassword =>
      'Supports phone or email with password login.';

  @override
  String get loginHelperCode =>
      'Supports phone or email code login. If unregistered, go register directly.';

  @override
  String get loginHelperPasswordEmailOnly =>
      'Supports email with password login.';

  @override
  String get loginHelperCodeEmailOnly =>
      'Supports email code login. If unregistered, go register directly.';

  @override
  String get registerTopTitle => 'Register';

  @override
  String get registerHeroTitle => 'Create Account';

  @override
  String registerHeroSubtitle(Object identifier) {
    return '$identifier code registration';
  }

  @override
  String get registerUsernameLabel => 'Username (optional)';

  @override
  String get registerUsernameHint =>
      'Used for profile display, e.g. luminous_user';

  @override
  String get registerUsernameValidation =>
      'Username must be 2-30 chars with no spaces';

  @override
  String get registerNeedCodeForCurrentAccount =>
      'Please request a verification code for the current account first';

  @override
  String get registerNeedAgreement =>
      'Please read and check User Agreement and Privacy Policy first';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHelperPhone =>
      'Phone registration only needs SMS code and password confirmation.';

  @override
  String get registerHelperEmail =>
      'Email registration only needs email code and password confirmation.';

  @override
  String get homeFeaturesTitle => 'Common Features';

  @override
  String get homeFeaturesSubtitle => 'Quick access to core health services';

  @override
  String get homeReminderTitle => 'Today\'s Reminders';

  @override
  String get homeStatusSyncing => 'Syncing';

  @override
  String get homeStatusRelaxed => 'Light day';

  @override
  String get homeStatusReady => 'Ready';

  @override
  String get homePillLoading => 'Loading reminders...';

  @override
  String homePillCount(int count) {
    return '$count reminders today';
  }

  @override
  String get homePillTips => 'Health Tips';

  @override
  String get homeHeroTitle => 'Health Assistant';

  @override
  String get homeHeroIntro => 'Here is your plan for today';

  @override
  String get homeSummaryTitleLoading => 'Preparing reminders';

  @override
  String get homeSummaryTitleNone => 'Today\'s status';

  @override
  String get homeSummaryTitleNext => 'Next reminder';

  @override
  String get homeSummaryDetailLoading =>
      'Syncing today\'s reminder schedule. Please wait a moment';

  @override
  String get homeSummaryDetailNone =>
      'No pending reminders today. Keep your current rhythm';

  @override
  String get homeSummaryBadgeLoading => 'Syncing';

  @override
  String get homeSummaryBadgeRelaxed => 'Easy day';

  @override
  String homeSummaryBadgeCount(int count) {
    return '$count scheduled';
  }

  @override
  String get homeNoReminder => 'No reminders';

  @override
  String homeNextReminderPrefix(Object title, Object subtitle) {
    return 'Next reminder: $title · $subtitle';
  }

  @override
  String get homeFeatureDrugScanTitle => 'Drug Scan';

  @override
  String get homeFeatureDrugScanSubtitle => 'Scan medicine by camera';

  @override
  String get homeFeatureManualSearchTitle => 'Manual Search';

  @override
  String get homeFeatureManualSearchSubtitle => 'Search by keywords';

  @override
  String get homeFeatureReminderTitle => 'Medication Reminder';

  @override
  String get homeFeatureReminderSubtitle => 'On-time notifications';

  @override
  String get homeFeatureCheckInTitle => 'Medication Check-in';

  @override
  String get homeFeatureCheckInSubtitle => 'Record intake status';

  @override
  String get homeFeatureDrugInfoTitle => 'Drug Info';

  @override
  String get homeFeatureDrugInfoSubtitle => 'Ingredients and cautions';

  @override
  String get homeFeatureSafetyTitle => 'Safety Assist';

  @override
  String get homeFeatureSafetySubtitle => 'Risk alerts';

  @override
  String get homeFeatureDevelopingToast => 'Feature in development';

  @override
  String get homeMedicinePickerTitle => 'Select medicine';

  @override
  String get homeTipsSheetTitle => 'All Health Tips';

  @override
  String get homeTipsSheetSubtitle =>
      'Tap any tip to replace the Home tip text';

  @override
  String get homeTip1 => 'Take medicine on time; don\'t skip or double dose';

  @override
  String get homeTip2 => 'Follow instructions for before or after meals';

  @override
  String get homeTip3 => 'Ask a pharmacist before combining medicines';

  @override
  String get homeTip4 => 'Do not double dose after missing one; consult first';

  @override
  String get homeTip5 => 'Seek medical care promptly if discomfort appears';

  @override
  String get homeTip6 => 'Finish antibiotic courses; don\'t stop early';

  @override
  String get homeTip7 => 'Store medicines away from light, moisture, and heat';

  @override
  String get homeTip8 => 'Clean out expired medicines regularly';

  @override
  String get homeTip9 => 'Check contraindications and interactions before use';

  @override
  String get homeTip10 => 'Regular rest helps stabilize medication effect';

  @override
  String get homeFallbackReminder1Title => '08:30 Vitamin D';

  @override
  String get homeFallbackReminder1Subtitle => 'Take 1 capsule after breakfast';

  @override
  String get homeFallbackReminder2Title => '19:30 Amoxicillin';

  @override
  String get homeFallbackReminder2Subtitle => 'Take 1 capsule after dinner';

  @override
  String get homeFallbackReminder3Title => '22:00 Blood Pressure Log';

  @override
  String get homeFallbackReminder3Subtitle => 'Record and upload before sleep';

  @override
  String get homeCheckInRecordsTitle => 'Check-in Records';

  @override
  String get homeCheckInRecordsSubtitle =>
      'Daily completion and actual check-in time';

  @override
  String get homeCheckInRecordsEmpty => 'No check-in records yet';

  @override
  String homeCheckInRecordsDoneCount(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get homeCheckInRecordsToday => 'Today';

  @override
  String get homeCheckInRecordsYesterday => 'Yesterday';

  @override
  String get homeCheckInRecordsStatusDone => 'Done';

  @override
  String get homeCheckInRecordsStatusPending => 'Pending';

  @override
  String homeCheckInRecordsCheckedAt(Object time) {
    return 'Checked at $time';
  }

  @override
  String get homeCheckInRecordsNotChecked => 'Not checked in';

  @override
  String get reminderListTitle => 'Medication Reminders';

  @override
  String get reminderAddButton => 'Add Reminder';

  @override
  String get reminderNeedLoginTitle => 'Please log in first';

  @override
  String get reminderNeedLoginSubtitle =>
      'After login, your reminder plans can be synced and delivered as system notifications on time.';

  @override
  String get reminderNeedLoginAction => 'Go to Login';

  @override
  String get reminderEmptyTitle => 'No reminders';

  @override
  String get reminderEmptySubtitle =>
      'Tap Add Reminder at the bottom-right to get started';

  @override
  String get reminderDeleteDialogTitle => 'Delete Reminder';

  @override
  String reminderDeleteDialogContent(Object productName, Object time) {
    return 'Delete \"$productName $time\"?';
  }

  @override
  String get reminderDeleteCancel => 'Cancel';

  @override
  String get reminderDeleteConfirm => 'Delete';

  @override
  String get reminderDeletedToast => 'Deleted';

  @override
  String get reminderSystemNotificationSubtitle =>
      'System notification reminder';

  @override
  String reminderDosePrefix(Object dosage) {
    return 'Dose: $dosage';
  }

  @override
  String get reminderNoExtraContent => 'No extra reminder content';

  @override
  String get reminderEditTitle => 'Edit Reminder';

  @override
  String get reminderCreateTitle => 'New Reminder';

  @override
  String get reminderEditSectionDrugTime => 'Medicine & Time';

  @override
  String get reminderEditSelectMedicine => 'Select medicine';

  @override
  String get reminderEditSelectMedicineHint =>
      'Choose from My Medicines or Search Library';

  @override
  String reminderEditSelectedIdentity(Object drugCode, Object approvalNo) {
    return 'Drug Code: $drugCode  Approval No.: $approvalNo';
  }

  @override
  String reminderEditTimeTitle(Object time) {
    return 'Reminder Time: $time';
  }

  @override
  String get reminderEditTimeSubtitle =>
      'Send a system notification at this time every day';

  @override
  String get reminderEditSectionEffectiveDate => 'Effective Date';

  @override
  String get reminderDateUnlimited => 'Unlimited';

  @override
  String reminderEditStartDateTitle(Object value) {
    return 'Start Date: $value';
  }

  @override
  String reminderEditEndDateTitle(Object value) {
    return 'End Date: $value';
  }

  @override
  String get reminderEditStartDateSubtitle =>
      'Leave empty to remove start date limit';

  @override
  String get reminderEditEndDateSubtitle =>
      'Leave empty to remove end date limit';

  @override
  String get reminderEditDateBadgeUnset => 'Unset';

  @override
  String get reminderEditDateBadgeSet => 'Set';

  @override
  String get reminderEditClearDateLimit => 'Clear date limits';

  @override
  String get reminderEditStatusEnabled => 'Enabled';

  @override
  String get reminderEditStatusDisabled => 'Disabled';

  @override
  String get reminderEditStatusBoundMedicine => 'Medicine linked';

  @override
  String get reminderEditStatusManualInput => 'Manual input';

  @override
  String get reminderEditDateRangeInvalidToast =>
      'Start date cannot be later than end date';

  @override
  String get reminderDateRangeAllTime => 'All time';

  @override
  String reminderDateRangeBetweenShort(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String reminderDateRangeFromShort(Object date) {
    return 'From $date';
  }

  @override
  String reminderDateRangeUntilShort(Object date) {
    return 'Until $date';
  }

  @override
  String get reminderEditSectionContent => 'Reminder Content';

  @override
  String get reminderEditNameLabel => 'Medicine Name (required)';

  @override
  String get reminderEditSubtitleLabel => 'Note (optional)';

  @override
  String get reminderEditSubtitleHint =>
      'For example: Take 1 capsule after breakfast';

  @override
  String get reminderEditSectionSwitch => 'Switch';

  @override
  String get reminderEditEnableSwitch => 'Enable reminder';

  @override
  String get reminderEditSave => 'Save';

  @override
  String get reminderEditTip =>
      'Note: Reminder information is for assistance only and cannot replace medical prescriptions. Seek medical care promptly if you feel unwell.';

  @override
  String get reminderEditPickerTitle => 'Select Reminder Medicine';

  @override
  String get reminderEditNeedLogin => 'Please log in first';

  @override
  String get reminderEditNameRequired => 'Medicine name cannot be empty';

  @override
  String get checkInPageTitle => 'Medication Check-in';

  @override
  String get checkInNeedLoginTitle => 'Please log in first';

  @override
  String get checkInNeedLoginSubtitle =>
      'After login, your plans on this device can be loaded and today\'s check-in status will be stored locally.';

  @override
  String get checkInNeedLoginAction => 'Go to Login';

  @override
  String get checkInEmptyTitle => 'No reminders today';

  @override
  String get checkInEmptySubtitle =>
      'Go to Medication Reminders to add a plan first';

  @override
  String get checkInMissingIdMarkDone =>
      'Missing reminder id. Unable to check in';

  @override
  String get checkInMarkedDoneToast => 'Saved on this device';

  @override
  String get checkInMissingIdMarkUndone =>
      'Missing reminder id. Unable to switch status';

  @override
  String get checkInUndoDialogTitle => 'Undo Local Check-in';

  @override
  String get checkInUndoDialogContent =>
      'Check-in data is stored on this device only. Undoing will immediately update what you see on this device. Continue?';

  @override
  String get checkInUndoDialogCancel => 'Cancel';

  @override
  String get checkInUndoDialogConfirm => 'Undo Local Check-in';

  @override
  String get checkInMarkedUndoneToast => 'Marked as not checked in';

  @override
  String get checkInDefaultTitle => 'Medication Reminder';

  @override
  String get checkInCardDefaultSubtitle => 'Please complete on time';

  @override
  String get checkInActionDone => 'Undo Check-in';

  @override
  String get checkInActionUndone => 'Check in';

  @override
  String get mineQuickReminderTitle => 'Today\'s Reminders';

  @override
  String get mineQuickReminderSubtitle => 'View plans';

  @override
  String get mineQuickSearchTitle => 'Manual Search';

  @override
  String get mineQuickSearchSubtitle => 'Drug info';

  @override
  String get mineQuickSettingsTitle => 'Settings';

  @override
  String get mineQuickSettingsSubtitle => 'Preferences';

  @override
  String get mineDevelopingToast => 'Feature in development';

  @override
  String get mineLoggedInActionLabel => 'Settings';

  @override
  String get mineAboutLegalese =>
      'Health assistant and medicine information companion app';

  @override
  String get mineProfileLoginNow => 'Log in now';

  @override
  String get mineProfileLoginHint =>
      'Log in to manage your account and sync personal data';

  @override
  String get mineProfileLoginAction => 'Log in';

  @override
  String get mineProfileChipAccountConnected => 'Account connected';

  @override
  String get mineProfileChipLocalOnly => 'Local experience now';

  @override
  String get mineProfileChipImageLocalOnly =>
      'Original images stay on this device';

  @override
  String get mineProfileChipSyncEnabled => 'Lightweight sync available';

  @override
  String get mineProfileChipSyncAfterLogin =>
      'Enable lightweight sync after login';

  @override
  String get mineQuickSectionTitle => 'Quick Access';

  @override
  String mineQuickSectionCount(int count) {
    return '$count items';
  }

  @override
  String get mineQuickSectionSubtitle =>
      'Keep account, sync, and device-related entries together';

  @override
  String get mineMenuTitle => 'More Settings';

  @override
  String get mineMenuSubtitle =>
      'Collect history, account security, and version info in one place';

  @override
  String get mineMenuHistoryTitle => 'Browse History';

  @override
  String get mineMenuHistorySubtitle => 'Medicines you viewed recently';

  @override
  String get mineBrowseHistoryPageTitle => 'Browse History';

  @override
  String get mineBrowseHistoryHeroTitle => 'Recently Viewed';

  @override
  String get mineBrowseHistoryHeroSubtitle =>
      'Medicine details you opened are saved automatically so you can come back later.';

  @override
  String mineBrowseHistoryCountLabel(int count) {
    return '$count records';
  }

  @override
  String get mineBrowseHistoryScopeAccount => 'Current account';

  @override
  String get mineBrowseHistoryScopeGuest => 'Local guest history';

  @override
  String get mineBrowseHistoryClearAction => 'Clear';

  @override
  String get mineBrowseHistoryClearConfirmTitle => 'Clear browsing history';

  @override
  String get mineBrowseHistoryClearConfirmMessage =>
      'This removes the local browsing history saved for the current account and cannot be undone.';

  @override
  String get mineBrowseHistoryConfirmAction => 'Clear all';

  @override
  String get mineBrowseHistoryEmptyTitle => 'No browsing history yet';

  @override
  String get mineBrowseHistoryEmptySubtitle =>
      'Search or scan a medicine and open its detail page. It will appear here automatically.';

  @override
  String get mineBrowseHistoryOpenSearchAction => 'Search medicines';

  @override
  String get mineBrowseHistoryRemoveAction => 'Remove';

  @override
  String get mineBrowseHistoryDeleteToast => 'Removed from browsing history';

  @override
  String get mineBrowseHistoryClearedToast => 'Browsing history cleared';

  @override
  String get mineMenuSecurityTitle => 'Account & Security';

  @override
  String get mineMenuSecuritySubtitle =>
      'Privacy settings and security options';

  @override
  String get mineMenuAboutTitle => 'About Luminous';

  @override
  String get mineMenuAboutSubtitle => 'Version info and usage guide';

  @override
  String get searchTitlePicker => 'Select Medicine';

  @override
  String get searchTitleManual => 'Manual Search';

  @override
  String get searchBadgePicker => 'Medicine Library';

  @override
  String get searchBadgeManual => 'Keyword Search';

  @override
  String get searchHeaderSubtitlePicker =>
      'Search and select from backend medicine library';

  @override
  String get searchHeaderSubtitleManual =>
      'Search by product name, approval number, or manufacturer';

  @override
  String get searchInputHint => 'Product Name / Approval No. / Manufacturer';

  @override
  String get searchActionSearch => 'Search';

  @override
  String get searchQueryModeTitle => 'Query Mode';

  @override
  String get searchQueryModeDetecting => 'Checking network...';

  @override
  String searchQueryModeCurrent(Object mode) {
    return 'Current: $mode';
  }

  @override
  String get searchQueryModeOnline => 'Online';

  @override
  String get searchQueryModeLocal => 'Local';

  @override
  String get searchDatabaseTitle => 'Database';

  @override
  String get searchDatabaseSourceNmpa => 'NMPA';

  @override
  String get searchDatabaseSourceDrugbank => 'Drugbank';

  @override
  String searchDatabaseCurrentHint(Object database) {
    return 'Current database: $database. Drugbank is not connected yet. Online queries still use NMPA (MySQL).';
  }

  @override
  String get searchDatabaseNotConnectedToast =>
      'Drugbank is not connected yet. NMPA is still used.';

  @override
  String get searchModeTagOnline => 'Online';

  @override
  String get searchModeTagLocal => 'Local';

  @override
  String get searchQuickTagsTitle => 'Popular Searches';

  @override
  String get searchQuickTagAmoxicillin => 'Amoxicillin';

  @override
  String get searchQuickTagIbuprofen => 'Ibuprofen';

  @override
  String get searchQuickTagVitaminD => 'Vitamin D';

  @override
  String get searchQuickTagCephalosporin => 'Cephalosporin';

  @override
  String get searchQuickTagAntibiotic => 'Antibiotic';

  @override
  String get searchQuickTagGastroMedicine => 'Stomach Medicine';

  @override
  String get searchHistoryTitle => 'Recent Searches';

  @override
  String get searchHistoryClearAction => 'Clear';

  @override
  String get searchHistoryEmpty => 'No search history';

  @override
  String get searchResultTitle => 'Search Results';

  @override
  String get searchGuideTitle => 'Search Tips';

  @override
  String get searchGuideTipProductNameLabel => 'Product Name';

  @override
  String get searchGuideTipProductNameExample =>
      'Amoxicillin Capsules, Ibuprofen Tablets';

  @override
  String get searchGuideTipApprovalNoLabel => 'Approval No.';

  @override
  String get searchGuideTipApprovalNoExample => 'NMPA H20013191';

  @override
  String get searchGuideTipManufacturerLabel => 'Manufacturer';

  @override
  String get searchGuideTipManufacturerExample => 'CSPC Group, CR Sanjiu';

  @override
  String get searchGuideTipDrugCodeLabel => 'Drug Code';

  @override
  String get searchGuideTipDrugCodeExample => '86901000000000 (national code)';

  @override
  String get searchReadyHint =>
      'Press \"Search\" or Enter to query the medicine database';

  @override
  String get searchEmptyTitle => 'No matching results';

  @override
  String get searchEmptySubtitle =>
      'Try searching again with product name, approval number, or manufacturer';

  @override
  String get searchErrorTitle => 'Search Failed';

  @override
  String get searchRetryAction => 'Retry';

  @override
  String get searchCommitEmptyToast =>
      'Please enter product name, approval number, or manufacturer before searching';

  @override
  String get searchHistoryClearedToast => 'Search history cleared';

  @override
  String searchApprovalNoPrefix(Object approvalNo) {
    return 'Approval No.: $approvalNo';
  }

  @override
  String get searchAlreadyAddedToast =>
      'This medicine is already in My Medicines';

  @override
  String get searchAddedPendingSyncToast =>
      'Added to My Medicines. Pending cloud sync';

  @override
  String get searchAddedToast => 'Added to My Medicines';

  @override
  String get searchAddFailedToast => 'Add failed. Please try again';

  @override
  String get searchResultAddedLabel => 'Added';

  @override
  String get searchResultAddActionLabel => 'Add to My Medicines';

  @override
  String reminderListCountLabel(int count) {
    return '$count reminders';
  }

  @override
  String reminderListEnabledCountLabel(int count) {
    return '$count enabled';
  }

  @override
  String reminderListDisabledCountLabel(int count) {
    return '$count disabled';
  }

  @override
  String reminderRangeLabel(Object range) {
    return 'Effective range: $range';
  }

  @override
  String get reminderRangeUnlimited => 'Unlimited';

  @override
  String reminderRangeBetween(Object start, Object end) {
    return '$start to $end';
  }

  @override
  String reminderRangeFrom(Object start) {
    return 'From $start';
  }

  @override
  String reminderRangeUntil(Object end) {
    return 'Until $end';
  }

  @override
  String get splashTitleMain => 'Smart Medication';

  @override
  String get splashTitleSubtitle => 'Luminous · Health Guard';

  @override
  String get splashBadgeScan => 'Scan';

  @override
  String get splashBadgeReminder => 'Reminder';

  @override
  String get splashFooterBrand => 'Luminous Smart Medication Assistant';

  @override
  String get splashFooterSlogan => 'Safe · Convenient · Smart';

  @override
  String get scanSourceCamera => 'Take Photo';

  @override
  String get scanSourceGallery => 'Choose from Album';

  @override
  String get scanSourceCancel => 'Cancel';

  @override
  String get scanCameraPermissionDeniedToast =>
      'Camera permission denied. Please allow it and try again';

  @override
  String get scanReadImageFailedToast =>
      'Failed to read image. Please try again';

  @override
  String get scanPageTitleActions => 'Medicine Scan';

  @override
  String get scanPageTitleResult => 'Scan Result';

  @override
  String get scanPhotoPlaceholderTitle => 'Ready to scan medicine';

  @override
  String get scanHeaderSubtitleScanning => 'Scanning, please wait...';

  @override
  String get scanHeaderSubtitleNoResult =>
      'Upload an image and Doubao vision model will identify medicine information';

  @override
  String scanHeaderSubtitleResultCount(int count) {
    return '$count candidates identified';
  }

  @override
  String get scanRetakeAction => 'Retake';

  @override
  String get scanInfoNoResult =>
      'Choose a medicine box or package image, then the backend will send it to Doubao vision model for recognition.\nIf multiple candidates are found, select the closest one first before taking further actions.';

  @override
  String get scanInfoNoCandidate =>
      'No valid result identified. Please try again with a clearer image.';

  @override
  String get scanResultSectionTitle => 'Recognition Results';

  @override
  String scanApprovalNoPrefix(Object approvalNo) {
    return 'Approval No.: $approvalNo';
  }

  @override
  String get scanActionRescanLabel => 'Scan Again';

  @override
  String get scanActionRescanSubtitle => 'Retake or choose another image';

  @override
  String get scanActionSaveAlbumLabel => 'Add to Album';

  @override
  String get scanActionSaveAlbumSavingSubtitle => 'Saving...';

  @override
  String get scanActionSaveAlbumSubtitle => 'Save to in-app album list';

  @override
  String get scanActionSearchLabel => 'Search This Medicine';

  @override
  String get scanActionSearchNoKeywordSubtitle =>
      'Selected candidate has no searchable fields';

  @override
  String get scanActionSearchSubtitle =>
      'Open Search page and query automatically';

  @override
  String get scanActionCancelLabel => 'Cancel';

  @override
  String get scanActionCancelSubtitle => 'Close current recognition page';

  @override
  String get scanSavedToAlbumToast => 'Added to in-app album';

  @override
  String get scanSaveToAlbumFailedToast => 'Failed to add to album';

  @override
  String get scanSearchMissingKeywordToast =>
      'Selected candidate has no searchable fields';

  @override
  String get settingsDisplayTitle => 'Display';

  @override
  String get settingsDisplaySubtitle =>
      'Theme mode and style will affect Home, Medicines, Album, and overlays together';

  @override
  String get settingsOrnamentFieldTitle => 'Atmosphere Ornaments';

  @override
  String get settingsOrnamentFieldSubtitle =>
      'Supports transparency 0%, 25%, 50%, 75%, and 100% (100% means hidden)';

  @override
  String get settingsOrnamentPreviewTitle => 'Live Preview';

  @override
  String get settingsOrnamentPreviewSubtitle =>
      'The gradient block above updates instantly with your ornament intensity';

  @override
  String get settingsOrnamentPresetTitle => 'Preset Levels';

  @override
  String get settingsOrnamentPresetSubtitle =>
      'Switch common transparency presets quickly for immediate visual tuning';

  @override
  String get settingsOrnamentSliderTitle => 'Custom Transparency';

  @override
  String get settingsOrnamentSliderSubtitle =>
      'Adjust from 0%-100% (5% steps) for fine-grained control per device';

  @override
  String get settingsOrnamentSliderMinLabel => '0% (Most Visible)';

  @override
  String get settingsOrnamentSliderMaxLabel => '100% (Hidden)';

  @override
  String settingsOrnamentCurrentPercent(Object percent) {
    return 'Current ornament transparency: $percent%';
  }

  @override
  String get settingsOrnamentOptionTransparency0 => 'Transparency 0%';

  @override
  String get settingsOrnamentOptionTransparency25 => 'Transparency 25%';

  @override
  String get settingsOrnamentOptionTransparency50 => 'Transparency 50%';

  @override
  String get settingsOrnamentOptionTransparency75 => 'Transparency 75%';

  @override
  String get settingsOrnamentOptionTransparency100 =>
      'Transparency 100% (Hidden)';

  @override
  String settingsOrnamentCurrent(Object option) {
    return 'Current atmosphere ornaments: $option';
  }

  @override
  String get settingsHubHeroTitle => 'Preference Settings';

  @override
  String get settingsHubHeroSubtitle =>
      'Enter theme and language settings here. More modules like notifications and privacy can be added later.';

  @override
  String get settingsHeroTitle => 'Appearance & Preferences';

  @override
  String get settingsHeroMoodDark =>
      'Night-friendly visuals are active now, and pages follow the current dark rhythm.';

  @override
  String get settingsHeroMoodLight =>
      'Light visuals are active now, keeping pages clear and softly layered.';

  @override
  String get settingsHeroAccountLoggedIn => 'Account connected';

  @override
  String get settingsHeroAccountLoggedOut => 'Not logged in';

  @override
  String get settingsHeroLocalMode => 'Local mode';

  @override
  String get settingsHeroLoggedInHint =>
      'You can keep adjusting theme styles. Account status stays on this device.';

  @override
  String get settingsHeroLoggedOutHint =>
      'The app works normally now. Login only enables extra lightweight sync.';

  @override
  String get settingsThemeModeFieldTitle => 'Theme Mode';

  @override
  String get settingsThemeModeFieldSubtitle =>
      'Follow system, force light, or force dark';

  @override
  String get settingsThemeModeOptionSystem => 'Follow System';

  @override
  String get settingsThemeModeOptionLight => 'Light';

  @override
  String get settingsThemeModeOptionDark => 'Dark';

  @override
  String settingsThemeModeCurrentSystem(Object appearance) {
    return 'Following system. System is using $appearance mode';
  }

  @override
  String settingsThemeModeCurrentFixed(Object appearance) {
    return 'Currently fixed to $appearance mode';
  }

  @override
  String get settingsThemeStyleFieldTitle => 'Theme Style';

  @override
  String get settingsThemeStyleFieldSubtitle =>
      'Soft Glow, Moon Mist, Divine Tree, Illusion, and Light Sand affect ambient, banner, and section visuals together';

  @override
  String get settingsThemeStyleInUseBadge => 'In Use';

  @override
  String get settingsThemeStyleOptionSoftGlow => 'Soft Glow';

  @override
  String get settingsThemeStyleOptionMoonMist => 'Moon Mist';

  @override
  String get settingsThemeStyleOptionDivineTree => 'Divine Tree';

  @override
  String get settingsThemeStyleOptionIllusion => 'Illusion';

  @override
  String get settingsThemeStyleOptionLightSand => 'Light Sand';

  @override
  String get settingsThemeStyleOptionSoftGlowDesc =>
      'Soft blue, pale violet, and warm gold together. Bright but gentle.';

  @override
  String get settingsThemeStyleOptionMoonMistDesc =>
      'A blue base infused with subtle violet haze, like moonlit cool veils.';

  @override
  String get settingsThemeStyleOptionDivineTreeDesc =>
      'Yellow-green with soft gold accents, like sunlight through leaves.';

  @override
  String get settingsThemeStyleOptionIllusionDesc =>
      'Purple-led palette with hints of blue glow, like neon edges in night mist.';

  @override
  String get settingsThemeStyleOptionLightSandDesc =>
      'Tea, dusty rose, and clay tones. Warm and restrained like dry sandstone and old fabric.';

  @override
  String get medicineDetailAiNoContentToast => 'AI returned no content';

  @override
  String get medicineDetailAiNetworkErrorToast =>
      'Network request failed. Please check your connection and try again.';

  @override
  String get medicineDetailPageTitle => 'Medicine Details';

  @override
  String get medicineDetailHeaderRefreshing => 'Refreshing';

  @override
  String get medicineDetailHeaderRefresh => 'Refresh';

  @override
  String get medicineDetailLabelApprovalNo => 'Approval No.';

  @override
  String get medicineDetailLabelDrugCode => 'Drug Code';

  @override
  String get medicineDetailHeaderBadge => 'Medicine Info';

  @override
  String get medicineDetailInfoTitle => 'Basic Information';

  @override
  String get medicineDetailLabelProductName => 'Product Name';

  @override
  String get medicineDetailLabelDosageForm => 'Dosage Form';

  @override
  String get medicineDetailLabelSpecification => 'Specification';

  @override
  String get medicineDetailLabelMarketingAuthorizationHolder =>
      'Marketing Authorization Holder';

  @override
  String get medicineDetailLabelManufacturer => 'Manufacturer';

  @override
  String get medicineDetailLabelDrugCodeRemark => 'Drug Code Remark';

  @override
  String get medicineDetailAiTitle => 'AI Insights';

  @override
  String get medicineDetailAiRefetch => 'Fetch Again';

  @override
  String get medicineDetailAiFetch => 'Get More Details';

  @override
  String get medicineDetailAiPlaceholder =>
      'Tap \"Get More Details\" and the backend will use AI to supplement leaflet information not stored in the database, such as ingredients, contraindications, and precautions.';

  @override
  String get medicineDetailSafetyTitle => 'Safety Notice';

  @override
  String get medicineDetailSafetyDisclaimer =>
      'Information in this app is for health education and reference only, and cannot replace a doctor\'s diagnosis or prescription. If you feel unwell or are taking medication, follow medical advice and consult professionals.';

  @override
  String get drugLoadFailedToast => 'Failed to load My Medicines';

  @override
  String get drugDeletedToast => 'Removed from My Medicines';

  @override
  String get drugDeleteFailedToast => 'Delete failed';

  @override
  String get drugPickerTitle => 'Select medicine';

  @override
  String get drugQuickEntrySearchTitle => 'Manual Search';

  @override
  String get drugQuickEntrySearchSubtitle => 'Name / Approval No.';

  @override
  String get drugQuickEntryScanTitle => 'Drug Scan';

  @override
  String get drugQuickEntryScanSubtitle => 'Photo Recognition';

  @override
  String get drugQuickEntryAiTitle => 'AI Insights';

  @override
  String get drugQuickEntryAiSubtitle => 'Usage & Warnings';

  @override
  String get drugSearchEntryTitle => 'Search Medicines';

  @override
  String get drugSearchEntrySubtitle =>
      'Supports product name / approval number / manufacturer';

  @override
  String get drugQuickSectionTitle => 'Quick Access';

  @override
  String get drugQuickSectionSubtitle =>
      'Keep frequent actions together for a lighter, smoother page flow';

  @override
  String get drugMyMedicinesTitle => 'My Medicines';

  @override
  String get drugEmptyTitle => 'No medicines yet';

  @override
  String get drugEmptySubtitle =>
      'Use \"Manual Search\" or \"Drug Scan\"\nto add medicines here';

  @override
  String get drugUnknownMedicineName => 'Unknown medicine';

  @override
  String get drugApprovalNoLabel => 'Approval No.';

  @override
  String get drugSourceScanLabel => 'Photo Recognition';

  @override
  String get drugSourceManualLabel => 'Manual Search';

  @override
  String get legalUserAgreementTitle => 'User Agreement';

  @override
  String get legalUserAgreementSummary =>
      'Before using Luminous Health Assistant, please review account rules, service boundaries, and usage requirements.';

  @override
  String get legalUserAgreementSection1Title => '1. Scope of this agreement';

  @override
  String get legalUserAgreementSection1Body =>
      'This agreement applies to your use of Luminous Health Assistant features, including health records, medicine lookup, AI-assisted analysis, and reminder management. By registering, logging in, or continuing to use the app, you are deemed to have read and agreed to this agreement.';

  @override
  String get legalUserAgreementSection2Title => '2. Service description';

  @override
  String get legalUserAgreementSection2Body =>
      'This app provides health information organization and reference support only. It does not constitute diagnosis, prescription, or medical advice. For high-risk matters such as medication use, allergies, pregnancy, or chronic disease management, always follow doctors, pharmacists, and official package instructions.';

  @override
  String get legalUserAgreementSection3Title => '3. Account and security';

  @override
  String get legalUserAgreementSection3Body =>
      'You are responsible for safeguarding your login credentials and must not lend, rent, or transfer your account. Risks caused by credential disclosure, sign-in on insecure devices, or failure to sign out are your responsibility.';

  @override
  String get legalUserAgreementSection4Title => '4. Acceptable use';

  @override
  String get legalUserAgreementSection4Body =>
      'You must not use this app for unlawful or non-compliant activities, including but not limited to identity forgery, malicious uploads, bulk API scraping, service interference, or dissemination of false medical information. We reserve the right to limit features when abnormal use is detected.';

  @override
  String get legalUserAgreementSection5Title => '5. AI content notice';

  @override
  String get legalUserAgreementSection5Body =>
      'AI interpretations, recognition results, and safety-assist content may be affected by model capability, input image quality, and completeness of medicine information, and may contain bias, omissions, or inapplicable suggestions. You should make independent judgments with package instructions and professional advice.';

  @override
  String get legalUserAgreementSection6Title => '6. Disclaimer';

  @override
  String get legalUserAgreementSection6Body =>
      'For service interruptions, result deviations, or data delays caused by network outages, third-party service failures, user input errors, device compatibility issues, or force majeure, we will try our best to recover services but do not assume medical liability for direct or indirect losses arising therefrom.';

  @override
  String get legalUserAgreementSection7Title => '7. Agreement updates';

  @override
  String get legalUserAgreementSection7Body =>
      'This agreement may be updated as features evolve. Updated terms will be presented in-app. Continued use of the app means acceptance of the updated agreement. If you disagree with updates, you should stop using related services.';

  @override
  String get legalPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalPrivacyPolicySummary =>
      'This page explains what information we collect, how we use it, and how you can manage it.';

  @override
  String get legalPrivacyPolicySection1Title => '1. Information we collect';

  @override
  String get legalPrivacyPolicySection1Body =>
      'When you use account, medicine recognition, reminder plans, and health record features, we may collect information you provide, such as phone number, email, nickname, medicine names, reminder plans, scan images, and necessary device basics.';

  @override
  String get legalPrivacyPolicySection2Title => '2. How information is used';

  @override
  String get legalPrivacyPolicySection2Body =>
      'Information is mainly used for account identification, personal data sync, medicine search and AI analysis, reminder generation, incident troubleshooting, and product optimization. We do not use your personal health data for unrelated marketing.';

  @override
  String get legalPrivacyPolicySection3Title => '3. Images and AI requests';

  @override
  String get legalPrivacyPolicySection3Body =>
      'When you actively use scan recognition, AI medicine interpretation, or safety assist, related images, text, and structured parameters are sent to backend and model services for processing. Avoid uploading images containing unrelated sensitive information such as ID cards, bank cards, or home addresses.';

  @override
  String get legalPrivacyPolicySection4Title => '4. Local storage';

  @override
  String get legalPrivacyPolicySection4Body =>
      'To reduce repeated sign-ins and improve experience, the app securely caches necessary local data, such as login state, profile summary, part of business records, and theme preferences. Login-state data is cleared when you sign out.';

  @override
  String get legalPrivacyPolicySection5Title => '5. Information sharing';

  @override
  String get legalPrivacyPolicySection5Body =>
      'Except when required by law, necessary for fulfilling services you request, or required for security protection, we do not sell or publicly disclose your personal information to unrelated third parties. If third-party cloud services are involved, processing is limited to the minimum necessary scope.';

  @override
  String get legalPrivacyPolicySection6Title => '6. Your rights';

  @override
  String get legalPrivacyPolicySection6Body =>
      'You can manage your information through in-app login, logout, profile updates, and local-data deletion. As more data-management capabilities are introduced, we will gradually support export, deletion, and finer-grained authorization controls.';

  @override
  String get legalPrivacyPolicySection7Title => '7. Contact and updates';

  @override
  String get legalPrivacyPolicySection7Body =>
      'If this privacy policy is materially updated, we will provide updated notices in-app. Continued use of related features means you have been informed of and accept the updated policy.';

  @override
  String get safetyTitle => 'Safety Assist';

  @override
  String get safetyHeroSubtitle =>
      'Organize single-medicine guidance and two-medicine interaction alerts in a gentler way';

  @override
  String get safetyModePair => 'Two-medicine interaction';

  @override
  String get safetyModeSingle => 'Single-medicine guidance';

  @override
  String get safetySelectedWaiting => 'Waiting for medicine selection';

  @override
  String safetySelectedCount(int count) {
    return '$count medicines selected';
  }

  @override
  String get safetyCloudWithContext => 'Can include account context';

  @override
  String get safetyCloudQuery => 'Cloud AI query';

  @override
  String get safetyModeCardTitle => 'Query Mode';

  @override
  String get safetyPickCardTitle => 'Select Medicines';

  @override
  String get safetyPickPlaceholderA => 'Please select Medicine A';

  @override
  String get safetyPickSubtitle => 'Select from My Medicines or search library';

  @override
  String get safetyPickBadgeA => 'Medicine A';

  @override
  String get safetyPickPlaceholderB => 'Please select Medicine B';

  @override
  String get safetyPickBadgeB => 'Medicine B';

  @override
  String get safetyActionCardTitle => 'Start Query';

  @override
  String get safetyActionQueryPair => 'Check Two-medicine Interaction';

  @override
  String get safetyActionQuerySingle => 'Check Medication Advice';

  @override
  String get safetyResultCardTitle => 'AI Result';

  @override
  String get safetyResultPlaceholder =>
      'After selecting medicines, tap \"Start Query\" and the backend will call AI to return medication advice or interaction alerts.';

  @override
  String get safetyPickerTitleA => 'Select Medicine A';

  @override
  String get safetyPickerTitleB => 'Select Medicine B';

  @override
  String get safetyToastSelectMedicine => 'Please select a medicine first';

  @override
  String get safetyToastSelectSecondMedicine =>
      'Please select one more medicine';

  @override
  String get safetyToastAiNoContent => 'AI returned no content';

  @override
  String get safetyDisclaimerTitle => 'Safety Notice';

  @override
  String get safetyDisclaimerText =>
      'This feature uses AI-generated content for health education and reference only, and cannot replace a doctor\'s diagnosis or prescription. If you feel unwell or are taking medication, follow medical advice and consult professionals.';

  @override
  String get pickerLoadFailedToast => 'Failed to load My Medicines';

  @override
  String get pickerHintLocalEmpty =>
      'Local medicine library is currently empty';

  @override
  String pickerHintLocalCount(int count) {
    return 'Local library has $count items';
  }

  @override
  String get pickerHintLocalPriority => 'Prefer local selection';

  @override
  String get pickerHintCloudFallback => 'Use cloud lookup when needed';

  @override
  String get pickerSearchBadge => 'Cloud Medicine Library';

  @override
  String get pickerSearchTitle => 'Manually Search Library';

  @override
  String get pickerSearchSubtitle =>
      'Search in cloud and bring the result back to this flow directly, useful for quick lookup before local save.';

  @override
  String get pickerMyMedicinesTitle => 'My Medicines';

  @override
  String pickerCount(int count) {
    return 'Total $count items';
  }

  @override
  String get pickerSyncing => 'Syncing';

  @override
  String get pickerEmptyTitle => 'No local medicine records yet';

  @override
  String get pickerEmptySubtitle =>
      'You can first search in the cloud medicine library, or save frequently used medicines here later.';

  @override
  String get albumHeaderTitle => 'Recognition Album';

  @override
  String get albumHeaderSubtitleEmpty =>
      'New recognition records will be archived here automatically';

  @override
  String get albumHeaderSubtitleNonEmpty =>
      'Original images stay local. Only thumbnails and recognition results sync to cloud';

  @override
  String get albumHeaderChipWaitingFirstRecord => 'Waiting for first record';

  @override
  String albumHeaderChipRecordCount(int count) {
    return '$count records';
  }

  @override
  String get albumHeaderChipNoOriginal => 'No original image archives';

  @override
  String albumHeaderChipOriginalCount(int count) {
    return '$count originals';
  }

  @override
  String get albumHeaderChipCloudSync => 'Lightweight cloud sync';

  @override
  String get albumHeaderChipLocalOnly => 'Local-only storage';

  @override
  String get albumErrorTitle => 'Something went wrong while syncing album';

  @override
  String get albumErrorHint => 'Pull down to try loading local records again';

  @override
  String get albumEmptyTitle => 'No records yet';

  @override
  String get albumEmptySubtitle =>
      'Take a photo in \"Medicine Scan\" and it will be saved here automatically';

  @override
  String get albumEmptyChipAutoArchive => 'Auto-archived after scan';

  @override
  String get albumEmptyChipLocalOnly => 'Original images stay on this device';

  @override
  String get albumLoginTitle => 'Enable lightweight sync';

  @override
  String get albumLoginSubtitle =>
      'After login, thumbnails and recognition results can sync to cloud while original images remain on this device';

  @override
  String get albumLoginChipNoUpload => 'Original images not uploaded';

  @override
  String get albumLoginChipLightweightSync => 'Sync lightweight results only';

  @override
  String get albumLoginActionSyncAfterLogin => 'Sync after login';

  @override
  String get albumLoginActionLogin => 'Log in';

  @override
  String get albumCardStatusLocalOriginal => 'Local original';

  @override
  String get albumCardStatusThumbnailOnly => 'Thumbnail only';

  @override
  String get albumCardSubtitleTapForDetail =>
      'Tap to view recognition result and medicine details';

  @override
  String albumApprovalNoPrefix(Object approvalNo) {
    return 'Approval No.: $approvalNo';
  }

  @override
  String get albumCardTagRescannable => 'Rescannable';

  @override
  String get albumCardTagLightRecord => 'Lightweight record';

  @override
  String get albumPreviewNoApprovalNo => 'No approval number';

  @override
  String get albumPreviewTagOriginalRescannable =>
      'Local original can be rescanned';

  @override
  String get albumPreviewTagThumbnailOnly => 'Thumbnail only';

  @override
  String albumPreviewTagRecordedAt(Object date) {
    return 'Recorded on $date';
  }

  @override
  String get albumPreviewLowQualityNotice =>
      'This record only keeps a thumbnail, so high-quality rescanning is unavailable.';

  @override
  String get albumPreviewOpenDetailAction => 'View Medicine Details';

  @override
  String get albumPreviewRescanAction => 'Scan Again';

  @override
  String get albumDetailMissingIdentityToast =>
      'This record is missing drugCode/approvalNo, cannot open details';

  @override
  String get albumRescanThumbnailOnlyToast =>
      'This record only keeps a thumbnail, so high-quality rescanning is unavailable';

  @override
  String get albumRescanReadOriginalFailedToast =>
      'Failed to read original image, cannot rescan';
}
