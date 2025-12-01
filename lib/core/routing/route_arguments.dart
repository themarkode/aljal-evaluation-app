/// Arguments for navigation between routes
class RouteArguments {
  RouteArguments._();
}

/// Arguments for evaluation-related routes
class EvaluationArguments {
  final String? evaluationId;
  final bool isEditing;
  final bool isViewing;

  const EvaluationArguments({
    this.evaluationId,
    this.isEditing = false,
    this.isViewing = false,
  });

  /// Create arguments for new evaluation
  factory EvaluationArguments.create() {
    return const EvaluationArguments(
      isEditing: true,
    );
  }

  /// Create arguments for editing evaluation
  factory EvaluationArguments.edit(String evaluationId) {
    return EvaluationArguments(
      evaluationId: evaluationId,
      isEditing: true,
    );
  }

  /// Create arguments for viewing evaluation
  factory EvaluationArguments.view(String evaluationId) {
    return EvaluationArguments(
      evaluationId: evaluationId,
      isViewing: true,
    );
  }
}

/// Arguments for form step routes
class FormStepArguments {
  final String? evaluationId;
  final int currentStep;
  final bool canGoBack;
  final bool canGoForward;

  const FormStepArguments({
    this.evaluationId,
    required this.currentStep,
    this.canGoBack = true,
    this.canGoForward = true,
  });

  /// Create arguments for specific step
  factory FormStepArguments.forStep({
    required int step,
    String? evaluationId,
  }) {
    return FormStepArguments(
      evaluationId: evaluationId,
      currentStep: step,
      canGoBack: step > 1,
      canGoForward: step < 9,
    );
  }

  /// Copy with modifications
  FormStepArguments copyWith({
    String? evaluationId,
    int? currentStep,
    bool? canGoBack,
    bool? canGoForward,
  }) {
    return FormStepArguments(
      evaluationId: evaluationId ?? this.evaluationId,
      currentStep: currentStep ?? this.currentStep,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
    );
  }

  /// Go to next step
  FormStepArguments nextStep() {
    final nextStepNumber = currentStep + 1;
    return FormStepArguments(
      evaluationId: evaluationId,
      currentStep: nextStepNumber,
      canGoBack: true,
      canGoForward: nextStepNumber < 9,
    );
  }

  /// Go to previous step
  FormStepArguments previousStep() {
    final prevStepNumber = currentStep - 1;
    return FormStepArguments(
      evaluationId: evaluationId,
      currentStep: prevStepNumber,
      canGoBack: prevStepNumber > 1,
      canGoForward: true,
    );
  }
}