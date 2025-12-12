// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: UserModel._idFromJson(json['id']),
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': UserModel._idToJson(instance.id),
      'email': instance.email,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
      'is_verified': instance.isVerified,
    };
