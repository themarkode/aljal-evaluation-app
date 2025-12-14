import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_date_picker.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/collapsible_section.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/data/models/pages_models/additional_data_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

/// Step 9: Additional Data Screen - FINAL FORM STEP
class Step9AdditionalDataScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step9AdditionalDataScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step9AdditionalDataScreen> createState() =>
      _Step9AdditionalDataScreenState();
}

class _Step9AdditionalDataScreenState
    extends ConsumerState<Step9AdditionalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _evaluationPurposeController;
  late TextEditingController _buildingSystemController;
  late TextEditingController _buildingRatioController;
  late TextEditingController _accordingToController;
  late TextEditingController _totalValueController;

  // Date
  DateTime? _evaluationIssueDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _evaluationPurposeController = TextEditingController();
    _buildingSystemController = TextEditingController();
    _buildingRatioController = TextEditingController();
    _accordingToController = TextEditingController();
    _totalValueController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final additionalData = evaluation.additionalData;

    if (additionalData != null) {
      _evaluationPurposeController.text =
          additionalData.evaluationPurpose ?? '';
      _buildingSystemController.text = additionalData.buildingSystem ?? '';
      _buildingRatioController.text = additionalData.buildingRatio ?? '';
      _accordingToController.text = additionalData.accordingTo ?? '';
      _totalValueController.text = additionalData.totalValue?.toString() ?? '';

      setState(() {
        _evaluationIssueDate = additionalData.evaluationIssueDate;
      });
    }
  }

  @override
  void dispose() {
    _evaluationPurposeController.dispose();
    _buildingSystemController.dispose();
    _buildingRatioController.dispose();
    _accordingToController.dispose();
    _totalValueController.dispose();
    super.dispose();
  }

  Future<void> _saveAndComplete() async {
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

        // Create AdditionalDataModel
        final additionalData = AdditionalDataModel(
          evaluationPurpose: _evaluationPurposeController.text.trim().isEmpty
              ? null
              : _evaluationPurposeController.text.trim(),
          buildingSystem: _buildingSystemController.text.trim().isEmpty
              ? null
              : _buildingSystemController.text.trim(),
          buildingRatio: _buildingRatioController.text.trim().isEmpty
              ? null
              : _buildingRatioController.text.trim(),
          accordingTo: _accordingToController.text.trim().isEmpty
              ? null
              : _accordingToController.text.trim(),
          totalValue: _totalValueController.text.trim().isEmpty
              ? null
              : double.tryParse(_totalValueController.text.trim()),
          evaluationIssueDate: _evaluationIssueDate,
        );

        // Update state with additional data
        ref
            .read(evaluationNotifierProvider.notifier)
            .updateAdditionalData(additionalData);

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
          // Reset evaluation state for next form
          ref.read(evaluationNotifierProvider.notifier).resetEvaluation();

          // Navigate to evaluation list
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.evaluationList,
            (route) => false,
          );
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
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep8,
      arguments: FormStepArguments.forStep(
        step: 8,
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بيانات إضافية',
                style: AppTypography.heading,
              ),
              Image.asset(
                'assets/images/Al_Jal_Logo.png',
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business, size: 40);
                },
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
                    child: CollapsibleSection(
                      title: 'بيانات إضافية',
                      initiallyExpanded: true,
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
                    onNext: _saveAndComplete,
                    onPrevious: _goBack,
                    nextText: 'حفظ النموذج',
                    previousText: 'صور وموقع العقار',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Evaluation Purpose Section
        Text(
          'الغرض من التقييم',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        _buildEvaluationPurposeField(),
        AppSpacing.verticalSpaceLG,

        // Regulatory Opinion Section
        Text(
          'الرأي التنظيمي',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        _buildBuildingSystemField(),
        AppSpacing.verticalSpaceMD,
        _buildBuildingRatioField(),
        AppSpacing.verticalSpaceMD,
        _buildAccordingToField(),
        AppSpacing.verticalSpaceLG,

        // Property Valuation Section
        Text(
          'تقدير العقار',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        _buildTotalValueField(),
        AppSpacing.verticalSpaceMD,
        _buildEvaluationIssueDateField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Evaluation Purpose Section
        Text(
          'الغرض من التقييم',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        _buildEvaluationPurposeField(),
        AppSpacing.verticalSpaceLG,

        // Regulatory Opinion Section
        Text(
          'الرأي التنظيمي',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        Row(
          children: [
            Expanded(child: _buildBuildingSystemField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildBuildingRatioField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildAccordingToField(),
        AppSpacing.verticalSpaceLG,

        // Property Valuation Section
        Text(
          'تقدير العقار',
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceSM,
        Row(
          children: [
            Expanded(child: _buildTotalValueField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildEvaluationIssueDateField()),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildEvaluationPurposeField() {
    return CustomTextField(
      controller: _evaluationPurposeController,
      label: 'الغرض من التقييم',
      hint: 'الغرض من التقييم',
    );
  }

  Widget _buildBuildingSystemField() {
    return CustomTextField(
      controller: _buildingSystemController,
      label: 'نظام البناء',
      hint: 'نظام البناء',
    );
  }

  Widget _buildBuildingRatioField() {
    return CustomTextField(
      controller: _buildingRatioController,
      label: 'النسبة',
      hint: 'النسبة',
    );
  }

  Widget _buildAccordingToField() {
    return CustomTextField(
      controller: _accordingToController,
      label: 'حسب',
      hint: 'حسب',
    );
  }

  Widget _buildTotalValueField() {
    return CustomTextField(
      controller: _totalValueController,
      label: 'القيمة الإجمالية',
      hint: '0.00',
      keyboardType: TextInputType.number,
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
    );
  }

  Widget _buildEvaluationIssueDateField() {
    return CustomDatePicker(
      label: 'تاريخ إصدار التقييم النهائي',
      value: _evaluationIssueDate,
      onChanged: (date) {
        setState(() {
          _evaluationIssueDate = date;
        });
      },
    );
  }
}
