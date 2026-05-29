//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_me_dto.g.dart';

/// UpdateMeDto
///
/// Properties:
/// * [nickname] - 昵称
/// * [avatar] - 头像 URL
@BuiltValue()
abstract class UpdateMeDto implements Built<UpdateMeDto, UpdateMeDtoBuilder> {
  /// 昵称
  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  /// 头像 URL
  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  UpdateMeDto._();

  factory UpdateMeDto([void updates(UpdateMeDtoBuilder b)]) = _$UpdateMeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateMeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateMeDto> get serializer => _$UpdateMeDtoSerializer();
}

class _$UpdateMeDtoSerializer implements PrimitiveSerializer<UpdateMeDto> {
  @override
  final Iterable<Type> types = const [UpdateMeDto, _$UpdateMeDto];

  @override
  final String wireName = r'UpdateMeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateMeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.nickname != null) {
      yield r'nickname';
      yield serializers.serialize(
        object.nickname,
        specifiedType: const FullType(String),
      );
    }
    if (object.avatar != null) {
      yield r'avatar';
      yield serializers.serialize(
        object.avatar,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateMeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateMeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nickname = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatar = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateMeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateMeDtoBuilder();
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

