import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 本地浏览记录条目。
///
/// 记录最近查看过的药品详情，用于“我的 > 浏览记录”页面展示与再次打开。
class BrowseHistoryEntry {
  const BrowseHistoryEntry({
    required this.identityKey,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.manufacturer,
    required this.marketingAuthorizationHolder,
    required this.drugCode,
    required this.approvalNo,
    required this.viewedAtMillis,
  });

  final String identityKey;
  final String productName;
  final String dosageForm;
  final String specification;
  final String manufacturer;
  final String marketingAuthorizationHolder;
  final String drugCode;
  final String approvalNo;
  final int viewedAtMillis;

  factory BrowseHistoryEntry.fromMedicineItem(
    MedicineItem item, {
    required int viewedAtMillis,
  }) {
    final identityKey = _identityKeyFromMedicine(item);
    return BrowseHistoryEntry(
      identityKey: identityKey,
      productName: item.productName.trim(),
      dosageForm: item.dosageForm.trim(),
      specification: item.specification.trim(),
      manufacturer: item.manufacturer.trim(),
      marketingAuthorizationHolder: item.marketingAuthorizationHolder.trim(),
      drugCode: item.drugCode.trim(),
      approvalNo: item.approvalNo.trim(),
      viewedAtMillis: viewedAtMillis,
    );
  }

  factory BrowseHistoryEntry.fromJson(Map<String, dynamic> json) {
    return BrowseHistoryEntry(
      identityKey: (json['identityKey'] ?? '').toString().trim(),
      productName: (json['productName'] ?? '').toString().trim(),
      dosageForm: (json['dosageForm'] ?? '').toString().trim(),
      specification: (json['specification'] ?? '').toString().trim(),
      manufacturer: (json['manufacturer'] ?? '').toString().trim(),
      marketingAuthorizationHolder: (json['marketingAuthorizationHolder'] ?? '')
          .toString()
          .trim(),
      drugCode: (json['drugCode'] ?? '').toString().trim(),
      approvalNo: (json['approvalNo'] ?? '').toString().trim(),
      viewedAtMillis:
          int.tryParse((json['viewedAtMillis'] ?? '').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identityKey': identityKey,
      'productName': productName,
      'dosageForm': dosageForm,
      'specification': specification,
      'manufacturer': manufacturer,
      'marketingAuthorizationHolder': marketingAuthorizationHolder,
      'drugCode': drugCode,
      'approvalNo': approvalNo,
      'viewedAtMillis': viewedAtMillis,
    };
  }

  bool get hasIdentity => identityKey.isNotEmpty;

  String get displayTitle => productName.isEmpty
      ? AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine')
      : productName;

  String get displaySubtitle {
    final parts = <String>[
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ];
    return parts.isEmpty
        ? AppI18nText.pick(zh: '暂无规格信息', en: 'No specification info')
        : parts.join(' · ');
  }

  String get displayTips {
    if (manufacturer.isNotEmpty) {
      return manufacturer;
    }
    if (marketingAuthorizationHolder.isNotEmpty) {
      return marketingAuthorizationHolder;
    }
    if (approvalNo.isNotEmpty) {
      return approvalNo;
    }
    return '';
  }

  DateTime get viewedAt => viewedAtMillis > 0
      ? DateTime.fromMillisecondsSinceEpoch(viewedAtMillis)
      : DateTime.fromMillisecondsSinceEpoch(0);

  MedicineItem toMedicineItem() {
    return MedicineItem(
      serialNo: '',
      approvalNo: approvalNo,
      productName: productName,
      dosageForm: dosageForm,
      specification: specification,
      marketingAuthorizationHolder: marketingAuthorizationHolder,
      manufacturer: manufacturer,
      drugCode: drugCode,
      drugCodeRemark: '',
    );
  }

  static String identityKeyFromMedicine(MedicineItem item) {
    return _identityKeyFromMedicine(item);
  }
}

String _identityKeyFromMedicine(MedicineItem item) {
  final drugCode = item.drugCode.trim();
  if (drugCode.isNotEmpty) {
    return 'drug:$drugCode';
  }
  final approvalNo = item.approvalNo.trim();
  if (approvalNo.isNotEmpty) {
    return 'approval:$approvalNo';
  }
  return '';
}
