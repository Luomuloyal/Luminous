//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tokens_dto.g.dart';

/// TokensDto
///
/// Properties:
/// * [accessToken] - 访问令牌
/// * [refreshToken] - 刷新令牌
/// * [expiresIn] - 访问令牌过期时间（秒）
@BuiltValue()
abstract class TokensDto implements Built<TokensDto, TokensDtoBuilder> {
  /// 访问令牌
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  /// 刷新令牌
  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  /// 访问令牌过期时间（秒）
  @BuiltValueField(wireName: r'expiresIn')
  num get expiresIn;

  TokensDto._();

  factory TokensDto([void updates(TokensDtoBuilder b)]) = _$TokensDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TokensDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TokensDto> get serializer => _$TokensDtoSerializer();
}

class _$TokensDtoSerializer implements PrimitiveSerializer<TokensDto> {
  @override
  final Iterable<Type> types = const [TokensDto, _$TokensDto];

  @override
  final String wireName = r'TokensDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TokensDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'expiresIn';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TokensDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TokensDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'expiresIn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.expiresIn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TokensDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TokensDtoBuilder();
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

