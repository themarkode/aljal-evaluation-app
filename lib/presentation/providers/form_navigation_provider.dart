import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'form_navigation_provider.g.dart';

// Enum for all form steps
enum FormStep {
  generalInfo,          // معلومات عامة
  generalPropertyInfo,  // معلومات عامة للعقار
  propertyDescription,  // وصف العقار
  generalDescription,   // الوصف العام للعقار
  areaDetails,         // تفاصيل المنطقة المحيطة بالعقار
  incomeNotes,         // ملاحظات الدخل
  sitePlans,           // المخطط ورفع القياس بالموقع
  propertyImages,      // صور وموقع العقار
  additionalData,      // بيانات إضافية
  buildingLandCost,    // تكلفة المباني والأرض
  economicIncome,      // الدخل الاقتصادي
}

@riverpod
class FormNavigationNotifier extends _$FormNavigationNotifier {
  @override
  FormNavigationState build() {
    return FormNavigationState(
      currentStep: FormStep.generalInfo,
      completedSteps: {},
      totalSteps: FormStep.values.length,
    );
  }
  
  // Navigate to specific step
  void goToStep(FormStep step) {
    state = state.copyWith(currentStep: step);
  }
  
  // Go to next step
  void nextStep() {
    final currentIndex = FormStep.values.indexOf(state.currentStep);
    if (currentIndex < FormStep.values.length - 1) {
      final nextStep = FormStep.values[currentIndex + 1];
      state = state.copyWith(
        currentStep: nextStep,
        completedSteps: {...state.completedSteps, state.currentStep},
      );
    }
  }
  
  // Go to previous step
  void previousStep() {
    final currentIndex = FormStep.values.indexOf(state.currentStep);
    if (currentIndex > 0) {
      final previousStep = FormStep.values[currentIndex - 1];
      state = state.copyWith(currentStep: previousStep);
    }
  }
  
  // Mark step as completed
  void markStepCompleted(FormStep step) {
    state = state.copyWith(
      completedSteps: {...state.completedSteps, step},
    );
  }
  
  // Check if step is completed
  bool isStepCompleted(FormStep step) {
    return state.completedSteps.contains(step);
  }
  
  // Check if can proceed to next step
  bool canProceed() {
    // Add validation logic here if needed
    return true;
  }
  
  // Get current step index (1-based for display)
  int getCurrentStepNumber() {
    return FormStep.values.indexOf(state.currentStep) + 1;
  }
  
  // Get step title in Arabic
  String getStepTitle(FormStep step) {
    switch (step) {
      case FormStep.generalInfo:
        return 'معلومات عامة';
      case FormStep.generalPropertyInfo:
        return 'معلومات عامة للعقار';
      case FormStep.propertyDescription:
        return 'وصف العقار';
      case FormStep.generalDescription:
        return 'الوصف العام للعقار';
      case FormStep.areaDetails:
        return 'تفاصيل المنطقة المحيطة بالعقار';
      case FormStep.incomeNotes:
        return 'ملاحظات الدخل';
      case FormStep.sitePlans:
        return 'المخطط ورفع القياس بالموقع';
      case FormStep.propertyImages:
        return 'صور وموقع العقار';
      case FormStep.additionalData:
        return 'بيانات إضافية';
      case FormStep.buildingLandCost:
        return 'تكلفة المباني والأرض';
      case FormStep.economicIncome:
        return 'الدخل الاقتصادي';
    }
  }
  
  // Reset navigation
  void reset() {
    state = FormNavigationState(
      currentStep: FormStep.generalInfo,
      completedSteps: {},
      totalSteps: FormStep.values.length,
    );
  }
}

// State class for form navigation
class FormNavigationState {
  final FormStep currentStep;
  final Set<FormStep> completedSteps;
  final int totalSteps;
  
  FormNavigationState({
    required this.currentStep,
    required this.completedSteps,
    required this.totalSteps,
  });
  
  FormNavigationState copyWith({
    FormStep? currentStep,
    Set<FormStep>? completedSteps,
    int? totalSteps,
  }) {
    return FormNavigationState(
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}


