import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class IAuthRemoteDatasource {
  Future<UserModel?> getCurrentUser();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Stream<UserModel?> authStateChanges();
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  AuthRemoteDatasource(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        return UserModel.fromJson(response);
      } catch (_) {
        return null;
      }
    });
  }
}

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRemoteDatasource(supabase);
});
