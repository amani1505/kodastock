class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.isVerified = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}