//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_brief_dto.g.dart';

/// UserBriefDto
///
/// Properties:
/// * [id] - 用户 ID
/// * [email] - 邮箱地址
/// * [nickname] - 昵称
/// * [emailVerified] - 邮箱是否已验证
/// * [createdAt] - 创建时间 (ISO 8601)
@BuiltValue()
abstract class UserBriefDto implements Built<UserBriefDto, UserBriefDtoBuilder> {
  /// 用户 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 邮箱地址
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 昵称
  @BuiltValueField(wireName: r'nickname')
  JsonObject? get nickname;

  /// 邮箱是否已验证
  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  /// 创建时间 (ISO 8601)
  @BuiltValueField(wireName: r'createdAt')
  String get createdAt;

  UserBriefDto._();

  factory UserBriefDto([void updates(UserBriefDtoBuilder b)]) = _$UserBriefDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserBriefDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserBriefDto> get serializer => _$UserBriefDtoSerializer();
}

class _$UserBriefDtoSerializer implements PrimitiveSerializer<UserBriefDto> {
  @override
  final Iterable<Type> types = const [UserBriefDto, _$UserBriefDto];

  @override
  final String wireName = r'UserBriefDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserBriefDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'nickname';
    yield object.nickname == null ? null : serializers.serialize(
      object.nickname,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserBriefDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserBriefDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.nickname = valueDes;
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserBriefDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserBriefDtoBuilder();
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

