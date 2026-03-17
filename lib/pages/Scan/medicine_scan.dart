import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/gallery_saver.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/scan.dart';
import 'package:permission_handler/permission_handler.dart';

/// 药物识别页面。
///
/// 页面职责：
/// - 调起相机拍照（ImagePicker）；
/// - 把照片上传到后端识别（ScanApi.scanMedicine）；
/// - 展示候选药品列表，并允许用户选择正确项；
/// - 在不同入口模式下提供不同动作（添加到我的药品/保存到相册/查看详情等）；
/// - best-effort 同步识别记录到远端并缓存到本地 SQLite。
enum ScanEntryMode {
  /// 首页入口：拍照后主要展示识别结果
  result,

  /// 药品页入口：拍照后主要展示操作项（添加/保存/查看/重拍）
  actions,
}

/// 药物识别页入口组件。
///
/// 该页面既可以作为“识别结果展示页”，也可以作为“识别后动作面板”。
/// 两种入口通过 `mode` 控制 UI 结构与按钮行为。
class MedicineScanPage extends StatefulWidget {
  /// 创建药物识别页面。
  const MedicineScanPage({
    super.key,
    this.mode = ScanEntryMode.result,
    this.autoStart = true,
  });

  /// 页面入口模式。
  ///
  /// - result：偏“识别结果展示”；
  /// - actions：偏“识别后操作（添加/保存/查看/重拍）”。
  final ScanEntryMode mode;

  /// 是否在页面首次展示后自动启动一次拍照识别流程。
  final bool autoStart;

  /// 创建药物识别页对应的状态对象。
  @override
  State<MedicineScanPage> createState() => _MedicineScanPageState();
}

/// 药物识别页的状态对象。
///
/// 这个页面的状态不是单纯的“拍一张照然后显示结果”，而是同时在维护：
/// - 视觉状态：`_sheetSize` 决定底部面板展开程度和照片区域收缩效果；
/// - 识别状态：`_photoBytes/_photoMimeType/_scanning/_scanResult/_selectedIndex`；
/// - 后处理状态：`_savingToGallery` 和本地/远端识别记录落库流程。
class _MedicineScanPageState extends State<MedicineScanPage> {
  /// 全局用户控制器，用于读取 userId（决定是否同步远端识别记录）。
  final UserController _userController = Get.find<UserController>();

  /// 底部拖拽面板控制器。
  ///
  /// 它不仅负责拖拽本身，也承担“首次自动展开面板”的动画入口。
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// 当前底部面板占屏幕高度比例（用于驱动图片区域的“收缩效果”）。
  ///
  /// 页面把“面板展开程度”映射成顶部图片区域高度，形成“照片被面板顶上去”
  /// 的联动效果，所以这里必须作为独立状态保留下来。
  double _sheetSize = 0.36;

  /// 当前拍摄照片的字节内容。
  ///
  /// 这份原始 bytes 会被多处复用：
  /// - 顶部直接预览；
  /// - 上传到后端做识别；
  /// - 生成缩略图并写入本地相册表。
  Uint8List? _photoBytes;

  /// 当前照片的 MIME 类型（用于上传接口与保存到相册）。
  ///
  /// 单独保存是因为同一份图片数据会流向多个下游环节，后端识别接口和相册
  /// 保存都需要明确知道图片类型。
  String _photoMimeType = 'image/jpeg';

  /// 是否正在把图片保存到系统相册。
  ///
  /// 相册保存是 best-effort 的后台动作，但仍需要一个状态来避免重复点击“保存”。
  bool _savingToGallery = false;

  /// 是否正在请求后端识别。
  ///
  /// 识别是页面的主耗时流程，这个状态负责：
  /// - 禁用重拍/底部操作按钮，避免并发请求；
  /// - 切换标题、副标题和结果区域的 loading 展示。
  bool _scanning = false;

  /// 当前识别结果（包含候选列表与缩略图 base64）。
  ///
  /// - null：尚未开始识别，或用户已重置状态；
  /// - 非 null：驱动候选列表渲染，并决定底部操作是否可用。
  MedicineScanResult? _scanResult;

  /// 当前选中的候选下标。
  ///
  /// 识别结果可能返回多个候选，页面后续的“查看详情/添加到我的药品/同步相册记录”
  /// 都围绕当前选中项展开，所以这里必须独立保存用户选择。
  int _selectedIndex = 0;

  /// 最近一次错误文案（用于在 UI 中展示错误卡片）。
  ///
  /// 错误不会“锁死”页面，用户仍然可以通过“重拍”重新走一次识别流程。
  String? _lastError;

  /// 页面初始化时接入两个启动动作：
  /// 1. 监听面板尺寸，驱动照片区域联动；
  /// 2. 首帧后自动展开面板，并按需自动拉起拍照识别。
  @override
  void initState() {
    super.initState();
    // 监听底部面板大小变化，用于联动图片区域高度。
    _sheetController.addListener(_onSheetChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Auto slide up for the "photo shrink / content reveal" effect.
      unawaited(_autoExpandSheet());
      if (widget.autoStart) {
        await _retakeAndScan();
      }
    });
  }

  /// 页面销毁时释放控制器资源。
  ///
  /// 必须移除 `_sheetController` 的监听，避免在销毁后仍触发 setState。
  @override
  void dispose() {
    // 释放 controller，避免内存泄漏。
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  /// 监听底部面板尺寸变化并同步到 `_sheetSize`。
  ///
  /// 这个方法只做一件事：把底部面板的真实尺寸反映到状态层，供 `build`
  /// 中计算图片区域高度，不在这里混入其他业务逻辑。
  void _onSheetChanged() {
    final next = _sheetController.size;
    if ((next - _sheetSize).abs() < 0.001) {
      return;
    }
    setState(() {
      _sheetSize = next;
    });
  }

  /// 首次进入页面后自动把底部面板拉到中间位置。
  ///
  /// 这样用户一进来就能同时看到：
  /// - 顶部照片区域；
  /// - 下方即将出现的识别结果/操作区。
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
      // Ignore: controller might not be attached yet.
    }
  }

  /// 构建药物识别页 UI。
  ///
  /// 页面由两层结构叠放：
  /// - 顶部照片预览区：根据 `_sheetSize` 动态收缩；
  /// - 底部拖拽面板：承载错误提示、操作入口与识别候选列表。
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
          // 底部面板最小高度（占屏幕比例）。
          final minChildSize = 0.22;
          // 底部面板最大高度（占屏幕比例）。
          final maxChildSize = 0.90;

          // 将当前面板高度映射为 0-1 的进度值，用于驱动图片区域高度插值。
          final t =
              ((_sheetSize - minChildSize) / (maxChildSize - minChildSize))
                  .clamp(0.0, 1.0);
          // 图片区域最大高度（面板最小时）。
          final maxImageHeight = constraints.maxHeight * 0.62;
          // 图片区域最小高度（面板最大时）。
          final minImageHeight = constraints.maxHeight * 0.28;
          // 根据面板展开程度计算当前图片区域高度。
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

  /// 构建顶部照片展示区域。
  ///
  /// - 未拍照时显示占位状态；
  /// - 拍照后显示拍摄的图片，并在底部圆角收边。
  Widget _buildPhotoArea() {
    // 当前照片 bytes；为空表示尚未拍照或已重置。
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
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '准备拍照识别',
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

  /// 构建底部可拖拽面板内容。
  ///
  /// 面板里会根据模式显示：
  /// - actions：操作入口区 + 结果列表（紧凑版）；
  /// - result：结果列表为主 + 底部按钮。
  ///
  /// 它承担的是“内容编排”职责，不直接处理拍照或识别，只根据当前状态把各块 UI
  /// 组装出来。
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
          if (widget.mode == ScanEntryMode.actions)
            _buildActionsSection()
          else
            _buildResultSection(),
          const SizedBox(height: 10),
          if (widget.mode == ScanEntryMode.actions)
            _buildResultSection(compact: true),
          const SizedBox(height: 10),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// 构建底部面板顶部的标题区域。
  Widget _buildHeaderRow() {
    /// 顶部标题文案，按入口模式切换。
    final title = widget.mode == ScanEntryMode.actions ? '药物识别' : '识别结果';

    /// 顶部副标题文案，根据当前识别状态动态变化。
    final subtitle = _scanning
        ? '识别中，请稍等...'
        : _scanResult == null
        ? '拍照后上传，由后端调用腾讯云智能问药能力识别药品信息'
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
          onPressed: _savingToGallery || _scanning ? null : _retakeAndScan,
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: const Text('重拍'),
        ),
      ],
    );
  }

  /// 构建错误提示卡片。
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

  /// 构建“操作模式”下的三个动作卡片。
  Widget _buildActionsSection() {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.add_circle_outline_rounded,
          color: const Color(0xFF0EA5E9),
          label: '添加到我的药品',
          subtitle: '识别后直接加入药品列表',
          onTap: _scanResult == null ? null : _addSelectedToMyMedicines,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: '保存到相册',
          subtitle: _savingToGallery ? '保存中...' : '将拍摄的照片保存至相册',
          onTap: _photoBytes == null ? null : _saveToGalleryOnly,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFF59E0B),
          label: '查看详细信息',
          subtitle: '查看基础信息与 AI 解读',
          onTap: _scanResult == null ? null : _openSelectedDetail,
        ),
      ],
    );
  }

  /// 构建识别结果区域。
  ///
  /// - `compact = false`：普通模式，结果区域作为主内容；
  /// - `compact = true`：操作模式下作为辅助紧凑列表展示。
  ///
  /// 这里统一处理四种结果态：识别中、未开始、无结果、有结果，保证页面在不同入口
  /// 模式下共用同一套候选渲染逻辑。
  Widget _buildResultSection({bool compact = false}) {
    /// 当前识别结果对象。
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
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          '拍照后我们会把图片上传到后端，由腾讯云智能问药能力完成识别。\n如识别到多个结果，你可以在列表里选择正确的药品。',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (result.candidates.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          '未识别到有效结果，请尝试重新拍摄（保证光线充足、文字清晰）。',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final title = compact ? '识别结果（可选择）' : '识别结果';

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
          Text(
            title,
            style: const TextStyle(
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
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedIndex = index),
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

  /// 构建底部按钮区域。
  ///
  /// 在 `result` 模式下，这里提供“添加到我的药品/查看详细信息/取消”；
  /// 在 `actions` 模式下，则只保留收尾动作“取消”，主要操作放到上面的 action tiles。
  Widget _buildBottomButtons() {
    /// 当前是否存在可用的识别结果。
    final canUseResult =
        _scanResult != null && _scanResult!.candidates.isNotEmpty;
    return Column(
      children: [
        if (widget.mode == ScanEntryMode.result) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canUseResult ? _addSelectedToMyMedicines : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('添加到我的药品'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: canUseResult ? _openSelectedDetail : null,
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('查看详细信息'),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('取消'),
          ),
        ),
      ],
    );
  }

  /// 重新拍照并执行识别流程。
  ///
  /// 步骤：
  /// 1. 重置页面状态；
  /// 2. 请求相机权限；
  /// 3. 调起相机拍照；
  /// 4. 读取图片字节；
  /// 5. 后台保存到系统相册；
  /// 6. 上传后端识别。
  ///
  /// 这里把“拍照”和“识别”串成同一个流程，是为了让页面始终围绕同一张最新
  /// 照片工作，避免旧照片结果和新拍照片预览混在一起。
  Future<void> _retakeAndScan() async {
    setState(() {
      _lastError = null;
      _scanResult = null;
      _selectedIndex = 0;
      _photoBytes = null;
    });

    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      if (mounted) {
        setState(() => _lastError = '相机权限被拒绝，请在系统设置中允许相机权限');
      }
      return;
    }

    /// 用于拍照的 ImagePicker 实例。
    final picker = ImagePicker();

    /// 用户实际拍摄得到的图片文件。
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      maxWidth: 1800,
    );
    if (!mounted) {
      return;
    }
    if (file == null) {
      Navigator.pop(context);
      return;
    }

    /// 读取后的图片二进制内容。
    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      setState(() => _lastError = '读取图片失败，请重试');
      return;
    }

    setState(() {
      _photoBytes = bytes;
      _photoMimeType = _guessMimeType(file.path);
    });

    // Save to system gallery in background
    unawaited(_saveToGallery(bytes));
    await _scan(bytes);
  }

  /// 后台把图片保存到系统相册。
  ///
  /// 这是 best-effort 行为，即使失败也不影响识别与本地缓存流程。
  Future<void> _saveToGallery(Uint8List bytes) async {
    if (_savingToGallery) return;
    setState(() => _savingToGallery = true);
    try {
      await GallerySaver.saveImage(
        bytes,
        fileName: 'luminous_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mimeType: _photoMimeType,
      );
    } catch (_) {
      // ignore, we still keep local record
    } finally {
      if (mounted) {
        setState(() => _savingToGallery = false);
      }
    }
  }

  /// 用户主动点击“保存到相册”时调用的包装方法。
  Future<void> _saveToGalleryOnly() async {
    final bytes = _photoBytes;
    if (bytes == null) return;
    await _saveToGallery(bytes);
    if (mounted) {
      ToastUtils.instance.show(context, '已保存到系统相册');
    }
  }

  /// 上传图片到后端并获取识别结果。
  ///
  /// 该方法只负责“识别主链路”：
  /// 1. base64 编码图片；
  /// 2. 调识别接口；
  /// 3. 选出默认候选；
  /// 4. 把结果交给 `_persistAlbumRecord` 做记录落库。
  Future<void> _scan(Uint8List bytes) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      /// 图片的 base64 字符串，用于接口上报。
      final base64 = base64Encode(bytes);

      /// 当前用户 id（可为空）。
      final userId = _userController.user.value?.id;

      /// 调用识别接口得到的响应。
      final response = await ScanApi.scanMedicine(
        userId: userId,
        imageBase64: base64,
        mimeType: _photoMimeType,
      );
      if (!mounted) return;

      /// 接口返回的识别结果对象。
      final result = response.result;
      setState(() {
        _scanResult = result;
        _selectedIndex = _findBestCandidateIndex(result);
      });

      await _persistAlbumRecord(bytes, result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _lastError = MessageUtils.extractError(e));
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  /// 把识别结果记录到本地相册表，并尽量同步到远端。
  ///
  /// 页面之所以在识别成功后立刻落库，是为了保证“相册”能作为识别历史入口
  /// 使用，即使稍后页面被关闭、网络同步失败，用户仍然能在本地看到刚刚的结果。
  Future<void> _persistAlbumRecord(
    Uint8List bytes,
    MedicineScanResult result,
  ) async {
    /// 当前选中的候选药品。
    final selected = _getSelectedCandidateOrNull();

    /// 最终要写入 album_items 的缩略图 base64。
    final thumbBase64 = result.thumbBase64.trim().isNotEmpty
        ? result.thumbBase64.trim()
        : _generateThumbBase64(bytes);

    /// 当前记录创建时间戳。
    final now = DateTime.now().millisecondsSinceEpoch;

    /// 如果远端同步成功，这里会拿到远端记录 id。
    String? remoteId;

    /// 当前登录用户 id。
    final userId = _userController.user.value?.id ?? '';
    if (userId.isNotEmpty && thumbBase64.isNotEmpty) {
      try {
        final r = await ScanApi.createScanRecord(
          userId: userId,
          thumbBase64: thumbBase64,
          drugCode: selected?.drugCode,
          approvalNo: selected?.approvalNo,
          productName: selected?.productName,
          takenAt: now,
        );
        remoteId = r.result.id;
      } catch (_) {
        // ignore sync errors
      }
    }

    try {
      /// 本地数据库实例。
      final db = await AppDatabase.instance.database;
      await db.insert('album_items', {
        'remoteId': remoteId,
        'identityKey': _buildIdentityKey(selected),
        'drugCode': selected?.drugCode ?? '',
        'approvalNo': selected?.approvalNo ?? '',
        'productName': selected?.productName ?? '',
        'filePath': '',
        'thumbBase64': thumbBase64,
        'takenAt': now,
        'source': 'scan',
        'createdAt': now,
      });
    } catch (_) {
      // ignore local album errors
    }
  }

  /// 找出默认应该选中的候选下标。
  ///
  /// 策略：优先选第一个有身份字段（drugCode/approvalNo）的候选。
  int _findBestCandidateIndex(MedicineScanResult result) {
    if (result.candidates.isEmpty) return 0;
    for (final entry in result.candidates.asMap().entries) {
      if (entry.value.hasIdentity) {
        return entry.key;
      }
    }
    return 0;
  }

  /// 获取当前被选中的候选结果。
  ///
  /// 如果没有结果或下标越界，则返回 null。
  ///
  /// 页面上的多个动作按钮都通过这个方法拿“当前选择”，避免每个入口都重复
  /// 处理空结果和越界保护。
  ScanCandidate? _getSelectedCandidateOrNull() {
    final result = _scanResult;
    if (result == null) return null;
    if (result.candidates.isEmpty) return null;
    final index = _selectedIndex.clamp(0, result.candidates.length - 1);
    return result.candidates[index];
  }

  /// 把当前选中的候选药品加入“我的药品”。
  ///
  /// 这里会先把扫描候选转换为统一的 `MedicineItem` 结构，再按与搜索页一致的
  /// 本地表字段写入，保证不同入口添加的药品记录结构保持一致。
  Future<void> _addSelectedToMyMedicines() async {
    /// 当前选中的候选药品。
    final c = _getSelectedCandidateOrNull();
    if (c == null) return;

    /// 将候选结果转换为统一的 `MedicineItem` 对象。
    final item = MedicineItem(
      serialNo: '',
      approvalNo: c.approvalNo,
      productName: c.productName,
      dosageForm: c.dosageForm,
      specification: c.specification,
      marketingAuthorizationHolder: '',
      manufacturer: c.manufacturer,
      drugCode: c.drugCode,
      drugCodeRemark: '',
    );

    try {
      final result = await myMedicineRepository.addMedicine(
        item: item,
        source: 'scan',
        userId: _userController.user.value?.id,
      );
      if (!mounted) return;
      if (!result.added) {
        ToastUtils.instance.show(context, '该药品已在我的药品列表中');
        return;
      }
      ToastUtils.instance.show(
        context,
        (_userController.user.value?.id ?? '').isNotEmpty &&
                !result.remoteSynced
            ? '已添加到我的药品，待同步到云端'
            : '已添加到我的药品',
      );
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.show(context, '添加失败，请重试');
    }
  }

  /// 打开当前选中候选的药品详情页。
  ///
  /// 详情页需要的是统一药品对象，因此这里会先把扫描候选映射为 `MedicineItem`。
  Future<void> _openSelectedDetail() async {
    /// 当前选中的候选药品。
    final c = _getSelectedCandidateOrNull();
    if (c == null) return;

    /// 由候选数据转换得到的详情初始对象。
    final item = MedicineItem(
      serialNo: '',
      approvalNo: c.approvalNo,
      productName: c.productName,
      dosageForm: c.dosageForm,
      specification: c.specification,
      marketingAuthorizationHolder: '',
      manufacturer: c.manufacturer,
      drugCode: c.drugCode,
      drugCodeRemark: '',
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  /// 从原始图片生成较小的缩略图 base64。
  ///
  /// 用于写入 album_items 表，减少相册列表显示时的存储与解码成本。
  String _generateThumbBase64(Uint8List bytes) {
    try {
      /// 解码后的原始图片对象。
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return '';

      /// 缩放后的缩略图对象。
      final resized = img.copyResize(decoded, width: 240);

      /// 重新编码后的 jpg 字节。
      final jpg = img.encodeJpg(resized, quality: 80);
      return base64Encode(jpg);
    } catch (_) {
      return '';
    }
  }

  /// 为识别候选生成唯一 identityKey。
  ///
  /// 优先级：drugCode > approvalNo > productName。
  String _buildIdentityKey(ScanCandidate? candidate) {
    if (candidate == null) {
      return 'scan:${DateTime.now().millisecondsSinceEpoch}';
    }
    if (candidate.drugCode.trim().isNotEmpty) {
      return 'drugCode:${candidate.drugCode.trim()}';
    }
    if (candidate.approvalNo.trim().isNotEmpty) {
      return 'approvalNo:${candidate.approvalNo.trim()}';
    }
    return 'name:${candidate.productName.trim()}';
  }

  /// 根据文件路径猜测 MIME 类型。
  ///
  /// 当前拍照流程主要会产出 jpeg，但仍保留 png 判断，兼容未来改成相册选择等入口。
  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

/// 操作模式下使用的统一动作卡片。
///
/// 用同一套视觉结构承载“添加到我的药品 / 保存到相册 / 查看详细信息”三种动作，
/// 只通过图标、颜色、文案和回调区分具体行为。
class _ActionTile extends StatelessWidget {
  /// 创建操作模式下的动作卡片。
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  /// 左侧图标。
  final IconData icon;

  /// 图标与背景主题色。
  final Color color;

  /// 主标题。
  final String label;

  /// 副标题。
  final String subtitle;

  /// 点击回调；为 null 时表示不可用。
  final VoidCallback? onTap;

  /// 构建统一样式的动作卡片。
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
