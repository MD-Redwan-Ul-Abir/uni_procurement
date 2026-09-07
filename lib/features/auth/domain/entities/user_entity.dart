import 'package:uni_procurement/core/constants/app_enums.dart';

/// User domain entity — framework-agnostic, no serialization.
class UserEntity {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? status;
  final String? token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.status,
    this.token,
  });
}
