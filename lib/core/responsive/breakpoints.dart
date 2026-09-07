/// Responsive breakpoints — the single source of truth for all
/// responsive behavior in the app. No other file should contain
/// raw pixel breakpoint values.
class Breakpoints {
  Breakpoints._();

  /// Anything below this is mobile.
  static const double mobile = 600;

  /// 600 – 1199 is tablet; >= 1200 is desktop.
  static const double tablet = 1200;

  /// Check the current device class from a width value.
  static DeviceType fromWidth(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType { mobile, tablet, desktop }
