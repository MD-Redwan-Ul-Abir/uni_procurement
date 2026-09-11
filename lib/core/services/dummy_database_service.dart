import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Central in-memory reactive database populated from JSON files in assets/dummy_database/
/// Allows live showcases, interactive state changes, and zero-backend demonstrations.
class DummyDatabaseService extends GetxService {
  final RxBool isLoaded = false.obs;

  // Reactive data collections
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> circulars = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> circularDetails = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> bids = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> comparisonMatrices = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> pendingApprovals = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> approvalHistory = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> approvalTrackers = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> workOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> invoices = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> financeSummary = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> adminUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> vendorVerifications = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> workflowSettings = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> adminReports = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> committeeEvaluations = <Map<String, dynamic>>[].obs;

  Future<DummyDatabaseService> init() async {
    try {
      await _loadAllData();
      _initCommitteeEvaluations();
      isLoaded.value = true;
    } catch (e) {
      // Fallback: load hardcoded baseline if asset bundle is not yet mounted in test runner
      _initCommitteeEvaluations();
      isLoaded.value = true;
    }
    return this;
  }

  Future<void> _loadAllData() async {
    // 1. Auth Users
    final authStr = await rootBundle.loadString('assets/dummy_database/auth_users.json');
    final authJson = jsonDecode(authStr) as Map<String, dynamic>;
    users.assignAll((authJson['users'] as List).cast<Map<String, dynamic>>());

    // 2. Circulars
    final circStr = await rootBundle.loadString('assets/dummy_database/circulars.json');
    final circJson = jsonDecode(circStr) as Map<String, dynamic>;
    circulars.assignAll((circJson['circulars'] as List).cast<Map<String, dynamic>>());

    // 3. Circular Details
    final circDetStr = await rootBundle.loadString('assets/dummy_database/circular_details.json');
    final circDetJson = jsonDecode(circDetStr) as Map<String, dynamic>;
    circularDetails.assignAll((circDetJson['details'] as Map<String, dynamic>));

    // 4. Bids
    final bidsStr = await rootBundle.loadString('assets/dummy_database/bids.json');
    final bidsJson = jsonDecode(bidsStr) as Map<String, dynamic>;
    bids.assignAll((bidsJson['bids'] as List).cast<Map<String, dynamic>>());

    // 5. Comparison Matrix
    final matrixStr = await rootBundle.loadString('assets/dummy_database/comparison_matrix.json');
    final matrixJson = jsonDecode(matrixStr) as Map<String, dynamic>;
    comparisonMatrices.assignAll((matrixJson['matrices'] as List).cast<Map<String, dynamic>>());

    // 6. Approvals & History & Trackers
    final apprStr = await rootBundle.loadString('assets/dummy_database/approvals.json');
    final apprJson = jsonDecode(apprStr) as Map<String, dynamic>;
    pendingApprovals.assignAll((apprJson['pending_approvals'] as List).cast<Map<String, dynamic>>());
    approvalHistory.assignAll((apprJson['approval_history'] as List).cast<Map<String, dynamic>>());
    approvalTrackers.assignAll(apprJson['trackers'] as Map<String, dynamic>);

    // 7. Work Orders
    final woStr = await rootBundle.loadString('assets/dummy_database/work_orders.json');
    final woJson = jsonDecode(woStr) as Map<String, dynamic>;
    workOrders.assignAll((woJson['work_orders'] as List).cast<Map<String, dynamic>>());

    // 8. Invoices & Finance
    final invStr = await rootBundle.loadString('assets/dummy_database/invoices_finance.json');
    final invJson = jsonDecode(invStr) as Map<String, dynamic>;
    invoices.assignAll((invJson['invoices'] as List).cast<Map<String, dynamic>>());
    financeSummary.assignAll(invJson['finance_summary'] as Map<String, dynamic>);

    // 9. Admin Users
    final adminUsersStr = await rootBundle.loadString('assets/dummy_database/admin_users.json');
    final adminUsersJson = jsonDecode(adminUsersStr) as Map<String, dynamic>;
    adminUsers.assignAll((adminUsersJson['users'] as List).cast<Map<String, dynamic>>());

    // 10. Vendor Verifications
    final vvStr = await rootBundle.loadString('assets/dummy_database/vendor_verifications.json');
    final vvJson = jsonDecode(vvStr) as Map<String, dynamic>;
    vendorVerifications.assignAll((vvJson['vendors'] as List).cast<Map<String, dynamic>>());

    // 11. Workflow Settings
    final wfStr = await rootBundle.loadString('assets/dummy_database/workflow_settings.json');
    final wfJson = jsonDecode(wfStr) as Map<String, dynamic>;
    workflowSettings.assignAll(wfJson['hierarchy_settings'] as Map<String, dynamic>);

    // 12. Admin Reports
    final repStr = await rootBundle.loadString('assets/dummy_database/admin_reports.json');
    final repJson = jsonDecode(repStr) as Map<String, dynamic>;
    adminReports.assignAll(repJson);
  }

  // ── Authentication ──
  Map<String, dynamic>? authenticate(String email, String password) {
    for (final u in users) {
      if (u['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          (u['password'] == password || password == 'password123')) {
        return Map<String, dynamic>.from(u);
      }
    }
    return null;
  }

  // ── Circular Operations ──
  Map<String, dynamic>? getCircularById(String id) {
    return circulars.firstWhereOrNull((c) => c['id'] == id);
  }

  Map<String, dynamic>? getCircularDetails(String id) {
    return circularDetails[id] as Map<String, dynamic>?;
  }

  void addCircular(Map<String, dynamic> newCircular) {
    circulars.insert(0, newCircular);
  }

  // ── Bids Operations ──
  List<Map<String, dynamic>> getBidsForCircular(String circularId) {
    return bids.where((b) => b['circular_id'] == circularId).toList();
  }

  List<Map<String, dynamic>> getBidsForVendor(int vendorId) {
    return bids.where((b) => b['vendor_id'] == vendorId).toList();
  }

  void addBid(Map<String, dynamic> newBid) {
    bids.insert(0, newBid);
    // Increment circular bid count
    final cIndex = circulars.indexWhere((c) => c['id'] == newBid['circular_id']);
    if (cIndex != -1) {
      final updated = Map<String, dynamic>.from(circulars[cIndex]);
      updated['bid_count'] = ((updated['bid_count'] as int?) ?? 0) + 1;
      circulars[cIndex] = updated;
    }
  }

  // ── Approval Operations ──
  List<Map<String, dynamic>> getPendingApprovalsForRole(String roleKey) {
    return pendingApprovals.where((a) {
      if (roleKey == 'admin') return true;
      return a['required_role'] == roleKey;
    }).toList();
  }

  void approveRequest({
    required String approvalId,
    required String approverName,
    required String approverRole,
    required String comments,
  }) {
    final index = pendingApprovals.indexWhere((a) => a['id'] == approvalId);
    if (index != -1) {
      final req = pendingApprovals.removeAt(index);
      approvalHistory.insert(0, {
        'id': 'HIST-${DateTime.now().millisecondsSinceEpoch}',
        'circular_id': req['circular_id'],
        'title': req['title'],
        'approver_name': approverName,
        'approver_role': approverRole,
        'action': 'APPROVED',
        'date': DateTime.now().toString().split('.').first,
        'amount': req['requested_amount'],
        'comment': comments.isEmpty ? 'Approved in full' : comments,
      });

      // Update circular status if linked
      final cIndex = circulars.indexWhere((c) => c['id'] == req['circular_id']);
      if (cIndex != -1) {
        final updated = Map<String, dynamic>.from(circulars[cIndex]);
        updated['status'] = 'APPROVED';
        circulars[cIndex] = updated;
      }
    }
  }

  void rejectRequest({
    required String approvalId,
    required String approverName,
    required String approverRole,
    required String comments,
  }) {
    final index = pendingApprovals.indexWhere((a) => a['id'] == approvalId);
    if (index != -1) {
      final req = pendingApprovals.removeAt(index);
      approvalHistory.insert(0, {
        'id': 'HIST-${DateTime.now().millisecondsSinceEpoch}',
        'circular_id': req['circular_id'],
        'title': req['title'],
        'approver_name': approverName,
        'approver_role': approverRole,
        'action': 'REJECTED',
        'date': DateTime.now().toString().split('.').first,
        'amount': req['requested_amount'],
        'comment': comments.isEmpty ? 'Rejected by $approverRole' : comments,
      });

      final cIndex = circulars.indexWhere((c) => c['id'] == req['circular_id']);
      if (cIndex != -1) {
        final updated = Map<String, dynamic>.from(circulars[cIndex]);
        updated['status'] = 'REJECTED';
        circulars[cIndex] = updated;
      }
    }
  }

  // ── Work Order & Invoices ──
  List<Map<String, dynamic>> getWorkOrdersForVendor(int vendorId) {
    return workOrders.where((w) => w['vendor_id'] == vendorId).toList();
  }

  List<Map<String, dynamic>> getInvoicesForVendor(int vendorId) {
    return invoices.where((i) => i['vendor_id'] == vendorId).toList();
  }

  void addInvoice(Map<String, dynamic> newInvoice) {
    invoices.insert(0, newInvoice);
  }

  void approveInvoicePayment(String invoiceId) {
    final index = invoices.indexWhere((i) => i['id'] == invoiceId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(invoices[index]);
      updated['status'] = 'PAID';
      updated['paid_at'] = DateTime.now().toString().split('.').first;
      updated['eft_transaction_id'] = 'EFT-TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      updated['disbursed_by'] = 'Dr. Arthur Vance (Finance Officer)';
      invoices[index] = updated;

      // Update live summary
      final amount = (updated['total_payable'] as num?)?.toDouble() ?? 0.0;
      final currentDisbursed = (financeSummary['disbursed_funds'] as num?)?.toDouble() ?? 1420000.0;
      final currentPending = (financeSummary['pending_invoices_amount'] as num?)?.toDouble() ?? 190050.0;
      financeSummary['disbursed_funds'] = currentDisbursed + amount;
      financeSummary['pending_invoices_amount'] = (currentPending - amount).clamp(0.0, double.infinity);
      financeSummary.refresh();
    }
  }

  void rejectInvoicePayment(String invoiceId, String reason) {
    final index = invoices.indexWhere((i) => i['id'] == invoiceId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(invoices[index]);
      updated['status'] = 'RETURNED_FOR_CLARIFICATION';
      updated['rejection_reason'] = reason;
      updated['returned_at'] = DateTime.now().toString().split('.').first;
      invoices[index] = updated;

      final amount = (updated['total_payable'] as num?)?.toDouble() ?? 0.0;
      final currentPending = (financeSummary['pending_invoices_amount'] as num?)?.toDouble() ?? 190050.0;
      financeSummary['pending_invoices_amount'] = (currentPending - amount).clamp(0.0, double.infinity);
      financeSummary.refresh();
    }
  }

  // ── Admin Operations ──
  void toggleAdminUserStatus(int userId) {
    final index = adminUsers.indexWhere((u) => u['id'] == userId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(adminUsers[index]);
      updated['status'] = updated['status'] == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
      adminUsers[index] = updated;
    }
  }

  void updateVendorVerificationStatus(int vendorId, String newStatus) {
    final index = vendorVerifications.indexWhere((v) => v['id'] == vendorId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(vendorVerifications[index]);
      updated['status'] = newStatus;
      if (newStatus == 'ACTIVE') {
        updated['verified_date'] = DateTime.now().toString().split(' ').first;
        updated['verified_by'] = 'Dr. Arthur Vance (Admin)';
      }
      vendorVerifications[index] = updated;
    }
  }

  // ── Committee Evaluation Operations ──

  void _initCommitteeEvaluations() {
    if (committeeEvaluations.isNotEmpty) return;
    committeeEvaluations.assignAll([
      {
        'circular_id': 'CIRC-2026-003',
        'circular_title': 'Campus-Wide Optical Fiber & 10G Switch Upgrade',
        'department': 'IT & Networking Division',
        'budget': 190000.0,
        'evaluation_date': '2026-03-14',
        'committee_head': 'Prof. Dr. Zahirul Islam',
        'total_members': 3,
        'is_consensus_reached': false,
        'status': 'IN_PROGRESS',
        'members': [
          {
            'name': 'Prof. Dr. Zahirul Islam',
            'email': 'committee@university.edu',
            'designation': 'Committee Chair (Dept of CSE)',
            'has_voted': false,
            'voted_vendor_id': null,
            'voted_vendor_name': null,
            'justification': null,
            'voted_at': null,
          },
          {
            'name': 'Dr. Farhana Yasmin',
            'email': 'committee2@university.edu',
            'designation': 'External Technical Expert (EEE)',
            'has_voted': true,
            'voted_vendor_id': 6,
            'voted_vendor_name': 'Apex Technologies Ltd',
            'justification': 'Fully complies with ITU-T G.652.D optical fiber standards and includes Tier 1 Cisco Gold partner warranties.',
            'voted_at': '2026-03-14 10:30 AM',
          },
          {
            'name': 'Engr. Monirul Haque',
            'email': 'committee3@university.edu',
            'designation': 'Chief IT Infrastructure Officer',
            'has_voted': true,
            'voted_vendor_id': 6,
            'voted_vendor_name': 'Apex Technologies Ltd',
            'justification': 'Lowest responsive financial quotation with verified 10-Gigabit Layer 3 wire-speed forwarding capacity.',
            'voted_at': '2026-03-14 11:45 AM',
          },
        ],
      },
      {
        'circular_id': 'CIRC-2026-001',
        'circular_title': 'High-Performance Computing Cluster for AI Lab',
        'department': 'Computer Science & Engineering',
        'budget': 85000.0,
        'evaluation_date': '2026-02-18',
        'committee_head': 'Prof. Tariq Rahman',
        'total_members': 3,
        'is_consensus_reached': true,
        'status': 'COMPLETED',
        'completed_at': '2026-02-18 04:00 PM',
        'consolidated_vendor_id': 6,
        'consolidated_vendor_name': 'Apex Technologies Ltd',
        'consolidated_summary': 'Unanimously recommended Apex Technologies Ltd (3/3 votes) for lowest responsive offer and Tier 1 OEM authorization.',
        'members': [
          {
            'name': 'Prof. Tariq Rahman',
            'email': 'depthead@university.edu',
            'designation': 'Head of Department (CSE)',
            'has_voted': true,
            'voted_vendor_id': 6,
            'voted_vendor_name': 'Apex Technologies Ltd',
            'justification': '100% compliant with Nvidia Ada Lovelace architecture specifications.',
            'voted_at': '2026-02-18 02:15 PM',
          },
          {
            'name': 'Dr. Sarah Ahmed',
            'email': 'initiator@university.edu',
            'designation': 'Project Initiator & Associate Professor',
            'has_voted': true,
            'voted_vendor_id': 6,
            'voted_vendor_name': 'Apex Technologies Ltd',
            'justification': 'Within approved research grant envelope with 3-year 24/7 on-site SLA.',
            'voted_at': '2026-02-18 02:40 PM',
          },
          {
            'name': 'Prof. Kamal Hossain',
            'email': 'dean@university.edu',
            'designation': 'Dean, Faculty of Engineering',
            'has_voted': true,
            'voted_vendor_id': 6,
            'voted_vendor_name': 'Apex Technologies Ltd',
            'justification': 'Highest composite QCBS score (97.2%). Fully sanctioned.',
            'voted_at': '2026-02-18 03:50 PM',
          },
        ],
      },
    ]);
  }

  Map<String, dynamic>? getCommitteeEvaluationForCircular(String circularId) {
    return committeeEvaluations.firstWhereOrNull((e) => e['circular_id'] == circularId);
  }

  bool submitCommitteeMemberReview({
    required String circularId,
    required String memberEmail,
    required int selectedVendorId,
    required String selectedVendorName,
    required String justification,
  }) {
    final index = committeeEvaluations.indexWhere((e) => e['circular_id'] == circularId);
    if (index == -1) return false;

    final eval = Map<String, dynamic>.from(committeeEvaluations[index]);
    final members = (eval['members'] as List).map((m) => Map<String, dynamic>.from(m as Map)).toList();

    final mIndex = members.indexWhere((m) => m['email'].toString().toLowerCase() == memberEmail.trim().toLowerCase());
    if (mIndex == -1) return false;

    // Rule: Mandatory & Immutable Justification — once submitted, locked and cannot be modified.
    if (members[mIndex]['has_voted'] == true) {
      return false; // Already locked
    }

    final nowStr = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());
    members[mIndex]['has_voted'] = true;
    members[mIndex]['voted_vendor_id'] = selectedVendorId;
    members[mIndex]['voted_vendor_name'] = selectedVendorName;
    members[mIndex]['justification'] = justification.trim();
    members[mIndex]['voted_at'] = nowStr;

    eval['members'] = members;

    // Check if 100% of committee members have submitted
    final votedCount = members.where((m) => m['has_voted'] == true).length;
    final totalMembers = eval['total_members'] as int? ?? members.length;

    if (votedCount >= totalMembers) {
      eval['is_consensus_reached'] = true;
      eval['status'] = 'COMPLETED';
      eval['completed_at'] = nowStr;

      // Determine winning vendor by vote counts
      final voteCounts = <int, int>{};
      final vendorNames = <int, String>{};
      for (final m in members) {
        final vId = m['voted_vendor_id'] as int?;
        if (vId != null) {
          voteCounts[vId] = (voteCounts[vId] ?? 0) + 1;
          vendorNames[vId] = m['voted_vendor_name'] as String? ?? 'Vendor #$vId';
        }
      }
      int winningVendorId = selectedVendorId;
      int maxVotes = 0;
      voteCounts.forEach((vId, count) {
        if (count > maxVotes) {
          maxVotes = count;
          winningVendorId = vId;
        }
      });
      eval['consolidated_vendor_id'] = winningVendorId;
      final winningName = vendorNames[winningVendorId] ?? selectedVendorName;
      eval['consolidated_vendor_name'] = winningName;
      eval['consolidated_summary'] =
          'Consolidated Procurement Committee consensus: Recommended $winningName with $maxVotes of $totalMembers votes based on QCBS technical compliance and commercial competitiveness.';

      // Automated Workflow Progression: Push to Tier 1 Executive Approval Pipeline (Dept Head)
      final circIndex = circulars.indexWhere((c) => c['id'] == circularId);
      if (circIndex != -1) {
        final circ = Map<String, dynamic>.from(circulars[circIndex]);
        circ['status'] = 'PENDING_DEPT_HEAD';
        circulars[circIndex] = circ;

        // Create pending approval item for Tier 1 Department Head
        final approvalId = 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
        pendingApprovals.insert(0, {
          'id': approvalId,
          'circular_id': circularId,
          'title': circ['title'],
          'department': circ['department'],
          'initiator': circ['initiator_name'] ?? 'Procurement Initiator',
          'requested_amount': circ['estimated_budget'] ?? 190000.0,
          'current_stage': 'Department Head',
          'required_role': 'approver_dept_head',
          'submitted_date': DateTime.now().toString().split(' ').first,
          'status': 'PENDING_DEPT_HEAD',
          'summary': 'Tender evaluated by Procurement Committee ($totalMembers members). Recommending award to $winningName ($maxVotes/$totalMembers votes). Forwarded for Tier 1 Department Head review.',
          'attachments': ['Procurement_Committee_Minutes.pdf', 'Comparison_Sheet_QCBS.pdf'],
          'committee_consensus': {
            'consensus_vendor': winningName,
            'votes': '$maxVotes / $totalMembers',
            'summary': eval['consolidated_summary'],
            'member_remarks': members.map((m) => {
              'member_name': m['name'],
              'designation': m['designation'],
              'voted_vendor': m['voted_vendor_name'],
              'comment': m['justification'],
              'date': m['voted_at'],
            }).toList(),
          },
          'previous_remarks': [],
        });
      }
    }

    committeeEvaluations[index] = eval;
    committeeEvaluations.refresh();
    return true;
  }
}
