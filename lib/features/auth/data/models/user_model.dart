class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}