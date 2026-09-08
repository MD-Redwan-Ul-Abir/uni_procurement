import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Vendor Dashboard — Isolated vendor landing page with summary stats,
/// dedicated My Bids / Participation History section, and open tenders.
class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Vendor Dashboard',
      selectedIndex: 0,
      body: Obx(() {
        final db = Get.find<DummyDatabaseService>();
        final storage = Get.find<StorageService>();
        Map<String, dynamic>? currentUser = storage.cachedUser;
        currentUser ??= db.users.firstWhereOrNull((u) => u['role'] == 'vendor');
        final userId = currentUser?['id'];
        final userName = (currentUser?['name'] ?? '').toString().toLowerCase();
        final userEmail = (currentUser?['email'] ?? '').toString().toLowerCase();

        final currencyFmt =
            NumberFormat.currency(symbol: '\$', decimalDigits: 0);

        // Filter bids strictly to this vendor's activity
        final myBids = db.bids.where((b) {
          final bVendorId = b['vendor_id'];
          final bVendorName = (b['vendor_name'] ?? '').toString().toLowerCase();
          final bVendorEmail = (b['vendor_email'] ?? '').toString().toLowerCase();

          return (userId != null && bVendorId == userId) ||
              (userName.isNotEmpty && bVendorName == userName) ||
              (userEmail.isNotEmpty && bVendorEmail == userEmail);
        }).toList();

        // Stats calculation
        final totalBids = myBids.length;
        final awardedBids = myBids.where((b) {
          final s = (b['status'] ?? '').toString().toUpperCase();
          return s == 'AWARDED';
        }).length;
        final underReviewBids = myBids.where((b) {
          final s = (b['status'] ?? '').toString().toUpperCase();
          return s == 'UNDER_REVIEW' || s == 'RECOMMENDED' || s == 'EVALUATED' || s == 'SUBMITTED';
        }).length;

        // Open tenders available for bidding
        final openCirculars = db.circulars.where((c) {
          final s = (c['status'] ?? '').toString().toUpperCase();
          return s == 'PUBLISHED';
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${currentUser?['name'] ?? 'Vendor'}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your active quotations, participation history, and new procurement tenders.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Summary Stat Cards
              ResponsiveBuilder(
                mobile: (_) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Available Tenders',
                            value: '${openCirculars.length}',
                            icon: Icons.campaign_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'My Bids',
                            value: '$totalBids',
                            icon: Icons.gavel_outlined,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Under Review',
                            value: '$underReviewBids',
                            icon: Icons.pending_actions_outlined,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Awarded Contracts',
                            value: '$awardedBids',
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                desktop: (_) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Available Tenders',
                        value: '${openCirculars.length}',
                        icon: Icons.campaign_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'My Submitted Bids',
                        value: '$totalBids',
                        icon: Icons.gavel_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Under Evaluation',
                        value: '$underReviewBids',
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Awarded Contracts',
                        value: '$awardedBids',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Dedicated Section: My Bids & Participation History ──
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history_outlined,
                                  color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'My Bids & Participation History',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (myBids.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => Get.toNamed('/vendor/my-bids'),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('View All Bids'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (myBids.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              Text(
                                'No bids submitted yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Explore active tenders below and submit your competitive quotation.',
                                style: TextStyle(
                                    color: AppColors.textTertiary, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                label: 'Browse Open Circulars',
                                icon: Icons.campaign_outlined,
                                onPressed: () => Get.toNamed('/circulars'),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myBids.take(4).length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final bid = myBids[index];
                            final id = bid['id'] as String? ?? '';
                            final circularTitle =
                                bid['circular_title'] as String? ?? '';
                            final circularId =
                                bid['circular_id'] as String? ?? '';
                            final amount = (bid['quoted_amount'] as num?)
                                    ?.toDouble() ??
                                0.0;
                            final date =
                                bid['submission_date'] as String? ?? '';
                            final status =
                                bid['status'] as String? ?? 'SUBMITTED';
                            final deliveryDays =
                                (bid['delivery_days'] as num?)?.toInt() ?? 30;

                            Color statusColor = AppColors.info;
                            if (status == 'AWARDED') {
                              statusColor = AppColors.success;
                            } else if (status == 'RECOMMENDED') {
                              statusColor = AppColors.primary;
                            } else if (status == 'UNDER_REVIEW') {
                              statusColor = AppColors.warning;
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.gavel,
                                      color: statusColor, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• $circularId',
                                            style: TextStyle(
                                              color: AppColors.textTertiary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        circularTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quoted: ${currencyFmt.format(amount)} • Delivery: $deliveryDays days • Submitted: $date',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Section: Open Circulars For Bidding ──
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.campaign_outlined,
                                  color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Open Procurement Opportunities',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => Get.toNamed('/circulars'),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (openCirculars.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No open circulars currently available.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: openCirculars.take(4).length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final c = openCirculars[index];
                            final id = c['id'] as String? ?? '';
                            final title = c['title'] as String? ?? '';
                            final dept = c['department'] as String? ?? '';
                            final budget = (c['estimated_budget'] as num?) ?? 0;
                            final deadline =
                                c['submission_deadline'] as String? ??
                                    c['deadline'] as String? ??
                                    'TBD';

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tender ID: $id • Dept: $dept • Budget: ${currencyFmt.format(budget)}',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Submission Deadline: $deadline',
                                        style: TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AppButton(
                                  label: 'View & Bid',
                                  icon: Icons.gavel_outlined,
                                  onPressed: () =>
                                      Get.toNamed('/circulars/$id'),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
