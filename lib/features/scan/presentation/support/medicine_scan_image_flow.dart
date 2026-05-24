part of '../scan.dart';

/// 药物识别页面的入口模式。
enum ScanEntryMode {
  /// 首页或独立入口。
  result,

  /// 药品页快捷入口。
  actions,
}

/// 打开图片来源选择弹层。
Future<ImageSource?> showMedicineScanSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    backgroundColor:
        theme.bottomSheetTheme.modalBackgroundColor ??
        theme.bottomSheetTheme.backgroundColor,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: scheme.primary),
              title: Text(
                l10n?.scanSourceCamera ?? '拍摄',
                style: TextStyle(color: scheme.onSurface),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: scheme.secondary,
              ),
              title: Text(
                l10n?.scanSourceGallery ?? '从相册选择',
                style: TextStyle(color: scheme.onSurface),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.close_rounded,
                color: scheme.onSurfaceVariant,
              ),
              title: Text(
                l10n?.scanSourceCancel ?? '取消',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

/// 选择图片并进入识别页。
Future<void> openMedicineScanFlow(
  BuildContext context, {
  ScanEntryMode mode = ScanEntryMode.result,
}) async {
  final selected = await pickMedicineScanImage(context);
  if (selected == null || !context.mounted) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MedicineScanPage(mode: mode, initialImage: selected),
    ),
  );
}

/// 先让用户选择来源，再读取图片内容。
Future<SelectedScanImage?> pickMedicineScanImage(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final source = await showMedicineScanSourceSheet(context);
  if (source == null) {
    return null;
  }

  if (source == ImageSource.camera) {
    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      if (context.mounted) {
        ToastUtils.instance.showTop(
          context,
          l10n?.scanCameraPermissionDeniedToast ?? '相机权限被拒绝，请允许后重试',
        );
      }
      return null;
    }
  }

  final picker = ImagePicker();
  XFile? file;
  try {
    file = await picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1800,
    );
  } catch (error) {
    if (context.mounted) {
      ToastUtils.instance.showTop(
        context,
        mediaAccessErrorText(source: source, error: error),
      );
    }
    return null;
  }
  if (file == null) {
    return null;
  }

  try {
    final bytes = await file.readAsBytes();
    return SelectedScanImage(
      bytes: bytes,
      mimeType: _guessMimeType(file.path),
      source: source,
    );
  } catch (_) {
    if (context.mounted) {
      ToastUtils.instance.showTop(
        context,
        l10n?.scanReadImageFailedToast ?? '读取图片失败，请重试',
      );
    }
    return null;
  }
}

String _guessMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
