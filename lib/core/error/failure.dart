
// ignore: always_use_package_imports
import 'app_exception.dart';

sealed class Failure {
  const Failure(this.message);
  final String message;

  factory Failure.fromException(AppException exception) {
    return switch (exception) {
      NetworkException()      => NetworkFailure(exception.message),
      AuthException()         => AuthFailure(exception.message),
      ServerException()       => ServerFailure(exception.message),
      UnauthorizedException() => AuthFailure(exception.message),
      NotFoundException()     => NotFoundFailure(exception.message),
      CacheException()        => CacheFailure(exception.message),
      ValidationException()   => ValidationFailure(exception.message),
      UnknownException()      => UnknownFailure(exception.message),
    };
  }
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
