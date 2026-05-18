import 'package:ecommerce_app/features/auth/logic/entity/auth_user_change.dart';
import 'package:ecommerce_app/features/auth/logic/entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn({required String email, required String password});

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({required String newPassword});

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity?> getProfile({required String userId});

  Future<void> refreshSession();

  Stream<AuthUserChange> get authStateChanges;
}
