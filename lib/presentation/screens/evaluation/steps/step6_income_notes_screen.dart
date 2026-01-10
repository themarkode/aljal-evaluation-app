import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/data/models/pages_models/income_notes_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 6: Income Notes Screen
class Step6IncomeNotesScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step6IncomeNotesScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step6IncomeNotesScreen> createState() =>
      _Step6IncomeNotesScreenState();
}

class _Step6IncomeNotesScreenState extends ConsumerState<Step6IncomeNotesScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _tenantTypeController;
  late TextEditingController _incomeDetailsController;
  late TextEditingController _unitDescriptionController;
  late TextEditingController _unitTypeController;
  late TextEditingController _vacancyRateController;
  late TextEditingController _rentalValueVerificationController;

  // Number value
  int _unitCount = 0;

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Initialize controllers
    _tenantTypeController = TextEditingController();
    _incomeDetailsController = TextEditingController();
    _unitDescriptionController = TextEditingController();
    _unitTypeController = TextEditingController();
    _vacancyRateController = TextEditingController();
    _rentalValueVerificationController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final incomeNotes = evaluation.incomeNotes;

    if (incomeNotes != null) {
      _tenantTypeController.text = incomeNotes.tenantType ?? '';
      _incomeDetailsController.text = incomeNotes.incomeDetails ?? '';
      _unitDescriptionController.text = incomeNotes.unitDescription ?? '';
      _unitTypeController.text = incomeNotes.unitType ?? '';
      _vacancyRateController.text = incomeNotes.vacancyRate?.toString() ?? '';
      _rentalValueVerificationController.text =
          incomeNotes.rentalValueVerification ?? '';

      setState(() {
        _unitCount = incomeNotes.unitCount ?? 0;
      });
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    _tenantTypeController.dispose();
    _incomeDetailsController.dispose();
    _unitDescriptionController.dispose();
    _unitTypeController.dispose();
    _vacancyRateController.dispose();
    _rentalValueVerificationController.dispose();
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

  void _incrementUnitCount() {
    setState(() {
      _unitCount++;
    });
  }

  void _decrementUnitCount() {
    if (_unitCount > 0) {
      setState(() {
        _unitCount--;
      });
    }
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save to memory state only (no Firebase save)
      saveCurrentDataToState();

      // Navigate to Step 7
      StepNavigation.goToNextStep(
        context,
        currentStep: 6,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 6,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final incomeNotes = IncomeNotesModel(
      tenantType: _tenantTypeController.textOrNull,
      unitCount: _unitCount,
      incomeDetails: _incomeDetailsController.textOrNull,
      unitDescription: _unitDescriptionController.textOrNull,
      unitType: _unitTypeController.textOrNull,
      vacancyRate: _vacancyRateController.doubleOrNull,
      rentalValueVerification: _rentalValueVerificationController.textOrNull,
    );
    ref
        .read(evaluationNotifierProvider.notifier)
        .updateIncomeNotes(incomeNotes);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 6,
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
        _buildTenantTypeField(),
        AppSpacing.verticalSpaceMD,
        _buildIncomeDetailsField(),
        AppSpacing.verticalSpaceMD,
        _buildUnitCountField(),
        AppSpacing.verticalSpaceMD,
        _buildUnitTypeField(),
        AppSpacing.verticalSpaceMD,
        _buildUnitDescriptionField(),
        AppSpacing.verticalSpaceMD,
        _buildVacancyRateField(),
        AppSpacing.verticalSpaceMD,
        _buildRentalValueVerificationField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTenantTypeField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildIncomeDetailsField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildUnitCountField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildUnitTypeField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildUnitDescriptionField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildVacancyRateField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildRentalValueVerificationField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildTenantTypeField() {
    return CustomTextField(
      controller: _tenantTypeController,
      label: 'نوع المستأجرين',
      hint: 'نوع المستأجرين',
      showValidationDot: true,
    );
  }

  Widget _buildIncomeDetailsField() {
    return CustomTextField(
      controller: _incomeDetailsController,
      label: 'تفاصيل الدخل',
      hint: 'تفاصيل الدخل',
      maxLines: 2,
    );
  }

  Widget _buildUnitCountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عدد الوحدات',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceXS,
        Container(
          padding: AppSpacing.fieldPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _decrementUnitCount,
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_unitCount',
                style: AppTypography.inputText,
              ),
              IconButton(
                onPressed: _incrementUnitCount,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTypeField() {
    return CustomTextField(
      controller: _unitTypeController,
      label: 'نوع الوحدات',
      hint: 'نوع الوحدات',
    );
  }

  Widget _buildUnitDescriptionField() {
    return CustomTextField(
      controller: _unitDescriptionController,
      label: 'وصف الوحدات',
      hint: 'نوع الوحدات',
      maxLines: 2,
    );
  }

  Widget _buildVacancyRateField() {
    return CustomTextField(
      controller: _vacancyRateController,
      label: 'نسبة الشواغر',
      hint: 'نسبة الشواغر',
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildRentalValueVerificationField() {
    return CustomTextField(
      controller: _rentalValueVerificationController,
      label: 'التأكد من القيمة الإيجارية للوحدات',
      hint: 'التأكد من القيمة الإيجارية للوحدات',
      maxLines: 2,
    );
  }
}
