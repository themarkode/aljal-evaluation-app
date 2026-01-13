import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/additional_data_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 9: Additional Data Screen
class Step9AdditionalDataScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step9AdditionalDataScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step9AdditionalDataScreen> createState() =>
      _Step9AdditionalDataScreenState();
}

class _Step9AdditionalDataScreenState
    extends ConsumerState<Step9AdditionalDataScreen> with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _evaluationPurposeController;
  late TextEditingController _buildingSystemController;
  late TextEditingController _buildingRatioController;
  late TextEditingController _accordingToController;

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _evaluationPurposeController = TextEditingController();
    _buildingSystemController = TextEditingController();
    _buildingRatioController = TextEditingController();
    _accordingToController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final additionalData = evaluation.additionalData;

    if (additionalData != null) {
      _evaluationPurposeController.text =
          additionalData.evaluationPurpose ?? '';
      _buildingSystemController.text = additionalData.buildingSystem ?? '';
      _buildingRatioController.text = additionalData.buildingRatio ?? '';
      _accordingToController.text = additionalData.accordingTo ?? '';
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    _evaluationPurposeController.dispose();
    _buildingSystemController.dispose();
    _buildingRatioController.dispose();
    _accordingToController.dispose();
    super.dispose();
  }

  /// Validate the form - returns true if valid
  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// Called when validation fails
  void _onValidationFailed() {
    _formKey.currentState?.validate();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save to memory state only (no Firebase save)
      saveCurrentDataToState();

      // Navigate to Step 10
      StepNavigation.goToNextStep(
        context,
        currentStep: 9,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 9,
        evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final additionalData = AdditionalDataModel(
      evaluationPurpose: _evaluationPurposeController.textOrNull,
      buildingSystem: _buildingSystemController.textOrNull,
      buildingRatio: _buildingRatioController.textOrNull,
      accordingTo: _accordingToController.textOrNull,
    );
    ref.read(evaluationNotifierProvider.notifier).updateAdditionalData(additionalData);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 9,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
                    onNext: _saveAndContinue,
                    onPrevious: _goBack,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      mobileContent: _buildMobileLayout(),
      tabletContent: _buildTabletLayout(),
      desktopContent: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Evaluation Purpose Section
        _buildEvaluationPurposeField(),
        AppSpacing.verticalSpaceMD,

        // Regulatory Opinion Section
        _buildBuildingSystemField(),
        AppSpacing.verticalSpaceMD,
        _buildBuildingRatioField(),
        AppSpacing.verticalSpaceMD,
        _buildAccordingToField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Evaluation Purpose Section
        _buildEvaluationPurposeField(),
        AppSpacing.verticalSpaceMD,

        // Regulatory Opinion Section
        Row(
          children: [
            Expanded(child: _buildBuildingSystemField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildBuildingRatioField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildAccordingToField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildEvaluationPurposeField() {
    return CustomTextField(
      controller: _evaluationPurposeController,
      label: 'الغرض من التقييم',
      hint: 'الغرض من التقييم',
      showValidationDot: true,
    );
  }

  Widget _buildBuildingSystemField() {
    return CustomTextField(
      controller: _buildingSystemController,
      label: 'نظام البناء',
      hint: 'نظام البناء',
      showValidationDot: true,
    );
  }

  Widget _buildBuildingRatioField() {
    return CustomTextField(
      controller: _buildingRatioController,
      label: 'النسبة',
      hint: 'النسبة',
      showValidationDot: true,
    );
  }

  Widget _buildAccordingToField() {
    return CustomTextField(
      controller: _accordingToController,
      label: 'حسب',
      hint: 'حسب',
      showValidationDot: true,
    );
  }
}
