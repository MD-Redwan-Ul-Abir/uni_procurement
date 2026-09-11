import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/permission_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import 'breakpoints.dart';

/// Navigation item for the sidebar/drawer.
class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final int badgeCount;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount = 0,
  });
}

/// The single shared shell used by every authenticated page.
///
/// - **Desktop (≥1200px):** permanent sidebar with full labels + content.
/// - **Tablet (600–1199px):** collapsible icon-only rail + content.
/// - **Mobile (<600px):** AppBar + Drawer + single-column content.
class AdaptiveScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int selectedIndex;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.selectedIndex = 0,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  bool _railExpanded = false;

  List<NavItem> get _navItems {
    final permission = Get.find<PermissionService>();
    return permission.navItemsForCurrentUser;
  }

  void _onNavTap(int index) {
    if (index < _navItems.length) {
      Get.toNamed(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = Breakpoints.fromWidth(constraints.maxWidth);

        switch (deviceType) {
          case DeviceType.desktop:
            return _buildDesktop(context);
          case DeviceType.tablet:
            return _buildTablet(context);
          case DeviceType.mobile:
            return _buildMobile(context);
        }
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Permanent sidebar with full labels.
          _DesktopSidebar(
            items: _navItems,
            selectedIndex: widget.selectedIndex,
            onTap: _onNavTap,
          ),
          // Vertical divider.
          const VerticalDivider(width: 1, thickness: 1),
          // Content area.
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, showMenuButton: false),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Collapsible rail — icons only by default, expands on hover.
          MouseRegion(
            onEnter: (_) => setState(() => _railExpanded = true),
            onExit: (_) => setState(() => _railExpanded = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _railExpanded ? 220 : 72,
              child: _TabletRail(
                items: _navItems,
                selectedIndex: widget.selectedIndex,
                expanded: _railExpanded,
                onTap: _onNavTap,
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, showMenuButton: false),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.actions,
        elevation: 0,
      ),
      drawer: _MobileDrawer(
        items: _navItems,
        selectedIndex: widget.selectedIndex,
        onTap: (index) {
          Navigator.pop(context); // Close drawer first.
          _onNavTap(index);
        },
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool showMenuButton}) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.actions != null) ...widget.actions!,
          const SizedBox(width: 12),
          _UserAvatar(),
        ],
      ),
    );
  }
}

// ── Desktop Sidebar ──

class _DesktopSidebar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Logo / branding area.
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                AppLogo(size: 34),
                SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Procurement',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Shanto-Mariam University of Creative Technology',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Nav items.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return _SidebarTile(
                  item: item,
                  selected: selected,
                  onTap: () => onTap(index),
                );
              },
            ),
          ),
          // Logout (authenticated only).
          if (Get.find<PermissionService>().currentRole != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SidebarTile(
                item: const NavItem(
                    label: 'Logout', icon: Icons.logout, route: '/login'),
                selected: false,
                onTap: () => Get.find<PermissionService>().logout(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (item.badgeCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
}

// ── Tablet Rail ──

class _TabletRail extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final bool expanded;
  final ValueChanged<int> onTap;

  const _TabletRail({
    required this.items,
    required this.selectedIndex,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          Container(
            height: 64,
            alignment: Alignment.center,
            child: const AppLogo(size: 32),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return Tooltip(
                  message: expanded ? '' : item.label,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              if (expanded) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile Drawer ──

class _MobileDrawer extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MobileDrawer({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                AppLogo(size: 42),
                SizedBox(width: 14),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Procurement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Shanto-Mariam University of Creative Technology',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: item.badgeCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  selected: selected,
                  onTap: () => onTap(index),
                );
              },
            ),
          ),
          if (Get.find<PermissionService>().currentRole != null) ...[
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                Get.find<PermissionService>().logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── User Avatar ──

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permission = Get.find<PermissionService>();
    if (permission.currentRole == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => Get.toNamed('/login'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.toNamed('/vendor/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Register'),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          Get.find<PermissionService>().logout();
        }
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Icon(Icons.person, size: 20, color: AppColors.primary),
      ),
    );
  }
}
