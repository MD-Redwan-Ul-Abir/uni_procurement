import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/core/routes/app_pages.dart';
import 'package:uni_procurement/core/routes/app_routes.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/auth/presentation/controllers/auth_controller.dart';
import 'package:uni_procurement/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:uni_procurement/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uni_procurement/features/auth/domain/usecases/login_usecase.dart';
import 'package:uni_procurement/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:uni_procurement/core/network/auth_interceptor.dart';
import 'package:uni_procurement/core/network/dio_client.dart';

class _FakeStorageService extends GetxService implements StorageService {
  String? _token;
  Map<String, dynamic>? _user;

  @override
  String? get token => _token;

  @override
  bool get hasToken => _token != null && _token!.isNotEmpty;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> removeToken() async {
    _token = null;
  }

  @override
  Map<String, dynamic>? get cachedUser => _user;

  @override
  Future<void> cacheUser(Map<String, dynamic> userJson) async {
    _user = userJson;
  }

  @override
  Future<void> clearSession() async {
    _token = null;
    _user = null;
  }

  @override
  void listenForSessionChanges(void Function() onSessionCleared) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDioClient implements DioClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Vendor 1-tap chip logs in and navigates to VendorDashboardPage', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.reset();

    final storage = _FakeStorageService();
    Get.put<StorageService>(storage);

    Get.put(AuthInterceptor(), permanent: true);

    final permission = PermissionService();
    Get.put<PermissionService>(permission);

    final db = DummyDatabaseService();
    db.users.assignAll([
      {
        'id': 1,
        'name': 'Dr. Arthur Vance',
        'email': 'admin@university.edu',
        'role': 'admin',
        'password': 'password123',
        'status': 'ACTIVE',
        'token': 'mock-admin-token',
      },
      {
        'id': 6,
        'name': 'Apex Technologies Ltd',
        'email': 'vendor@apextech.com',
        'role': 'vendor',
        'password': 'password123',
        'status': 'ACTIVE',
        'token': 'mock-vendor-token',
      }
    ]);
    db.circulars.assignAll([
      {
        'id': 'CIRC-2026-001',
        'title': 'High-Performance Computing Cluster',
        'department': 'Computer Science',
        'estimated_budget': 100000.0,
        'status': 'PUBLISHED',
        'submission_deadline': '2026-04-30',
        'bid_count': 1,
      }
    ]);
    db.bids.assignAll([
      {
        'id': 'BID-2026-001',
        'circular_id': 'CIRC-2026-001',
        'circular_title': 'High-Performance Computing Cluster',
        'vendor_id': 6,
        'vendor_name': 'Apex Technologies Ltd',
        'vendor_email': 'vendor@apextech.com',
        'quoted_amount': 95000.0,
        'submission_date': '2026-03-15',
        'status': 'SUBMITTED',
        'delivery_days': 20,
      }
    ]);
    Get.put<DummyDatabaseService>(db);

    final remoteDataSource = AuthRemoteDatasource(_FakeDioClient());
    final authRepo = AuthRepositoryImpl(remoteDataSource);
    final loginUseCase = LoginUseCase(authRepo);
    final getMeUseCase = GetMeUseCase(authRepo);

    Get.put<AuthController>(
      AuthController(loginUseCase: loginUseCase, getMeUseCase: getMeUseCase),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showcase Demo Accounts (1-Tap Login)'), findsOneWidget);

    // Tap the Vendor demo chip
    final vendorChip = find.widgetWithText(ActionChip, 'Vendor');
    expect(vendorChip, findsOneWidget);
    await tester.tap(vendorChip);
    await tester.pumpAndSettle();

    expect(permission.currentRole, equals(UserRole.vendor));
    expect(Get.currentRoute, equals(AppRoutes.vendorDashboard));
  });
}
