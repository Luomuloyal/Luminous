// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_me_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateMeDto extends UpdateMeDto {
  @override
  final String? nickname;
  @override
  final String? avatar;

  factory _$UpdateMeDto([void Function(UpdateMeDtoBuilder)? updates]) =>
      (UpdateMeDtoBuilder()..update(updates))._build();

  _$UpdateMeDto._({this.nickname, this.avatar}) : super._();
  @override
  UpdateMeDto rebuild(void Function(UpdateMeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateMeDtoBuilder toBuilder() => UpdateMeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateMeDto &&
        nickname == other.nickname &&
        avatar == other.avatar;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateMeDto')
          ..add('nickname', nickname)
          ..add('avatar', avatar))
        .toString();
  }
}

class UpdateMeDtoBuilder implements Builder<UpdateMeDto, UpdateMeDtoBuilder> {
  _$UpdateMeDto? _$v;

  String? _nickname;
  String? get nickname => _$this._nickname;
  set nickname(String? nickname) => _$this._nickname = nickname;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  UpdateMeDtoBuilder() {
    UpdateMeDto._defaults(this);
  }

  UpdateMeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nickname = $v.nickname;
      _avatar = $v.avatar;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateMeDto other) {
    _$v = other as _$UpdateMeDto;
  }

  @override
  void update(void Function(UpdateMeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateMeDto build() => _build();

  _$UpdateMeDto _build() {
    final _$result = _$v ??
        _$UpdateMeDto._(
          nickname: nickname,
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
