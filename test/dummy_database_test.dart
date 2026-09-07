import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';

void main() {
  group('DummyDatabaseService Interactive Operations Test', () {
    late DummyDatabaseService db;

    setUp(() async {
      Get.reset();
      db = DummyDatabaseService();
      // Populate baseline data in-memory for testing
      db.users.assignAll([
        {
          'id': 1,
          'name': 'Dr. Arthur Vance',
          'email': 'admin@university.edu',
          'role': 'admin',
          'password': 'password123',
        },
        {
          'id': 6,
          'name': 'Apex Technologies Ltd',
          'email': 'vendor@apextech.com',
          'role': 'vendor',
          'password': 'password123',
        }
      ]);
      db.circulars.assignAll([
        {
          'id': 'CIRC-2026-001',
          'title': 'High-Performance Computing Cluster for AI Lab',
          'status': 'AWARDED',
          'bid_count': 3,
        }
      ]);
      db.invoices.assignAll([
        {
          'id': 'INV-2026-301',
          'work_order_id': 'WO-2026-001',
          'circular_title': 'High-Performance Computing Cluster for AI Lab',
          'vendor_name': 'Apex Technologies Ltd',
          'invoice_number': 'APEX-2026-0089',
          'total_payable': 86625.0,
          'status': 'PENDING_REVIEW',
        }
      ]);
      db.adminUsers.assignAll([
        {
          'id': 1,
          'name': 'Dr. Arthur Vance',
          'email': 'admin@university.edu',
          'role': 'admin',
          'status': 'ACTIVE',
        }
      ]);
      db.vendorVerifications.assignAll([
        {
          'id': 9,
          'company_name': 'Metro Data Solutions',
          'status': 'PENDING',
        }
      ]);
      db.pendingApprovals.assignAll([
        {
          'id': 'APP-2026-001',
          'circular_id': 'CIRC-2026-002',
          'title': 'Automated DNA Sequencer',
          'required_role': 'approver_dean',
          'requested_amount': 135000.0,
        }
      ]);
      Get.put<DummyDatabaseService>(db);
    });

    tearDown(() {
      Get.reset();
    });

    test('authenticate succeeds for valid credentials', () {
      final user = db.authenticate('admin@university.edu', 'password123');
      expect(user, isNotNull);
      expect(user!['name'], equals('Dr. Arthur Vance'));
      expect(user['role'], equals('admin'));
    });

    test('approveInvoicePayment updates invoice status to PAID reactively', () {
      expect(db.invoices.first['status'], equals('PENDING_REVIEW'));
      db.approveInvoicePayment('INV-2026-301');
      expect(db.invoices.first['status'], equals('PAID'));
    });

    test('toggleAdminUserStatus flips user between ACTIVE and INACTIVE', () {
      expect(db.adminUsers.first['status'], equals('ACTIVE'));
      db.toggleAdminUserStatus(1);
      expect(db.adminUsers.first['status'], equals('INACTIVE'));
      db.toggleAdminUserStatus(1);
      expect(db.adminUsers.first['status'], equals('ACTIVE'));
    });

    test('updateVendorVerificationStatus activates vendor', () {
      expect(db.vendorVerifications.first['status'], equals('PENDING'));
      db.updateVendorVerificationStatus(9, 'ACTIVE');
      expect(db.vendorVerifications.first['status'], equals('ACTIVE'));
      expect(db.vendorVerifications.first['verified_by'], isNotNull);
    });

    test('approveRequest records audit history and updates circular status', () {
      expect(db.pendingApprovals.length, equals(1));
      db.approveRequest(
        approvalId: 'APP-2026-001',
        approverName: 'Prof. Kamal Hossain',
        approverRole: 'Faculty Dean',
        comments: 'Approved without objections',
      );
      expect(db.pendingApprovals.length, equals(0));
      expect(db.approvalHistory.length, equals(1));
      expect(db.approvalHistory.first['action'], equals('APPROVED'));
      expect(db.approvalHistory.first['approver_name'], equals('Prof. Kamal Hossain'));
    });

    test('addBid increments circular bid_count', () {
      expect(db.circulars.first['bid_count'], equals(3));
      db.addBid({
        'id': 'BID-2026-999',
        'circular_id': 'CIRC-2026-001',
        'vendor_id': 6,
        'vendor_name': 'Apex Technologies Ltd',
        'grand_total': 80000.0,
      });
      expect(db.circulars.first['bid_count'], equals(4));
    });
  });
}
