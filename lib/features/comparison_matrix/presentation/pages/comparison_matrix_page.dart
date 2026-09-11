import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';

class ComparisonMatrixPage extends StatelessWidget {
  const ComparisonMatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    final circularId = Get.parameters['id'] ?? 'CIRC-2026-001';
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    final matrix = db.comparisonMatrices.firstWhereOrNull((m) => m['circular_id'] == circularId) ??
        (db.comparisonMatrices.isNotEmpty ? db.comparisonMatrices.first : null);

    if (matrix == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparison Matrix')),
        body: const Center(child: Text('No comparison matrix available for this tender yet.')),
      );
    }

    final vendors = (matrix['vendors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final title = matrix['circular_title'] as String? ?? 'Tender Comparison';
    final budget = (matrix['budget'] as num?)?.toDouble() ?? 0.0;
    final committee = matrix['committee_head'] as String? ?? 'Evaluation Committee';
    final evalDate = matrix['evaluation_date'] as String? ?? '2026-02-18';

    return Scaffold(
      appBar: AppBar(
        title: Text('Comparison Matrix: ${matrix['circular_id']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => AppToast.info(
              title: 'Print',
              description: 'Preparing printable evaluation matrix report',
              context: context,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
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
                              child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Evaluated by: $committee | Date: $evalDate',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 32,
                          runSpacing: 16,
                          children: [
                            _summaryStat('Approved Budget', currencyFmt.format(budget), AppColors.primary),
                            _summaryStat('Bidders Evaluated', '${vendors.length} Vendors', AppColors.info),
                            _summaryStat('Evaluation Method', 'Quality & Cost-Based (QCBS)', AppColors.textPrimary),
                            _summaryStat('Recommended Award', vendors.isNotEmpty ? vendors.first['vendor_name'] : 'N/A', AppColors.success),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Comparison Data Table
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
                        Text('Comparative Scoring & Ranking',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.05)),
                            border: TableBorder.all(color: AppColors.border, width: 1),
                            columns: const [
                              DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Vendor Name', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Quoted Price', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Diff from Budget', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Tech Score', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Financial Score', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Composite Score', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Delivery', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Warranty', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Evaluation Result', style: TextStyle(fontWeight: FontWeight.w700))),
                            ],
                            rows: vendors.map((v) {
                              final rank = v['rank'] as int? ?? 1;
                              final isWinner = rank == 1;
                              final quote = (v['quoted_amount'] as num?)?.toDouble() ?? 0.0;
                              final diff = (v['difference_from_budget'] as num?)?.toDouble() ?? 0.0;

                              return DataRow(
                                color: isWinner
                                    ? WidgetStateProperty.all(AppColors.success.withValues(alpha: 0.05))
                                    : null,
                                cells: [
                                  DataCell(
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: isWinner ? AppColors.success : AppColors.border,
                                      child: Text('$rank',
                                          style: TextStyle(
                                              color: isWinner ? Colors.white : AppColors.textPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  DataCell(Text(v['vendor_name'] ?? '',
                                      style: TextStyle(fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500))),
                                  DataCell(Text(currencyFmt.format(quote),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isWinner ? AppColors.success : AppColors.textPrimary))),
                                  DataCell(Text(
                                    '${diff <= 0 ? '-' : '+'}${currencyFmt.format(diff.abs())}',
                                    style: TextStyle(
                                        color: diff <= 0 ? AppColors.success : AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  )),
                                  DataCell(Text('${v['technical_score'] ?? '-'}%')),
                                  DataCell(Text('${v['financial_score'] ?? '-'}%')),
                                  DataCell(Text('${v['composite_score'] ?? '-'}%',
                                      style: const TextStyle(fontWeight: FontWeight.w700))),
                                  DataCell(Text(v['delivery_timeline'] ?? '')),
                                  DataCell(Text(v['warranty'] ?? '')),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isWinner
                                            ? AppColors.success.withValues(alpha: 0.12)
                                            : AppColors.border.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        v['status'] ?? '',
                                        style: TextStyle(
                                          color: isWinner ? AppColors.success : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Committee Recommendation Box
                if (vendors.isNotEmpty)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.success, width: 1.5),
                    ),
                    color: AppColors.success.withValues(alpha: 0.04),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.verified, color: AppColors.success, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Formal Committee Recommendation',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Based on the QCBS combined score of 97.2%, ${vendors.first['vendor_name']} is evaluated as the lowest responsive and technically superior bidder for ${currencyFmt.format(vendors.first['quoted_amount'])}. The committee recommends sanctioning the award.',
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppButton(
                                label: 'Open Approval Tracker',
                                icon: Icons.track_changes_outlined,
                                isOutlined: true,
                                onPressed: () => Get.toNamed('/approvals/tracker?id=${matrix['circular_id']}'),
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

  Widget _summaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
