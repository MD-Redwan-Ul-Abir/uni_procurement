import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
