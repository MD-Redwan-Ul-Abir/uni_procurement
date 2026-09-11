import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/core/services/bid_compliance_service.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/circulars/presentation/pages/circular_detail_page.dart';
import 'package:uni_procurement/features/circulars/presentation/widgets/bid_status_summary_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BidComplianceService Unit Tests', () {
    test('categorizeBid categorizes statuses strictly into 3 states', () {
      // 1. Bid Submitted
      expect(
        BidComplianceService.categorizeBid({'status': 'SUBMITTED'}),
        equals(BidStatusCategory.bidSubmitted),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'RECEIVED'}),
        equals(BidStatusCategory.bidSubmitted),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'DRAFT'}),
        equals(BidStatusCategory.bidSubmitted),
      );

      // 2. Bid Pending
      expect(
        BidComplianceService.categorizeBid({'status': 'PENDING'}),
        equals(BidStatusCategory.bidPending),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'UNDER_REVIEW'}),
        equals(BidStatusCategory.bidPending),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'EVALUATION'}),
        equals(BidStatusCategory.bidPending),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'EVALUATED'}),
        equals(BidStatusCategory.bidPending),
      );

      // 3. Bid Waiting
      expect(
        BidComplianceService.categorizeBid({'status': 'WAITING'}),
        equals(BidStatusCategory.bidWaiting),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'RECOMMENDED'}),
        equals(BidStatusCategory.bidWaiting),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'AWARDED'}),
        equals(BidStatusCategory.bidWaiting),
      );
      expect(
        BidComplianceService.categorizeBid({'status': 'ACCEPTED'}),
        equals(BidStatusCategory.bidWaiting),
      );
    });

    test('getCategoryCounts strictly aggregates counts across 3 categories', () {
      final sampleBids = [
        {'id': 'B1', 'status': 'SUBMITTED'},
        {'id': 'B2', 'status': 'UNDER_REVIEW'},
        {'id': 'B3', 'status': 'WAITING'},
        {'id': 'B4', 'status': 'SUBMITTED'},
        {'id': 'B5', 'status': 'AWARDED'},
      ];

      final counts = BidComplianceService.getCategoryCounts(sampleBids);
      expect(counts[BidStatusCategory.bidSubmitted], equals(2));
      expect(counts[BidStatusCategory.bidPending], equals(1));
      expect(counts[BidStatusCategory.bidWaiting], equals(2));
    });

    test('isDeadlineExpired correctly computes past and future dates', () {
      // Future date
      expect(BidComplianceService.isDeadlineExpired('2099-12-31'), isFalse);
      // Past date
      expect(BidComplianceService.isDeadlineExpired('2020-01-01'), isTrue);
      // Invalid / empty
      expect(BidComplianceService.isDeadlineExpired(null), isFalse);
      expect(BidComplianceService.isDeadlineExpired('TBD'), isFalse);
    });

    test('Before deadline: vendor offer prices remain confidential for ALL users', () {
      const futureDeadline = '2099-12-31';

      // Admin CANNOT view
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.admin,
        ),
        isFalse,
      );

      // Initiator CANNOT view
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.initiator,
        ),
        isFalse,
      );

      // Procurement Committee Approvers CANNOT view
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.approverDeptHead,
        ),
        isFalse,
      );
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.approverDean,
        ),
        isFalse,
      );
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.approverRegistrar,
        ),
        isFalse,
      );

      // Vendor CANNOT view
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: UserRole.vendor,
        ),
        isFalse,
      );

      // Guest / null CANNOT view
      expect(
        BidComplianceService.canViewBidPrices(
          deadline: futureDeadline,
          role: null,
        ),
        isFalse,
      );

      // Mask text
      expect(
        BidComplianceService.getPriceMaskText(deadline: futureDeadline, role: UserRole.admin),
        contains('Confidential until closing date'),
      );
    });

    test('After deadline: only authorized users & Procurement Committee can view quotations', () {
      const pastDeadline = '2020-01-01';

      // Authorized roles
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.admin),
        isTrue,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.initiator),
        isTrue,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.approverDeptHead),
        isTrue,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.approverDean),
        isTrue,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.approverRegistrar),
        isTrue,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.finance),
        isTrue,
      );

      // Unauthorized roles
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: UserRole.vendor),
        isFalse,
      );
      expect(
        BidComplianceService.canViewBidPrices(deadline: pastDeadline, role: null),
        isFalse,
      );

      // Mask text for unauthorized
      expect(
        BidComplianceService.getPriceMaskText(deadline: pastDeadline, role: UserRole.vendor),
        contains('Authorized Committee Only'),
      );
    });
  });

  group('BidStatusSummaryCard Widget Tests', () {
    late DummyDatabaseService db;
    late PermissionService permission;

    setUp(() {
      Get.reset();
      db = DummyDatabaseService();
      permission = PermissionService();
      Get.put<DummyDatabaseService>(db);
      Get.put<PermissionService>(permission);

      // Populate mock data
      db.circulars.assignAll([
        {
          'id': 'CIRC-TEST-001',
          'title': 'Test Tender with Active Bidding',
          'department': 'CSE',
          'category': 'IT Equipment',
          'estimated_budget': 100000.0,
          'status': 'PUBLISHED',
          'submission_deadline': '2099-12-31', // Future
          'description': 'Test circular description',
          'bid_count': 3,
        },
        {
          'id': 'CIRC-TEST-002',
          'title': 'Test Tender Expired',
          'department': 'EEE',
          'category': 'Lab Equipment',
          'estimated_budget': 50000.0,
          'status': 'EVALUATION',
          'submission_deadline': '2020-01-01', // Past
          'description': 'Past deadline circular',
          'bid_count': 1,
        },
      ]);

      db.bids.assignAll([
        {
          'id': 'BID-001',
          'circular_id': 'CIRC-TEST-001',
          'vendor_name': 'Tech Corp',
          'quoted_amount': 95000.0,
          'submission_date': '2026-03-01',
          'status': 'SUBMITTED',
          'delivery_days': 30,
        },
        {
          'id': 'BID-002',
          'circular_id': 'CIRC-TEST-001',
          'vendor_name': 'Alpha Ltd',
          'quoted_amount': 92000.0,
          'submission_date': '2026-03-02',
          'status': 'UNDER_REVIEW',
          'delivery_days': 25,
        },
        {
          'id': 'BID-003',
          'circular_id': 'CIRC-TEST-001',
          'vendor_name': 'Beta Solutions',
          'quoted_amount': 88000.0,
          'submission_date': '2026-03-03',
          'status': 'WAITING',
          'delivery_days': 20,
        },
        {
          'id': 'BID-004',
          'circular_id': 'CIRC-TEST-002',
          'vendor_name': 'Gamma Instruments',
          'quoted_amount': 45000.0,
          'submission_date': '2020-01-01',
          'status': 'RECOMMENDED',
          'delivery_days': 15,
        },
      ]);
    });

    testWidgets('renders all 3 categories with live counts before deadline', (tester) async {
      permission.setRole(UserRole.admin);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BidStatusSummaryCard(
                circularId: 'CIRC-TEST-001',
                submissionDeadline: '2099-12-31',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and categories
      expect(find.text('Bid Live Status & Compliance Summary'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Bid Submitted'), findsWidgets);
      expect(find.text('Bid Pending'), findsWidgets);
      expect(find.text('Bid Waiting'), findsWidgets);

      // Check confidential banner
      expect(find.textContaining('Sealed Bid Confidentiality Protocol Active'), findsOneWidget);

      // Check that offer price is sealed and confidential even for admin before deadline
      expect(find.text('95,000'), findsNothing);
      expect(find.text('92,000'), findsNothing);
      expect(find.text('88,000'), findsNothing);
      expect(find.textContaining('Confidential until closing date'), findsWidgets);
    });

    testWidgets('reveals quotation price after deadline for authorized user', (tester) async {
      // User is Department Head (Procurement Committee)
      permission.setRole(UserRole.approverDeptHead);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BidStatusSummaryCard(
                circularId: 'CIRC-TEST-002',
                submissionDeadline: '2020-01-01',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check unsealed banner
      expect(find.textContaining('Bid Closing Deadline Expired: Quotations Unsealed'), findsOneWidget);

      // Offer price must now be revealed to authorized committee
      expect(find.textContaining('45,000'), findsOneWidget);
    });

    testWidgets('masks quotation price after deadline for unauthorized guest/vendor', (tester) async {
      // Vendor logged in
      permission.setRole(UserRole.vendor);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BidStatusSummaryCard(
                circularId: 'CIRC-TEST-002',
                submissionDeadline: '2020-01-01',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Banner indicates restricted access
      expect(find.textContaining('Bid Closing Deadline Officially Expired'), findsOneWidget);

      // Offer price must NOT be revealed to vendor
      expect(find.textContaining('45,000'), findsNothing);
      expect(find.textContaining('Authorized Committee Only'), findsOneWidget);
    });
  });

  group('CircularDetailPage Integration Tests', () {
    late DummyDatabaseService db;
    late PermissionService permission;

    setUp(() {
      Get.reset();
      db = DummyDatabaseService();
      permission = PermissionService();
      final storage = StorageService();
      Get.put<DummyDatabaseService>(db);
      Get.put<PermissionService>(permission);
      Get.put<StorageService>(storage);

      db.circulars.assignAll([
        {
          'id': 'CIRC-2026-004',
          'title': 'Central Library RFID Circulation',
          'department': 'Central University Library',
          'category': 'Automation Software',
          'estimated_budget': 62000.0,
          'status': 'PUBLISHED',
          'submission_deadline': '2099-12-31',
          'description': 'RFID circulation system',
          'bid_count': 1,
        },
      ]);

      db.bids.assignAll([
        {
          'id': 'BID-2026-105',
          'circular_id': 'CIRC-2026-004',
          'vendor_name': 'Apex Technologies Ltd',
          'quoted_amount': 59800.0,
          'submission_date': '2026-03-10',
          'status': 'SUBMITTED',
          'delivery_days': 25,
        },
      ]);
    });

    testWidgets('renders BidStatusSummaryCard inside CircularDetailPage', (tester) async {
      Get.parameters = {'id': 'CIRC-2026-004'};

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CircularDetailPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Check that the summary card is visible in detail page
      expect(find.text('Bid Live Status & Compliance Summary'), findsOneWidget);
      expect(find.text('Bid Submitted'), findsWidgets);
      expect(find.text('Bid Pending'), findsWidgets);
      expect(find.text('Bid Waiting'), findsWidgets);
      // Prices remain confidential
      expect(find.text('59,800'), findsNothing);
      expect(find.textContaining('Confidential until closing date'), findsWidgets);
    });
  });
}
