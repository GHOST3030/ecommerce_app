import 'package:ecommerce_app/features/auth/logic/entity/user_entity.dart';

enum AuthUserChangeType {
  initialSession,
  passwordRecovery,
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
  userDeleted,
  mfaChallengeVerified,
}

class AuthUserChange {
  final AuthUserChangeType type;
  final UserEntity? user;

  const AuthUserChange({
    required this.type,
    this.user,
  });
}
