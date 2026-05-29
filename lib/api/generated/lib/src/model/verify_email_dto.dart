//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_email_dto.g.dart';

/// VerifyEmailDto
///
/// Properties:
/// * [email] - 邮箱地址
/// * [code] - 验证码
@BuiltValue()
abstract class VerifyEmailDto implements Built<VerifyEmailDto, VerifyEmailDtoBuilder> {
  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 验证码
  @BuiltValueField(wireName: r'code')
  String get code;

  VerifyEmailDto._();

  factory VerifyEmailDto([void updates(VerifyEmailDtoBuilder b)]) = _$VerifyEmailDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerifyEmailDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerifyEmailDto> get serializer => _$VerifyEmailDtoSerializer();
}

class _$VerifyEmailDtoSerializer implements PrimitiveSerializer<VerifyEmailDto> {
  @override
  final Iterable<Type> types = const [VerifyEmailDto, _$VerifyEmailDto];

  @override
  final String wireName = r'VerifyEmailDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerifyEmailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerifyEmailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VerifyEmailDtoBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerifyEmailDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerifyEmailDtoBuilder();
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

