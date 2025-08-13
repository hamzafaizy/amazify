// lib/network/http_client.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Implement this however you store tokens (SecureStorage, Hive, etc.).
abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> saveToken(String? token);
}

/// Simple wrapper for successful responses.
class ApiResponse<T> {
  final T data;
  final int statusCode;
  final Headers headers;

  ApiResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
  });
}

/// Consistent error model thrown by HttpClient.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class HttpClient {
  final Dio _dio;
  final String baseUrl;
  final TokenStorage tokenStorage;

  /// Config
  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;
  final int maxRetries;
  final Duration initialBackoff;
  final bool enableLogging;

  /// Singleton helper (optional): call `HttpClient.create(...)` once and keep a reference.
  HttpClient._internal({
    required this.baseUrl,
    required this.tokenStorage,
    this.connectTimeout = const Duration(seconds: 10),
    this.sendTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
    this.maxRetries = 2,
    this.initialBackoff = const Duration(milliseconds: 400),
    this.enableLogging = false,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           sendTimeout: sendTimeout,
           receiveTimeout: receiveTimeout,
           contentType: Headers.jsonContentType,
           responseType: ResponseType.json,
           validateStatus: (code) => code != null && code >= 200 && code < 400,
         ),
       ) {
    _setupInterceptors();
  }

  /// Factory for convenience.
  factory HttpClient.create({
    required String baseUrl,
    required TokenStorage tokenStorage,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration sendTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
    int maxRetries = 2,
    Duration initialBackoff = const Duration(milliseconds: 400),
    bool enableLogging = false,
  }) {
    return HttpClient._internal(
      baseUrl: baseUrl,
      tokenStorage: tokenStorage,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      maxRetries: maxRetries,
      initialBackoff: initialBackoff,
      enableLogging: enableLogging,
    );
  }

  void _setupInterceptors() {
    // Authorization + default headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (err, handler) async {
          // If unauthorized and you support refresh-tokens, you could plug that logic here.
          handler.next(err);
        },
      ),
    );

    // Retry with backoff for transient errors
    _dio.interceptors.add(
      _RetryInterceptor(
        dio: _dio,
        maxRetries: maxRetries,
        initialBackoff: initialBackoff,
      ),
    );

    // Optional logging
    if (enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => print(obj), // ignore: avoid_print
        ),
      );
    }
  }

  // ─────────── Public HTTP methods ───────────

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final res = await _dio.get<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>(
        data: res.data as T,
        statusCode: res.statusCode ?? 0,
        headers: res.headers,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final res = await _dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>(
        data: res.data as T,
        statusCode: res.statusCode ?? 0,
        headers: res.headers,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.put<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>(
        data: res.data as T,
        statusCode: res.statusCode ?? 0,
        headers: res.headers,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>(
        data: res.data as T,
        statusCode: res.statusCode ?? 0,
        headers: res.headers,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  /// Multipart file upload.
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required Map<String, dynamic> fields,
    required List<MultipartFile> files,
    String filesFieldName = 'files',
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final form = FormData.fromMap({...fields, filesFieldName: files});

    try {
      final res = await _dio.post<T>(
        path,
        data: form,
        queryParameters: query,
        options: (options ?? Options()).copyWith(
          contentType: 'multipart/form-data',
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse<T>(
        data: res.data as T,
        statusCode: res.statusCode ?? 0,
        headers: res.headers,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  /// File download to a path.
  Future<void> download(
    String url,
    String savePath, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _throwApiException(e);
    }
  }

  // ─────────── Auth helpers ───────────

  Future<void> setBearerToken(String? token) async {
    await tokenStorage.saveToken(token);
  }

  // ─────────── Internal helpers ───────────

  Never _throwApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String message;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'Network error. Please check your connection and try again.';
    } else if (status != null) {
      // Try to extract server error message
      message =
          _extractServerMessage(data) ??
          'Request failed with status code $status';
    } else if (e.error is SocketException) {
      message = 'No internet connection.';
    } else {
      message = e.message ?? 'Unexpected error occurred.';
    }

    throw ApiException(message, statusCode: status, details: data);
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Common API error shapes
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      if (data['errors'] is List && data['errors'].isNotEmpty) {
        final first = data['errors'].first;
        if (first is String) return first;
        if (first is Map && first['message'] is String) return first['message'];
      }
    }
    return null;
  }
}

/// Interceptor that retries idempotent requests (GET, some network errors)
/// with exponential backoff. POST is retried only on connection-level failures.
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialBackoff;

  _RetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.initialBackoff,
  });

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Only retry if we have retries left & it's a retryable error.
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final method = requestOptions.method.toUpperCase();
    if (!_isIdempotent(method) && !_isConnectionIssue(err)) {
      // Avoid retrying non-idempotent calls except for pure connection issues.
      return handler.next(err);
    }

    // Compute attempt number
    final currentRetries = (requestOptions.extra['retries'] as int?) ?? 0;
    if (currentRetries >= maxRetries) {
      return handler.next(err);
    }

    // Backoff
    final backoff = initialBackoff * (1 << currentRetries);
    await Future.delayed(backoff);

    // Bump retry count
    final newOptions = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      extra: {...requestOptions.extra, 'retries': currentRetries + 1},
    );

    try {
      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: newOptions,
        cancelToken: requestOptions.cancelToken,
        onReceiveProgress: requestOptions.onReceiveProgress,
        onSendProgress: requestOptions.onSendProgress,
      );
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException e) {
    if (_isConnectionIssue(e)) return true;

    final status = e.response?.statusCode ?? 0;
    // Retry on 429, 503, 502, 504 etc.
    const retryable = {429, 502, 503, 504};
    return retryable.contains(status);
  }

  bool _isConnectionIssue(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError ||
      e.error is SocketException;

  bool _isIdempotent(String method) =>
      const {'GET', 'HEAD', 'OPTIONS'}.contains(method);
}
