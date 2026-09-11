import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class BidSubmissionPage extends StatefulWidget {
  const BidSubmissionPage({super.key});

  @override
  State<BidSubmissionPage> createState() => _BidSubmissionPageState();
}

class _BidSubmissionPageState extends State<BidSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _deliveryDaysController = TextEditingController(text: '30');
  final _remarksController = TextEditingController();

  String _selectedCircularId = 'CIRC-2026-004';
  bool _compliant = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final paramId = Get.parameters['circularId'];
    if (paramId != null && paramId.isNotEmpty) {
      _selectedCircularId = paramId;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _deliveryDaysController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final db = Get.find<DummyDatabaseService>();
    final circular = db.getCircularById(_selectedCircularId);
    final circTitle = circular?['title'] as String? ?? 'Procurement Tender';

    final newBidId = 'BID-2026-${db.bids.length + 101}';
    final quotedPrice = double.tryParse(_priceController.text.trim()) ?? 60000.0;
    final days = int.tryParse(_deliveryDaysController.text.trim()) ?? 30;

    final newBid = {
      'id': newBidId,
      'circular_id': _selectedCircularId,
      'circular_title': circTitle,
      'vendor_id': 6,
      'vendor_name': 'Apex Technologies Ltd',
      'quoted_amount': quotedPrice,
      'submission_date': DateTime.now().toString().split(' ').first,
      'status': 'SUBMITTED',
      'delivery_days': days,
      'technical_score': null,
      'financial_score': null,
      'total_score': null,
      'remarks': _remarksController.text.trim().isEmpty
          ? 'Quotation submitted with complete technical compliance.'
          : _remarksController.text.trim(),
      'documents': [
        {'name': 'Technical_Quotation_Apex.pdf', 'size_kb': 2140},
        {'name': 'OEM_Authorization_Certificate.pdf', 'size_kb': 980}
      ]
    };

    db.addBid(newBid);

    setState(() => _isLoading = false);

    AppToast.success(
      title: 'Bid Submitted Successfully',
      description: 'Your proposal for $circTitle ($newBidId) is now under review.',
    );

    Get.offNamed('/bids');
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Tender Bid'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
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
                        'Vendor Quotation Submission',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit your formal commercial and technical proposal for this procurement circular.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      Text('Target Circular / Tender',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              )),
                      const SizedBox(height: 6),
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: _selectedCircularId,
                          isExpanded: true,
                          items: db.circulars.map((c) {
                            final id = c['id'] as String;
                            final title = c['title'] as String;
                            return DropdownMenuItem(
                              value: id,
                              child: Text('$id — $title', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCircularId = val);
                          },
                        );
                      }),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _priceController,
                              label: 'Total Quoted Amount (${AppConstants.currencySymbol})',
                              hint: 'e.g. 59800',
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.required(v, 'Quoted amount'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _deliveryDaysController,
                              label: 'Delivery Timeline (Calendar Days)',
                              hint: 'e.g. 30',
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.required(v, 'Delivery days'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _remarksController,
                        label: 'Technical Remarks & Warranty Terms',
                        hint: 'Include warranty, OEM support SLA, and local maintenance availability...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Document Upload Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text('Attached Proposal Documents',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Chip(
                              avatar: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                              label: const Text('Technical_Quotation_Apex.pdf (2.1 MB)'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            Chip(
                              avatar: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                              label: const Text('OEM_Authorization_Certificate.pdf (0.9 MB)'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      CheckboxListTile(
                        value: _compliant,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'I certify that this quotation complies with all technical specifications and requirements in the circular notice.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onChanged: (val) => setState(() => _compliant = val ?? true),
                      ),
                      const SizedBox(height: 24),

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
                            label: 'Submit Bid',
                            icon: Icons.gavel_outlined,
                            isLoading: _isLoading,
                            onPressed: _submitBid,
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
