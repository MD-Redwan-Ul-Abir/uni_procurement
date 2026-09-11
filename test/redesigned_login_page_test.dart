import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/network/auth_interceptor.dart';
import 'package:uni_procurement/core/network/dio_client.dart';
import 'package:uni_procurement/core/routes/app_pages.dart';
import 'package:uni_procurement/core/routes/app_routes.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:uni_procurement/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uni_procurement/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:uni_procurement/features/auth/domain/usecases/login_usecase.dart';
import 'package:uni_procurement/features/auth/presentation/controllers/auth_controller.dart';

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

  setUp(() {
    Get.reset();
    final storage = _FakeStorageService();
    Get.put<StorageService>(storage);
    Get.put(AuthInterceptor(), permanent: true);
    final permission = PermissionService();
    Get.put<PermissionService>(permission);

    final db = DummyDatabaseService();
    db.circulars.assignAll([
      {
        'id': 'CIRC-2026-001',
        'title': 'High-Performance Computing Cluster',
        'department': 'Computer Science & Engineering',
        'category': 'IT & Lab Equipment',
        'estimated_budget': 85000.0,
        'status': 'PUBLISHED',
        'submission_deadline': '2026-04-30',
        'bid_count': 3,
        'description': 'GPU-accelerated cluster for ML research.',
      },
      {
        'id': 'CIRC-2026-002',
        'title': 'Automated Spectral Photometers',
        'department': 'Chemistry Department',
        'category': 'Scientific Instruments',
        'estimated_budget': 145000.0,
        'status': 'EVALUATION',
        'submission_deadline': '2026-05-15',
        'bid_count': 2,
        'description': 'UV-Vis spectrophotometers for laboratory work.',
      },
      {
        'id': 'CIRC-2026-DRAFT',
        'title': 'Internal Draft Not Public',
        'department': 'Admin',
        'category': 'General',
        'estimated_budget': 10000.0,
        'status': 'DRAFT',
        'submission_deadline': '2026-06-01',
        'bid_count': 0,
        'description': 'Draft circular.',
      },
    ]);
    Get.put<DummyDatabaseService>(db);

    final remoteDataSource = AuthRemoteDatasource(_FakeDioClient());
    final authRepo = AuthRepositoryImpl(remoteDataSource);
    final loginUseCase = LoginUseCase(authRepo);
    final getMeUseCase = GetMeUseCase(authRepo);

    Get.put<AuthController>(
      AuthController(loginUseCase: loginUseCase, getMeUseCase: getMeUseCase),
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Desktop split layout renders login panel on left and circulars on right',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Verify left blue branding & login section
    expect(find.text('SHANTO-MARIAM UNIVERSITY'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Showcase Demo Accounts (1-Tap Login)'), findsOneWidget);

    // Verify right white public ongoing circulars section
    expect(find.text('Public Ongoing Procurement Circulars'), findsOneWidget);
    expect(find.text('LIVE PUBLIC NOTICES'), findsOneWidget);
    expect(find.text('High-Performance Computing Cluster'), findsOneWidget);
    expect(find.text('Automated Spectral Photometers'), findsOneWidget);

    // Verify DRAFT circular is filtered out from public view
    expect(find.text('Internal Draft Not Public'), findsNothing);
  });

  testWidgets('Search on public ongoing circulars filters results correctly',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Find search field in circulars panel
    final searchField = find.widgetWithText(
        TextField, 'Search tender title, category, department or ID...');
    expect(searchField, findsOneWidget);

    // Type query matching only the computing cluster
    await tester.enterText(searchField, 'Photometers');
    await tester.pumpAndSettle();

    expect(find.text('Automated Spectral Photometers'), findsOneWidget);
    expect(find.text('High-Performance Computing Cluster'), findsNothing);
  });

  testWidgets('Mobile view displays segmented switcher and toggles views',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Mobile top bar buttons
    expect(find.text('Sign In'), findsWidgets);
    expect(find.textContaining('Public Tenders'), findsOneWidget);

    // Currently on Sign In
    expect(find.text('Welcome back'), findsOneWidget);

    // Tap Public Tenders tab
    final tendersTab = find.textContaining('Public Tenders');
    await tester.tap(tendersTab);
    await tester.pumpAndSettle();

    // Now circulars are visible
    expect(find.text('Public Ongoing Procurement Circulars'), findsOneWidget);
    expect(find.text('High-Performance Computing Cluster'), findsOneWidget);
  });

  testWidgets('Only All Notices and Open for Bids filters exist, and no internal status tags on cards',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    // Verify only 'All Notices' and 'Open for Bids' exist
    expect(find.widgetWithText(FilterChip, 'All Notices'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Open for Bids'), findsOneWidget);

    // Verify the other four removed filter chips are NOT present
    expect(find.text('In Evaluation'), findsNothing);
    expect(find.text('Under Review'), findsNothing);
    expect(find.text('IT & Equipment'), findsNothing);
    expect(find.text('Scientific & Lab'), findsNothing);

    // Verify internal status chips like "PUBLISHED", "EVALUATION", "AWARDED", "PENDING" are NOT on cards
    expect(find.text('PUBLISHED'), findsNothing);
    expect(find.text('EVALUATION'), findsNothing);
    expect(find.text('AWARDED'), findsNothing);
    expect(find.text('PENDING'), findsNothing);

    // Tap "Open for Bids"
    await tester.tap(find.widgetWithText(FilterChip, 'Open for Bids'));
    await tester.pumpAndSettle();

    // Only the published/open circular is shown
    expect(find.text('High-Performance Computing Cluster'), findsOneWidget);
    expect(find.text('Automated Spectral Photometers'), findsNothing);
  });
}
