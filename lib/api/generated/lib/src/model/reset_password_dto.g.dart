// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResetPasswordDto extends ResetPasswordDto {
  @override
  final String email;
  @override
  final String code;
  @override
  final String password;

  factory _$ResetPasswordDto(
          [void Function(ResetPasswordDtoBuilder)? updates]) =>
      (ResetPasswordDtoBuilder()..update(updates))._build();

  _$ResetPasswordDto._(
      {required this.email, required this.code, required this.password})
      : super._();
  @override
  ResetPasswordDto rebuild(void Function(ResetPasswordDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResetPasswordDtoBuilder toBuilder() =>
      ResetPasswordDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResetPasswordDto &&
        email == other.email &&
        code == other.code &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResetPasswordDto')
          ..add('email', email)
          ..add('code', code)
          ..add('password', password))
        .toString();
  }
}

class ResetPasswordDtoBuilder
    implements Builder<ResetPasswordDto, ResetPasswordDtoBuilder> {
  _$ResetPasswordDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ResetPasswordDtoBuilder() {
    ResetPasswordDto._defaults(this);
  }

  ResetPasswordDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _code = $v.code;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResetPasswordDto other) {
    _$v = other as _$ResetPasswordDto;
  }

  @override
  void update(void Function(ResetPasswordDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResetPasswordDto build() => _build();

  _$ResetPasswordDto _build() {
    final _$result = _$v ??
        _$ResetPasswordDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ResetPasswordDto', 'email'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ResetPasswordDto', 'code'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'ResetPasswordDto', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
