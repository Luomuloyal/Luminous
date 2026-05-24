part of '../scan.dart';

extension _MedicineScanLabels on _MedicineScanPageState {
  String _pageTitle(AppLocalizations? l10n) {
    if (widget.mode == ScanEntryMode.actions) {
      return l10n?.scanPageTitleActions ?? 'Medicine Scan';
    }
    return l10n?.scanPageTitleResult ?? 'Scan Result';
  }

  String _headerSubtitle(
    AppLocalizations? l10n,
    MedicineScanController controller,
  ) {
    if (controller.scanning) {
      return l10n?.scanHeaderSubtitleScanning ?? 'Scanning, please wait...';
    }
    if (controller.scanResult == null) {
      return l10n?.scanHeaderSubtitleNoResult ??
          'Upload an image and the vision model will identify medicine information';
    }
    final count = controller.scanResult!.candidates.length;
    return l10n?.scanHeaderSubtitleResultCount(count) ??
        '$count candidates identified';
  }

  String _approvalNoText(AppLocalizations? l10n, String approvalNo) {
    return l10n?.scanApprovalNoPrefix(approvalNo) ??
        'Approval No.: $approvalNo';
  }

  String _infoNoResultText(AppLocalizations? l10n) {
    return l10n?.scanInfoNoResult ??
        'Choose a medicine package image and the backend will send it to the vision model for recognition.\n'
            'If multiple candidates are found, select the closest one first before taking further actions.';
  }

  String _infoNoCandidateText(AppLocalizations? l10n) {
    return l10n?.scanInfoNoCandidate ??
        'No valid result identified. Please try again with a clearer image.';
  }

  String _resultSectionTitle(AppLocalizations? l10n) {
    return l10n?.scanResultSectionTitle ?? 'Recognition Results';
  }

  String _actionRescanLabel(AppLocalizations? l10n) {
    return l10n?.scanActionRescanLabel ?? 'Scan Again';
  }

  String _actionRescanSubtitle(AppLocalizations? l10n) {
    return l10n?.scanActionRescanSubtitle ?? 'Retake or choose another image';
  }

  String _actionSaveAlbumLabel(AppLocalizations? l10n) {
    return l10n?.scanActionSaveAlbumLabel ?? 'Add to Album';
  }

  String _actionSaveAlbumSubtitle(AppLocalizations? l10n, bool savingToAlbum) {
    if (savingToAlbum) {
      return l10n?.scanActionSaveAlbumSavingSubtitle ?? 'Saving...';
    }
    return l10n?.scanActionSaveAlbumSubtitle ?? 'Save to in-app album list';
  }

  String _actionSearchLabel(AppLocalizations? l10n) {
    return l10n?.scanActionSearchLabel ?? 'Search This Medicine';
  }

  String _actionSearchSubtitle(AppLocalizations? l10n, bool hasKeyword) {
    if (!hasKeyword) {
      return l10n?.scanActionSearchNoKeywordSubtitle ??
          'Selected candidate has no searchable fields';
    }
    return l10n?.scanActionSearchSubtitle ??
        'Open Search page and query automatically';
  }

  String _actionCancelLabel(AppLocalizations? l10n) {
    return l10n?.scanActionCancelLabel ?? 'Cancel';
  }

  String _actionCancelSubtitle(AppLocalizations? l10n) {
    return l10n?.scanActionCancelSubtitle ?? 'Close current recognition page';
  }

  String _searchMissingKeywordToastText(AppLocalizations? l10n) {
    return l10n?.scanSearchMissingKeywordToast ??
        'Selected candidate has no searchable fields';
  }
}
