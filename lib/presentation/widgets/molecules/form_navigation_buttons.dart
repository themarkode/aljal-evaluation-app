import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';

/// Step names for navigation display
const Map<int, String> stepNames = {
  1: 'معلومات عامة',
  2: 'معلومات عامة للعقار',
  3: 'وصف العقار',
  4: 'الطوابق',
  5: 'تفاصيل المساحة',
  6: 'ملاحظات الدخل',
  7: 'المخططات الموقعية',
  8: 'صور العقار',
  9: 'بيانات إضافية',
};

/// Form navigation buttons with step names (Previous Step Name | Next Step Name)
class FormNavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isLoading;
  final String? nextText; // Override for custom text (e.g., "حفظ النموذج")
  final String? previousText; // Override for custom text (e.g., "إلغاء")

  const FormNavigationButtons({
    super.key,
    required this.currentStep,
    this.onPrevious,
    this.onNext,
    this.isLoading = false,
    this.nextText,
    this.previousText,
  });

  String get _nextButtonText {
    if (nextText != null) return nextText!;
    if (currentStep >= 9) return 'حفظ النموذج';
    return stepNames[currentStep + 1] ?? 'التالي';
  }

  String get _previousButtonText {
    if (previousText != null) return previousText!;
    if (currentStep <= 1) return 'إلغاء';
    return stepNames[currentStep - 1] ?? 'السابق';
  }

  bool get _isFirstStep => currentStep <= 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Next button (Right side in RTL) - Primary action
            Expanded(
              child: _buildNextButton(),
            ),
            const SizedBox(width: 12),
            // Previous/Cancel button (Left side in RTL)
            Expanded(
              child: _buildPreviousButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onNext,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text or loading indicator
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Flexible(
                  child: Text(
                    _nextButtonText,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              // Arrow icon (pointing left in RTL for "forward/next")
              if (!isLoading) const SizedBox(width: 8),
              if (!isLoading)
                const Icon(
                  Icons.arrow_back_rounded, // Flipped: use back arrow for RTL "next"
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPrevious,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFirstStep ? AppColors.border : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arrow/X icon first (on the right in RTL)
              Icon(
                _isFirstStep ? Icons.close_rounded : Icons.arrow_forward_rounded, // Flipped: use forward arrow for RTL "back"
                color: _isFirstStep ? AppColors.textSecondary : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              // Text
              Flexible(
                child: Text(
                  _previousButtonText,
                  style: AppTypography.labelMedium.copyWith(
                    color: _isFirstStep ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
