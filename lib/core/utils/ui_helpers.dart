import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../constants/app_constants.dart';

/// UI helper functions for dialogs, snackbars, and loading indicators
class UIHelpers {
  UIHelpers._();

  // ============================================================
  // SNACKBAR
  // ============================================================

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration ?? AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: duration ?? AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: duration ?? AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.heading,
        ),
        content: Text(
          message,
          style: AppTypography.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText ?? AppConstants.confirmCancelButton,
              style: AppTypography.buttonText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDangerous ? AppColors.error : AppColors.primary,
            ),
            child: Text(
              confirmText ?? AppConstants.confirmDeleteButton,
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  static Future<bool?> showDeleteConfirmationDialog(
    BuildContext context, {
    String? itemName,
  }) async {
    return showConfirmationDialog(
      context,
      title: AppConstants.confirmDelete,
      message: AppConstants.confirmDeleteMessage,
      confirmText: AppConstants.confirmDeleteButton,
      cancelText: AppConstants.confirmCancelButton,
      isDangerous: true,
    );
  }

  // ============================================================
  // LOADING DIALOG
  // ============================================================

  /// Show loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                AppSpacing.verticalSpaceMD,
                Text(
                  message,
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  /// Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: AppSpacing.allSM,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: Text(
                title,
                style: AppTypography.heading,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyLarge,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? AppConstants.buttonClose),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR DIALOG
  // ============================================================

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: AppSpacing.allSM,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: AppColors.error,
                size: 32,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: Text(
                title,
                style: AppTypography.heading,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyLarge,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(buttonText ?? AppConstants.buttonClose),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET
  // ============================================================

  /// Show bottom sheet
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.radiusTopLG,
        ),
        child: child,
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  /// Show date picker
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // ============================================================
  // LOADING OVERLAY
  // ============================================================

  /// Show loading overlay (non-dialog)
  static Widget loadingOverlay({
    required bool isLoading,
    required Widget child,
    String? message,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: AppSpacing.allXL,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.radiusLG,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    if (message != null) ...[
                      AppSpacing.verticalSpaceMD,
                      Text(
                        message,
                        style: AppTypography.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // FOCUS MANAGEMENT
  // ============================================================

  /// Unfocus current text field
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Move focus to next field
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous field
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  // ============================================================
  // KEYBOARD
  // ============================================================

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // SCROLL
  // ============================================================

  /// Scroll to top
  static void scrollToTop(ScrollController controller) {
    controller.animateTo(
      0,
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  /// Scroll to bottom
  static void scrollToBottom(ScrollController controller) {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }
}
