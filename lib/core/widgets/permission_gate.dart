import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_enums.dart';
import '../services/permission_service.dart';

/// Declarative role-based widget guard.
///
/// ```dart
/// PermissionGate(
///   allowedRoles: [UserRole.finance],
///   child: ElevatedButton(...),
/// )
/// ```
class PermissionGate extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permission = Get.find<PermissionService>();
    final role = permission.currentRole;

    if (role != null && allowedRoles.contains(role)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
