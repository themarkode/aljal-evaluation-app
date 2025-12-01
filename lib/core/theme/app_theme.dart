import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.success,
        error: AppColors.error,
        surface: AppColors.surface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.heading,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
          side: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: AppSpacing.fieldPadding,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppSpacing.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderWidthThick,
          ),
        ),
        labelStyle: AppTypography.labelLarge,
        hintStyle: AppTypography.placeholder,
        errorStyle: AppTypography.errorText,
        helperStyle: AppTypography.helperText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: AppColors.white,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMD,
          ),
          elevation: 0,
          textStyle: AppTypography.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMD,
          ),
          side: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
          textStyle: AppTypography.buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonText,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: AppSpacing.iconSize,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: AppSpacing.borderWidth,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          return AppColors.white;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusSM,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          return AppColors.midGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success.withOpacity(0.5);
          }
          return AppColors.lightGray;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLG,
        ),
        titleTextStyle: AppTypography.heading,
        contentTextStyle: AppTypography.bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusTopLG,
        ),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.heading,
        displayMedium: AppTypography.heading,
        displaySmall: AppTypography.heading,
        headlineLarge: AppTypography.heading,
        headlineMedium: AppTypography.fieldTitle,
        headlineSmall: AppTypography.fieldTitle,
        titleLarge: AppTypography.fieldTitle,
        titleMedium: AppTypography.fieldTitle,
        titleSmall: AppTypography.dropdownOptions,
        bodyLarge: AppTypography.dropdownOptions,
        bodyMedium: AppTypography.addImageText,
        bodySmall: AppTypography.addImageText,
        labelLarge: AppTypography.buttonText,
        labelMedium: AppTypography.dropdownOptions,
        labelSmall: AppTypography.addImageText,
      ),
      fontFamily: AppTypography.fontFamily,
    );
  }
}
