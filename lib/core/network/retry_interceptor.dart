import 'dart:async';
import 'package:dio/dio.dart';

/// Retries idempotent GET requests on transient failures (timeout, 5xx).
/// Never retries POST/PATCH/DELETE to avoid duplicate side effects.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;
  final Duration _baseDelay;

  RetryInterceptor(
    this._dio, {
    int maxRetries = 2,
    Duration baseDelay = const Duration(seconds: 1),
  })  : _maxRetries = maxRetries,
        _baseDelay = baseDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isGet = err.requestOptions.method.toUpperCase() == 'GET';
    final isRetryable = _isRetryableError(err);

    if (!isGet || !isRetryable) {
      return handler.next(err);
    }

    final retryCount =
        (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    if (retryCount >= _maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff: 1s, 2s, 4s...
    final delay = _baseDelay * (1 << retryCount);
    await Future.delayed(delay);

    try {
      err.requestOptions.extra['_retryCount'] = retryCount + 1;
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isRetryableError(DioException err) {
    // Timeout or connection errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Server errors (5xx)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    return false;
  }
}
