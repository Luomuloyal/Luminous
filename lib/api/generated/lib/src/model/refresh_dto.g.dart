// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshDto extends RefreshDto {
  @override
  final String refreshToken;

  factory _$RefreshDto([void Function(RefreshDtoBuilder)? updates]) =>
      (RefreshDtoBuilder()..update(updates))._build();

  _$RefreshDto._({required this.refreshToken}) : super._();
  @override
  RefreshDto rebuild(void Function(RefreshDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshDtoBuilder toBuilder() => RefreshDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshDto && refreshToken == other.refreshToken;
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
    return (newBuiltValueToStringHelper(r'RefreshDto')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshDtoBuilder implements Builder<RefreshDto, RefreshDtoBuilder> {
  _$RefreshDto? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshDtoBuilder() {
    RefreshDto._defaults(this);
  }

  RefreshDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshDto other) {
    _$v = other as _$RefreshDto;
  }

  @override
  void update(void Function(RefreshDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshDto build() => _build();

  _$RefreshDto _build() {
    final _$result = _$v ??
        _$RefreshDto._(
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'RefreshDto', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
