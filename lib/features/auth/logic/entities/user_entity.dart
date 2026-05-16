class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final String role;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}