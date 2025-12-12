// lib/data/models/auth/user_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // ID can be int or String from API, so we handle both
  @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
  final String id;
  
  final String email;
  final String name;
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;
  
  // Make isVerified derived from emailVerifiedAt if not provided
  @JsonKey(name: 'is_verified', defaultValue: false)
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.emailVerifiedAt,
    this.isVerified = false,
  });

  // Handle id that can be int or String
  static String _idFromJson(dynamic id) {
    if (id == null) return '';
    return id.toString();
  }
  
  static dynamic _idToJson(String id) => id;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      isVerified: emailVerifiedAt != null || isVerified,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      isVerified: entity.isVerified,
    );
  }
}