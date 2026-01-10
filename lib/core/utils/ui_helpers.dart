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

  /// Show date picker with custom input dialog that uses regular keyboard
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? DateTime(2100);
    final effectiveInitialDate = initialDate ?? now;

    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _CustomDatePickerDialog(
          initialDate: effectiveInitialDate,
          firstDate: effectiveFirstDate,
          lastDate: effectiveLastDate,
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

/// Custom date picker dialog with regular keyboard for manual input
class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CustomDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late TextEditingController _textController;
  late DateTime _selectedDate;
  bool _isCalendarMode = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _textController = TextEditingController(
      text: _formatDate(_selectedDate),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  DateTime? _parseDate(String text) {
    try {
      // Try parsing dd/mm/yyyy format
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day != null && month != null && year != null) {
          if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900 && year <= 2100) {
            final date = DateTime(year, month, day);
            // Verify the date is valid (e.g., not Feb 30)
            if (date.day == day && date.month == month && date.year == year) {
              return date;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void _validateAndSetDate(String text) {
    final date = _parseDate(text);
    if (date != null) {
      if (date.isBefore(widget.firstDate)) {
        setState(() => _errorText = 'التاريخ قبل الحد الأدنى');
      } else if (date.isAfter(widget.lastDate)) {
        setState(() => _errorText = 'التاريخ بعد الحد الأقصى');
      } else {
        setState(() {
          _selectedDate = date;
          _errorText = null;
        });
      }
    } else if (text.isNotEmpty) {
      setState(() => _errorText = 'تنسيق غير صالح (يوم/شهر/سنة)');
    } else {
      setState(() => _errorText = null);
    }
  }

  void _showCalendar() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      locale: const Locale('ar'),
      helpText: 'اختيار التاريخ',
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
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _textController.text = _formatDate(date);
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'اختيار التاريخ',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            // Toggle between calendar and text input
            IconButton(
              icon: Icon(
                _isCalendarMode ? Icons.edit : Icons.calendar_today,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() => _isCalendarMode = !_isCalendarMode);
              },
              tooltip: _isCalendarMode ? 'إدخال يدوي' : 'التقويم',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isCalendarMode) ...[
              // Calendar mode - show selected date and calendar button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatDate(_selectedDate),
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showCalendar,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('فتح التقويم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Text input mode - show text field with regular keyboard
              Text(
                'أدخل التاريخ بصيغة: يوم/شهر/سنة',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                // Use text keyboard type for full keyboard with "/" character
                keyboardType: TextInputType.text,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall,
                decoration: InputDecoration(
                  hintText: 'يوم/شهر/سنة',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  errorText: _errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _validateAndSetDate,
              ),
              const SizedBox(height: 8),
              Text(
                'مثال: 29/12/2025',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _errorText == null
                ? () => Navigator.of(context).pop(_selectedDate)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(
              'تأكيد',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
