import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';

class WorkOrderListPage extends StatelessWidget {
  const WorkOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Work Orders & Contracts',
      selectedIndex: 2,
      body: Obx(() {
        final orders = db.workOrders;
        if (orders.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No Work Orders Issued',
            subtitle: 'Awarded tenders will generate work orders here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final wo = orders[index];
            final id = wo['id'] as String? ?? '';
            final title = wo['title'] as String? ?? '';
            final vendorName = wo['vendor_name'] as String? ?? '';
            final amount = (wo['contract_amount'] as num?)?.toDouble() ?? 0.0;
            final statusStr = wo['status'] as String? ?? 'AWARDED';
            final statusEnum = WorkOrderStatus.fromString(statusStr);
            final dept = wo['department'] as String? ?? '';
            final completionDate = wo['expected_completion_date'] as String? ?? '';
            final milestones = (wo['milestones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final completedMilestones = milestones.where((m) => m['completed'] == true).length;
            final progress = milestones.isNotEmpty ? completedMilestones / milestones.length : 0.0;

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
                              Text(id,
                                  style: const TextStyle(
                                      color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Vendor: $vendorName | Dept: $dept',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusChip.fromWorkOrderStatus(statusEnum),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 32,
                      runSpacing: 10,
                      children: [
                        _colStat('Contract Value', currencyFmt.format(amount), isBold: true),
                        _colStat('Target Handover', completionDate),
                        _colStat('Milestones Completed', '$completedMilestones / ${milestones.length}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: progress == 1.0 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: 'Upload Invoice',
                          icon: Icons.receipt_long_outlined,
                          isOutlined: true,
                          onPressed: () => Get.toNamed('/invoices/upload?workOrderId=$id'),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'View Order Details',
                          icon: Icons.assignment_turned_in_outlined,
                          onPressed: () => Get.toNamed('/work-orders/detail?id=$id'),
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

  Widget _colStat(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
