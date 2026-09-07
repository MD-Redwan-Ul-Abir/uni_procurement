/// Centralized API endpoint paths.
/// Replace the base URL via environment or DioClient configuration.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base ──
  static const String baseUrl = 'http://localhost:8000/api';

  // ── Auth ──
  static const String login = '/login';
  static const String vendorRegister = '/vendor/register';
  static const String me = '/me';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ── Admin: Users ──
  static const String adminUsers = '/admin/users';
  static String adminUserById(int id) => '/admin/users/$id';
  static String adminUserPendingCount(int id) =>
      '/admin/users/$id/pending-count';

  // ── Admin: Vendor Verification ──
  static const String adminPendingVendors = '/admin/vendors';
  static String adminVerifyVendor(int id) => '/admin/vendors/$id/verify';

  // ── Admin: Workflow Hierarchy ──
  static const String adminWorkflowHierarchy = '/admin/workflow-hierarchy';
  static const String adminBypassRules =
      '/admin/workflow-hierarchy/bypass-rules';

  // ── Admin: Reports ──
  static const String adminReportsSummary = '/admin/reports/summary';
  static const String adminReportsCharts = '/admin/reports/charts';

  // ── Departments ──
  static const String departments = '/departments';

  // ── Circulars ──
  static const String circulars = '/circulars';
  static String circularById(int id) => '/circulars/$id';
  static String circularMyBid(int id) => '/circulars/$id/my-bid';
  static String circularMatrix(int id) => '/circulars/$id/matrix';
  static String circularInitiateApproval(int id) =>
      '/circulars/$id/initiate-approval';
  static String circularApprovalHistory(int id) =>
      '/circulars/$id/approval-history';

  // ── Bids ──
  static const String bids = '/bids';

  // ── Approvals ──
  static const String approvalsPending = '/approvals/pending';
  static String approvalById(int id) => '/approvals/$id';
  static String approvalApprove(int id) => '/approvals/$id/approve';
  static String approvalReject(int id) => '/approvals/$id/reject';

  // ── Work Orders ──
  static const String workOrders = '/work-orders';
  static String workOrderById(int id) => '/work-orders/$id';
  static String workOrderInvoice(int id) => '/work-orders/$id/invoice';
}
