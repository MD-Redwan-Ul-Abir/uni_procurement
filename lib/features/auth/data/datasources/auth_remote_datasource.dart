import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

/// Remote data source for authentication API calls, backed by DummyDatabaseService for showcasing.
class AuthRemoteDatasource {
  final DioClient _client;

  AuthRemoteDatasource(this._client);

  Future<UserModel> login(String email, String password) async {
    if (Get.isRegistered<DummyDatabaseService>()) {
      final dummyDb = Get.find<DummyDatabaseService>();
      final user = dummyDb.authenticate(email, password);
      if (user != null) {
        return UserModel.fromJson(
          user,
          token: user['token'] as String? ?? 'mock-jwt-token-${user['id']}',
        );
      }
    }

    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(
        data['user'] as Map<String, dynamic>,
        token: data['token'] as String?,
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> registerVendor({
    required String companyName,
    required String address,
    required String contactPerson,
    required String phone,
    required String tradeLicenseNumber,
    required dynamic tradeLicenseFile,
    required String taxId,
    required dynamic taxIdFile,
    required String email,
    required String password,
  }) async {
    if (Get.isRegistered<DummyDatabaseService>()) {
      final dummyDb = Get.find<DummyDatabaseService>();
      final tlName = tradeLicenseFile is String ? tradeLicenseFile.split('/').last.split('\\').last : 'TradeLicense.pdf';
      final tinName = taxIdFile is String ? taxIdFile.split('/').last.split('\\').last : 'TaxCert.pdf';
      dummyDb.vendorVerifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch % 10000,
        'company_name': companyName,
        'email': email,
        'contact_person': contactPerson,
        'phone': phone,
        'address': address,
        'trade_license_number': tradeLicenseNumber,
        'trade_license_file': tlName,
        'tax_id': taxId,
        'tax_id_file': tinName,
        'registration_date': DateTime.now().toString().split(' ').first,
        'status': 'PENDING',
        'notes': 'Online registration submitted via vendor sign up portal.'
      });
      return;
    }

    try {
      final formData = FormData.fromMap({
        'company_name': companyName,
        'address': address,
        'contact_person': contactPerson,
        'phone': phone,
        'trade_license_number': tradeLicenseNumber,
        'trade_license_file': tradeLicenseFile is String
            ? await MultipartFile.fromFile(tradeLicenseFile)
            : tradeLicenseFile,
        'tax_id': taxId,
        'tax_id_file': taxIdFile is String
            ? await MultipartFile.fromFile(taxIdFile)
            : taxIdFile,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      await _client.post(
        ApiEndpoints.vendorRegister,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    if (Get.isRegistered<DummyDatabaseService>()) {
      if (Get.isRegistered<StorageService>()) {
        final cached = Get.find<StorageService>().cachedUser;
        if (cached != null) {
          return UserModel.fromJson(cached);
        }
      }
      final dummyDb = Get.find<DummyDatabaseService>();
      if (dummyDb.users.isNotEmpty) {
        return UserModel.fromJson(dummyDb.users.first);
      }
    }

    try {
      final response = await _client.get(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>? ?? data;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> resetPassword(
      String token, String password, String passwordConfirmation) async {
    try {
      await _client.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      throw const UnauthorizedException();
    }

    if (statusCode == 422 && data is Map<String, dynamic>) {
      final errors = <String, List<String>>{};
      final rawErrors = data['errors'] as Map<String, dynamic>?;
      rawErrors?.forEach((key, value) {
        if (value is List) {
          errors[key] = value.cast<String>();
        }
      });
      throw ValidationException(
        data['message'] as String? ?? 'Validation failed',
        fieldErrors: errors,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkException();
    }

    final message =
        (data is Map<String, dynamic> ? data['message'] as String? : null) ??
            'Something went wrong';
    throw ServerException(message, statusCode: statusCode);
  }
}
