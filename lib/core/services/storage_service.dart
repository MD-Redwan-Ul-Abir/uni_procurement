import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

/// Web-safe storage service wrapping [GetStorage].
/// Handles token persistence and multi-tab session consistency
/// via browser storage events.
class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    await _box.initStorage;
    return this;
  }

  // ── Token ──

  String? get token => _box.read<String>(AppConstants.tokenKey);

  Future<void> saveToken(String token) async {
    await _box.write(AppConstants.tokenKey, token);
  }

  Future<void> removeToken() async {
    await _box.remove(AppConstants.tokenKey);
  }

  bool get hasToken => token != null && token!.isNotEmpty;

  // ── Cached User ──

  Map<String, dynamic>? get cachedUser {
    final raw = _box.read(AppConstants.userKey);
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> cacheUser(Map<String, dynamic> userJson) async {
    await _box.write(AppConstants.userKey, jsonEncode(userJson));
  }

  // ── Session ──

  Future<void> clearSession() async {
    await _box.remove(AppConstants.tokenKey);
    await _box.remove(AppConstants.userKey);
  }

  /// Listen for storage changes from other tabs (multi-tab logout).
  void listenForSessionChanges(void Function() onSessionCleared) {
    _box.listenKey(AppConstants.tokenKey, (value) {
      if (value == null || (value is String && value.isEmpty)) {
        onSessionCleared();
      }
    });
  }
}
