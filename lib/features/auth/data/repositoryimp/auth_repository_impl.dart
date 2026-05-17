import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide UserAttributes;
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../data/datasource/app_exception.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../logic/entity/user_entity.dart';
import '../../logic/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    return _execute(() => _datasource.signIn(email: email, password: password));
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return _execute(
      () => _datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    return _execute(() => _datasource.signOut());
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    return _execute(() => _datasource.forgotPassword(email: email));
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    return _execute(() => _datasource.resetPassword(newPassword: newPassword));
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _execute(() => _datasource.getCurrentUser());
  }

  @override
  Future<UserEntity?> getProfile({required String userId}) async {
    return _execute(() => _datasource.getProfile(userId: userId));
  }

  @override
  Future<void> refreshSession() async {
    return _execute(() => _datasource.refreshSession());
  }

  @override
  Stream<UserEntity?> get authStateChanges => _datasource.authStateChanges;

  Future<T> _execute<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } on SocketException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  AppException _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return const InvalidCredentialsException();
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return const EmailAlreadyInUseException();
    }
    if (msg.contains('password should be at least')) {
      return const WeakPasswordException();
    }
    if (msg.contains('user not found')) {
      return const UserNotFoundException();
    }
    if (msg.contains('email not confirmed')) {
      return const EmailNotVerifiedException();
    }
    if (msg.contains('jwt expired') || msg.contains('session')) {
      return const SessionExpiredException();
    }

    return UnknownException(e.message);
  }
}
