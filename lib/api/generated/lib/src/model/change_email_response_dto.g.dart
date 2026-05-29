// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeEmailResponseDto extends ChangeEmailResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final ChangeEmailDataDto data;

  factory _$ChangeEmailResponseDto(
          [void Function(ChangeEmailResponseDtoBuilder)? updates]) =>
      (ChangeEmailResponseDtoBuilder()..update(updates))._build();

  _$ChangeEmailResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  ChangeEmailResponseDto rebuild(
          void Function(ChangeEmailResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangeEmailResponseDtoBuilder toBuilder() =>
      ChangeEmailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeEmailResponseDto &&
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
    return (newBuiltValueToStringHelper(r'ChangeEmailResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class ChangeEmailResponseDtoBuilder
    implements Builder<ChangeEmailResponseDto, ChangeEmailResponseDtoBuilder> {
  _$ChangeEmailResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ChangeEmailDataDtoBuilder? _data;
  ChangeEmailDataDtoBuilder get data =>
      _$this._data ??= ChangeEmailDataDtoBuilder();
  set data(ChangeEmailDataDtoBuilder? data) => _$this._data = data;

  ChangeEmailResponseDtoBuilder() {
    ChangeEmailResponseDto._defaults(this);
  }

  ChangeEmailResponseDtoBuilder get _$this {
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
  void replace(ChangeEmailResponseDto other) {
    _$v = other as _$ChangeEmailResponseDto;
  }

  @override
  void update(void Function(ChangeEmailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeEmailResponseDto build() => _build();

  _$ChangeEmailResponseDto _build() {
    _$ChangeEmailResponseDto _$result;
    try {
      _$result = _$v ??
          _$ChangeEmailResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ChangeEmailResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'ChangeEmailResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChangeEmailResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
