import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Modern Typography System for Al-Jal Evaluation App
/// 
/// Uses Inter font with Arabic-optimized styles.
/// Designed for readability and elegance.
class AppTypography {
  AppTypography._();

  // ============================================================
  // FONT FAMILY
  // ============================================================

  static const String fontFamily = 'Inter';
  static const String arabicFontFamily = 'Inter'; // Can be changed to Tajawal or Cairo

  // ============================================================
  // DISPLAY STYLES - For large headings
  // ============================================================

  /// Display Large - App title, splash screen
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display Medium - Section titles
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  /// Display Small - Card titles
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // HEADLINE STYLES - For page titles
  // ============================================================

  /// Headline Large - Page titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Headline Medium - Section headers
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  /// Headline Small - Subsection headers
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ============================================================
  // TITLE STYLES - For emphasis
  // ============================================================

  /// Title Large - Important labels
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Title Medium - Form labels
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Title Small - Small labels
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  // ============================================================
  // BODY STYLES - For content
  // ============================================================

  /// Body Large - Main content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Body Medium - Secondary content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Body Small - Tertiary content
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ============================================================
  // LABEL STYLES - For buttons and chips
  // ============================================================

  /// Label Large - Primary buttons
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Label Medium - Secondary buttons
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Label Small - Chips and tags
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  // ============================================================
  // SEMANTIC STYLES - Purpose-based
  // ============================================================

  /// Main heading style
  static const TextStyle heading = headlineLarge;

  /// Field title (form labels)
  static const TextStyle fieldTitle = titleMedium;

  /// Section header (collapsible sections)
  static TextStyle sectionHeader = headlineMedium.copyWith(
    color: AppColors.white,
    fontWeight: FontWeight.w600,
  );

  /// Button text
  static const TextStyle buttonText = labelLarge;

  /// Input text
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Placeholder text
  static const TextStyle placeholder = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  /// Helper text
  static const TextStyle helperText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Error text
  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.4,
  );

  /// Card title
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Card subtitle
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Badge text
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // ============================================================
  // LEGACY ALIASES (for compatibility)
  // ============================================================

  static const TextStyle dropdownOptions = bodyLarge;
  static const TextStyle underlineText = headlineMedium;
  static const TextStyle addImageText = bodyMedium;

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle toBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle toUnderlined(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: style.color,
    );
  }
}
