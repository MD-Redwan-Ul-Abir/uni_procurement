import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_colors.dart';

/// Centralized notification service leveraging Toastification 3.2.0.
class AppToast {
  AppToast._();

  /// Show a success toast notification
  static ToastificationItem? success({
    required String title,
    String? description,
    BuildContext? context,
    Duration autoCloseDuration = const Duration(seconds: 4),
    AlignmentGeometry alignment = Alignment.topRight,
  }) {
    return show(
      title: title,
      description: description,
      type: ToastificationType.success,
      primaryColor: AppColors.success,
      context: context,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  /// Show an error toast notification
  static ToastificationItem? error({
    required String title,
    String? description,
    BuildContext? context,
    Duration autoCloseDuration = const Duration(seconds: 5),
    AlignmentGeometry alignment = Alignment.topRight,
  }) {
    return show(
      title: title,
      description: description,
      type: ToastificationType.error,
      primaryColor: AppColors.error,
      context: context,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  /// Show an info toast notification
  static ToastificationItem? info({
    required String title,
    String? description,
    BuildContext? context,
    Duration autoCloseDuration = const Duration(seconds: 4),
    AlignmentGeometry alignment = Alignment.topRight,
  }) {
    return show(
      title: title,
      description: description,
      type: ToastificationType.info,
      primaryColor: AppColors.primary,
      context: context,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  /// Show a warning toast notification
  static ToastificationItem? warning({
    required String title,
    String? description,
    BuildContext? context,
    Duration autoCloseDuration = const Duration(seconds: 4),
    AlignmentGeometry alignment = Alignment.topRight,
  }) {
    return show(
      title: title,
      description: description,
      type: ToastificationType.warning,
      primaryColor: AppColors.warning,
      context: context,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  /// Show a customized toast notification
  static ToastificationItem? show({
    required String title,
    String? description,
    ToastificationType type = ToastificationType.info,
    ToastificationStyle style = ToastificationStyle.flat,
    Color? primaryColor,
    BuildContext? context,
    Duration autoCloseDuration = const Duration(seconds: 4),
    AlignmentGeometry alignment = Alignment.topRight,
    bool showProgressBar = true,
  }) {
    final targetContext = context ?? Get.context;
    if (targetContext == null) return null;
    return toastification.show(
      context: targetContext,
      type: type,
      style: style,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      alignment: alignment,
      autoCloseDuration: autoCloseDuration,
      primaryColor: primaryColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 16,
          offset: Offset(0, 4),
          spreadRadius: 0,
        )
      ],
      showProgressBar: showProgressBar,
      dragToClose: true,
      pauseOnHover: true,
    );
  }
}
