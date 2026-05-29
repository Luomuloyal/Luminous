// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_data_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyEmailDataDto extends VerifyEmailDataDto {
  @override
  final bool emailVerified;

  factory _$VerifyEmailDataDto(
          [void Function(VerifyEmailDataDtoBuilder)? updates]) =>
      (VerifyEmailDataDtoBuilder()..update(updates))._build();

  _$VerifyEmailDataDto._({required this.emailVerified}) : super._();
  @override
  VerifyEmailDataDto rebuild(
          void Function(VerifyEmailDataDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyEmailDataDtoBuilder toBuilder() =>
      VerifyEmailDataDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyEmailDataDto && emailVerified == other.emailVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyEmailDataDto')
          ..add('emailVerified', emailVerified))
        .toString();
  }
}

class VerifyEmailDataDtoBuilder
    implements Builder<VerifyEmailDataDto, VerifyEmailDataDtoBuilder> {
  _$VerifyEmailDataDto? _$v;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  VerifyEmailDataDtoBuilder() {
    VerifyEmailDataDto._defaults(this);
  }

  VerifyEmailDataDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _emailVerified = $v.emailVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyEmailDataDto other) {
    _$v = other as _$VerifyEmailDataDto;
  }

  @override
  void update(void Function(VerifyEmailDataDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyEmailDataDto build() => _build();

  _$VerifyEmailDataDto _build() {
    final _$result = _$v ??
        _$VerifyEmailDataDto._(
          emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified, r'VerifyEmailDataDto', 'emailVerified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
