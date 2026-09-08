import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_enums.dart';
import '../responsive/adaptive_scaffold.dart';
import 'storage_service.dart';

/// Centralized permission + navigation service.
/// All role checks route through here — no scattered `if (role == ...)` in widgets.
class PermissionService extends GetxService {
  final Rx<UserRole?> _currentRole = Rx<UserRole?>(null);

  UserRole? get currentRole => _currentRole.value;

  void setRole(UserRole role) {
    _currentRole.value = role;
  }

  void clearRole() {
    _currentRole.value = null;
  }

  // ── Route Access ──

  /// Map of which roles can access which route prefixes.
  /// Order matters — more specific prefixes must come before broader ones.
  static const Map<String, List<UserRole>> _routePermissions = {
    // Initiator-only routes
    '/initiator': [UserRole.initiator],
    '/circulars/create': [UserRole.initiator],

    // Vendor-only routes
    '/vendor': [UserRole.vendor],
    '/bids': [UserRole.vendor],

    // Admin routes
    '/admin': [UserRole.admin],

    // Approval routes
    '/approvals': [
      UserRole.approverDeptHead,
      UserRole.approverDean,
      UserRole.approverRegistrar,
      UserRole.initiator,
    ],

    // Finance routes
    '/finance': [UserRole.finance],

    // Work orders (Vendor fulfills, Finance oversees)
    '/work-orders': [UserRole.vendor, UserRole.finance],
  };

  /// Check if the current user can access a route.
  bool canAccess(String routeName) {
    // Public routes accessible without login
    if (routeName == '/circulars' ||
        routeName.startsWith('/circulars/') && !routeName.endsWith('/bid') && !routeName.endsWith('/create') && !routeName.endsWith('/matrix')) {
      return true;
    }

    final role = currentRole;
    if (role == null) return false;

    // Admin can access everything.
    if (role == UserRole.admin) return true;

    // Check specific route permissions.
    for (final entry in _routePermissions.entries) {
      if (routeName.startsWith(entry.key)) {
        return entry.value.contains(role);
      }
    }

    // Default: allow (unprotected route).
    return true;
  }

  // ── Navigation Items ──

  List<NavItem> get navItemsForCurrentUser {
    final role = currentRole;
    if (role == null) {
      return const [
        NavItem(
          label: 'Active Circulars',
          icon: Icons.campaign_outlined,
          route: '/circulars',
        ),
        NavItem(
          label: 'Sign In',
          icon: Icons.login_outlined,
          route: '/login',
        ),
        NavItem(
          label: 'Register as Vendor',
          icon: Icons.person_add_outlined,
          route: '/vendor/register',
        ),
      ];
    }

    switch (role) {
      case UserRole.admin:
        return const [
          NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              route: '/admin/reports'),
          NavItem(
              label: 'Users',
              icon: Icons.people_outline,
              route: '/admin/users'),
          NavItem(
              label: 'Vendor Verification',
              icon: Icons.verified_user_outlined,
              route: '/admin/vendor-verification'),
          NavItem(
              label: 'Workflow Settings',
              icon: Icons.account_tree_outlined,
              route: '/admin/workflow-settings'),
          NavItem(
              label: 'Reports',
              icon: Icons.bar_chart_outlined,
              route: '/admin/reports'),
        ];
      case UserRole.initiator:
        return const [
          NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              route: '/initiator/dashboard'),
          NavItem(
              label: 'Active Tenders',
              icon: Icons.description_outlined,
              route: '/circulars'),
          NavItem(
              label: 'Create Circular',
              icon: Icons.add_circle_outline,
              route: '/initiator/circulars/new'),
          NavItem(
              label: 'Approval Tracker',
              icon: Icons.track_changes_outlined,
              route: '/approvals'),
          NavItem(
              label: 'Completed Projects',
              icon: Icons.history_outlined,
              route: '/initiator/history'),
        ];
      case UserRole.approverDeptHead:
      case UserRole.approverDean:
      case UserRole.approverRegistrar:
        return const [
          NavItem(
              label: 'Pending Approvals',
              icon: Icons.pending_actions_outlined,
              route: '/approvals'),
          NavItem(
              label: 'Approval History',
              icon: Icons.history_outlined,
              route: '/approvals/history'),
        ];
      case UserRole.vendor:
        return const [
          NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              route: '/vendor/dashboard'),
          NavItem(
              label: 'Active Circulars',
              icon: Icons.campaign_outlined,
              route: '/circulars'),
          NavItem(
              label: 'My Bids',
              icon: Icons.gavel_outlined,
              route: '/vendor/my-bids'),
          NavItem(
              label: 'My Work Orders',
              icon: Icons.assignment_outlined,
              route: '/work-orders'),
        ];
      case UserRole.finance:
        return const [
          NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              route: '/finance'),
          NavItem(
              label: 'Invoices & Claims',
              icon: Icons.receipt_long_outlined,
              route: '/finance/invoices'),
          NavItem(
              label: 'Settled Payments',
              icon: Icons.check_circle_outline,
              route: '/finance/completed'),
          NavItem(
              label: 'Work Orders',
              icon: Icons.assignment_outlined,
              route: '/work-orders'),
        ];
    }
  }

  // ── Role Home ──

  String get homeRoute {
    switch (currentRole) {
      case UserRole.admin:
        return '/admin/reports';
      case UserRole.initiator:
        return '/initiator/dashboard';
      case UserRole.approverDeptHead:
      case UserRole.approverDean:
      case UserRole.approverRegistrar:
        return '/approvals';
      case UserRole.vendor:
        return '/vendor/dashboard';
      case UserRole.finance:
        return '/finance';
      case null:
        return '/login';
    }
  }

  // ── Logout ──

  void logout() {
    clearRole();
    Get.find<StorageService>().clearSession();
    Get.offAllNamed('/login');
  }
}

