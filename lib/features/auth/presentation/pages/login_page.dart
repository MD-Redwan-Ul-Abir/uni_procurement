import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/auth_controller.dart';

/// Redesigned Login & Public Circulars Portal Page.
/// Desktop: 1/3 left side (Deep Blue branding + Login Form) and
/// 2/3 right side (White public ongoing procurement circulars portal).
/// Tablet / Mobile: Responsive layout with clean tab switching.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _mobileSelectedTab = 0; // 0 = Sign In, 1 = Public Tenders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: ResponsiveBuilder(
        desktop: (_) => const _DesktopSplitLayout(),
        tablet: (ctx) {
          final width = MediaQuery.sizeOf(ctx).width;
          if (width >= 960) {
            return const _DesktopSplitLayout(isTablet: true);
          }
          return _MobileAndTabletTabLayout(
            selectedTab: _mobileSelectedTab,
            onTabChanged: (index) => setState(() => _mobileSelectedTab = index),
          );
        },
        mobile: (_) => _MobileAndTabletTabLayout(
          selectedTab: _mobileSelectedTab,
          onTabChanged: (index) => setState(() => _mobileSelectedTab = index),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop Split Layout (1/3 Blue Login Panel + 2/3 White Circulars Panel)
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopSplitLayout extends StatelessWidget {
  final bool isTablet;
  const _DesktopSplitLayout({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Blue Panel (approx 1/3 screen width)
        Expanded(
          flex: isTablet ? 38 : 34,
          child: const _BlueLoginSidePanel(),
        ),

        // Right White Panel (approx 2/3 screen width)
        Expanded(
          flex: isTablet ? 62 : 66,
          child: const _WhitePublicCircularsPanel(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left Blue Panel (1/3 width: Branding + Login Credentials & Form)
// ─────────────────────────────────────────────────────────────────────────────

class _BlueLoginSidePanel extends StatelessWidget {
  const _BlueLoginSidePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF091E47), // Deep SMUCT Navy
            Color(0xFF123E8A), // Royal Brand Blue
            Color(0xFF0B2558), // Rich Dark Navy
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background ambient circles
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main scrollable content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // University Branding Header
                    Row(
                      children: [
                        const AppLogo(size: 46),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SHANTO-MARIAM UNIVERSITY',
                                style: TextStyle(
                                  color: AppColors.accentLight.withValues(alpha: 0.95),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'E-Procurement',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                'Official E-Tendering & Purchasing Portal',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Crisp White Form Container
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const _LoginForm(),
                    ),

                    const SizedBox(height: 18),

                    // Institutional Trust / Security Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '256-Bit SSL Encrypted Procurement System',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right White Panel (2/3 width: Public Ongoing Procurement Circulars)
// ─────────────────────────────────────────────────────────────────────────────

class _WhitePublicCircularsPanel extends StatefulWidget {
  const _WhitePublicCircularsPanel();

  @override
  State<_WhitePublicCircularsPanel> createState() =>
      _WhitePublicCircularsPanelState();
}

class _WhitePublicCircularsPanelState
    extends State<_WhitePublicCircularsPanel> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );

    return Container(
      color: AppColors.scaffoldBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Header Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE PUBLIC NOTICES',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'No login required to view notices',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Public Ongoing Procurement Circulars',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Explore active tenders, equipment purchases, and university service contracts open for bids.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/circulars'),
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: const Text('Full Tender Portal'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Search & Filter row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              'Search tender title, category, department or ID...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Filter Chips: Only "All Notices" and "Open for Bids"
                Row(
                  children: [
                    _filterChip('ALL', 'All Notices'),
                    _filterChip('OPEN', 'Open for Bids'),
                  ],
                ),
              ],
            ),
          ),

          // ── Reactive Circulars List ──
          Expanded(
            child: Obx(() {
              final query = _searchController.text.trim().toLowerCase();

              // Only show public ongoing circulars (filter out draft)
              final filtered = db.circulars.where((c) {
                final status = (c['status'] ?? '').toString().toUpperCase();
                if (status == 'DRAFT') return false;

                final title = (c['title'] ?? '').toString().toLowerCase();
                final dept = (c['department'] ?? '').toString().toLowerCase();
                final id = (c['id'] ?? '').toString().toLowerCase();
                final category = (c['category'] ?? '').toString().toLowerCase();

                final matchesQuery = query.isEmpty ||
                    title.contains(query) ||
                    dept.contains(query) ||
                    id.contains(query) ||
                    category.contains(query);

                bool matchesFilter = true;
                if (_selectedFilter == 'OPEN' || _selectedFilter == 'PUBLISHED') {
                  matchesFilter = status == 'PUBLISHED';
                }

                return matchesQuery && matchesFilter;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No Circulars Found',
                      subtitle:
                          'No public circulars match your search or filter criteria.',
                      action: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedFilter = 'ALL';
                          });
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final id = item['id'] as String? ?? '';
                  final title = item['title'] as String? ?? '';
                  final dept = item['department'] as String? ?? '';
                  final category =
                      item['category'] as String? ?? 'General Procurement';
                  final budget =
                      (item['estimated_budget'] as num?)?.toDouble() ?? 0.0;
                  final deadline =
                      item['submission_deadline'] as String? ?? 'TBD';
                  final bidCount = item['bid_count'] as int? ?? 0;
                  final description = item['description'] as String? ?? '';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.toNamed('/circulars/detail?id=$id'),
                      hoverColor: AppColors.primary.withValues(alpha: 0.02),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header: ID Pill + Category (No internal status badges)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    id,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.sidebarBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Circular Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Department
                            Row(
                              children: [
                                const Icon(Icons.business_outlined,
                                    size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    dept,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Key Information Bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.borderLight, width: 1),
                              ),
                              child: Row(
                                children: [
                                  // Estimated Budget
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ESTIMATED BUDGET',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currencyFmt.format(budget),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: 1,
                                    height: 26,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(width: 10),

                                  // Submission Deadline
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SUBMISSION DEADLINE',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.event_outlined,
                                                size: 12,
                                                color: AppColors.textSecondary),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                deadline,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: 1,
                                    height: 26,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(width: 10),

                                  // Bids Count
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SUBMISSIONS',
                                        style: TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$bidCount ${bidCount == 1 ? "Bid" : "Bids"}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Card Action Footer
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => Get.toNamed(
                                    '/circulars/detail?id=$id'),
                                icon: const Icon(Icons.description_outlined,
                                    size: 14),
                                label: const Text('View Tender Specs'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filterKey;
          });
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile & Narrow Tablet Responsive Layout with Segmented Tab Switching
// ─────────────────────────────────────────────────────────────────────────────

class _MobileAndTabletTabLayout extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _MobileAndTabletTabLayout({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();

    return Column(
      children: [
        // Top Navigation & Segmented Switch Bar
        Container(
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.paddingOf(context).top + 10, 16, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF091E47), Color(0xFF123E8A)],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const AppLogo(size: 34),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'E-Procurement Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Segmented Tabs: [ Sign In ] vs [ Public Circulars (N) ]
              Obx(() {
                final publicCount = db.circulars
                    .where((c) =>
                        (c['status'] ?? '').toString().toUpperCase() != 'DRAFT')
                    .length;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          index: 0,
                          icon: Icons.lock_outline,
                          label: 'Sign In',
                          isActive: selectedTab == 0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _tabButton(
                          index: 1,
                          icon: Icons.campaign_outlined,
                          label: 'Public Tenders ($publicCount)',
                          isActive: selectedTab == 1,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Body Content
        Expanded(
          child: selectedTab == 0
              ? const _BlueLoginSidePanel()
              : const _WhitePublicCircularsPanel(),
        ),
      ],
    );
  }

  Widget _tabButton({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The Clean White Login Form Component
// ─────────────────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Obx(() => Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                'Sign in to your university account',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 18),

              // Email field
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hint: 'you@university.edu',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                errorText: controller.fieldErrors['email'],
                validator: Validators.email,
              ),
              const SizedBox(height: 14),

              // Password field
              AppTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                errorText: controller.fieldErrors['password'],
                validator: (value) =>
                    Validators.required(value, 'Password'),
              ),

              // Login error alert
              if (controller.loginError.value != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.loginError.value!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 6),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sign In button
              AppButton(
                label: 'Sign In',
                onPressed: controller.login,
                isLoading: controller.isLoading.value,
                width: double.infinity,
              ),

              const SizedBox(height: 16),

              // Showcase Demo Accounts (1-Tap Login)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Showcase Demo Accounts (1-Tap Login)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _demoChip(controller, 'Admin', 'admin@university.edu'),
                        _demoChip(
                            controller, 'Initiator', 'initiator@university.edu'),
                        _demoChip(
                            controller, 'Dept Head', 'depthead@university.edu'),
                        _demoChip(controller, 'Dean', 'dean@university.edu'),
                        _demoChip(
                            controller, 'Registrar', 'registrar@university.edu'),
                        _demoChip(
                            controller, 'Vendor', 'vendor@apextech.com'),
                        _demoChip(
                            controller, 'Finance', 'finance@university.edu'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Vendor registration link
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Are you a vendor? ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/vendor/register'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      'Register here',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _demoChip(AuthController controller, String label, String email) {
    return ActionChip(
      visualDensity: VisualDensity.compact,
      label: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      onPressed: () {
        controller.quickLogin(email, 'password123');
      },
    );
  }
}
