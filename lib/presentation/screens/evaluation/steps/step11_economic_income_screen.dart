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
import 'package:aljal_evaluation/data/models/pages_models/economic_income_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Step 11: Economic Income Screen - الدخل الاقتصادي (FINAL STEP)
class Step11EconomicIncomeScreen extends ConsumerStatefulWidget {
  final String? evaluationId;
  final bool isViewOnly;

  const Step11EconomicIncomeScreen({
    super.key,
    this.evaluationId,
    this.isViewOnly = false,
  });

  @override
  ConsumerState<Step11EconomicIncomeScreen> createState() =>
      _Step11EconomicIncomeScreenState();
}

class _Step11EconomicIncomeScreenState
    extends ConsumerState<Step11EconomicIncomeScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'en_US');

  // Income Units (dynamic table)
  List<_IncomeUnitEntry> _incomeUnits = [];

  // Capitalization Rate
  late TextEditingController _capitalizationRateController;

  // Monthly Property Rent
  late TextEditingController _monthlyPropertyRentController;

  @override
  void initState() {
    super.initState();
    initStepScreen();

    // Initialize controllers
    _capitalizationRateController = TextEditingController();
    _monthlyPropertyRentController = TextEditingController();

    // Add listeners for live calculations
    _capitalizationRateController.addListener(_onFieldChanged);
    _monthlyPropertyRentController.addListener(_onFieldChanged);

    // Load existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final economicIncome = evaluation.economicIncome;

    if (economicIncome != null) {
      _capitalizationRateController.text =
          economicIncome.capitalizationRate?.toString() ?? '';
      _monthlyPropertyRentController.text =
          economicIncome.monthlyPropertyRent?.toString() ?? '';

      // Load income units
      if (economicIncome.incomeUnits != null &&
          economicIncome.incomeUnits!.isNotEmpty) {
        setState(() {
          _incomeUnits = economicIncome.incomeUnits!.map((unit) {
            return _IncomeUnitEntry(
              countController:
                  TextEditingController(text: unit.unitCount?.toString() ?? ''),
              typeController: TextEditingController(text: unit.unitType ?? ''),
              areaController:
                  TextEditingController(text: unit.unitArea?.toString() ?? ''),
              rentController:
                  TextEditingController(text: unit.economicRent?.toString() ?? ''),
              onChanged: _onFieldChanged,
            );
          }).toList();
        });
      } else {
        // Start with at least one unit
        _addIncomeUnit();
      }
    } else {
      // Start with at least one unit
      _addIncomeUnit();
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    disposeStepScreen();
    _capitalizationRateController.dispose();
    _monthlyPropertyRentController.dispose();
    for (var entry in _incomeUnits) {
      entry.dispose();
    }
    super.dispose();
  }

  // ========================================
  // CALCULATION HELPERS
  // ========================================

  double get _monthlyTotalIncome {
    double total = 0;
    for (var unit in _incomeUnits) {
      total += unit.monthlyIncome;
    }
    return total;
  }

  int get _totalUnitCount {
    int total = 0;
    for (var unit in _incomeUnits) {
      total += unit.unitCount;
    }
    return total;
  }

  double get _annualTotalIncome => _monthlyTotalIncome * 12;

  double get _finalTotalValue {
    final rate = _capitalizationRateController.doubleOrNull ?? 0;
    if (rate == 0) return 0;
    return _annualTotalIncome / (rate / 100);
  }

  // ========================================
  // DYNAMIC TABLE METHODS
  // ========================================

  void _addIncomeUnit() {
    setState(() {
      _incomeUnits.add(_IncomeUnitEntry(
        countController: TextEditingController(),
        typeController: TextEditingController(),
        areaController: TextEditingController(),
        rentController: TextEditingController(),
        onChanged: _onFieldChanged,
      ));
    });
  }

  void _removeIncomeUnit(int index) {
    if (_incomeUnits.length > 1) {
      setState(() {
        _incomeUnits[index].dispose();
        _incomeUnits.removeAt(index);
      });
    }
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

  Future<void> _saveAndComplete() async {
    // In view-only mode, just go back to list
    if (widget.isViewOnly) {
      StepNavigation.goToEvaluationList(context);
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Save current form data to state
        saveCurrentDataToState();

        // Update status to completed
        ref.read(evaluationNotifierProvider.notifier).updateStatus('completed');

        // Save evaluation to Firebase
        await ref.read(evaluationNotifierProvider.notifier).saveEvaluation();

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ النموذج بنجاح'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate back to evaluation list and clear form state
        if (mounted) {
          ref.read(evaluationNotifierProvider.notifier).resetEvaluation();
          StepNavigation.goToEvaluationList(context);
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حفظ النموذج: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _goBack() {
    // In view-only mode, just navigate
    if (widget.isViewOnly) {
      StepNavigation.goToPreviousStep(
        context,
        currentStep: 11,
        evaluationId: widget.evaluationId,
        isViewOnly: true,
      );
      return;
    }

    saveCurrentDataToState();
    StepNavigation.goToPreviousStep(
      context,
      currentStep: 11,
      evaluationId: widget.evaluationId,
    );
  }

  @override
  void saveCurrentDataToState() {
    final incomeUnits = _incomeUnits.map((entry) {
      return EconomicIncomeUnit(
        unitCount: entry.countController.intOrNull,
        unitType: entry.typeController.textOrNull,
        unitArea: entry.areaController.doubleOrNull,
        economicRent: entry.rentController.doubleOrNull,
      );
    }).toList();

    final economicIncome = EconomicIncomeModel(
      incomeUnits: incomeUnits.isNotEmpty ? incomeUnits : null,
      capitalizationRate: _capitalizationRateController.doubleOrNull,
      monthlyPropertyRent: _monthlyPropertyRentController.doubleOrNull,
    );

    ref
        .read(evaluationNotifierProvider.notifier)
        .updateEconomicIncome(economicIncome);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 11,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
      onNext: _saveAndComplete,
      onPrevious: _goBack,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      isViewOnly: widget.isViewOnly,
      mobileContent: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title
        _buildSectionTitle('الدخل الاقتصادي'),
        AppSpacing.verticalSpaceMD,

        // Income Units Table Header
        _buildTableHeader(),
        AppSpacing.verticalSpaceSM,

        // Income Units (dynamic table)
        ..._incomeUnits.asMap().entries.map((entry) {
          final index = entry.key;
          final unit = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildIncomeUnitItem(index, unit),
          );
        }),

        // Add button
        CustomButton.secondary(
          text: 'أضف وحدة',
          onPressed: _addIncomeUnit,
          icon: const Icon(Icons.add, color: AppColors.white),
          isExpanded: true,
        ),
        AppSpacing.verticalSpaceMD,

        // Totals Row
        _buildTotalsRow(),
        AppSpacing.verticalSpaceMD,

        // Annual Income and Capitalization Rate
        _buildAnnualIncomeSection(),
        AppSpacing.verticalSpaceMD,

        // Monthly Property Rent
        _buildMonthlyPropertyRentSection(),
        AppSpacing.verticalSpaceLG,

        // Evaluation Issue Date
        _buildEvaluationIssueDateSection(),
        AppSpacing.verticalSpaceMD,

        // Final Total Value (تقدير العقار)
        _buildPropertyEvaluationSection(),
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

  Widget _buildTableHeader() {
    return Container(
      padding: AppSpacing.allSM,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.radiusSM,
      ),
      child: Row(
        children: [
          _buildHeaderCell('العدد', flex: 1),
          _buildHeaderCell('نوع الوحدة', flex: 2),
          _buildHeaderCell('المساحة م٢', flex: 1),
          _buildHeaderCell('ايجار اقتصادي', flex: 1),
          _buildHeaderCell('دخل شهري', flex: 1),
          const SizedBox(width: 40), // Space for delete button
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTypography.fieldTitle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIncomeUnitItem(int index, _IncomeUnitEntry unit) {
    return Container(
      padding: AppSpacing.allSM,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // العدد
          Expanded(
            flex: 1,
            child: _buildCompactTextField(
              unit.countController,
              'العدد',
              isNumber: true,
            ),
          ),
          AppSpacing.horizontalSpaceXS,
          // نوع الوحدة
          Expanded(
            flex: 2,
            child: _buildCompactTextField(
              unit.typeController,
              'نوع الوحدة',
            ),
          ),
          AppSpacing.horizontalSpaceXS,
          // المساحة م٢
          Expanded(
            flex: 1,
            child: _buildCompactTextField(
              unit.areaController,
              'المساحة',
              isNumber: true,
            ),
          ),
          AppSpacing.horizontalSpaceXS,
          // ايجار اقتصادي
          Expanded(
            flex: 1,
            child: _buildCompactTextField(
              unit.rentController,
              'ايجار',
              isNumber: true,
            ),
          ),
          AppSpacing.horizontalSpaceXS,
          // دخل شهري (calculated)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.radiusSM,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _numberFormat.format(unit.monthlyIncome),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Delete button
          if (_incomeUnits.length > 1)
            IconButton(
              onPressed: () => _removeIncomeUnit(index),
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.error,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCompactTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Container(
      height: 36,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.radiusSM,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.radiusSM,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.radiusSM,
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsRow() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي', style: AppTypography.fieldTitle),
              Text(
                'العدد: $_totalUnitCount',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'الدخل الشهري: ${_numberFormat.format(_monthlyTotalIncome)} د.ك',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnualIncomeSection() {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Annual Total Income (calculated)
          Text('الدخل الاجمالي السنوي', style: AppTypography.fieldTitle),
          AppSpacing.verticalSpaceXS,
          Text(
            '${_numberFormat.format(_annualTotalIncome)} د.ك',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          ),
          AppSpacing.verticalSpaceMD,
          // Capitalization Rate (manual input)
          CustomTextField(
            controller: _capitalizationRateController,
            label: 'معدل الرسملة',
            hint: '0',
            keyboardType: TextInputType.number,
            showValidationDot: false,
            suffixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('%'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPropertyRentSection() {
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
          _buildSectionSubtitle('الايجار الشهري للعقار'),
          AppSpacing.verticalSpaceSM,
          CustomTextField(
            controller: _monthlyPropertyRentController,
            label: 'الايجار الشهري',
            hint: '0',
            keyboardType: TextInputType.number,
            showValidationDot: false,
            suffixIcon: Padding(
              padding: AppSpacing.horizontalSM,
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  'د.ك',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Container(
      padding: AppSpacing.allSM,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.radiusSM,
      ),
      child: Text(
        title,
        style: AppTypography.fieldTitle.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEvaluationIssueDateSection() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final issueDate = evaluation.generalInfo?.issueDate;
    
    String formattedDate = 'غير محدد';
    if (issueDate != null) {
      formattedDate = '${issueDate.day}/${issueDate.month}/${issueDate.year}';
    }

    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تاريخ إصدار التقييم',
            style: AppTypography.fieldTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formattedDate,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyEvaluationSection() {
    return Container(
      padding: AppSpacing.allLG,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تقدير العقار',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' : ',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                'القيمة الاجمالية',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            '${_numberFormat.format(_finalTotalValue)} د.ك',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

// Helper class for dynamic income unit entries
class _IncomeUnitEntry {
  final TextEditingController countController;
  final TextEditingController typeController;
  final TextEditingController areaController;
  final TextEditingController rentController;

  _IncomeUnitEntry({
    required this.countController,
    required this.typeController,
    required this.areaController,
    required this.rentController,
    required VoidCallback onChanged,
  }) {
    countController.addListener(onChanged);
    rentController.addListener(onChanged);
  }

  int get unitCount => int.tryParse(countController.text) ?? 0;

  /// دخل شهري = العدد × ايجار اقتصادي
  double get monthlyIncome {
    final count = int.tryParse(countController.text) ?? 0;
    final rent = double.tryParse(rentController.text) ?? 0;
    return count * rent;
  }

  void dispose() {
    countController.dispose();
    typeController.dispose();
    areaController.dispose();
    rentController.dispose();
  }
}
