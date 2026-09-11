import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';

/// Initiator Dashboard — summary stats, recent circulars, quick actions.
class InitiatorDashboardPage extends StatelessWidget {
  const InitiatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Initiator Dashboard',
      selectedIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/initiator/circulars/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Circular'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final db = Get.find<DummyDatabaseService>();
        final circulars = db.circulars;
        final currencyFmt =
            NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

        // Compute stats.
        final total = circulars.length;
        final active = circulars.where((c) {
          final s = (c['status'] ?? '').toString().toUpperCase();
          return s == 'PUBLISHED' || s == 'EVALUATION';
        }).length;
        final pending = circulars.where((c) {
          final s = (c['status'] ?? '').toString().toUpperCase();
          return s.startsWith('PENDING');
        }).length;
        final awarded = circulars.where((c) {
          final s = (c['status'] ?? '').toString().toUpperCase();
          return s == 'AWARDED' || s == 'APPROVED';
        }).length;

        // Recent circulars (sorted by date, latest first, max 5).
        final sorted = List<Map<String, dynamic>>.from(circulars);
        sorted.sort((a, b) {
          final da = a['deadline'] ?? a['created_at'] ?? '';
          final db2 = b['deadline'] ?? b['created_at'] ?? '';
          return db2.toString().compareTo(da.toString());
        });
        final recent = sorted.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header.
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s an overview of your procurement activity.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),

              // Stat cards.
              ResponsiveBuilder(
                mobile: (_) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Circulars',
                            value: '$total',
                            icon: Icons.description_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Active',
                            value: '$active',
                            icon: Icons.campaign_outlined,
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
                            title: 'Pending Approval',
                            value: '$pending',
                            icon: Icons.pending_actions_outlined,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Awarded',
                            value: '$awarded',
                            icon: Icons.emoji_events_outlined,
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
                        title: 'Total Circulars',
                        value: '$total',
                        icon: Icons.description_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Active',
                        value: '$active',
                        icon: Icons.campaign_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending Approval',
                        value: '$pending',
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Awarded',
                        value: '$awarded',
                        icon: Icons.emoji_events_outlined,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recent circulars section.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Circulars',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.toNamed('/circulars'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (recent.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No circulars yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Get.toNamed('/initiator/circulars/new'),
                          child: const Text('Create your first circular'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recent.map((c) {
                  final title = c['title'] ?? 'Untitled';
                  final dept = c['department'] ?? '';
                  final status = c['status'] ?? 'DRAFT';
                  final budget = c['estimated_budget'] as num?;
                  final id = c['id'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Get.toNamed('/circulars/$id'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.description_outlined,
                                    color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$dept${budget != null ? ' • ${currencyFmt.format(budget)}' : ''}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              StatusChip(
                                label: CircularStatus.fromString(
                                        status.toString())
                                    .label,
                                color: _statusColor(status.toString()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Quick action buttons.
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'New Circular',
                    onTap: () => Get.toNamed('/circulars/create'),
                  ),
                  _QuickActionButton(
                    icon: Icons.track_changes_outlined,
                    label: 'Track Approvals',
                    onTap: () => Get.toNamed('/approvals'),
                  ),
                  _QuickActionButton(
                    icon: Icons.history_outlined,
                    label: 'View History',
                    onTap: () => Get.toNamed('/initiator/history'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PUBLISHED':
        return AppColors.info;
      case 'EVALUATION':
        return AppColors.warning;
      case 'APPROVED':
      case 'AWARDED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        if (status.toUpperCase().startsWith('PENDING')) {
          return AppColors.warning;
        }
        return AppColors.textSecondary;
    }
  }
}

// ── Stat Card ──

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button ──

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
