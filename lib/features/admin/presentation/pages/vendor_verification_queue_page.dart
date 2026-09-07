import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';

class VendorVerificationQueuePage extends StatefulWidget {
  const VendorVerificationQueuePage({super.key});

  @override
  State<VendorVerificationQueuePage> createState() => _VendorVerificationQueuePageState();
}

class _VendorVerificationQueuePageState extends State<VendorVerificationQueuePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'PENDING';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();

    return AdaptiveScaffold(
      title: 'Vendor Verification Queue',
      selectedIndex: 2,
      body: Obx(() {
        final allVendors = db.vendorVerifications;
        final pendingCount = allVendors.where((v) => v['status'] == 'PENDING').length;
        final verifiedCount = allVendors.where((v) => v['status'] == 'ACTIVE').length;

        final filtered = allVendors.where((v) {
          final matchesStatus = _selectedStatus == 'ALL' || v['status'] == _selectedStatus;
          final q = _searchQuery.toLowerCase().trim();
          final matchesSearch = q.isEmpty ||
              (v['company_name']?.toString().toLowerCase().contains(q) ?? false) ||
              (v['trade_license_number']?.toString().toLowerCase().contains(q) ?? false) ||
              (v['contact_person']?.toString().toLowerCase().contains(q) ?? false) ||
              (v['email']?.toString().toLowerCase().contains(q) ?? false);
          return matchesStatus && matchesSearch;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Minimalist Overview Stats
                      _buildSummaryStats(
                        screenWidth: screenWidth,
                        totalCount: allVendors.length,
                        pendingCount: pendingCount,
                        verifiedCount: verifiedCount,
                      ),

                      const SizedBox(height: 20),

                      // Section 2: Search Input
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search vendors by company name, license number, or contact...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBg,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),

                      const SizedBox(height: 16),

                      // Section 3: Horizontal Filter Tabs (Scrollable on small screens)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('PENDING', 'Pending Verification ($pendingCount)'),
                            const SizedBox(width: 8),
                            _buildFilterChip('ACTIVE', 'Verified & Active ($verifiedCount)'),
                            const SizedBox(width: 8),
                            _buildFilterChip('ALL', 'All Vendors (${allVendors.length})'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 4: Results Count Header
                      Text(
                        filtered.isEmpty
                            ? 'No applications matching criteria'
                            : 'Showing ${filtered.length} vendor applications',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Section 5: Vendor Cards
                      if (filtered.isEmpty)
                        const EmptyState(
                          icon: Icons.verified_user_outlined,
                          title: 'No Vendors Found',
                          subtitle: 'No vendor applications match your filter or search term.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final vendor = filtered[index];
                            return _buildVendorCard(
                              context: context,
                              db: db,
                              vendor: vendor,
                              isDesktop: isDesktop,
                            );
                          },
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

  // ── Summary Stats ──
  Widget _buildSummaryStats({
    required double screenWidth,
    required int totalCount,
    required int pendingCount,
    required int verifiedCount,
  }) {
    final stats = [
      _StatItem(
        label: 'Awaiting Action',
        value: '$pendingCount Queued',
        subtext: 'Requires document inspection',
        icon: Icons.hourglass_top_outlined,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
      ),
      _StatItem(
        label: 'Verified Suppliers',
        value: '$verifiedCount Verified',
        subtext: 'Active university vendors',
        icon: Icons.check_circle_outline,
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFF0FDF4),
      ),
      _StatItem(
        label: 'Total Enrolled',
        value: '$totalCount Vendors',
        subtext: 'Registered vendor portal database',
        icon: Icons.storefront_outlined,
        color: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: 0.08),
      ),
    ];

    if (screenWidth >= 768) {
      return Row(
        children: stats.map((s) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _buildStatTile(s),
          ),
        )).toList(),
      );
    } else {
      return Column(
        children: stats.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildStatTile(s),
        )).toList(),
      );
    }
  }

  Widget _buildStatTile(_StatItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chip Widget ──
  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor: AppColors.cardBg,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  // ── Responsive Vendor Card ──
  Widget _buildVendorCard({
    required BuildContext context,
    required DummyDatabaseService db,
    required Map<String, dynamic> vendor,
    required bool isDesktop,
  }) {
    final id = vendor['id'] as int;
    final companyName = vendor['company_name'] as String? ?? '';
    final contactPerson = vendor['contact_person'] as String? ?? '';
    final phone = vendor['phone'] as String? ?? '';
    final email = vendor['email'] as String? ?? '';
    final tradeLicense = vendor['trade_license_number'] as String? ?? '';
    final taxId = vendor['tax_id'] as String? ?? '';
    final status = vendor['status'] as String? ?? 'PENDING';
    final regDate = vendor['registration_date'] as String? ?? '';
    final isPending = status == 'PENDING';

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.hourglass_top_outlined : Icons.check_circle_outlined,
            size: 13,
            color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
          ),
          const SizedBox(width: 5),
          Text(
            isPending ? 'PENDING VERIFICATION' : 'VERIFIED SUPPLIER',
            style: TextStyle(
              color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Company Name & Status Badge
            isDesktop
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                        child: Text(
                          companyName.isNotEmpty ? companyName[0].toUpperCase() : 'V',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Vendor ID: #$id • Submitted: $regDate',
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      badge,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            child: Text(
                              companyName.isNotEmpty ? companyName[0].toUpperCase() : 'V',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              companyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            'ID #$id • $regDate',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                          ),
                          badge,
                        ],
                      ),
                    ],
                  ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // Metadata Grid (Wrap for responsive flow)
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _buildMetaItem(Icons.person_outline, 'Contact Person', contactPerson),
                _buildMetaItem(Icons.phone_outlined, 'Phone', phone),
                _buildMetaItem(Icons.email_outlined, 'Email', email),
                _buildMetaItem(Icons.badge_outlined, 'Trade License', tradeLicense),
                _buildMetaItem(Icons.receipt_long_outlined, 'TIN', taxId),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Bottom Actions: Responsive layout
            isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Inspect Documents', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Get.toNamed('/admin/vendor-verification/detail?id=$id'),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Verify & Activate',
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            db.updateVendorVerificationStatus(id, 'ACTIVE');
                            AppToast.success(
                              title: 'Vendor Verified',
                              description: '$companyName is now verified and active.',
                            );
                          },
                        ),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Inspect Documents'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Get.toNamed('/admin/vendor-verification/detail?id=$id'),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Verify & Activate',
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            db.updateVendorVerificationStatus(id, 'ACTIVE');
                            AppToast.success(
                              title: 'Vendor Verified',
                              description: '$companyName is now verified and active.',
                            );
                          },
                        ),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
