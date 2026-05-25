import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 药品选择器条目列表 provider。
///
/// 替代旧 GetX `MedicinePickerController`。
final medicinePickerProvider =
    AsyncNotifierProvider<MedicinePickerNotifier, List<MedicineItem>>(
      MedicinePickerNotifier.new,
    );

class MedicinePickerNotifier extends AsyncNotifier<List<MedicineItem>> {
  @override
  Future<List<MedicineItem>> build() async {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';

    final rows = await myMedicineRepository.loadLocalRows(userId: userId);
    var items = rows.map(_rowToItem).toList(growable: false);

    if (userId.isNotEmpty) {
      await myMedicineRepository.syncRemote(userId);
      final syncedRows = await myMedicineRepository.loadLocalRows(
        userId: userId,
      );
      items = syncedRows.map(_rowToItem).toList(growable: false);
    }

    return items;
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
}
