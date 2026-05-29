//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'success_response_dto.g.dart';

/// SuccessResponseDto
///
/// Properties:
/// * [code] - 结果码
/// * [message] - 提示消息
/// * [data] - 数据
@BuiltValue()
abstract class SuccessResponseDto implements Built<SuccessResponseDto, SuccessResponseDtoBuilder> {
  /// 结果码
  @BuiltValueField(wireName: r'code')
  num get code;

  /// 提示消息
  @BuiltValueField(wireName: r'message')
  String get message;

  /// 数据
  @BuiltValueField(wireName: r'data')
  JsonObject? get data;

  SuccessResponseDto._();

  factory SuccessResponseDto([void updates(SuccessResponseDtoBuilder b)]) = _$SuccessResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SuccessResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SuccessResponseDto> get serializer => _$SuccessResponseDtoSerializer();
}

class _$SuccessResponseDtoSerializer implements PrimitiveSerializer<SuccessResponseDto> {
  @override
  final Iterable<Type> types = const [SuccessResponseDto, _$SuccessResponseDto];

  @override
  final String wireName = r'SuccessResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SuccessResponseDto object, {
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
    yield object.data == null ? null : serializers.serialize(
      object.data,
      specifiedType: const FullType.nullable(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SuccessResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SuccessResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.data = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SuccessResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SuccessResponseDtoBuilder();
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

