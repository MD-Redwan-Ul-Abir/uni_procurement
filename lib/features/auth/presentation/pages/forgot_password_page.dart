import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final sent = false.obs;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Obx(() => sent.value
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mark_email_read,
                            size: 40, color: AppColors.success),
                      ),
                      const SizedBox(height: 24),
                      Text('Check your email',
                          style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: 12),
                      Text(
                        'We\'ve sent a password reset link to your email address.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'Back to Login',
                        isOutlined: true,
                        onPressed: () => Get.offAllNamed('/login'),
                      ),
                    ],
                  )
                : Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        Text('Forgot Password?',
                            style:
                                Theme.of(context).textTheme.displaySmall),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email and we\'ll send you a reset link.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: emailController,
                          label: 'Email Address',
                          hint: 'you@university.edu',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Send Reset Link',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              sent.value = true;
                            }
                          },
                          width: double.infinity,
                        ),
                      ],
                    ),
                  )),
          ),
        ),
      ),
    );
  }
}
