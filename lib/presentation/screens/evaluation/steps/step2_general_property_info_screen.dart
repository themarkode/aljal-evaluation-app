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
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_date_picker.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_property_info_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

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
    extends ConsumerState<Step2GeneralPropertyInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _areaController;
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
  String? _propertyType;

  // Date value
  DateTime? _documentDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _areaController = TextEditingController();
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
      _areaController.text = propertyInfo.area ?? '';
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
        _propertyType = propertyInfo.propertyType;
        _documentDate = propertyInfo.documentDate;
      });
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
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

  void _saveAndContinue() {
    // Validate form - show errors if validation fails
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Scroll to first error
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Create GeneralPropertyInfoModel
    final propertyInfo = GeneralPropertyInfoModel(
      governorate: _governorate,
      area: _areaController.text.trim().isEmpty
          ? null
          : _areaController.text.trim(),
      plotNumber: _plotNumberController.text.trim().isEmpty
          ? null
          : _plotNumberController.text.trim(),
      parcelNumber: _parcelNumberController.text.trim().isEmpty
          ? null
          : _parcelNumberController.text.trim(),
      planNumber: _planNumberController.text.trim().isEmpty
          ? null
          : _planNumberController.text.trim(),
      documentNumber: _documentNumberController.text.trim().isEmpty
          ? null
          : _documentNumberController.text.trim(),
      documentDate: _documentDate,
      areaSize: _areaSizeController.text.trim().isEmpty
          ? null
          : double.tryParse(_areaSizeController.text.trim()),
      propertyType: _propertyType,
      autoNumber: _autoNumberController.text.trim().isEmpty
          ? null
          : _autoNumberController.text.trim(),
      houseNumber: _houseNumberController.text.trim().isEmpty
          ? null
          : _houseNumberController.text.trim(),
      streetCount: _streetCountController.text.trim().isEmpty
          ? null
          : int.tryParse(_streetCountController.text.trim()),
      parkingCount: _parkingCountController.text.trim().isEmpty
          ? null
          : int.tryParse(_parkingCountController.text.trim()),
      landNotes: _landNotesController.text.trim().isEmpty
          ? null
          : _landNotesController.text.trim(),
      landFacing: _landFacingController.text.trim().isEmpty
          ? null
          : _landFacingController.text.trim(),
      landShape: _landShapeController.text.trim().isEmpty
          ? null
          : _landShapeController.text.trim(),
    );

    // Update state
    ref
        .read(evaluationNotifierProvider.notifier)
        .updateGeneralPropertyInfo(propertyInfo);

    // Navigate to Step 3 (which currently routes to Step 4)
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep3,
      arguments: FormStepArguments.forStep(
        step: 3,
        evaluationId: widget.evaluationId,
      ),
    );
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep1,
      arguments: FormStepArguments.forStep(
        step: 1,
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
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              Expanded(
                child: StepNavigationDropdown(
                  currentStep: 2,
                  evaluationId: widget.evaluationId,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.evaluationList,
                  (route) => false,
                ),
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
            ],
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingMobileInsets,
                    child: ResponsiveBuilder(
                      builder: (context, deviceType) {
                        switch (deviceType) {
                          case DeviceType.mobile:
                            return _buildMobileLayout();
                          case DeviceType.tablet:
                            return _buildTabletLayout();
                          case DeviceType.desktop:
                            return _buildDesktopLayout();
                        }
                      },
                    ),
                  ),
                ),
                // Navigation buttons
                FormNavigationButtons(
                  currentStep: 2,
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
      onChanged: (value) {
        setState(() {
          _governorate = value;
        });
      },
    );
  }

  Widget _buildAreaField() {
    return CustomTextField(
      controller: _areaController,
      label: 'اسم المنطقة',
      hint: 'اسم المنطقة',
    );
  }

  Widget _buildPlotNumberField() {
    return CustomTextField(
      controller: _plotNumberController,
      label: 'رقم القطعة',
      hint: 'رقم القطعة',
    );
  }

  Widget _buildParcelNumberField() {
    return CustomTextField(
      controller: _parcelNumberController,
      label: 'رقم القسيمة',
      hint: 'رقم القسيمة',
    );
  }

  Widget _buildPlanNumberField() {
    return CustomTextField(
      controller: _planNumberController,
      label: 'رقم المخطط',
      hint: 'رقم المخطط',
    );
  }

  Widget _buildDocumentNumberField() {
    return CustomTextField(
      controller: _documentNumberController,
      label: 'رقم الوثيقة',
      hint: 'رقم الوثيقة',
    );
  }

  Widget _buildDocumentDateField() {
    return CustomDatePicker(
      label: 'تاريخ الوثيقة',
      value: _documentDate,
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
    );
  }

  Widget _buildPropertyTypeField() {
    return CustomDropdown(
      label: 'نوع العقار',
      hint: 'نوع العقار',
      value: _propertyType,
      items: DropdownOptions.propertyTypes,
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
      hint: 'الرقم الآلي',
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
