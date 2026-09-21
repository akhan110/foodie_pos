import 'package:flutter/foundation.dart';

/// Configuration options for initializing the singleton [Network] client.
class NetworkConfig {
  NetworkConfig({
    String? baseUrl,
    this.tokenProvider,
    this.onUnauthorized,
    Map<String, dynamic>? defaultHeaders,
    this.defaultConnectTimeout = const Duration(seconds: 30),
    this.defaultSendTimeout = const Duration(seconds: 30),
    this.defaultReceiveTimeout = const Duration(seconds: 30),
    bool? enableLogging,
  })  : baseUrl = _resolveBaseUrl(baseUrl),
        defaultHeaders = defaultHeaders ??
            const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
        enableLogging = enableLogging ?? kDebugMode;

  /// The root server URL for all API endpoints.
  final String baseUrl;

  /// Dynamic asynchronous callback to obtain the bearer token per request.
  final Future<String?> Function()? tokenProvider;

  /// Callback triggered when a 401 Unauthorized status is received (debounced).
  final Future<void> Function()? onUnauthorized;

  /// Global headers applied to every outgoing request unless overridden.
  final Map<String, dynamic> defaultHeaders;

  /// Default timeout for establishing a connection with the server.
  final Duration defaultConnectTimeout;

  /// Default timeout for sending the request payload.
  final Duration defaultSendTimeout;

  /// Default timeout for receiving the server response.
  final Duration defaultReceiveTimeout;

  /// Whether development-only logging is enabled (redacted for security).
  final bool enableLogging;

  static String _resolveBaseUrl(String? customUrl) {
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    throw StateError(
      'API_BASE_URL is not configured. Please pass a baseUrl to NetworkConfig '
      'or define --dart-define=API_BASE_URL=https://api.example.com when building/running.',
    );
  }
}
