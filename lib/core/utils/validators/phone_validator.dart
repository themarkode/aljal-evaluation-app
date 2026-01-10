import 'package:flutter/services.dart';

/// Validation for Kuwait phone numbers
class PhoneValidator {
  PhoneValidator._();

  /// Validates Kuwait phone number (exactly 8 digits)
  /// Returns null if valid, error message if invalid
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Empty is allowed (not required)
    }

    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 8) {
      return 'رقم الهاتف يجب أن يكون 8 أرقام';
    }

    if (digitsOnly.length > 8) {
      return 'رقم الهاتف يجب ألا يتجاوز 8 أرقام';
    }

    return null;
  }

  /// Input formatters for Kuwait phone number (8 digits only)
  static List<TextInputFormatter> formatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(8),
    ];
  }
}

