/// Route names for navigation
class RouteNames {
  RouteNames._();

  // ============================================================
  // MAIN ROUTES
  // ============================================================
  
  /// Initial route - Evaluation list screen
  static const String initial = '/';
  
  /// Evaluation list screen (التقارير)
  static const String evaluationList = '/evaluations';
  
  /// Create new evaluation
  static const String newEvaluation = '/evaluations/new';
  
  /// Edit existing evaluation
  static const String editEvaluation = '/evaluations/edit';
  
  /// View evaluation details
  static const String viewEvaluation = '/evaluations/view';

  // ============================================================
  // FORM STEP ROUTES
  // ============================================================
  
  /// Form Step 1: معلومات عامة (General Info)
  static const String formStep1 = '/form/step1';
  
  /// Form Step 2: معلومات عامة للعقار (Property Info)
  static const String formStep2 = '/form/step2';
  
  /// Form Step 3: وصف العقار (Property Description)
  static const String formStep3 = '/form/step3';
  
  /// Form Step 4: الوصف العام للعقار (Floors)
  static const String formStep4 = '/form/step4';
  
  /// Form Step 5: تفاصيل المنطقة المحيطة (Area Details)
  static const String formStep5 = '/form/step5';
  
  /// Form Step 6: ملاحظات الدخل (Income Notes)
  static const String formStep6 = '/form/step6';
  
  /// Form Step 7: المخطط ورفع القياس (Site Plans)
  static const String formStep7 = '/form/step7';
  
  /// Form Step 8: صور وموقع العقار (Property Images)
  static const String formStep8 = '/form/step8';
  
  /// Form Step 9: بيانات إضافية (Additional Data)
  static const String formStep9 = '/form/step9';

  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  /// Get form step route by index (1-9)
  static String getFormStepRoute(int step) {
    switch (step) {
      case 1:
        return formStep1;
      case 2:
        return formStep2;
      case 3:
        return formStep3;
      case 4:
        return formStep4;
      case 5:
        return formStep5;
      case 6:
        return formStep6;
      case 7:
        return formStep7;
      case 8:
        return formStep8;
      case 9:
        return formStep9;
      default:
        return formStep1;
    }
  }
  
  /// Get step number from route
  static int getStepNumberFromRoute(String route) {
    switch (route) {
      case formStep1:
        return 1;
      case formStep2:
        return 2;
      case formStep3:
        return 3;
      case formStep4:
        return 4;
      case formStep5:
        return 5;
      case formStep6:
        return 6;
      case formStep7:
        return 7;
      case formStep8:
        return 8;
      case formStep9:
        return 9;
      default:
        return 1;
    }
  }
  
  /// Get edit evaluation route with ID
  static String getEditEvaluationRoute(String evaluationId) {
    return '$editEvaluation/$evaluationId';
  }
  
  /// Get view evaluation route with ID
  static String getViewEvaluationRoute(String evaluationId) {
    return '$viewEvaluation/$evaluationId';
  }
}