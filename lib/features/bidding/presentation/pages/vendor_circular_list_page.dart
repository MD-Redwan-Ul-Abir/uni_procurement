import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';

/// Vendor-specific circular list — only shows published/active circulars.
/// Vendors cannot see drafts, and there is no "Create Circular" FAB.
class VendorCircularListPage extends StatefulWidget {
  const VendorCircularListPage({super.key});

  @override
  State<VendorCircularListPage> createState() => _VendorCircularListPageState();
}

class _VendorCircularListPageState extends State<VendorCircularListPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'ALL';

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
      title: 'Active Circulars',
      selectedIndex: 1,
      body: Obx(() {
        final query = _searchController.text.trim().toLowerCase();

        // Only show published circulars that are open for bidding.
        final active = db.circulars.where((c) {
          final status = (c['status'] ?? '').toString().toUpperCase();
          final isActive = status == 'PUBLISHED' || status == 'EVALUATION';
          if (!isActive) return false;

          // Category filter.
          if (_selectedCategory != 'ALL') {
            final category =
                (c['category'] ?? c['department'] ?? '').toString();
            if (category != _selectedCategory) return false;
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

        // Extract unique departments for filter chips.
        final departments = db.circulars
            .map((c) => (c['department'] ?? '').toString())
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

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
                      hintText: 'Search circulars by title, department...',
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
                  if (departments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('All Departments'),
                              selected: _selectedCategory == 'ALL',
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = 'ALL'),
                              selectedColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _selectedCategory == 'ALL'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: _selectedCategory == 'ALL'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...departments.map((d) {
                            final selected = _selectedCategory == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(d),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _selectedCategory = d),
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
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Results count.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    '${active.length} active circular${active.length == 1 ? '' : 's'} available',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Circular cards.
            Expanded(
              child: active.isEmpty
                  ? const EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'No Active Circulars',
                      subtitle:
                          'There are currently no tenders open for bidding. Check back later.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: active.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = active[index];
                        final title = c['title'] ?? 'Untitled';
                        final dept = c['department'] ?? '';
                        final status = c['status'] ?? 'PUBLISHED';
                        final budget = c['estimated_budget'] as num?;
                        final deadline = c['deadline'] ?? '';
                        final id = c['id'] ?? '';
                        final bidsCount = c['bid_count'] as int? ?? 0;

                        return Material(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                Get.toNamed('/vendor/circulars/$id'),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      AppColors.border.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.info
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                            Icons.description_outlined,
                                            color: AppColors.info,
                                            size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dept.toString(),
                                              style: TextStyle(
                                                color:
                                                    AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusChip(
                                        label: status
                                                    .toString()
                                                    .toUpperCase() ==
                                                'PUBLISHED'
                                            ? 'Open for Bids'
                                            : CircularStatus.fromString(
                                                    status.toString())
                                                .label,
                                        color: AppColors.success,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      if (budget != null)
                                        _InfoPill(
                                          icon: Icons.payments_outlined,
                                          text: currencyFmt.format(budget),
                                        ),
                                      if (deadline
                                          .toString()
                                          .isNotEmpty)
                                        _InfoPill(
                                          icon:
                                              Icons.calendar_today_outlined,
                                          text:
                                              'Due: ${deadline.toString()}',
                                        ),
                                      _InfoPill(
                                        icon: Icons.people_outline,
                                        text:
                                            '$bidsCount bid${bidsCount == 1 ? '' : 's'}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => Get.toNamed(
                                          '/vendor/circulars/$id'),
                                      icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 18),
                                      label: const Text('View & Bid'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.3)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                      ),
                                    ),
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
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
