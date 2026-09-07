import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_chip.dart';

class WorkOrderDetailPage extends StatelessWidget {
  const WorkOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.parameters['id'] ?? 'WO-2026-001';
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final wo = db.workOrders.firstWhereOrNull((w) => w['id'] == orderId) ??
        (db.workOrders.isNotEmpty ? db.workOrders.first : null);

    if (wo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Work Order Details')),
        body: const Center(child: Text('Work order not found.')),
      );
    }

    final statusEnum = WorkOrderStatus.fromString(wo['status'] as String? ?? 'AWARDED');
    final milestones = (wo['milestones'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Work Order: ${wo['id']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => AppToast.info(
              title: 'Downloaded',
              description: 'Official signed Work Order contract PDF saved',
              context: context,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(wo['title'] ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Contractor: ${wo['vendor_name']} | Dept: ${wo['department']}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusChip.fromWorkOrderStatus(statusEnum),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 32,
                          runSpacing: 16,
                          children: [
                            _statTile('Contract Value', currencyFmt.format(wo['contract_amount']), AppColors.primary),
                            _statTile('Issued Date', wo['issue_date'] ?? '', AppColors.textPrimary),
                            _statTile('Expected Completion', wo['expected_completion_date'] ?? '', AppColors.warning),
                            _statTile('Actual Delivery', wo['actual_delivery_date'] ?? 'In Progress', AppColors.info),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Deliverable Scope Summary
                Card(
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
                          children: const [
                            Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text('Scope Summary & Terms', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          wo['scope_summary'] ?? '',
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Authorized Vendor Contact: ${wo['contact_person']}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Project Milestones
                Card(
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
                          children: const [
                            Icon(Icons.flag_outlined, size: 20, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text('Delivery Milestones & Stages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...milestones.map((m) {
                          final isDone = m['completed'] == true;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.success.withValues(alpha: 0.12)
                                        : AppColors.border.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDone ? Icons.check : Icons.hourglass_empty,
                                    size: 16,
                                    color: isDone ? AppColors.success : AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    m['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: 13,
                                      color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Text(
                                  m['date'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDone ? AppColors.success : AppColors.textTertiary,
                                    fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer Actions
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: 'Track Tender Workflow',
                          icon: Icons.track_changes_outlined,
                          isOutlined: true,
                          onPressed: () => Get.toNamed('/approvals/tracker?id=${wo['circular_id']}'),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: 'Submit Bill / Invoice',
                          icon: Icons.receipt_long_outlined,
                          onPressed: () => Get.toNamed('/invoices/upload?workOrderId=${wo['id']}'),
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

  Widget _statTile(String label, String value, Color color) {
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
