import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/site_plans_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 7: Site Plans Screen
class Step7SitePlansScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step7SitePlansScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step7SitePlansScreen> createState() =>
      _Step7SitePlansScreenState();
}

class _Step7SitePlansScreenState extends ConsumerState<Step7SitePlansScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _generalNotesController;
  late TextEditingController _approvedPlanComparisonController;
  late TextEditingController _siteMeasurementNumbersController;
  late TextEditingController _violationNotesController;

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _generalNotesController = TextEditingController();
    _approvedPlanComparisonController = TextEditingController();
    _siteMeasurementNumbersController = TextEditingController();
    _violationNotesController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final sitePlans = evaluation.sitePlans;

    if (sitePlans != null) {
      _generalNotesController.text = sitePlans.generalNotes ?? '';
      _approvedPlanComparisonController.text =
          sitePlans.approvedPlanComparison ?? '';
      _siteMeasurementNumbersController.text =
          sitePlans.siteMeasurementNumbers ?? '';
      _violationNotesController.text = sitePlans.violationNotes ?? '';
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    _generalNotesController.dispose();
    _approvedPlanComparisonController.dispose();
    _siteMeasurementNumbersController.dispose();
    _violationNotesController.dispose();
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

      // Navigate to Step 8
      StepNavigation.goToNextStep(
        context,
        currentStep: 7,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 7,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final sitePlans = SitePlansModel(
      generalNotes: _generalNotesController.textOrNull,
      approvedPlanComparison: _approvedPlanComparisonController.textOrNull,
      siteMeasurementNumbers: _siteMeasurementNumbersController.textOrNull,
      violationNotes: _violationNotesController.textOrNull,
    );
    ref.read(evaluationNotifierProvider.notifier).updateSitePlans(sitePlans);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 7,
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
      children: [
        _buildGeneralNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildApprovedPlanComparisonField(),
        AppSpacing.verticalSpaceMD,
        _buildSiteMeasurementNumbersField(),
        AppSpacing.verticalSpaceMD,
        _buildViolationNotesField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildGeneralNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildApprovedPlanComparisonField(),
        AppSpacing.verticalSpaceMD,
        _buildSiteMeasurementNumbersField(),
        AppSpacing.verticalSpaceMD,
        _buildViolationNotesField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildGeneralNotesField() {
    return CustomTextField(
      controller: _generalNotesController,
      label: 'ملاحظات عامة',
      hint: 'ملاحظات عامة...',
      maxLines: 5,
      showValidationDot: true,
    );
  }

  Widget _buildApprovedPlanComparisonField() {
    return CustomTextField(
      controller: _approvedPlanComparisonController,
      label: 'مقارنة المخطط المعتمد بالموقع',
      hint: 'مقارنة المخطط المعتمد بالموقع...',
      maxLines: 5,
    );
  }

  Widget _buildSiteMeasurementNumbersField() {
    return CustomTextField(
      controller: _siteMeasurementNumbersController,
      label: 'رقم المقاسات بالموقع',
      hint: 'رقم المقاسات بالموقع...',
      maxLines: 5,
    );
  }

  Widget _buildViolationNotesField() {
    return CustomTextField(
      controller: _violationNotesController,
      label: 'ملاحظات المخالفات',
      hint: 'ملاحظات المخالفات...',
      maxLines: 5,
    );
  }
}
