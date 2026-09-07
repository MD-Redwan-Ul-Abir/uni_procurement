import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/empty_state.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'ALL';

  final List<String> _roles = [
    'ALL',
    'admin',
    'initiator',
    'approver_dept_head',
    'approver_dean',
    'approver_registrar',
    'finance',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRole(String role) {
    switch (role) {
      case 'admin':
        return 'System Admin';
      case 'initiator':
        return 'Tender Initiator';
      case 'approver_dept_head':
        return 'Dept Head';
      case 'approver_dean':
        return 'Dean Approver';
      case 'approver_registrar':
        return 'Registrar Approver';
      case 'finance':
        return 'Finance Officer';
      default:
        return role.toUpperCase();
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'approver_dept_head':
      case 'approver_dean':
      case 'approver_registrar':
        return Icons.verified_user_outlined;
      case 'finance':
        return Icons.account_balance_outlined;
      default:
        return Icons.edit_document;
    }
  }

  // Refined institutional palette: minimal, clean, theme-aligned
  Color _roleBadgeBg(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFEFF6FF); // Soft royal blue
      case 'approver_dept_head':
      case 'approver_dean':
      case 'approver_registrar':
        return const Color(0xFFF1F5F9); // Neutral slate
      case 'finance':
        return const Color(0xFFF0FDF4); // Subtle mint
      default:
        return const Color(0xFFF8FAFC); // Clean cloud grey
    }
  }

  Color _roleBadgeText(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFF1D4ED8); // Deep blue
      case 'approver_dept_head':
      case 'approver_dean':
      case 'approver_registrar':
        return const Color(0xFF334155); // Slate dark
      case 'finance':
        return const Color(0xFF15803D); // Forest green
      default:
        return const Color(0xFF475569); // Slate grey
    }
  }

  Color _roleBadgeBorder(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFBFDBFE);
      case 'approver_dept_head':
      case 'approver_dean':
      case 'approver_registrar':
        return const Color(0xFFCBD5E1);
      case 'finance':
        return const Color(0xFFBBF7D0);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();

    return AdaptiveScaffold(
      title: 'User Management',
      selectedIndex: 1,
      body: Obx(() {
        final allUsers = db.adminUsers;

        final filtered = allUsers.where((u) {
          final matchesRole = _selectedRole == 'ALL' || u['role'] == _selectedRole;
          final q = _searchQuery.toLowerCase().trim();
          final matchesSearch = q.isEmpty ||
              (u['name']?.toString().toLowerCase().contains(q) ?? false) ||
              (u['email']?.toString().toLowerCase().contains(q) ?? false) ||
              (u['department']?.toString().toLowerCase().contains(q) ?? false);
          return matchesRole && matchesSearch;
        }).toList();

        // Metrics calculations
        final totalCount = allUsers.length;
        final activeCount = allUsers.where((u) => u['status'] == 'ACTIVE').length;
        final approverCount = allUsers.where((u) => (u['role'] as String? ?? '').startsWith('approver') || u['role'] == 'admin').length;
        final departmentsCount = allUsers.map((u) => u['department']).toSet().length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= 850;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Executive KPI Metrics Strip
                      _buildMetricsStrip(
                        screenWidth: screenWidth,
                        totalCount: totalCount,
                        activeCount: activeCount,
                        approverCount: approverCount,
                        departmentsCount: departmentsCount,
                      ),

                      const SizedBox(height: 20),

                      // Section 2: Search & Action Toolbar
                      _buildActionToolbar(
                        context: context,
                        db: db,
                        isDesktop: isDesktop,
                        allUsersCount: allUsers.length,
                      ),

                      const SizedBox(height: 16),

                      // Section 3: Horizontal Role Filters
                      _buildRoleFilters(allUsers),

                      const SizedBox(height: 20),

                      // Section 4: Results Count Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            filtered.isEmpty
                                ? 'No users matching criteria'
                                : 'Showing ${filtered.length} of $totalCount registered staff members',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedRole != 'ALL')
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedRole = 'ALL';
                                });
                              },
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Reset Filters', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Section 5: Responsive User List
                      if (filtered.isEmpty)
                        const EmptyState(
                          icon: Icons.people_outline,
                          title: 'No Users Found',
                          subtitle: 'Try adjusting your search query or role filter to find active personnel.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final user = filtered[index];
                            return _buildUserCard(
                              context: context,
                              db: db,
                              user: user,
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

  // ── Executive Summary Metrics Strip ──
  Widget _buildMetricsStrip({
    required double screenWidth,
    required int totalCount,
    required int activeCount,
    required int approverCount,
    required int departmentsCount,
  }) {
    final metrics = [
      _MetricData(
        label: 'Total Directory',
        value: '$totalCount Staff',
        subtext: 'Registered accounts',
        icon: Icons.badge_outlined,
      ),
      _MetricData(
        label: 'Active Accounts',
        value: '$activeCount Active',
        subtext: '${totalCount - activeCount} suspended/inactive',
        icon: Icons.check_circle_outline,
        valueColor: AppColors.success,
      ),
      _MetricData(
        label: 'Governance Officers',
        value: '$approverCount Reviewers',
        subtext: 'Dean, Registrar, Admin & Heads',
        icon: Icons.security_outlined,
      ),
      _MetricData(
        label: 'Campus Departments',
        value: '$departmentsCount Units',
        subtext: 'Operational procurement units',
        icon: Icons.apartment_outlined,
      ),
    ];

    if (screenWidth >= 900) {
      return Row(
        children: metrics.map((m) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: _buildMetricTile(m),
        ))).toList(),
      );
    } else if (screenWidth >= 550) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricTile(metrics[0])),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile(metrics[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile(metrics[2])),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile(metrics[3])),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: metrics.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMetricTile(m),
        )).toList(),
      );
    }
  }

  Widget _buildMetricTile(_MetricData data) {
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
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: data.valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Toolbar (Search + Add Button) ──
  Widget _buildActionToolbar({
    required BuildContext context,
    required DummyDatabaseService db,
    required bool isDesktop,
    required int allUsersCount,
  }) {
    final searchWidget = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by staff name, email, or department...',
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
    );

    final addButton = AppButton(
      label: 'Add Staff Member',
      icon: Icons.person_add_outlined,
      onPressed: () => _showAddUserDialog(context, db),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: searchWidget),
          const SizedBox(width: 14),
          addButton,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchWidget,
          const SizedBox(height: 10),
          addButton,
        ],
      );
    }
  }

  // ── Horizontal Role Filter Chips ──
  Widget _buildRoleFilters(List<Map<String, dynamic>> allUsers) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _roles.map((role) {
          final isSelected = _selectedRole == role;
          final count = role == 'ALL'
              ? allUsers.length
              : allUsers.where((u) => u['role'] == role).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${_formatRole(role)} ($count)'),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedRole = role),
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
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── User Card Component ──
  Widget _buildUserCard({
    required BuildContext context,
    required DummyDatabaseService db,
    required Map<String, dynamic> user,
    required bool isDesktop,
  }) {
    final id = user['id'] as int;
    final name = user['name'] as String? ?? '';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? '';
    final dept = user['department'] as String? ?? '';
    final status = user['status'] as String? ?? 'ACTIVE';
    final lastLogin = user['last_login'] as String? ?? 'Never';
    final isActive = status == 'ACTIVE';

    final roleBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _roleBadgeBg(role),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _roleBadgeBorder(role)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _roleIcon(role),
            size: 13,
            color: _roleBadgeText(role),
          ),
          const SizedBox(width: 5),
          Text(
            _formatRole(role),
            style: TextStyle(
              color: _roleBadgeText(role),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    final statusWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.success : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.success : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        AppSwitch(
          value: isActive,
          activeColor: AppColors.primary,
          onChanged: (val) {
            db.toggleAdminUserStatus(id);
            AppToast.info(
              title: 'Account Status Updated',
              description: '$name is now ${val ? "ACTIVE" : "INACTIVE"}.',
            );
          },
        ),
      ],
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: isDesktop
            // ── Desktop Layout: Spacious, aligned tabular card ──
            ? Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Email
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Department & Last Login
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                dept,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.schedule_outlined, size: 12, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              'Last Login: $lastLogin',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Role Badge
                  roleBadge,

                  const SizedBox(width: 24),

                  // Active Switch
                  statusWidget,
                ],
              )
            // ── Mobile/Tablet Layout: Clean stacked card without overflow ──
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      roleBadge,
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active: $lastLogin',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      statusWidget,
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // ── Sleek Add User Dialog ──
  void _showAddUserDialog(BuildContext context, DummyDatabaseService db) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    String selectedRole = 'initiator';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBg,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add University Staff',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provision an administrative staff account with specific procurement role permissions.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Dr. Sarah Ahmed',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'University Email *',
                    hintText: 'user@university.edu',
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: deptCtrl,
                  decoration: InputDecoration(
                    labelText: 'Academic / Administrative Department',
                    hintText: 'e.g. Computer Science & Engineering',
                    prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Procurement Role *',
                    prefixIcon: const Icon(Icons.shield_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'initiator', child: Text('Tender Initiator')),
                    DropdownMenuItem(value: 'approver_dept_head', child: Text('Dept Head Approver')),
                    DropdownMenuItem(value: 'approver_dean', child: Text('Dean Approver')),
                    DropdownMenuItem(value: 'approver_registrar', child: Text('Registrar Approver')),
                    DropdownMenuItem(value: 'finance', child: Text('Finance Officer')),
                    DropdownMenuItem(value: 'admin', child: Text('System Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedRole = val;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: 'Create Account',
                      icon: Icons.check,
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                          AppToast.error(
                            title: 'Required Fields',
                            description: 'Please provide both full name and university email.',
                          );
                          return;
                        }
                        final newUser = {
                          'id': DateTime.now().millisecondsSinceEpoch % 10000,
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'role': selectedRole,
                          'department': deptCtrl.text.trim().isEmpty
                              ? 'General Administration'
                              : deptCtrl.text.trim(),
                          'status': 'ACTIVE',
                          'created_at': DateTime.now().toString().split(' ').first,
                          'last_login': 'Never',
                        };
                        db.adminUsers.insert(0, newUser);
                        Get.back();
                        AppToast.success(
                          title: 'Staff Account Created',
                          description: 'Account for ${newUser["name"]} successfully added.',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color? valueColor;

  const _MetricData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    this.valueColor,
  });
}
