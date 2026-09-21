import 'package:dio/dio.dart';

/// Categorized types of API exceptions.
enum ApiExceptionType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  notAcceptable,
  validationError,
  tooManyRequests,
  serverError,
  serviceUnavailable,
  timeout,
  connectionError,
  cancelled,
  badCertificate,
  parsingError,
  unknown,
}

/// A strongly typed exception class representing any API, network, or parsing failure.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.responseData,
    this.type = ApiExceptionType.unknown,
    this.originalException,
    this.stackTrace,
  });

  /// User-friendly or server-returned failure message.
  final String message;

  /// HTTP status code (if available from server response).
  final int? statusCode;

  /// Raw response data received from the backend (if any).
  final dynamic responseData;

  /// Categorized failure type.
  final ApiExceptionType type;

  /// Underlying exception or error (e.g. [DioException], [FormatException]).
  final Object? originalException;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  /// Convenience getters for common status checks.
  bool get isUnauthorized =>
      statusCode == 401 || type == ApiExceptionType.unauthorized;
  bool get isForbidden => statusCode == 403 || type == ApiExceptionType.forbidden;
  bool get isNotFound => statusCode == 404 || type == ApiExceptionType.notFound;
  bool get isValidationError =>
      statusCode == 422 ||
      statusCode == 400 ||
      type == ApiExceptionType.validationError;
  bool get isTimeout => type == ApiExceptionType.timeout;
  bool get isConnectionError => type == ApiExceptionType.connectionError;
  bool get isServerError =>
      (statusCode != null && statusCode! >= 500) ||
      type == ApiExceptionType.serverError ||
      type == ApiExceptionType.serviceUnavailable;

  /// Converts a [DioException] into a domain-level [ApiException].
  factory ApiException.fromDioException(DioException dioException) {
    final response = dioException.response;
    final statusCode = response?.statusCode;
    final responseData = response?.data;

    String message = _extractServerMessage(responseData) ??
        dioException.message ??
        '';

    ApiExceptionType type;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        type = ApiExceptionType.timeout;
        if (message.isEmpty) {
          message = 'The connection timed out. Please check your internet connection and try again.';
        }
        break;

      case DioExceptionType.connectionError:
        type = ApiExceptionType.connectionError;
        if (message.isEmpty) {
          message = 'No internet connection or server is unreachable.';
        }
        break;

      case DioExceptionType.cancel:
        type = ApiExceptionType.cancelled;
        if (message.isEmpty) {
          message = 'Request was cancelled.';
        }
        break;

      case DioExceptionType.badCertificate:
        type = ApiExceptionType.badCertificate;
        if (message.isEmpty) {
          message = 'SSL/TLS certificate verification failed.';
        }
        break;

      case DioExceptionType.badResponse:
        type = _mapStatusCodeToType(statusCode);
        if (message.isEmpty) {
          message = _defaultMessageForStatusCode(statusCode);
        }
        break;

      case DioExceptionType.unknown:
      default:
        type = ApiExceptionType.unknown;
        if (message.isEmpty) {
          message = 'An unexpected error occurred. Please try again.';
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      responseData: responseData,
      type: type,
      originalException: dioException,
      stackTrace: dioException.stackTrace,
    );
  }

  /// Maps HTTP status code to [ApiExceptionType].
  static ApiExceptionType _mapStatusCodeToType(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ApiExceptionType.badRequest;
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
      case 406:
        return ApiExceptionType.notAcceptable;
      case 422:
        return ApiExceptionType.validationError;
      case 429:
        return ApiExceptionType.tooManyRequests;
      case 500:
      case 502:
        return ApiExceptionType.serverError;
      case 503:
      case 504:
        return ApiExceptionType.serviceUnavailable;
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiExceptionType.serverError;
        }
        return ApiExceptionType.unknown;
    }
  }

  /// Returns standard fallback messages for status codes.
  static String _defaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please verify your inputs.';
      case 401:
        return 'Authentication expired or invalid. Please login again.';
      case 403:
        return 'Access denied. You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 406:
        return 'Request not acceptable.';
      case 422:
        return 'Validation error. Please check submitted data.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Request failed with status code $statusCode.';
    }
  }

  /// Defensively extracts error description from backend response payloads.
  static String? _extractServerMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data.trim();

    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['msg'] != null && data['msg'].toString().isNotEmpty) {
        return data['msg'].toString();
      }
      if (data['error'] != null) {
        final error = data['error'];
        if (error is String && error.isNotEmpty) return error;
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
      }
      if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        if (errors is Map && errors.isNotEmpty) {
          final firstVal = errors.values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          return firstVal.toString();
        }
      }
    }
    return null;
  }

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, type: $type, message: $message)';
}
