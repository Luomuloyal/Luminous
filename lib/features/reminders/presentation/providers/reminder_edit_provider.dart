import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 提醒编辑页状态。
class ReminderEditState {
  const ReminderEditState({
    this.selectedMedicines = const [],
    this.time = '08:00',
    this.startDate = '',
    this.endDate = '',
    this.enabled = true,
    this.saving = false,
    this.isEdit = false,
  });

  final List<MedicineItem> selectedMedicines;
  final String time;
  final String startDate;
  final String endDate;
  final bool enabled;
  final bool saving;
  final bool isEdit;

  bool get hasLinkedIdentity => selectedMedicines.isNotEmpty;
  bool get canSave => !saving && selectedMedicines.isNotEmpty;

  String get normalizedProductName {
    final names = selectedMedicines
        .map((item) => item.productName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    return names.isEmpty ? '' : names.toSet().join('、');
  }

  ReminderEditState copyWith({
    List<MedicineItem>? selectedMedicines,
    String? time,
    String? startDate,
    String? endDate,
    bool? enabled,
    bool? saving,
    bool? isEdit,
  }) {
    return ReminderEditState(
      selectedMedicines: selectedMedicines ?? this.selectedMedicines,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enabled: enabled ?? this.enabled,
      saving: saving ?? this.saving,
      isEdit: isEdit ?? this.isEdit,
    );
  }
}

/// 提醒编辑页状态管理器。
class ReminderEditNotifier extends Notifier<ReminderEditState> {
  String get _userId => ref.read(currentUserProvider)?.id ?? '';

  @override
  ReminderEditState build() {
    return const ReminderEditState();
  }

  void initialize({ReminderPlan? initial}) {
    final medicines = <MedicineItem>[];
    final refs = initial?.medicines ?? const <ReminderMedicineRef>[];
    if (refs.isNotEmpty) {
      medicines.addAll(refs
          .where((item) => item.productName.trim().isNotEmpty)
          .map(_toMedicineItem)
          .toList(growable: false));
    } else if ((initial?.productName ?? '').trim().isNotEmpty) {
      medicines.add(MedicineItem(
        serialNo: '',
        approvalNo: initial?.approvalNo ?? '',
        productName: initial?.productName ?? '',
        dosageForm: '',
        specification: initial?.dosage ?? '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: initial?.drugCode ?? '',
        drugCodeRemark: '',
      ));
    }

    state = state.copyWith(
      selectedMedicines: medicines,
      time: initial?.time ?? '08:00',
      enabled: initial?.enabled ?? true,
      startDate: initial?.startDate ?? '',
      endDate: initial?.endDate ?? '',
      isEdit: initial != null,
    );
  }

  void setEnabled(bool value) {
    if (state.enabled == value) return;
    state = state.copyWith(enabled: value);
  }

  void removeSelectedMedicineAt(int index) {
    final medicines = List<MedicineItem>.from(state.selectedMedicines);
    if (index < 0 || index >= medicines.length) return;
    medicines.removeAt(index);
    state = state.copyWith(selectedMedicines: medicines);
  }

  void addSelectedMedicine(MedicineItem item) {
    final identity = medicineIdentityKey(item);
    if (state.selectedMedicines.any((e) => medicineIdentityKey(e) == identity)) {
      return; // duplicate, page handles toast
    }
    state = state.copyWith(
      selectedMedicines: [...state.selectedMedicines, item],
    );
  }

  void setTime(String time) {
    state = state.copyWith(time: time);
  }

  void setStartDate(String date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(String date) {
    state = state.copyWith(endDate: date);
  }

  void clearDateRange() {
    state = state.copyWith(startDate: '', endDate: '');
  }

  /// 返回保存后的 ReminderPlan，失败返回 null。
  /// validationErrors 在验证失败时由 page 层处理。
  Future<ReminderPlan?> save({
    required String scopedUserId,
  }) async {
    if (scopedUserId.trim().isEmpty) return null;
    if (state.selectedMedicines.isEmpty) return null;

    final medicines = state.selectedMedicines
        .where((item) => item.productName.trim().isNotEmpty)
        .map((item) => ReminderMedicineRef(
              drugCode: item.drugCode.trim(),
              approvalNo: item.approvalNo.trim(),
              productName: item.productName.trim(),
            ))
        .toList(growable: false);

    if (medicines.isEmpty) return null;
    final primary = medicines.first;

    state = state.copyWith(saving: true);

    try {
      final response = await ReminderApi.upsert(
        userId: scopedUserId,
        time: state.time,
        drugCode: primary.drugCode,
        approvalNo: primary.approvalNo,
        productName: state.normalizedProductName,
        medicines: medicines,
        dosage: '', // page 层从 TextEditingController 读取
        subtitle: '', // page 层从 TextEditingController 读取
        enabled: state.enabled,
        repeatRule: 'daily',
        method: 'notification',
        startDate: state.startDate,
        endDate: state.endDate,
      );
      await _syncReminderMedicinesToLocal(scopedUserId);
      return response.result;
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  String medicineIdentityKey(MedicineItem item) {
    final drugCode = item.drugCode.trim();
    if (drugCode.isNotEmpty) return 'drug:$drugCode';
    final approvalNo = item.approvalNo.trim();
    if (approvalNo.isNotEmpty) return 'approval:$approvalNo';
    return 'name:${item.productName.trim()}';
  }

  MedicineItem _toMedicineItem(ReminderMedicineRef ref) {
    return MedicineItem(
      serialNo: '',
      approvalNo: ref.approvalNo,
      productName: ref.productName,
      dosageForm: '',
      specification: '',
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: ref.drugCode,
      drugCodeRemark: '',
    );
  }

  Future<void> _syncReminderMedicinesToLocal(String scopedUserId) async {
    if (scopedUserId.trim().isEmpty || state.selectedMedicines.isEmpty) return;
    for (final item in state.selectedMedicines) {
      final normalized = MedicineItem(
        serialNo: item.serialNo,
        approvalNo: item.approvalNo,
        productName: item.productName,
        dosageForm: item.dosageForm,
        specification: item.specification,
        marketingAuthorizationHolder: item.marketingAuthorizationHolder,
        manufacturer: item.manufacturer,
        drugCode: item.drugCode,
        drugCodeRemark: item.drugCodeRemark,
      );
      try {
        await myMedicineRepository.addMedicine(
          item: normalized,
          source: 'reminder',
          userId: scopedUserId,
        );
      } catch (_) {}
    }
  }
}

final reminderEditProvider =
    NotifierProvider<ReminderEditNotifier, ReminderEditState>(() {
  return ReminderEditNotifier();
});
