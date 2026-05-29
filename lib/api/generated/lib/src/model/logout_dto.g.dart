// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LogoutDto extends LogoutDto {
  @override
  final String refreshToken;

  factory _$LogoutDto([void Function(LogoutDtoBuilder)? updates]) =>
      (LogoutDtoBuilder()..update(updates))._build();

  _$LogoutDto._({required this.refreshToken}) : super._();
  @override
  LogoutDto rebuild(void Function(LogoutDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LogoutDtoBuilder toBuilder() => LogoutDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LogoutDto && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LogoutDto')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class LogoutDtoBuilder implements Builder<LogoutDto, LogoutDtoBuilder> {
  _$LogoutDto? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  LogoutDtoBuilder() {
    LogoutDto._defaults(this);
  }

  LogoutDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LogoutDto other) {
    _$v = other as _$LogoutDto;
  }

  @override
  void update(void Function(LogoutDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LogoutDto build() => _build();

  _$LogoutDto _build() {
    final _$result = _$v ??
        _$LogoutDto._(
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'LogoutDto', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
