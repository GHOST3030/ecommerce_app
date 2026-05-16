sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred.']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred.']);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access.']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred.']);
}

final class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed.']);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
