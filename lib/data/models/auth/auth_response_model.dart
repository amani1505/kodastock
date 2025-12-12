// lib/data/models/auth/auth_response_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  // Make success optional with default value
  @JsonKey(defaultValue: true)
  final bool success;
  
  final String? message;
  
  // API returns 'token' not 'access_token'
  @JsonKey(name: 'token')
  final String? accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  @JsonKey(name: 'token_type', defaultValue: 'Bearer')
  final String tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  
  final UserModel? user;

  const AuthResponseModel({
    this.success = true,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
  
  // Helper to check if login was successful
  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
}