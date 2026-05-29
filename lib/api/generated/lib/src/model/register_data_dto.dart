//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:luminous_api/src/model/user_brief_dto.dart';
import 'package:luminous_api/src/model/tokens_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_data_dto.g.dart';

/// RegisterDataDto
///
/// Properties:
/// * [user] 
/// * [tokens] 
@BuiltValue()
abstract class RegisterDataDto implements Built<RegisterDataDto, RegisterDataDtoBuilder> {
  @BuiltValueField(wireName: r'user')
  UserBriefDto get user;

  @BuiltValueField(wireName: r'tokens')
  TokensDto get tokens;

  RegisterDataDto._();

  factory RegisterDataDto([void updates(RegisterDataDtoBuilder b)]) = _$RegisterDataDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterDataDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterDataDto> get serializer => _$RegisterDataDtoSerializer();
}

class _$RegisterDataDtoSerializer implements PrimitiveSerializer<RegisterDataDto> {
  @override
  final Iterable<Type> types = const [RegisterDataDto, _$RegisterDataDto];

  @override
  final String wireName = r'RegisterDataDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserBriefDto),
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
    RegisterDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterDataDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserBriefDto),
          ) as UserBriefDto;
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
  RegisterDataDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterDataDtoBuilder();
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

