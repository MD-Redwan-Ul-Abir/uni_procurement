import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/adaptive_scaffold.dart';
import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_switch.dart';

class WorkflowHierarchySettingsPage extends StatefulWidget {
  const WorkflowHierarchySettingsPage({super.key});

  @override
  State<WorkflowHierarchySettingsPage> createState() => _WorkflowHierarchySettingsPageState();
}

class _WorkflowHierarchySettingsPageState extends State<WorkflowHierarchySettingsPage> {
  // Local state for interactive switches
  bool _requireThreeQuotes = true;
  bool _enableAlerts = true;
  bool _strictBudgetCeiling = true;
  int _displayDays = 14;

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Workflow Settings',
      selectedIndex: 3,
      body: Obx(() {
        final settings = db.workflowSettings;
        final tiers = (settings['tiers'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 700;
            final isMobile = constraints.maxWidth < 550;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_tree_outlined, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hierarchical Financial Sanction Thresholds',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Procurement circulars dynamically route to appropriate university administrative tiers based on estimated budget limits.',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Approval Escalation Tiers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),

                      ...tiers.map((tier) {
                        final level = tier['tier_level'] as int? ?? 1;
                        final title = tier['role_title'] as String? ?? '';
                        final min = (tier['threshold_min'] as num?)?.toDouble() ?? 0.0;
                        final max = (tier['threshold_max'] as num?)?.toDouble();
                        final days = tier['auto_escalate_days'] as int? ?? 5;
                        final desc = tier['description'] as String? ?? '';

                        final rangeStr = max != null
                            ? '${currencyFmt.format(min)} — ${currencyFmt.format(max)}'
                            : 'Above ${currencyFmt.format(min)} (Unlimited)';

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        '$level',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: isDesktop
                                          ? Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    rangeStr,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    rangeStr,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(left: isMobile ? 0 : 44),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'Auto-escalate to next tier if inactive for $days business days',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 28),

                      Text(
                        'Procurement Policy & Governance Rules',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: 'Require 3 Minimum Responsive Quotations',
                                subtitle:
                                    'Comparison matrix cannot be evaluated unless at least 3 eligible vendors participate.',
                                value: _requireThreeQuotes,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _requireThreeQuotes = val),
                              ),
                              const Divider(height: 24),
                              AppSwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: 'Strict Budget Ceiling Enforcement',
                                subtitle:
                                    'Prevent circular creation if departmental budget allocation is exceeded.',
                                value: _strictBudgetCeiling,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _strictBudgetCeiling = val),
                              ),
                              const Divider(height: 24),
                              AppSwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: 'Automatic Escalation & In-App Alerts',
                                subtitle:
                                    'Send push notifications and automated email reminders to approving officers.',
                                value: _enableAlerts,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _enableAlerts = val),
                              ),
                              const Divider(height: 24),
                              isMobile
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Public Tender Display Window',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        const Text('Minimum days circular must remain live for vendor submissions',
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: _displayDays > 7 ? () => setState(() => _displayDays--) : null,
                                            ),
                                            Text('$_displayDays Days',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: _displayDays < 30 ? () => setState(() => _displayDays++) : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Public Tender Display Window',
                                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                              SizedBox(height: 2),
                                              Text('Minimum days circular must remain live for vendor submissions',
                                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: _displayDays > 7 ? () => setState(() => _displayDays--) : null,
                                            ),
                                            Text('$_displayDays Days',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: _displayDays < 30 ? () => setState(() => _displayDays++) : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      isDesktop
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _requireThreeQuotes = true;
                                      _enableAlerts = true;
                                      _strictBudgetCeiling = true;
                                      _displayDays = 14;
                                    });
                                    AppToast.info(
                                      title: 'Settings Reset',
                                      description: 'Default governance rules restored.',
                                      context: context,
                                    );
                                  },
                                  child: const Text('Reset Defaults'),
                                ),
                                const SizedBox(width: 16),
                                AppButton(
                                  label: 'Save Configuration',
                                  icon: Icons.save,
                                  onPressed: () {
                                    AppToast.success(
                                      title: 'Configuration Saved',
                                      description:
                                          'Workflow hierarchy rules and financial threshold settings saved successfully.',
                                      context: context,
                                    );
                                  },
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppButton(
                                  label: 'Save Configuration',
                                  icon: Icons.save,
                                  onPressed: () {
                                    AppToast.success(
                                      title: 'Configuration Saved',
                                      description:
                                          'Workflow hierarchy rules and financial threshold settings saved successfully.',
                                      context: context,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _requireThreeQuotes = true;
                                      _enableAlerts = true;
                                      _strictBudgetCeiling = true;
                                      _displayDays = 14;
                                    });
                                    AppToast.info(
                                      title: 'Settings Reset',
                                      description: 'Default governance rules restored.',
                                      context: context,
                                    );
                                  },
                                  child: const Text('Reset Defaults'),
                                ),
                              ],
                            ),
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
}

