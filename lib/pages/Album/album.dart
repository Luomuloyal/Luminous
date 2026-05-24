import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/components/album.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/pages/Album/controllers/album_controller.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/viewmodels/album.dart';

/// 识别相册页。
///
/// 用于展示当前用户作用域下的本地识别记录。
class AlbumView extends StatelessWidget {
  /// 创建识别相册页组件。
  const AlbumView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlbumController>(
      init: AlbumController(),
      global: false,
      builder: (controller) {
        return AlbumPage(
          headerPalette: SoftBannerPalettes.albumOf(context),
          loading: controller.loading,
          isLoggedIn: controller.isLoggedIn,
          error: controller.error,
          entries: controller.entries,
          onRefresh: controller.load,
          onTapLogin: () => Navigator.pushNamed(context, '/login'),
          onTapEntry: (entry) => _openPreview(context, controller, entry),
        );
      },
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    AlbumController controller,
    AlbumEntry entry,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlbumPreviewPage(
          entry: entry,
          onOpenDetail: () => _openDetailFromEntry(context, controller, entry),
          onRescan: entry.hasOriginalImage
              ? () => _rescanEntry(context, controller, entry)
              : null,
        ),
      ),
    );
  }

  /// 打开某条相册记录对应的药品详情页。
  Future<void> _openDetailFromEntry(
    BuildContext context,
    AlbumController controller,
    AlbumEntry entry,
  ) async {
    final item = controller.toMedicineItem(entry);
    if (!item.hasIdentity) {
      controller.showToast(controller.missingIdentityToast());
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
    AlbumController controller,
    AlbumEntry entry,
  ) async {
    if (!entry.hasOriginalImage) {
      controller.showToast(controller.thumbnailOnlyToast());
      return;
    }

    final bytes = await controller.readImageBytes(entry.imagePath);
    if (!context.mounted) {
      return;
    }
    if (bytes == null) {
      controller.showToast(controller.readOriginalFailedToast());
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
}
