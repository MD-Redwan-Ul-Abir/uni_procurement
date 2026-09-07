/// Failure hierarchy for use with `dartz` Either.
/// Every use case returns `Future<Either<Failure, T>>`.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure($message)';
}

/// Server returned an error response (4xx/5xx).
class ServerFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ServerFailure(
    super.message, {
    super.statusCode,
    this.errors,
  });
}

/// No internet or connection timed out.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Backend returned 422 with field-specific validation errors.
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    required this.fieldErrors,
    super.statusCode = 422,
  });

  /// Get the first error for a specific field.
  String? forField(String field) {
    final errors = fieldErrors[field];
    return errors != null && errors.isNotEmpty ? errors.first : null;
  }
}

/// Local storage read/write failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

/// User is not authorized (token expired, forced logout).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please log in again.']);
}
