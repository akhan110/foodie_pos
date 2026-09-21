import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network_config.dart';

import 'configure_dio_stub.dart'
    if (dart.library.js_interop) 'configure_dio_web.dart';

/// A production-ready, thread-safe Singleton HTTP Client utilizing [Dio].
class Network {
  Network._();

  /// The global singleton instance of [Network].
  static final Network instance = Network._();

  /// Factory constructor returning the singleton instance.
  factory Network() => instance;

  late Dio _dio;
  NetworkConfig? _config;
  bool _isInitialized = false;
  bool _isHandlingUnauthorized = false;

  /// Whether the network layer has been initialized with a [NetworkConfig].
  bool get isInitialized => _isInitialized;

  /// Exposes the internal [Dio] instance for testing or direct customization.
  Dio get dio {
    _ensureInitialized();
    return _dio;
  }

  /// Initializes the singleton with an optional custom [NetworkConfig].
  ///
  /// If [config] is omitted, it will attempt to read from `API_BASE_URL` environment define.
  void init({NetworkConfig? config}) {
    _config = config ?? NetworkConfig();

    final baseOptions = BaseOptions(
      baseUrl: _config!.baseUrl,
      connectTimeout: _config!.defaultConnectTimeout,
      sendTimeout: _config!.defaultSendTimeout,
      receiveTimeout: _config!.defaultReceiveTimeout,
      headers: Map<String, dynamic>.from(_config!.defaultHeaders),
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    // Platform-specific configuration (Web vs Mobile/Desktop)
    configureDioPlatform(_dio);

    // Setup interceptors
    _dio.interceptors.clear();
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createUnauthorizedInterceptor());

    if (_config!.enableLogging) {
      _dio.interceptors.add(_createSafeLoggingInterceptor());
    }

    _isInitialized = true;
  }

  /// Replaces the underlying [HttpClientAdapter] for unit testing.
  @visibleForTesting
  void setHttpClientAdapter(HttpClientAdapter adapter) {
    _ensureInitialized();
    _dio.httpClientAdapter = adapter;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      init();
    }
  }

  /// Interceptor to inject bearer token dynamically per request without mutating global options.
  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final bool isBearerRequired =
            options.extra['isBearerRequired'] as bool? ?? true;

        if (isBearerRequired && _config?.tokenProvider != null) {
          try {
            final token = await _config!.tokenProvider!();
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            }
          } catch (e) {
            // If token retrieval fails, proceed without throwing in interceptor
            debugPrint('⚠️ Network: Failed to retrieve bearer token: $e');
          }
        }
        return handler.next(options);
      },
    );
  }

  /// Interceptor to handle 401 Unauthorized with debouncing.
  InterceptorsWrapper _createUnauthorizedInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            _config?.onUnauthorized != null) {
          if (!_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            try {
              await _config!.onUnauthorized!();
            } catch (e) {
              debugPrint('⚠️ Network: Error executing onUnauthorized callback: $e');
            } finally {
              // Debounce lock release
              Future.delayed(const Duration(milliseconds: 800), () {
                _isHandlingUnauthorized = false;
              });
            }
          }
        }
        return handler.next(error);
      },
    );
  }

  /// Interceptor for development-only logging with strict data redaction.
  InterceptorsWrapper _createSafeLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final sanitizedHeaders = _sanitizeMap(options.headers);
        final sanitizedData = _sanitizeData(options.data);

        debugPrint('🌐 [HTTP REQUEST] ${options.method} ${options.uri}');
        debugPrint('   Headers: $sanitizedHeaders');
        if (sanitizedData != null) {
          debugPrint('   Body: $sanitizedData');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final sanitizedData = _sanitizeData(response.data);
        debugPrint(
            '✅ [HTTP RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
        if (sanitizedData != null) {
          debugPrint('   Data: $sanitizedData');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
            '❌ [HTTP ERROR] ${error.response?.statusCode ?? 'NO_STATUS'} ${error.requestOptions.uri}');
        debugPrint('   Message: ${error.message}');
        if (error.response?.data != null) {
          debugPrint('   Error Data: ${_sanitizeData(error.response?.data)}');
        }
        return handler.next(error);
      },
    );
  }

  /// Core request dispatcher.
  Future<BaseResponseModel<T>> apiRequest<T>({
    required ApiRequestType requestType,
    required String endPoint,
    T Function(dynamic data)? parser,
    Map<String, dynamic>? queryParameters,
    dynamic requestData,
    Map<String, dynamic>? additionalHeaders,
    bool isBearerRequired = true,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    CancelToken? cancelToken,
    void Function(BaseResponseModel<T> response)? onSuccess,
    void Function(ApiException error)? onFailure,
  }) async {
    _ensureInitialized();

    final options = Options(
      method: requestType.method,
      headers: additionalHeaders,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: <String, dynamic>{
        'isBearerRequired': isBearerRequired,
      },
    );

    try {
      final response = await _dio.request<dynamic>(
        endPoint,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      BaseResponseModel<T> responseModel;
      try {
        responseModel = BaseResponseModel<T>.fromJson(
          response.data,
          parser: parser,
          statusCode: response.statusCode,
        );
      } catch (parseError, stackTrace) {
        final exception = ApiException(
          message: 'Failed to parse response: $parseError',
          statusCode: response.statusCode,
          responseData: response.data,
          type: ApiExceptionType.parsingError,
          originalException: parseError,
          stackTrace: stackTrace,
        );
        onFailure?.call(exception);
        throw exception;
      }

      onSuccess?.call(responseModel);
      return responseModel;
    } on DioException catch (dioError) {
      final exception = ApiException.fromDioException(dioError);
      onFailure?.call(exception);
      throw exception;
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;

      final exception = ApiException(
        message: e.toString(),
        type: ApiExceptionType.unknown,
        originalException: e,
        stackTrace: stackTrace,
      );
      onFailure?.call(exception);
      throw exception;
    }
  }

  // ===========================================================================
  // SECURITY SANITIZATION HELPERS
  // ===========================================================================

  static const List<String> _sensitiveKeys = [
    'authorization',
    'auth',
    'password',
    'pass',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'cookie',
    'set-cookie',
    'api_key',
    'apikey',
    'x-api-key',
    'pin',
    'cvv',
    'credit_card',
    'card_number',
  ];

  static Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    for (final entry in map.entries) {
      final keyStr = entry.key.toString();
      final keyLower = keyStr.toLowerCase();

      if (_sensitiveKeys.any((s) => keyLower.contains(s))) {
        sanitized[keyStr] = '[REDACTED]';
      } else if (entry.value is Map) {
        sanitized[keyStr] = _sanitizeMap(entry.value as Map);
      } else if (entry.value is List) {
        sanitized[keyStr] = _sanitizeList(entry.value as List);
      } else {
        sanitized[keyStr] = entry.value;
      }
    }
    return sanitized;
  }

  static List<dynamic> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) return _sanitizeMap(item);
      if (item is List) return _sanitizeList(item);
      return item;
    }).toList();
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;
    if (data is FormData) {
      return '[FormData with ${data.fields.length} fields, ${data.files.length} files]';
    }
    if (data is Map) {
      return _sanitizeMap(data);
    }
    if (data is List) {
      return _sanitizeList(data);
    }
    return data.toString();
  }
}
