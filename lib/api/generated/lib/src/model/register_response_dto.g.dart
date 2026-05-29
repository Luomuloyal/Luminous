// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterResponseDto extends RegisterResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final RegisterDataDto data;

  factory _$RegisterResponseDto(
          [void Function(RegisterResponseDtoBuilder)? updates]) =>
      (RegisterResponseDtoBuilder()..update(updates))._build();

  _$RegisterResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  RegisterResponseDto rebuild(
          void Function(RegisterResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterResponseDtoBuilder toBuilder() =>
      RegisterResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterResponseDto &&
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
    return (newBuiltValueToStringHelper(r'RegisterResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class RegisterResponseDtoBuilder
    implements Builder<RegisterResponseDto, RegisterResponseDtoBuilder> {
  _$RegisterResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  RegisterDataDtoBuilder? _data;
  RegisterDataDtoBuilder get data => _$this._data ??= RegisterDataDtoBuilder();
  set data(RegisterDataDtoBuilder? data) => _$this._data = data;

  RegisterResponseDtoBuilder() {
    RegisterResponseDto._defaults(this);
  }

  RegisterResponseDtoBuilder get _$this {
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
  void replace(RegisterResponseDto other) {
    _$v = other as _$RegisterResponseDto;
  }

  @override
  void update(void Function(RegisterResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterResponseDto build() => _build();

  _$RegisterResponseDto _build() {
    _$RegisterResponseDto _$result;
    try {
      _$result = _$v ??
          _$RegisterResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'RegisterResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'RegisterResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RegisterResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
