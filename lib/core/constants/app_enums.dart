/// All user roles in the system, mapped 1:1 from the backend.
enum UserRole {
  admin,
  initiator,
  approverDeptHead,
  approverDean,
  approverRegistrar,
  vendor,
  finance;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'System Admin';
      case UserRole.initiator:
        return 'Initiator';
      case UserRole.approverDeptHead:
        return 'Department Head';
      case UserRole.approverDean:
        return 'Dean';
      case UserRole.approverRegistrar:
        return 'Registrar';
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.finance:
        return 'Finance';
    }
  }

  /// Parse from backend snake_case string.
  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'initiator':
        return UserRole.initiator;
      case 'approver_dept_head':
        return UserRole.approverDeptHead;
      case 'approver_dean':
        return UserRole.approverDean;
      case 'approver_registrar':
        return UserRole.approverRegistrar;
      case 'vendor':
        return UserRole.vendor;
      case 'finance':
        return UserRole.finance;
      default:
        throw ArgumentError('Unknown role: $value');
    }
  }

  /// Convert to backend snake_case string.
  String toApiString() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.initiator:
        return 'initiator';
      case UserRole.approverDeptHead:
        return 'approver_dept_head';
      case UserRole.approverDean:
        return 'approver_dean';
      case UserRole.approverRegistrar:
        return 'approver_registrar';
      case UserRole.vendor:
        return 'vendor';
      case UserRole.finance:
        return 'finance';
    }
  }

  bool get isApprover =>
      this == UserRole.approverDeptHead ||
      this == UserRole.approverDean ||
      this == UserRole.approverRegistrar;
}

/// Circular (tender) lifecycle statuses.
enum CircularStatus {
  draft,
  published,
  evaluation,
  pendingDeptHead,
  pendingDean,
  pendingRegistrar,
  approved,
  rejected,
  sentBack,
  awarded;

  String get label {
    switch (this) {
      case CircularStatus.draft:
        return 'Draft';
      case CircularStatus.published:
        return 'Published';
      case CircularStatus.evaluation:
        return 'Evaluation';
      case CircularStatus.pendingDeptHead:
        return 'Pending Dept Head';
      case CircularStatus.pendingDean:
        return 'Pending Dean';
      case CircularStatus.pendingRegistrar:
        return 'Pending Registrar';
      case CircularStatus.approved:
        return 'Approved';
      case CircularStatus.rejected:
        return 'Rejected';
      case CircularStatus.sentBack:
        return 'Sent Back';
      case CircularStatus.awarded:
        return 'Awarded';
    }
  }

  static CircularStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return CircularStatus.draft;
      case 'PUBLISHED':
        return CircularStatus.published;
      case 'EVALUATION':
        return CircularStatus.evaluation;
      case 'PENDING_DEPT_HEAD':
        return CircularStatus.pendingDeptHead;
      case 'PENDING_DEAN':
        return CircularStatus.pendingDean;
      case 'PENDING_REGISTRAR':
        return CircularStatus.pendingRegistrar;
      case 'APPROVED':
        return CircularStatus.approved;
      case 'REJECTED':
        return CircularStatus.rejected;
      case 'SENT_BACK':
        return CircularStatus.sentBack;
      case 'AWARDED':
        return CircularStatus.awarded;
      default:
        return CircularStatus.draft;
    }
  }

  bool get isPending =>
      this == CircularStatus.pendingDeptHead ||
      this == CircularStatus.pendingDean ||
      this == CircularStatus.pendingRegistrar;
}

/// Vendor account statuses.
enum VendorStatus {
  pending,
  active,
  rejected;

  String get label {
    switch (this) {
      case VendorStatus.pending:
        return 'Pending Verification';
      case VendorStatus.active:
        return 'Active';
      case VendorStatus.rejected:
        return 'Rejected';
    }
  }

  static VendorStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return VendorStatus.pending;
      case 'ACTIVE':
        return VendorStatus.active;
      case 'REJECTED':
        return VendorStatus.rejected;
      default:
        return VendorStatus.pending;
    }
  }
}

/// Work order lifecycle statuses.
enum WorkOrderStatus {
  awarded,
  delivered,
  invoiceSubmitted,
  completed;

  String get label {
    switch (this) {
      case WorkOrderStatus.awarded:
        return 'Awarded';
      case WorkOrderStatus.delivered:
        return 'Delivered';
      case WorkOrderStatus.invoiceSubmitted:
        return 'Invoice Submitted';
      case WorkOrderStatus.completed:
        return 'Completed';
    }
  }

  static WorkOrderStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AWARDED':
        return WorkOrderStatus.awarded;
      case 'DELIVERED':
        return WorkOrderStatus.delivered;
      case 'INVOICE_SUBMITTED':
        return WorkOrderStatus.invoiceSubmitted;
      case 'COMPLETED':
        return WorkOrderStatus.completed;
      default:
        return WorkOrderStatus.awarded;
    }
  }
}

/// Internal user account status.
enum AccountStatus {
  active,
  inactive;

  static AccountStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return AccountStatus.active;
      case 'INACTIVE':
        return AccountStatus.inactive;
      default:
        return AccountStatus.active;
    }
  }
}
