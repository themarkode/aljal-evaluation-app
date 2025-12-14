import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/income_notes_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

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

class _Step6IncomeNotesScreenState
    extends ConsumerState<Step6IncomeNotesScreen> {
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
    _tenantTypeController.dispose();
    _incomeDetailsController.dispose();
    _unitDescriptionController.dispose();
    _unitTypeController.dispose();
    _vacancyRateController.dispose();
    _rentalValueVerificationController.dispose();
    super.dispose();
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
      // Create IncomeNotesModel
      final incomeNotes = IncomeNotesModel(
        tenantType: _tenantTypeController.text.trim().isEmpty
            ? null
            : _tenantTypeController.text.trim(),
        unitCount: _unitCount,
        incomeDetails: _incomeDetailsController.text.trim().isEmpty
            ? null
            : _incomeDetailsController.text.trim(),
        unitDescription: _unitDescriptionController.text.trim().isEmpty
            ? null
            : _unitDescriptionController.text.trim(),
        unitType: _unitTypeController.text.trim().isEmpty
            ? null
            : _unitTypeController.text.trim(),
        vacancyRate: _vacancyRateController.text.trim().isEmpty
            ? null
            : double.tryParse(_vacancyRateController.text.trim()),
        rentalValueVerification:
            _rentalValueVerificationController.text.trim().isEmpty
                ? null
                : _rentalValueVerificationController.text.trim(),
      );

      // Update state
      ref
          .read(evaluationNotifierProvider.notifier)
          .updateIncomeNotes(incomeNotes);

      // Navigate to Step 7
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep7,
        arguments: FormStepArguments.forStep(
          step: 7,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep5,
      arguments: FormStepArguments.forStep(
        step: 5,
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
                  currentStep: 6,
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
                Container(
                  padding: AppSpacing.screenPaddingMobileInsets,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: FormNavigationButtons(
                    onNext: _saveAndContinue,
                    onPrevious: _goBack,
                    nextText: 'المخطط ورفع القياس بالموقع',
                    previousText: 'تفاصيل المنطقة المحيطه بالعقار',
                    showPrevious: true,
                  ),
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
