//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refresh_dto.g.dart';

/// RefreshDto
///
/// Properties:
/// * [refreshToken] - 刷新令牌
@BuiltValue()
abstract class RefreshDto implements Built<RefreshDto, RefreshDtoBuilder> {
  /// 刷新令牌
  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  RefreshDto._();

  factory RefreshDto([void updates(RefreshDtoBuilder b)]) = _$RefreshDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefreshDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefreshDto> get serializer => _$RefreshDtoSerializer();
}

class _$RefreshDtoSerializer implements PrimitiveSerializer<RefreshDto> {
  @override
  final Iterable<Type> types = const [RefreshDto, _$RefreshDto];

  @override
  final String wireName = r'RefreshDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefreshDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefreshDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefreshDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RefreshDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefreshDtoBuilder();
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

