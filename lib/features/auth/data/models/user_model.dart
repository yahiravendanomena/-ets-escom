import '../../domain/entities/user.dart';

/// Modelo de datos para User.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
    };
  }
}