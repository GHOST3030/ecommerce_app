sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Invalid email or password.');
}

final class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException()
      : super('This email is already registered.');
}

final class WeakPasswordException extends AppException {
  const WeakPasswordException()
      : super('Password must be at least 6 characters.');
}

final class NetworkException extends AppException {
  const NetworkException()
      : super('Network error. Check your connection.');
}

final class SessionExpiredException extends AppException {
  const SessionExpiredException()
      : super('Session expired. Please sign in again.');
}

final class UserNotFoundException extends AppException {
  const UserNotFoundException()
      : super('No account found with this email.');
}

final class EmailNotVerifiedException extends AppException {
  const EmailNotVerifiedException()
      : super('Please verify your email before signing in.');
}

final class UnknownException extends AppException {
  const UnknownException([String? detail])
      : super(detail ?? 'An unexpected error occurred.');
}
