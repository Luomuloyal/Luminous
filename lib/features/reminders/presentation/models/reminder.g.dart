// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ReminderMedicineRefToJson(
  ReminderMedicineRef instance,
) => <String, dynamic>{
  'drugCode': instance.drugCode,
  'approvalNo': instance.approvalNo,
  'productName': instance.productName,
};

Map<String, dynamic> _$ReminderPlanToJson(ReminderPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'time': instance.time,
      'drugCode': instance.drugCode,
      'approvalNo': instance.approvalNo,
      'productName': instance.productName,
      'medicines': instance.medicines,
      'dosage': instance.dosage,
      'subtitle': instance.subtitle,
      'enabled': instance.enabled,
      'repeatRule': instance.repeatRule,
      'method': instance.method,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };
