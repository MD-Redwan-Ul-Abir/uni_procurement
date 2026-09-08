import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

/// Auth controller — manages login, session check, and force logout.
class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final GetMeUseCase _getMeUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required GetMeUseCase getMeUseCase,
  })  : _loginUseCase = loginUseCase,
        _getMeUseCase = getMeUseCase;

  // ── Form state ──
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ── Reactive state ──
  final isLoading = false.obs;
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final loginError = RxnString();
  final fieldErrors = <String, String>{}.obs;

  // ── Login ──
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    loginError.value = null;
    fieldErrors.clear();

    final result = await _loginUseCase(
      emailController.text.trim(),
      passwordController.text,
    );

    result.fold(
      (failure) {
        isLoading.value = false;
        if (failure is ValidationFailure) {
          failure.fieldErrors.forEach((key, value) {
            fieldErrors[key] = value.first;
          });
        } else if (failure.statusCode == 401) {
          loginError.value = failure.message;
        } else {
          AppToast.error(
            title: 'Error',
            description: failure.message,
          );
        }
      },
      (user) async {
        isLoading.value = false;
        await _onLoginSuccess(user);
      },
    );
  }

  // ── 1-Tap Showcase Login ──
  Future<void> quickLogin(String email, String password) async {
    emailController.text = email;
    passwordController.text = password;
    loginError.value = null;
    fieldErrors.clear();
    isLoading.value = true;

    final result = await _loginUseCase(email.trim(), password);
    result.fold(
      (failure) {
        isLoading.value = false;
        if (failure.statusCode == 401) {
          loginError.value = failure.message;
        } else {
          AppToast.error(
            title: 'Login Error',
            description: failure.message,
          );
        }
      },
      (user) async {
        isLoading.value = false;
        await _onLoginSuccess(user, forceHome: true);
      },
    );
  }

  Future<void> _onLoginSuccess(UserEntity user, {bool forceHome = false}) async {
    currentUser.value = user;

    // Persist token.
    final storage = Get.find<StorageService>();
    if (user.token != null) {
      await storage.saveToken(user.token!);
    }

    // Cache user data.
    if (user is UserModel) {
      await storage.cacheUser(user.toJson());
    }

    // Set role in permission service.
    final permission = Get.find<PermissionService>();
    permission.setRole(user.role);

    // Check for vendor pending status.
    if (user.role == UserRole.vendor && user.status == 'PENDING') {
      Get.offAllNamed('/pending-approval');
      return;
    }

    // Redirect: honor ?redirect= param unless forceHome is requested.
    final redirect = forceHome ? null : Get.parameters['redirect'];
    if (redirect != null && redirect.isNotEmpty && permission.canAccess(redirect)) {
      Get.offAllNamed(redirect);
    } else {
      Get.offAllNamed(permission.homeRoute);
    }
  }

  // ── Session Check ──
  Future<void> checkSession() async {
    final storage = Get.find<StorageService>();
    if (!storage.hasToken) return;

    isLoading.value = true;
    final result = await _getMeUseCase();

    result.fold(
      (failure) {
        isLoading.value = false;
        storage.clearSession();
      },
      (user) {
        isLoading.value = false;
        _onLoginSuccess(user);
      },
    );
  }

  // ── Forgot Password ──
  final forgotPasswordEmail = TextEditingController();
  final forgotPasswordLoading = false.obs;
  final forgotPasswordSent = false.obs;

  // ── Cleanup ──
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotPasswordEmail.dispose();
    super.onClose();
  }
}
