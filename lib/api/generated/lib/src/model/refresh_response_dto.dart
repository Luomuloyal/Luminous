//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:luminous_api/src/model/tokens_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refresh_response_dto.g.dart';

/// RefreshResponseDto
///
/// Properties:
/// * [code] - 结果码
/// * [message] - 提示消息
/// * [data] 
@BuiltValue()
abstract class RefreshResponseDto implements Built<RefreshResponseDto, RefreshResponseDtoBuilder> {
  /// 结果码
  @BuiltValueField(wireName: r'code')
  num get code;

  /// 提示消息
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'data')
  TokensDto get data;

  RefreshResponseDto._();

  factory RefreshResponseDto([void updates(RefreshResponseDtoBuilder b)]) = _$RefreshResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefreshResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefreshResponseDto> get serializer => _$RefreshResponseDtoSerializer();
}

class _$RefreshResponseDtoSerializer implements PrimitiveSerializer<RefreshResponseDto> {
  @override
  final Iterable<Type> types = const [RefreshResponseDto, _$RefreshResponseDto];

  @override
  final String wireName = r'RefreshResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefreshResponseDto object, {
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
      specifiedType: const FullType(TokensDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefreshResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefreshResponseDtoBuilder result,
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
            specifiedType: const FullType(TokensDto),
          ) as TokensDto;
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
  RefreshResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefreshResponseDtoBuilder();
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

