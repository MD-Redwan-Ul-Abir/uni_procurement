import '../constants/app_enums.dart';

/// Strict three-state categorization for bids per procurement compliance.
enum BidStatusCategory {
  bidSubmitted('Bid Submitted'),
  bidPending('Bid Pending'),
  bidWaiting('Bid Waiting');

  final String label;
  const BidStatusCategory(this.label);
}

/// Service handling tender bid status categorization, deadline compliance,
/// and offer price confidentiality guards.
class BidComplianceService {
  BidComplianceService._();

  /// Strictly categorizes a bid into:
  /// - [BidStatusCategory.bidSubmitted]
  /// - [BidStatusCategory.bidPending]
  /// - [BidStatusCategory.bidWaiting]
  static BidStatusCategory categorizeBid(Map<String, dynamic> bid) {
    final status = (bid['status'] as String? ?? 'SUBMITTED').trim().toUpperCase();

    // 1. Bid Submitted: Received / initial submission
    if (status == 'SUBMITTED' || status == 'RECEIVED' || status == 'DRAFT') {
      return BidStatusCategory.bidSubmitted;
    }

    // 2. Bid Pending: Under technical/financial evaluation, review, or clarification
    if (status == 'UNDER_REVIEW' ||
        status == 'PENDING' ||
        status == 'EVALUATION' ||
        status == 'EVALUATED' ||
        status == 'IN_REVIEW') {
      return BidStatusCategory.bidPending;
    }

    // 3. Bid Waiting: Awaiting committee decision, recommended, awarded, or accepted
    if (status == 'WAITING' ||
        status == 'RECOMMENDED' ||
        status == 'AWARDED' ||
        status == 'ACCEPTED' ||
        status == 'APPROVED' ||
        status == 'REJECTED') {
      return BidStatusCategory.bidWaiting;
    }

    return BidStatusCategory.bidSubmitted;
  }

  /// Calculates counts for each of the 3 strict categories from a list of bids.
  static Map<BidStatusCategory, int> getCategoryCounts(List<Map<String, dynamic>> bids) {
    final counts = <BidStatusCategory, int>{
      BidStatusCategory.bidSubmitted: 0,
      BidStatusCategory.bidPending: 0,
      BidStatusCategory.bidWaiting: 0,
    };

    for (final bid in bids) {
      final category = categorizeBid(bid);
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  /// Checks if the Bid Closing Date (submission deadline) has passed.
  /// If deadline is null or unparseable, defaults to false (not expired).
  static bool isDeadlineExpired(dynamic deadlineRaw) {
    if (deadlineRaw == null) return false;
    final str = deadlineRaw.toString().trim();
    if (str.isEmpty || str == 'TBD') return false;

    final parsed = DateTime.tryParse(str);
    if (parsed == null) return false;

    // The deadline expires at the end of the specified day (23:59:59)
    // or exact timestamp if time was provided.
    final hasTime = str.contains('T') || str.contains(':');
    final deadlineTime = hasTime
        ? parsed
        : DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);

    return DateTime.now().isAfter(deadlineTime);
  }

  /// Determines whether a given user role is permitted to view vendor offer prices
  /// and financial quotations for this tender.
  ///
  /// Compliance Rules:
  /// 1. BEFORE the Bid Closing Date: Vendor offer prices remain ABSOLUTELY CONFIDENTIAL
  ///    and cannot be viewed by ANY user (including Admin, Initiator, Committee).
  /// 2. AFTER the deadline has officially expired: Actual financial quotations and bid
  ///    details may ONLY be accessed by authorized users & the Procurement Committee
  ///    (Admin, Initiator, ApproverDeptHead, ApproverDean, ApproverRegistrar, Finance).
  ///    Unauthorized users (Guests, Vendors) cannot view competitor offer prices.
  static bool canViewBidPrices({
    required dynamic deadline,
    required UserRole? role,
    int? currentVendorId,
    int? bidVendorId,
  }) {
    final expired = isDeadlineExpired(deadline);

    // Rule 1: Before deadline, NO USER can view vendor offer prices.
    if (!expired) {
      return false;
    }

    // Rule 2: After deadline, only authorized roles (Procurement Committee, Admin, Initiator, Finance)
    // may view actual quotations.
    if (role == null) return false;

    final isAuthorizedStaff = role == UserRole.admin ||
        role == UserRole.initiator ||
        role == UserRole.approverDeptHead ||
        role == UserRole.approverDean ||
        role == UserRole.approverRegistrar ||
        role == UserRole.finance;

    return isAuthorizedStaff;
  }

  /// Full description text for masked/sealed price when viewing is unauthorized.
  static String getPriceMaskText({required dynamic deadline, required UserRole? role}) {
    final expired = isDeadlineExpired(deadline);
    if (!expired) {
      return 'Confidential until closing date';
    } else {
      return 'Authorized Committee Only';
    }
  }

  /// Compact label for sleek minimalist pills in tables and mobile cards.
  static String getCompactMaskText({required dynamic deadline, required UserRole? role}) {
    final expired = isDeadlineExpired(deadline);
    if (!expired) {
      return 'Sealed Bid';
    } else {
      return 'Committee Only';
    }
  }
}
