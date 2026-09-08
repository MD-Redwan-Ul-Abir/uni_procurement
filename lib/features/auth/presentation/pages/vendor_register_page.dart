import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/vendor_register_controller.dart';

/// Vendor registration page — 3-step stepper.
/// Desktop/Tablet: horizontal stepper with visible step labels.
/// Mobile: compact "Step X of 3" + progress bar.
class VendorRegisterPage extends StatelessWidget {
  const VendorRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => const _MobileRegisterLayout(),
        desktop: (_) => const _DesktopRegisterLayout(),
      ),
    );
  }
}

class _DesktopRegisterLayout extends StatelessWidget {
  const _DesktopRegisterLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Branding panel.
        Expanded(
          flex: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.storefront, color: Colors.white.withValues(alpha: 0.9), size: 48),
                    const SizedBox(height: 24),
                    const Text(
                      'Vendor\nRegistration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Join our procurement network.\nComplete the registration and wait\nfor verification.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Form.
        Expanded(
          flex: 60,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: const _StepperContent(showHorizontalStepper: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileRegisterLayout extends StatelessWidget {
  const _MobileRegisterLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button.
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 16),
                Text('Vendor Registration',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 24),
                const _StepperContent(showHorizontalStepper: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperContent extends StatelessWidget {
  final bool showHorizontalStepper;

  const _StepperContent({required this.showHorizontalStepper});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VendorRegisterController>();

    return Obx(() {
      final step = controller.currentStep.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stepper indicator.
          if (showHorizontalStepper)
            HorizontalStepIndicator(currentStep: step)
          else
            _CompactStepIndicator(currentStep: step),

          const SizedBox(height: 32),

          // Step content.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStepContent(step, controller),
          ),

          const SizedBox(height: 32),

          // Navigation buttons.
          Row(
            children: [
              if (step > 0)
                Expanded(
                  child: AppButton(
                    label: 'Back',
                    isOutlined: true,
                    onPressed: controller.previousStep,
                  ),
                ),
              if (step > 0) const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: step == 2 ? 'Submit Registration' : 'Continue',
                  onPressed: controller.nextStep,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Already have an account? Sign in'),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStepContent(int step, VendorRegisterController controller) {
    switch (step) {
      case 0:
        return _Step1CompanyDetails(key: const ValueKey(0), controller: controller);
      case 1:
        return _Step2LegalDocuments(key: const ValueKey(1), controller: controller);
      case 2:
        return _Step3Credentials(key: const ValueKey(2), controller: controller);
      default:
        return const SizedBox();
    }
  }
}

// ── Step Indicators ──

class HorizontalStepIndicator extends StatelessWidget {
  final int currentStep;

  const HorizontalStepIndicator({super.key, required this.currentStep});

  static const _steps = ['Company Details', 'Legal Documents', 'Credentials'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 32,
              alignment: Alignment.center,
              child: Container(
                height: 2,
                color: index ~/ 2 < currentStep
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isComplete = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isComplete || isCurrent
                    ? AppColors.primary
                    : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _steps[stepIndex],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CompactStepIndicator extends StatelessWidget {
  final int currentStep;

  const _CompactStepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${currentStep + 1} of 3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / 3,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Company Details ──

class _Step1CompanyDetails extends StatelessWidget {
  final VendorRegisterController controller;

  const _Step1CompanyDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Company Details',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Tell us about your company',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const SizedBox(height: 24),
          AppTextField(
            controller: controller.companyNameController,
            label: 'Company Name',
            hint: 'Enter your company name',
            validator: (v) => Validators.required(v, 'Company name'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.addressController,
            label: 'Address',
            hint: 'Enter company address',
            maxLines: 2,
            validator: (v) => Validators.required(v, 'Address'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.contactPersonController,
            label: 'Contact Person',
            hint: 'Full name of contact person',
            validator: (v) => Validators.required(v, 'Contact person'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            hint: '+880 1234 567890',
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Legal Documents ──

class _Step2LegalDocuments extends StatelessWidget {
  final VendorRegisterController controller;

  const _Step2LegalDocuments({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legal Documents',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Upload your business documents',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const SizedBox(height: 24),
          AppTextField(
            controller: controller.tradeLicenseNumberController,
            label: 'Trade License Number',
            hint: 'Enter trade license number',
            validator: (v) => Validators.required(v, 'Trade license number'),
          ),
          const SizedBox(height: 16),
          _FileUploadTile(
            label: 'Trade License Document (Strictly Mandatory)',
            fileName: controller.tradeLicenseFile.value?.name,
            fileSize: controller.tradeLicenseFile.value?.lengthSync(),
            error: controller.tradeLicenseError.value,
            onPick: controller.pickTradeLicense,
            onRemove: () => controller.tradeLicenseFile.value = null,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: controller.taxIdController,
            label: 'Tax ID / TIN',
            hint: 'Enter tax identification number',
            validator: (v) => Validators.required(v, 'Tax ID / TIN'),
          ),
          const SizedBox(height: 16),
          _FileUploadTile(
            label: 'TIN Document (Strictly Mandatory)',
            fileName: controller.taxIdFile.value?.name,
            fileSize: controller.taxIdFile.value?.lengthSync(),
            error: controller.taxIdFileError.value,
            onPick: controller.pickTaxIdFile,
            onRemove: () => controller.taxIdFile.value = null,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: controller.binNumberController,
            label: 'Business Identification Number (BIN)',
            hint: 'Enter 9 or 11 digit BIN',
            validator: (v) => Validators.required(v, 'BIN'),
          ),
          const SizedBox(height: 16),
          _FileUploadTile(
            label: 'BIN Document (Strictly Mandatory)',
            fileName: controller.binFile.value?.name,
            fileSize: controller.binFile.value?.lengthSync(),
            error: controller.binFileError.value,
            onPick: controller.pickBinFile,
            onRemove: () => controller.binFile.value = null,
          ),
        ],
      ),
    );
  }
}

class _FileUploadTile extends StatelessWidget {
  final String label;
  final String? fileName;
  final int? fileSize;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _FileUploadTile({
    required this.label,
    this.fileName,
    this.fileSize,
    this.error,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                )),
        const SizedBox(height: 6),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: error != null ? AppColors.error : AppColors.border,
                style: hasFile ? BorderStyle.solid : BorderStyle.none,
              ),
              borderRadius: BorderRadius.circular(10),
              color: hasFile
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : AppColors.scaffoldBg,
            ),
            child: hasFile
                ? Row(
                    children: [
                      Icon(Icons.description,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName!,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (fileSize != null)
                              Text(
                                '${(fileSize! / 1024).toStringAsFixed(1)} KB',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: AppColors.textSecondary, size: 24),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Click to upload (PDF/Image, max 5MB)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!,
              style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      ],
    );
  }
}

// ── Step 3: Credentials ──

class _Step3Credentials extends StatelessWidget {
  final VendorRegisterController controller;

  const _Step3Credentials({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Credentials',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Create your login credentials',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const SizedBox(height: 24),
          AppTextField(
            controller: controller.emailController,
            label: 'Email Address',
            hint: 'company@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            errorText: controller.fieldErrors['email'],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.passwordController,
            label: 'Password',
            hint: 'Min 8 characters, letters and numbers',
            obscureText: true,
            validator: Validators.password,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            obscureText: true,
            validator: (v) => Validators.confirmPassword(
                v, controller.passwordController.text),
          ),
        ],
      ),
    );
  }
}
