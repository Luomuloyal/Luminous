import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 药品选择页控制器。
///
/// 负责管理：
/// - 本地“我的药品”加载；
/// - 登录态下的远端同步；
/// - 行数据到 `MedicineItem` 的类型转换。
class MedicinePickerController extends GetxController {
  MedicinePickerController({MyMedicineRepository? repository})
    : _repository = repository ?? myMedicineRepository;

  final MyMedicineRepository _repository;

  bool _loading = false;
  List<MedicineItem> _items = const <MedicineItem>[];

  /// 当前是否正在加载“我的药品”。
  bool get loading => _loading;

  /// 当前可选的药品列表。
  List<MedicineItem> get items => _items;

  /// 当前登录用户 id。
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// 加载“我的药品”：先读本地，再在登录态下同步远端。
  Future<void> load() async {
    if (_loading) {
      return;
    }

    _loading = true;
    update();

    try {
      final rows = await _repository.loadLocalRows(userId: userId);
      if (isClosed) {
        return;
      }
      _items = rows.map(_rowToItem).toList(growable: false);
      update();

      if (userId.isNotEmpty) {
        await _repository.syncRemote(userId);
        final syncedRows = await _repository.loadLocalRows(userId: userId);
        if (isClosed) {
          return;
        }
        _items = syncedRows.map(_rowToItem).toList(growable: false);
      }
    } catch (_) {
      _showToast(_l10n?.pickerLoadFailedToast ?? '加载我的药品失败');
    } finally {
      if (!isClosed) {
        _loading = false;
        update();
      }
    }
  }

  MedicineItem _rowToItem(Map<String, dynamic> row) {
    return MedicineItem(
      serialNo: '',
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      dosageForm: (row['dosageForm'] ?? '').toString(),
      specification: (row['specification'] ?? '').toString(),
      marketingAuthorizationHolder: '',
      manufacturer: (row['manufacturer'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      drugCodeRemark: '',
    );
  }

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;

  void _showToast(String message) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }
}
