import 'package:flutter/material.dart';
import 'package:luminous/utils/app_i18n_text.dart';

/// 药品页（Drug）相关的数据结构与展示模型。
///
/// 该文件承担数据职责：
/// - `DrugQuickEntry`：描述"快捷入口"卡片的数据；
/// - `DrugMedicineCardViewModel`：把数据库行转换为 UI 友好数据。
class DrugQuickEntry {
  /// 创建一个快捷入口数据对象。
  const DrugQuickEntry({
    required this.entryKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeName,
  });

  /// 快捷入口稳定标识，用于点击分支等逻辑判断。
  final String entryKey;

  /// 卡片主标题。
  final String title;

  /// 卡片副标题。
  final String subtitle;

  /// 卡片图标。
  final IconData icon;

  /// 卡片主色（用于图标背景和图标本身）。
  final Color color;

  /// 点击后跳转的路由名。
  ///
  /// 为空表示该入口走自定义逻辑（例如打开拍照识别或药品选择器）。
  final String routeName;
}

/// "我的药品"列表卡片的展示模型。
///
/// 作用：把数据库查询出来的 `Map<String, dynamic>` 行数据规范化为 UI 渲染直接使用的字段，
/// 避免在 Widget build 中大量拼字符串和判断，减少重复工作。
class DrugMedicineCardViewModel {
  /// 创建一个药品卡片展示模型。
  DrugMedicineCardViewModel({
    required this.productName,
    required this.subtitle,
    required this.metaText,
    required this.sourceLabel,
    required this.sourceColor,
    required this.dateText,
  });

  /// 从数据库行数据构建卡片展示模型。
  ///
  /// 该方法会做：
  /// - 字段兜底与字符串化；
  /// - 副标题/元信息拼接；
  /// - 来源徽标映射；
  /// - 创建日期格式化。
  factory DrugMedicineCardViewModel.fromRow(
    Map<String, dynamic> row, {
    String? unknownProductName,
    String? approvalNoLabel,
    String? sourceScanLabel,
    String? sourceManualSearchLabel,
  }) {
    final unknownName =
        unknownProductName ??
        AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine');
    final approvalLabel =
        approvalNoLabel ?? AppI18nText.pick(zh: '批准文号', en: 'Approval No.');
    final scanLabel =
        sourceScanLabel ?? AppI18nText.pick(zh: '拍照识别', en: 'Photo scan');
    final manualLabel =
        sourceManualSearchLabel ??
        AppI18nText.pick(zh: '手动搜索', en: 'Manual search');

    // 剂型字段。
    final dosageForm = (row['dosageForm'] ?? '').toString();
    // 规格字段。
    final specification = (row['specification'] ?? '').toString();
    // 生产单位字段。
    final manufacturer = (row['manufacturer'] ?? '').toString();
    // 批准文号字段。
    final approvalNo = (row['approvalNo'] ?? '').toString();
    // 来源字段（scan/manual 等）。
    final source = (row['source'] ?? '').toString();
    // 创建时间戳（毫秒）。
    final createdAt = row['createdAt'];

    // 副标题组成：剂型 + 规格。
    final subtitleParts = <String>[
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ];

    // 元信息组成：生产单位 + 批准文号。
    final metaParts = <String>[
      if (manufacturer.isNotEmpty) manufacturer,
      if (approvalNo.isNotEmpty) '$approvalLabel: $approvalNo',
    ];

    return DrugMedicineCardViewModel(
      productName: (row['productName'] ?? unknownName).toString(),
      subtitle: subtitleParts.join(' · '),
      metaText: metaParts.join('  '),
      sourceLabel: source.isEmpty
          ? ''
          : (source == 'scan' ? scanLabel : manualLabel),
      sourceColor: source == 'scan'
          ? const Color(0xFF10B981)
          : const Color(0xFF0EA5E9),
      dateText: _formatDate(createdAt),
    );
  }

  /// 药品名称（为空时一般会兜底为"未知药品"）。
  final String productName;

  /// 副标题（剂型 + 规格）。
  final String subtitle;

  /// 额外元信息（厂家/批准文号等拼接文本）。
  final String metaText;

  /// 来源徽标文本（例如"拍照识别""手动搜索"）。
  final String sourceLabel;

  /// 来源徽标颜色。
  final Color sourceColor;

  /// 创建日期显示文本（yyyy-MM-dd）。
  final String dateText;
}

/// 将毫秒时间戳格式化为 `yyyy-MM-dd`。
///
/// - 输入为空或不可解析时返回空字符串；
/// - 这样 UI 层可以用 `isNotEmpty` 判断是否展示日期。
String _formatDate(dynamic createdAt) {
  if (createdAt == null) {
    return '';
  }
  final milliseconds = createdAt is int
      ? createdAt
      : int.tryParse(createdAt.toString());
  if (milliseconds == null || milliseconds <= 0) {
    return '';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: false);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
