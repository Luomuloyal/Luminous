//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cooldown_message_dto.g.dart';

/// CooldownMessageDto
///
/// Properties:
/// * [cooldown] - 冷却时间（秒）
/// * [message] - 提示消息
@BuiltValue()
abstract class CooldownMessageDto implements Built<CooldownMessageDto, CooldownMessageDtoBuilder> {
  /// 冷却时间（秒）
  @BuiltValueField(wireName: r'cooldown')
  num get cooldown;

  /// 提示消息
  @BuiltValueField(wireName: r'message')
  String get message;

  CooldownMessageDto._();

  factory CooldownMessageDto([void updates(CooldownMessageDtoBuilder b)]) = _$CooldownMessageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CooldownMessageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CooldownMessageDto> get serializer => _$CooldownMessageDtoSerializer();
}

class _$CooldownMessageDtoSerializer implements PrimitiveSerializer<CooldownMessageDto> {
  @override
  final Iterable<Type> types = const [CooldownMessageDto, _$CooldownMessageDto];

  @override
  final String wireName = r'CooldownMessageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CooldownMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cooldown';
    yield serializers.serialize(
      object.cooldown,
      specifiedType: const FullType(num),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CooldownMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CooldownMessageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cooldown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.cooldown = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CooldownMessageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CooldownMessageDtoBuilder();
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

