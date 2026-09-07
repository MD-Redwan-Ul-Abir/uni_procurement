import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/features/auth/domain/entities/user_entity.dart';

/// Data model extending [UserEntity] with JSON serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.department,
    super.status,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      department: json['department'] as String?,
      status: json['status'] as String?,
      token: token ?? json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toApiString(),
      'department': department,
      'status': status,
    };
  }
}
