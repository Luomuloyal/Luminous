import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/local_storage/secure_token_store.dart';
import 'package:luminous/core/local_storage/token_manager.dart';
import 'package:luminous/features/auth/data/token_refresh_service.dart';

/// In-memory [SecureTokenStore] for tests.
class _FakeTokenStore implements SecureTokenStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
}

/// A Dio adapter that returns a canned [Response] or throws.
class _FakeAdapter implements HttpClientAdapter {
  final dynamic Function(RequestOptions options) handler;

  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    if (result is Response) {
      final body = result.data;
      final bodyStr = body is String ? body : jsonEncode(body);
      return ResponseBody.fromString(
        bodyStr,
        result.statusCode ?? 200,
        headers: {'content-type': ['application/json']},
      );
    }
    throw result as Object;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeTokenStore store;
  late TokenManager testTokenManager;
  late TokenRefreshService service;
  int sessionExpiredCalls = 0;

  setUp(() async {
    store = _FakeTokenStore();
    testTokenManager = TokenManager(store: store);
    await testTokenManager.init();
    sessionExpiredCalls = 0;
    await testTokenManager.setToken('');
    await testTokenManager.setRefreshToken('');
  });

  Dio makeDio(Map<String, dynamic> body, {int status = 200}) {
    final adapter = _FakeAdapter((_) {
      return Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: status,
        data: body,
      );
    });
    return Dio(BaseOptions())..httpClientAdapter = adapter;
  }

  Dio makeThrowingDio(Object error) {
    final adapter = _FakeAdapter((_) => throw error);
    return Dio(BaseOptions())..httpClientAdapter = adapter;
  }

  group('TokenRefreshService', () {
    test('refresh succeeds and persists new tokens', () async {
      await testTokenManager.setRefreshToken('old-refresh');

      service = TokenRefreshService(
        dio: makeDio({
          'code': '1',
          'result': {
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          },
        }),
        tokenManagerOverride: testTokenManager,
      );

      final result = await service.refresh();
      expect(result, isTrue);

      expect(await testTokenManager.getToken(), 'new-access');
      expect(await testTokenManager.getRefreshToken(), 'new-refresh');
    });

    test('refresh fails when no refresh token stored', () async {
      service = TokenRefreshService(
        dio: makeDio({'code': '1', 'result': {}}),
        tokenManagerOverride: testTokenManager,
      );
      service.onSessionExpired(() => sessionExpiredCalls++);

      final result = await service.refresh();
      expect(result, isFalse);
      expect(sessionExpiredCalls, 1);
    });

    test('refresh fails on server error and fires session expired', () async {
      await testTokenManager.setRefreshToken('stale-token');

      service = TokenRefreshService(
        dio: makeDio({'code': '0', 'msg': 'invalid token'}, status: 401),
        tokenManagerOverride: testTokenManager,
      );
      service.onSessionExpired(() => sessionExpiredCalls++);

      final result = await service.refresh();
      expect(result, isFalse);
      expect(sessionExpiredCalls, 1);
      expect(await testTokenManager.getToken(), '');
    });

    test('refresh fails on network error and fires session expired', () async {
      await testTokenManager.setRefreshToken('network-test');

      service = TokenRefreshService(
        dio: makeThrowingDio(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        ),
        tokenManagerOverride: testTokenManager,
      );
      service.onSessionExpired(() => sessionExpiredCalls++);

      final result = await service.refresh();
      expect(result, isFalse);
      expect(sessionExpiredCalls, 1);
    });

    test('concurrent refresh calls are debounced', () async {
      await testTokenManager.setRefreshToken('debounce-test');

      var callCount = 0;
      final adapter = _FakeAdapter((_) {
        callCount++;
        return Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'code': '1',
            'result': {
              'accessToken': 'at-$callCount',
              'refreshToken': 'rt-$callCount',
            },
          },
        );
      });

      service = TokenRefreshService(
        dio: Dio(BaseOptions())..httpClientAdapter = adapter,
        tokenManagerOverride: testTokenManager,
      );

      final results = await Future.wait([
        service.refresh(),
        service.refresh(),
        service.refresh(),
      ]);

      expect(results.every((r) => r == true), isTrue);
      expect(callCount, 1);
    });

    test('session expired fires at most once during debounced failure',
        () async {
      await testTokenManager.setRefreshToken('fail-debounce');

      service = TokenRefreshService(
        dio: makeDio({'code': '0'}, status: 401),
        tokenManagerOverride: testTokenManager,
      );
      service.onSessionExpired(() => sessionExpiredCalls++);

      final results = await Future.wait([
        service.refresh(),
        service.refresh(),
        service.refresh(),
      ]);

      expect(results.every((r) => r == false), isTrue);
      expect(sessionExpiredCalls, 1);
    });
  });
}
