import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../services/storage_service.dart';

/// Interceptor that attaches the bearer token to every outgoing request
/// and triggers a global force-logout on any 401 response.
class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final storage = Get.find<StorageService>();
    final token = storage.token;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Trigger global logout — AuthController listens for this.
      // Use a slight delay to avoid calling Get.find during an interceptor chain.
      Future.microtask(() {
        try {
          // The AuthController is permanent, so this is always available.
          Get.find<StorageService>().clearSession();
          // Navigate to login, preserving the current path for redirect.
          final currentPath = Get.currentRoute;
          Get.offAllNamed(
            '/login${currentPath != '/login' ? '?redirect=$currentPath' : ''}',
          );
        } catch (_) {
          // If GetX navigation isn't ready yet, silently skip.
        }
      });
    }

    handler.next(err);
  }
}
