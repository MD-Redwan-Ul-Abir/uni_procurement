import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class MyBidsPage extends StatelessWidget {
  const MyBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final storage = Get.find<StorageService>();
    final permission = Get.find<PermissionService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'My Bids & Participation History',
      selectedIndex: 2,
      body: Obx(() {
        final currentUser = storage.cachedUser;
        final userId = currentUser?['id'];
        final userName = (currentUser?['name'] ?? '').toString().toLowerCase();
        final userEmail = (currentUser?['email'] ?? '').toString().toLowerCase();

        // Admin can see all bids; vendors only see their own bids
        final bids = (permission.currentRole == UserRole.admin)
            ? db.bids
            : db.bids.where((b) {
                final bVendorId = b['vendor_id'];
                final bVendorName =
                    (b['vendor_name'] ?? '').toString().toLowerCase();
                final bVendorEmail =
                    (b['vendor_email'] ?? '').toString().toLowerCase();

                return (userId != null && bVendorId == userId) ||
                    (userName.isNotEmpty && bVendorName == userName) ||
                    (userEmail.isNotEmpty && bVendorEmail == userEmail);
              }).toList();

        if (bids.isEmpty) {
          return const EmptyState(
            icon: Icons.gavel_outlined,
            title: 'No Bids Submitted Yet',
            subtitle: 'Explore active circulars and submit your quotations.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: bids.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final bid = bids[index];
            final id = bid['id'] as String? ?? '';
            final circularTitle = bid['circular_title'] as String? ?? '';
            final circularId = bid['circular_id'] as String? ?? '';
            final amount = (bid['quoted_amount'] as num?)?.toDouble() ?? 0.0;
            final date = bid['submission_date'] as String? ?? '';
            final status = bid['status'] as String? ?? 'SUBMITTED';
            final deliveryDays = bid['delivery_days'] as int? ?? 30;
            final techScore = bid['technical_score'] as num?;
            final vendorName = bid['vendor_name'] as String? ?? 'Vendor';
            final docs = (bid['documents'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            Color statusColor = AppColors.info;
            if (status == 'AWARDED') statusColor = AppColors.success;
            if (status == 'RECOMMENDED') statusColor = AppColors.primary;
            if (status == 'UNDER_REVIEW') statusColor = AppColors.warning;

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
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• Tender: $circularId',
                                    style: TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                circularTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submitted by: $vendorName',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 32,
                      runSpacing: 10,
                      children: [
                        _infoItem('Quoted Price', currencyFmt.format(amount), isBold: true),
                        _infoItem('Submission Date', date),
                        _infoItem('Delivery Promise', '$deliveryDays Days'),
                        if (techScore != null)
                          _infoItem('Tech Evaluation', '$techScore / 100'),
                      ],
                    ),
                    if (docs.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: docs.map((d) {
                          return Chip(
                            avatar: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                            label: Text(
                              '${d['name']} (${(d['size_kb'] / 1024).toStringAsFixed(1)}MB)',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: AppColors.scaffoldBg,
                            side: const BorderSide(color: AppColors.border),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: 'View Tender',
                          icon: Icons.open_in_new,
                          isOutlined: true,
                          onPressed: () => Get.toNamed('/circulars/detail?id=$circularId'),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Comparison Matrix',
                          icon: Icons.analytics_outlined,
                          isOutlined: true,
                          onPressed: () => Get.toNamed('/comparison-matrix?id=$circularId'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _infoItem(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
