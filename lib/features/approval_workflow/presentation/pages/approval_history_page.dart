import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';

class ApprovalHistoryPage extends StatelessWidget {
  const ApprovalHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Approval Audit History',
      selectedIndex: 1,
      body: Obx(() {
        final history = db.approvalHistory;
        if (history.isEmpty) {
          return const EmptyState(
            icon: Icons.history_outlined,
            title: 'No Approval History',
            subtitle: 'Past approval actions will be recorded here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = history[index];
            final id = item['id'] as String? ?? '';
            final title = item['title'] as String? ?? '';
            final approverName = item['approver_name'] as String? ?? '';
            final approverRole = item['approver_role'] as String? ?? '';
            final action = item['action'] as String? ?? 'APPROVED';
            final date = item['date'] as String? ?? '';
            final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
            final comment = item['comment'] as String? ?? '';

            final isApproved = action == 'APPROVED';

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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isApproved ? Icons.check : Icons.close,
                            size: 18,
                            color: isApproved ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    action,
                                    style: TextStyle(
                                      color: isApproved ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('• $id', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                  const Spacer(),
                                  Text(date, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                'Decided by: $approverName ($approverRole) | Amount: ${currencyFmt.format(amount)}',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"$comment"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                        ),
                      ),
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
