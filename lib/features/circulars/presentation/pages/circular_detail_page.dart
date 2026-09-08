import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_chip.dart';

class CircularDetailPage extends StatelessWidget {
  const CircularDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final circularId = Get.parameters['id'] ?? 'CIRC-2026-001';
    final db = Get.find<DummyDatabaseService>();
    final permission = Get.find<PermissionService>();

    final circular = db.getCircularById(circularId) ??
        (db.circulars.isNotEmpty ? db.circulars.first : null);

    if (circular == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Circular Detail')),
        body: const Center(child: Text('Circular not found')),
      );
    }

    final detail = db.getCircularDetails(circularId) ??
        (db.circularDetails.isNotEmpty
            ? db.circularDetails.values.first as Map<String, dynamic>
            : null);

    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final statusStr = circular['status'] as String? ?? 'DRAFT';
    final statusEnum = CircularStatus.fromString(statusStr);
    final isVendor = permission.currentRole == UserRole.vendor;
    final isInitiatorOrAdmin = permission.currentRole == UserRole.initiator ||
        permission.currentRole == UserRole.admin;
    final isGuest = permission.currentRole == null;

    final items = (detail?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final eligibility = (detail?['eligibility_criteria'] as List?)?.cast<String>() ?? [];
    final requiredDocs = (detail?['required_documents'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(circular['id'] as String? ?? 'Tender Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => AppToast.info(
              title: 'Shared',
              description: 'Link copied to clipboard',
              context: context,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                                    circular['title'] as String? ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Department: ${circular['department']} | Category: ${circular['category']}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            StatusChip.fromCircularStatus(statusEnum),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 32,
                          runSpacing: 16,
                          children: [
                            _statBlock(
                              'Estimated Budget',
                              currencyFmt.format((circular['estimated_budget'] as num?) ?? 0),
                              Icons.payments_outlined,
                              AppColors.primary,
                            ),
                            _statBlock(
                              'Submission Deadline',
                              circular['submission_deadline'] as String? ?? 'TBD',
                              Icons.event_outlined,
                              AppColors.warning,
                            ),
                            _statBlock(
                              'Warranty Required',
                              '${detail?['warranty_years'] ?? 3} Years On-site',
                              Icons.verified_outlined,
                              AppColors.info,
                            ),
                            _statBlock(
                              'Delivery Period',
                              '${detail?['delivery_period_days'] ?? 45} Days',
                              Icons.local_shipping_outlined,
                              AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Scope of Work
                _sectionCard(
                  title: 'Scope of Work',
                  icon: Icons.description_outlined,
                  child: Text(
                    detail?['scope_of_work'] as String? ?? circular['description'] as String? ?? '',
                    style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                  ),
                ),

                const SizedBox(height: 24),

                // Bill of Quantities (BOQ) Table
                if (items.isNotEmpty)
                  _sectionCard(
                    title: 'Bill of Quantities & Specifications',
                    icon: Icons.format_list_numbered_outlined,
                    child: Table(
                      border: TableBorder.all(color: AppColors.border, width: 1),
                      columnWidths: const {
                        0: FixedColumnWidth(48),
                        1: FlexColumnWidth(4),
                        2: FixedColumnWidth(70),
                        3: FixedColumnWidth(130),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05)),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Item Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Est. Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                        ...items.map((it) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('${it['item_no']}', style: const TextStyle(fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(it['description'] ?? '', style: const TextStyle(fontSize: 13)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('${it['quantity']} ${it['unit']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  currencyFmt.format((it['unit_estimated_price'] as num?) ?? 0),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Eligibility Criteria & Required Documents
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _sectionCard(
                        title: 'Eligibility Requirements',
                        icon: Icons.checklist_outlined,
                        child: Column(
                          children: eligibility.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _sectionCard(
                        title: 'Required Documents',
                        icon: Icons.attach_file_outlined,
                        child: Column(
                          children: requiredDocs.map((doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(doc, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Bar
                Card(
                  elevation: 0,
                  color: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isInitiatorOrAdmin) ...[
                          AppButton(
                            label: 'Track Approval Workflow',
                            icon: Icons.track_changes_outlined,
                            isOutlined: true,
                            onPressed: () => Get.toNamed(
                                '/approvals/tracker/${circular['id']}'),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            label: 'Comparison Matrix',
                            icon: Icons.analytics_outlined,
                            isOutlined: true,
                            onPressed: () => Get.toNamed(
                                '/circulars/${circular['id']}/matrix'),
                          ),
                        ],
                        if (isVendor) ...[
                          AppButton(
                            label: 'Submit Bid / Quotation',
                            icon: Icons.gavel_outlined,
                            onPressed: () => Get.toNamed(
                                '/circulars/${circular['id']}/bid'),
                          ),
                        ],
                        if (isGuest) ...[
                          OutlinedButton.icon(
                            onPressed: () => Get.toNamed(
                                '/login?redirect=/circulars/${circular['id']}/bid'),
                            icon: const Icon(Icons.login, size: 16),
                            label: const Text('Sign In to Bid'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/vendor/register'),
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text('Register as Vendor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBlock(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
