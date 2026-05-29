// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeResponseDto extends MeResponseDto {
  @override
  final num code;
  @override
  final String message;
  @override
  final UserFullDto data;

  factory _$MeResponseDto([void Function(MeResponseDtoBuilder)? updates]) =>
      (MeResponseDtoBuilder()..update(updates))._build();

  _$MeResponseDto._(
      {required this.code, required this.message, required this.data})
      : super._();
  @override
  MeResponseDto rebuild(void Function(MeResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeResponseDtoBuilder toBuilder() => MeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeResponseDto &&
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
    return (newBuiltValueToStringHelper(r'MeResponseDto')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class MeResponseDtoBuilder
    implements Builder<MeResponseDto, MeResponseDtoBuilder> {
  _$MeResponseDto? _$v;

  num? _code;
  num? get code => _$this._code;
  set code(num? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  UserFullDtoBuilder? _data;
  UserFullDtoBuilder get data => _$this._data ??= UserFullDtoBuilder();
  set data(UserFullDtoBuilder? data) => _$this._data = data;

  MeResponseDtoBuilder() {
    MeResponseDto._defaults(this);
  }

  MeResponseDtoBuilder get _$this {
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
  void replace(MeResponseDto other) {
    _$v = other as _$MeResponseDto;
  }

  @override
  void update(void Function(MeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeResponseDto build() => _build();

  _$MeResponseDto _build() {
    _$MeResponseDto _$result;
    try {
      _$result = _$v ??
          _$MeResponseDto._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'MeResponseDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'MeResponseDto', 'message'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
