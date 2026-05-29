//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_email_data_dto.g.dart';

/// VerifyEmailDataDto
///
/// Properties:
/// * [emailVerified] - 邮箱是否已验证
@BuiltValue()
abstract class VerifyEmailDataDto implements Built<VerifyEmailDataDto, VerifyEmailDataDtoBuilder> {
  /// 邮箱是否已验证
  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  VerifyEmailDataDto._();

  factory VerifyEmailDataDto([void updates(VerifyEmailDataDtoBuilder b)]) = _$VerifyEmailDataDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerifyEmailDataDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerifyEmailDataDto> get serializer => _$VerifyEmailDataDtoSerializer();
}

class _$VerifyEmailDataDtoSerializer implements PrimitiveSerializer<VerifyEmailDataDto> {
  @override
  final Iterable<Type> types = const [VerifyEmailDataDto, _$VerifyEmailDataDto];

  @override
  final String wireName = r'VerifyEmailDataDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerifyEmailDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerifyEmailDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VerifyEmailDataDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerifyEmailDataDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerifyEmailDataDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

