// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ForgotPasswordResponseDto extends ForgotPasswordResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final CooldownMessageDto data;

  factory _$ForgotPasswordResponseDto(
          [void Function(ForgotPasswordResponseDtoBuilder)? updates]) =>
      (ForgotPasswordResponseDtoBuilder()..update(updates))._build();

  _$ForgotPasswordResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  ForgotPasswordResponseDto rebuild(
          void Function(ForgotPasswordResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ForgotPasswordResponseDtoBuilder toBuilder() =>
      ForgotPasswordResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ForgotPasswordResponseDto &&
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
    return (newBuiltValueToStringHelper(r'ForgotPasswordResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class ForgotPasswordResponseDtoBuilder
    implements
        Builder<ForgotPasswordResponseDto, ForgotPasswordResponseDtoBuilder> {
  _$ForgotPasswordResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  CooldownMessageDtoBuilder? _data;
  CooldownMessageDtoBuilder get data =>
      _$this._data ??= CooldownMessageDtoBuilder();
  set data(CooldownMessageDtoBuilder? data) => _$this._data = data;

  ForgotPasswordResponseDtoBuilder() {
    ForgotPasswordResponseDto._defaults(this);
  }

  ForgotPasswordResponseDtoBuilder get _$this {
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
  void replace(ForgotPasswordResponseDto other) {
    _$v = other as _$ForgotPasswordResponseDto;
  }

  @override
  void update(void Function(ForgotPasswordResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ForgotPasswordResponseDto build() => _build();

  _$ForgotPasswordResponseDto _build() {
    _$ForgotPasswordResponseDto _$result;
    try {
      _$result = _$v ??
          _$ForgotPasswordResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ForgotPasswordResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'ForgotPasswordResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ForgotPasswordResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
