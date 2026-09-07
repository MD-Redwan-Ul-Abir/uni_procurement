import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Login page — responsive split-screen layout.
/// Desktop: branded panel left (55%), form right (45%).
/// Tablet: narrower brand panel (~35%) or top banner.
/// Mobile: full-width form, no brand panel.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: (_) => const _MobileLoginLayout(),
        tablet: (_) => const _TabletLoginLayout(),
        desktop: (_) => const _DesktopLoginLayout(),
      ),
    );
  }
}

// ── Desktop Layout ──

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Branding panel (55%).
        Expanded(
          flex: 55,
          child: _BrandingPanel(),
        ),
        // Form panel (45%).
        Expanded(
          flex: 45,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const _LoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tablet Layout ──

class _TabletLoginLayout extends StatelessWidget {
  const _TabletLoginLayout();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Below ~900px, use top banner instead of side panel.
    if (width < 900) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: _BrandingPanel(compact: true),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const _LoginForm(),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 35,
          child: _BrandingPanel(),
        ),
        Expanded(
          flex: 65,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const _LoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile Layout ──

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            // Compact branding.
            const AppLogo(size: 64),
            const SizedBox(height: 16),
            Text(
              'UniProcure',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'University E-Procurement Portal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 48),
            const _LoginForm(),
          ],
        ),
      ),
    );
  }
}

// ── Branding Panel ──

class _BrandingPanel extends StatelessWidget {
  final bool compact;

  const _BrandingPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            const Color(0xFF0D2B6B),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 24 : 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(size: compact ? 38 : 48),
                  const SizedBox(width: 14),
                  Text(
                    'UniProcure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 24),
                Text(
                  'Streamline your university\nprocurement process',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Manage circulars, bids, approvals, and work orders\nin one unified platform.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                // Feature highlights.
                _FeatureItem(
                    icon: Icons.speed, text: 'Fast, transparent procurement'),
                const SizedBox(height: 16),
                _FeatureItem(
                    icon: Icons.verified,
                    text: 'Multi-tier approval workflow'),
                const SizedBox(height: 16),
                _FeatureItem(
                    icon: Icons.analytics,
                    text: 'Real-time comparison matrix'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Login Form ──

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Obx(() => Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Email field.
              AppTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hint: 'you@university.edu',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                errorText: controller.fieldErrors['email'],
                validator: Validators.email,
              ),
              const SizedBox(height: 20),

              // Password field.
              AppTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                errorText: controller.fieldErrors['password'],
                validator: (value) =>
                    Validators.required(value, 'Password'),
              ),

              // Login error.
              if (controller.loginError.value != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.loginError.value!,
                          style: TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              // Forgot password link.
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),

              const SizedBox(height: 24),
              // Login button.
              AppButton(
                label: 'Sign In',
                onPressed: controller.login,
                isLoading: controller.isLoading.value,
                width: double.infinity,
              ),

              const SizedBox(height: 20),
              // Showcase quick-switch.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Showcase Demo Accounts (1-Tap Login)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _demoChip(controller, 'Admin', 'admin@university.edu'),
                        _demoChip(controller, 'Initiator', 'initiator@university.edu'),
                        _demoChip(controller, 'Dept Head', 'depthead@university.edu'),
                        _demoChip(controller, 'Dean', 'dean@university.edu'),
                        _demoChip(controller, 'Registrar', 'registrar@university.edu'),
                        _demoChip(controller, 'Vendor', 'vendor@apextech.com'),
                        _demoChip(controller, 'Finance', 'finance@university.edu'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Vendor registration link.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Are you a vendor? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/vendor/register'),
                    child: const Text('Register here'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _demoChip(AuthController controller, String label, String email) {
    return ActionChip(
      visualDensity: VisualDensity.compact,
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      onPressed: () {
        controller.emailController.text = email;
        controller.passwordController.text = 'password123';
        controller.login();
      },
    );
  }
}
