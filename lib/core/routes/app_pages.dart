import 'package:get/get.dart';

import '../../features/admin/presentation/bindings/admin_binding.dart';
import '../../features/admin/presentation/pages/admin_reports_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';
import '../../features/admin/presentation/pages/vendor_verification_detail_page.dart';
import '../../features/admin/presentation/pages/vendor_verification_queue_page.dart';
import '../../features/admin/presentation/pages/workflow_hierarchy_settings_page.dart';
import '../../features/approval_workflow/presentation/bindings/approval_binding.dart';
import '../../features/approval_workflow/presentation/pages/approval_history_page.dart';
import '../../features/approval_workflow/presentation/pages/approval_list_page.dart';
import '../../features/approval_workflow/presentation/pages/approval_review_page.dart';
import '../../features/approval_workflow/presentation/pages/approval_tracker_page.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pending_approval_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/vendor_register_page.dart';
import '../../features/bidding/presentation/bindings/bid_binding.dart';
import '../../features/bidding/presentation/pages/bid_submission_page.dart';
import '../../features/bidding/presentation/pages/my_bids_page.dart';
import '../../features/circulars/presentation/bindings/circular_binding.dart';
import '../../features/circulars/presentation/pages/circular_detail_page.dart';
import '../../features/circulars/presentation/pages/circular_list_page.dart';
import '../../features/circulars/presentation/pages/create_circular_page.dart';
import '../../features/comparison_matrix/presentation/bindings/matrix_binding.dart';
import '../../features/comparison_matrix/presentation/pages/comparison_matrix_page.dart';
import '../../features/finance/presentation/bindings/finance_binding.dart';
import '../../features/finance/presentation/pages/finance_completed_page.dart';
import '../../features/finance/presentation/pages/finance_dashboard_page.dart';
import '../../features/finance/presentation/pages/finance_invoices_page.dart';
import '../../features/finance/presentation/pages/finance_review_page.dart';
import '../../features/work_orders/presentation/bindings/work_order_binding.dart';
import '../../features/work_orders/presentation/pages/invoice_upload_page.dart';
import '../../features/work_orders/presentation/pages/work_order_detail_page.dart';
import '../../features/work_orders/presentation/pages/work_order_list_page.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

/// All GetX page route definitions.
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    // ── Auth (Guest) ──
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      middlewares: [GuestGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.vendorRegister,
      page: () => const VendorRegisterPage(),
      binding: AuthBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.pendingApproval,
      page: () => const PendingApprovalPage(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: AuthBinding(),
      middlewares: [GuestGuard()],
    ),

    // ── Admin ──
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => const UserManagementPage(),
      binding: AdminBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminVendorVerification,
      page: () => const VendorVerificationQueuePage(),
      binding: AdminBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminVendorDetail,
      page: () => const VendorVerificationDetailPage(),
      binding: AdminBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminWorkflowSettings,
      page: () => const WorkflowHierarchySettingsPage(),
      binding: AdminBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminReports,
      page: () => const AdminReportsPage(),
      binding: AdminBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Circulars ──
    GetPage(
      name: AppRoutes.circulars,
      page: () => const CircularListPage(),
      binding: CircularBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.circularCreate,
      page: () => const CreateCircularPage(),
      binding: CircularBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.circularDetail,
      page: () => const CircularDetailPage(),
      binding: CircularBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Bidding ──
    GetPage(
      name: AppRoutes.bidSubmit,
      page: () => const BidSubmissionPage(),
      binding: BidBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.myBids,
      page: () => const MyBidsPage(),
      binding: BidBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Comparison Matrix ──
    GetPage(
      name: AppRoutes.comparisonMatrix,
      page: () => const ComparisonMatrixPage(),
      binding: MatrixBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Approvals ──
    GetPage(
      name: AppRoutes.approvals,
      page: () => const ApprovalListPage(),
      binding: ApprovalBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.approvalReview,
      page: () => const ApprovalReviewPage(),
      binding: ApprovalBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.approvalTracker,
      page: () => const ApprovalTrackerPage(),
      binding: ApprovalBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.approvalHistory,
      page: () => const ApprovalHistoryPage(),
      binding: ApprovalBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Work Orders ──
    GetPage(
      name: AppRoutes.workOrders,
      page: () => const WorkOrderListPage(),
      binding: WorkOrderBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.workOrderDetail,
      page: () => const WorkOrderDetailPage(),
      binding: WorkOrderBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.invoiceUpload,
      page: () => const InvoiceUploadPage(),
      binding: WorkOrderBinding(),
      middlewares: [AuthGuard()],
    ),

    // ── Finance ──
    GetPage(
      name: AppRoutes.finance,
      page: () => const FinanceDashboardPage(),
      binding: FinanceBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.financeInvoices,
      page: () => const FinanceInvoicesPage(),
      binding: FinanceBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.financeCompleted,
      page: () => const FinanceCompletedPage(),
      binding: FinanceBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.financeReview,
      page: () => const FinanceReviewPage(),
      binding: FinanceBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
