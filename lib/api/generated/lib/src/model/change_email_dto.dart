//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_email_dto.g.dart';

/// ChangeEmailDto
///
/// Properties:
/// * [currentEmail] - 当前邮箱
/// * [newEmail] - 新邮箱
/// * [code] - 验证码
@BuiltValue()
abstract class ChangeEmailDto implements Built<ChangeEmailDto, ChangeEmailDtoBuilder> {
  /// 当前邮箱
  @BuiltValueField(wireName: r'currentEmail')
  String get currentEmail;

  /// 新邮箱
  @BuiltValueField(wireName: r'newEmail')
  String get newEmail;

  /// 验证码
  @BuiltValueField(wireName: r'code')
  String get code;

  ChangeEmailDto._();

  factory ChangeEmailDto([void updates(ChangeEmailDtoBuilder b)]) = _$ChangeEmailDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangeEmailDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangeEmailDto> get serializer => _$ChangeEmailDtoSerializer();
}

class _$ChangeEmailDtoSerializer implements PrimitiveSerializer<ChangeEmailDto> {
  @override
  final Iterable<Type> types = const [ChangeEmailDto, _$ChangeEmailDto];

  @override
  final String wireName = r'ChangeEmailDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangeEmailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currentEmail';
    yield serializers.serialize(
      object.currentEmail,
      specifiedType: const FullType(String),
    );
    yield r'newEmail';
    yield serializers.serialize(
      object.newEmail,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChangeEmailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangeEmailDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currentEmail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentEmail = valueDes;
          break;
        case r'newEmail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newEmail = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChangeEmailDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangeEmailDtoBuilder();
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

