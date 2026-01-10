import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/core/constants/dropdown_options.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_dropdown.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/property_description_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 3: Property Description Screen (وصف العقار)
class Step3PropertyDescriptionScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step3PropertyDescriptionScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step3PropertyDescriptionScreen> createState() =>
      _Step3PropertyDescriptionScreenState();
}

class _Step3PropertyDescriptionScreenState
    extends ConsumerState<Step3PropertyDescriptionScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _propertyAgeController;
  late TextEditingController _exteriorCladdingController;
  late TextEditingController _elevatorCountController;
  late TextEditingController _escalatorCountController;
  late TextEditingController _publicServicesController;
  late TextEditingController _neighboringPropertyTypesController;
  late TextEditingController _buildingRatioController;
  late TextEditingController _exteriorFacadesController;
  late TextEditingController _maintenanceNotesController;

  // Dropdown values
  String? _propertyCondition;
  String? _finishingType;
  String? _airConditioningType;

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _propertyAgeController = TextEditingController();
    _exteriorCladdingController = TextEditingController();
    _elevatorCountController = TextEditingController();
    _escalatorCountController = TextEditingController();
    _publicServicesController = TextEditingController();
    _neighboringPropertyTypesController = TextEditingController();
    _buildingRatioController = TextEditingController();
    _exteriorFacadesController = TextEditingController();
    _maintenanceNotesController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final propertyDescription = evaluation.propertyDescription;

    if (propertyDescription != null) {
      _propertyAgeController.text = propertyDescription.propertyAge ?? '';
      _exteriorCladdingController.text =
          propertyDescription.exteriorCladding ?? '';
      _elevatorCountController.text =
          propertyDescription.elevatorCount?.toString() ?? '';
      _escalatorCountController.text =
          propertyDescription.escalatorCount?.toString() ?? '';
      _publicServicesController.text = propertyDescription.publicServices ?? '';
      _neighboringPropertyTypesController.text =
          propertyDescription.neighboringPropertyTypes ?? '';
      _buildingRatioController.text =
          propertyDescription.buildingRatio?.toString() ?? '';
      _exteriorFacadesController.text =
          propertyDescription.exteriorFacades ?? '';
      _maintenanceNotesController.text =
          propertyDescription.maintenanceNotes ?? '';

      setState(() {
        _propertyCondition = propertyDescription.propertyCondition;
        _finishingType = propertyDescription.finishingType;
        _airConditioningType = propertyDescription.airConditioningType;
      });
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    _propertyAgeController.dispose();
    _exteriorCladdingController.dispose();
    _elevatorCountController.dispose();
    _escalatorCountController.dispose();
    _publicServicesController.dispose();
    _neighboringPropertyTypesController.dispose();
    _buildingRatioController.dispose();
    _exteriorFacadesController.dispose();
    _maintenanceNotesController.dispose();
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

      // Navigate to Step 4
      StepNavigation.goToNextStep(
        context,
        currentStep: 3,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 3,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final propertyDescription = PropertyDescriptionModel(
      propertyCondition: _propertyCondition,
      finishingType: _finishingType,
      propertyAge: _propertyAgeController.textOrNull,
      airConditioningType: _airConditioningType,
      exteriorCladding: _exteriorCladdingController.textOrNull,
      elevatorCount: _elevatorCountController.intOrNull,
      escalatorCount: _escalatorCountController.intOrNull,
      publicServices: _publicServicesController.textOrNull,
      neighboringPropertyTypes: _neighboringPropertyTypesController.textOrNull,
      buildingRatio: _buildingRatioController.doubleOrNull,
      exteriorFacades: _exteriorFacadesController.textOrNull,
      maintenanceNotes: _maintenanceNotesController.textOrNull,
    );
    ref
        .read(evaluationNotifierProvider.notifier)
        .updatePropertyDescription(propertyDescription);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 3,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
      onNext: _saveAndContinue,
      onPrevious: _goBack,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      mobileContent: _buildFormFields(),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Property Condition Dropdown
        CustomDropdown(
          label: 'حالة العقار',
          hint: 'اختر حالة العقار',
          value: _propertyCondition,
          items: DropdownOptions.propertyConditions,
          showValidationDot: true,
          onChanged: (value) {
            setState(() {
              _propertyCondition = value;
            });
          },
        ),
        AppSpacing.verticalSpaceMD,

        // Finishing Type Dropdown
        CustomDropdown(
          label: 'نوع التشطيب',
          hint: 'اختر نوع التشطيب',
          value: _finishingType,
          items: DropdownOptions.finishingTypes,
          showValidationDot: true,
          onChanged: (value) {
            setState(() {
              _finishingType = value;
            });
          },
        ),
        AppSpacing.verticalSpaceMD,

        // Property Age
        CustomTextField(
          controller: _propertyAgeController,
          label: 'عمر العقار',
          hint: 'عمر العقار بالسنوات',
          showValidationDot: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Air Conditioning Type Dropdown
        CustomDropdown(
          label: 'نوع التكييف',
          hint: 'اختر نوع التكييف',
          value: _airConditioningType,
          items: DropdownOptions.airConditioningTypes,
          showValidationDot: true,
          onChanged: (value) {
            setState(() {
              _airConditioningType = value;
            });
          },
        ),
        AppSpacing.verticalSpaceMD,

        // Exterior Cladding
        CustomTextField(
          controller: _exteriorCladdingController,
          label: 'التكسية الخارجية',
          hint: 'التكسية الخارجية',
          showValidationDot: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Elevator Count
        CustomTextField(
          controller: _elevatorCountController,
          label: 'عدد المصاعد',
          hint: '0',
          keyboardType: TextInputType.number,
          showValidationDot: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Escalator Count
        CustomTextField(
          controller: _escalatorCountController,
          label: 'عدد السلالم المتحركة',
          hint: '0',
          keyboardType: TextInputType.number,
          showValidationDot: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Public Services
        CustomTextField(
          controller: _publicServicesController,
          label: 'الخدمات والمرافق العامة',
          hint: 'الخدمات والمرافق العامة',
          maxLines: 2,
          showValidationDot: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Neighboring Property Types
        CustomTextField(
          controller: _neighboringPropertyTypesController,
          label: 'أنواع العقارات المجاورة',
          hint: 'أنواع العقارات المجاورة',
          showValidationDot: true,
          maxLines: 2,
        ),
        AppSpacing.verticalSpaceMD,

        // Building Ratio
        CustomTextField(
          controller: _buildingRatioController,
          label: 'نسبة البناء %',
          hint: 'نسبة البناء',
          keyboardType: TextInputType.number,
        ),
        AppSpacing.verticalSpaceMD,

        // Exterior Facades
        CustomTextField(
          controller: _exteriorFacadesController,
          label: 'الواجهات الخارجية',
          hint: 'الواجهات الخارجية',
        ),
        AppSpacing.verticalSpaceMD,

        // Maintenance Notes
        CustomTextField(
          controller: _maintenanceNotesController,
          label: 'ملاحظات الصيانة',
          hint: 'ملاحظات الصيانة',
          maxLines: 3,
        ),
      ],
    );
  }
}
