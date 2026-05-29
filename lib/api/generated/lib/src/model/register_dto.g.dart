// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterDto extends RegisterDto {
  @override
  final String email;
  @override
  final String password;
  @override
  final String? nickname;

  factory _$RegisterDto([void Function(RegisterDtoBuilder)? updates]) =>
      (RegisterDtoBuilder()..update(updates))._build();

  _$RegisterDto._({required this.email, required this.password, this.nickname})
      : super._();
  @override
  RegisterDto rebuild(void Function(RegisterDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterDtoBuilder toBuilder() => RegisterDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterDto &&
        email == other.email &&
        password == other.password &&
        nickname == other.nickname;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterDto')
          ..add('email', email)
          ..add('password', password)
          ..add('nickname', nickname))
        .toString();
  }
}

class RegisterDtoBuilder implements Builder<RegisterDto, RegisterDtoBuilder> {
  _$RegisterDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _nickname;
  String? get nickname => _$this._nickname;
  set nickname(String? nickname) => _$this._nickname = nickname;

  RegisterDtoBuilder() {
    RegisterDto._defaults(this);
  }

  RegisterDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _nickname = $v.nickname;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterDto other) {
    _$v = other as _$RegisterDto;
  }

  @override
  void update(void Function(RegisterDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterDto build() => _build();

  _$RegisterDto _build() {
    final _$result = _$v ??
        _$RegisterDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'RegisterDto', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'RegisterDto', 'password'),
          nickname: nickname,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
