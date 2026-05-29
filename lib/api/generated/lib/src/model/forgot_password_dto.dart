//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'forgot_password_dto.g.dart';

/// ForgotPasswordDto
///
/// Properties:
/// * [email] - 邮箱地址
@BuiltValue()
abstract class ForgotPasswordDto implements Built<ForgotPasswordDto, ForgotPasswordDtoBuilder> {
  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  ForgotPasswordDto._();

  factory ForgotPasswordDto([void updates(ForgotPasswordDtoBuilder b)]) = _$ForgotPasswordDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ForgotPasswordDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ForgotPasswordDto> get serializer => _$ForgotPasswordDtoSerializer();
}

class _$ForgotPasswordDtoSerializer implements PrimitiveSerializer<ForgotPasswordDto> {
  @override
  final Iterable<Type> types = const [ForgotPasswordDto, _$ForgotPasswordDto];

  @override
  final String wireName = r'ForgotPasswordDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ForgotPasswordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ForgotPasswordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ForgotPasswordDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ForgotPasswordDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ForgotPasswordDtoBuilder();
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

