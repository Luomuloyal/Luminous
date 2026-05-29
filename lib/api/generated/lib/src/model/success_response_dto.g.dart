// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SuccessResponseDto extends SuccessResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final JsonObject? data;

  factory _$SuccessResponseDto(
          [void Function(SuccessResponseDtoBuilder)? updates]) =>
      (SuccessResponseDtoBuilder()..update(updates))._build();

  _$SuccessResponseDto._({required this.code, required this.message, this.data})
      : super._();
  @override
  SuccessResponseDto rebuild(
          void Function(SuccessResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SuccessResponseDtoBuilder toBuilder() =>
      SuccessResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SuccessResponseDto &&
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
    return (newBuiltValueToStringHelper(r'SuccessResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class SuccessResponseDtoBuilder
    implements Builder<SuccessResponseDto, SuccessResponseDtoBuilder> {
  _$SuccessResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  SuccessResponseDtoBuilder() {
    SuccessResponseDto._defaults(this);
  }

  SuccessResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SuccessResponseDto other) {
    _$v = other as _$SuccessResponseDto;
  }

  @override
  void update(void Function(SuccessResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SuccessResponseDto build() => _build();

  _$SuccessResponseDto _build() {
    final _$result = _$v ??
        _$SuccessResponseDto._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'SuccessResponseDto', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'SuccessResponseDto', 'message'),
          data: data,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
