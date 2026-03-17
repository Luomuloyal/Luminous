import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/components/album.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:sqflite/sqflite.dart';

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

  /// 页面最终展示的相册条目列表。
  List<AlbumEntry> _entries = [];

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
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      /// 先从本地数据库读取的相册记录。
      final local = await _loadLocal();
      if (!mounted) return;
      setState(() => _entries = local);

      /// 当前是否满足拉远端记录的前提：已登录且有有效 userId。
      final loggedIn = _userController.isLoggedIn && _userId.isNotEmpty;
      if (loggedIn) {
        /// 远端识别记录列表接口返回结果。
        final remote = await ScanApi.listScanRecords(
          userId: _userId,
          page: 1,
          pageSize: 50,
        );
        if (!mounted) return;

        /// 合并本地与远端后得到的最终展示结果。
        final merged = _merge(local, remote.result.items);
        setState(() => _entries = merged);
        await _cacheRemoteToLocal(remote.result.items);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = MessageUtils.extractError(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 读取本地缓存的相册记录。
  Future<List<AlbumEntry>> _loadLocal() async {
    try {
      /// 本地数据库实例。
      final db = await AppDatabase.instance.database;

      /// 从 album_items 表按创建时间倒序查询到的行数据。
      final rows = await db.query('album_items', orderBy: 'createdAt DESC');
      return rows.map(AlbumEntry.fromLocalRow).toList();
    } catch (_) {
      return [];
    }
  }

  /// 合并本地相册记录与远端识别记录。
  ///
  /// 规则：
  /// - 有 remoteId 的本地记录与远端记录按 remoteId 去重；
  /// - 没有 remoteId 的本地离线记录直接保留；
  /// - 最终按 takenAt 倒序排序。
  List<AlbumEntry> _merge(List<AlbumEntry> local, List<ScanRecordItem> remote) {
    /// 以 remoteId 为 key 的去重 map。
    final map = <String, AlbumEntry>{};
    for (final entry in local) {
      /// 本地条目的远端 id。
      final key = entry.remoteId.trim();
      if (key.isNotEmpty) {
        map[key] = entry;
      }
    }

    /// 把远端记录覆盖写入 map，保证远端数据优先。
    for (final record in remote) {
      map[record.id.trim()] = AlbumEntry.fromScanRecord(record);
    }

    /// 合并后的结果列表。
    final result = <AlbumEntry>[
      ...local.where((entry) => entry.remoteId.trim().isEmpty),
      ...map.values,
    ];
    result.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return result;
  }

  /// 将远端识别记录缓存到本地数据库。
  ///
  /// 这是 best-effort 行为：即使缓存失败，也不影响当前页面展示。
  Future<void> _cacheRemoteToLocal(List<ScanRecordItem> items) async {
    try {
      /// 本地数据库实例。
      final db = await AppDatabase.instance.database;

      /// 逐条把远端记录写入 album_items 表。
      for (final item in items) {
        await db.insert('album_items', {
          'remoteId': item.id,
          'identityKey': _buildIdentityKey(
            item.drugCode,
            item.approvalNo,
            item.productName,
          ),
          'drugCode': item.drugCode,
          'approvalNo': item.approvalNo,
          'productName': item.productName,
          'filePath': '',
          'thumbBase64': item.thumbBase64,
          'takenAt': item.takenAt,
          'source': 'scan',
          'createdAt': item.takenAt == 0
              ? DateTime.now().millisecondsSinceEpoch
              : item.takenAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {}
  }

  /// 生成相册/药品记录统一使用的 identityKey。
  ///
  /// 优先级：drugCode > approvalNo > productName。
  String _buildIdentityKey(String drugCode, String approvalNo, String name) {
    if (drugCode.trim().isNotEmpty) return 'drugCode:${drugCode.trim()}';
    if (approvalNo.trim().isNotEmpty) return 'approvalNo:${approvalNo.trim()}';
    return 'name:${name.trim()}';
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
      onTapEntry: _openDetail,
    );
  }

  /// 打开某条相册记录对应的药品详情页。
  ///
  /// 如果记录缺少 drugCode 和 approvalNo，则无法进入详情页，只提示用户。
  Future<void> _openDetail(AlbumEntry entry) async {
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
}
