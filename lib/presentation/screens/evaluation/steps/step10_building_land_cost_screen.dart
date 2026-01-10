import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/building_land_cost_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';
import 'package:intl/intl.dart';

/// Step 10: Building and Land Cost Screen - تكلفة المباني والارض
class Step10BuildingLandCostScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step10BuildingLandCostScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step10BuildingLandCostScreen> createState() =>
      _Step10BuildingLandCostScreenState();
}

class _Step10BuildingLandCostScreenState
    extends ConsumerState<Step10BuildingLandCostScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'en_US');

  // Fixed Building Area Controllers (always shown)
  late TextEditingController _buildingAreaController;
  late TextEditingController _buildingAreaPM2Controller;

  // Additional Area Costs (dynamic table)
  List<_AreaCostEntry> _additionalAreaCosts = [];

  // Indirect Cost
  late TextEditingController _indirectCostPercentageController;

  // Depreciation
  late TextEditingController _depreciationPercentageController;

  // Land Area
  late TextEditingController _landAreaController;
  late TextEditingController _landAreaPM2Controller;

  @override
  void initState() {
    super.initState();
    initStepScreen();

    // Initialize controllers
    _buildingAreaController = TextEditingController();
    _buildingAreaPM2Controller = TextEditingController();
    _indirectCostPercentageController = TextEditingController();
    _depreciationPercentageController = TextEditingController();
    _landAreaController = TextEditingController();
    _landAreaPM2Controller = TextEditingController();

    // Add listeners for live calculations
    _buildingAreaController.addListener(_onFieldChanged);
    _buildingAreaPM2Controller.addListener(_onFieldChanged);
    _indirectCostPercentageController.addListener(_onFieldChanged);
    _depreciationPercentageController.addListener(_onFieldChanged);
    _landAreaController.addListener(_onFieldChanged);
    _landAreaPM2Controller.addListener(_onFieldChanged);

    // Load existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final buildingLandCost = evaluation.buildingLandCost;

    // Auto-fill land area from Step 2 (generalPropertyInfo.areaSize)
    final landAreaFromStep2 = evaluation.generalPropertyInfo?.areaSize;
    if (landAreaFromStep2 != null) {
      _landAreaController.text = landAreaFromStep2.toString();
    }

    if (buildingLandCost != null) {
      _buildingAreaController.text =
          buildingLandCost.buildingArea?.toString() ?? '';
      _buildingAreaPM2Controller.text =
          buildingLandCost.buildingAreaPM2?.toString() ?? '';
      _indirectCostPercentageController.text =
          buildingLandCost.indirectCostPercentage?.toString() ?? '';
      _depreciationPercentageController.text =
          buildingLandCost.depreciationPercentage?.toString() ?? '';
      _landAreaPM2Controller.text =
          buildingLandCost.landAreaPM2?.toString() ?? '';

      // Load additional area costs
      if (buildingLandCost.additionalAreaCosts != null &&
          buildingLandCost.additionalAreaCosts!.isNotEmpty) {
        setState(() {
          _additionalAreaCosts =
              buildingLandCost.additionalAreaCosts!.map((entry) {
            return _AreaCostEntry(
              nameController: TextEditingController(text: entry.areaName ?? ''),
              areaController:
                  TextEditingController(text: entry.area?.toString() ?? ''),
              pm2Controller:
                  TextEditingController(text: entry.pricePerM2?.toString() ?? ''),
              onChanged: _onFieldChanged,
            );
          }).toList();
        });
      }
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    disposeStepScreen();
    _buildingAreaController.dispose();
    _buildingAreaPM2Controller.dispose();
    _indirectCostPercentageController.dispose();
    _depreciationPercentageController.dispose();
    _landAreaController.dispose();
    _landAreaPM2Controller.dispose();
    for (var entry in _additionalAreaCosts) {
      entry.dispose();
    }
    super.dispose();
  }

  // ========================================
  // CALCULATION HELPERS
  // ========================================

  double get _buildingAreaTotalCost {
    final area = _buildingAreaController.doubleOrNull ?? 0;
    final pm2 = _buildingAreaPM2Controller.doubleOrNull ?? 0;
    return area * pm2;
  }

  double get _directTotalCost {
    double total = _buildingAreaTotalCost;
    for (var entry in _additionalAreaCosts) {
      total += entry.totalCost;
    }
    return total;
  }

  double get _indirectCostValue {
    final percentage = _indirectCostPercentageController.doubleOrNull ?? 0;
    return (percentage / 100) * _directTotalCost;
  }

  double get _totalBuildingCost => _directTotalCost + _indirectCostValue;

  double get _depreciationValue {
    final percentage = _depreciationPercentageController.doubleOrNull ?? 0;
    return (percentage / 100) * _totalBuildingCost;
  }

  double get _buildingValueAfterDepreciation =>
      _totalBuildingCost - _depreciationValue;

  double get _totalCostOfLandArea {
    final area = _landAreaController.doubleOrNull ?? 0;
    final pm2 = _landAreaPM2Controller.doubleOrNull ?? 0;
    return area * pm2;
  }

  double get _valueByCostMethod =>
      _buildingValueAfterDepreciation + _totalCostOfLandArea;

  // ========================================
  // DYNAMIC TABLE METHODS
  // ========================================

  void _addAreaCost() {
    setState(() {
      _additionalAreaCosts.add(_AreaCostEntry(
        nameController: TextEditingController(),
        areaController: TextEditingController(),
        pm2Controller: TextEditingController(),
        onChanged: _onFieldChanged,
      ));
    });
  }

  void _removeAreaCost(int index) {
    setState(() {
      _additionalAreaCosts[index].dispose();
      _additionalAreaCosts.removeAt(index);
    });
  }

  // ========================================
  // NAVIGATION
  // ========================================

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _onValidationFailed() {
    _formKey.currentState?.validate();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      saveCurrentDataToState();
      StepNavigation.goToNextStep(
        context,
        currentStep: 10,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    saveCurrentDataToState();
    StepNavigation.goToPreviousStep(
      context,
      currentStep: 10,
      evaluationId: widget.evaluationId,
    );
  }

  @override
  void saveCurrentDataToState() {
    final additionalCosts = _additionalAreaCosts.map((entry) {
      return AreaCostEntry(
        areaName: entry.nameController.textOrNull,
        area: entry.areaController.doubleOrNull,
        pricePerM2: entry.pm2Controller.doubleOrNull,
      );
    }).toList();

    final buildingLandCost = BuildingLandCostModel(
      buildingArea: _buildingAreaController.doubleOrNull,
      buildingAreaPM2: _buildingAreaPM2Controller.doubleOrNull,
      additionalAreaCosts: additionalCosts.isNotEmpty ? additionalCosts : null,
      indirectCostPercentage: _indirectCostPercentageController.doubleOrNull,
      depreciationPercentage: _depreciationPercentageController.doubleOrNull,
      landArea: _landAreaController.doubleOrNull,
      landAreaPM2: _landAreaPM2Controller.doubleOrNull,
    );

    ref
        .read(evaluationNotifierProvider.notifier)
        .updateBuildingLandCost(buildingLandCost);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 10,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
      onNext: _saveAndContinue,
      onPrevious: _goBack,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      mobileContent: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title
        _buildSectionTitle('تكلفة المباني والارض'),
        AppSpacing.verticalSpaceMD,

        // Fixed Building Area Fields (always shown)
        _buildBuildingAreaSection(),
        AppSpacing.verticalSpaceMD,

        // Additional Area Costs (dynamic table)
        _buildAdditionalAreaCostsSection(),
        AppSpacing.verticalSpaceMD,

        // Direct Total Cost (calculated)
        _buildCalculatedField('التكلفة الاجمالية المباشرة', _directTotalCost),
        AppSpacing.verticalSpaceMD,

        // Indirect Cost Section
        _buildIndirectCostSection(),
        AppSpacing.verticalSpaceMD,

        // Total Building Cost (calculated)
        _buildCalculatedField('تكلفة البناء الاجمالية', _totalBuildingCost),
        AppSpacing.verticalSpaceMD,

        // Depreciation Section
        _buildDepreciationSection(),
        AppSpacing.verticalSpaceMD,

        // Building Value After Depreciation (calculated)
        _buildCalculatedField(
            'قيمة المباني بعد خصم الاستهلاك', _buildingValueAfterDepreciation),
        AppSpacing.verticalSpaceMD,

        // Land Area Section
        _buildLandAreaSection(),
        AppSpacing.verticalSpaceMD,

        // Value by Cost Method (Final calculated value)
        _buildFinalValueField('القيمة بطريقة التكلفة', _valueByCostMethod),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.radiusMD,
      ),
      child: Text(
        title,
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBuildingAreaSection() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مساحة البناء',
            style: AppTypography.fieldTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _buildingAreaController,
                  label: 'المساحة',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: CustomTextField(
                  controller: _buildingAreaPM2Controller,
                  label: 'د/م٢',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: _buildReadOnlyField(
                  'اجمالي التكلفة',
                  _buildingAreaTotalCost,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalAreaCostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Additional area cost entries
        ..._additionalAreaCosts.asMap().entries.map((entry) {
          final index = entry.key;
          final areaCost = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildAreaCostItem(index, areaCost),
          );
        }),

        // Add button
        CustomButton.secondary(
          text: 'أضف مساحة',
          onPressed: _addAreaCost,
          icon: const Icon(Icons.add, color: AppColors.white),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildAreaCostItem(int index, _AreaCostEntry entry) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with delete button
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: entry.nameController,
                  label: 'اسم المساحة',
                  hint: 'مثال: السرداب، الخدمات، الارضي',
                  showValidationDot: false,
                ),
              ),
              IconButton(
                onPressed: () => _removeAreaCost(index),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: entry.areaController,
                  label: 'المساحة',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: CustomTextField(
                  controller: entry.pm2Controller,
                  label: 'د/م٢',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: _buildReadOnlyField(
                  'اجمالي التكلفة',
                  entry.totalCost,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndirectCostSection() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التكلفة الغير مباشرة',
            style: AppTypography.fieldTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _indirectCostPercentageController,
                  label: 'النسبة %',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('%'),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: _buildReadOnlyField(
                  'القيمة',
                  _indirectCostValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepreciationSection() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الاستهلاك',
            style: AppTypography.fieldTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _depreciationPercentageController,
                  label: 'النسبة %',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('%'),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: _buildReadOnlyField(
                  'القيمة',
                  _depreciationValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLandAreaSection() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مساحة الأرض',
            style: AppTypography.fieldTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _landAreaController,
                  label: 'مساحة الارض م٢',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                  enabled: false, // Auto-filled from Step 2
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: CustomTextField(
                  controller: _landAreaPM2Controller,
                  label: 'سعر المتر د.ك',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  showValidationDot: false,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: _buildReadOnlyField(
                  'اجمالي تكلفة الأرض',
                  _totalCostOfLandArea,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldTitle),
        AppSpacing.verticalSpaceXS,
        Container(
          width: double.infinity,
          padding: AppSpacing.fieldPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _numberFormat.format(value),
            style: AppTypography.inputText.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatedField(String label, double value) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.fieldTitle),
          Text(
            '${_numberFormat.format(value)} د.ك',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalValueField(String label, double value) {
    return Container(
      padding: AppSpacing.allLG,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            '${_numberFormat.format(value)} د.ك',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for dynamic area cost entries
class _AreaCostEntry {
  final TextEditingController nameController;
  final TextEditingController areaController;
  final TextEditingController pm2Controller;

  _AreaCostEntry({
    required this.nameController,
    required this.areaController,
    required this.pm2Controller,
    required VoidCallback onChanged,
  }) {
    areaController.addListener(onChanged);
    pm2Controller.addListener(onChanged);
  }

  double get totalCost {
    final area = double.tryParse(areaController.text) ?? 0;
    final pm2 = double.tryParse(pm2Controller.text) ?? 0;
    return area * pm2;
  }

  void dispose() {
    nameController.dispose();
    areaController.dispose();
    pm2Controller.dispose();
  }
}
