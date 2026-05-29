//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:luminous_api/src/model/tokens_dto.dart';
import 'package:luminous_api/src/model/user_full_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'login_data_dto.g.dart';

/// LoginDataDto
///
/// Properties:
/// * [user] 
/// * [tokens] 
@BuiltValue()
abstract class LoginDataDto implements Built<LoginDataDto, LoginDataDtoBuilder> {
  @BuiltValueField(wireName: r'user')
  UserFullDto get user;

  @BuiltValueField(wireName: r'tokens')
  TokensDto get tokens;

  LoginDataDto._();

  factory LoginDataDto([void updates(LoginDataDtoBuilder b)]) = _$LoginDataDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LoginDataDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LoginDataDto> get serializer => _$LoginDataDtoSerializer();
}

class _$LoginDataDtoSerializer implements PrimitiveSerializer<LoginDataDto> {
  @override
  final Iterable<Type> types = const [LoginDataDto, _$LoginDataDto];

  @override
  final String wireName = r'LoginDataDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LoginDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserFullDto),
    );
    yield r'tokens';
    yield serializers.serialize(
      object.tokens,
      specifiedType: const FullType(TokensDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LoginDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LoginDataDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserFullDto),
          ) as UserFullDto;
          result.user.replace(valueDes);
          break;
        case r'tokens':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TokensDto),
          ) as TokensDto;
          result.tokens.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LoginDataDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LoginDataDtoBuilder();
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

