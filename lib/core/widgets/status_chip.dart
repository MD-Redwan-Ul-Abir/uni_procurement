import 'package:flutter/material.dart';

import '../constants/app_enums.dart';
import '../theme/app_colors.dart';

/// A colored chip that reflects a status value.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  /// Factory from [CircularStatus].
  factory StatusChip.fromCircularStatus(CircularStatus status) {
    return StatusChip(
      label: status.label,
      color: _colorForCircularStatus(status),
    );
  }

  /// Factory from [WorkOrderStatus].
  factory StatusChip.fromWorkOrderStatus(WorkOrderStatus status) {
    return StatusChip(
      label: status.label,
      color: _colorForWorkOrderStatus(status),
    );
  }

  /// Factory from [VendorStatus].
  factory StatusChip.fromVendorStatus(VendorStatus status) {
    return StatusChip(
      label: status.label,
      color: _colorForVendorStatus(status),
    );
  }

  static Color _colorForCircularStatus(CircularStatus status) {
    switch (status) {
      case CircularStatus.draft:
        return AppColors.draft;
      case CircularStatus.published:
        return AppColors.info;
      case CircularStatus.evaluation:
        return AppColors.warning;
      case CircularStatus.pendingDeptHead:
      case CircularStatus.pendingDean:
      case CircularStatus.pendingRegistrar:
        return AppColors.pending;
      case CircularStatus.approved:
        return AppColors.approved;
      case CircularStatus.rejected:
      case CircularStatus.sentBack:
        return AppColors.rejected;
      case CircularStatus.awarded:
        return AppColors.awarded;
    }
  }

  static Color _colorForWorkOrderStatus(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.awarded:
        return AppColors.awarded;
      case WorkOrderStatus.delivered:
        return AppColors.info;
      case WorkOrderStatus.invoiceSubmitted:
        return AppColors.warning;
      case WorkOrderStatus.completed:
        return AppColors.approved;
    }
  }

  static Color _colorForVendorStatus(VendorStatus status) {
    switch (status) {
      case VendorStatus.pending:
        return AppColors.pending;
      case VendorStatus.active:
        return AppColors.approved;
      case VendorStatus.rejected:
        return AppColors.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
