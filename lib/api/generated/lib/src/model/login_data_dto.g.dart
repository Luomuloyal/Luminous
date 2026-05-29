// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginDataDto extends LoginDataDto {
  @override
  final UserFullDto user;
  @override
  final TokensDto tokens;

  factory _$LoginDataDto([void Function(LoginDataDtoBuilder)? updates]) =>
      (LoginDataDtoBuilder()..update(updates))._build();

  _$LoginDataDto._({required this.user, required this.tokens}) : super._();
  @override
  LoginDataDto rebuild(void Function(LoginDataDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginDataDtoBuilder toBuilder() => LoginDataDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginDataDto &&
        user == other.user &&
        tokens == other.tokens;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, tokens.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginDataDto')
          ..add('user', user)
          ..add('tokens', tokens))
        .toString();
  }
}

class LoginDataDtoBuilder
    implements Builder<LoginDataDto, LoginDataDtoBuilder> {
  _$LoginDataDto? _$v;

  UserFullDtoBuilder? _user;
  UserFullDtoBuilder get user => _$this._user ??= UserFullDtoBuilder();
  set user(UserFullDtoBuilder? user) => _$this._user = user;

  TokensDtoBuilder? _tokens;
  TokensDtoBuilder get tokens => _$this._tokens ??= TokensDtoBuilder();
  set tokens(TokensDtoBuilder? tokens) => _$this._tokens = tokens;

  LoginDataDtoBuilder() {
    LoginDataDto._defaults(this);
  }

  LoginDataDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _tokens = $v.tokens.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginDataDto other) {
    _$v = other as _$LoginDataDto;
  }

  @override
  void update(void Function(LoginDataDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginDataDto build() => _build();

  _$LoginDataDto _build() {
    _$LoginDataDto _$result;
    try {
      _$result = _$v ??
          _$LoginDataDto._(
            user: user.build(),
            tokens: tokens.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
        _$failedField = 'tokens';
        tokens.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LoginDataDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
