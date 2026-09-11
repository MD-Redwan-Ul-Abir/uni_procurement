import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Vendor-specific circular detail — read-only view with Submit Bid CTA.
/// No edit/delete actions (those are initiator-only).
class VendorCircularDetailPage extends StatelessWidget {
  const VendorCircularDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final circularId = Get.parameters['id'] ?? '';
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Circular Details',
      selectedIndex: 1,
      body: Obx(() {
        // Find the circular from the database.
        final circular = db.circulars.firstWhereOrNull(
          (c) => c['id'].toString() == circularId,
        );

        if (circular == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'Circular not found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final title = circular['title'] ?? 'Untitled';
        final dept = circular['department'] ?? '';
        final description = circular['description'] ?? 'No description available.';
        final budget = circular['estimated_budget'] as num?;
        final deadline = circular['deadline'] ?? '';
        final status = (circular['status'] ?? 'PUBLISHED').toString().toUpperCase();
        final bidsCount = circular['bid_count'] as int? ?? 0;
        final requirements =
            (circular['requirements'] as List?)?.cast<String>() ?? [];
        final documents =
            (circular['required_documents'] as List?)?.cast<String>() ?? [];

        // Get detail data if available.
        final detailData = db.circularDetails[circularId] as Map<String, dynamic>?;
        final items = (detailData?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        final canBid = status == 'PUBLISHED';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: canBid
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            canBid ? 'Open for Bids' : status,
                            style: TextStyle(
                              color:
                                  canBid ? AppColors.success : AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'ID: $circularId',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dept.toString(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (budget != null)
                          _MetaItem(
                            icon: Icons.payments_outlined,
                            label: 'Budget',
                            value: currencyFmt.format(budget),
                          ),
                        if (deadline.toString().isNotEmpty)
                          _MetaItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Deadline',
                            value: deadline.toString(),
                          ),
                        _MetaItem(
                          icon: Icons.people_outline,
                          label: 'Bids',
                          value: '$bidsCount submitted',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description.
              _SectionHeader(title: 'Description'),
              const SizedBox(height: 12),
              Text(
                description.toString(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              // Items table (if detail data available).
              if (items.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHeader(title: 'Required Items'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.3)),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBg,
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Item',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Qty',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Unit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        ...items.map((item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    item['name']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    item['quantity']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    item['unit']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ],

              // Requirements.
              if (requirements.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHeader(title: 'Requirements'),
                const SizedBox(height: 12),
                ...requirements.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Required documents.
              if (documents.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHeader(title: 'Required Documents'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: documents
                      .map((d) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.info.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 16, color: AppColors.info),
                                const SizedBox(width: 6),
                                Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 36),

              // CTA: Submit Bid.
              if (canBid)
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Submit Your Bid',
                    icon: Icons.gavel,
                    onPressed: () =>
                        Get.toNamed('/circulars/$circularId/bid'),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This circular is currently in $status status and is not accepting bids.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
