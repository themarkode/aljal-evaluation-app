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

/// A dropdown widget for navigating between form steps
class StepNavigationDropdown extends StatefulWidget {
  final int currentStep;
  final String? evaluationId;

  const StepNavigationDropdown({
    super.key,
    required this.currentStep,
    this.evaluationId,
  });

  @override
  State<StepNavigationDropdown> createState() => _StepNavigationDropdownState();
}

class _StepNavigationDropdownState extends State<StepNavigationDropdown> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _navigateToStep(StepInfo step) {
    if (step.stepNumber == widget.currentStep) {
      // Already on this step, just close the dropdown
      setState(() {
        _isExpanded = false;
      });
      return;
    }

    // Navigate to the selected step
    Navigator.pushReplacementNamed(
      context,
      step.routeName,
      arguments: FormStepArguments.forStep(
        step: step.stepNumber,
        evaluationId: widget.evaluationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStepInfo = allSteps[widget.currentStep - 1];

    return Column(
      children: [
        // Dropdown header button
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current step title
                Text(
                  currentStepInfo.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Expand/collapse icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown list
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: allSteps.map((step) {
                  final isCurrentStep = step.stepNumber == widget.currentStep;
                  
                  return InkWell(
                    onTap: () => _navigateToStep(step),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentStep
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: step.stepNumber < allSteps.length
                              ? BorderSide(
                                  color: AppColors.border.withOpacity(0.5),
                                  width: 1,
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Step number circle
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrentStep
                                  ? AppColors.primary
                                  : AppColors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCurrentStep
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${step.stepNumber}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isCurrentStep
                                      ? Colors.white
                                      : AppColors.textSecondary,
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
                                color: isCurrentStep
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isCurrentStep
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
              ),
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

