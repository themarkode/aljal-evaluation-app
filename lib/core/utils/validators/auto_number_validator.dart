import 'package:flutter/services.dart';

/// Validation for الرقم الآلي (Auto Number)
class AutoNumberValidator {
  AutoNumberValidator._();

  /// Validates الرقم الآلي (exactly 8 digits)
  /// Returns null if valid, error message if invalid
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Empty is allowed (not required)
    }

    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 8) {
      return 'الرقم الآلي يجب أن يكون 8 أرقام';
    }

    if (digitsOnly.length > 8) {
      return 'الرقم الآلي يجب ألا يتجاوز 8 أرقام';
    }

    return null;
  }

  /// Input formatters for الرقم الآلي (8 digits only)
  static List<TextInputFormatter> formatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(8),
    ];
  }
}

