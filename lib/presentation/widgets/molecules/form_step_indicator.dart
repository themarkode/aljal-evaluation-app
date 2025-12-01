import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/constants/app_constants.dart';

/// Form step indicator showing progress through 9 steps
class FormStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const FormStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = AppConstants.totalFormSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step counter text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة $currentStep من $totalSteps',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                '${((currentStep / totalSteps) * 100).toInt()}%',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceXS,

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: 8,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          AppSpacing.verticalSpaceXS,

          // Current step title
          if (currentStep >= 1 &&
              currentStep <= AppConstants.formStepTitles.length)
            Text(
              AppConstants.formStepTitles[currentStep - 1],
              style: AppTypography.fieldTitle,
              textDirection: TextDirection.rtl,
            ),
        ],
      ),
    );
  }
}
