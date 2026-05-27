// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$MedicineItemToJson(MedicineItem instance) =>
    <String, dynamic>{
      'serialNo': instance.serialNo,
      'approvalNo': instance.approvalNo,
      'productName': instance.productName,
      'dosageForm': instance.dosageForm,
      'specification': instance.specification,
      'marketingAuthorizationHolder': instance.marketingAuthorizationHolder,
      'manufacturer': instance.manufacturer,
      'drugCode': instance.drugCode,
      'drugCodeRemark': instance.drugCodeRemark,
    };

Map<String, dynamic> _$MedicineAiDetailResultToJson(
  MedicineAiDetailResult instance,
) => <String, dynamic>{
  'text': instance.text,
  'source': instance.source,
  'cachedAt': instance.cachedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
};
