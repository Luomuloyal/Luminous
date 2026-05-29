// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_data_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterDataDto extends RegisterDataDto {
  @override
  final UserBriefDto user;
  @override
  final TokensDto tokens;

  factory _$RegisterDataDto([void Function(RegisterDataDtoBuilder)? updates]) =>
      (RegisterDataDtoBuilder()..update(updates))._build();

  _$RegisterDataDto._({required this.user, required this.tokens}) : super._();
  @override
  RegisterDataDto rebuild(void Function(RegisterDataDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterDataDtoBuilder toBuilder() => RegisterDataDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterDataDto &&
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
    return (newBuiltValueToStringHelper(r'RegisterDataDto')
          ..add('user', user)
          ..add('tokens', tokens))
        .toString();
  }
}

class RegisterDataDtoBuilder
    implements Builder<RegisterDataDto, RegisterDataDtoBuilder> {
  _$RegisterDataDto? _$v;

  UserBriefDtoBuilder? _user;
  UserBriefDtoBuilder get user => _$this._user ??= UserBriefDtoBuilder();
  set user(UserBriefDtoBuilder? user) => _$this._user = user;

  TokensDtoBuilder? _tokens;
  TokensDtoBuilder get tokens => _$this._tokens ??= TokensDtoBuilder();
  set tokens(TokensDtoBuilder? tokens) => _$this._tokens = tokens;

  RegisterDataDtoBuilder() {
    RegisterDataDto._defaults(this);
  }

  RegisterDataDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _tokens = $v.tokens.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterDataDto other) {
    _$v = other as _$RegisterDataDto;
  }

  @override
  void update(void Function(RegisterDataDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterDataDto build() => _build();

  _$RegisterDataDto _build() {
    _$RegisterDataDto _$result;
    try {
      _$result = _$v ??
          _$RegisterDataDto._(
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
            r'RegisterDataDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
