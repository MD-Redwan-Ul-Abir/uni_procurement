/// Custom exceptions thrown by data sources, caught and mapped to
/// [Failure] subclasses by repository implementations.

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException(
    this.message, {
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ServerException($statusCode: $message)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred.']);
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ValidationException(
    this.message, {
    required this.fieldErrors,
  });
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Unauthorized.']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error.']);
}
