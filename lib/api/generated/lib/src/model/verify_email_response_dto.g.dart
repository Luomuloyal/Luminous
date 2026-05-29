// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyEmailResponseDto extends VerifyEmailResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final VerifyEmailDataDto data;

  factory _$VerifyEmailResponseDto(
          [void Function(VerifyEmailResponseDtoBuilder)? updates]) =>
      (VerifyEmailResponseDtoBuilder()..update(updates))._build();

  _$VerifyEmailResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  VerifyEmailResponseDto rebuild(
          void Function(VerifyEmailResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyEmailResponseDtoBuilder toBuilder() =>
      VerifyEmailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyEmailResponseDto &&
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
    return (newBuiltValueToStringHelper(r'VerifyEmailResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class VerifyEmailResponseDtoBuilder
    implements Builder<VerifyEmailResponseDto, VerifyEmailResponseDtoBuilder> {
  _$VerifyEmailResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  VerifyEmailDataDtoBuilder? _data;
  VerifyEmailDataDtoBuilder get data =>
      _$this._data ??= VerifyEmailDataDtoBuilder();
  set data(VerifyEmailDataDtoBuilder? data) => _$this._data = data;

  VerifyEmailResponseDtoBuilder() {
    VerifyEmailResponseDto._defaults(this);
  }

  VerifyEmailResponseDtoBuilder get _$this {
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
  void replace(VerifyEmailResponseDto other) {
    _$v = other as _$VerifyEmailResponseDto;
  }

  @override
  void update(void Function(VerifyEmailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyEmailResponseDto build() => _build();

  _$VerifyEmailResponseDto _build() {
    _$VerifyEmailResponseDto _$result;
    try {
      _$result = _$v ??
          _$VerifyEmailResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'VerifyEmailResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'VerifyEmailResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VerifyEmailResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
