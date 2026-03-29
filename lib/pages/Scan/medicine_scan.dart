import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/stores/album_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/scan_image_processing.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/scan.dart';
import 'package:permission_handler/permission_handler.dart';

/// 药物识别页面的入口模式。
enum ScanEntryMode {
  /// 首页或独立入口。
  result,

  /// 药品页快捷入口。
  actions,
}

/// 用户为识别页选择的一张图片。
class SelectedScanImage {
  const SelectedScanImage({
    required this.bytes,
    required this.mimeType,
    required this.source,
  });

  final Uint8List bytes;
  final String mimeType;
  final ImageSource source;
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
  final file = await picker.pickImage(
    source: source,
    imageQuality: 92,
    maxWidth: 1800,
  );
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
  });

  final ScanEntryMode mode;

  /// 首次进入页面时已经选好的图片。
  final SelectedScanImage? initialImage;

  /// 当没有 [initialImage] 时，是否在首帧后自动弹出图片来源选择。
  final bool promptSourceOnStart;

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

  final UserController _userController = Get.find<UserController>();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _sheetSizeNotifier = ValueNotifier<double>(
    _initialSheetSize,
  );

  Uint8List? _photoBytes;
  String _photoMimeType = 'image/jpeg';
  bool _scanning = false;
  bool _savingToAlbum = false;
  MedicineScanResult? _scanResult;
  int _selectedIndex = 0;
  String? _lastError;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  String _pageTitle(AppLocalizations? l10n) {
    if (widget.mode == ScanEntryMode.actions) {
      return l10n?.scanPageTitleActions ?? 'Medicine Scan';
    }
    return l10n?.scanPageTitleResult ?? 'Scan Result';
  }

  String _headerSubtitle(AppLocalizations? l10n) {
    if (_scanning) {
      return l10n?.scanHeaderSubtitleScanning ?? 'Scanning, please wait...';
    }
    if (_scanResult == null) {
      return l10n?.scanHeaderSubtitleNoResult ??
          'Upload an image and the vision model will identify medicine information';
    }
    final count = _scanResult!.candidates.length;
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

  String _actionSaveAlbumSubtitle(AppLocalizations? l10n) {
    if (_savingToAlbum) {
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

  String _savedToastText(AppLocalizations? l10n) {
    return l10n?.scanSavedToAlbumToast ?? 'Added to in-app album';
  }

  String _saveFailedToastText(AppLocalizations? l10n) {
    return l10n?.scanSaveToAlbumFailedToast ?? 'Failed to add to album';
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
      if (widget.initialImage != null) {
        await _applyImageAndScan(widget.initialImage!);
      } else if (widget.promptSourceOnStart) {
        await _pickAndScan(closeIfCancelled: true);
      }
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
    final l10n = _l10n;
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
                child: _buildPhotoArea(),
                builder: (context, sheetSize, child) {
                  final t =
                      ((sheetSize - _minSheetSize) /
                              (_maxSheetSize - _minSheetSize))
                          .clamp(0.0, 1.0);
                  final imageHeight =
                      maxImageHeight - (maxImageHeight - minImageHeight) * t;
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
                    return _buildSheet(scrollController);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoArea() {
    final l10n = _l10n;
    final bytes = _photoBytes;
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

  Widget _buildSheet(ScrollController scrollController) {
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
          _buildHeaderRow(),
          const SizedBox(height: 12),
          if (_lastError != null) _buildErrorCard(_lastError!),
          _buildResultSection(),
          const SizedBox(height: 10),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    final title = _pageTitle(l10n);
    final subtitle = _headerSubtitle(l10n);

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
          onPressed: _scanning ? null : _pickAndScan,
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

  Widget _buildResultSection() {
    final l10n = _l10n;
    final result = _scanResult;
    final scheme = Theme.of(context).colorScheme;
    if (_scanning) {
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
              final selected = index == _selectedIndex;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == result.candidates.length - 1 ? 0 : 10,
                ),
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
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

  Widget _buildActionsSection() {
    final l10n = _l10n;
    final selected = _getSelectedCandidateOrNull();
    final hasResult = selected != null;
    final searchKeyword = _buildSearchKeyword(selected);

    return Column(
      children: [
        _ActionTile(
          icon: Icons.refresh_rounded,
          color: const Color(0xFF0EA5E9),
          label: _actionRescanLabel(l10n),
          subtitle: _actionRescanSubtitle(l10n),
          onTap: _scanning ? null : _pickAndScan,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: _actionSaveAlbumLabel(l10n),
          subtitle: _actionSaveAlbumSubtitle(l10n),
          onTap: hasResult && !_savingToAlbum ? _saveToAppAlbum : null,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.search_rounded,
          color: const Color(0xFF10B981),
          label: _actionSearchLabel(l10n),
          subtitle: _actionSearchSubtitle(l10n, searchKeyword.isNotEmpty),
          onTap: searchKeyword.isEmpty ? null : _searchSelectedMedicine,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.close_rounded,
          color: const Color(0xFF94A3B8),
          label: _actionCancelLabel(l10n),
          subtitle: _actionCancelSubtitle(l10n),
          onTap: _scanning ? null : () => Navigator.maybePop(context),
        ),
      ],
    );
  }

  Future<void> _pickAndScan({bool closeIfCancelled = false}) async {
    final image = await pickMedicineScanImage(context);
    if (!mounted) {
      return;
    }
    if (image == null) {
      if (closeIfCancelled) {
        Navigator.maybePop(context);
      }
      return;
    }
    await _applyImageAndScan(image);
  }

  Future<void> _applyImageAndScan(SelectedScanImage image) async {
    setState(() {
      _lastError = null;
      _scanResult = null;
      _selectedIndex = 0;
      _photoBytes = image.bytes;
      _photoMimeType = image.mimeType;
    });
    await _scan(image.bytes);
  }

  Future<void> _scan(Uint8List bytes) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      final base64 = await encodeScanImageBase64(bytes);
      final userId = _userController.user.value?.id;
      final response = await ScanApi.scanMedicine(
        userId: userId,
        imageBase64: base64,
        mimeType: _photoMimeType,
      );
      if (!mounted) return;

      final result = response.result;
      setState(() {
        _scanResult = result;
        _selectedIndex = _findBestCandidateIndex(result);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _lastError = MessageUtils.extractError(e));
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  Future<void> _saveToAppAlbum() async {
    final l10n = _l10n;
    final bytes = _photoBytes;
    final result = _scanResult;
    if (bytes == null || result == null || _savingToAlbum) {
      return;
    }
    setState(() => _savingToAlbum = true);
    try {
      await _persistAlbumRecord(bytes, result);
      if (!mounted) return;
      ToastUtils.instance.show(context, _savedToastText(l10n));
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(
        context,
        e,
        fallback: _saveFailedToastText(l10n),
      );
    } finally {
      if (mounted) {
        setState(() => _savingToAlbum = false);
      }
    }
  }

  Future<void> _persistAlbumRecord(
    Uint8List bytes,
    MedicineScanResult result,
  ) async {
    final selected = _getSelectedCandidateOrNull();
    final now = DateTime.now().millisecondsSinceEpoch;
    final userId = _userController.user.value?.id ?? '';
    await albumLocalStore.saveScanRecord(
      userId: userId,
      drugCode: selected?.drugCode,
      approvalNo: selected?.approvalNo,
      productName: selected?.productName,
      imageBytes: bytes,
      imageMimeType: _photoMimeType,
      preferredThumbBase64: result.thumbBase64,
      takenAt: now,
    );
  }

  int _findBestCandidateIndex(MedicineScanResult result) {
    if (result.candidates.isEmpty) return 0;
    for (final entry in result.candidates.asMap().entries) {
      if (entry.value.hasIdentity) {
        return entry.key;
      }
    }
    return 0;
  }

  ScanCandidate? _getSelectedCandidateOrNull() {
    final result = _scanResult;
    if (result == null || result.candidates.isEmpty) {
      return null;
    }
    final index = _selectedIndex.clamp(0, result.candidates.length - 1);
    return result.candidates[index];
  }

  Future<void> _searchSelectedMedicine() async {
    final l10n = _l10n;
    final selected = _getSelectedCandidateOrNull();
    final keyword = _buildSearchKeyword(selected);
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, _searchMissingKeywordToastText(l10n));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SearchView(initialKeyword: keyword, autoSearchOnInit: true),
      ),
    );
  }

  String _buildSearchKeyword(ScanCandidate? candidate) {
    if (candidate == null) {
      return '';
    }
    if (candidate.productName.trim().isNotEmpty) {
      return candidate.productName.trim();
    }
    if (candidate.approvalNo.trim().isNotEmpty) {
      return candidate.approvalNo.trim();
    }
    if (candidate.manufacturer.trim().isNotEmpty) {
      return candidate.manufacturer.trim();
    }
    return '';
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
