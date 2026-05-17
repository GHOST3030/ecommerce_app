import '../../logic/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.avatarUrl,
    required super.createdAt,
    required super.isEmailVerified,
  });

  factory UserModel.fromSupabaseProfile(
    Map<String, dynamic> profile, {
    required bool isEmailVerified,
  }) {
    return UserModel(
      id: profile['id'] as String,
      email: profile['email'] as String,
      fullName: profile['full_name'] as String? ?? '',
      avatarUrl: profile['avatar_url'] as String?,
      createdAt: DateTime.parse(profile['created_at'] as String),
      isEmailVerified: isEmailVerified,
    );
  }

  factory UserModel.fromSupabaseUser(
    Map<String, dynamic> user, {
    String fullName = '',
  }) {
    return UserModel(
      id: user['id'] as String,
      email: user['email'] as String? ?? '',
      fullName: fullName,
      avatarUrl: null,
      createdAt: DateTime.tryParse(user['created_at'] as String? ?? '') ??
          DateTime.now(),
      isEmailVerified: user['email_confirmed_at'] != null,
    );
  }

  Map<String, dynamic> toProfileInsert() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      isEmailVerified: entity.isEmailVerified,
    );
  }
}
