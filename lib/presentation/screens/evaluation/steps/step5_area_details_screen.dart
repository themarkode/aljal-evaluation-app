import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/area_details_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 5: Area Details Screen
class Step5AreaDetailsScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step5AreaDetailsScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step5AreaDetailsScreen> createState() =>
      _Step5AreaDetailsScreenState();
}

class _Step5AreaDetailsScreenState extends ConsumerState<Step5AreaDetailsScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _streetsAndInfrastructureController;
  late TextEditingController _areaPropertyTypesController;
  late TextEditingController _areaEntrancesExitsController;
  late TextEditingController _generalAreaDirectionController;
  late TextEditingController _areaRentalRatesController;
  late TextEditingController _neighboringTenantTypesController;
  late TextEditingController _areaVacancyRatesController;

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _streetsAndInfrastructureController = TextEditingController();
    _areaPropertyTypesController = TextEditingController();
    _areaEntrancesExitsController = TextEditingController();
    _generalAreaDirectionController = TextEditingController();
    _areaRentalRatesController = TextEditingController();
    _neighboringTenantTypesController = TextEditingController();
    _areaVacancyRatesController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final areaDetails = evaluation.areaDetails;

    if (areaDetails != null) {
      _streetsAndInfrastructureController.text =
          areaDetails.streetsAndInfrastructure ?? '';
      _areaPropertyTypesController.text = areaDetails.areaPropertyTypes ?? '';
      _areaEntrancesExitsController.text = areaDetails.areaEntrancesExits ?? '';
      _generalAreaDirectionController.text =
          areaDetails.generalAreaDirection ?? '';
      _areaRentalRatesController.text = areaDetails.areaRentalRates ?? '';
      _neighboringTenantTypesController.text =
          areaDetails.neighboringTenantTypes ?? '';
      _areaVacancyRatesController.text = areaDetails.areaVacancyRates ?? '';
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    _streetsAndInfrastructureController.dispose();
    _areaPropertyTypesController.dispose();
    _areaEntrancesExitsController.dispose();
    _generalAreaDirectionController.dispose();
    _areaRentalRatesController.dispose();
    _neighboringTenantTypesController.dispose();
    _areaVacancyRatesController.dispose();
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

      // Navigate to Step 6
      StepNavigation.goToNextStep(
        context,
        currentStep: 5,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 5,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final areaDetails = AreaDetailsModel(
      streetsAndInfrastructure: _streetsAndInfrastructureController.textOrNull,
      areaPropertyTypes: _areaPropertyTypesController.textOrNull,
      areaEntrancesExits: _areaEntrancesExitsController.textOrNull,
      generalAreaDirection: _generalAreaDirectionController.textOrNull,
      areaRentalRates: _areaRentalRatesController.textOrNull,
      neighboringTenantTypes: _neighboringTenantTypesController.textOrNull,
      areaVacancyRates: _areaVacancyRatesController.textOrNull,
    );
    ref
        .read(evaluationNotifierProvider.notifier)
        .updateAreaDetails(areaDetails);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 5,
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
        _buildStreetsAndInfrastructureField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaEntrancesExitsField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaPropertyTypesField(),
        AppSpacing.verticalSpaceMD,
        _buildGeneralAreaDirectionField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaRentalRatesField(),
        AppSpacing.verticalSpaceMD,
        _buildNeighboringTenantTypesField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaVacancyRatesField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStreetsAndInfrastructureField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildAreaEntrancesExitsField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildAreaPropertyTypesField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildGeneralAreaDirectionField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildAreaRentalRatesField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildNeighboringTenantTypesField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildAreaVacancyRatesField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildStreetsAndInfrastructureField() {
    return CustomTextField(
      controller: _streetsAndInfrastructureController,
      label: 'الشوارع والبنية التحتية',
      hint: 'الشوارع والبنية التحتية',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildAreaEntrancesExitsField() {
    return CustomTextField(
      controller: _areaEntrancesExitsController,
      label: 'مداخل ومخارج المنطقة',
      hint: 'مداخل ومخارج المنطقة',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildAreaPropertyTypesField() {
    return CustomTextField(
      controller: _areaPropertyTypesController,
      label: 'أنواع العقارات بالمنطقة',
      hint: 'أنواع العقارات بالمنطقة',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildGeneralAreaDirectionField() {
    return CustomTextField(
      controller: _generalAreaDirectionController,
      label: 'التوجه العام بالمنطقة',
      hint: 'التوجه العام بالمنطقة',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildAreaRentalRatesField() {
    return CustomTextField(
      controller: _areaRentalRatesController,
      label: 'معدل الإيجارات بالمنطقة',
      hint: 'معدل الإيجارات بالمنطقة',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildNeighboringTenantTypesField() {
    return CustomTextField(
      controller: _neighboringTenantTypesController,
      label: 'نوع المستأجرين بالعقارات المجاورة',
      hint: 'نوع المستأجرين بالعقارات المجاورة',
      maxLines: 2,
      showValidationDot: true,
    );
  }

  Widget _buildAreaVacancyRatesField() {
    return CustomTextField(
      controller: _areaVacancyRatesController,
      label: 'معدلات الشواغر بالمنطقة',
      hint: 'معدلات الشواغر بالمنطقة',
      maxLines: 2,
    );
  }
}
