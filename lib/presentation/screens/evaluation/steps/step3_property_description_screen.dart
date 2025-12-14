import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/core/constants/dropdown_options.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_dropdown.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/property_description_model.dart';

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
    extends ConsumerState<Step3PropertyDescriptionScreen> {
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

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create PropertyDescriptionModel
      final propertyDescription = PropertyDescriptionModel(
        propertyCondition: _propertyCondition,
        finishingType: _finishingType,
        propertyAge: _propertyAgeController.text.trim().isEmpty
            ? null
            : _propertyAgeController.text.trim(),
        airConditioningType: _airConditioningType,
        exteriorCladding: _exteriorCladdingController.text.trim().isEmpty
            ? null
            : _exteriorCladdingController.text.trim(),
        elevatorCount: _elevatorCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_elevatorCountController.text.trim()),
        escalatorCount: _escalatorCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_escalatorCountController.text.trim()),
        publicServices: _publicServicesController.text.trim().isEmpty
            ? null
            : _publicServicesController.text.trim(),
        neighboringPropertyTypes:
            _neighboringPropertyTypesController.text.trim().isEmpty
                ? null
                : _neighboringPropertyTypesController.text.trim(),
        buildingRatio: _buildingRatioController.text.trim().isEmpty
            ? null
            : double.tryParse(_buildingRatioController.text.trim()),
        exteriorFacades: _exteriorFacadesController.text.trim().isEmpty
            ? null
            : _exteriorFacadesController.text.trim(),
        maintenanceNotes: _maintenanceNotesController.text.trim().isEmpty
            ? null
            : _maintenanceNotesController.text.trim(),
      );

      // Update state
      ref
          .read(evaluationNotifierProvider.notifier)
          .updatePropertyDescription(propertyDescription);

      // Navigate to Step 4 (Floors)
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep4,
        arguments: FormStepArguments.forStep(
          step: 4,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep2,
      arguments: FormStepArguments.forStep(
        step: 2,
        evaluationId: widget.evaluationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leadingWidth: 70,
          leading: GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.evaluationList,
              (route) => false,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/images/Al_Jal_Logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business_rounded,
                    color: AppColors.primary,
                    size: 28,
                  );
                },
              ),
            ),
          ),
          title: StepNavigationDropdown(
            currentStep: 3,
            evaluationId: widget.evaluationId,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
              onPressed: _goBack,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingMobileInsets,
                    child: _buildFormFields(),
                  ),
                ),
                // Navigation buttons
                FormNavigationButtons(
                  currentStep: 3,
                  onNext: _saveAndContinue,
                  onPrevious: _goBack,
                ),
              ],
            ),
          ),
        ),
      ),
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
        ),
        AppSpacing.verticalSpaceMD,

        // Air Conditioning Type Dropdown
        CustomDropdown(
          label: 'نوع التكييف',
          hint: 'اختر نوع التكييف',
          value: _airConditioningType,
          items: DropdownOptions.airConditioningTypes,
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
        ),
        AppSpacing.verticalSpaceMD,

        // Row for Elevator and Escalator counts
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _elevatorCountController,
                label: 'عدد المصاعد',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: CustomTextField(
                controller: _escalatorCountController,
                label: 'عدد السلالم المتحركة',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,

        // Public Services
        CustomTextField(
          controller: _publicServicesController,
          label: 'الخدمات والمرافق العامة',
          hint: 'الخدمات والمرافق العامة',
          maxLines: 2,
        ),
        AppSpacing.verticalSpaceMD,

        // Neighboring Property Types
        CustomTextField(
          controller: _neighboringPropertyTypesController,
          label: 'أنواع العقارات المجاورة',
          hint: 'أنواع العقارات المجاورة',
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
