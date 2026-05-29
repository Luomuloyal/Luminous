// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyEmailDto extends VerifyEmailDto {
  @override
  final String email;
  @override
  final String code;

  factory _$VerifyEmailDto([void Function(VerifyEmailDtoBuilder)? updates]) =>
      (VerifyEmailDtoBuilder()..update(updates))._build();

  _$VerifyEmailDto._({required this.email, required this.code}) : super._();
  @override
  VerifyEmailDto rebuild(void Function(VerifyEmailDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyEmailDtoBuilder toBuilder() => VerifyEmailDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyEmailDto &&
        email == other.email &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyEmailDto')
          ..add('email', email)
          ..add('code', code))
        .toString();
  }
}

class VerifyEmailDtoBuilder
    implements Builder<VerifyEmailDto, VerifyEmailDtoBuilder> {
  _$VerifyEmailDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  VerifyEmailDtoBuilder() {
    VerifyEmailDto._defaults(this);
  }

  VerifyEmailDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyEmailDto other) {
    _$v = other as _$VerifyEmailDto;
  }

  @override
  void update(void Function(VerifyEmailDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyEmailDto build() => _build();

  _$VerifyEmailDto _build() {
    final _$result = _$v ??
        _$VerifyEmailDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'VerifyEmailDto', 'email'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'VerifyEmailDto', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
