import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';

void main() {
  group('CodeTicketResult', () {
    test('fromJson → toJson → fromJson round-trip', () {
      final original = CodeTicketResult.fromJson(const {'id': 'ticket-1'});
      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = CodeTicketResult.fromJson(decoded);

      expect(rebuilt.id, 'ticket-1');
    });

    test('fromJson handles _id fallback', () {
      final result = CodeTicketResult.fromJson(const {'_id': 'ticket-99'});
      expect(result.id, 'ticket-99');
    });
  });

  group('RegisterResult', () {
    test('fromJson → toJson → fromJson round-trip', () {
      final original = RegisterResult.fromJson(const {
        'id': 'reg-1',
        'accessToken': 'at-xxx',
        'refreshToken': 'rt-xxx',
      });
      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = RegisterResult.fromJson(decoded);

      expect(rebuilt.id, 'reg-1');
      expect(rebuilt.accessToken, 'at-xxx');
      expect(rebuilt.refreshToken, 'rt-xxx');
    });

    test('fromJson handles missing tokens', () {
      final result = RegisterResult.fromJson(const {'id': 'reg-2'});
      expect(result.accessToken, '');
      expect(result.refreshToken, '');
    });
  });

  group('LoginResult', () {
    test('fromJson → toJson → fromJson round-trip', () {
      final original = LoginResult.fromJson({
        'user': {
          'id': 'u-1',
          'username': 'test',
          'email': 'a@b.com',
          'phone': '13800138000',
          'name': 'Test User',
          'type': 0,
        },
        'accessToken': 'at-xxx',
        'refreshToken': 'rt-xxx',
      });
      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = LoginResult.fromJson(decoded);

      expect(rebuilt.token, 'at-xxx');
      expect(rebuilt.refreshToken, 'rt-xxx');
      expect(rebuilt.user.id, 'u-1');
      expect(rebuilt.user.username, 'test');
    });

    test('fromJson token maps to token field', () {
      final result = LoginResult.fromJson({
        'user': {'id': 'u-1', 'username': 'x', 'email': '', 'phone': '', 'name': '', 'type': 0},
        'accessToken': 'tok',
        'refreshToken': 'ref',
      });
      expect(result.token, 'tok');
    });
  });
}
