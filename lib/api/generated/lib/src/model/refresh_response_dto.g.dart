// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshResponseDto extends RefreshResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final TokensDto data;

  factory _$RefreshResponseDto(
          [void Function(RefreshResponseDtoBuilder)? updates]) =>
      (RefreshResponseDtoBuilder()..update(updates))._build();

  _$RefreshResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  RefreshResponseDto rebuild(
          void Function(RefreshResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshResponseDtoBuilder toBuilder() =>
      RefreshResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshResponseDto &&
        code == other.code &&
        message == other.message &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class RefreshResponseDtoBuilder
    implements Builder<RefreshResponseDto, RefreshResponseDtoBuilder> {
  _$RefreshResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  TokensDtoBuilder? _data;
  TokensDtoBuilder get data => _$this._data ??= TokensDtoBuilder();
  set data(TokensDtoBuilder? data) => _$this._data = data;

  RefreshResponseDtoBuilder() {
    RefreshResponseDto._defaults(this);
  }

  RefreshResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshResponseDto other) {
    _$v = other as _$RefreshResponseDto;
  }

  @override
  void update(void Function(RefreshResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshResponseDto build() => _build();

  _$RefreshResponseDto _build() {
    _$RefreshResponseDto _$result;
    try {
      _$result = _$v ??
          _$RefreshResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'RefreshResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'RefreshResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefreshResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
