import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/lucent_client.dart';

void main() {
  group('LucentPaginationMeta', () {
    test('fromJson parses all fields', () {
      final meta = LucentPaginationMeta.fromJson({
        'page': 2,
        'pageSize': 10,
        'total': 55,
        'totalPages': 6,
      });

      expect(meta.page, 2);
      expect(meta.pageSize, 10);
      expect(meta.total, 55);
      expect(meta.totalPages, 6);
    });

    test('fromJson defaults for missing fields', () {
      final meta = LucentPaginationMeta.fromJson(<String, dynamic>{});

      expect(meta.page, 1);
      expect(meta.pageSize, 20);
      expect(meta.total, 0);
      expect(meta.totalPages, 0);
    });
  });

  group('LucentResponseMeta', () {
    test('fromJson returns empty meta for null', () {
      final meta = LucentResponseMeta.fromJson(null);
      expect(meta.pagination, isNull);
    });

    test('fromJson parses pagination', () {
      final meta = LucentResponseMeta.fromJson({
        'pagination': {'page': 1, 'pageSize': 20, 'total': 0, 'totalPages': 0},
      });

      expect(meta.pagination, isNotNull);
      expect(meta.pagination!.page, 1);
    });
  });

  group('LucentApiResult', () {
    test('isOk returns true for code 0', () {
      final result = LucentApiResult<String>(
        code: 0,
        message: '',
        data: 'test',
      );
      expect(result.isOk, isTrue);
    });

    test('isOk returns false for non-zero code', () {
      final result = LucentApiResult<String>(
        code: 401001,
        message: 'Unauthorized',
        data: '',
      );
      expect(result.isOk, isFalse);
    });

    test('stores all fields correctly', () {
      const result = LucentApiResult<int>(
        code: 0,
        message: 'done',
        data: 42,
      );

      expect(result.code, 0);
      expect(result.message, 'done');
      expect(result.data, 42);
      expect(result.meta, isNull);
    });
  });

  group('parseLucentResponse', () {
    test('success response: parses data and returns LucentApiResult', () {
      final raw = <String, dynamic>{
        'code': 0,
        'message': '',
        'data': {'name': 'Aspirin'},
      };

      final result = parseLucentResponse<Map<String, dynamic>>(
        rawData: raw,
        decoder: (json) => json as Map<String, dynamic>,
      );

      expect(result.code, 0);
      expect(result.message, '');
      expect(result.data['name'], 'Aspirin');
      expect(result.meta, isNull);
    });

    test('success response with null data: passes null to decoder', () {
      final raw = <String, dynamic>{
        'code': 0,
        'message': '',
        'data': null,
      };

      final result = parseLucentResponse<Object?>(
        rawData: raw,
        decoder: (json) => json,
      );

      expect(result.code, 0);
      expect(result.data, isNull);
    });

    test('error response: throws ApiException with code and message', () {
      final raw = <String, dynamic>{
        'code': 401001,
        'message': 'Invalid credentials',
        'data': null,
      };

      expect(
        () => parseLucentResponse<dynamic>(
          rawData: raw,
          decoder: (json) => json,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', '401001')
              .having(
                (e) => e.message,
                'message',
                'Invalid credentials',
              ),
        ),
      );
    });

    test('error response with empty message: uses fallback message', () {
      final raw = <String, dynamic>{
        'code': 500001,
        'message': '',
        'data': null,
      };

      expect(
        () => parseLucentResponse<dynamic>(
          rawData: raw,
          decoder: (json) => json,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', '500001')
              .having((e) => e.message, 'message', 'Request failed'),
        ),
      );
    });

    test('paginated response: parses meta.pagination', () {
      final raw = <String, dynamic>{
        'code': 0,
        'message': '',
        'data': <Map<String, dynamic>>[
          {'id': 1},
          {'id': 2},
        ],
        'meta': {
          'pagination': {
            'page': 1,
            'pageSize': 20,
            'total': 42,
            'totalPages': 3,
          },
        },
      };

      final result = parseLucentResponse<List<dynamic>>(
        rawData: raw,
        decoder: (json) => json as List<dynamic>,
      );

      expect(result.code, 0);
      expect(result.data, hasLength(2));
      expect(result.meta, isNotNull);
      expect(result.meta!.pagination, isNotNull);
      expect(result.meta!.pagination!.total, 42);
      expect(result.meta!.pagination!.totalPages, 3);
    });

    test('success response with missing code: defaults to error', () {
      final raw = <String, dynamic>{
        'data': 'hello',
      };

      expect(
        () => parseLucentResponse<String>(
          rawData: raw,
          decoder: (json) => json as String,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', '-1'),
        ),
      );
    });
  });
}
