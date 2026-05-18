import 'package:ecommerce_app/features/auth/logic/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phone,
    super.avatarUrl,
    required super.role,
    required super.createdAt,
    required super.isEmailVerified,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    required bool isEmailVerified,
  }) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: _nullableString(json['avatar_url']),
      role: json['role'] as String? ?? 'user',
      createdAt: _parseDateTime(json['created_at']),
      isEmailVerified: isEmailVerified,
    );
  }

  factory UserModel.fromAuthUser(
    Map<String, dynamic> json, {
    String fullName = '',
    String phone = '',
    String? avatarUrl,
    String role = 'user',
  }) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: fullName,
      phone: phone,
      avatarUrl: _nullableString(avatarUrl),
      role: role,
      createdAt: _parseDateTime(json['created_at']),
      isEmailVerified: json['email_confirmed_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl ?? '',
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl ?? '',
        'role': role,
      };

  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      createdAt: entity.createdAt,
      isEmailVerified: entity.isEmailVerified,
    );
  }

  static String? _nullableString(Object? value) {
    final stringValue = value as String?;
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
