/// App-wide constant values.
class AppConstants {
  AppConstants._();

  static const String appName = 'E-Procurement';
  static const String universityName = 'Shanto-Mariam University of Creative Technology';
  static const String appTitle = 'E-Procurement - Shanto-Mariam University of Creative Technology';

  /// Maximum file upload size in bytes (5 MB).
  static const int maxUploadSizeBytes = 5 * 1024 * 1024;

  /// Allowed file extensions for document uploads.
  static const List<String> allowedDocExtensions = ['pdf'];

  /// Allowed file extensions for image uploads.
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  /// Polling interval for status-sensitive pages (seconds).
  static const int pollingIntervalSeconds = 30;

  /// Storage keys.
  static const String tokenKey = 'auth_token';
  static const String userKey = 'cached_user';

  /// Date/time formats.
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  /// Currency.
  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';
}
