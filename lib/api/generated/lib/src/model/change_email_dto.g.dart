// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeEmailDto extends ChangeEmailDto {
  @override
  final String currentEmail;
  @override
  final String newEmail;
  @override
  final String code;

  factory _$ChangeEmailDto([void Function(ChangeEmailDtoBuilder)? updates]) =>
      (ChangeEmailDtoBuilder()..update(updates))._build();

  _$ChangeEmailDto._(
      {required this.currentEmail, required this.newEmail, required this.code})
      : super._();
  @override
  ChangeEmailDto rebuild(void Function(ChangeEmailDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangeEmailDtoBuilder toBuilder() => ChangeEmailDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeEmailDto &&
        currentEmail == other.currentEmail &&
        newEmail == other.newEmail &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentEmail.hashCode);
    _$hash = $jc(_$hash, newEmail.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeEmailDto')
          ..add('currentEmail', currentEmail)
          ..add('newEmail', newEmail)
          ..add('code', code))
        .toString();
  }
}

class ChangeEmailDtoBuilder
    implements Builder<ChangeEmailDto, ChangeEmailDtoBuilder> {
  _$ChangeEmailDto? _$v;

  String? _currentEmail;
  String? get currentEmail => _$this._currentEmail;
  set currentEmail(String? currentEmail) => _$this._currentEmail = currentEmail;

  String? _newEmail;
  String? get newEmail => _$this._newEmail;
  set newEmail(String? newEmail) => _$this._newEmail = newEmail;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ChangeEmailDtoBuilder() {
    ChangeEmailDto._defaults(this);
  }

  ChangeEmailDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentEmail = $v.currentEmail;
      _newEmail = $v.newEmail;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeEmailDto other) {
    _$v = other as _$ChangeEmailDto;
  }

  @override
  void update(void Function(ChangeEmailDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeEmailDto build() => _build();

  _$ChangeEmailDto _build() {
    final _$result = _$v ??
        _$ChangeEmailDto._(
          currentEmail: BuiltValueNullFieldError.checkNotNull(
              currentEmail, r'ChangeEmailDto', 'currentEmail'),
          newEmail: BuiltValueNullFieldError.checkNotNull(
              newEmail, r'ChangeEmailDto', 'newEmail'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ChangeEmailDto', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
