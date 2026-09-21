/// Generic API response model representing a standardized response envelope.
///
/// Supports standard envelopes:
/// ```json
/// {
///   "success": true,
///   "message": "Request successful",
///   "data": { ... },
///   "statusCode": 200
/// }
/// ```
/// As well as alternative response envelopes (e.g. `status`, `msg`, `result`, `payload`)
/// or direct raw data responses.
class BaseResponseModel<T> {
  const BaseResponseModel({
    required this.success,
    this.message = '',
    this.data,
    this.statusCode,
    this.rawData,
  });

  /// Indicates if the request was successful according to business logic or HTTP status code.
  final bool success;

  /// Optional server message describing the outcome.
  final String message;

  /// Strongly typed parsed payload.
  final T? data;

  /// HTTP status code associated with the response.
  final int? statusCode;

  /// Raw untouched response data.
  final dynamic rawData;

  /// Factory constructor to parse response payload defensively.
  factory BaseResponseModel.fromJson(
    dynamic json, {
    T Function(dynamic data)? parser,
    int? statusCode,
  }) {
    if (json == null) {
      return BaseResponseModel<T>(
        success: (statusCode != null && statusCode >= 200 && statusCode < 300),
        message: '',
        data: null,
        statusCode: statusCode,
        rawData: null,
      );
    }

    // When the response is a standard Map envelope
    if (json is Map<String, dynamic>) {
      final bool isSuccess = _extractSuccess(json, statusCode);
      final String message = _extractMessage(json);
      final dynamic rawPayload = _extractPayload(json);

      T? parsedData;
      if (rawPayload != null && parser != null) {
        parsedData = parser(rawPayload);
      } else if (rawPayload is T) {
        parsedData = rawPayload;
      } else if (rawPayload == null && parser != null) {
        parsedData = parser(json);
      }

      return BaseResponseModel<T>(
        success: isSuccess,
        message: message,
        data: parsedData,
        statusCode: (json['statusCode'] as num?)?.toInt() ?? statusCode,
        rawData: json,
      );
    }

    // When the response is a direct List or primitive type without an envelope
    T? parsedData;
    if (parser != null) {
      parsedData = parser(json);
    } else if (json is T) {
      parsedData = json;
    }

    final bool isSuccess =
        (statusCode != null && statusCode >= 200 && statusCode < 300);

    return BaseResponseModel<T>(
      success: isSuccess,
      message: '',
      data: parsedData,
      statusCode: statusCode,
      rawData: json,
    );
  }

  static bool _extractSuccess(Map<String, dynamic> json, int? statusCode) {
    if (json.containsKey('success') && json['success'] is bool) {
      return json['success'] as bool;
    }
    if (json.containsKey('status')) {
      final dynamic status = json['status'];
      if (status is bool) return status;
      if (status is String) {
        return status.toLowerCase() == 'success' || status.toLowerCase() == 'ok';
      }
      if (status is num) return status == 200 || status == 1;
    }
    if (statusCode != null) {
      return statusCode >= 200 && statusCode < 300;
    }
    return true;
  }

  static String _extractMessage(Map<String, dynamic> json) {
    if (json.containsKey('message') && json['message'] != null) {
      return json['message'].toString();
    }
    if (json.containsKey('msg') && json['msg'] != null) {
      return json['msg'].toString();
    }
    if (json.containsKey('error') && json['error'] is String) {
      return json['error'] as String;
    }
    if (json.containsKey('detail') && json['detail'] != null) {
      return json['detail'].toString();
    }
    return '';
  }

  static dynamic _extractPayload(Map<String, dynamic> json) {
    if (json.containsKey('data')) return json['data'];
    if (json.containsKey('result')) return json['result'];
    if (json.containsKey('payload')) return json['payload'];
    if (json.containsKey('items')) return json['items'];
    if (json.containsKey('body')) return json['body'];
    return json;
  }
}
