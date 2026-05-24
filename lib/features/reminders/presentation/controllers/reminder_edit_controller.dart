import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 提醒编辑页页面级控制器。
///
/// 负责维护提醒编辑表单、药品选择、日期时间选择与保存流程。
class ReminderEditController extends GetxController {
  ReminderEditController({this.initial});

  final ReminderPlan? initial;

  late final TextEditingController nameController = TextEditingController(
    text: initial?.productName ?? '',
  );
  late final TextEditingController subtitleController = TextEditingController(
    text: initial?.subtitle ?? '',
  );
  late final TextEditingController dosageController = TextEditingController(
    text: initial?.dosage ?? '',
  );

  final List<MedicineItem> _selectedMedicines = <MedicineItem>[];
  String _time = '08:00';
  String _startDate = '';
  String _endDate = '';
  bool _enabled = true;
  bool _saving = false;

  bool get isEdit => initial != null;
  List<MedicineItem> get selectedMedicines =>
      List<MedicineItem>.unmodifiable(_selectedMedicines);
  String get time => _time;
  String get startDate => _startDate;
  String get endDate => _endDate;
  bool get enabled => _enabled;
  bool get saving => _saving;
  String get normalizedProductName => _composeSelectedMedicineNames();
  String get normalizedDosage => dosageController.text.trim();
  String get normalizedExtraContent => subtitleController.text.trim();
  bool get hasLinkedIdentity => _selectedMedicines.isNotEmpty;
  bool get canSave => !_saving && _selectedMedicines.isNotEmpty;
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _time = initial?.time ?? '08:00';
    _enabled = initial?.enabled ?? true;
    _startDate = initial?.startDate ?? '';
    _endDate = initial?.endDate ?? '';
    _hydrateInitialMedicines(initial);
  }

  @override
  void onClose() {
    nameController.dispose();
    subtitleController.dispose();
    dosageController.dispose();
    super.onClose();
  }

  String shortDate(String value) {
    final text = value.trim();
    if (text.length >= 10) {
      return text.substring(5, 10);
    }
    return text;
  }

  String dateRangeChipText(AppLocalizations? l10n) {
    if (_startDate.isEmpty && _endDate.isEmpty) {
      return l10n?.reminderDateRangeAllTime ?? '全时段';
    }
    if (_startDate.isNotEmpty && _endDate.isNotEmpty) {
      return l10n?.reminderDateRangeBetweenShort(
            shortDate(_startDate),
            shortDate(_endDate),
          ) ??
          '${shortDate(_startDate)}~${shortDate(_endDate)}';
    }
    if (_startDate.isNotEmpty) {
      return l10n?.reminderDateRangeFromShort(shortDate(_startDate)) ??
          '${shortDate(_startDate)}起';
    }
    return l10n?.reminderDateRangeUntilShort(shortDate(_endDate)) ??
        '至${shortDate(_endDate)}';
  }

  String buildSelectedIdentitySubtitle(AppLocalizations? l10n) {
    if (_selectedMedicines.isEmpty) {
      return l10n?.reminderEditSelectMedicineHint ?? '可从"我的药品/搜索库"选择';
    }
    if (_selectedMedicines.length == 1) {
      final selected = _selectedMedicines.first;
      final drugCode = selected.drugCode.trim().isEmpty
          ? '-'
          : selected.drugCode.trim();
      final approvalNo = selected.approvalNo.trim().isEmpty
          ? '-'
          : selected.approvalNo.trim();
      return l10n?.reminderEditSelectedIdentity(drugCode, approvalNo) ??
          'Drug Code: $drugCode  Approval No.: $approvalNo';
    }
    final first = _selectedMedicines.first;
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    if (locale.startsWith('zh')) {
      return '已选择 ${_selectedMedicines.length} 种药品，首项: ${first.productName}';
    }
    return '${_selectedMedicines.length} medicines selected, first: ${first.productName}';
  }

  void clearDateRange() {
    _startDate = '';
    _endDate = '';
    update();
  }

  void setEnabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    update();
  }

  void removeSelectedMedicineAt(int index) {
    if (index < 0 || index >= _selectedMedicines.length) {
      return;
    }
    _selectedMedicines.removeAt(index);
    nameController.text = normalizedProductName;
    update();
  }

  Future<void> pickMedicine(
    BuildContext context, {
    required String pickerTitle,
    required String duplicateToast,
  }) async {
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(title: pickerTitle),
      ),
    );
    if (!context.mounted || isClosed || item == null) {
      return;
    }
    final identity = medicineIdentityKey(item);
    if (_selectedMedicines.any((e) => medicineIdentityKey(e) == identity)) {
      ToastUtils.instance.show(context, duplicateToast);
      return;
    }

    _selectedMedicines.add(item);
    nameController.text = normalizedProductName;
    update();
  }

  Future<void> pickTime(BuildContext context) async {
    final parts = _time.split(':');
    final h = parts.length == 2 ? int.tryParse(parts[0]) ?? 8 : 8;
    final m = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (!context.mounted || isClosed || picked == null) {
      return;
    }
    _time =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    update();
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await _pickDate(
      context,
      _startDate.isEmpty ? _endDate : _startDate,
    );
    if (!context.mounted || isClosed || picked == null) {
      return;
    }
    _startDate = picked;
    update();
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await _pickDate(
      context,
      _endDate.isEmpty ? _startDate : _endDate,
    );
    if (!context.mounted || isClosed || picked == null) {
      return;
    }
    _endDate = picked;
    update();
  }

  Future<ReminderPlan?> save(
    BuildContext context, {
    required String needLoginToast,
    required String nameRequiredToast,
    required String invalidDateRangeToast,
  }) async {
    final scopedUserId = userId;
    if (scopedUserId.trim().isEmpty) {
      ToastUtils.instance.show(context, needLoginToast);
      Navigator.pushNamed(context, '/login');
      return null;
    }

    if (_selectedMedicines.isEmpty) {
      ToastUtils.instance.show(context, nameRequiredToast);
      return null;
    }
    final productName = normalizedProductName;
    final medicines = _selectedMedicines
        .where((item) => item.productName.trim().isNotEmpty)
        .map(
          (item) => ReminderMedicineRef(
            drugCode: item.drugCode.trim(),
            approvalNo: item.approvalNo.trim(),
            productName: item.productName.trim(),
          ),
        )
        .toList(growable: false);

    if (medicines.isEmpty) {
      ToastUtils.instance.show(context, nameRequiredToast);
      return null;
    }

    final primaryMedicine = medicines.first;
    if (_startDate.isNotEmpty &&
        _endDate.isNotEmpty &&
        _startDate.compareTo(_endDate) > 0) {
      ToastUtils.instance.show(context, invalidDateRangeToast);
      return null;
    }

    _saving = true;
    update();

    try {
      final response = await ReminderApi.upsert(
        userId: scopedUserId,
        id: initial?.id,
        time: _time,
        drugCode: primaryMedicine.drugCode,
        approvalNo: primaryMedicine.approvalNo,
        productName: productName,
        medicines: medicines,
        dosage: normalizedDosage,
        subtitle: normalizedExtraContent,
        enabled: _enabled,
        repeatRule: 'daily',
        method: 'notification',
        startDate: _startDate,
        endDate: _endDate,
      );
      await _syncReminderMedicinesToLocal(scopedUserId);
      return response.result;
    } finally {
      if (!isClosed) {
        _saving = false;
        update();
      }
    }
  }

  String doseLabel(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '服用剂量(可选)' : 'Dose (optional)';
  }

  String doseHint(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '例如 1 粒 / 5 ml' : 'e.g. 1 tablet / 5 ml';
  }

  String extraContentLabel(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh')
        ? '额外提醒内容(可选)'
        : 'Extra reminder content (optional)';
  }

  String extraContentHint(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh')
        ? '例如 饭后服用，注意多喝水'
        : 'e.g. Take after meals and drink more water';
  }

  void _hydrateInitialMedicines(ReminderPlan? init) {
    final refs = init?.medicines ?? const <ReminderMedicineRef>[];
    if (refs.isNotEmpty) {
      _selectedMedicines.addAll(
        refs
            .where((item) => item.productName.trim().isNotEmpty)
            .map(_toMedicineItem)
            .toList(growable: false),
      );
    } else if ((init?.productName ?? '').trim().isNotEmpty) {
      _selectedMedicines.add(
        MedicineItem(
          serialNo: '',
          approvalNo: init?.approvalNo ?? '',
          productName: init?.productName ?? '',
          dosageForm: '',
          specification: init?.dosage ?? '',
          marketingAuthorizationHolder: '',
          manufacturer: '',
          drugCode: init?.drugCode ?? '',
          drugCodeRemark: '',
        ),
      );
    }
    nameController.text = normalizedProductName;
  }

  MedicineItem _toMedicineItem(ReminderMedicineRef ref) {
    return MedicineItem(
      serialNo: '',
      approvalNo: ref.approvalNo,
      productName: ref.productName,
      dosageForm: '',
      specification: normalizedDosage,
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: ref.drugCode,
      drugCodeRemark: '',
    );
  }

  String _composeSelectedMedicineNames() {
    final names = _selectedMedicines
        .map((item) => item.productName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) {
      return nameController.text.trim();
    }
    return names.toSet().join('、');
  }

  String medicineIdentityKey(MedicineItem item) {
    final drugCode = item.drugCode.trim();
    if (drugCode.isNotEmpty) {
      return 'drug:$drugCode';
    }
    final approvalNo = item.approvalNo.trim();
    if (approvalNo.isNotEmpty) {
      return 'approval:$approvalNo';
    }
    return 'name:${item.productName.trim()}';
  }

  DateTime _resolvePickerInitial(String raw) {
    final now = DateTime.now();
    final minDate = DateTime(2000, 1, 1);
    final maxDate = DateTime(now.year + 5, 12, 31);
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return now;
    }
    if (parsed.isBefore(minDate)) {
      return minDate;
    }
    if (parsed.isAfter(maxDate)) {
      return maxDate;
    }
    return parsed;
  }

  Future<String?> _pickDate(BuildContext context, String initialRaw) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _resolvePickerInitial(initialRaw),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) {
      return null;
    }
    return '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _syncReminderMedicinesToLocal(String scopedUserId) async {
    if (scopedUserId.trim().isEmpty || _selectedMedicines.isEmpty) {
      return;
    }
    for (final item in _selectedMedicines) {
      final normalized = MedicineItem(
        serialNo: item.serialNo,
        approvalNo: item.approvalNo,
        productName: item.productName,
        dosageForm: item.dosageForm,
        specification: item.specification.isNotEmpty
            ? item.specification
            : normalizedDosage,
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
