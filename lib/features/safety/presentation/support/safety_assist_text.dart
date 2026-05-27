import 'package:luminous/l10n/app_localizations.dart';

String safetyTitle(AppLocalizations? l10n) {
  return l10n?.safetyTitle ?? 'Safety Assist';
}

String heroSubtitle(AppLocalizations? l10n) {
  return l10n?.safetyHeroSubtitle ??
      'Organize single-medicine guidance and two-medicine interaction alerts in a gentler way';
}

String modeSingleText(AppLocalizations? l10n) {
  return l10n?.safetyModeSingle ?? 'Single-medicine guidance';
}

String modePairText(AppLocalizations? l10n) {
  return l10n?.safetyModePair ?? 'Two-medicine interaction';
}

String cloudWithContextText(AppLocalizations? l10n) {
  return l10n?.safetyCloudWithContext ?? 'Can include account context';
}

String cloudQueryText(AppLocalizations? l10n) {
  return l10n?.safetyCloudQuery ?? 'Cloud AI query';
}

String pickSubtitleText(AppLocalizations? l10n) {
  return l10n?.safetyPickSubtitle ??
      'Select from My Medicines or search library';
}

String pickPlaceholderText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickPlaceholderA ?? 'Please select Medicine A';
  }
  return l10n?.safetyPickPlaceholderB ?? 'Please select Medicine B';
}

String pickBadgeText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickBadgeA ?? 'Medicine A';
  }
  return l10n?.safetyPickBadgeB ?? 'Medicine B';
}

String actionQueryText(
  AppLocalizations? l10n,
  String mode, {
  required bool hasResult,
}) {
  if (hasResult) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '重新分析' : 'Analyze again';
  }
  if (mode == 'pair') {
    return l10n?.safetyActionQueryPair ?? 'Check Two-medicine Interaction';
  }
  return l10n?.safetyActionQuerySingle ?? 'Check Medication Advice';
}

String pickerTitleText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickerTitleA ?? 'Select Medicine A';
  }
  return l10n?.safetyPickerTitleB ?? 'Select Medicine B';
}

String cancelActionText(AppLocalizations? l10n) {
  return l10n?.reminderDeleteCancel ?? '取消';
}
