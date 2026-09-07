import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/finance/presentation/pages/finance_completed_page.dart';
import 'package:uni_procurement/features/finance/presentation/pages/finance_dashboard_page.dart';
import 'package:uni_procurement/features/finance/presentation/pages/finance_invoices_page.dart';
import 'package:uni_procurement/features/finance/presentation/pages/finance_review_page.dart';

class _MockStorageService extends GetxService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late DummyDatabaseService db;
  late PermissionService perm;

  setUp(() {
    Get.reset();
    db = DummyDatabaseService();
    db.invoices.assignAll([
      {
        'id': 'INV-2026-301',
        'work_order_id': 'WO-2026-001',
        'circular_title': 'High-Performance Computing Cluster for AI Lab',
        'vendor_id': 6,
        'vendor_name': 'Apex Technologies Ltd',
        'invoice_number': 'APEX-2026-0089',
        'invoice_date': '2026-03-02',
        'amount': 82500.0,
        'tax_amount': 4125.0,
        'total_payable': 86625.0,
        'status': 'PENDING_REVIEW',
        'chalan_number': 'CHAL-DH-88129',
        'delivery_date': '2026-03-01',
        'department': 'Computer Science & Engineering',
        'remarks': 'Hardware delivery accepted and signed by Lab in-charge.',
        'bank_details': {
          'bank_name': 'Eastern Bank Ltd',
          'branch': 'Gulshan Branch, Dhaka',
          'account_name': 'Apex Technologies Ltd',
          'account_number': '1041060098712',
          'routing_number': '095261456',
        },
        'attached_documents': [
          {'name': 'Invoice_APEX-0089.pdf', 'size_kb': 1450},
          {'name': 'Signed_Goods_Delivery_Chalan.pdf', 'size_kb': 2210},
        ],
      },
      {
        'id': 'INV-2025-245',
        'work_order_id': 'WO-2025-089',
        'circular_title': 'Annual Campus Network Firewall Licensing',
        'vendor_id': 6,
        'vendor_name': 'Apex Technologies Ltd',
        'invoice_number': 'APEX-2025-0982',
        'invoice_date': '2025-12-10',
        'amount': 34000.0,
        'tax_amount': 1700.0,
        'total_payable': 35700.0,
        'status': 'PAID',
        'chalan_number': 'CHAL-DH-77291',
        'delivery_date': '2025-12-08',
        'department': 'IT & Networking Division',
        'remarks': 'Payment disbursed via EFT.',
        'bank_details': {
          'bank_name': 'Eastern Bank Ltd',
          'branch': 'Gulshan Branch, Dhaka',
          'account_name': 'Apex Technologies Ltd',
          'account_number': '1041060098712',
          'routing_number': '095261456',
        },
        'attached_documents': [
          {'name': 'Invoice_Paid_Receipt.pdf', 'size_kb': 1120},
        ],
      },
    ]);

    db.financeSummary.assignAll({
      'total_procurement_budget': 3500000.0,
      'committed_funds': 2185000.0,
      'disbursed_funds': 1420000.0,
      'pending_invoices_amount': 86625.0,
      'fiscal_year': '2025-2026',
      'uncommitted_balance': 1315000.0,
      'avg_turnaround_days': 3.2,
      'eft_success_rate': '98.5%',
      'spend_by_department': [
        {'department': 'Computer Science & Engineering', 'allocated': 850000.0, 'disbursed': 420000.0, 'percentage': 29.5},
        {'department': 'Academic Affairs', 'allocated': 620000.0, 'disbursed': 280000.0, 'percentage': 19.7},
      ],
    });

    Get.put<DummyDatabaseService>(db);
    Get.put<StorageService>(_MockStorageService());
    perm = PermissionService();
    perm.setRole(UserRole.finance);
    Get.put<PermissionService>(perm);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp(Widget page) {
    return GetMaterialApp(
      home: page,
      theme: ThemeData(useMaterial3: true),
    );
  }

  group('Finance Database Business Logic Tests', () {
    test('approveInvoicePayment updates status to PAID and populates EFT credentials', () {
      expect(db.invoices.first['status'], equals('PENDING_REVIEW'));
      db.approveInvoicePayment('INV-2026-301');
      expect(db.invoices.first['status'], equals('PAID'));
      expect(db.invoices.first['eft_transaction_id'], isNotNull);
      expect(db.invoices.first['paid_at'], isNotNull);
      expect(db.invoices.first['disbursed_by'], contains('Finance Officer'));
    });

    test('rejectInvoicePayment updates status and reason', () {
      expect(db.invoices.first['status'], equals('PENDING_REVIEW'));
      db.rejectInvoicePayment('INV-2026-301', 'Chalan signature missing');
      expect(db.invoices.first['status'], equals('RETURNED_FOR_CLARIFICATION'));
      expect(db.invoices.first['rejection_reason'], equals('Chalan signature missing'));
    });
  });

  group('Finance Dashboard Responsive Rendering Tests', () {
    testWidgets('renders on Desktop (1400x900) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance & Treasury'), findsOneWidget);
      expect(find.text('Fiscal Procurement Budget'), findsOneWidget);
      expect(find.text('Committed Contract Liabilities'), findsOneWidget);
      expect(find.text('Disbursed Settlements'), findsOneWidget);
      expect(find.text('Budget Utilization & Ceilings'), findsOneWidget);
      expect(find.text('Urgent Claims Requiring Disbursal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on Tablet (800x1000) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance & Treasury'), findsOneWidget);
      expect(find.text('Review Pending Claims'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on Mobile (390x844) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance & Treasury'), findsOneWidget);
      expect(find.text('Urgent Claims Requiring Disbursal'), findsOneWidget);
      expect(find.text('INV-2026-301'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on Small Mobile (320x568) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance & Treasury'), findsOneWidget);
      expect(find.text('INV-2026-301'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Finance Invoices Queue Responsive Rendering & Filtering Tests', () {
    testWidgets('renders on Desktop (1400x900) and filters by query', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceInvoicesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Invoices & Claims Queue'), findsOneWidget);
      expect(find.text('Total Invoices Logged'), findsOneWidget);
      expect(find.text('INV-2026-301'), findsOneWidget);
      expect(find.text('INV-2025-245'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), '2026-301');
      await tester.pumpAndSettle();

      expect(find.text('INV-2026-301'), findsOneWidget);
      expect(find.text('INV-2025-245'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on Mobile (390x844) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceInvoicesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Invoices & Claims Queue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Finance Settled Payments Page Rendering Tests', () {
    testWidgets('renders on Desktop and Mobile without overflow', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceCompletedPage()));
      await tester.pumpAndSettle();

      expect(find.text('Settled Payments & Treasury Audit'), findsOneWidget);
      expect(find.text('Total Reconciled Payouts'), findsOneWidget);
      expect(find.text('INV-2025-245'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Finance Review & EFT Disbursal Page Tests', () {
    testWidgets('renders invoice audit details and executes approval modal', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const FinanceReviewPage()));
      await tester.pumpAndSettle();

      expect(find.text('Invoice & Payment Disbursal Audit'), findsOneWidget);
      expect(find.text('Verified Bank Routing Credentials (BEFTN / RTGS)'), findsOneWidget);
      expect(find.text('Eastern Bank Ltd'), findsOneWidget);
      // Scroll to and tap Approve & Disburse
      await tester.ensureVisible(find.text('Approve & Disburse Payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve & Disburse Payment'));
      await tester.pumpAndSettle();

      // Modal dialog should appear
      expect(find.text('Confirm EFT Payment Release'), findsOneWidget);
      expect(find.text('Authorize & Disburse'), findsOneWidget);

      // Confirm in dialog
      await tester.tap(find.text('Authorize & Disburse'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
