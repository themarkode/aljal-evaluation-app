import 'package:flutter/material.dart';

/// Extension methods for [TextEditingController] to simplify form data extraction.
/// 
/// These helpers reduce the repetitive pattern of:
/// ```dart
/// fieldName: _controller.text.trim().isEmpty ? null : _controller.text.trim()
/// ```
/// 
/// To simply:
/// ```dart
/// fieldName: _controller.textOrNull
/// ```
extension FormFieldHelpers on TextEditingController {
  /// Returns the trimmed text value, or null if empty.
  /// 
  /// Example:
  /// ```dart
  /// final name = _nameController.textOrNull; // Returns String? 
  /// ```
  String? get textOrNull {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Returns the trimmed text parsed as an integer, or null if empty or invalid.
  /// 
  /// Example:
  /// ```dart
  /// final count = _countController.intOrNull; // Returns int?
  /// ```
  int? get intOrNull {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  /// Returns the trimmed text parsed as a double, or null if empty or invalid.
  /// 
  /// Example:
  /// ```dart
  /// final price = _priceController.doubleOrNull; // Returns double?
  /// ```
  double? get doubleOrNull {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  /// Returns the trimmed text, or a default value if empty.
  /// 
  /// Example:
  /// ```dart
  /// final name = _nameController.textOrDefault('Unknown'); // Returns String
  /// ```
  String textOrDefault(String defaultValue) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? defaultValue : trimmed;
  }

  /// Returns the trimmed text parsed as an integer, or a default value if empty/invalid.
  /// 
  /// Example:
  /// ```dart
  /// final count = _countController.intOrDefault(0); // Returns int
  /// ```
  int intOrDefault(int defaultValue) {
    return intOrNull ?? defaultValue;
  }

  /// Returns the trimmed text parsed as a double, or a default value if empty/invalid.
  /// 
  /// Example:
  /// ```dart
  /// final price = _priceController.doubleOrDefault(0.0); // Returns double
  /// ```
  double doubleOrDefault(double defaultValue) {
    return doubleOrNull ?? defaultValue;
  }
}

