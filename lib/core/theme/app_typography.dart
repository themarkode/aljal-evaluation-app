import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography based on Figma design system
///
/// This class defines all text styles used throughout the app.
/// All styles use the Inter font family as specified in the design.
/// Font sizes are in logical pixels (sp equivalent in Flutter).
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ============================================================
  // FONT FAMILY
  // ============================================================

  /// Primary font family for the entire app
  static const String fontFamily = 'Inter';

  // ============================================================
  // BASE TEXT STYLES - From Figma Design System
  // ============================================================

  /// Field Title Style
  /// Used for: Form field labels, section titles
  /// Font: Inter Semi Bold, Size: 22px
  static const TextStyle fieldTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600, // Semi Bold
    color: AppColors.textPrimary,
    height: 1.3, // Line height multiplier
  );

  /// Dropdown Options Style
  /// Used for: Dropdown menu items, selectable options
  /// Font: Inter Medium, Size: 22px
  static const TextStyle dropdownOptions = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Heading Style
  /// Used for: Page titles, main headings
  /// Font: Inter Semi Bold, Size: 24px
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semi Bold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Underline Text Style
  /// Used for: Section headers with underline, emphasized text
  /// Font: Inter Semi Bold, Size: 22px, Underlined
  static const TextStyle underlineText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600, // Semi Bold
    color: AppColors.textPrimary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.textPrimary,
    height: 1.3,
  );

  /// Add Image Text Style
  /// Used for: Image upload placeholders, helper text
  /// Font: Inter Regular, Size: 18px
  static const TextStyle addImageText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ============================================================
  // SEMANTIC TEXT STYLES - Purpose-based naming
  // ============================================================

  /// Body text - regular content
  static const TextStyle bodyLarge = dropdownOptions;

  /// Body text - smaller content
  static const TextStyle bodyMedium = addImageText;

  /// Labels for form fields
  static const TextStyle labelLarge = fieldTitle;

  /// Page titles and main headings
  static const TextStyle titleLarge = heading;

  // ============================================================
  // COMPONENT-SPECIFIC STYLES - For specific use cases
  // ============================================================

  /// Text style for section headers (blue collapsible headers)
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.white, // White text on blue background
    height: 1.3,
  );

  /// Text style for button text (primary buttons)
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  /// Text style for placeholder text
  static const TextStyle placeholder = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.midGray,
    height: 1.3,
  );

  /// Text style for input field text
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Text style for error messages
  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );

  /// Text style for helper text (hints below fields)
  static const TextStyle helperText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ============================================================
  // UTILITY METHODS - For creating variations
  // ============================================================

  /// Create a copy of a text style with a different color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Create a copy of a text style with a different size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create a copy of a text style with a different weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create a bold version of a text style
  static TextStyle toBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Create an underlined version of a text style
  static TextStyle toUnderlined(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: style.color,
    );
  }
}
