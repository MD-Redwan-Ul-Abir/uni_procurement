import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Dashboard & Reports',
      selectedIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Export Comprehensive Report',
          onPressed: () {
            AppToast.success(
              title: 'Report Exported',
              description: 'Procurement analytics summary PDF generated and downloaded.',
              context: context,
            );
          },
        ),
      ],
      body: Obx(() {
        final reports = db.adminReports;
        final overview = reports['overview'] as Map<String, dynamic>? ?? {};
        final finance = db.financeSummary;
        final spendByCategory = (reports['spend_by_category'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final monthlyTrends = (reports['monthly_trends'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final topVendors = (reports['top_performing_vendors'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        final totalSpend = (overview['total_procurement_spend'] as num?)?.toDouble() ?? 2480000.0;
        final fiscalBudget = (finance['total_procurement_budget'] as num?)?.toDouble() ?? 3500000.0;
        final activeTenders = overview['active_tenders_count'] ?? 8;
        final registeredVendors = overview['total_registered_vendors'] ?? 46;
        final pendingVerifications = overview['pending_verifications_count'] ?? 2;
        final pendingApprovals = overview['pending_approvals_count'] ?? 3;
        final avgApprovalDays = overview['average_approval_days'] ?? 4.8;
        final onTimeRate = overview['on_time_delivery_rate'] ?? '94.2%';

        final kpiItems = [
          _KpiData(
            label: 'Total Procurement Spend',
            value: currencyFmt.format(totalSpend),
            subtext: '70.9% of Annual Budget',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
          ),
          _KpiData(
            label: 'Fiscal Year Budget',
            value: currencyFmt.format(fiscalBudget),
            subtext: 'FY 2025-2026 Allocation',
            icon: Icons.account_balance_outlined,
            color: const Color(0xFF0D9488), // Teal
          ),
          _KpiData(
            label: 'Active Public Tenders',
            value: '$activeTenders Tenders',
            subtext: '3 in Technical Evaluation',
            icon: Icons.campaign_outlined,
            color: AppColors.info,
          ),
          _KpiData(
            label: 'Registered Vendors',
            value: '$registeredVendors Active',
            subtext: 'Across 6 University Sectors',
            icon: Icons.storefront_outlined,
            color: const Color(0xFF7C3AED), // Violet
          ),
          _KpiData(
            label: 'Pending Approvals',
            value: '$pendingApprovals in Queue',
            subtext: 'Dean & Registrar Review',
            icon: Icons.pending_actions_outlined,
            color: AppColors.warning,
          ),
          _KpiData(
            label: 'Pending Verifications',
            value: '$pendingVerifications Applications',
            subtext: 'Statutory TIN/Trade Checks',
            icon: Icons.verified_user_outlined,
            color: const Color(0xFFEA580C), // Orange
          ),
          _KpiData(
            label: 'Avg Approval Turnaround',
            value: '$avgApprovalDays Days',
            subtext: 'Target: ≤ 7.0 Business Days',
            icon: Icons.speed_outlined,
            color: AppColors.accent,
          ),
          _KpiData(
            label: 'On-Time Delivery Rate',
            value: '$onTimeRate',
            subtext: 'Milestone SLA Compliance',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= 1050;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Responsive KPI Cards Grid (Equal Width, 0 trailing gaps)
                      _buildResponsiveKpiGrid(kpiItems, screenWidth),

                      const SizedBox(height: 24),

                      // Section 2: Quick Action Cockpit Strip
                      _buildQuickActionStrip(context, pendingApprovals, pendingVerifications),

                      const SizedBox(height: 28),

                      // Section 3: Analytics Row (Side-by-Side on Desktop, Stacked on Mobile/Tablet)
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSpendByCategoryCard(context, spendByCategory, currencyFmt)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildMonthlyTrendsCard(context, monthlyTrends, currencyFmt)),
                          ],
                        )
                      else ...[
                        _buildSpendByCategoryCard(context, spendByCategory, currencyFmt),
                        const SizedBox(height: 20),
                        _buildMonthlyTrendsCard(context, monthlyTrends, currencyFmt),
                      ],

                      const SizedBox(height: 28),

                      // Section 4: Top Performing Vendors Leaderboard
                      _buildTopVendorsCard(context, topVendors, currencyFmt, screenWidth),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── KPI Grid Builder ──
  Widget _buildResponsiveKpiGrid(List<_KpiData> items, double screenWidth) {
    int crossAxisCount;
    if (screenWidth >= 1150) {
      crossAxisCount = 4;
    } else if (screenWidth >= 650) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += crossAxisCount) {
      final chunk = items.sublist(i, (i + crossAxisCount > items.length) ? items.length : i + crossAxisCount);
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: (i + crossAxisCount < items.length) ? 14 : 0),
          child: Row(
            children: chunk.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _kpiCard(item),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _kpiCard(_KpiData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtext,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Cockpit ──
  Widget _buildQuickActionStrip(BuildContext context, int pendingApprovals, int pendingVerifications) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Administrative Quick Actions:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionChip(
                label: 'Approvals Queue ($pendingApprovals)',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                onTap: () => Get.toNamed('/approvals'),
              ),
              _actionChip(
                label: 'Verify Vendors ($pendingVerifications)',
                icon: Icons.verified_user_outlined,
                color: const Color(0xFFEA580C),
                onTap: () => Get.toNamed('/admin/vendor-verification'),
              ),
              _actionChip(
                label: 'Staff Directory',
                icon: Icons.people_outline,
                color: AppColors.info,
                onTap: () => Get.toNamed('/admin/users'),
              ),
              _actionChip(
                label: 'Hierarchy Settings',
                icon: Icons.account_tree_outlined,
                color: const Color(0xFF0D9488),
                onTap: () => Get.toNamed('/admin/workflow-settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Spend by Category Card ──
  Widget _buildSpendByCategoryCard(BuildContext context, List<Map<String, dynamic>> categories, NumberFormat fmt) {
    final categoryIcons = {
      'Scientific & Lab Equipment': Icons.biotech_outlined,
      'IT & Campus Networking': Icons.router_outlined,
      'Heavy Machinery & Workshop': Icons.precision_manufacturing_outlined,
      'Smart Classroom & AV': Icons.co_present_outlined,
      'Library & Office Automation': Icons.menu_book_outlined,
    };

    final categoryColors = {
      'Scientific & Lab Equipment': AppColors.primary,
      'IT & Campus Networking': const Color(0xFF0284C7),
      'Heavy Machinery & Workshop': const Color(0xFFD97706),
      'Smart Classroom & AV': const Color(0xFF7C3AED),
      'Library & Office Automation': const Color(0xFF0D9488),
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spend by Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Procurement allocation across operational domains',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${categories.length} Sectors',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...categories.map((cat) {
              final name = cat['category'] as String? ?? '';
              final amount = (cat['amount'] as num?)?.toDouble() ?? 0.0;
              final pct = (cat['percentage'] as num?)?.toDouble() ?? 0.0;
              final icon = categoryIcons[name] ?? Icons.category_outlined;
              final color = categoryColors[name] ?? AppColors.primary;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          fmt.format(amount),
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100.0,
                        minHeight: 7,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Monthly Trends Card ──
  Widget _buildMonthlyTrendsCard(BuildContext context, List<Map<String, dynamic>> trends, NumberFormat fmt) {
    final maxSpend = trends.fold<double>(0.0, (prev, elem) {
      final s = (elem['spend'] as num?)?.toDouble() ?? 0.0;
      return s > prev ? s : prev;
    });

    final total6Month = trends.fold<double>(0.0, (prev, elem) => prev + ((elem['spend'] as num?)?.toDouble() ?? 0.0));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Spend & Tender Trends',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Disbursed funds over recent 6-month cycle',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  fmt.format(total6Month),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...trends.map((m) {
              final month = m['month'] as String? ?? '';
              final spend = (m['spend'] as num?)?.toDouble() ?? 0.0;
              final circulars = m['circulars'] ?? 0;
              final ratio = maxSpend > 0 ? (spend / maxSpend) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 66,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        month,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 10,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Text(
                        fmt.format(spend),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$circulars Tenders',
                        style: const TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Top Vendors Card ──
  Widget _buildTopVendorsCard(
    BuildContext context,
    List<Map<String, dynamic>> topVendors,
    NumberFormat fmt,
    double screenWidth,
  ) {
    final isCompact = screenWidth < 750;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Performing University Vendors',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ranked by contract completion volume, milestone SLA, and lab evaluation ratings',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.people_outline, size: 15),
                  label: const Text('Manage Vendors', style: TextStyle(fontSize: 12)),
                  onPressed: () => Get.toNamed('/admin/vendor-verification'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...topVendors.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final v = entry.value;
              final name = v['vendor_name'] as String? ?? '';
              final orders = v['orders_count'] ?? 0;
              final val = (v['total_value'] as num?)?.toDouble() ?? 0.0;
              final rating = (v['rating'] as num?)?.toDouble() ?? 5.0;

              final badgeColor = rank == 1
                  ? const Color(0xFFEAB308) // Gold
                  : rank == 2
                      ? const Color(0xFF94A3B8) // Silver
                      : const Color(0xFFD97706); // Bronze

              if (isCompact) {
                // Stacked responsive layout for mobile
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: badgeColor)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$orders Completed Orders', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text(fmt.format(val), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                );
              }

              // Desktop wide layout
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Verified Tier-1 Vendor Partner', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('$orders Orders Completed', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        fmt.format(val),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const Text(' / 5.0', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });
}


