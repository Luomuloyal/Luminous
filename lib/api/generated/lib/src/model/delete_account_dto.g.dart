// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteAccountDto extends DeleteAccountDto {
  @override
  final String password;

  factory _$DeleteAccountDto(
          [void Function(DeleteAccountDtoBuilder)? updates]) =>
      (DeleteAccountDtoBuilder()..update(updates))._build();

  _$DeleteAccountDto._({required this.password}) : super._();
  @override
  DeleteAccountDto rebuild(void Function(DeleteAccountDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAccountDtoBuilder toBuilder() =>
      DeleteAccountDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAccountDto && password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteAccountDto')
          ..add('password', password))
        .toString();
  }
}

class DeleteAccountDtoBuilder
    implements Builder<DeleteAccountDto, DeleteAccountDtoBuilder> {
  _$DeleteAccountDto? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  DeleteAccountDtoBuilder() {
    DeleteAccountDto._defaults(this);
  }

  DeleteAccountDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAccountDto other) {
    _$v = other as _$DeleteAccountDto;
  }

  @override
  void update(void Function(DeleteAccountDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAccountDto build() => _build();

  _$DeleteAccountDto _build() {
    final _$result = _$v ??
        _$DeleteAccountDto._(
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'DeleteAccountDto', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
