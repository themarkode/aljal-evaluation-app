import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/utils/validators/auto_number_validator.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/core/constants/dropdown_options.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_dropdown.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_searchable_dropdown.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_date_picker.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_property_info_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 2: General Property Information Screen
class Step2GeneralPropertyInfoScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step2GeneralPropertyInfoScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step2GeneralPropertyInfoScreen> createState() =>
      _Step2GeneralPropertyInfoScreenState();
}

class _Step2GeneralPropertyInfoScreenState
    extends ConsumerState<Step2GeneralPropertyInfoScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _plotNumberController;
  late TextEditingController _parcelNumberController;
  late TextEditingController _planNumberController;
  late TextEditingController _documentNumberController;
  late TextEditingController _areaSizeController;
  late TextEditingController _autoNumberController;
  late TextEditingController _houseNumberController;
  late TextEditingController _streetCountController;
  late TextEditingController _parkingCountController;
  late TextEditingController _landNotesController;
  late TextEditingController _landFacingController;
  late TextEditingController _landShapeController;

  // Dropdown values
  String? _governorate;
  String? _area;
  String? _propertyType;

  // Date value
  DateTime? _documentDate;

  // Note: errorBlinkTrigger is now provided by StepScreenMixin (centralized)

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _plotNumberController = TextEditingController();
    _parcelNumberController = TextEditingController();
    _planNumberController = TextEditingController();
    _documentNumberController = TextEditingController();
    _areaSizeController = TextEditingController();
    _autoNumberController = TextEditingController();
    _houseNumberController = TextEditingController();
    _streetCountController = TextEditingController();
    _parkingCountController = TextEditingController();
    _landNotesController = TextEditingController();
    _landFacingController = TextEditingController();
    _landShapeController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final propertyInfo = evaluation.generalPropertyInfo;

    if (propertyInfo != null) {
      _plotNumberController.text = propertyInfo.plotNumber ?? '';
      _parcelNumberController.text = propertyInfo.parcelNumber ?? '';
      _planNumberController.text = propertyInfo.planNumber ?? '';
      _documentNumberController.text = propertyInfo.documentNumber ?? '';
      _areaSizeController.text = propertyInfo.areaSize?.toString() ?? '';
      _autoNumberController.text = propertyInfo.autoNumber ?? '';
      _houseNumberController.text = propertyInfo.houseNumber ?? '';
      _streetCountController.text = propertyInfo.streetCount?.toString() ?? '';
      _parkingCountController.text =
          propertyInfo.parkingCount?.toString() ?? '';
      _landNotesController.text = propertyInfo.landNotes ?? '';
      _landFacingController.text = propertyInfo.landFacing ?? '';
      _landShapeController.text = propertyInfo.landShape ?? '';

      setState(() {
        _governorate = propertyInfo.governorate;
        _area = propertyInfo.area;
        _propertyType = propertyInfo.propertyType;
        _documentDate = propertyInfo.documentDate;
      });
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin (removes lifecycle observer + errorBlinkTrigger)
    _plotNumberController.dispose();
    _parcelNumberController.dispose();
    _planNumberController.dispose();
    _documentNumberController.dispose();
    _areaSizeController.dispose();
    _autoNumberController.dispose();
    _houseNumberController.dispose();
    _streetCountController.dispose();
    _parkingCountController.dispose();
    _landNotesController.dispose();
    _landFacingController.dispose();
    _landShapeController.dispose();
    super.dispose();
  }

  /// Validate the form - returns true if valid
  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// Trigger blink animation on error text fields
  void _onValidationFailed() {
    // Validate to show error messages
    _formKey.currentState?.validate();

    // Trigger blink on error fields using centralized mixin method
    triggerErrorBlink();
  }

  void _saveAndContinue() {
    // Validate form - show errors if validation fails
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Trigger blink on error fields
      _onValidationFailed();
      return;
    }

    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    // Navigate to Step 3
    StepNavigation.goToNextStep(
      context,
      currentStep: 2,
      evaluationId: widget.evaluationId,
    );
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 2,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final propertyInfo = GeneralPropertyInfoModel(
      governorate: _governorate,
      area: _area,
      plotNumber: _plotNumberController.textOrNull,
      parcelNumber: _parcelNumberController.textOrNull,
      planNumber: _planNumberController.textOrNull,
      documentNumber: _documentNumberController.textOrNull,
      documentDate: _documentDate,
      areaSize: _areaSizeController.doubleOrNull,
      propertyType: _propertyType,
      autoNumber: _autoNumberController.textOrNull,
      houseNumber: _houseNumberController.textOrNull,
      streetCount: _streetCountController.intOrNull,
      parkingCount: _parkingCountController.intOrNull,
      landNotes: _landNotesController.textOrNull,
      landFacing: _landFacingController.textOrNull,
      landShape: _landShapeController.textOrNull,
    );
    ref
        .read(evaluationNotifierProvider.notifier)
        .updateGeneralPropertyInfo(propertyInfo);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 2,
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
        _buildGovernorateField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaField(),
        AppSpacing.verticalSpaceMD,
        _buildPlotNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildParcelNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildPlanNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildDocumentNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildDocumentDateField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaSizeField(),
        AppSpacing.verticalSpaceMD,
        _buildPropertyTypeField(),
        AppSpacing.verticalSpaceMD,
        _buildAutoNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildHouseNumberField(),
        AppSpacing.verticalSpaceMD,
        _buildStreetCountField(),
        AppSpacing.verticalSpaceMD,
        _buildParkingCountField(),
        AppSpacing.verticalSpaceMD,
        _buildLandNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildLandFacingField(),
        AppSpacing.verticalSpaceMD,
        _buildLandShapeField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildGovernorateField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildAreaField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildPlotNumberField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildParcelNumberField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildPlanNumberField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildDocumentNumberField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildDocumentDateField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildAreaSizeField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildPropertyTypeField(),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildAutoNumberField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildHouseNumberField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildStreetCountField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildParkingCountField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildLandNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildLandFacingField(),
        AppSpacing.verticalSpaceMD,
        _buildLandShapeField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildGovernorateField() {
    return CustomDropdown(
      label: 'اسم المحافظة',
      hint: 'اسم المحافظة',
      value: _governorate,
      items: DropdownOptions.governorates,
      showValidationDot: true,
      onChanged: (value) {
        setState(() {
          _governorate = value;
          // Reset area when governorate changes
          _area = null;
        });
      },
    );
  }

  Widget _buildAreaField() {
    final areas = DropdownOptions.getAreasForGovernorate(_governorate);
    return CustomSearchableDropdown(
      label: 'اسم المنطقة',
      hint: 'ابحث عن المنطقة...',
      value: _area,
      items: areas,
      showValidationDot: true,
      enabled: _governorate != null,
      allowCustomValue: true, // Allow user to type custom area if not in list
      onChanged: (value) {
        setState(() {
          _area = value;
        });
      },
    );
  }

  Widget _buildPlotNumberField() {
    return CustomTextField(
      controller: _plotNumberController,
      label: 'رقم القطعة',
      hint: 'رقم القطعة',
      showValidationDot: true,
    );
  }

  Widget _buildParcelNumberField() {
    return CustomTextField(
      controller: _parcelNumberController,
      label: 'رقم القسيمة',
      hint: 'رقم القسيمة',
      showValidationDot: true,
    );
  }

  Widget _buildPlanNumberField() {
    return CustomTextField(
      controller: _planNumberController,
      label: 'رقم المخطط',
      hint: 'رقم المخطط',
      showValidationDot: true,
    );
  }

  Widget _buildDocumentNumberField() {
    return CustomTextField(
      controller: _documentNumberController,
      label: 'رقم الوثيقة',
      hint: 'رقم الوثيقة',
      showValidationDot: true,
    );
  }

  Widget _buildDocumentDateField() {
    return CustomDatePicker(
      label: 'تاريخ الوثيقة',
      value: _documentDate,
      showValidationDot: true,
      onChanged: (date) {
        setState(() {
          _documentDate = date;
        });
      },
    );
  }

  Widget _buildAreaSizeField() {
    return CustomTextField(
      controller: _areaSizeController,
      label: 'المساحة م²',
      hint: 'المساحة م²',
      keyboardType: TextInputType.number,
      showValidationDot: true,
    );
  }

  Widget _buildPropertyTypeField() {
    return CustomDropdown(
      label: 'نوع العقار',
      hint: 'نوع العقار',
      value: _propertyType,
      items: DropdownOptions.propertyTypes,
      showValidationDot: true,
      onChanged: (value) {
        setState(() {
          _propertyType = value;
        });
      },
    );
  }

  Widget _buildAutoNumberField() {
    return CustomTextField(
      controller: _autoNumberController,
      label: 'الرقم الآلي',
      hint: 'أدخل 8 أرقام',
      showValidationDot: true,
      keyboardType: TextInputType.number,
      inputFormatters: AutoNumberValidator.formatters(),
      validator: AutoNumberValidator.validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      errorBlinkTrigger: errorBlinkTrigger, // From StepScreenMixin
    );
  }

  Widget _buildHouseNumberField() {
    return CustomTextField(
      controller: _houseNumberController,
      label: 'رقم المنزل',
      hint: 'رقم المنزل',
    );
  }

  Widget _buildStreetCountField() {
    return CustomTextField(
      controller: _streetCountController,
      label: 'عدد الشوارع',
      hint: 'عدد الشوارع',
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildParkingCountField() {
    return CustomTextField(
      controller: _parkingCountController,
      label: 'مواقف السيارات',
      hint: 'مواقف السيارات',
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildLandNotesField() {
    return CustomTextField(
      controller: _landNotesController,
      label: 'ملاحظات أرض العقار',
      hint: 'ملاحظات أرض العقار',
      maxLines: 3,
    );
  }

  Widget _buildLandFacingField() {
    return CustomTextField(
      controller: _landFacingController,
      label: 'اتجاه واجهة القسيمة',
      hint: 'اتجاه واجهة القسيمة',
    );
  }

  Widget _buildLandShapeField() {
    return CustomTextField(
      controller: _landShapeController,
      label: 'شكل وتضاريس الأرض',
      hint: 'شكل وتضاريس الأرض',
    );
  }
}
