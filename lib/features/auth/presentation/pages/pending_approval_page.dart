import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Static informational page shown to vendors with PENDING status.
class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.hourglass_empty,
                      size: 48, color: AppColors.warning),
                ),
                const SizedBox(height: 32),
                Text(
                  'Registration Under Review',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your registration is under review. You\'ll be notified via email once your account has been verified and approved.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: 'Back to Login',
                  isOutlined: true,
                  icon: Icons.arrow_back,
                  onPressed: () => Get.offAllNamed('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
