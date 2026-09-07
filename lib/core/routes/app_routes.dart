/// All route name constants. Never inline a route string in a widget.
class AppRoutes {
  AppRoutes._();

  // ── Auth ──
  static const String login = '/login';
  static const String vendorRegister = '/vendor/register';
  static const String pendingApproval = '/pending-approval';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password/:token';

  // ── Admin ──
  static const String adminUsers = '/admin/users';
  static const String adminVendorVerification = '/admin/vendor-verification';
  static const String adminVendorDetail = '/admin/vendor-verification/:id';
  static const String adminWorkflowSettings = '/admin/workflow-settings';
  static const String adminReports = '/admin/reports';

  // ── Circulars ──
  static const String circulars = '/circulars';
  static const String circularCreate = '/circulars/create';
  static const String circularDetail = '/circulars/:id';

  // ── Bidding ──
  static const String bidSubmit = '/circulars/:id/bid';
  static const String myBids = '/bids';

  // ── Matrix ──
  static const String comparisonMatrix = '/circulars/:id/matrix';

  // ── Approvals ──
  static const String approvals = '/approvals';
  static const String approvalReview = '/approvals/:id/review';
  static const String approvalTracker = '/approvals/tracker/:circularId';
  static const String approvalHistory = '/approvals/history';

  // ── Work Orders ──
  static const String workOrders = '/work-orders';
  static const String workOrderDetail = '/work-orders/:id';
  static const String invoiceUpload = '/work-orders/:id/invoice';

  // ── Finance ──
  static const String finance = '/finance';
  static const String financeInvoices = '/finance/invoices';
  static const String financeCompleted = '/finance/completed';
  static const String financeReview = '/finance/review/:id';
}
