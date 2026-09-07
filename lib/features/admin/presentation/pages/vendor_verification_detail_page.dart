import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/dummy_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_button.dart';

class VendorVerificationDetailPage extends StatelessWidget {
  const VendorVerificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DummyDatabaseService>();
    final rawId = Get.parameters['id'] ?? '9';
    final vendorId = int.tryParse(rawId) ?? 9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Verification Audit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final vendor = db.vendorVerifications.firstWhereOrNull((v) => v['id'] == vendorId) ??
            (db.vendorVerifications.isNotEmpty ? db.vendorVerifications.first : null);

        if (vendor == null) {
          return const Center(child: Text('Vendor record not found.'));
        }

        final id = vendor['id'] as int;
        final companyName = vendor['company_name'] as String? ?? '';
        final email = vendor['email'] as String? ?? '';
        final contactPerson = vendor['contact_person'] as String? ?? '';
        final phone = vendor['phone'] as String? ?? '';
        final address = vendor['address'] as String? ?? '';
        final tradeLicense = vendor['trade_license_number'] as String? ?? '';
        final tradeLicenseFile = vendor['trade_license_file'] as String? ?? '';
        final taxId = vendor['tax_id'] as String? ?? '';
        final taxIdFile = vendor['tax_id_file'] as String? ?? '';
        final regDate = vendor['registration_date'] as String? ?? '';
        final status = vendor['status'] as String? ?? 'PENDING';
        final notes = vendor['notes'] as String? ?? '';
        final verifiedDate = vendor['verified_date'] as String? ?? 'N/A';
        final verifiedBy = vendor['verified_by'] as String? ?? 'N/A';
        final isPending = status == 'PENDING';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 650;

            final badge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPending ? Icons.hourglass_top_outlined : Icons.check_circle_outlined,
                    size: 14,
                    color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPending ? 'PENDING VERIFICATION' : 'ACTIVE & VERIFIED',
                    style: TextStyle(
                      color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Overview Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isDesktop
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                companyName,
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Vendor ID #$id • Submitted on $regDate',
                                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        badge,
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          companyName,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Vendor ID #$id • Submitted on $regDate',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                        const SizedBox(height: 10),
                                        badge,
                                      ],
                                    ),
                          if (!isPending) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Verified by $verifiedBy on $verifiedDate',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const Divider(height: 32),
                          Wrap(
                            spacing: 32,
                            runSpacing: 12,
                            children: [
                              _infoBlock('Contact Person', contactPerson),
                              _infoBlock('Email Address', email),
                              _infoBlock('Telephone', phone),
                              _infoBlock('Business Address', address),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Statutory Legal Documentation Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statutory Legal Registrations',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _documentRow(
                            title: 'Municipal Trade License',
                            regNumber: tradeLicense,
                            fileName: tradeLicenseFile,
                            isVerified: !isPending,
                          ),
                          const SizedBox(height: 12),
                          _documentRow(
                            title: 'Taxpayer Identification Certificate (TIN)',
                            regNumber: taxId,
                            fileName: taxIdFile,
                            isVerified: !isPending,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verification Notes
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Notes & Compliance Remarks',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notes.isEmpty ? 'No additional notes logged.' : notes,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Verification Actions
                  if (isPending)
                    isDesktop
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                                onPressed: () {
                                  db.updateVendorVerificationStatus(id, 'REJECTED');
                                  Get.back();
                                  AppToast.error(
                                    title: 'Application Rejected',
                                    description: 'Vendor application for $companyName has been rejected.',
                                    context: context,
                                  );
                                },
                                child: const Text('Reject Application'),
                              ),
                              const SizedBox(width: 16),
                              AppButton(
                                label: 'Verify & Activate Vendor',
                                icon: Icons.verified_user,
                                onPressed: () {
                                  db.updateVendorVerificationStatus(id, 'ACTIVE');
                                  AppToast.success(
                                    title: 'Vendor Activated',
                                    description:
                                        '$companyName has been approved and activated in the university vendor directory.',
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
                                label: 'Verify & Activate Vendor',
                                icon: Icons.verified_user,
                                onPressed: () {
                                  db.updateVendorVerificationStatus(id, 'ACTIVE');
                                  AppToast.success(
                                    title: 'Vendor Activated',
                                    description:
                                        '$companyName has been approved and activated in the university vendor directory.',
                                    context: context,
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                                onPressed: () {
                                  db.updateVendorVerificationStatus(id, 'REJECTED');
                                  Get.back();
                                  AppToast.error(
                                    title: 'Application Rejected',
                                    description: 'Vendor application for $companyName has been rejected.',
                                    context: context,
                                  );
                                },
                                child: const Text('Reject Application'),
                              ),
                            ],
                          )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, color: AppColors.success, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This vendor is officially verified and eligible to bid on all published university tenders.',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
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

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _documentRow({
    required String title,
    required String regNumber,
    required String fileName,
    required bool isVerified,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 460;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.file_present_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Registration Number: $regNumber', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('Attached File: $fileName', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('View Document', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        AppToast.info(
                          title: 'Preview Document',
                          description: 'Opening verified scan of $fileName...',
                          context: context,
                        );
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.file_present_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Registration Number: $regNumber', style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('Attached File: $fileName', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('View Document', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        AppToast.info(
                          title: 'Preview Document',
                          description: 'Opening verified scan of $fileName...',
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

