part of '../scan.dart';

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
}
