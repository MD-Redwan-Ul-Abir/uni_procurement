import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';

class ApprovalReviewPage extends StatefulWidget {
  const ApprovalReviewPage({super.key});

  @override
  State<ApprovalReviewPage> createState() => _ApprovalReviewPageState();
}

class _ApprovalReviewPageState extends State<ApprovalReviewPage> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleDecision(bool isApprove) async {
    final db = Get.find<DummyDatabaseService>();
    final permission = Get.find<PermissionService>();
    final approvalId = Get.parameters['id'] ?? 'APP-2026-001';

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final approverRole = permission.currentRole?.label ?? 'Approver';
    final user = permission.currentRole != null
        ? db.users.firstWhereOrNull((u) => u['role'] == permission.currentRole!.toApiString())
        : null;
    final approverName = user?['name'] as String? ?? 'Reviewer';

    if (isApprove) {
      db.approveRequest(
        approvalId: approvalId,
        approverName: approverName,
        approverRole: approverRole,
        comments: _commentController.text.trim(),
      );
      AppToast.success(
        title: 'Sanction Approved',
        description: 'Request $approvalId has been approved and forwarded.',
        context: context,
      );
    } else {
      db.rejectRequest(
        approvalId: approvalId,
        approverName: approverName,
        approverRole: approverRole,
        comments: _commentController.text.trim(),
      );
      AppToast.error(
        title: 'Request Rejected',
        description: 'Request $approvalId has been rejected and logged in history.',
        context: context,
      );
    }

    setState(() => _isLoading = false);
    Get.offNamed('/approvals');
  }

  @override
  Widget build(BuildContext context) {
    final approvalId = Get.parameters['id'] ?? 'APP-2026-001';
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    final req = db.pendingApprovals.firstWhereOrNull((a) => a['id'] == approvalId) ??
        (db.pendingApprovals.isNotEmpty ? db.pendingApprovals.first : null);

    if (req == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Approval')),
        body: const Center(child: Text('Approval item not found or already processed.')),
      );
    }

    final prevRemarks = (req['previous_remarks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final amount = (req['requested_amount'] as num?)?.toDouble() ?? 0.0;
    final committeeEval = db.getCommitteeEvaluationForCircular(req['circular_id'] as String? ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text('Review: ${req['id']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.rate_review_outlined, color: AppColors.warning, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                req['title'] ?? '',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 32,
                          runSpacing: 12,
                          children: [
                            _stat('Requested Sanction', currencyFmt.format(amount), AppColors.primary),
                            _stat('Department', req['department'] ?? '', AppColors.textPrimary),
                            _stat('Current Tier', req['current_stage'] ?? '', AppColors.warning),
                            _stat('Initiator', req['initiator'] ?? '', AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Executive Summary:',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req['summary'] ?? '',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Consolidated Committee Suggestion (Section 3.3 & 3.4)
                if (committeeEval != null && committeeEval['is_consensus_reached'] == true) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.success, width: 1.5),
                    ),
                    color: AppColors.success.withValues(alpha: 0.04),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.gavel_rounded, color: AppColors.success, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Consolidated Committee Suggestion',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '100% Consensus',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Recommended Bidder: ${committeeEval['consolidated_vendor_name'] ?? 'Vendor'}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            committeeEval['consolidated_summary'] ?? 'Evaluation complete.',
                            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          const Text(
                            'Committee Members Immutable Votes & Comments:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          ...((committeeEval['members'] as List?)?.cast<Map<String, dynamic>>() ?? []).map((m) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check, size: 14, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                                        children: [
                                          TextSpan(
                                            text: '${m['name']}: ',
                                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                          ),
                                          TextSpan(text: '"${m['justification'] ?? 'Endorsed'}"'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => Get.toNamed('/circulars/${req['circular_id']}/matrix'),
                              icon: const Icon(Icons.analytics_outlined, size: 16),
                              label: const Text('Open QCBS Comparison Sheet'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Previous Tier Approvals & Remarks
                if (prevRemarks.isNotEmpty) ...[
                  Text('Previous Tier Endorsements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...prevRemarks.map((r) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                const SizedBox(width: 8),
                                Text(
                                  '${r['role']} — ${r['name']}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const Spacer(),
                                Text(r['date'] ?? '',
                                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"${r['comment']}"',
                              style: TextStyle(
                                  fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Action / Decision Box
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Formal Decision & Remarks',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter approval notes, allocation codes or justification...',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              label: 'Reject Request',
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              isLoading: _isLoading,
                              onPressed: () => _handleDecision(false),
                            ),
                            const SizedBox(width: 12),
                            AppButton(
                              label: 'Approve & Sanction',
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              icon: Icons.check,
                              isLoading: _isLoading,
                              onPressed: () => _handleDecision(true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
