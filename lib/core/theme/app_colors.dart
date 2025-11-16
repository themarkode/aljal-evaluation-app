import 'package:flutter/material.dart';

/// App color palette based on Figma design system
///
/// This class defines all colors used throughout the app.
/// Colors are organized into categories for better maintainability.
/// All colors are defined as static constants for compile-time optimization.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================
  // PRIMARY COLORS - Main brand colors
  // ============================================================

  /// Primary blue used for main actions and primary buttons
  /// Hex: #007AD3
  static const Color lightBlue = Color(0xFF007AD3);

  /// Primary green used for success states and confirmation actions
  /// Hex: #129E44
  static const Color green = Color(0xFF129E44);

  /// Light green used for success indicators and validation dots
  /// Hex: #1FDB81
  static const Color lightGreen = Color(0xFF1FDB81);

  // ============================================================
  // SEMANTIC COLORS - Status and feedback colors
  // ============================================================

  /// Error color for warnings, errors, and destructive actions
  /// Hex: #DD1D1D
  static const Color lightRed = Color(0xFFDD1D1D);

  // ============================================================
  // NEUTRAL COLORS - Grays and text colors
  // ============================================================

  /// Pure black for primary text and icons
  /// Hex: #03111B
  static const Color black = Color(0xFF03111B);

  /// Mid-tone black with 70% opacity for secondary text
  /// Hex: #03111B with opacity 0.7
  static const Color midBlack = Color(0xB303111B); // Note: B3 = 70% in hex

  /// Mid gray for borders and dividers
  /// Hex: #D1D1D1
  static const Color midGray = Color(0xFFD1D1D1);

  /// Light gray for backgrounds and disabled states
  /// Hex: #E0E0E0
  static const Color lightGray = Color(0xFFE0E0E0);

  /// Pure white for backgrounds and contrast
  /// Hex: #FFFFFF
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================
  // SEMANTIC ALIASES - For better code readability
  // ============================================================

  /// Primary color - used for main actions (buttons, links)
  static const Color primary = lightBlue;

  /// Success color - used for completed actions and validation
  static const Color success = green;

  /// Success indicator - used for validation dots and checkmarks
  static const Color successIndicator = lightGreen;

  /// Error color - used for errors and destructive actions
  static const Color error = lightRed;

  /// Background color - main app background
  static const Color background = lightGray;

  /// Surface color - card and container backgrounds
  static const Color surface = white;

  /// Text primary - main text color
  static const Color textPrimary = black;

  /// Text secondary - subtle text and labels
  static const Color textSecondary = midBlack;

  /// Border color - dividers and field borders
  static const Color border = midGray;

  // ============================================================
  // SPECIFIC USE CASES - Component-specific colors
  // ============================================================

  /// Section header background (collapsible blue headers)
  static const Color sectionHeader = lightBlue;

  /// Validation dot color (green dots next to required fields)
  static const Color validationDot = lightGreen;

  /// Delete button color
  static const Color deleteButton = lightRed;

  /// Primary action button
  static const Color primaryButton = lightBlue;

  /// Success button (like "Save" or "Complete")
  static const Color successButton = green;
}
