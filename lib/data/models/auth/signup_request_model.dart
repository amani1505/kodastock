// lib/data/models/auth/signup_request_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

@JsonSerializable()
class SignupRequestModel {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  const SignupRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}