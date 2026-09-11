import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Procurement Committee Evaluation Workspace / Dashboard.
/// Implements Section 3.3 of SMUCT Technical Proposal:
/// Dedicated Procurement Committee Evaluation Module.
class CommitteeDashboardPage extends StatelessWidget {
  const CommitteeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Procurement Committee Dashboard',
      selectedIndex: 0,
      body: Obx(() {
        final db = Get.find<DummyDatabaseService>();
        final storage = Get.find<StorageService>();
        final currentUserEmail = storage.userEmail ?? 'committee@university.edu';
        final currencyFmt = NumberFormat.currency(
          symbol: AppConstants.currencySymbol,
          decimalDigits: 0,
        );

        final evaluations = db.committeeEvaluations;
        final inProgressList = evaluations.where((e) => e['status'] == 'IN_PROGRESS').toList();
        final completedList = evaluations.where((e) => e['status'] == 'COMPLETED').toList();

        // Count reviews pending for the current member
        int pendingMyVote = 0;
        for (final eval in inProgressList) {
          final members = (eval['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final currentMember = members.firstWhereOrNull(
            (m) => m['email'].toString().toLowerCase() == currentUserEmail.toLowerCase(),
          );
          if (currentMember != null && currentMember['has_voted'] != true) {
            pendingMyVote++;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Banner ──
                  _buildHeaderBanner(context),
                  const SizedBox(height: 24),

                  // ── KPI Summary Cards ──
                  _buildKpiMetrics(
                    context,
                    totalAssigned: evaluations.length,
                    activeReview: inProgressList.length,
                    pendingMyVote: pendingMyVote,
                    consensusReached: completedList.length,
                  ),
                  const SizedBox(height: 28),

                  // ── Active Tender Evaluation Queue ──
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            'Active Committee Evaluation Radar',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${inProgressList.length} Active',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (inProgressList.isEmpty)
                    _buildEmptyQueueCard('No tenders currently pending committee evaluation.')
                  else
                    ...inProgressList.map((eval) => _buildEvaluationCard(
                          context,
                          eval: eval,
                          currentUserEmail: currentUserEmail,
                          currencyFmt: currencyFmt,
                        )),

                  const SizedBox(height: 32),

                  // ── Concluded Evaluations / Consensus Archive ──
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Concluded Evaluations & Consensus Archive',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (completedList.isEmpty)
                    _buildEmptyQueueCard('No completed evaluations in this session yet.')
                  else
                    ...completedList.map((eval) => _buildCompletedCard(
                          context,
                          eval: eval,
                          currencyFmt: currencyFmt,
                        )),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF091E47),
            Color(0xFF143B80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF091E47).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ResponsiveBuilder(
        desktop: (_) => _bannerContent(isDesktop: true),
        tablet: (_) => _bannerContent(isDesktop: false),
        mobile: (_) => _bannerContent(isDesktop: false),
      ),
    );
  }

  Widget _bannerContent({required bool isDesktop}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.gavel, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Procurement Committee Evaluation Workspace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Confidential Quality & Cost-Based Selection (QCBS) ranking, independent member reviews, mandatory justification logs, and automated multi-tier consensus progression.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiMetrics(
    BuildContext context, {
    required int totalAssigned,
    required int activeReview,
    required int pendingMyVote,
    required int consensusReached,
  }) {
    return ResponsiveBuilder(
      desktop: (_) => Row(
        children: [
          Expanded(child: _kpiTile('Assigned Projects', '$totalAssigned', Icons.assignment_outlined, const Color(0xFF1D4ED8), const Color(0xFFEFF6FF))),
          const SizedBox(width: 16),
          Expanded(child: _kpiTile('In Active Review', '$activeReview', Icons.sync_outlined, const Color(0xFFD97706), const Color(0xFFFFFBEB))),
          const SizedBox(width: 16),
          Expanded(child: _kpiTile('Awaiting Your Vote', '$pendingMyVote', Icons.how_to_vote_outlined, const Color(0xFFDC2626), const Color(0xFFFEF2F2))),
          const SizedBox(width: 16),
          Expanded(child: _kpiTile('Consensus Finalized', '$consensusReached', Icons.task_alt, const Color(0xFF059669), const Color(0xFFECFDF5))),
        ],
      ),
      tablet: (_) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(width: 260, child: _kpiTile('Assigned Projects', '$totalAssigned', Icons.assignment_outlined, const Color(0xFF1D4ED8), const Color(0xFFEFF6FF))),
          SizedBox(width: 260, child: _kpiTile('In Active Review', '$activeReview', Icons.sync_outlined, const Color(0xFFD97706), const Color(0xFFFFFBEB))),
          SizedBox(width: 260, child: _kpiTile('Awaiting Your Vote', '$pendingMyVote', Icons.how_to_vote_outlined, const Color(0xFFDC2626), const Color(0xFFFEF2F2))),
          SizedBox(width: 260, child: _kpiTile('Consensus Finalized', '$consensusReached', Icons.task_alt, const Color(0xFF059669), const Color(0xFFECFDF5))),
        ],
      ),
      mobile: (_) => Column(
        children: [
          _kpiTile('Assigned Projects', '$totalAssigned', Icons.assignment_outlined, const Color(0xFF1D4ED8), const Color(0xFFEFF6FF)),
          const SizedBox(height: 10),
          _kpiTile('In Active Review', '$activeReview', Icons.sync_outlined, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
          const SizedBox(height: 10),
          _kpiTile('Awaiting Your Vote', '$pendingMyVote', Icons.how_to_vote_outlined, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
          const SizedBox(height: 10),
          _kpiTile('Consensus Finalized', '$consensusReached', Icons.task_alt, const Color(0xFF059669), const Color(0xFFECFDF5)),
        ],
      ),
    );
  }

  Widget _kpiTile(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(
    BuildContext context, {
    required Map<String, dynamic> eval,
    required String currentUserEmail,
    required NumberFormat currencyFmt,
  }) {
    final circularId = eval['circular_id'] as String;
    final title = eval['circular_title'] as String? ?? 'Procurement Tender';
    final dept = eval['department'] as String? ?? 'Department';
    final budget = (eval['budget'] as num?)?.toDouble() ?? 0.0;
    final members = (eval['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalMembers = eval['total_members'] as int? ?? members.length;
    final votedMembers = members.where((m) => m['has_voted'] == true).length;
    final progress = totalMembers > 0 ? (votedMembers / totalMembers) : 0.0;

    final currentMember = members.firstWhereOrNull(
      (m) => m['email'].toString().toLowerCase() == currentUserEmail.toLowerCase(),
    );
    final userHasVoted = currentMember?['has_voted'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: userHasVoted ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.4),
          width: userHasVoted ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badges & Budget
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      circularId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'IN COMMITTEE REVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Budget: ${currencyFmt.format(budget)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Department
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Requisition Faculty / Division: $dept',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Committee Progress Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Consensus: $votedMembers/$totalMembers Reviewed (${(progress * 100).toInt()}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              if (userHasVoted)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Your Vote Recorded',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ],
                )
              else
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending_actions, size: 14, color: Color(0xFFDC2626)),
                    SizedBox(width: 4),
                    Text(
                      'Your Review Required',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : const Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Committee Members Status Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.map((m) {
              final hasVoted = m['has_voted'] == true;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: hasVoted ? const Color(0xFFECFDF5) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasVoted ? const Color(0xFFA7F3D0) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasVoted ? Icons.check_circle : Icons.schedule,
                      size: 14,
                      color: hasVoted ? const Color(0xFF059669) : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m['name'] as String? ?? 'Member',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasVoted ? const Color(0xFF065F46) : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Action Button Row
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AppButton(
                  label: userHasVoted ? 'Inspect Comparison Sheet' : 'Open Comparison Sheet & Vote',
                  icon: userHasVoted ? Icons.visibility_outlined : Icons.how_to_vote_outlined,
                  onPressed: () => Get.toNamed('/committee/evaluation/$circularId'),
                  isOutlined: userHasVoted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(
    BuildContext context, {
    required Map<String, dynamic> eval,
    required NumberFormat currencyFmt,
  }) {
    final circularId = eval['circular_id'] as String;
    final title = eval['circular_title'] as String? ?? 'Tender';
    final dept = eval['department'] as String? ?? 'Department';
    final winner = eval['consolidated_vendor_name'] as String? ?? 'Winning Vendor';
    final summary = eval['consolidated_summary'] as String? ?? 'Consensus finalized.';
    final completedAt = eval['completed_at'] as String? ?? 'Recently';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      circularId,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '100% CONSENSUS REACHED',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
              Text(
                completedAt,
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(dept, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified, color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consolidated Recommendation: $winner',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Get.toNamed('/committee/evaluation/$circularId'),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text('View Official Comparison Sheet'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueueCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
