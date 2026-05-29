// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_brief_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserBriefDto extends UserBriefDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final JsonObject? nickname;
  @override
  final bool emailVerified;
  @override
  final String createdAt;

  factory _$UserBriefDto([void Function(UserBriefDtoBuilder)? updates]) =>
      (UserBriefDtoBuilder()..update(updates))._build();

  _$UserBriefDto._(
      {required this.id,
      required this.email,
      this.nickname,
      required this.emailVerified,
      required this.createdAt})
      : super._();
  @override
  UserBriefDto rebuild(void Function(UserBriefDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBriefDtoBuilder toBuilder() => UserBriefDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserBriefDto &&
        id == other.id &&
        email == other.email &&
        nickname == other.nickname &&
        emailVerified == other.emailVerified &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserBriefDto')
          ..add('id', id)
          ..add('email', email)
          ..add('nickname', nickname)
          ..add('emailVerified', emailVerified)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class UserBriefDtoBuilder
    implements Builder<UserBriefDto, UserBriefDtoBuilder> {
  _$UserBriefDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  JsonObject? _nickname;
  JsonObject? get nickname => _$this._nickname;
  set nickname(JsonObject? nickname) => _$this._nickname = nickname;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  UserBriefDtoBuilder() {
    UserBriefDto._defaults(this);
  }

  UserBriefDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _nickname = $v.nickname;
      _emailVerified = $v.emailVerified;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserBriefDto other) {
    _$v = other as _$UserBriefDto;
  }

  @override
  void update(void Function(UserBriefDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserBriefDto build() => _build();

  _$UserBriefDto _build() {
    final _$result = _$v ??
        _$UserBriefDto._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'UserBriefDto', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'UserBriefDto', 'email'),
          nickname: nickname,
          emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified, r'UserBriefDto', 'emailVerified'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserBriefDto', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
