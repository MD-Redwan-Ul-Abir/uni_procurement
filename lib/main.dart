import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_enums.dart';
import 'core/network/auth_interceptor.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/dummy_database_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage.
  await GetStorage.init();

  // Register core services.
  final storage = await StorageService().init();
  Get.put(storage, permanent: true);
  final dummyDb = await DummyDatabaseService().init();
  Get.put(dummyDb, permanent: true);
  Get.put(AuthInterceptor(), permanent: true);

  final permission = PermissionService();
  // Restore existing session role on boot/refresh
  if (storage.hasToken && storage.cachedUser != null) {
    try {
      final cachedRole = storage.cachedUser!['role']?.toString();
      if (cachedRole != null) {
        permission.setRole(UserRole.fromString(cachedRole));
      }
    } catch (_) {}
  }
  Get.put(permission, permanent: true);

  // Listen for multi-tab logout.
  storage.listenForSessionChanges(() {
    final permission = Get.find<PermissionService>();
    permission.clearRole();
    if (Get.currentRoute != '/login') {
      Get.offAllNamed(AppRoutes.login);
    }
  });

  runApp(const UniProcurementApp());
}

class UniProcurementApp extends StatelessWidget {
  const UniProcurementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'University E-Procurement Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
