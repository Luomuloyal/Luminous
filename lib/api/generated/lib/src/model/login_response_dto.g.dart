// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginResponseDto extends LoginResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final LoginDataDto data;

  factory _$LoginResponseDto(
          [void Function(LoginResponseDtoBuilder)? updates]) =>
      (LoginResponseDtoBuilder()..update(updates))._build();

  _$LoginResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  LoginResponseDto rebuild(void Function(LoginResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginResponseDtoBuilder toBuilder() =>
      LoginResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginResponseDto &&
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
    return (newBuiltValueToStringHelper(r'LoginResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class LoginResponseDtoBuilder
    implements Builder<LoginResponseDto, LoginResponseDtoBuilder> {
  _$LoginResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  LoginDataDtoBuilder? _data;
  LoginDataDtoBuilder get data => _$this._data ??= LoginDataDtoBuilder();
  set data(LoginDataDtoBuilder? data) => _$this._data = data;

  LoginResponseDtoBuilder() {
    LoginResponseDto._defaults(this);
  }

  LoginResponseDtoBuilder get _$this {
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
  void replace(LoginResponseDto other) {
    _$v = other as _$LoginResponseDto;
  }

  @override
  void update(void Function(LoginResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginResponseDto build() => _build();

  _$LoginResponseDto _build() {
    _$LoginResponseDto _$result;
    try {
      _$result = _$v ??
          _$LoginResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'LoginResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'LoginResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LoginResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
