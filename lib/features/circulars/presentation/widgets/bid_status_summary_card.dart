import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/bid_compliance_service.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Live status summary of bids for a circular, strictly categorized into:
/// 1. Bid Submitted
/// 2. Bid Pending
/// 3. Bid Waiting
///
/// Strictly enforces compliance: vendor offer prices remain confidential
/// before the closing date for all users. After deadline expiry, prices
/// are accessible only by authorized users and the Procurement Committee.
class BidStatusSummaryCard extends StatelessWidget {
  final String circularId;
  final String? submissionDeadline;

  const BidStatusSummaryCard({
    super.key,
    required this.circularId,
    this.submissionDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final permission = Get.find<PermissionService>();
    final currencyFmt = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );

    return Obx(() {
      // Fetch circular to ensure accurate deadline
      final circular = db.getCircularById(circularId) ??
          db.circulars.firstWhereOrNull((c) => c['id'].toString() == circularId);
      final deadline = submissionDeadline ??
          circular?['submission_deadline'] ??
          circular?['deadline'] ??
          'TBD';

      // Reactive bids for this circular
      final bids = db.bids
          .where((b) => b['circular_id'].toString() == circularId)
          .toList();

      final categoryCounts = BidComplianceService.getCategoryCounts(bids);
      final isExpired = BidComplianceService.isDeadlineExpired(deadline);
      final canViewPrices = BidComplianceService.canViewBidPrices(
        deadline: deadline,
        role: permission.currentRole,
      );

      final submittedCount = categoryCounts[BidStatusCategory.bidSubmitted] ?? 0;
      final pendingCount = categoryCounts[BidStatusCategory.bidPending] ?? 0;
      final waitingCount = categoryCounts[BidStatusCategory.bidWaiting] ?? 0;
      final totalBids = bids.length;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isExpired
                ? AppColors.info.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title and Live Badge
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 620;
                  final totalBadge = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Total: $totalBids ${totalBids == 1 ? 'Bid' : 'Bids'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Bid Live Status & Compliance Summary',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Strict 3-tier categorization & automated sealed bid confidentiality protocol',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                            if (isCompact) ...[
                              const SizedBox(height: 8),
                              totalBadge,
                            ],
                          ],
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: 12),
                        totalBadge,
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Compliance Protocol Notice Banner
              _buildComplianceBanner(context, isExpired, canViewPrices, deadline),

              const SizedBox(height: 20),

              // 3 Strict Category KPI Metric Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildCategoryKpi(
                          title: 'Bid Submitted',
                          count: submittedCount,
                          subtitle: 'Formally received & registered',
                          icon: Icons.mark_email_read_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryKpi(
                          title: 'Bid Pending',
                          count: pendingCount,
                          subtitle: 'Under technical / eligibility review',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.warning,
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryKpi(
                          title: 'Bid Waiting',
                          count: waitingCount,
                          subtitle: 'Awaiting committee evaluation / award',
                          icon: Icons.access_time_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _buildCategoryKpi(
                          title: 'Bid Submitted',
                          count: submittedCount,
                          subtitle: 'Formally received & registered',
                          icon: Icons.mark_email_read_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildCategoryKpi(
                          title: 'Bid Pending',
                          count: pendingCount,
                          subtitle: 'Under technical / eligibility review',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildCategoryKpi(
                          title: 'Bid Waiting',
                          count: waitingCount,
                          subtitle: 'Awaiting committee evaluation / award',
                          icon: Icons.access_time_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Bids Breakdown Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.table_chart_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Submitted Quotations & Bids Log',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!canViewPrices)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock_outline, size: 13, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text(
                            'Financials Sealed',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Bids Table or Empty State
              if (bids.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'No bids currently recorded for this published circular.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                _buildBidsTable(context, bids, canViewPrices, currencyFmt, deadline, permission.currentRole),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildComplianceBanner(
    BuildContext context,
    bool isExpired,
    bool canViewPrices,
    String deadline,
  ) {
    if (!isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB), // warm amber tint
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lock_clock_outlined,
              color: Color(0xFFD97706),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sealed Bid Confidentiality Protocol Active (Closing Date: $deadline)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'To maintain strict compliance, vendor offer prices remain absolutely confidential before the Bid Closing Date and cannot be viewed by any user. Quotations will unseal automatically after the deadline.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFB45309),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Deadline Expired
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: canViewPrices
            ? const Color(0xFFF0FDF4) // soft emerald tint
            : const Color(0xFFEFF6FF), // soft blue tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: canViewPrices
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            canViewPrices ? Icons.lock_open_rounded : Icons.verified_user_outlined,
            color: canViewPrices ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canViewPrices
                      ? 'Bid Closing Deadline Expired: Quotations Unsealed ($deadline)'
                      : 'Bid Closing Deadline Officially Expired ($deadline)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: canViewPrices ? const Color(0xFF166534) : const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  canViewPrices
                      ? 'Actual financial quotations and bid details are now accessible to authorized personnel and the Procurement Committee.'
                      : 'Actual financial quotations and bid details may only be accessed by authorized users (and the Procurement Committee) in accordance with system permissions.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: canViewPrices ? const Color(0xFF15803D) : const Color(0xFF1D4ED8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryKpi({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsTable(
    BuildContext context,
    List<Map<String, dynamic>> bids,
    bool canViewPrices,
    NumberFormat currencyFmt,
    String deadline,
    dynamic role,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 700),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primary.withValues(alpha: 0.04),
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              dataTextStyle: const TextStyle(fontSize: 12.5),
              horizontalMargin: 16,
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Bid ID')),
                DataColumn(label: Text('Vendor / Bidder')),
                DataColumn(label: Text('Submission Date')),
                DataColumn(label: Text('Live Category')),
                DataColumn(label: Text('Offer Price (Quotation)')),
                DataColumn(label: Text('Delivery')),
              ],
              rows: bids.map((bid) {
                final bidId = bid['id'] as String? ?? '';
                final vendorName = bid['vendor_name'] as String? ?? 'Vendor';
                final date = bid['submission_date'] as String? ?? '';
                final days = bid['delivery_days'] ?? 30;
                final amount = (bid['quoted_amount'] as num?)?.toDouble() ?? 0.0;
                final category = BidComplianceService.categorizeBid(bid);

                Color catColor = AppColors.primary;
                if (category == BidStatusCategory.bidPending) catColor = AppColors.warning;
                if (category == BidStatusCategory.bidWaiting) catColor = const Color(0xFF7C3AED);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        bidId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        vendorName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(date)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: catColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          category.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      canViewPrices
                          ? Text(
                              currencyFmt.format(amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.border,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    size: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    BidComplianceService.getPriceMaskText(
                                      deadline: deadline,
                                      role: role,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    DataCell(Text('$days Days')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
