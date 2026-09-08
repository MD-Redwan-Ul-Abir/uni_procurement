import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/core/error/exceptions.dart';
import 'package:uni_procurement/core/network/dio_client.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/auth/data/datasources/auth_remote_datasource.dart';

class _MockStorageService extends GetxService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockDioClient implements DioClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RBAC & Role Separation Tests', () {
    late PermissionService permissionService;

    setUp(() {
      Get.reset();
      Get.put<StorageService>(_MockStorageService());
      permissionService = PermissionService();
      Get.put(permissionService);
    });

    test('Home routes are correctly isolated for Initiator and Vendor', () {
      permissionService.setRole(UserRole.initiator);
      expect(permissionService.homeRoute, '/initiator/dashboard');

      permissionService.setRole(UserRole.vendor);
      expect(permissionService.homeRoute, '/vendor/dashboard');

      permissionService.setRole(UserRole.admin);
      expect(permissionService.homeRoute, '/admin/reports');

      permissionService.clearRole();
      expect(permissionService.homeRoute, '/login');
    });

    test('Initiator has project/tender nav items and NO vendor nav items', () {
      permissionService.setRole(UserRole.initiator);
      final navItems = permissionService.navItemsForCurrentUser;
      final routes = navItems.map((item) => item.route).toList();

      expect(routes, contains('/initiator/dashboard'));
      expect(routes, contains('/circulars'));
      expect(routes, contains('/initiator/circulars/new'));
      expect(routes, contains('/approvals'));
      expect(routes, contains('/initiator/history'));

      // Strict isolation: Initiator must NOT have vendor routes
      expect(routes.contains('/vendor/dashboard'), isFalse);
      expect(routes.contains('/vendor/my-bids'), isFalse);
      expect(routes.contains('/work-orders'), isFalse);
    });

    test('Vendor has isolated nav items and NO initiator menus or rights', () {
      permissionService.setRole(UserRole.vendor);
      final navItems = permissionService.navItemsForCurrentUser;
      final routes = navItems.map((item) => item.route).toList();

      expect(routes, contains('/vendor/dashboard'));
      expect(routes, contains('/circulars'));
      expect(routes, contains('/vendor/my-bids'));
      expect(routes, contains('/work-orders'));

      // Strict isolation: Vendor must NOT have initiator routes
      expect(routes.contains('/initiator/dashboard'), isFalse);
      expect(routes.contains('/initiator/circulars/new'), isFalse);
      expect(routes.contains('/circulars/create'), isFalse);
      expect(routes.contains('/initiator/history'), isFalse);
      expect(routes.contains('/approvals'), isFalse);
    });

    test('Guest (unauthenticated) has public navigation items', () {
      permissionService.clearRole();
      final navItems = permissionService.navItemsForCurrentUser;
      final routes = navItems.map((item) => item.route).toList();

      expect(routes, contains('/circulars'));
      expect(routes, contains('/login'));
      expect(routes, contains('/vendor/register'));

      // Guest cannot see internal dashboards
      expect(routes.contains('/initiator/dashboard'), isFalse);
      expect(routes.contains('/vendor/dashboard'), isFalse);
    });

    test('Public circulars are accessible without login', () {
      permissionService.clearRole();
      expect(permissionService.canAccess('/circulars'), isTrue);
      expect(permissionService.canAccess('/circulars/CIRC-2026-001'), isTrue);
    });

    test('Role route permissions strictly separate Initiator and Vendor', () {
      // Initiator permissions
      permissionService.setRole(UserRole.initiator);
      expect(permissionService.canAccess('/initiator/dashboard'), isTrue);
      expect(permissionService.canAccess('/initiator/circulars/new'), isTrue);
      expect(permissionService.canAccess('/initiator/history'), isTrue);
      expect(permissionService.canAccess('/circulars/create'), isTrue);
      expect(permissionService.canAccess('/circulars'), isTrue);

      // Initiator CANNOT access vendor routes
      expect(permissionService.canAccess('/vendor/dashboard'), isFalse);
      expect(permissionService.canAccess('/vendor/my-bids'), isFalse);
      expect(permissionService.canAccess('/bids'), isFalse);

      // Vendor permissions
      permissionService.setRole(UserRole.vendor);
      expect(permissionService.canAccess('/vendor/dashboard'), isTrue);
      expect(permissionService.canAccess('/vendor/my-bids'), isTrue);
      expect(permissionService.canAccess('/bids'), isTrue);
      expect(permissionService.canAccess('/circulars'), isTrue);

      // Vendor CANNOT access initiator routes
      expect(permissionService.canAccess('/initiator/dashboard'), isFalse);
      expect(permissionService.canAccess('/initiator/circulars/new'), isFalse);
      expect(permissionService.canAccess('/initiator/history'), isFalse);
      expect(permissionService.canAccess('/circulars/create'), isFalse);
    });
  });

  group('Vendor Registration Document Mandatory Validation Tests', () {
    late AuthRemoteDatasource datasource;

    setUp(() {
      Get.reset();
      Get.put<StorageService>(_MockStorageService());
      datasource = AuthRemoteDatasource(_MockDioClient());
    });

    test('Rejects vendor registration if Trade License is missing', () async {
      expect(
        () => datasource.registerVendor(
          companyName: 'Test Co',
          address: 'Dhaka',
          contactPerson: 'Mr. Test',
          phone: '+880123456789',
          tradeLicenseNumber: 'TL-123',
          tradeLicenseFile: null, // MISSING
          taxId: 'TIN-123',
          taxIdFile: 'tin.pdf',
          binNumber: 'BIN-123',
          binFile: 'bin.pdf',
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Rejects vendor registration if TIN document is missing', () async {
      expect(
        () => datasource.registerVendor(
          companyName: 'Test Co',
          address: 'Dhaka',
          contactPerson: 'Mr. Test',
          phone: '+880123456789',
          tradeLicenseNumber: 'TL-123',
          tradeLicenseFile: 'tl.pdf',
          taxId: 'TIN-123',
          taxIdFile: null, // MISSING
          binNumber: 'BIN-123',
          binFile: 'bin.pdf',
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Rejects vendor registration if BIN document is missing', () async {
      expect(
        () => datasource.registerVendor(
          companyName: 'Test Co',
          address: 'Dhaka',
          contactPerson: 'Mr. Test',
          phone: '+880123456789',
          tradeLicenseNumber: 'TL-123',
          tradeLicenseFile: 'tl.pdf',
          taxId: 'TIN-123',
          taxIdFile: 'tin.pdf',
          binNumber: 'BIN-123',
          binFile: null, // MISSING
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Accepts vendor registration when Trade License, TIN, and BIN are all present', () async {
      final dummyDb = DummyDatabaseService();
      Get.put(dummyDb);

      await datasource.registerVendor(
        companyName: 'Complete Corp',
        address: 'Dhaka',
        contactPerson: 'Rahim',
        phone: '+8801700000000',
        tradeLicenseNumber: 'TL-8899',
        tradeLicenseFile: 'trade_license.pdf',
        taxId: 'TIN-9900',
        taxIdFile: 'tin_cert.pdf',
        binNumber: 'BIN-1122',
        binFile: 'bin_cert.pdf',
        email: 'rahim@complete.com',
        password: 'password123',
      );

      final inserted = dummyDb.vendorVerifications.first;
      expect(inserted['company_name'], 'Complete Corp');
      expect(inserted['trade_license_file'], 'trade_license.pdf');
      expect(inserted['tax_id_file'], 'tin_cert.pdf');
      expect(inserted['bin_file'], 'bin_cert.pdf');
      expect(inserted['bin_number'], 'BIN-1122');
    });
  });
}
