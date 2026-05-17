import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_model.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource(this._client);

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign in failed: no user returned');

    return _fetchProfile(user.id, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final user = response.user;
    if (user == null) throw Exception('Sign up failed: no user returned');

    final model = UserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: fullName,
      avatarUrl: null,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : DateTime.now(),
      isEmailVerified: user.emailConfirmedAt != null,
    );

    await _insertProfile(model);
    return model;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<UserModel?> getProfile({required String userId}) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(userId, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      try {
        return await _fetchProfile(
          user.id,
          isEmailVerified: user.emailConfirmedAt != null,
        );
      } catch (_) {
        return UserModel.fromSupabaseUser(
          {'id': user.id, 'email': user.email, 'created_at': user.createdAt},
        );
      }
    });
  }

  Future<UserModel> _fetchProfile(
    String userId, {
    required bool isEmailVerified,
  }) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromSupabaseProfile(
      data,
      isEmailVerified: isEmailVerified,
    );
  }

  Future<void> _insertProfile(UserModel model) async {
    await _client.from('profiles').upsert(model.toProfileInsert());
  }
}
