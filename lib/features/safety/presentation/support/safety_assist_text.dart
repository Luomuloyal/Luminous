part of '../pages/safety_assist_page.dart';

String _safetyTitle(AppLocalizations? l10n) {
  return l10n?.safetyTitle ?? 'Safety Assist';
}

String _heroSubtitle(AppLocalizations? l10n) {
  return l10n?.safetyHeroSubtitle ??
      'Organize single-medicine guidance and two-medicine interaction alerts in a gentler way';
}

String _modeSingleText(AppLocalizations? l10n) {
  return l10n?.safetyModeSingle ?? 'Single-medicine guidance';
}

String _modePairText(AppLocalizations? l10n) {
  return l10n?.safetyModePair ?? 'Two-medicine interaction';
}

String _cloudWithContextText(AppLocalizations? l10n) {
  return l10n?.safetyCloudWithContext ?? 'Can include account context';
}

String _cloudQueryText(AppLocalizations? l10n) {
  return l10n?.safetyCloudQuery ?? 'Cloud AI query';
}

String _pickSubtitleText(AppLocalizations? l10n) {
  return l10n?.safetyPickSubtitle ??
      'Select from My Medicines or search library';
}

String _pickPlaceholderText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickPlaceholderA ?? 'Please select Medicine A';
  }
  return l10n?.safetyPickPlaceholderB ?? 'Please select Medicine B';
}

String _pickBadgeText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickBadgeA ?? 'Medicine A';
  }
  return l10n?.safetyPickBadgeB ?? 'Medicine B';
}

String _actionQueryText(
  AppLocalizations? l10n,
  String mode, {
  required bool hasResult,
}) {
  if (hasResult) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '重新分析' : 'Analyze again';
  }
  if (mode == SafetyAssistController.pairMode) {
    return l10n?.safetyActionQueryPair ?? 'Check Two-medicine Interaction';
  }
  return l10n?.safetyActionQuerySingle ?? 'Check Medication Advice';
}

String _resultPlaceholderText(AppLocalizations? l10n) {
  return l10n?.safetyResultPlaceholder ??
      'After selecting medicines, tap "Start Query" and the backend will call AI to return medication advice or interaction alerts.';
}

String _pickerTitleText(AppLocalizations? l10n, int slot) {
  if (slot == 0) {
    return l10n?.safetyPickerTitleA ?? 'Select Medicine A';
  }
  return l10n?.safetyPickerTitleB ?? 'Select Medicine B';
}

String _cancelActionText(AppLocalizations? l10n) {
  return l10n?.reminderDeleteCancel ?? '取消';
}
