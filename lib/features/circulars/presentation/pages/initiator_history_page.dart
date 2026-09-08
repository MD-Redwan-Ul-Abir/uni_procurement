import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';

/// Initiator History — completed / awarded / rejected tenders.
class InitiatorHistoryPage extends StatefulWidget {
  const InitiatorHistoryPage({super.key});

  @override
  State<InitiatorHistoryPage> createState() => _InitiatorHistoryPageState();
}

class _InitiatorHistoryPageState extends State<InitiatorHistoryPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  static const _filters = ['ALL', 'AWARDED', 'APPROVED', 'REJECTED'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Completed Projects',
      selectedIndex: 4,
      body: Obx(() {
        final query = _searchController.text.trim().toLowerCase();
        final completed = db.circulars.where((c) {
          final status = (c['status'] ?? '').toString().toUpperCase();
          // Only show completed statuses.
          final isCompleted = status == 'AWARDED' ||
              status == 'APPROVED' ||
              status == 'REJECTED' ||
              status == 'COMPLETED';
          if (!isCompleted) return false;

          // Filter by selected status.
          if (_selectedFilter != 'ALL' && status != _selectedFilter) {
            return false;
          }

          // Search filter.
          if (query.isNotEmpty) {
            final title = (c['title'] ?? '').toString().toLowerCase();
            final dept = (c['department'] ?? '').toString().toLowerCase();
            final id = (c['id'] ?? '').toString().toLowerCase();
            return title.contains(query) ||
                dept.contains(query) ||
                id.contains(query);
          }

          return true;
        }).toList();

        return Column(
          children: [
            // Search + filter bar.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search completed projects...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.scaffoldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final selected = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f == 'ALL' ? 'All' : CircularStatus.fromString(f).label),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedFilter = f),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Results.
            Expanded(
              child: completed.isEmpty
                  ? const EmptyState(
                      icon: Icons.history_outlined,
                      title: 'No Completed Projects',
                      subtitle:
                          'Completed, awarded, and rejected tenders will appear here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: completed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = completed[index];
                        final title = c['title'] ?? 'Untitled';
                        final dept = c['department'] ?? '';
                        final status = c['status'] ?? 'DRAFT';
                        final budget = c['estimated_budget'] as num?;
                        final deadline = c['deadline'] ?? '';
                        final id = c['id'] ?? '';

                        return Material(
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
                                  color:
                                      AppColors.border.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                                  status.toString())
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _statusIcon(status.toString()),
                                          color: _statusColor(
                                              status.toString()),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              dept.toString(),
                                              style: TextStyle(
                                                color:
                                                    AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusChip(
                                        label:
                                            CircularStatus.fromString(
                                                    status.toString())
                                                .label,
                                        color: _statusColor(
                                            status.toString()),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (budget != null)
                                        _InfoPill(
                                          icon: Icons.payments_outlined,
                                          text: currencyFmt.format(budget),
                                        ),
                                      if (deadline.toString().isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        _InfoPill(
                                          icon: Icons.calendar_today_outlined,
                                          text: deadline.toString(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'AWARDED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'AWARDED':
        return Icons.emoji_events_outlined;
      case 'APPROVED':
        return Icons.check_circle_outline;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.history_outlined;
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
