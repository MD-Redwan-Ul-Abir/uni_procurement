import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';

class ApprovalTrackerPage extends StatelessWidget {
  const ApprovalTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final circularId = Get.parameters['id'] ?? 'CIRC-2026-001';
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final tracker = db.approvalTrackers[circularId] as Map<String, dynamic>? ??
        (db.approvalTrackers.isNotEmpty ? db.approvalTrackers.values.first as Map<String, dynamic> : null);

    if (tracker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Approval Tracker')),
        body: const Center(child: Text('No workflow tracker found for this tender.')),
      );
    }

    final title = tracker['title'] as String? ?? 'Procurement Workflow';
    final amount = (tracker['total_amount'] as num?)?.toDouble() ?? 0.0;
    final steps = (tracker['steps'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Workflow Tracker: $circularId'),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.track_changes_outlined, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('Tender Ref: $circularId | Sanction Value: ${currencyFmt.format(amount)}',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Vertical Stepper Timeline
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
                        Text('Approval Hierarchy Progress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 24),
                        ...List.generate(steps.length, (index) {
                          final step = steps[index];
                          final isLast = index == steps.length - 1;
                          final status = step['status'] as String? ?? 'PENDING';
                          final isCompleted = status == 'COMPLETED';
                          final isInProgress = status == 'IN_PROGRESS';

                          Color stepColor = AppColors.border;
                          IconData stepIcon = Icons.circle_outlined;
                          if (isCompleted) {
                            stepColor = AppColors.success;
                            stepIcon = Icons.check;
                          } else if (isInProgress) {
                            stepColor = AppColors.warning;
                            stepIcon = Icons.hourglass_top;
                          }

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step Indicator Column
                                Column(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.success
                                            : isInProgress
                                                ? AppColors.warning.withValues(alpha: 0.15)
                                                : AppColors.border.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: stepColor, width: 2),
                                      ),
                                      child: Icon(
                                        stepIcon,
                                        size: 16,
                                        color: isCompleted
                                            ? Colors.white
                                            : isInProgress
                                                ? AppColors.warning
                                                : AppColors.textTertiary,
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isCompleted ? AppColors.success : AppColors.border,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // Step Details Content
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              step['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isInProgress ? AppColors.primary : AppColors.textPrimary,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (step['date'] != null)
                                              Text(
                                                step['date'] as String,
                                                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Assigned to: ${step['assigned_to']} (${step['role']})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          step['note'] ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
}
