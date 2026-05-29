//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:luminous_api/src/model/cooldown_message_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'forgot_password_response_dto.g.dart';

/// ForgotPasswordResponseDto
///
/// Properties:
/// * [code] - 结果码
/// * [message] - 提示消息
/// * [data] 
@BuiltValue()
abstract class ForgotPasswordResponseDto implements Built<ForgotPasswordResponseDto, ForgotPasswordResponseDtoBuilder> {
  /// 结果码
  @BuiltValueField(wireName: r'code')
  num get code;

  /// 提示消息
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'data')
  CooldownMessageDto get data;

  ForgotPasswordResponseDto._();

  factory ForgotPasswordResponseDto([void updates(ForgotPasswordResponseDtoBuilder b)]) = _$ForgotPasswordResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ForgotPasswordResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ForgotPasswordResponseDto> get serializer => _$ForgotPasswordResponseDtoSerializer();
}

class _$ForgotPasswordResponseDtoSerializer implements PrimitiveSerializer<ForgotPasswordResponseDto> {
  @override
  final Iterable<Type> types = const [ForgotPasswordResponseDto, _$ForgotPasswordResponseDto];

  @override
  final String wireName = r'ForgotPasswordResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ForgotPasswordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(num),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CooldownMessageDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ForgotPasswordResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ForgotPasswordResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CooldownMessageDto),
          ) as CooldownMessageDto;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ForgotPasswordResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ForgotPasswordResponseDtoBuilder();
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

