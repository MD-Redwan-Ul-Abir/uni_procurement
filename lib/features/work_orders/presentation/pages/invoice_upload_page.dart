import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class InvoiceUploadPage extends StatefulWidget {
  const InvoiceUploadPage({super.key});

  @override
  State<InvoiceUploadPage> createState() => _InvoiceUploadPageState();
}

class _InvoiceUploadPageState extends State<InvoiceUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _invNumberController = TextEditingController(text: 'INV-2026-0099');
  final _amountController = TextEditingController(text: '82500');
  final _chalanController = TextEditingController(text: 'CHAL-DH-90124');
  final _remarksController = TextEditingController();

  String _selectedWorkOrderId = 'WO-2026-001';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final paramWo = Get.parameters['workOrderId'];
    if (paramWo != null && paramWo.isNotEmpty) {
      _selectedWorkOrderId = paramWo;
    }
  }

  @override
  void dispose() {
    _invNumberController.dispose();
    _amountController.dispose();
    _chalanController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final db = Get.find<DummyDatabaseService>();
    final amount = double.tryParse(_amountController.text.trim()) ?? 82500.0;
    final tax = amount * 0.05;
    final total = amount + tax;

    final wo = db.workOrders.firstWhereOrNull((w) => w['id'] == _selectedWorkOrderId);
    final title = wo?['title'] as String? ?? 'Procured Goods Delivery';
    final newInvId = 'INV-2026-${db.invoices.length + 301}';

    final newInvoice = {
      'id': newInvId,
      'work_order_id': _selectedWorkOrderId,
      'circular_title': title,
      'vendor_id': 6,
      'vendor_name': 'Apex Technologies Ltd',
      'invoice_number': _invNumberController.text.trim(),
      'invoice_date': DateTime.now().toString().split(' ').first,
      'amount': amount,
      'tax_amount': tax,
      'total_payable': total,
      'status': 'PENDING_REVIEW',
      'chalan_number': _chalanController.text.trim(),
      'delivery_date': DateTime.now().toString().split(' ').first,
      'department': wo?['department'] ?? 'General Procurement',
      'remarks': _remarksController.text.trim().isEmpty
          ? 'Delivery completed as per contractual specifications. Requesting financial disbursement.'
          : _remarksController.text.trim(),
      'bank_details': {
        'bank_name': 'Eastern Bank Ltd',
        'branch': 'Gulshan Branch, Dhaka',
        'account_name': 'Apex Technologies Ltd',
        'account_number': '1041060098712',
        'routing_number': '095261456'
      },
      'attached_documents': [
        {'name': 'Vendor_Tax_Invoice_Signed.pdf', 'size_kb': 1650},
        {'name': 'Chalan_Verification_Note.pdf', 'size_kb': 2100}
      ]
    };

    db.addInvoice(newInvoice);

    // Update work order status to INVOICE_SUBMITTED
    final woIndex = db.workOrders.indexWhere((w) => w['id'] == _selectedWorkOrderId);
    if (woIndex != -1) {
      final updated = Map<String, dynamic>.from(db.workOrders[woIndex]);
      updated['status'] = 'INVOICE_SUBMITTED';
      db.workOrders[woIndex] = updated;
    }

    setState(() => _isLoading = false);

    AppToast.success(
      title: 'Invoice Submitted',
      description: 'Invoice $newInvId has been submitted to Accounts & Finance.',
    );

    Get.offNamed('/work-orders');
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final tax = amount * 0.05;
    final total = amount + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Vendor Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billing & Invoice Submission',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit verified billing documents and delivery chalans for Finance Department sanction.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      Text('Reference Work Order',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              )),
                      const SizedBox(height: 6),
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedWorkOrderId,
                          isExpanded: true,
                          items: db.workOrders.map((w) {
                            final id = w['id'] as String;
                            final title = w['title'] as String;
                            return DropdownMenuItem(
                              value: id,
                              child: Text('$id — $title', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWorkOrderId = val);
                          },
                        );
                      }),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _invNumberController,
                              label: 'Vendor Invoice Number',
                              hint: 'e.g. APEX-2026-0089',
                              validator: (v) => Validators.required(v, 'Invoice number'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _chalanController,
                              label: 'Delivery Chalan / Gate Pass No.',
                              hint: 'e.g. CHAL-DH-88129',
                              validator: (v) => Validators.required(v, 'Chalan number'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _amountController,
                        label: 'Taxable Goods / Services Amount (USD)',
                        hint: '82500',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.required(v, 'Amount'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),

                      // Tax & Total calculation banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Net Base: ${currencyFmt.format(amount)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text('Govt VAT / AIT (5%): ${currencyFmt.format(tax)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Gross Claim',
                                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                Text(
                                  currencyFmt.format(total),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _remarksController,
                        label: 'Delivery Acceptance Notes',
                        hint: 'Attach delivery confirmation and installation sign-off details...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Attached Scans
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vendor_Tax_Invoice_Signed.pdf & Chalan_Verification_Note.pdf (Attached)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Icon(Icons.check_circle, size: 16, color: AppColors.success),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            isOutlined: true,
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            label: 'Submit for Payment',
                            icon: Icons.send_outlined,
                            isLoading: _isLoading,
                            onPressed: _submitInvoice,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
