import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/bid_compliance_service.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Modern, minimalistic, and fully responsive live status summary of bids.
///
/// Strictly categorizes bids into:
/// 1. Bid Submitted
/// 2. Bid Pending
/// 3. Bid Waiting
///
/// Enforces procurement compliance: vendor offer prices remain confidential
/// before the closing date for all users. After deadline expiry, prices
/// are unsealed only for authorized users and the Procurement Committee.
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
      final circular = db.getCircularById(circularId) ??
          db.circulars.firstWhereOrNull((c) => c['id'].toString() == circularId);
      final deadline = submissionDeadline ??
          circular?['submission_deadline'] ??
          circular?['deadline'] ??
          'TBD';

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

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title, Live indicator, and Total badge
            _buildHeader(context, totalBids),

            const SizedBox(height: 18),

            // Minimalist Compliance Protocol Callout
            _buildComplianceCallout(context, isExpired, canViewPrices, deadline),

            const SizedBox(height: 20),

            // 3-Column Strict Category Metric Tiles
            _buildCategoryMetrics(submittedCount, pendingCount, waitingCount),

            const SizedBox(height: 24),

            // Section Divider
            const Divider(height: 1, color: AppColors.borderLight),

            const SizedBox(height: 20),

            // Quotations Log Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Submitted Quotations & Bids Log',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: canViewPrices
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        canViewPrices ? Icons.lock_open_rounded : Icons.lock_outline,
                        size: 13,
                        color: canViewPrices ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        canViewPrices ? 'Financials Unsealed' : 'Financials Sealed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: canViewPrices ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Responsive Bids Log (Table for desktop, Cards for mobile)
            if (bids.isEmpty)
              _buildEmptyState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 680;
                  if (isDesktop) {
                    return _buildDesktopBidsTable(
                      context,
                      bids,
                      canViewPrices,
                      currencyFmt,
                      deadline,
                      permission.currentRole,
                    );
                  } else {
                    return _buildMobileBidsList(
                      context,
                      bids,
                      canViewPrices,
                      currencyFmt,
                      deadline,
                      permission.currentRole,
                    );
                  }
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, int totalBids) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final totalBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              color: AppColors.textPrimary,
            ),
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security_outlined,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  const SizedBox(height: 3),
                  const Text(
                    'Strict 3-tier categorization & automated sealed bid confidentiality protocol',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
    );
  }

  Widget _buildComplianceCallout(
    BuildContext context,
    bool isExpired,
    bool canViewPrices,
    String deadline,
  ) {
    final bgColor = !isExpired
        ? const Color(0xFFFFFBEB)
        : (canViewPrices ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF));
    final borderColor = !isExpired
        ? const Color(0xFFFDE68A)
        : (canViewPrices ? const Color(0xFFBBF7D0) : const Color(0xFFBFDBFE));
    final iconColor = !isExpired
        ? const Color(0xFFD97706)
        : (canViewPrices ? const Color(0xFF16A34A) : const Color(0xFF2563EB));
    final textColor = !isExpired
        ? const Color(0xFF92400E)
        : (canViewPrices ? const Color(0xFF166534) : const Color(0xFF1E40AF));
    final subtextColor = !isExpired
        ? const Color(0xFFB45309)
        : (canViewPrices ? const Color(0xFF15803D) : const Color(0xFF1D4ED8));

    final title = !isExpired
        ? 'Sealed Bid Confidentiality Protocol Active (Closing Date: $deadline)'
        : (canViewPrices
            ? 'Bid Closing Deadline Expired: Quotations Unsealed ($deadline)'
            : 'Bid Closing Deadline Officially Expired ($deadline)');

    final subtitle = !isExpired
        ? 'To maintain strict compliance, vendor offer prices remain absolutely confidential before the Bid Closing Date and cannot be viewed by any user. Quotations will unseal automatically after the deadline.'
        : (canViewPrices
            ? 'Actual financial quotations and bid details are now accessible to authorized personnel and the Procurement Committee.'
            : 'Actual financial quotations and bid details may only be accessed by authorized users (and the Procurement Committee) in accordance with system permissions.');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            !isExpired
                ? Icons.lock_clock_outlined
                : (canViewPrices ? Icons.lock_open_rounded : Icons.verified_user_outlined),
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subtextColor,
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

  Widget _buildCategoryMetrics(int submitted, int pending, int waiting) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        final items = [
          _MetricData(
            title: 'Bid Submitted',
            count: submitted,
            subtitle: 'Formally received',
            icon: Icons.mark_email_read_outlined,
            color: AppColors.primary,
          ),
          _MetricData(
            title: 'Bid Pending',
            count: pending,
            subtitle: 'Under evaluation',
            icon: Icons.hourglass_top_rounded,
            color: AppColors.warning,
          ),
          _MetricData(
            title: 'Bid Waiting',
            count: waiting,
            subtitle: 'Awaiting decision',
            icon: Icons.access_time_rounded,
            color: const Color(0xFF7C3AED),
          ),
        ];

        if (isNarrow) {
          return Column(
            children: items.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildMetricTile(m),
              );
            }).toList(),
          );
        }

        return Row(
          children: items.map((m) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: m == items.last ? 0 : 12,
                ),
                child: _buildMetricTile(m),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricTile(_MetricData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: data.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.count}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.subtitle,
                  style: const TextStyle(
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(
        child: Text(
          'No bids currently recorded for this published circular.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Clean, modern desktop table without rigid cell constraints or overflow.
  Widget _buildDesktopBidsTable(
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
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.1), // Bid ID
            1: FlexColumnWidth(1.8), // Vendor
            2: FlexColumnWidth(1.1), // Date
            3: FlexColumnWidth(1.2), // Live Category
            4: FlexColumnWidth(2.4), // Offer Price
            5: FlexColumnWidth(0.9), // Delivery
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              children: const [
                _HeaderCell('Bid ID'),
                _HeaderCell('Vendor / Bidder'),
                _HeaderCell('Date'),
                _HeaderCell('Category'),
                _HeaderCell('Offer Price'),
                _HeaderCell('Delivery'),
              ],
            ),
            // Data rows
            ...bids.map((bid) {
              final bidId = bid['id'] as String? ?? '';
              final vendorName = bid['vendor_name'] as String? ?? 'Vendor';
              final date = bid['submission_date'] as String? ?? '';
              final days = bid['delivery_days'] ?? 30;
              final amount = (bid['quoted_amount'] as num?)?.toDouble() ?? 0.0;
              final category = BidComplianceService.categorizeBid(bid);

              return TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                children: [
                  // Bid ID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      bidId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  // Vendor Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      vendorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Submission Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Category Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: _buildCategoryPill(category),
                  ),
                  // Offer Price (unsealed or sealed pill with tooltip)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: _buildPriceBadge(
                      canViewPrices: canViewPrices,
                      amount: amount,
                      currencyFmt: currencyFmt,
                      deadline: deadline,
                      role: role,
                    ),
                  ),
                  // Delivery Days
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      '$days Days',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Modern, mobile-responsive stacked cards for smaller screens.
  Widget _buildMobileBidsList(
    BuildContext context,
    List<Map<String, dynamic>> bids,
    bool canViewPrices,
    NumberFormat currencyFmt,
    String deadline,
    dynamic role,
  ) {
    return Column(
      children: bids.map((bid) {
        final bidId = bid['id'] as String? ?? '';
        final vendorName = bid['vendor_name'] as String? ?? 'Vendor';
        final date = bid['submission_date'] as String? ?? '';
        final days = bid['delivery_days'] ?? 30;
        final amount = (bid['quoted_amount'] as num?)?.toDouble() ?? 0.0;
        final category = BidComplianceService.categorizeBid(bid);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bidId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  _buildCategoryPill(category),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vendorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Submitted: $date • Delivery: $days Days',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Financial Quotation:',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                  _buildPriceBadge(
                    canViewPrices: canViewPrices,
                    amount: amount,
                    currencyFmt: currencyFmt,
                    deadline: deadline,
                    role: role,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryPill(BidStatusCategory category) {
    Color color = AppColors.primary;
    if (category == BidStatusCategory.bidPending) color = AppColors.warning;
    if (category == BidStatusCategory.bidWaiting) color = const Color(0xFF7C3AED);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriceBadge({
    required bool canViewPrices,
    required double amount,
    required NumberFormat currencyFmt,
    required String deadline,
    required dynamic role,
  }) {
    if (canViewPrices) {
      return Text(
        currencyFmt.format(amount),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      );
    }

    final maskText = BidComplianceService.getPriceMaskText(deadline: deadline, role: role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 12,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 5),
            Text(
              maskText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MetricData {
  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
