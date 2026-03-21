import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/components/album.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/stores/album_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 识别相册页。
///
/// 用于展示历史识别记录，并在本地缓存与远端记录之间做一次轻量合并。
class AlbumView extends StatefulWidget {
  /// 创建识别相册页组件。
  const AlbumView({super.key});

  /// 创建相册页对应的状态对象。
  @override
  State<AlbumView> createState() => _AlbumViewState();
}

/// 相册页状态对象。
///
/// 主要负责两件事：
/// - 先读本地缓存，保证页面能尽快出内容；
/// - 已登录时再拉远端记录并合并，补齐跨设备/跨会话同步的数据。
class _AlbumViewState extends State<AlbumView> {
  /// 全局用户控制器。
  ///
  /// 用于判断当前是否登录，以及读取当前用户 id。
  final UserController _userController = Get.find<UserController>();

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;

  /// 相册页当前是否正在加载数据。
  bool _loading = false;

  /// 当前错误文案。
  ///
  /// 非空时页面会展示错误 banner。
  String? _error;

  /// 相册本地缓存读写入口。
  final AlbumLocalStore _albumLocalStore = albumLocalStore;

  /// 页面最终展示的相册条目列表。
  List<AlbumEntry> _entries = [];

  /// 当前是否有新的刷新请求在排队。
  bool _reloadQueued = false;

  /// 当前活跃加载请求的编号。
  int _loadRequestId = 0;

  /// 当前登录用户 id。
  ///
  /// 未登录时为空字符串。
  String get _userId => _userController.user.value?.id ?? '';

  /// 页面初始化时立即加载相册数据。
  @override
  void initState() {
    super.initState();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _load();
    });
    _load();
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    super.dispose();
  }

  /// 加载相册页数据。
  ///
  /// 顺序是：
  /// 1. 先读本地数据库；
  /// 2. 如果已登录，再拉远端识别记录；
  /// 3. 合并本地与远端结果；
  /// 4. 再把远端数据回写缓存到本地。
  Future<void> _load() async {
    final userId = _userId.trim();
    if (_loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      /// 先从本地数据库读取的相册记录。
      final local = await _loadLocal(userId: userId);
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() => _entries = local);

      /// 当前是否满足拉远端记录的前提：已登录且有有效 userId。
      final loggedIn = _userController.isLoggedIn && userId.isNotEmpty;
      if (loggedIn) {
        await _albumLocalStore.syncRemoteForUser(userId);
        if (!_canApplyLoadResult(requestId, userId)) return;
        final refreshedLocal = await _loadLocal(userId: userId);
        if (!_canApplyLoadResult(requestId, userId)) return;
        setState(() => _entries = refreshedLocal);
      }
    } catch (e) {
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() => _error = MessageUtils.extractError(e));
    } finally {
      if (_isActiveLoadRequest(requestId) && mounted) {
        setState(() => _loading = false);
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && mounted) {
        _reloadQueued = false;
        unawaited(_load());
      }
    }
  }

  /// 读取本地缓存的相册记录。
  Future<List<AlbumEntry>> _loadLocal({required String userId}) {
    return _albumLocalStore.loadEntries(userId: userId);
  }

  bool _canApplyLoadResult(int requestId, String userId) {
    return mounted &&
        _isActiveLoadRequest(requestId) &&
        userId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  /// 构建相册页 UI。
  @override
  Widget build(BuildContext context) {
    return AlbumPage(
      headerPalette: SoftBannerPalettes.album,
      loading: _loading,
      isLoggedIn: _userController.isLoggedIn,
      error: _error,
      entries: _entries,
      onRefresh: _load,
      onTapLogin: () => Navigator.pushNamed(context, '/login'),
      onTapEntry: _openPreview,
    );
  }

  Future<void> _openPreview(AlbumEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlbumPreviewPage(
          entry: entry,
          onOpenDetail: () => _openDetailFromEntry(entry),
          onRescan: entry.hasOriginalImage ? () => _rescanEntry(entry) : null,
        ),
      ),
    );
  }

  /// 打开某条相册记录对应的药品详情页。
  Future<void> _openDetailFromEntry(AlbumEntry entry) async {
    /// 根据相册条目拼装出的药品详情初始对象。
    final item = MedicineItem(
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
    if (!item.hasIdentity) {
      ToastUtils.instance.show(context, '该记录缺少 drugCode/approvalNo，无法查看详情');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  Future<void> _rescanEntry(AlbumEntry entry) async {
    final imageBase64 = entry.imageBase64.trim();
    if (imageBase64.isEmpty) {
      ToastUtils.instance.show(context, '该旧记录仅有缩略图，无法高质量重识别');
      return;
    }

    final bytes = decodeBase64Bytes(imageBase64);
    if (bytes == null || !mounted) {
      ToastUtils.instance.show(context, '原图读取失败，无法重识别');
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
                : guessImageMimeType(bytes),
            source: ImageSource.gallery,
          ),
        ),
      ),
    );
  }
}
