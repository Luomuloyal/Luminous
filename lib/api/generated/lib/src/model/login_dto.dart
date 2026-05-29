//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'login_dto.g.dart';

/// LoginDto
///
/// Properties:
/// * [email] - 邮箱地址
/// * [password] - 密码（与验证码二选一）
/// * [code] - 邮箱验证码（与密码二选一）
@BuiltValue()
abstract class LoginDto implements Built<LoginDto, LoginDtoBuilder> {
  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 密码（与验证码二选一）
  @BuiltValueField(wireName: r'password')
  String? get password;

  /// 邮箱验证码（与密码二选一）
  @BuiltValueField(wireName: r'code')
  String? get code;

  LoginDto._();

  factory LoginDto([void updates(LoginDtoBuilder b)]) = _$LoginDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LoginDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LoginDto> get serializer => _$LoginDtoSerializer();
}

class _$LoginDtoSerializer implements PrimitiveSerializer<LoginDto> {
  @override
  final Iterable<Type> types = const [LoginDto, _$LoginDto];

  @override
  final String wireName = r'LoginDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LoginDtoBuilder result,
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
  LoginDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LoginDtoBuilder();
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

