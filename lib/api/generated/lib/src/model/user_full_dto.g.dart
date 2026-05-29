// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_full_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserFullDto extends UserFullDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final JsonObject? nickname;
  @override
  final JsonObject? avatar;
  @override
  final bool emailVerified;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  factory _$UserFullDto([void Function(UserFullDtoBuilder)? updates]) =>
      (UserFullDtoBuilder()..update(updates))._build();

  _$UserFullDto._(
      {required this.id,
      required this.email,
      this.nickname,
      this.avatar,
      required this.emailVerified,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  UserFullDto rebuild(void Function(UserFullDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserFullDtoBuilder toBuilder() => UserFullDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserFullDto &&
        id == other.id &&
        email == other.email &&
        nickname == other.nickname &&
        avatar == other.avatar &&
        emailVerified == other.emailVerified &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserFullDto')
          ..add('id', id)
          ..add('email', email)
          ..add('nickname', nickname)
          ..add('avatar', avatar)
          ..add('emailVerified', emailVerified)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class UserFullDtoBuilder implements Builder<UserFullDto, UserFullDtoBuilder> {
  _$UserFullDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  JsonObject? _nickname;
  JsonObject? get nickname => _$this._nickname;
  set nickname(JsonObject? nickname) => _$this._nickname = nickname;

  JsonObject? _avatar;
  JsonObject? get avatar => _$this._avatar;
  set avatar(JsonObject? avatar) => _$this._avatar = avatar;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _updatedAt;
  String? get updatedAt => _$this._updatedAt;
  set updatedAt(String? updatedAt) => _$this._updatedAt = updatedAt;

  UserFullDtoBuilder() {
    UserFullDto._defaults(this);
  }

  UserFullDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _nickname = $v.nickname;
      _avatar = $v.avatar;
      _emailVerified = $v.emailVerified;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserFullDto other) {
    _$v = other as _$UserFullDto;
  }

  @override
  void update(void Function(UserFullDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserFullDto build() => _build();

  _$UserFullDto _build() {
    final _$result = _$v ??
        _$UserFullDto._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'UserFullDto', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'UserFullDto', 'email'),
          nickname: nickname,
          avatar: avatar,
          emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified, r'UserFullDto', 'emailVerified'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserFullDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'UserFullDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
