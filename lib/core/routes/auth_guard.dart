import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_enums.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

/// Auth guard middleware that protects all authenticated routes.
/// Checks:
/// 1. Valid session (token exists).
/// 2. Role-based route access via [PermissionService].
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    final permission = Get.find<PermissionService>();

    // Not logged in → redirect to login with redirect param.
    if (!storage.hasToken || permission.currentRole == null) {
      final redirectParam =
          route != null && route != '/login' ? '?redirect=$route' : '';
      return RouteSettings(name: '/login$redirectParam');
    }

    // Logged in but no access to this route → redirect to role's home.
    if (route != null && !permission.canAccess(route)) {
      return RouteSettings(name: permission.homeRoute);
    }

    return null; // Allow navigation.
  }
}

/// Role-based guard — restricts routes to specific [UserRole]s.
/// Runs at priority 2 (after [AuthGuard] at priority 1).
/// Admin always bypasses role checks.
class RoleGuard extends GetMiddleware {
  final List<UserRole> allowedRoles;

  RoleGuard(this.allowedRoles);

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final permission = Get.find<PermissionService>();
    final role = permission.currentRole;

    // Not logged in — handled by AuthGuard, but guard defensively.
    if (role == null) return const RouteSettings(name: '/login');

    // Admin bypasses all role restrictions.
    if (role == UserRole.admin) return null;

    // Check if the current role is in the allowed list.
    if (!allowedRoles.contains(role)) {
      return RouteSettings(name: permission.homeRoute);
    }

    return null; // Allow navigation.
  }
}

/// Middleware for auth pages (login, register) — if already logged in,
/// redirect to the role's home.
class GuestGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    final permission = Get.find<PermissionService>();

    if (storage.hasToken && permission.currentRole != null) {
      return RouteSettings(name: permission.homeRoute);
    }

    return null;
  }
}
