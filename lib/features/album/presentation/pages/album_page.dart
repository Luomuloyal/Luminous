import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/features/album/data/album_local_store.dart';
import 'package:luminous/features/album/presentation/models/album.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/album_provider.dart';
import '../widgets/album_page_widgets.dart';
import '../widgets/album_preview.dart';

/// 识别相册页。
///
/// 状态由 [albumEntriesProvider]（Riverpod AsyncNotifier）管理，
/// 替代旧 GetX `AlbumController`。
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(albumEntriesProvider);
    final isLoggedIn = ref.watch(
      currentUserProvider.select((u) => u?.hasData ?? false),
    );

    final errorText = entriesAsync.error != null
        ? _extractError(entriesAsync.error!)
        : null;

    return AlbumPageLayout(
      headerPalette: SoftBannerPalettes.albumOf(context),
      loading: entriesAsync.isLoading,
      isLoggedIn: isLoggedIn,
      error: errorText,
      entries: entriesAsync.hasValue ? entriesAsync.value! : const [],
      onRefresh: () async => ref.invalidate(albumEntriesProvider),
      onTapLogin: () => Navigator.pushNamed(context, '/login'),
      onTapEntry: (entry) => _openPreview(context, ref, entry),
    );
  }

  String _extractError(Object error) {
    return MessageUtils.extractError(error);
  }

  Future<void> _openPreview(
    BuildContext context,
    WidgetRef ref,
    AlbumEntry entry,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlbumPreviewPage(
          entry: entry,
          onOpenDetail: () => _openDetailFromEntry(context, ref, entry),
          onRescan: entry.hasOriginalImage
              ? () => _rescanEntry(context, ref, entry)
              : null,
        ),
      ),
    );
  }

  Future<void> _openDetailFromEntry(
    BuildContext context,
    WidgetRef ref,
    AlbumEntry entry,
  ) async {
    final item = _toMedicineItem(entry);
    if (!item.hasIdentity) {
      _showToast(context, _missingIdentityToast(context));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  Future<void> _rescanEntry(
    BuildContext context,
    WidgetRef ref,
    AlbumEntry entry,
  ) async {
    if (!entry.hasOriginalImage) {
      _showToast(context, _thumbnailOnlyToast(context));
      return;
    }

    final bytes = await albumLocalStore.readImageBytes(entry.imagePath);
    if (!context.mounted) return;
    if (bytes == null) {
      _showToast(context, _readOriginalFailedToast(context));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineScanPage(
          mode: ScanEntryMode.result,
          initialImage: SelectedScanImage(
            bytes: bytes,
            mimeType: entry.imageMimeType.trim().isNotEmpty
                ? entry.imageMimeType.trim()
                : 'image/jpeg',
            source: ImageSource.gallery,
          ),
        ),
      ),
    );
  }

  /// 从相册条目构造药品种类（迁自旧 [AlbumController.toMedicineItem]）。
  static MedicineItem _toMedicineItem(AlbumEntry entry) {
    return MedicineItem(
      serialNo: '',
      approvalNo: entry.approvalNo,
      productName: entry.productName,
      dosageForm: '',
      specification: '',
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: entry.drugCode,
      drugCodeRemark: '',
    );
  }

  void _showToast(BuildContext context, String message) {
    ToastUtils.instance.show(context, message);
  }

  String _missingIdentityToast(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.albumDetailMissingIdentityToast ??
        '该记录缺少 drugCode/approvalNo，无法查看详情';
  }

  String _thumbnailOnlyToast(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.albumRescanThumbnailOnlyToast ??
        '当前记录仅保存缩略图，无法高质量重识别';
  }

  String _readOriginalFailedToast(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.albumRescanReadOriginalFailedToast ??
        '原图读取失败，无法重识别';
  }
}
