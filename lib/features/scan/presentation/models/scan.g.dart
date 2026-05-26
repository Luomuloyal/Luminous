// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ScanCandidateToJson(ScanCandidate instance) =>
    <String, dynamic>{
      'drugCode': instance.drugCode,
      'approvalNo': instance.approvalNo,
      'productName': instance.productName,
      'dosageForm': instance.dosageForm,
      'specification': instance.specification,
      'manufacturer': instance.manufacturer,
      'score': instance.score,
    };

Map<String, dynamic> _$MedicineScanResultToJson(MedicineScanResult instance) =>
    <String, dynamic>{
      'candidates': instance.candidates,
      'thumbBase64': instance.thumbBase64,
    };
