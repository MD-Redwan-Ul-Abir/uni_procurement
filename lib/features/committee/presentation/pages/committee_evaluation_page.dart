import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';

/// Automated Comparison Sheet (CS) & Committee Member Evaluation Page.
/// Implements Section 3.3 and 3.4 of the SMUCT Technical Proposal.
class CommitteeEvaluationPage extends StatefulWidget {
  const CommitteeEvaluationPage({super.key});

  @override
  State<CommitteeEvaluationPage> createState() => _CommitteeEvaluationPageState();
}

class _CommitteeEvaluationPageState extends State<CommitteeEvaluationPage> {
  final _commentController = TextEditingController();
  int? _selectedVendorId;
  String? _selectedVendorName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview({
    required String circularId,
    required String memberEmail,
    required String memberName,
  }) {
    if (_selectedVendorId == null) {
      AppToast.error(
        title: 'Vendor Selection Required',
        description: 'Please select your recommended vendor from the Comparison Sheet.',
        context: context,
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      AppToast.error(
        title: 'Mandatory Justification Required',
        description: 'Every committee member must provide a formal justification comment for their choice.',
        context: context,
      );
      return;
    }

    if (comment.length < 15) {
      AppToast.error(
        title: 'Detailed Justification Required',
        description: 'Please provide a substantive justification (minimum 15 characters).',
        context: context,
      );
      return;
    }

    // Confirmation dialog to emphasize immutability
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_clock, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Confirm Immutable Submission', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are voting to recommend: $_selectedVendorName',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'As specified in Section 3.3 of statutory guidelines, once submitted, your review, vendor selection, and justification comment are permanently locked and cannot be modified.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _executeSubmission(circularId, memberEmail, memberName);
            },
            child: const Text('Confirm & Seal Review'),
          ),
        ],
      ),
    );
  }

  void _executeSubmission(String circularId, String memberEmail, String memberName) {
    final db = Get.find<DummyDatabaseService>();
    setState(() => _isSubmitting = true);

    final success = db.submitCommitteeMemberReview(
      circularId: circularId,
      memberEmail: memberEmail,
      selectedVendorId: _selectedVendorId!,
      selectedVendorName: _selectedVendorName!,
      justification: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      AppToast.success(
        title: 'Review Submitted & Locked',
        description: 'Your official recommendation has been immutably recorded in the institutional audit log.',
        context: context,
      );
    } else {
      AppToast.error(
        title: 'Submission Failed',
        description: 'Could not record review. You may have already submitted a locked vote.',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final circularId = Get.parameters['id'] ?? 'CIRC-2026-003';
    final db = Get.find<DummyDatabaseService>();
    final storage = Get.find<StorageService>();
    final currentUserEmail = storage.userEmail ?? 'committee@university.edu';
    final currencyFmt = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );

    return AdaptiveScaffold(
      title: 'Committee Evaluation & Comparison Sheet',
      selectedIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.print_outlined),
          tooltip: 'Export Evaluation Dossier',
          onPressed: () => AppToast.info(
            title: 'Print / Export',
            description: 'Compiling formatted statutory Comparison Sheet PDF.',
            context: context,
          ),
        ),
      ],
      body: Obx(() {
        final eval = db.getCommitteeEvaluationForCircular(circularId);
        final matrix = db.comparisonMatrices.firstWhereOrNull((m) => m['circular_id'] == circularId) ??
            (db.comparisonMatrices.isNotEmpty ? db.comparisonMatrices.first : null);

        if (eval == null || matrix == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Evaluation dossier not found for $circularId'),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Back to Radar',
                  isOutlined: true,
                  onPressed: () => Get.offNamed('/committee/dashboard'),
                ),
              ],
            ),
          );
        }

        final members = (eval['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final totalMembers = eval['total_members'] as int? ?? members.length;
        final votedCount = members.where((m) => m['has_voted'] == true).length;
        final isConsensusReached = eval['is_consensus_reached'] == true;
        final vendors = (matrix['vendors'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        final currentMember = members.firstWhereOrNull(
          (m) => m['email'].toString().toLowerCase() == currentUserEmail.toLowerCase(),
        );
        final hasCurrentUserVoted = currentMember?['has_voted'] == true;
        final currentMemberName = currentMember?['name'] as String? ?? 'Committee Member';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Breadcrumb Navigation ──
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.toNamed('/committee/dashboard'),
                        child: const Text(
                          'Radar',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Evaluation: $circularId',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Tender Header Card ──
                  _buildTenderHeader(matrix, eval, currencyFmt),
                  const SizedBox(height: 20),

                  // ── Dynamic Committee Progress & Consensus Banner ──
                  _buildConsensusProgressCard(
                    context,
                    members: members,
                    totalMembers: totalMembers,
                    votedCount: votedCount,
                    isConsensusReached: isConsensusReached,
                    eval: eval,
                  ),
                  const SizedBox(height: 24),

                  // ── Automated Comparison Sheet (CS) Section ──
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.table_chart_outlined, color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Automated Comparison Sheet (CS)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Quality & Cost-Based Selection (QCBS) combined technical and financial scores',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Responsive Comparison Cards / Table
                  _buildComparisonMatrixView(context, vendors, currencyFmt),
                  const SizedBox(height: 28),

                  // ── Individual Member Selection & Mandatory Justification Panel ──
                  _buildMemberReviewPanel(
                    context,
                    circularId: circularId,
                    currentUserEmail: currentUserEmail,
                    currentMemberName: currentMemberName,
                    hasCurrentUserVoted: hasCurrentUserVoted,
                    currentMember: currentMember,
                    vendors: vendors,
                  ),
                  const SizedBox(height: 28),

                  // ── All Committee Member Suggestions & Immutable Log ──
                  _buildAllMemberReviewsLog(members),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTenderHeader(
    Map<String, dynamic> matrix,
    Map<String, dynamic> eval,
    NumberFormat currencyFmt,
  ) {
    final title = matrix['circular_title'] as String? ?? 'Tender Title';
    final dept = matrix['department'] as String? ?? 'Department';
    final budget = (matrix['budget'] as num?)?.toDouble() ?? 0.0;
    final evalDate = matrix['evaluation_date'] as String? ?? '2026-03-14';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requisitioning Entity: $dept | Evaluation Session: $evalDate',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _statItem('Approved Budget Ceiling', currencyFmt.format(budget), const Color(0xFF0F172A)),
              _statItem('Evaluation Method', 'QCBS (Quality & Cost)', AppColors.primary),
              _statItem('Committee Size', '${eval['total_members']} Appointed Members', const Color(0xFF059669)),
              _statItem('Quotation Privacy', 'Unsealed Post-Closing Date', const Color(0xFF0891B2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildConsensusProgressCard(
    BuildContext context, {
    required List<Map<String, dynamic>> members,
    required int totalMembers,
    required int votedCount,
    required bool isConsensusReached,
    required Map<String, dynamic> eval,
  }) {
    final progress = totalMembers > 0 ? (votedCount / totalMembers) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isConsensusReached ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConsensusReached ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConsensusReached ? Icons.check_circle : Icons.hourglass_top,
                color: isConsensusReached ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isConsensusReached
                      ? '100% Committee Consensus Finalized — Automated Pipeline Triggered'
                      : 'Committee Evaluation in Progress: $votedCount of $totalMembers Members Submitted',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isConsensusReached ? const Color(0xFF065F46) : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isConsensusReached
                ? 'All $totalMembers committee members have submitted immutable evaluations. Consolidated recommendation is generated and pushed to Tier 1 Executive Approval (Department Head).'
                : 'As mandated by Section 3.3, workflow progression remains paused until 100% of committee members complete their independent review and immutable justification.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isConsensusReached ? const Color(0xFF047857) : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isConsensusReached ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              valueColor: AlwaysStoppedAnimation<Color>(
                isConsensusReached ? AppColors.success : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMatrixView(
    BuildContext context,
    List<Map<String, dynamic>> vendors,
    NumberFormat currencyFmt,
  ) {
    return Column(
      children: vendors.map((v) {
        final name = v['vendor_name'] as String;
        final quoted = (v['quoted_amount'] as num?)?.toDouble() ?? 0.0;
        final diff = (v['difference_from_budget'] as num?)?.toDouble() ?? 0.0;
        final timeline = v['delivery_timeline'] as String? ?? 'N/A';
        final warranty = v['warranty'] as String? ?? 'N/A';
        final techScore = (v['technical_score'] as num?)?.toDouble() ?? 0.0;
        final finScore = (v['financial_score'] as num?)?.toDouble() ?? 0.0;
        final compScore = (v['composite_score'] as num?)?.toDouble() ?? 0.0;
        final rank = v['rank'] as int? ?? 1;
        final status = v['status'] as String? ?? 'Responsive';
        final isRankOne = rank == 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRankOne ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200,
              width: isRankOne ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line: Rank badge, Name, Quoted Price
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isRankOne ? AppColors.primary : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isRankOne ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isRankOne ? const Color(0xFF059669) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFmt.format(quoted),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Text(
                        diff < 0
                            ? '(${currencyFmt.format(diff.abs())} under budget)'
                            : '(+${currencyFmt.format(diff)} over budget)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: diff <= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Breakdown Chips & Metrics
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _metricChip('Technical Score', '$techScore / 100'),
                  _metricChip('Financial Score', '$finScore / 100'),
                  _metricChip('QCBS Composite', '$compScore%', isHighlight: true),
                  _metricChip('Delivery Timeline', timeline),
                  _metricChip('Warranty', warranty),
                ],
              ),
              const SizedBox(height: 12),

              // Technical dossier link
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Text(
                      v['technical_compliance'] as String? ?? 'Compliant with tender requirements',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => AppToast.info(
                      title: 'Bid Dossier',
                      description: 'Viewing technical specifications & commercial bid for $name.',
                      context: context,
                    ),
                    icon: const Icon(Icons.attach_file, size: 15),
                    label: const Text('View Dossier', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _metricChip(String label, String value, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberReviewPanel(
    BuildContext context, {
    required String circularId,
    required String currentUserEmail,
    required String currentMemberName,
    required bool hasCurrentUserVoted,
    required Map<String, dynamic>? currentMember,
    required List<Map<String, dynamic>> vendors,
  }) {
    if (hasCurrentUserVoted) {
      final votedVendorName = currentMember?['voted_vendor_name'] ?? 'Recommended Vendor';
      final justification = currentMember?['justification'] ?? 'No comments provided.';
      final votedAt = currentMember?['voted_at'] ?? 'Timestamped';

      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user, color: AppColors.success, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Your Official Recommendation (Sealed & Immutable)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                  ),
                ),
                Text(
                  votedAt,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Recommended Supplier: $votedVendorName',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF14532D)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Text(
                justification,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.45),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '🔒 In accordance with Section 3.3 audit rules, your submission has been locked and permanently attributed to your credentials.',
              style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
            ),
          ],
        ),
      );
    }

    // Member hasn't voted yet — show voting form
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.how_to_vote, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Individual Committee Member Selection & Justification',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Reviewing as: $currentMemberName ($currentUserEmail)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Select Vendor
          const Text(
            '1. Select Your Recommended Bidder:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          ...vendors.map((v) {
            final vId = v['vendor_id'] as int;
            final vName = v['vendor_name'] as String;
            final isSelected = _selectedVendorId == vId;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedVendorId = vId;
                  _selectedVendorName = vName;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Rank #${v['rank']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // 2. Mandatory Justification Comment
          const Text(
            '2. Mandatory Justification Comment:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Provide formal reasoning explaining your choice based on technical compliance, price competitiveness, and warranty support.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Lowest responsive quotation meeting 100% of single-mode fiber standards with Tier 1 manufacturer authorization...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),

          // Audit Integrity Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mandatory Audit Integrity Notice: Once you click "Submit Official Recommendation", your decision and comments are locked and cannot be edited. The file will automatically progress once 100% of members have voted.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'Submit Official Recommendation',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: () => _submitReview(
                  circularId: circularId,
                  memberEmail: currentUserEmail,
                  memberName: currentMemberName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllMemberReviewsLog(List<Map<String, dynamic>> members) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.people_alt_outlined, color: AppColors.textPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Procurement Committee Member Log & Opinions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          ...members.map((m) {
            final name = m['name'] as String? ?? 'Member';
            final designation = m['designation'] as String? ?? 'Evaluator';
            final hasVoted = m['has_voted'] == true;
            final votedVendor = m['voted_vendor_name'] as String? ?? 'Pending';
            final justification = m['justification'] as String?;
            final votedAt = m['voted_at'] as String? ?? 'Awaiting Review';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hasVoted ? const Color(0xFFF8FAFC) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasVoted ? Colors.grey.shade200 : const Color(0xFFFECACA),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasVoted ? Icons.check_circle : Icons.schedule,
                        size: 16,
                        color: hasVoted ? AppColors.success : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$name ($designation)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        votedAt,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasVoted ? AppColors.textSecondary : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  if (hasVoted) ...[
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Recommended: $votedVendor',
                    //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    // ),
                    // Justification comment commented out as committee members cannot view peer comments:
                    // if (justification != null) ...[
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     '"$justification"',
                    //     style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    //   ),
                    // ],
                  ] else ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Review pending submission by this member.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
