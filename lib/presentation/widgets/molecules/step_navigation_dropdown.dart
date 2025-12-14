import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';

/// Step data for navigation
class StepInfo {
  final int stepNumber;
  final String title;
  final String routeName;

  const StepInfo({
    required this.stepNumber,
    required this.title,
    required this.routeName,
  });
}

/// All form steps
const List<StepInfo> allSteps = [
  StepInfo(stepNumber: 1, title: 'معلومات عامة', routeName: RouteNames.formStep1),
  StepInfo(stepNumber: 2, title: 'معلومات عامة للعقار', routeName: RouteNames.formStep2),
  StepInfo(stepNumber: 3, title: 'الوصف العام للعقار', routeName: RouteNames.formStep3),
  StepInfo(stepNumber: 4, title: 'الطوابق', routeName: RouteNames.formStep4),
  StepInfo(stepNumber: 5, title: 'تفاصيل المساحة', routeName: RouteNames.formStep5),
  StepInfo(stepNumber: 6, title: 'ملاحظات الدخل', routeName: RouteNames.formStep6),
  StepInfo(stepNumber: 7, title: 'المخططات الموقعية', routeName: RouteNames.formStep7),
  StepInfo(stepNumber: 8, title: 'صور العقار', routeName: RouteNames.formStep8),
  StepInfo(stepNumber: 9, title: 'بيانات إضافية', routeName: RouteNames.formStep9),
];

/// A compact dropdown widget for navigating between form steps (for AppBar use)
class StepNavigationDropdown extends StatelessWidget {
  final int currentStep;
  final String? evaluationId;

  const StepNavigationDropdown({
    super.key,
    required this.currentStep,
    this.evaluationId,
  });

  void _navigateToStep(BuildContext context, StepInfo step) {
    if (step.stepNumber == currentStep) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      step.routeName,
      arguments: FormStepArguments.forStep(
        step: step.stepNumber,
        evaluationId: evaluationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStepInfo = allSteps[currentStep - 1];

    return PopupMenuButton<StepInfo>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      elevation: 8,
      onSelected: (step) => _navigateToStep(context, step),
      itemBuilder: (context) => allSteps.map((step) {
        final isCurrentStep = step.stepNumber == currentStep;
        return PopupMenuItem<StepInfo>(
          value: step,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Step number circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCurrentStep ? AppColors.primary : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentStep ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isCurrentStep ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Step title
                Expanded(
                  child: Text(
                    step.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isCurrentStep ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isCurrentStep ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // Check icon for current step
                if (isCurrentStep)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current step title (appears on RIGHT in RTL)
            Text(
              currentStepInfo.title,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            // Step indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$currentStep',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), // Space between content and arrow
            // Dropdown arrow (appears on LEFT in RTL)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
