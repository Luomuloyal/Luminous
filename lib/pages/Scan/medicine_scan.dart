import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/stores/album_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
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
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍摄'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('取消'),
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
  final source = await showMedicineScanSourceSheet(context);
  if (source == null) {
    return null;
  }

  if (source == ImageSource.camera) {
    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      if (context.mounted) {
        ToastUtils.instance.showTop(context, '相机权限被拒绝，请允许后重试');
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
      ToastUtils.instance.showTop(context, '读取图片失败，请重试');
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
  final UserController _userController = Get.find<UserController>();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  double _sheetSize = 0.36;
  Uint8List? _photoBytes;
  String _photoMimeType = 'image/jpeg';
  bool _scanning = false;
  bool _savingToAlbum = false;
  MedicineScanResult? _scanResult;
  int _selectedIndex = 0;
  String? _lastError;

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
    super.dispose();
  }

  void _onSheetChanged() {
    final next = _sheetController.size;
    if ((next - _sheetSize).abs() < 0.001) {
      return;
    }
    setState(() {
      _sheetSize = next;
    });
  }

  Future<void> _autoExpandSheet() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      await _sheetController.animateTo(
        0.72,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // Controller might not be attached yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.mode == ScanEntryMode.actions ? '药物识别' : '识别结果'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minChildSize = 0.22;
          final maxChildSize = 0.90;
          final t =
              ((_sheetSize - minChildSize) / (maxChildSize - minChildSize))
                  .clamp(0.0, 1.0);
          final maxImageHeight = constraints.maxHeight * 0.62;
          final minImageHeight = constraints.maxHeight * 0.28;
          final imageHeight =
              maxImageHeight - (maxImageHeight - minImageHeight) * t;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: _buildPhotoArea(),
              ),
              Positioned.fill(
                child: DraggableScrollableSheet(
                  controller: _sheetController,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                  initialChildSize: 0.36,
                  snap: true,
                  snapSizes: const [0.36, 0.72, 0.90],
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
                const Text(
                  '准备识别药物',
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FB),
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
                color: const Color(0xFFCBD5E1),
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
    final title = widget.mode == ScanEntryMode.actions ? '药物识别' : '识别结果';
    final subtitle = _scanning
        ? '识别中，请稍等...'
        : _scanResult == null
        ? '选择图片后上传，由豆包视觉模型识别药物信息'
        : '共识别 ${_scanResult!.candidates.length} 个候选结果';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
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
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: _scanning ? null : _pickAndScan,
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: const Text('重拍'),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7F1D1D),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final result = _scanResult;
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
      return _buildInfoCard(
        '选一张药盒或药品包装图片，后端会把图片交给豆包视觉模型做识别。\n'
        '如识别到多个候选，你可以先在列表里选择更接近的一项，再执行后续动作。',
      );
    }

    if (result.candidates.isEmpty) {
      return _buildInfoCard('未识别到有效结果，请尝试重新选择更清晰的图片。');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '识别结果',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
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
                    color: selected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.displaySubtitle,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.manufacturer.trim().isEmpty
                                  ? (c.approvalNo.trim().isEmpty
                                        ? ''
                                        : '批准文号: ${c.approvalNo}')
                                  : c.manufacturer,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
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
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.12),
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
    );
  }

  Widget _buildActionsSection() {
    final selected = _getSelectedCandidateOrNull();
    final hasResult = selected != null;
    final searchKeyword = _buildSearchKeyword(selected);

    return Column(
      children: [
        _ActionTile(
          icon: Icons.refresh_rounded,
          color: const Color(0xFF0EA5E9),
          label: '再次识别',
          subtitle: '重新选择拍摄或相册图片',
          onTap: _scanning ? null : _pickAndScan,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: '添加到相册',
          subtitle: _savingToAlbum ? '写入中...' : '保存到软件相册列表',
          onTap: hasResult && !_savingToAlbum ? _saveToAppAlbum : null,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.search_rounded,
          color: const Color(0xFF10B981),
          label: '搜索该药物',
          subtitle: searchKeyword.isEmpty ? '当前候选缺少可搜索字段' : '跳转搜索页并自动查询',
          onTap: searchKeyword.isEmpty ? null : _searchSelectedMedicine,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.close_rounded,
          color: const Color(0xFF94A3B8),
          label: '取消',
          subtitle: '关闭当前识别页面',
          onTap: _scanning ? null : () => Navigator.maybePop(context),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.55,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w600,
        ),
      ),
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
      final base64 = base64Encode(bytes);
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
    final bytes = _photoBytes;
    final result = _scanResult;
    if (bytes == null || result == null || _savingToAlbum) {
      return;
    }
    setState(() => _savingToAlbum = true);
    try {
      await _persistAlbumRecord(bytes, result);
      if (!mounted) return;
      ToastUtils.instance.show(context, '已添加到软件相册');
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e, fallback: '添加到相册失败');
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
    final thumbBase64 = result.thumbBase64.trim().isNotEmpty
        ? result.thumbBase64.trim()
        : _generateThumbBase64(bytes);
    final now = DateTime.now().millisecondsSinceEpoch;

    String? remoteId;
    final userId = _userController.user.value?.id ?? '';
    if (userId.isNotEmpty && thumbBase64.isNotEmpty) {
      try {
        final remote = await ScanApi.createScanRecord(
          userId: userId,
          thumbBase64: thumbBase64,
          drugCode: selected?.drugCode,
          approvalNo: selected?.approvalNo,
          productName: selected?.productName,
          takenAt: now,
        );
        remoteId = remote.result.id;
      } catch (_) {
        // Remote sync is best-effort.
      }
    }

    await albumLocalStore.saveScanRecord(
      remoteId: remoteId,
      drugCode: selected?.drugCode,
      approvalNo: selected?.approvalNo,
      productName: selected?.productName,
      thumbBase64: thumbBase64,
      imageBase64: base64Encode(bytes),
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
    final selected = _getSelectedCandidateOrNull();
    final keyword = _buildSearchKeyword(selected);
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, '当前候选缺少可搜索字段');
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

  String _generateThumbBase64(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return '';

      final resized = img.copyResize(decoded, width: 240);
      final jpg = img.encodeJpg(resized, quality: 80);
      return base64Encode(jpg);
    } catch (_) {
      return '';
    }
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
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
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
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
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
