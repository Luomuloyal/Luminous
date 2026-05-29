//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'send_verification_code_dto.g.dart';

/// SendVerificationCodeDto
///
/// Properties:
/// * [email] - 邮箱地址
/// * [scene] - 验证码场景
@BuiltValue()
abstract class SendVerificationCodeDto implements Built<SendVerificationCodeDto, SendVerificationCodeDtoBuilder> {
  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 验证码场景
  @BuiltValueField(wireName: r'scene')
  SendVerificationCodeDtoSceneEnum get scene;
  // enum sceneEnum {  register,  login,  reset-password,  change-email,  };

  SendVerificationCodeDto._();

  factory SendVerificationCodeDto([void updates(SendVerificationCodeDtoBuilder b)]) = _$SendVerificationCodeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SendVerificationCodeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SendVerificationCodeDto> get serializer => _$SendVerificationCodeDtoSerializer();
}

class _$SendVerificationCodeDtoSerializer implements PrimitiveSerializer<SendVerificationCodeDto> {
  @override
  final Iterable<Type> types = const [SendVerificationCodeDto, _$SendVerificationCodeDto];

  @override
  final String wireName = r'SendVerificationCodeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SendVerificationCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'scene';
    yield serializers.serialize(
      object.scene,
      specifiedType: const FullType(SendVerificationCodeDtoSceneEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SendVerificationCodeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SendVerificationCodeDtoBuilder result,
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
        case r'scene':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SendVerificationCodeDtoSceneEnum),
          ) as SendVerificationCodeDtoSceneEnum;
          result.scene = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SendVerificationCodeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SendVerificationCodeDtoBuilder();
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

class SendVerificationCodeDtoSceneEnum extends EnumClass {

  /// 验证码场景
  @BuiltValueEnumConst(wireName: r'register')
  static const SendVerificationCodeDtoSceneEnum register = _$sendVerificationCodeDtoSceneEnum_register;
  /// 验证码场景
  @BuiltValueEnumConst(wireName: r'login')
  static const SendVerificationCodeDtoSceneEnum login = _$sendVerificationCodeDtoSceneEnum_login;
  /// 验证码场景
  @BuiltValueEnumConst(wireName: r'reset-password')
  static const SendVerificationCodeDtoSceneEnum resetPassword = _$sendVerificationCodeDtoSceneEnum_resetPassword;
  /// 验证码场景
  @BuiltValueEnumConst(wireName: r'change-email')
  static const SendVerificationCodeDtoSceneEnum changeEmail = _$sendVerificationCodeDtoSceneEnum_changeEmail;

  static Serializer<SendVerificationCodeDtoSceneEnum> get serializer => _$sendVerificationCodeDtoSceneEnumSerializer;

  const SendVerificationCodeDtoSceneEnum._(String name): super(name);

  static BuiltSet<SendVerificationCodeDtoSceneEnum> get values => _$sendVerificationCodeDtoSceneEnumValues;
  static SendVerificationCodeDtoSceneEnum valueOf(String name) => _$sendVerificationCodeDtoSceneEnumValueOf(name);
}

