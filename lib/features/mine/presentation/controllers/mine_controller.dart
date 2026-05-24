import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/browse_history.dart';

/// 我的页页面级控制器。
class MineController extends GetxController {
  MineController({BrowseHistoryStore? historyStore})
    : _historyStore = historyStore ?? browseHistoryStore;

  final BrowseHistoryStore _historyStore;

  ProviderSubscription? _userWorker;
  BrowseHistoryEntry? _latestBrowseEntry;
  int _browseHistoryCount = 0;

  BrowseHistoryEntry? get latestBrowseEntry => _latestBrowseEntry;
  int get browseHistoryCount => _browseHistoryCount;
  bool get isLoggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false);

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      unawaited(loadBrowseHistoryPreview());
      update();
    });
    unawaited(loadBrowseHistoryPreview());
  }

  @override
  void onClose() {
    _userWorker?.close();
    super.onClose();
  }

  UserSafe? get currentUser =>
      globalProviderContainer.read(currentUserProvider);

  Future<void> loadBrowseHistoryPreview() async {
    try {
      final entries = await _historyStore.loadEntries(
        userId: globalProviderContainer.read(currentUserProvider)?.id,
      );
      if (isClosed) {
        return;
      }
      _latestBrowseEntry = entries.isEmpty ? null : entries.first;
      _browseHistoryCount = entries.length;
      update();
    } catch (_) {
      if (isClosed) {
        return;
      }
      _latestBrowseEntry = null;
      _browseHistoryCount = 0;
      update();
    }
  }

  Future<void> onTapProfile(BuildContext context) async {
    if (!(globalProviderContainer.read(currentUserProvider)?.hasData ??
        false)) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> onTapAction(BuildContext context) async {
    if (!(globalProviderContainer.read(currentUserProvider)?.hasData ??
        false)) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  void onTapQuickAction(
    BuildContext context,
    String id, {
    AppLocalizations? l10n,
  }) {
    if (id == 'search') {
      Navigator.pushNamed(context, '/search');
      return;
    }
    if (id == 'reminders') {
      Navigator.pushNamed(context, '/reminders');
      return;
    }
    if (id == 'settings') {
      Navigator.pushNamed(context, '/settings');
      return;
    }
    ToastUtils.instance.show(context, l10n?.mineDevelopingToast ?? '功能开发中');
  }

  Future<void> openBrowseHistory(BuildContext context) async {
    await Navigator.pushNamed(context, '/browse-history');
    if (isClosed) {
      return;
    }
    await loadBrowseHistoryPreview();
  }

  void onTapAbout(BuildContext context, {required String legalese}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: const Text('关于 Luminous'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppReleaseInfo.appName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                '版本 ${AppReleaseInfo.fullVersion}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                legalese,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/user-agreement');
              },
              child: Text(l10n?.legalUserAgreementTitle ?? '用户协议'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/privacy-policy');
              },
              child: Text(l10n?.legalPrivacyPolicyTitle ?? '隐私政策'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
