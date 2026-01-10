import 'package:flutter/material.dart';

/// Modern, Elegant Color Palette for Al-Jal Evaluation App
/// 
/// Designed for a professional real estate evaluation application
/// with Arabic UI support and beautiful gradients.
class AppColors {
  AppColors._();

  // ============================================================
  // PRIMARY BRAND COLORS - Deep Navy & Gold Theme
  // ============================================================

  /// Deep navy blue - main brand color
  static const Color navy = Color(0xFF1A237E);
  
  /// Rich navy for headers
  static const Color navyDark = Color(0xFF0D1B3E);
  
  /// Lighter navy for accents
  static const Color navyLight = Color(0xFF3949AB);
  
  /// Gold accent - premium feel
  static const Color gold = Color(0xFFD4AF37);
  
  /// Light gold for highlights
  static const Color goldLight = Color(0xFFF5E6B3);

  // ============================================================
  // SEMANTIC COLORS - Status colors
  // ============================================================

  /// Success green - modern teal-green
  static const Color success = Color(0xFF00897B);
  static const Color successLight = Color(0xFFE0F2F1);
  
  /// Error red - soft but noticeable
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  
  /// Warning amber
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF8E1);
  
  /// Info blue
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ============================================================
  // NEUTRAL COLORS - Modern grays
  // ============================================================

  /// Pure black for text
  static const Color black = Color(0xFF1A1A2E);
  
  /// Dark gray for secondary text
  static const Color darkGray = Color(0xFF4A4A5C);
  
  /// Medium gray for borders
  static const Color mediumGray = Color(0xFFBDBDC7);
  
  /// Light gray for backgrounds
  static const Color lightGray = Color(0xFFF5F5F7);
  
  /// Off-white for surfaces
  static const Color offWhite = Color(0xFFFAFAFC);
  
  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================
  // GRADIENT DEFINITIONS
  // ============================================================

  /// Primary gradient - for headers and buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyDark, navy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gold gradient - for accents and highlights
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E6B3), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [offWhite, lightGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================
  // SEMANTIC ALIASES
  // ============================================================

  /// Primary color
  static const Color primary = navy;
  
  /// Primary variant
  static const Color primaryDark = navyDark;
  static const Color primaryLight = navyLight;
  
  /// Accent color
  static const Color accent = gold;
  
  /// Background color
  static const Color background = lightGray;
  
  /// Surface color (cards, dialogs)
  static const Color surface = white;
  
  /// Elevated surface (floating elements)
  static const Color surfaceElevated = offWhite;
  
  /// Text colors
  static const Color textPrimary = black;
  static const Color textSecondary = darkGray;
  static const Color textHint = mediumGray;
  
  /// Border color
  static const Color border = mediumGray;
  static const Color borderLight = Color(0xFFE8E8EC);

  // ============================================================
  // COMPONENT-SPECIFIC COLORS
  // ============================================================

  /// Section header (collapsible)
  static const Color sectionHeader = navy;
  
  /// Validation dot
  static const Color validationDot = success;
  
  /// Delete button
  static const Color deleteButton = error;
  
  /// Primary action button
  static const Color primaryButton = navy;
  
  /// Success button
  static const Color successButton = success;
  
  /// Card shadow color
  static Color cardShadow = black.withOpacity(0.08);
  
  /// Overlay color
  static Color overlay = black.withOpacity(0.5);

  // ============================================================
  // LEGACY ALIASES (for compatibility)
  // ============================================================
  
  static const Color lightBlue = navy;
  static const Color green = success;
  static const Color lightGreen = Color(0xFF4DB6AC);
  static const Color lightRed = error;
  static const Color midBlack = darkGray;
  static const Color midGray = mediumGray;
  static const Color successIndicator = lightGreen;
}
