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

  // ── Initiator ──
  static const String initiatorDashboard = '/initiator/dashboard';
  static const String initiatorNewCircular = '/initiator/circulars/new';
  static const String initiatorHistory = '/initiator/history';

  // ── Circulars (Public / Initiator / Admin) ──
  static const String circulars = '/circulars';
  static const String circularCreate = '/circulars/create';
  static const String circularDetail = '/circulars/:id';

  // ── Vendor ──
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorCirculars = '/vendor/circulars';
  static const String vendorCircularDetail = '/vendor/circulars/:id';
  static const String vendorMyBids = '/vendor/my-bids';

  // ── Bidding (Vendor) ──
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

  // ── Procurement Committee Module ──
  static const String committeeDashboard = '/committee/dashboard';
  static const String committeeEvaluation = '/committee/evaluation/:id';
  static const String committeeHistory = '/committee/history';
}

