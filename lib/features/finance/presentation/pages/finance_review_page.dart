import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';

class FinanceReviewPage extends StatelessWidget {
  const FinanceReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final invoiceId = Get.parameters['id'] ?? 'INV-2026-301';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice & Payment Disbursal Audit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Disbursement Voucher',
            onPressed: () {
              AppToast.info(
                title: 'Print Queue Initiated',
                description: 'Voucher for $invoiceId sent to treasury printer.',
                context: context,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download Invoice Dossier (PDF)',
            onPressed: () {
              AppToast.success(
                title: 'Dossier Downloaded',
                description: 'Complete compliance bundle and invoice files downloaded.',
                context: context,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final inv = db.invoices.firstWhereOrNull((i) => i['id'] == invoiceId) ??
            (db.invoices.isNotEmpty ? db.invoices.first : null);

        if (inv == null) {
          return const Center(child: Text('Invoice record not found.'));
        }

        final id = inv['id'] as String? ?? '';
        final woId = inv['work_order_id'] as String? ?? '';
        final title = inv['circular_title'] as String? ?? '';
        final vendorName = inv['vendor_name'] as String? ?? '';
        final invNo = inv['invoice_number'] as String? ?? '';
        final invDate = inv['invoice_date'] as String? ?? '';
        final baseAmount = (inv['amount'] as num?)?.toDouble() ?? 0.0;
        final taxAmount = (inv['tax_amount'] as num?)?.toDouble() ?? 0.0;
        final totalPayable = (inv['total_payable'] as num?)?.toDouble() ?? 0.0;
        final status = inv['status'] as String? ?? 'PENDING_REVIEW';
        final isPaid = status == 'PAID';
        final isReturned = status == 'RETURNED_FOR_CLARIFICATION';
        final chalan = inv['chalan_number'] as String? ?? 'N/A';
        final deliveryDate = inv['delivery_date'] as String? ?? 'N/A';
        final department = inv['department'] as String? ?? 'General';
        final remarks = inv['remarks'] as String? ?? 'No remarks provided.';
        final bankDetails = inv['bank_details'] as Map<String, dynamic>? ?? {};
        final docs = (inv['attached_documents'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final eftTx = inv['eft_transaction_id'] as String? ?? 'EFT-TX-${id.replaceAll(RegExp(r'[^0-9]'), '')}921';
        final disbursedBy = inv['disbursed_by'] as String? ?? 'Dr. Arthur Vance (Finance Officer)';
        final paidAt = inv['paid_at'] as String? ?? 'Reconciled in Treasury';
        final returnReason = inv['rejection_reason'] as String? ?? '';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 750;

            final statusBadge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPaid
                    ? const Color(0xFFF0FDF4)
                    : isReturned
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPaid
                      ? const Color(0xFFBBF7D0)
                      : isReturned
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle_outlined
                        : isReturned
                            ? Icons.error_outline
                            : Icons.hourglass_top_outlined,
                    size: 14,
                    color: isPaid
                        ? const Color(0xFF15803D)
                        : isReturned
                            ? AppColors.error
                            : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPaid
                        ? 'PAID & DISBURSED'
                        : isReturned
                            ? 'RETURNED FOR CLARIFICATION'
                            : 'PENDING EFT DISBURSAL',
                    style: TextStyle(
                      color: isPaid
                          ? const Color(0xFF15803D)
                          : isReturned
                              ? AppColors.error
                              : const Color(0xFFB45309),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Header Claim Overview Card
                      Container(
                        padding: const EdgeInsets.all(24),
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
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.scaffoldBg,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Text(
                                                'Vendor Ref: $invNo',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          title,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  statusBadge,
                                ],
                              )
                            else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
                                  statusBadge,
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Vendor Ref: $invNo', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            ],

                            const Divider(height: 32),

                            Wrap(
                              spacing: 32,
                              runSpacing: 14,
                              children: [
                                _infoBlock('Payee Vendor', vendorName),
                                _infoBlock('Work Order Ref', woId),
                                _infoBlock('Operating Department', department),
                                _infoBlock('Invoice Submission Date', invDate),
                                _infoBlock('Delivery Chalan Number', chalan),
                                _infoBlock('Goods Acceptance Date', deliveryDate),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (isReturned) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Returned for Audit Clarification', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                                    const SizedBox(height: 2),
                                    Text(returnReason, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Section 2: Itemized Financial Calculation Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Itemized Financial Calculation & Statutory Withholdings',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Statutory NBR Compliant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _calcRow('Net Base Claim (Goods & Professional Services)', currencyFmt.format(baseAmount)),
                            const SizedBox(height: 8),
                            _calcRow('Applicable VAT / AIT (5.0% Standard Withholding)', currencyFmt.format(taxAmount)),
                            const SizedBox(height: 8),
                            _calcRow('University Procurement Processing Fee', '\$0.00', isMuted: true),
                            const Divider(height: 24),
                            _calcRow(
                              'Total Gross Claim Amount Payable',
                              currencyFmt.format(totalPayable),
                              isBold: true,
                              valueColor: AppColors.primary,
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.account_tree_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'General Ledger Code: GL-8812-CAPEX-EQUIP • Sanction Tier: Tier 2 (Dean / Finance Approval)',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 3: Verified Bank Routing Credentials Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verified Bank Routing Credentials (BEFTN / RTGS)',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Treasury Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 32,
                              runSpacing: 14,
                              children: [
                                _infoBlock('Bank Institution', bankDetails['bank_name'] ?? 'N/A'),
                                _infoBlock('Branch Location', bankDetails['branch'] ?? 'N/A'),
                                _infoBlock('Account Beneficiary Name', bankDetails['account_name'] ?? 'N/A'),
                                _infoBlock('Bank Account Number', bankDetails['account_number'] ?? 'N/A'),
                                _infoBlock('Central Routing Number', bankDetails['routing_number'] ?? 'N/A'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 4: Attached Compliance & Inspection Documents
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Attached Compliance, Chalan & Inspection Documents',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (docs.isEmpty)
                              const Text('No attachments uploaded.', style: TextStyle(color: AppColors.textTertiary))
                            else
                              ...docs.map((doc) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.scaffoldBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            doc['name'] as String? ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          '${doc['size_kb']} KB',
                                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(Icons.download, size: 18, color: AppColors.primary),
                                          tooltip: 'Download Document',
                                          onPressed: () {
                                            AppToast.success(
                                              title: 'Document Downloaded',
                                              description: '${doc['name']} saved to downloads.',
                                              context: context,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )),

                            const SizedBox(height: 16),
                            const Text('Goods Inspection & Certification Remarks:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(remarks, style: const TextStyle(fontSize: 13, height: 1.4)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 5: Electronic Fund Transfer Action Cockpit
                      if (!isPaid)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.payments_outlined, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Electronic Fund Transfer (EFT) Release Cockpit',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Approving below instructs university treasury to execute immediate electronic payment of ${currencyFmt.format(totalPayable)} to $vendorName.',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _showClarificationDialog(context, db, id, currencyFmt),
                                    icon: const Icon(Icons.assignment_return_outlined, size: 16, color: AppColors.error),
                                    label: const Text('Return for Clarification', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  AppButton(
                                    label: 'Approve & Disburse Payment',
                                    icon: Icons.check_circle_outline,
                                    onPressed: () => _showDisbursementConfirmation(
                                      context: context,
                                      db: db,
                                      id: id,
                                      vendorName: vendorName,
                                      amountFormatted: currencyFmt.format(totalPayable),
                                      bankName: bankDetails['bank_name'] ?? 'Bank EFT',
                                      acctNo: bankDetails['account_number'] ?? 'N/A',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_user, color: AppColors.success, size: 28),
                                  const SizedBox(width: 14),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Payment Disbursed & Reconciled with University Treasury',
                                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'EFT Reference: $eftTx • Disbursed By: $disbursedBy • Time: $paidAt',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              AppButton(
                                label: 'Download Receipt',
                                icon: Icons.download,
                                isOutlined: true,
                                onPressed: () {
                                  AppToast.success(
                                    title: 'Payment Certificate Downloaded',
                                    description: 'EFT receipt for voucher $id downloaded.',
                                    context: context,
                                  );
                                },
                              ),
                            ],
                          ),
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

  static Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  static Widget _calcRow(String label, String value, {bool isBold = false, bool isMuted = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isMuted ? AppColors.textTertiary : isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isMuted ? AppColors.textTertiary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ── Confirmation Modal ──
  void _showDisbursementConfirmation({
    required BuildContext context,
    required DummyDatabaseService db,
    required String id,
    required String vendorName,
    required String amountFormatted,
    required String bankName,
    required String acctNo,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payments_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Confirm EFT Payment Release',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please confirm that all goods inspection certificates and tax withholdings have been audited before authorizing fund clearance.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _dialogRow('Payee Beneficiary:', vendorName),
                  const SizedBox(height: 6),
                  _dialogRow('Disbursement Value:', amountFormatted, isBold: true),
                  const SizedBox(height: 6),
                  _dialogRow('Destination Bank:', bankName),
                  const SizedBox(height: 6),
                  _dialogRow('Account Number:', acctNo),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Authorize & Disburse',
            icon: Icons.check,
            onPressed: () {
              Navigator.of(ctx).pop();
              db.approveInvoicePayment(id);
              AppToast.success(
                title: 'Payment Disbursed Successfully',
                description: 'Funds ($amountFormatted) transferred to $vendorName. Reconciled in treasury ledger.',
                context: context,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClarificationDialog(
    BuildContext context,
    DummyDatabaseService db,
    String id,
    NumberFormat currencyFmt,
  ) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment_return_outlined, color: AppColors.error),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Return Claim for Clarification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provide feedback remarks detailing missing inspection certificates or discrepancy in invoice calculations:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Goods delivery chalan missing signature from lab in-charge.',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              final reason = textController.text.trim().isEmpty
                  ? 'Clarification required regarding goods acceptance certificate.'
                  : textController.text.trim();
              Navigator.of(ctx).pop();
              db.rejectInvoicePayment(id, reason);
              AppToast.warning(
                title: 'Claim Returned for Clarification',
                description: 'Invoice $id flagged and returned to vendor with audit notes.',
                context: context,
              );
            },
            child: const Text('Return Claim'),
          ),
        ],
      ),
    );
  }

  static Widget _dialogRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            val,
            style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
