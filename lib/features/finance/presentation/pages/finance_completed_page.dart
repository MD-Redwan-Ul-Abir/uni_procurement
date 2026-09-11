import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';

class FinanceCompletedPage extends StatefulWidget {
  const FinanceCompletedPage({super.key});

  @override
  State<FinanceCompletedPage> createState() => _FinanceCompletedPageState();
}

class _FinanceCompletedPageState extends State<FinanceCompletedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      title: 'Settled Payments & Treasury Audit',
      selectedIndex: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Export Reconciled Payment Vouchers (PDF)',
          onPressed: () {
            AppToast.success(
              title: 'Treasury Vouchers Exported',
              description: 'Reconciled EFT payment certificates downloaded.',
              context: context,
            );
          },
        ),
      ],
      body: Obx(() {
        final allInvoices = db.invoices;
        final settledInvoices = allInvoices.where((i) => i['status'] == 'PAID').toList();

        final filtered = settledInvoices.where((inv) {
          final q = _searchQuery.toLowerCase().trim();
          if (q.isEmpty) return true;
          return (inv['id']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['invoice_number']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['circular_title']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['vendor_name']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['eft_transaction_id']?.toString().toLowerCase().contains(q) ?? false) ||
              (inv['department']?.toString().toLowerCase().contains(q) ?? false);
        }).toList();

        final totalSettledAmount = settledInvoices.fold<double>(
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
                      // Section 1: Executive Audit Summary Strip
                      _buildAuditMetricsStrip(
                        screenWidth: screenWidth,
                        count: settledInvoices.length,
                        totalAmount: totalSettledAmount,
                        currencyFmt: currencyFmt,
                      ),

                      const SizedBox(height: 20),

                      // Section 2: Search Input
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search settled payments by EFT ID, Invoice No, Payee, or Department...',
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

                      const SizedBox(height: 20),

                      // Section 3: Header Count
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            filtered.isEmpty
                                ? 'No settled payments match query'
                                : 'Showing ${filtered.length} of ${settledInvoices.length} reconciled settlements',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 14, color: AppColors.success),
                                SizedBox(width: 6),
                                Text(
                                  'All Funds Disbursed via Bangladesh Bank BEFTN/RTGS',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Section 4: Settled Cards
                      if (filtered.isEmpty)
                        const EmptyState(
                          icon: Icons.check_circle_outline,
                          title: 'No Settled Records Found',
                          subtitle: 'Payments cleared by the finance department will be logged in this ledger.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final inv = filtered[index];
                            return _buildSettledCard(context, inv, currencyFmt, isDesktop);
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

  Widget _buildAuditMetricsStrip({
    required double screenWidth,
    required int count,
    required double totalAmount,
    required NumberFormat currencyFmt,
  }) {
    final metrics = [
      _AuditTile(
        label: 'Total Reconciled Payouts',
        value: currencyFmt.format(totalAmount),
        subtext: 'Cumulative cleared disbursements',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _AuditTile(
        label: 'Settled Invoices',
        value: '$count Vouchers',
        subtext: 'Verified goods & services',
        icon: Icons.receipt_long_outlined,
        color: AppColors.primary,
      ),
      _AuditTile(
        label: 'Audit Discrepancies',
        value: '0 Exceptions',
        subtext: '100% statutory tax compliance',
        icon: Icons.shield_outlined,
        color: const Color(0xFF0D9488),
      ),
      _AuditTile(
        label: 'EFT Channel',
        value: 'Automated BEFTN',
        subtext: 'Zero cash disbursement',
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF7C3AED),
      ),
    ];

    if (screenWidth >= 900) {
      return Row(
        children: metrics.map((m) => Expanded(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: _tile(m)),
        )).toList(),
      );
    } else if (screenWidth >= 550) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _tile(metrics[0])),
              const SizedBox(width: 10),
              Expanded(child: _tile(metrics[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _tile(metrics[2])),
              const SizedBox(width: 10),
              Expanded(child: _tile(metrics[3])),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: metrics.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _tile(m))).toList(),
      );
    }
  }

  Widget _tile(_AuditTile m) {
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
              color: m.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(m.icon, color: m.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(m.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: m.color)),
                Text(m.subtext, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettledCard(
    BuildContext context,
    Map<String, dynamic> inv,
    NumberFormat currencyFmt,
    bool isDesktop,
  ) {
    final id = inv['id'] as String? ?? '';
    final title = inv['circular_title'] as String? ?? '';
    final vendorName = inv['vendor_name'] as String? ?? '';
    final invNo = inv['invoice_number'] as String? ?? '';
    final totalPayable = (inv['total_payable'] as num?)?.toDouble() ?? 0.0;
    final date = inv['invoice_date'] as String? ?? '';
    final dept = inv['department'] as String? ?? 'General';
    final chalan = inv['chalan_number'] as String? ?? 'N/A';
    final eftTx = inv['eft_transaction_id'] as String? ?? 'EFT-TX-${id.replaceAll(RegExp(r'[^0-9]'), '')}921';
    final disbursedBy = inv['disbursed_by'] as String? ?? 'Dr. Arthur Vance (Finance Officer)';
    final bank = (inv['bank_details'] as Map<String, dynamic>?)?['bank_name'] ?? 'Bank EFT';
    final acct = (inv['bank_details'] as Map<String, dynamic>?)?['account_number'] ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 14),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                eftTx,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 13, color: AppColors.success),
                              SizedBox(width: 4),
                              Text(
                                'SETTLED & DISBURSED',
                                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      'Payee: $vendorName • Dept: $dept • Cleared: $date • Bank: $bank ($acct) • Chalan: $chalan',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Amount Settled & Disbursed', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(
                        currencyFmt.format(totalPayable),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Authorized By', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(disbursedBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      AppToast.success(
                        title: 'Payment Voucher Downloaded',
                        description: 'Treasury voucher for $id and invoice ref $invNo downloaded.',
                        context: context,
                      );
                    },
                    icon: const Icon(Icons.download, size: 16, color: AppColors.primary),
                    label: const Text('Download Voucher', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => Get.toNamed('/finance/review?id=$id'),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Full Audit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

class _AuditTile {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _AuditTile({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });
}
