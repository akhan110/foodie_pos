import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:foodiepos/services/network/network_config.dart';


/// Lightweight custom HttpClientAdapter for mock testing Dio requests.
class MockHttpClientAdapter implements HttpClientAdapter {
  MockHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class TestUser {
  const TestUser({required this.id, required this.name});

  final int id;
  final String name;

  factory TestUser.fromJson(Map<String, dynamic> json) => TestUser(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

void main() {
  group('Network & BaseResponseModel Unit Tests', () {
    late Network network;
    String? currentToken = 'initial_token_123';
    int unauthorizedCallCount = 0;

    setUp(() {
      unauthorizedCallCount = 0;
      currentToken = 'initial_token_123';

      network = Network.instance;
      network.init(
        config: NetworkConfig(
          baseUrl: 'https://api.foodiepos.test/v1',
          tokenProvider: () async => currentToken,
          onUnauthorized: () async {
            unauthorizedCallCount++;
          },
          enableLogging: false,
        ),
      );
    });

    test('1. Successful GET returning typed single object', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          expect(options.method, 'GET');
          expect(options.uri.toString(), 'https://api.foodiepos.test/v1/user/1');
          expect(options.headers['Authorization'], 'Bearer initial_token_123');


          final responseMap = {
            'success': true,
            'message': 'User retrieved successfully',
            'data': {'id': 1, 'name': 'Alex Khan'},
            'statusCode': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(responseMap),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final response = await network.apiRequest<TestUser>(
        requestType: ApiRequestType.get,
        endPoint: '/user/1',
        parser: (data) => TestUser.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.message, 'User retrieved successfully');
      expect(response.data, isNotNull);
      expect(response.data!.id, 1);
      expect(response.data!.name, 'Alex Khan');
    });

    test('2. Successful GET returning a typed List', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          final responseMap = {
            'success': true,
            'data': [
              {'id': 1, 'name': 'Burger Cashier'},
              {'id': 2, 'name': 'Pizza Chef'},
            ],
            'statusCode': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(responseMap),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final response = await network.apiRequest<List<TestUser>>(
        requestType: ApiRequestType.get,
        endPoint: '/users',
        parser: (data) => (data as List)
            .map((item) => TestUser.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.length, 2);
      expect(response.data![0].name, 'Burger Cashier');
      expect(response.data![1].name, 'Pizza Chef');
    });

    test('3. Successful POST with JSON body and custom headers', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          expect(options.method, 'POST');
          expect(options.headers['X-Custom-Header'], 'SpecialValue');
          expect(options.queryParameters['storeId'], '01');

          final Map<String, dynamic> body = options.data as Map<String, dynamic>;
          expect(body['name'], 'New Product');

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Created',
              'data': {'id': 99, 'name': 'New Product'},
              'statusCode': 201,
            }),
            201,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final response = await network.apiRequest<TestUser>(
        requestType: ApiRequestType.post,
        endPoint: '/products',
        requestData: {'name': 'New Product'},
        queryParameters: {'storeId': '01'},
        additionalHeaders: {'X-Custom-Header': 'SpecialValue'},
        parser: (data) => TestUser.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.data!.id, 99);
    });

    test('4. Public request without Bearer token', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          expect(options.headers.containsKey('Authorization'), isFalse);

          return ResponseBody.fromString(
            jsonEncode({'success': true, 'data': 'public_info'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final response = await network.apiRequest<String>(
        requestType: ApiRequestType.get,
        endPoint: '/public-config',
        isBearerRequired: false,
        parser: (data) => data.toString(),
      );

      expect(response.success, isTrue);
      expect(response.data, 'public_info');
    });

    test('5. 401 Unauthorized triggers onUnauthorized and debounces concurrent calls', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Session expired', 'statusCode': 401}),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      // Trigger 2 simultaneous 401 requests
      final future1 = network.apiRequest<dynamic>(
        requestType: ApiRequestType.get,
        endPoint: '/orders/1',
      );
      final future2 = network.apiRequest<dynamic>(
        requestType: ApiRequestType.get,
        endPoint: '/orders/2',
      );

      await expectLater(future1, throwsA(isA<ApiException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)));
      await expectLater(future2, throwsA(isA<ApiException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)));

      // Debounce ensure callback only ran once
      expect(unauthorizedCallCount, 1);
    });

    test('6. Connection timeout handling', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          );
        }),
      );

      try {
        await network.apiRequest<dynamic>(
          requestType: ApiRequestType.get,
          endPoint: '/slow-endpoint',
        );
        fail('Should throw ApiException');
      } on ApiException catch (e) {
        expect(e.isTimeout, isTrue);
        expect(e.type, ApiExceptionType.timeout);
      }
    });

    test('7. Malformed / non-standard response fallback parsing', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          // Non-standard response format without standard keys
          return ResponseBody.fromString(
            jsonEncode({
              'status': 'OK',
              'payload': {'id': 50, 'name': 'Direct Payload'},
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final response = await network.apiRequest<TestUser>(
        requestType: ApiRequestType.get,
        endPoint: '/custom-envelope',
        parser: (data) => TestUser.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.data!.id, 50);
      expect(response.data!.name, 'Direct Payload');
    });

    test('8. Successful PUT, PATCH, and DELETE requests', () async {
      final methodsCalled = <String>[];

      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          methodsCalled.add(options.method);
          return ResponseBody.fromString(
            jsonEncode({'success': true, 'data': {'id': 1, 'name': 'Updated'}}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      await network.apiRequest<TestUser>(
        requestType: ApiRequestType.put,
        endPoint: '/users/1',
        requestData: {'name': 'Updated'},
        parser: (d) => TestUser.fromJson(d as Map<String, dynamic>),
      );

      await network.apiRequest<TestUser>(
        requestType: ApiRequestType.patch,
        endPoint: '/users/1',
        requestData: {'name': 'Patched'},
        parser: (d) => TestUser.fromJson(d as Map<String, dynamic>),
      );

      await network.apiRequest<dynamic>(
        requestType: ApiRequestType.delete,
        endPoint: '/users/1',
      );

      expect(methodsCalled, ['PUT', 'PATCH', 'DELETE']);
    });

    test('9. Multipart FormData request', () async {
      network.setHttpClientAdapter(
        MockHttpClientAdapter((options) async {
          expect(options.method, 'POST');
          expect(options.data, isA<FormData>());

          final formData = options.data as FormData;
          expect(formData.fields.any((f) => f.key == 'title' && f.value == 'Receipt'), isTrue);

          return ResponseBody.fromString(
            jsonEncode({'success': true, 'data': 'uploaded'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }),
      );

      final formData = FormData.fromMap({
        'title': 'Receipt',
        'file': MultipartFile.fromBytes([1, 2, 3], filename: 'receipt.png'),
      });

      final response = await network.apiRequest<String>(
        requestType: ApiRequestType.post,
        endPoint: '/upload',
        requestData: formData,
        parser: (data) => data.toString(),
      );

      expect(response.success, isTrue);
      expect(response.data, 'uploaded');
    });

    test('10. Missing API_BASE_URL throws informative StateError', () {
      expect(
        () => NetworkConfig(baseUrl: ''),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('API_BASE_URL is not configured'))),
      );
    });
  });
}
