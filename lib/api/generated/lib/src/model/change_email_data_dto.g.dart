// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_data_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeEmailDataDto extends ChangeEmailDataDto {
  @override
  final String email;
  @override
  final bool emailVerified;

  factory _$ChangeEmailDataDto(
          [void Function(ChangeEmailDataDtoBuilder)? updates]) =>
      (ChangeEmailDataDtoBuilder()..update(updates))._build();

  _$ChangeEmailDataDto._({required this.email, required this.emailVerified})
      : super._();
  @override
  ChangeEmailDataDto rebuild(
          void Function(ChangeEmailDataDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangeEmailDataDtoBuilder toBuilder() =>
      ChangeEmailDataDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeEmailDataDto &&
        email == other.email &&
        emailVerified == other.emailVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeEmailDataDto')
          ..add('email', email)
          ..add('emailVerified', emailVerified))
        .toString();
  }
}

class ChangeEmailDataDtoBuilder
    implements Builder<ChangeEmailDataDto, ChangeEmailDataDtoBuilder> {
  _$ChangeEmailDataDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  ChangeEmailDataDtoBuilder() {
    ChangeEmailDataDto._defaults(this);
  }

  ChangeEmailDataDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _emailVerified = $v.emailVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeEmailDataDto other) {
    _$v = other as _$ChangeEmailDataDto;
  }

  @override
  void update(void Function(ChangeEmailDataDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeEmailDataDto build() => _build();

  _$ChangeEmailDataDto _build() {
    final _$result = _$v ??
        _$ChangeEmailDataDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ChangeEmailDataDto', 'email'),
          emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified, r'ChangeEmailDataDto', 'emailVerified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
