// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_code_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SendVerificationCodeResponseDto
    extends SendVerificationCodeResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final CooldownMessageDto data;

  factory _$SendVerificationCodeResponseDto(
          [void Function(SendVerificationCodeResponseDtoBuilder)? updates]) =>
      (SendVerificationCodeResponseDtoBuilder()..update(updates))._build();

  _$SendVerificationCodeResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  SendVerificationCodeResponseDto rebuild(
          void Function(SendVerificationCodeResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SendVerificationCodeResponseDtoBuilder toBuilder() =>
      SendVerificationCodeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendVerificationCodeResponseDto &&
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
    return (newBuiltValueToStringHelper(r'SendVerificationCodeResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class SendVerificationCodeResponseDtoBuilder
    implements
        Builder<SendVerificationCodeResponseDto,
            SendVerificationCodeResponseDtoBuilder> {
  _$SendVerificationCodeResponseDto? _$v;

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

  SendVerificationCodeResponseDtoBuilder() {
    SendVerificationCodeResponseDto._defaults(this);
  }

  SendVerificationCodeResponseDtoBuilder get _$this {
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
  void replace(SendVerificationCodeResponseDto other) {
    _$v = other as _$SendVerificationCodeResponseDto;
  }

  @override
  void update(void Function(SendVerificationCodeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendVerificationCodeResponseDto build() => _build();

  _$SendVerificationCodeResponseDto _build() {
    _$SendVerificationCodeResponseDto _$result;
    try {
      _$result = _$v ??
          _$SendVerificationCodeResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'SendVerificationCodeResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'SendVerificationCodeResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SendVerificationCodeResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
