import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';

/// Centralized step navigation helper.
/// 
/// This class provides static methods for navigating between form steps,
/// reducing duplicate navigation code across all step screens.
/// 
/// Usage:
/// ```dart
/// StepNavigation.goToStep(context, 2, evaluationId: 'abc123');
/// StepNavigation.goToNextStep(context, currentStep: 1, evaluationId: 'abc123');
/// StepNavigation.goToPreviousStep(context, currentStep: 2, evaluationId: 'abc123');
/// ```
class StepNavigation {
  StepNavigation._(); // Private constructor to prevent instantiation

  /// Total number of steps in the form
  static const int totalSteps = 11;

  /// Step names for display
  static const Map<int, String> stepNames = {
    1: 'المعلومات العامة',
    2: 'بيانات العقار العامة',
    3: 'وصف العقار',
    4: 'الأدوار',
    5: 'تفاصيل المنطقة',
    6: 'ملاحظات الدخل',
    7: 'المخططات الموقعية',
    8: 'صور العقار',
    9: 'بيانات إضافية',
    10: 'تكلفة المباني والأرض',
    11: 'الدخل الاقتصادي',
  };

  /// Get the route name for a given step
  static String getRouteForStep(int step) {
    switch (step) {
      case 1:
        return RouteNames.formStep1;
      case 2:
        return RouteNames.formStep2;
      case 3:
        return RouteNames.formStep3;
      case 4:
        return RouteNames.formStep4;
      case 5:
        return RouteNames.formStep5;
      case 6:
        return RouteNames.formStep6;
      case 7:
        return RouteNames.formStep7;
      case 8:
        return RouteNames.formStep8;
      case 9:
        return RouteNames.formStep9;
      case 10:
        return RouteNames.formStep10;
      case 11:
        return RouteNames.formStep11;
      default:
        return RouteNames.formStep1;
    }
  }

  /// Get the step name for display
  static String getStepName(int step) {
    return stepNames[step] ?? 'خطوة $step';
  }

  /// Navigate to a specific step
  static void goToStep(
    BuildContext context,
    int step, {
    String? evaluationId,
    bool replace = true,
  }) {
    final routeName = getRouteForStep(step);
    final arguments = FormStepArguments.forStep(
      step: step,
      evaluationId: evaluationId,
    );

    if (replace) {
      Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
    } else {
      Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Navigate to the next step
  static void goToNextStep(
    BuildContext context, {
    required int currentStep,
    String? evaluationId,
  }) {
    if (currentStep < totalSteps) {
      goToStep(context, currentStep + 1, evaluationId: evaluationId);
    }
  }

  /// Navigate to the previous step
  static void goToPreviousStep(
    BuildContext context, {
    required int currentStep,
    String? evaluationId,
  }) {
    if (currentStep > 1) {
      goToStep(context, currentStep - 1, evaluationId: evaluationId);
    }
  }

  /// Navigate to the evaluation list
  static void goToEvaluationList(BuildContext context, {bool clearStack = true}) {
    if (clearStack) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.evaluationList,
        (route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.evaluationList);
    }
  }

  /// Check if a step is valid
  static bool isValidStep(int step) {
    return step >= 1 && step <= totalSteps;
  }

  /// Check if current step is the first step
  static bool isFirstStep(int step) => step == 1;

  /// Check if current step is the last step
  static bool isLastStep(int step) => step == totalSteps;

  /// Get progress percentage (0.0 to 1.0)
  static double getProgressPercentage(int step) {
    return step / totalSteps;
  }

  /// Get all step items for dropdown/navigation
  static List<StepItem> getAllStepItems() {
    return List.generate(
      totalSteps,
      (index) => StepItem(
        step: index + 1,
        name: getStepName(index + 1),
      ),
    );
  }
}

/// Model class for step item
class StepItem {
  final int step;
  final String name;

  const StepItem({
    required this.step,
    required this.name,
  });

  @override
  String toString() => 'الخطوة $step: $name';
}

