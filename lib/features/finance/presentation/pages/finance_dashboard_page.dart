import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class FinanceDashboardPage extends StatelessWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Finance & Treasury',
      selectedIndex: 0,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'FY 2025–2026',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Export Treasury & Disbursement Ledger',
          onPressed: () {
            AppToast.success(
              title: 'Treasury Ledger Exported',
              description: 'Comprehensive FY 2025-2026 disbursement summary downloaded.',
              context: context,
            );
          },
        ),
      ],
      body: Obx(() {
        final summary = db.financeSummary;
        final invoices = db.invoices;

        final totalBudget = (summary['total_procurement_budget'] as num?)?.toDouble() ?? 3500000.0;
        final committed = (summary['committed_funds'] as num?)?.toDouble() ?? 2185000.0;
        final disbursed = (summary['disbursed_funds'] as num?)?.toDouble() ?? 1420000.0;
        final uncommitted = (totalBudget - committed).clamp(0.0, double.infinity);

        // Pending and paid lists
        final pendingInvoices = invoices.where((i) => i['status'] == 'PENDING_REVIEW').toList();
        final paidInvoices = invoices.where((i) => i['status'] == 'PAID').toList();

        final pendingAmount = pendingInvoices.fold<double>(
          0.0,
          (sum, inv) => sum + ((inv['total_payable'] as num?)?.toDouble() ?? 0.0),
        );

        final avgTurnaround = summary['avg_turnaround_days'] ?? 3.2;
        final eftSuccess = summary['eft_success_rate'] ?? '98.5%';

        final kpiItems = [
          _FinanceKpiData(
            label: 'Fiscal Procurement Budget',
            value: currencyFmt.format(totalBudget),
            subtext: 'FY 2025-26 Annual Allocation',
            icon: Icons.account_balance_outlined,
            color: const Color(0xFF0D9488), // Teal
          ),
          _FinanceKpiData(
            label: 'Committed Contract Liabilities',
            value: currencyFmt.format(committed),
            subtext: '${((committed / totalBudget) * 100).toStringAsFixed(1)}% of Budget Committed',
            icon: Icons.assignment_turned_in_outlined,
            color: AppColors.primary,
          ),
          _FinanceKpiData(
            label: 'Disbursed Settlements',
            value: currencyFmt.format(disbursed),
            subtext: '${((disbursed / totalBudget) * 100).toStringAsFixed(1)}% Treasury Disbursed',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
          _FinanceKpiData(
            label: 'Pending Invoices Payable',
            value: currencyFmt.format(pendingAmount),
            subtext: '${pendingInvoices.length} Claims Awaiting EFT',
            icon: Icons.pending_actions_outlined,
            color: AppColors.warning,
          ),
          _FinanceKpiData(
            label: 'Uncommitted Fiscal Balance',
            value: currencyFmt.format(uncommitted),
            subtext: 'Available for New Requisitions',
            icon: Icons.savings_outlined,
            color: const Color(0xFF7C3AED), // Violet
          ),
          _FinanceKpiData(
            label: 'Claims in Audit Queue',
            value: '${pendingInvoices.length} Pending',
            subtext: '${paidInvoices.length} Settled Invoices',
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFFEA580C), // Orange
          ),
          _FinanceKpiData(
            label: 'Average Settlement Turnaround',
            value: '$avgTurnaround Days',
            subtext: 'Target: ≤ 5.0 Business Days',
            icon: Icons.speed_outlined,
            color: AppColors.accent,
          ),
          _FinanceKpiData(
            label: 'EFT Direct Clearance Rate',
            value: '$eftSuccess',
            subtext: 'BEFTN / RTGS Routing',
            icon: Icons.verified_outlined,
            color: const Color(0xFF059669), // Emerald
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
                      // Section 1: Responsive KPI Grid (Admin Style: 4/2/1 cols, equal flex)
                      _buildResponsiveKpiGrid(kpiItems, screenWidth),

                      const SizedBox(height: 24),

                      // Section 2: Quick Action Cockpit Strip
                      _buildQuickActionStrip(context, pendingInvoices.length, paidInvoices.length),

                      const SizedBox(height: 28),

                      // Section 3: Analytics Row (Side-by-Side on Desktop, Stacked on Mobile/Tablet)
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildBudgetUtilizationCard(
                                context,
                                totalBudget: totalBudget,
                                committed: committed,
                                disbursed: disbursed,
                                uncommitted: uncommitted,
                                currencyFmt: currencyFmt,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: _buildDepartmentSpendCard(
                                context,
                                summary: summary,
                                currencyFmt: currencyFmt,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildBudgetUtilizationCard(
                          context,
                          totalBudget: totalBudget,
                          committed: committed,
                          disbursed: disbursed,
                          uncommitted: uncommitted,
                          currencyFmt: currencyFmt,
                        ),
                        const SizedBox(height: 20),
                        _buildDepartmentSpendCard(
                          context,
                          summary: summary,
                          currencyFmt: currencyFmt,
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Section 4: Urgent Claims Action Table / Cards
                      _buildUrgentClaimsSection(context, pendingInvoices, currencyFmt, screenWidth),

                      const SizedBox(height: 32),
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

  // ── Responsive KPI Grid (Admin Pattern) ──
  Widget _buildResponsiveKpiGrid(List<_FinanceKpiData> items, double screenWidth) {
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
      final chunk = items.sublist(
        i,
        (i + crossAxisCount > items.length) ? items.length : i + crossAxisCount,
      );
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

  Widget _kpiCard(_FinanceKpiData data) {
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

  // ── Quick Action Cockpit Strip ──
  Widget _buildQuickActionStrip(BuildContext context, int pendingCount, int paidCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 750;

          final items = [
            _quickActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Review Pending Claims',
              badge: '$pendingCount Urgent',
              badgeColor: AppColors.warning,
              onTap: () => Get.toNamed('/finance/invoices'),
            ),
            _quickActionButton(
              icon: Icons.check_circle_outline,
              label: 'Settled Disbursals',
              badge: '$paidCount Cleared',
              badgeColor: AppColors.success,
              onTap: () => Get.toNamed('/finance/completed'),
            ),
            _quickActionButton(
              icon: Icons.assignment_outlined,
              label: 'Contract Commitments',
              badge: 'Work Orders',
              badgeColor: AppColors.primary,
              onTap: () => Get.toNamed('/work-orders'),
            ),
            _quickActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Fiscal Reconciliation',
              badge: 'Audit Ready',
              badgeColor: const Color(0xFF0D9488),
              onTap: () {
                AppToast.info(
                  title: 'Treasury Reconciled',
                  description: 'All pending EFT clearing batches reconciled with bank statement records.',
                  context: context,
                );
              },
            ),
          ];

          if (isCompact) {
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: items.map((w) => SizedBox(width: constraints.maxWidth > 400 ? (constraints.maxWidth - 12) / 2 : double.infinity, child: w)).toList(),
            );
          }

          return Row(
            children: items.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w))).toList(),
          );
        },
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Budget Utilization & Ceiling Card ──
  Widget _buildBudgetUtilizationCard(
    BuildContext context, {
    required double totalBudget,
    required double committed,
    required double disbursed,
    required double uncommitted,
    required NumberFormat currencyFmt,
  }) {
    final committedPct = totalBudget > 0 ? (committed / totalBudget).clamp(0.0, 1.0) : 0.0;
    final disbursedPct = totalBudget > 0 ? (disbursed / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Utilization & Ceilings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Cumulative commitments & actual payouts against FY budget',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Fiscal Health: Good',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Stacked visual progress representation
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Flexible(
                    flex: (disbursedPct * 100).toInt(),
                    child: Container(color: AppColors.success),
                  ),
                  Flexible(
                    flex: (((committed - disbursed) / totalBudget).clamp(0.0, 1.0) * 100).toInt(),
                    child: Container(color: AppColors.primary),
                  ),
                  Flexible(
                    flex: ((uncommitted / totalBudget).clamp(0.0, 1.0) * 100).toInt(),
                    child: Container(color: AppColors.border),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend & Breakdown
          Row(
            children: [
              _legendItem(
                color: AppColors.success,
                label: 'Disbursed',
                value: currencyFmt.format(disbursed),
                subtext: '${(disbursedPct * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 14),
              _legendItem(
                color: AppColors.primary,
                label: 'Committed',
                value: currencyFmt.format(committed),
                subtext: '${(committedPct * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 14),
              _legendItem(
                color: AppColors.textTertiary,
                label: 'Uncommitted',
                value: currencyFmt.format(uncommitted),
                subtext: '${((uncommitted / totalBudget) * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),

          const Divider(height: 28),

          // Appropriation sub-breakdown
          Row(
            children: [
              Expanded(
                child: _submetricTile('CapEx Lab Equipment', '${AppConstants.currencySymbol}1,575,000', '45.0% share', const Color(0xFF0D9488)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _submetricTile('IT Infrastructure', '${AppConstants.currencySymbol}1,050,000', '30.0% share', AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _submetricTile('Research Grants', '${AppConstants.currencySymbol}875,000', '25.0% share', const Color(0xFF7C3AED)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            Text(subtext, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _submetricTile(String label, String value, String subtext, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Text(subtext, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  // ── Department Spend & Distribution Card ──
  Widget _buildDepartmentSpendCard(
    BuildContext context, {
    required Map<String, dynamic> summary,
    required NumberFormat currencyFmt,
  }) {
    final deptSpend = (summary['spend_by_department'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      padding: const EdgeInsets.all(22),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Departmental Spend Allocation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Disbursements by university operating academic faculties',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.pie_chart_outline, size: 20, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 18),

          if (deptSpend.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No department data available.')),
            )
          else
            ...deptSpend.map((d) {
              final name = d['department'] as String? ?? 'General';
              final disbursed = (d['disbursed'] as num?)?.toDouble() ?? 0.0;
              final pct = (d['percentage'] as num?)?.toDouble() ?? 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${currencyFmt.format(disbursed)} (${pct.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: _colorForIndex(deptSpend.indexOf(d)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _colorForIndex(int idx) {
    const colors = [
      AppColors.primary,
      Color(0xFF0D9488),
      Color(0xFF7C3AED),
      Color(0xFFEA580C),
      Color(0xFF0284C7),
    ];
    return colors[idx % colors.length];
  }

  // ── Urgent Claims Requiring Action Section ──
  Widget _buildUrgentClaimsSection(
    BuildContext context,
    List<Map<String, dynamic>> pendingInvoices,
    NumberFormat currencyFmt,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth < 700 ? double.infinity : 680),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Urgent Claims Requiring Disbursal',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.warning.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${pendingInvoices.length} Pending Review',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Vendor invoices validated by procurement ready for BEFTN treasury release',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
              label: 'View All Claims',
              icon: Icons.arrow_forward_rounded,
              isOutlined: true,
              onPressed: () => Get.toNamed(AppRoutes.financeInvoices),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (pendingInvoices.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const EmptyState(
              icon: Icons.verified_outlined,
              title: 'All Claims Disbursed',
              subtitle: 'There are no pending vendor claims awaiting electronic payment clearance.',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingInvoices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final inv = pendingInvoices[index];
              return _buildUrgentClaimCard(context, inv, currencyFmt, screenWidth);
            },
          ),
      ],
    );
  }

  Widget _buildUrgentClaimCard(
    BuildContext context,
    Map<String, dynamic> inv,
    NumberFormat currencyFmt,
    double screenWidth,
  ) {
    final id = inv['id'] as String? ?? '';
    final title = inv['circular_title'] as String? ?? '';
    final vendorName = inv['vendor_name'] as String? ?? '';
    final invNo = inv['invoice_number'] as String? ?? '';
    final amount = (inv['total_payable'] as num?)?.toDouble() ?? 0.0;
    final date = inv['invoice_date'] as String? ?? '';
    final dept = inv['department'] as String? ?? 'General';
    final chalan = inv['chalan_number'] as String? ?? 'N/A';
    final bank = (inv['bank_details'] as Map<String, dynamic>?)?['bank_name'] ?? 'Bank EFT';

    final isWide = screenWidth >= 950;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: AppColors.warning),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.toNamed('/finance/review?id=$id'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: isWide
                      ? _buildWideClaimCardContent(
                          context,
                          id: id,
                          title: title,
                          vendorName: vendorName,
                          invNo: invNo,
                          amount: amount,
                          date: date,
                          dept: dept,
                          chalan: chalan,
                          bank: bank,
                          currencyFmt: currencyFmt,
                        )
                      : _buildStackedClaimCardContent(
                          context,
                          id: id,
                          title: title,
                          vendorName: vendorName,
                          invNo: invNo,
                          amount: amount,
                          date: date,
                          dept: dept,
                          chalan: chalan,
                          bank: bank,
                          currencyFmt: currencyFmt,
                          screenWidth: screenWidth,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideClaimCardContent(
    BuildContext context, {
    required String id,
    required String title,
    required String vendorName,
    required String invNo,
    required double amount,
    required String date,
    required String dept,
    required String chalan,
    required String bank,
    required NumberFormat currencyFmt,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Ref: $invNo',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_filled_rounded, size: 11, color: AppColors.warning),
                        SizedBox(width: 4),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // Metadata Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _metaPill(Icons.business_outlined, vendorName, isHighlighted: true),
                  _metaPill(Icons.school_outlined, dept),
                  _metaPill(Icons.inventory_2_outlined, 'Chalan: $chalan'),
                  _metaPill(Icons.calendar_today_outlined, date),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Vertical dividing accent
        Container(
          width: 1,
          height: 85,
          color: AppColors.border,
        ),

        const SizedBox(width: 24),

        // Right Financial Box
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'NET PAYABLE VALUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  currencyFmt.format(amount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      bank,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Review & Disburse',
                  icon: Icons.payments_outlined,
                  onPressed: () => Get.toNamed('/finance/review?id=$id'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackedClaimCardContent(
    BuildContext context, {
    required String id,
    required String title,
    required String vendorName,
    required String invNo,
    required double amount,
    required String date,
    required String dept,
    required String chalan,
    required String bank,
    required NumberFormat currencyFmt,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    id,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Ref: $invNo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 11, color: AppColors.warning),
                  SizedBox(width: 4),
                  Text(
                    'Action Required',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),

        // Metadata Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _metaPill(Icons.business_outlined, vendorName, isHighlighted: true),
            _metaPill(Icons.school_outlined, dept),
            _metaPill(Icons.inventory_2_outlined, 'Chalan: $chalan'),
            _metaPill(Icons.calendar_today_outlined, date),
          ],
        ),
        const SizedBox(height: 14),

        // Hairline Divider
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Bottom Action Area
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NET PAYABLE VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFmt.format(amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_outlined, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          bank,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screenWidth < 520 ? double.infinity : null,
              child: AppButton(
                label: 'Review & Disburse',
                icon: Icons.payments_outlined,
                onPressed: () => Get.toNamed('/finance/review?id=$id'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metaPill(IconData icon, String label, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary.withValues(alpha: 0.05) : AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlighted ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isHighlighted ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceKpiData {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _FinanceKpiData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });
}
