//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_dto.g.dart';

/// RegisterDto
///
/// Properties:
/// * [email] - 邮箱地址
/// * [password] - 密码（8-32位，需包含大小写字母和数字）
/// * [nickname] - 昵称
@BuiltValue()
abstract class RegisterDto implements Built<RegisterDto, RegisterDtoBuilder> {
  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 密码（8-32位，需包含大小写字母和数字）
  @BuiltValueField(wireName: r'password')
  String get password;

  /// 昵称
  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  RegisterDto._();

  factory RegisterDto([void updates(RegisterDtoBuilder b)]) = _$RegisterDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterDto> get serializer => _$RegisterDtoSerializer();
}

class _$RegisterDtoSerializer implements PrimitiveSerializer<RegisterDto> {
  @override
  final Iterable<Type> types = const [RegisterDto, _$RegisterDto];

  @override
  final String wireName = r'RegisterDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    if (object.nickname != null) {
      yield r'nickname';
      yield serializers.serialize(
        object.nickname,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterDtoBuilder result,
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
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nickname = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterDtoBuilder();
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

