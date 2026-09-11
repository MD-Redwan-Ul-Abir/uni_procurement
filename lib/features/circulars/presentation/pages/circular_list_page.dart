import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';

class CircularListPage extends StatefulWidget {
  const CircularListPage({super.key});

  @override
  State<CircularListPage> createState() => _CircularListPageState();
}

class _CircularListPageState extends State<CircularListPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final permission = Get.find<PermissionService>();
    final canCreate = permission.currentRole == UserRole.initiator ||
        permission.currentRole == UserRole.admin;
    final isVendorOrGuest = permission.currentRole == UserRole.vendor ||
        permission.currentRole == null;
    final isGuest = permission.currentRole == null;

    final selectedNavIndex = permission.currentRole == UserRole.vendor ? 1 : 1;
    final currencyFmt = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 0);

    return AdaptiveScaffold(
      title: isGuest ? 'Public Tenders Portal' : 'Active Procurement Circulars',
      selectedIndex: selectedNavIndex,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/initiator/circulars/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Circular'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: Obx(() {
        final query = _searchController.text.trim().toLowerCase();
        final filtered = db.circulars.where((c) {
          final status = (c['status'] ?? '').toString().toUpperCase();

          // Hide internal draft circulars from vendors and public guests
          if (isVendorOrGuest && status == 'DRAFT') return false;

          final title = (c['title'] ?? '').toString().toLowerCase();
          final dept = (c['department'] ?? '').toString().toLowerCase();
          final id = (c['id'] ?? '').toString().toLowerCase();
          final matchesQuery = query.isEmpty ||
              title.contains(query) ||
              dept.contains(query) ||
              id.contains(query);

          final matchesStatus = _selectedStatus == 'ALL' ||
              (_selectedStatus == 'PENDING' &&
                  (status.contains('PENDING') || status == 'EVALUATION')) ||
              status == _selectedStatus;

          return matchesQuery && matchesStatus;
        }).toList();

        return Column(
          children: [
            if (isGuest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primaryDark.withValues(alpha: 0.12),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Public Procurement Portal',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Browse open university circulars. Register as a vendor to submit quotations.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Get.toNamed('/login'),
                          icon: const Icon(Icons.login, size: 16),
                          label: const Text('Sign In'),
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
                    ),
                  ],
                ),
              ),
            // Filter / Search Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.cardBg,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search by title, department or circular ID...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusFilterChip('ALL', 'All Tenders'),
                        _statusFilterChip('PUBLISHED', 'Published'),
                        _statusFilterChip('EVALUATION', 'Evaluation'),
                        _statusFilterChip('PENDING', 'In Approval'),
                        _statusFilterChip('APPROVED', 'Approved'),
                        _statusFilterChip('AWARDED', 'Awarded'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Results List
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No Circulars Found',
                      subtitle: 'Try changing your search keywords or status filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final id = item['id'] as String? ?? '';
                        final title = item['title'] as String? ?? '';
                        final dept = item['department'] as String? ?? '';
                        final category = item['category'] as String? ?? 'General';
                        final budget = (item['estimated_budget'] as num?)?.toDouble() ?? 0.0;
                        final statusStr = item['status'] as String? ?? 'DRAFT';
                        final deadline = item['submission_deadline'] as String? ?? 'TBD';
                        final bidCount = item['bid_count'] as int? ?? 0;
                        final statusEnum = CircularStatus.fromString(statusStr);

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Get.toNamed('/circulars/detail?id=$id'),
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
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    id,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.border
                                                        .withValues(alpha: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    category,
                                                    style: const TextStyle(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      StatusChip.fromCircularStatus(statusEnum),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item['description'] as String? ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.account_balance,
                                              size: 16, color: AppColors.textTertiary),
                                          const SizedBox(width: 6),
                                          Text(dept,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.attach_money,
                                              size: 16, color: AppColors.primary),
                                          Text(
                                            currencyFmt.format(budget),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.event_outlined,
                                              size: 16, color: AppColors.textTertiary),
                                          const SizedBox(width: 6),
                                          Text('Deadline: $deadline',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.gavel_outlined,
                                              size: 16, color: AppColors.info),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$bidCount Bids',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.info,
                                            ),
                                          ),
                                        ],
                                      ),
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

  Widget _statusFilterChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
        },
      ),
    );
  }
}
