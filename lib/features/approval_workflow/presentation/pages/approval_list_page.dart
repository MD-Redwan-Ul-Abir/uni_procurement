import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class ApprovalListPage extends StatelessWidget {
  const ApprovalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final permission = Get.find<PermissionService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Pending Approvals',
      selectedIndex: 0,
      body: Obx(() {
        final currentRole = permission.currentRole;
        final roleKey = currentRole != null ? currentRole.toApiString() : 'approver_dept_head';
        final items = db.getPendingApprovalsForRole(roleKey);

        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.done_all_outlined,
            title: 'All Clear! No Pending Approvals',
            subtitle: 'You have no requisitions or awards awaiting your decision.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final app = items[index];
            final id = app['id'] as String? ?? '';
            final title = app['title'] as String? ?? '';
            final dept = app['department'] as String? ?? '';
            final initiator = app['initiator'] as String? ?? '';
            final amount = (app['requested_amount'] as num?)?.toDouble() ?? 0.0;
            final date = app['submitted_date'] as String? ?? '';
            final stage = app['current_stage'] as String? ?? 'Stage';
            final summary = app['summary'] as String? ?? '';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Awaiting: $stage',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Requisitioned by: $initiator ($dept)',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Amount', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            const SizedBox(height: 2),
                            Text(
                              currencyFmt.format(amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      summary,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        Text('Submitted: $date',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Spacer(),
                        AppButton(
                          label: 'Track',
                          icon: Icons.track_changes_outlined,
                          isOutlined: true,
                          onPressed: () => Get.toNamed('/approvals/tracker?id=${app['circular_id']}'),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Review & Decision',
                          icon: Icons.rate_review_outlined,
                          onPressed: () => Get.toNamed('/approvals/review?id=$id'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
