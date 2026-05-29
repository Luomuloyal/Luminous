//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_email_data_dto.g.dart';

/// ChangeEmailDataDto
///
/// Properties:
/// * [email] - 新邮箱地址
/// * [emailVerified] - 邮箱是否已验证
@BuiltValue()
abstract class ChangeEmailDataDto implements Built<ChangeEmailDataDto, ChangeEmailDataDtoBuilder> {
  /// 新邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 邮箱是否已验证
  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  ChangeEmailDataDto._();

  factory ChangeEmailDataDto([void updates(ChangeEmailDataDtoBuilder b)]) = _$ChangeEmailDataDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangeEmailDataDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangeEmailDataDto> get serializer => _$ChangeEmailDataDtoSerializer();
}

class _$ChangeEmailDataDtoSerializer implements PrimitiveSerializer<ChangeEmailDataDto> {
  @override
  final Iterable<Type> types = const [ChangeEmailDataDto, _$ChangeEmailDataDto];

  @override
  final String wireName = r'ChangeEmailDataDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangeEmailDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChangeEmailDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangeEmailDataDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
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
  ChangeEmailDataDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangeEmailDataDtoBuilder();
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

