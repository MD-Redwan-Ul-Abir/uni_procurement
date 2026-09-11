import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class FinanceInvoicesPage extends StatefulWidget {
  const FinanceInvoicesPage({super.key});

  @override
  State<FinanceInvoicesPage> createState() => _FinanceInvoicesPageState();
}

class _FinanceInvoicesPageState extends State<FinanceInvoicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  String _selectedDepartment = 'ALL';

  @override
  void initState() {
    super.initState();
    final statusParam = Get.parameters['status'];
    if (statusParam != null && statusParam.isNotEmpty) {
      _selectedStatus = statusParam;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 2);

    return AdaptiveScaffold(
      title: 'Invoices & Claims Queue',
      selectedIndex: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Export Invoices Ledger (CSV)',
          onPressed: () {
            AppToast.success(
              title: 'Invoices Ledger Exported',
              description: 'Filtered procurement claims downloaded in CSV format.',
              context: context,
            );
          },
        ),
      ],
      body: Obx(() {
        final allInvoices = db.invoices;

        final departments = <String>{'ALL'};
        for (final inv in allInvoices) {
          final dept = inv['department'] as String?;
          if (dept != null && dept.isNotEmpty) {
            departments.add(dept);
          }
        }

        final filtered = allInvoices.where((inv) {
          final matchesStatus = _selectedStatus == 'ALL' || inv['status'] == _selectedStatus;
          final matchesDept = _selectedDepartment == 'ALL' || inv['department'] == _selectedDepartment;

          final q = _searchQuery.toLowerCase().trim();
          final matchesSearch = q.isEmpty ||
              (inv['id']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['invoice_number']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['circular_title']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['vendor_name']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['chalan_number']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['department']?.toString().toLowerCase().contains(q) ?? false);

          return matchesStatus && matchesDept && matchesSearch;
        }).toList();

        final totalCount = allInvoices.length;
        final pendingCount = allInvoices.where((i) => i['status'] == 'PENDING_REVIEW').length;
        final paidCount = allInvoices.where((i) => i['status'] == 'PAID').length;
        final totalPayableSum = allInvoices.fold<double>(
          0.0,
          (sum, inv) => sum + ((inv['total_payable'] as num?)?.toDouble() ?? 0.0),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= 850;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Executive Metrics Strip
                      _buildMetricsStrip(
                        screenWidth: screenWidth,
                        totalCount: totalCount,
                        pendingCount: pendingCount,
                        paidCount: paidCount,
                        totalPayableSum: totalPayableSum,
                      ),

                      const SizedBox(height: 20),

                      // Section 2: Search & Filter Toolbar
                      _buildSearchAndFilters(
                        context: context,
                        departments: departments.toList(),
                        pendingCount: pendingCount,
                        paidCount: paidCount,
                        totalCount: totalCount,
                      ),

                      const SizedBox(height: 20),

                      // Section 3: Results Count Header
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            filtered.isEmpty
                                ? 'No claims matching criteria'
                                : 'Showing ${filtered.length} of $totalCount registered invoices',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedStatus != 'ALL' || _selectedDepartment != 'ALL')
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedStatus = 'ALL';
                                  _selectedDepartment = 'ALL';
                                });
                              },
                              icon: const Icon(Icons.clear, size: 14),
                              label: const Text('Reset filters', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Section 4: Responsive Invoice Cards List
                      if (filtered.isEmpty)
                        const EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No Invoices Found',
                          subtitle: 'Try adjusting your search query, status, or department filter.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final inv = filtered[index];
                            return _buildInvoiceCard(context, inv, currencyFmt, isDesktop);
                          },
                        ),

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

  // ── Executive Summary Metrics Strip ──
  Widget _buildMetricsStrip({
    required double screenWidth,
    required int totalCount,
    required int pendingCount,
    required int paidCount,
    required double totalPayableSum,
  }) {
    final currencyFmt = NumberFormat.compactCurrency(symbol: AppConstants.currencySymbol);
    final metrics = [
      _MetricTileData(
        label: 'Total Invoices Logged',
        value: '$totalCount Records',
        subtext: 'Submitted by verified vendors',
        icon: Icons.receipt_outlined,
      ),
      _MetricTileData(
        label: 'Pending Disbursal',
        value: '$pendingCount Urgent',
        subtext: 'Awaiting EFT clearance',
        icon: Icons.pending_actions_outlined,
        valueColor: AppColors.warning,
      ),
      _MetricTileData(
        label: 'Reconciled & Paid',
        value: '$paidCount Settled',
        subtext: 'Transferred via electronic treasury',
        icon: Icons.check_circle_outline,
        valueColor: AppColors.success,
      ),
      _MetricTileData(
        label: 'Gross Claims Volume',
        value: currencyFmt.format(totalPayableSum),
        subtext: 'FY 2025-26 cumulative total',
        icon: Icons.account_balance_wallet_outlined,
        valueColor: AppColors.primary,
      ),
    ];

    if (screenWidth >= 900) {
      return Row(
        children: metrics.map((m) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildMetricTile(m),
          ),
        )).toList(),
      );
    } else if (screenWidth >= 550) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricTile(metrics[0])),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile(metrics[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile(metrics[2])),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile(metrics[3])),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: metrics.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildMetricTile(m),
        )).toList(),
      );
    }
  }

  Widget _buildMetricTile(_MetricTileData m) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (m.valueColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(m.icon, color: m.valueColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  m.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: m.valueColor ?? AppColors.textPrimary,
                  ),
                ),
                Text(
                  m.subtext,
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search & Filter Controls ──
  Widget _buildSearchAndFilters({
    required BuildContext context,
    required List<String> departments,
    required int pendingCount,
    required int paidCount,
    required int totalCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search claims by Invoice ID, Ref, Payee Vendor, Tender, or Chalan...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: AppColors.cardBg,
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),

        const SizedBox(height: 14),

        // Status Tabs & Department Dropdown
        if (MediaQuery.of(context).size.width < 700) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Invoices ($totalCount)'),
                const SizedBox(width: 8),
                _buildFilterChip('PENDING_REVIEW', 'Pending Disbursal ($pendingCount)'),
                const SizedBox(width: 8),
                _buildFilterChip('PAID', 'Settled & Paid ($paidCount)'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedDepartment,
                icon: const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                items: departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(dept == 'ALL' ? 'All Departments' : dept, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDepartment = val);
                },
              ),
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Invoices ($totalCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING_REVIEW', 'Pending Disbursal ($pendingCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PAID', 'Settled & Paid ($paidCount)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Department Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDepartment,
                    icon: const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    items: departments.map((dept) {
                      return DropdownMenuItem<String>(
                        value: dept,
                        child: Text(dept == 'ALL' ? 'All Departments' : dept),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDepartment = val);
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFilterChip(String statusKey, String label) {
    final isSelected = _selectedStatus == statusKey;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = statusKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Invoice Card (Admin Clean Layout) ──
  Widget _buildInvoiceCard(
    BuildContext context,
    Map<String, dynamic> inv,
    NumberFormat currencyFmt,
    bool isDesktop,
  ) {
    final id = inv['id'] as String? ?? '';
    final title = inv['circular_title'] as String? ?? '';
    final vendorName = inv['vendor_name'] as String? ?? '';
    final invNo = inv['invoice_number'] as String? ?? '';
    final baseAmount = (inv['amount'] as num?)?.toDouble() ?? 0.0;
    final taxAmount = (inv['tax_amount'] as num?)?.toDouble() ?? 0.0;
    final totalPayable = (inv['total_payable'] as num?)?.toDouble() ?? 0.0;
    final status = inv['status'] as String? ?? 'PENDING_REVIEW';
    final isPending = status == 'PENDING_REVIEW';
    final date = inv['invoice_date'] as String? ?? '';
    final dept = inv['department'] as String? ?? 'General';
    final chalan = inv['chalan_number'] as String? ?? 'N/A';
    final woId = inv['work_order_id'] as String? ?? '';
    final bank = (inv['bank_details'] as Map<String, dynamic>?)?['bank_name'] ?? 'Bank EFT';

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon indicator
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPending ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? Icons.hourglass_top : Icons.check,
                    color: isPending ? AppColors.warning : AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(id, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                              Text('• Ref: $invNo', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                              Text('• Work Order: $woId', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? AppColors.warning.withValues(alpha: 0.12)
                                  : AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPending ? AppColors.warning.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPending ? Icons.pending_actions : Icons.verified,
                                  size: 13,
                                  color: isPending ? AppColors.warning : AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPending ? 'PENDING' : 'SETTLED',
                                  style: TextStyle(
                                    color: isPending ? AppColors.warning : AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 20,
                        runSpacing: 4,
                        children: [
                          _infoItem(Icons.storefront_outlined, 'Payee: $vendorName'),
                          _infoItem(Icons.apartment_outlined, 'Dept: $dept'),
                          _infoItem(Icons.receipt_outlined, 'Chalan: $chalan'),
                          _infoItem(Icons.calendar_today_outlined, 'Submitted: $date'),
                          _infoItem(Icons.account_balance_outlined, 'Bank: $bank'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Financial amounts & Action button
            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _costColumn('Base Claim', currencyFmt.format(baseAmount)),
                    _costColumn('VAT / Tax (5%)', currencyFmt.format(taxAmount)),
                    _costColumn(
                      'Total Payable',
                      currencyFmt.format(totalPayable),
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
                if (isPending)
                  AppButton(
                    label: 'Audit & Disburse',
                    icon: Icons.payments_outlined,
                    onPressed: () => Get.toNamed('/finance/review?id=$id'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/finance/review?id=$id'),
                    icon: const Icon(Icons.receipt_long, size: 16, color: AppColors.success),
                    label: const Text('View Payment Proof', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _costColumn(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _MetricTileData {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color? valueColor;

  const _MetricTileData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    this.valueColor,
  });
}
