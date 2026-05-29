//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_account_dto.g.dart';

/// DeleteAccountDto
///
/// Properties:
/// * [password] - 当前密码（确认注销）
@BuiltValue()
abstract class DeleteAccountDto implements Built<DeleteAccountDto, DeleteAccountDtoBuilder> {
  /// 当前密码（确认注销）
  @BuiltValueField(wireName: r'password')
  String get password;

  DeleteAccountDto._();

  factory DeleteAccountDto([void updates(DeleteAccountDtoBuilder b)]) = _$DeleteAccountDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAccountDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAccountDto> get serializer => _$DeleteAccountDtoSerializer();
}

class _$DeleteAccountDtoSerializer implements PrimitiveSerializer<DeleteAccountDto> {
  @override
  final Iterable<Type> types = const [DeleteAccountDto, _$DeleteAccountDto];

  @override
  final String wireName = r'DeleteAccountDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteAccountDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteAccountDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAccountDtoBuilder();
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

