import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/constants/app_enums.dart';
import 'package:uni_procurement/core/services/dummy_database_service.dart';
import 'package:uni_procurement/core/services/permission_service.dart';
import 'package:uni_procurement/core/services/storage_service.dart';
import 'package:uni_procurement/features/committee/presentation/pages/committee_dashboard_page.dart';
import 'package:uni_procurement/features/committee/presentation/pages/committee_evaluation_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Procurement Committee Unit & Role Tests', () {
    test('UserRole.procurementCommittee parses correctly', () {
      expect(UserRole.fromString('procurement_committee'), UserRole.procurementCommittee);
      expect(UserRole.fromString('committee'), UserRole.procurementCommittee);
      expect(UserRole.procurementCommittee.label, 'Procurement Committee');
      expect(UserRole.procurementCommittee.toApiString(), 'procurement_committee');
    });

    test('PermissionService configures committee home route and nav items', () {
      final permission = PermissionService();
      permission.setRole(UserRole.procurementCommittee);

      expect(permission.homeRoute, '/committee/dashboard');
      expect(permission.canAccess('/committee/dashboard'), isTrue);
      expect(permission.canAccess('/committee/evaluation/CIRC-2026-003'), isTrue);

      final navItems = permission.navItemsForCurrentUser;
      expect(navItems.any((i) => i.route == '/committee/dashboard'), isTrue);
      expect(navItems.any((i) => i.route == '/committee/history'), isTrue);
    });
  });

  group('Procurement Committee Consensus & Workflow Progression Tests', () {
    late DummyDatabaseService db;

    setUp(() async {
      Get.reset();
      db = DummyDatabaseService();
      await db.init();
      Get.put<DummyDatabaseService>(db);
    });

    test('CIRC-2026-003 has initial evaluation state with 2 of 3 members voted', () {
      final eval = db.getCommitteeEvaluationForCircular('CIRC-2026-003');
      expect(eval, isNotNull);
      expect(eval!['is_consensus_reached'], isFalse);

      final members = (eval['members'] as List).cast<Map<String, dynamic>>();
      expect(members.length, 3);

      final votedMembers = members.where((m) => m['has_voted'] == true).toList();
      expect(votedMembers.length, 2);

      // Chair (Prof. Dr. Zahirul Islam) hasn't voted yet
      final chair = members.firstWhere((m) => m['email'] == 'committee@university.edu');
      expect(chair['has_voted'], isFalse);
    });

    test('Chair votes, reaches 100% consensus, and pushes to Tier 1 Dept Head approval', () {
      // Chair submits review
      final success = db.submitCommitteeMemberReview(
        circularId: 'CIRC-2026-003',
        memberEmail: 'committee@university.edu',
        selectedVendorId: 6,
        selectedVendorName: 'Apex Technologies Ltd',
        justification: 'Meets 100% of Corning single-mode optical fiber criteria with Tier 1 Cisco warranty.',
      );

      expect(success, isTrue);

      final updatedEval = db.getCommitteeEvaluationForCircular('CIRC-2026-003');
      expect(updatedEval!['is_consensus_reached'], isTrue);
      expect(updatedEval['status'], 'COMPLETED');
      expect(updatedEval['consolidated_vendor_id'], 6);
      expect(updatedEval['consolidated_vendor_name'], 'Apex Technologies Ltd');

      // Circular status updated to PENDING_DEPT_HEAD
      final circ = db.getCircularById('CIRC-2026-003');
      expect(circ!['status'], 'PENDING_DEPT_HEAD');

      // Created a pending approval queue item for Department Head
      final deptHeadApprovals = db.getPendingApprovalsForRole('approver_dept_head');
      final newApproval = deptHeadApprovals.firstWhere((a) => a['circular_id'] == 'CIRC-2026-003');
      expect(newApproval, isNotNull);
      expect(newApproval['current_stage'], 'Department Head');
      expect(newApproval['committee_consensus'], isNotNull);
    });

    test('Immutable decision: member cannot modify or vote again once locked', () {
      // First vote
      final firstAttempt = db.submitCommitteeMemberReview(
        circularId: 'CIRC-2026-003',
        memberEmail: 'committee@university.edu',
        selectedVendorId: 6,
        selectedVendorName: 'Apex Technologies Ltd',
        justification: 'First immutable vote comment.',
      );
      expect(firstAttempt, isTrue);

      // Second vote attempt must be rejected (immutable)
      final secondAttempt = db.submitCommitteeMemberReview(
        circularId: 'CIRC-2026-003',
        memberEmail: 'committee@university.edu',
        selectedVendorId: 8,
        selectedVendorName: 'BioMed Systems',
        justification: 'Attempting to change vote.',
      );
      expect(secondAttempt, isFalse);
    });
  });

  group('Procurement Committee Widget & Responsive Rendering Tests', () {
    late DummyDatabaseService db;
    late StorageService storage;
    late PermissionService permission;

    setUp(() async {
      Get.reset();
      db = DummyDatabaseService();
      await db.init();
      Get.put<DummyDatabaseService>(db);

      storage = StorageService();
      Get.put<StorageService>(storage);

      permission = PermissionService();
      permission.setRole(UserRole.procurementCommittee);
      Get.put<PermissionService>(permission);
    });

    testWidgets('CommitteeDashboardPage renders on Desktop with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CommitteeDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Procurement Committee Evaluation Workspace'), findsOneWidget);
      expect(find.text('Active Committee Evaluation Radar'), findsOneWidget);
      expect(find.textContaining('Campus-Wide Optical Fiber'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommitteeDashboardPage renders on Mobile (400x800) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CommitteeDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Procurement Committee Evaluation Workspace'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommitteeEvaluationPage renders Comparison Sheet (CS) and QCBS ranking', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.parameters = {'id': 'CIRC-2026-003'};

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CommitteeEvaluationPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Automated Comparison Sheet (CS)'), findsOneWidget);
      expect(find.text('Apex Technologies Ltd'), findsWidgets);
      expect(find.text('1. Select Your Recommended Bidder:'), findsOneWidget);
      expect(find.text('2. Mandatory Justification Comment:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
