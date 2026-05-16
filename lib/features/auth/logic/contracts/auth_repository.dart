import 'package:ecommerce_app/features/auth/logic/entities/user_entity.dart';

abstract interface class IAuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Stream<UserEntity?> authStateChanges();
}
