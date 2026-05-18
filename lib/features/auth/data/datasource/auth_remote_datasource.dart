import 'package:ecommerce_app/core/config/app_config.dart';
import 'package:ecommerce_app/features/auth/data/model/user_model.dart';
import 'package:ecommerce_app/features/auth/logic/entity/auth_user_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    return _fetchUser(user.id, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: AppConfig.emailVerificationRedirectUrl,
      data: {'full_name': fullName},
    );

    final user = response.user;
    if (user == null) throw Exception('Sign up failed: no user returned');

    final model = UserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: fullName,
      phone: '',
      avatarUrl: null,
      role: 'user',
      createdAt: DateTime.parse(user.createdAt),
      isEmailVerified: user.emailConfirmedAt != null,
    );

    return model;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConfig.passwordResetRedirectUrl,
    );
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchUser(user.id, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<UserModel?> getProfile({required String userId}) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchUser(userId, isEmailVerified: user.emailConfirmedAt != null);
  }

  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }

  Stream<AuthUserChange> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final type = _mapAuthChangeEvent(data.event);
      final user = data.session?.user;
      if (user == null) return AuthUserChange(type: type);

      try {
        final model = await _fetchUser(
          user.id,
          isEmailVerified: user.emailConfirmedAt != null,
        );
        return AuthUserChange(type: type, user: model);
      } catch (_) {
        return AuthUserChange(
          type: type,
          user: UserModel.fromAuthUser(
            {
              'id': user.id,
              'email': user.email,
              'created_at': user.createdAt,
              'email_confirmed_at': user.emailConfirmedAt,
            },
          ),
        );
      }
    });
  }

  Future<UserModel> _fetchUser(
    String userId, {
    required bool isEmailVerified,
  }) async {
    final data = await _client.from('users').select().eq('id', userId).single();

    return UserModel.fromJson(
      data,
      isEmailVerified: isEmailVerified,
    );
  }

  AuthUserChangeType _mapAuthChangeEvent(AuthChangeEvent event) {
    switch (event) {
      case AuthChangeEvent.initialSession:
        return AuthUserChangeType.initialSession;
      case AuthChangeEvent.passwordRecovery:
        return AuthUserChangeType.passwordRecovery;
      case AuthChangeEvent.signedIn:
        return AuthUserChangeType.signedIn;
      case AuthChangeEvent.signedOut:
        return AuthUserChangeType.signedOut;
      case AuthChangeEvent.tokenRefreshed:
        return AuthUserChangeType.tokenRefreshed;
      case AuthChangeEvent.userUpdated:
        return AuthUserChangeType.userUpdated;
      // ignore: deprecated_member_use
      case AuthChangeEvent.userDeleted:
        return AuthUserChangeType.userDeleted;
      case AuthChangeEvent.mfaChallengeVerified:
        return AuthUserChangeType.mfaChallengeVerified;
    }
  }
}
