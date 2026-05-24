import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/features/search/presentation/search.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Scan/controllers/medicine_scan_controller.dart';
import 'package:luminous/pages/Scan/models/selected_scan_image.dart';
import 'package:luminous/utils/media_access_error_text.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:permission_handler/permission_handler.dart';

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

/// 药物识别页。
///
/// 页面职责：
/// - 承载选中的图片并上传后端识别；
/// - 展示候选药品列表并允许用户切换候选；
/// - 提供再次识别、添加到软件相册、搜索该药物、取消四个动作。
class MedicineScanPage extends StatefulWidget {
  const MedicineScanPage({
    super.key,
    this.mode = ScanEntryMode.result,
    this.initialImage,
    this.promptSourceOnStart = false,
    this.controller,
  });

  final ScanEntryMode mode;

  /// 首次进入页面时已经选好的图片。
  final SelectedScanImage? initialImage;

  /// 当没有 [initialImage] 时，是否在首帧后自动弹出图片来源选择。
  final bool promptSourceOnStart;

  /// 页面级 GetX controller，可在测试或注入场景下覆写。
  final MedicineScanController? controller;

  @override
  State<MedicineScanPage> createState() => _MedicineScanPageState();
}

class _MedicineScanPageState extends State<MedicineScanPage> {
  static const double _minSheetSize = 0.22;
  static const double _initialSheetSize = 0.36;
  static const double _expandedSheetSize = 0.72;
  static const double _maxSheetSize = 0.90;
  static const List<double> _snapSheetSizes = <double>[
    _initialSheetSize,
    _expandedSheetSize,
    _maxSheetSize,
  ];

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _sheetSizeNotifier = ValueNotifier<double>(
    _initialSheetSize,
  );
  late final MedicineScanController _controller =
      widget.controller ?? MedicineScanController();
  late final String _controllerTag =
      'medicine-scan:${identityHashCode(_controller)}';

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

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_autoExpandSheet());
      await _controller.handleEntryFlow(
        initialImage: widget.initialImage,
        promptSourceOnStart: widget.promptSourceOnStart,
        pickImage: () => pickMedicineScanImage(context),
        onPromptCancelled: () {
          if (mounted) {
            Navigator.maybePop(context);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _sheetSizeNotifier.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    final next = _sheetController.size;
    if ((next - _sheetSizeNotifier.value).abs() < 0.001) {
      return;
    }
    _sheetSizeNotifier.value = next;
  }

  Future<void> _autoExpandSheet() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      await _sheetController.animateTo(
        _expandedSheetSize,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // Controller might not be attached yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MedicineScanController>(
      init: _controller,
      tag: _controllerTag,
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(_pageTitle(l10n)),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final maxImageHeight = constraints.maxHeight * 0.62;
              final minImageHeight = constraints.maxHeight * 0.28;

              return Stack(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _sheetSizeNotifier,
                    child: _buildPhotoArea(controller, l10n),
                    builder: (context, sheetSize, child) {
                      final t =
                          ((sheetSize - _minSheetSize) /
                                  (_maxSheetSize - _minSheetSize))
                              .clamp(0.0, 1.0);
                      final imageHeight =
                          maxImageHeight -
                          (maxImageHeight - minImageHeight) * t;
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: imageHeight,
                        child: child!,
                      );
                    },
                  ),
                  Positioned.fill(
                    child: DraggableScrollableSheet(
                      controller: _sheetController,
                      minChildSize: _minSheetSize,
                      maxChildSize: _maxSheetSize,
                      initialChildSize: _initialSheetSize,
                      snap: true,
                      snapSizes: _snapSheetSizes,
                      builder: (context, scrollController) {
                        return _buildSheet(scrollController, controller, l10n);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPhotoArea(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final bytes = controller.photoBytes;
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: bytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_back_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.scanPhotoPlaceholderTitle ?? 'Ready to scan medicine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
    );
  }

  Widget _buildSheet(
    ScrollController scrollController,
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildHeaderRow(controller, l10n),
          const SizedBox(height: 12),
          if (controller.lastError != null)
            _buildErrorCard(controller.lastError!),
          _buildResultSection(controller, l10n),
          const SizedBox(height: 10),
          _buildActionsSection(controller, l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final title = _pageTitle(l10n);
    final subtitle = _headerSubtitle(l10n, controller);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: appTintedSurface(
              context,
              const Color(0xFF10B981),
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: controller.scanning
              ? null
              : () => controller.pickAndScan(
                  pickImage: () => pickMedicineScanImage(context),
                ),
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: Text(l10n?.scanRetakeAction ?? 'Retake'),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      radius: 16,
      borderColor: appTintedBorder(
        context,
        const Color(0xFFEF4444),
        lightAlpha: 0.16,
        darkAlpha: 0.24,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  const Color(0xFFEF4444),
                  lightAlpha: 0.12,
                  darkAlpha: 0.20,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final result = controller.scanResult;
    final scheme = Theme.of(context).colorScheme;
    if (controller.scanning) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (result == null) {
      return _buildInfoCard(_infoNoResultText(l10n));
    }

    if (result.candidates.isEmpty) {
      return _buildInfoCard(_infoNoCandidateText(l10n));
    }

    return AppSurfaceCard(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _resultSectionTitle(l10n),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...result.candidates.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              final selected = index == controller.selectedIndex;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == result.candidates.length - 1 ? 0 : 10,
                ),
                child: InkWell(
                  onTap: () => controller.selectCandidate(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.primary,
                        lightAlpha: selected ? 0.08 : 0.03,
                        darkAlpha: selected ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? appTintedBorder(
                                context,
                                scheme.primary,
                                lightAlpha: 0.16,
                                darkAlpha: 0.24,
                              )
                            : scheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.displaySubtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.manufacturer.trim().isEmpty
                                    ? (c.approvalNo.trim().isEmpty
                                          ? ''
                                          : _approvalNoText(l10n, c.approvalNo))
                                    : c.manufacturer,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (c.score > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appTintedSurface(
                                context,
                                const Color(0xFF10B981),
                                lightAlpha: 0.10,
                                darkAlpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${(c.score * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return AppSurfaceCard(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final selected = controller.selectedCandidate;
    final hasResult = selected != null;
    final searchKeyword = controller.searchKeyword;

    return Column(
      children: [
        _ActionTile(
          icon: Icons.refresh_rounded,
          color: const Color(0xFF0EA5E9),
          label: _actionRescanLabel(l10n),
          subtitle: _actionRescanSubtitle(l10n),
          onTap: controller.scanning
              ? null
              : () => controller.pickAndScan(
                  pickImage: () => pickMedicineScanImage(context),
                ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: _actionSaveAlbumLabel(l10n),
          subtitle: _actionSaveAlbumSubtitle(l10n, controller.savingToAlbum),
          onTap: hasResult && controller.canSaveToAlbum
              ? controller.saveToAppAlbum
              : null,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.search_rounded,
          color: const Color(0xFF10B981),
          label: _actionSearchLabel(l10n),
          subtitle: _actionSearchSubtitle(l10n, searchKeyword.isNotEmpty),
          onTap: searchKeyword.isEmpty
              ? null
              : () => _searchSelectedMedicine(controller),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.close_rounded,
          color: const Color(0xFF94A3B8),
          label: _actionCancelLabel(l10n),
          subtitle: _actionCancelSubtitle(l10n),
          onTap: controller.scanning ? null : () => Navigator.maybePop(context),
        ),
      ],
    );
  }

  Future<void> _searchSelectedMedicine(
    MedicineScanController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final keyword = controller.searchKeyword;
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, _searchMissingKeywordToastText(l10n));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SearchPage(initialKeyword: keyword, autoSearchOnInit: true),
      ),
    );
  }
}

String _guessMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AppSurfaceCard(
        radius: 16,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appTintedSurface(
                    context,
                    color,
                    lightAlpha: 0.10,
                    darkAlpha: 0.18,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onTap == null
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
