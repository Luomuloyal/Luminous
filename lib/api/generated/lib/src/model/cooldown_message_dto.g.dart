// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooldown_message_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CooldownMessageDto extends CooldownMessageDto {
  @override
  final num cooldown;
  @override
  final String message;

  factory _$CooldownMessageDto(
          [void Function(CooldownMessageDtoBuilder)? updates]) =>
      (CooldownMessageDtoBuilder()..update(updates))._build();

  _$CooldownMessageDto._({required this.cooldown, required this.message})
      : super._();
  @override
  CooldownMessageDto rebuild(
          void Function(CooldownMessageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CooldownMessageDtoBuilder toBuilder() =>
      CooldownMessageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CooldownMessageDto &&
        cooldown == other.cooldown &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cooldown.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CooldownMessageDto')
          ..add('cooldown', cooldown)
          ..add('message', message))
        .toString();
  }
}

class CooldownMessageDtoBuilder
    implements Builder<CooldownMessageDto, CooldownMessageDtoBuilder> {
  _$CooldownMessageDto? _$v;

  num? _cooldown;
  num? get cooldown => _$this._cooldown;
  set cooldown(num? cooldown) => _$this._cooldown = cooldown;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  CooldownMessageDtoBuilder() {
    CooldownMessageDto._defaults(this);
  }

  CooldownMessageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cooldown = $v.cooldown;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CooldownMessageDto other) {
    _$v = other as _$CooldownMessageDto;
  }

  @override
  void update(void Function(CooldownMessageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CooldownMessageDto build() => _build();

  _$CooldownMessageDto _build() {
    final _$result = _$v ??
        _$CooldownMessageDto._(
          cooldown: BuiltValueNullFieldError.checkNotNull(
              cooldown, r'CooldownMessageDto', 'cooldown'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'CooldownMessageDto', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
