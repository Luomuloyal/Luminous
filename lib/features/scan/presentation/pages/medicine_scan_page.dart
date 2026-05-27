part of '../scan.dart';

/// 药物识别页。
class MedicineScanPage extends ConsumerStatefulWidget {
  const MedicineScanPage({
    super.key,
    this.mode = ScanEntryMode.result,
    this.initialImage,
    this.promptSourceOnStart = false,
  });

  final ScanEntryMode mode;
  final SelectedScanImage? initialImage;
  final bool promptSourceOnStart;

  @override
  ConsumerState<MedicineScanPage> createState() => _MedicineScanPageState();
}

class _MedicineScanPageState extends ConsumerState<MedicineScanPage> {
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

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_autoExpandSheet());
      await _handleEntryFlow();
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
    } catch (_) {}
  }

  Future<void> _handleEntryFlow() async {
    if (widget.initialImage != null) {
      ref.read(scanProvider.notifier).applyImageAndScan(
        bytes: widget.initialImage!.bytes,
        mimeType: widget.initialImage!.mimeType,
      );
      return;
    }
    if (!widget.promptSourceOnStart) return;

    final image = await pickMedicineScanImage(context);
    if (image != null && mounted) {
      ref.read(scanProvider.notifier).applyImageAndScan(
        bytes: image.bytes,
        mimeType: image.mimeType,
      );
    } else if (mounted) {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
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
                child: _buildPhotoArea(state, l10n),
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
                    return _buildSheet(scrollController, state, l10n);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
