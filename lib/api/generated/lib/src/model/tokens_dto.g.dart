// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TokensDto extends TokensDto {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final num expiresIn;

  factory _$TokensDto([void Function(TokensDtoBuilder)? updates]) =>
      (TokensDtoBuilder()..update(updates))._build();

  _$TokensDto._(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresIn})
      : super._();
  @override
  TokensDto rebuild(void Function(TokensDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokensDtoBuilder toBuilder() => TokensDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TokensDto &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        expiresIn == other.expiresIn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TokensDto')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('expiresIn', expiresIn))
        .toString();
  }
}

class TokensDtoBuilder implements Builder<TokensDto, TokensDtoBuilder> {
  _$TokensDto? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  num? _expiresIn;
  num? get expiresIn => _$this._expiresIn;
  set expiresIn(num? expiresIn) => _$this._expiresIn = expiresIn;

  TokensDtoBuilder() {
    TokensDto._defaults(this);
  }

  TokensDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _expiresIn = $v.expiresIn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TokensDto other) {
    _$v = other as _$TokensDto;
  }

  @override
  void update(void Function(TokensDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TokensDto build() => _build();

  _$TokensDto _build() {
    final _$result = _$v ??
        _$TokensDto._(
          accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken, r'TokensDto', 'accessToken'),
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'TokensDto', 'refreshToken'),
          expiresIn: BuiltValueNullFieldError.checkNotNull(
              expiresIn, r'TokensDto', 'expiresIn'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
