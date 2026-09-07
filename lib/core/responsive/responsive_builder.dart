import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// A builder widget that selects a child widget based on the current
/// screen width, using the shared [Breakpoints] definitions.
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (ctx) => MobileLayout(),
///   tablet: (ctx) => TabletLayout(),   // optional, falls back to mobile
///   desktop: (ctx) => DesktopLayout(), // optional, falls back to tablet
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final type = Breakpoints.fromWidth(width);

        switch (type) {
          case DeviceType.desktop:
            return (desktop ?? tablet ?? mobile)(context);
          case DeviceType.tablet:
            return (tablet ?? mobile)(context);
          case DeviceType.mobile:
            return mobile(context);
        }
      },
    );
  }

  /// Helper to get the current device type from context.
  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Breakpoints.fromWidth(width);
  }

  /// Whether the current context is at mobile breakpoint.
  static bool isMobile(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.mobile;

  /// Whether the current context is at tablet breakpoint.
  static bool isTablet(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.tablet;

  /// Whether the current context is at desktop breakpoint.
  static bool isDesktop(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.desktop;
}
