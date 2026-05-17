import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ecommerce_app/features/auth/data/mappers/user_mapper.dart';
import 'package:ecommerce_app/features/auth/logic/contracts/auth_repository.dart';
import 'package:ecommerce_app/features/auth/logic/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._datasource);

  final IAuthRemoteDatasource _datasource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final model = await _datasource.getCurrentUser();
      return model != null ? UserMapper.toEntity(model) : null;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _datasource.signIn(email: email, password: password);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _datasource.authStateChanges().map(
          (model) => model != null ? UserMapper.toEntity(model) : null,
        );
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});