// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_code_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SendVerificationCodeDtoSceneEnum
    _$sendVerificationCodeDtoSceneEnum_register =
    const SendVerificationCodeDtoSceneEnum._('register');
const SendVerificationCodeDtoSceneEnum
    _$sendVerificationCodeDtoSceneEnum_login =
    const SendVerificationCodeDtoSceneEnum._('login');
const SendVerificationCodeDtoSceneEnum
    _$sendVerificationCodeDtoSceneEnum_resetPassword =
    const SendVerificationCodeDtoSceneEnum._('resetPassword');
const SendVerificationCodeDtoSceneEnum
    _$sendVerificationCodeDtoSceneEnum_changeEmail =
    const SendVerificationCodeDtoSceneEnum._('changeEmail');

SendVerificationCodeDtoSceneEnum _$sendVerificationCodeDtoSceneEnumValueOf(
    String name) {
  switch (name) {
    case 'register':
      return _$sendVerificationCodeDtoSceneEnum_register;
    case 'login':
      return _$sendVerificationCodeDtoSceneEnum_login;
    case 'resetPassword':
      return _$sendVerificationCodeDtoSceneEnum_resetPassword;
    case 'changeEmail':
      return _$sendVerificationCodeDtoSceneEnum_changeEmail;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SendVerificationCodeDtoSceneEnum>
    _$sendVerificationCodeDtoSceneEnumValues = BuiltSet<
        SendVerificationCodeDtoSceneEnum>(const <SendVerificationCodeDtoSceneEnum>[
  _$sendVerificationCodeDtoSceneEnum_register,
  _$sendVerificationCodeDtoSceneEnum_login,
  _$sendVerificationCodeDtoSceneEnum_resetPassword,
  _$sendVerificationCodeDtoSceneEnum_changeEmail,
]);

Serializer<SendVerificationCodeDtoSceneEnum>
    _$sendVerificationCodeDtoSceneEnumSerializer =
    _$SendVerificationCodeDtoSceneEnumSerializer();

class _$SendVerificationCodeDtoSceneEnumSerializer
    implements PrimitiveSerializer<SendVerificationCodeDtoSceneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'register': 'register',
    'login': 'login',
    'resetPassword': 'reset-password',
    'changeEmail': 'change-email',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'register': 'register',
    'login': 'login',
    'reset-password': 'resetPassword',
    'change-email': 'changeEmail',
  };

  @override
  final Iterable<Type> types = const <Type>[SendVerificationCodeDtoSceneEnum];
  @override
  final String wireName = 'SendVerificationCodeDtoSceneEnum';

  @override
  Object serialize(
          Serializers serializers, SendVerificationCodeDtoSceneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SendVerificationCodeDtoSceneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SendVerificationCodeDtoSceneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SendVerificationCodeDto extends SendVerificationCodeDto {
  @override
  final String email;
  @override
  final SendVerificationCodeDtoSceneEnum scene;

  factory _$SendVerificationCodeDto(
          [void Function(SendVerificationCodeDtoBuilder)? updates]) =>
      (SendVerificationCodeDtoBuilder()..update(updates))._build();

  _$SendVerificationCodeDto._({required this.email, required this.scene})
      : super._();
  @override
  SendVerificationCodeDto rebuild(
          void Function(SendVerificationCodeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SendVerificationCodeDtoBuilder toBuilder() =>
      SendVerificationCodeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendVerificationCodeDto &&
        email == other.email &&
        scene == other.scene;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, scene.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SendVerificationCodeDto')
          ..add('email', email)
          ..add('scene', scene))
        .toString();
  }
}

class SendVerificationCodeDtoBuilder
    implements
        Builder<SendVerificationCodeDto, SendVerificationCodeDtoBuilder> {
  _$SendVerificationCodeDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  SendVerificationCodeDtoSceneEnum? _scene;
  SendVerificationCodeDtoSceneEnum? get scene => _$this._scene;
  set scene(SendVerificationCodeDtoSceneEnum? scene) => _$this._scene = scene;

  SendVerificationCodeDtoBuilder() {
    SendVerificationCodeDto._defaults(this);
  }

  SendVerificationCodeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _scene = $v.scene;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SendVerificationCodeDto other) {
    _$v = other as _$SendVerificationCodeDto;
  }

  @override
  void update(void Function(SendVerificationCodeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendVerificationCodeDto build() => _build();

  _$SendVerificationCodeDto _build() {
    final _$result = _$v ??
        _$SendVerificationCodeDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'SendVerificationCodeDto', 'email'),
          scene: BuiltValueNullFieldError.checkNotNull(
              scene, r'SendVerificationCodeDto', 'scene'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
