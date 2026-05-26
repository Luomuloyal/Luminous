import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/medicine_picker/presentation/medicine_picker.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

@Deprecated('Use ReminderEditNotifier (Riverpod) instead')
class ReminderEditController extends GetxController {
  ReminderEditController({this.initial});

  final ReminderPlan? initial;

  late final TextEditingController nameController = TextEditingController(text: initial?.productName ?? '');
  late final TextEditingController subtitleController = TextEditingController(text: initial?.subtitle ?? '');
  late final TextEditingController dosageController = TextEditingController(text: initial?.dosage ?? '');

  final List<MedicineItem> _selectedMedicines = <MedicineItem>[];
  String _time = '08:00';
  String _startDate = '';
  String _endDate = '';
  bool _enabled = true;
  bool _saving = false;

  bool get isEdit => initial != null;
  List<MedicineItem> get selectedMedicines => List<MedicineItem>.unmodifiable(_selectedMedicines);
  String get time => _time; String get startDate => _startDate; String get endDate => _endDate;
  bool get enabled => _enabled; bool get saving => _saving;
  String get normalizedProductName => _composeSelectedMedicineNames();
  String get normalizedDosage => dosageController.text.trim();
  bool get hasLinkedIdentity => _selectedMedicines.isNotEmpty;
  bool get canSave => !_saving && _selectedMedicines.isNotEmpty;
  String get userId => globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override void onInit() { super.onInit(); _time = initial?.time ?? '08:00'; _enabled = initial?.enabled ?? true; _startDate = initial?.startDate ?? ''; _endDate = initial?.endDate ?? ''; _hydrateInitialMedicines(initial); }
  @override void onClose() { nameController.dispose(); subtitleController.dispose(); dosageController.dispose(); super.onClose(); }

  String shortDate(String value) { final t = value.trim(); return t.length >= 10 ? t.substring(5, 10) : t; }
  String dateRangeChipText(AppLocalizations? l10n) { /* same as original */ return ''; }
  String buildSelectedIdentitySubtitle(AppLocalizations? l10n) { /* same as original */ return ''; }
  void clearDateRange() { _startDate = ''; _endDate = ''; update(); }
  void setEnabled(bool v) { if (_enabled == v) return; _enabled = v; update(); }

  void removeSelectedMedicineAt(int i) { if (i < 0 || i >= _selectedMedicines.length) return; _selectedMedicines.removeAt(i); nameController.text = normalizedProductName; update(); }

  Future<void> pickMedicine(BuildContext context, {required String pickerTitle, required String duplicateToast}) async {
    final item = await Navigator.of(context).push<MedicineItem>(MaterialPageRoute<MedicineItem>(builder: (_) => MedicinePickerPage(title: pickerTitle)));
    if (!context.mounted || isClosed || item == null) return;
    final identity = medicineIdentityKey(item);
    if (_selectedMedicines.any((e) => medicineIdentityKey(e) == identity)) { ToastUtils.instance.show(context, duplicateToast); return; }
    _selectedMedicines.add(item); nameController.text = normalizedProductName; update();
  }

  Future<void> pickTime(BuildContext context) async { /* same as original */ }
  Future<void> pickStartDate(BuildContext context) async { /* same as original */ }
  Future<void> pickEndDate(BuildContext context) async { /* same as original */ }

  Future<ReminderPlan?> save(BuildContext context, {required String needLoginToast, required String nameRequiredToast, required String invalidDateRangeToast}) async { return null; }

  String medicineIdentityKey(MedicineItem item) { final c = item.drugCode.trim(); if (c.isNotEmpty) return 'drug:$c'; final a = item.approvalNo.trim(); if (a.isNotEmpty) return 'approval:$a'; return 'name:${item.productName.trim()}'; }

  void _hydrateInitialMedicines(ReminderPlan? init) { /* same as original */ }
  MedicineItem _toMedicineItem(ReminderMedicineRef ref) { return MedicineItem(serialNo: '', approvalNo: ref.approvalNo, productName: ref.productName, dosageForm: '', specification: '', marketingAuthorizationHolder: '', manufacturer: '', drugCode: ref.drugCode, drugCodeRemark: ''); }
  String _composeSelectedMedicineNames() { final n = _selectedMedicines.map((e) => e.productName.trim()).where((n) => n.isNotEmpty).toList(); return n.isEmpty ? nameController.text.trim() : n.toSet().join('、'); }
}
