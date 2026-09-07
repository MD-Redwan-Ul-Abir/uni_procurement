import '../constants/app_constants.dart';

/// Shared validation functions for forms.
/// Used with `TextFormField.validator`.
class Validators {
  Validators._();

  /// Non-empty check.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Valid email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Minimum length.
  static String? minLength(String? value, int min,
      [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Password strength (min 8, at least 1 letter + 1 digit).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Confirm password matches.
  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Phone number (basic: 10+ digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 10 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Positive number.
  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num? parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  /// File size check (in bytes).
  static String? fileSize(int? sizeInBytes) {
    if (sizeInBytes == null) return null;
    if (sizeInBytes > AppConstants.maxUploadSizeBytes) {
      final maxMB = AppConstants.maxUploadSizeBytes / (1024 * 1024);
      return 'File must be smaller than ${maxMB.toInt()}MB';
    }
    return null;
  }

  /// File extension check.
  static String? fileExtension(String? fileName, List<String> allowed) {
    if (fileName == null) return null;
    final ext = fileName.split('.').last.toLowerCase();
    if (!allowed.contains(ext)) {
      return 'Allowed formats: ${allowed.join(', ')}';
    }
    return null;
  }
}
