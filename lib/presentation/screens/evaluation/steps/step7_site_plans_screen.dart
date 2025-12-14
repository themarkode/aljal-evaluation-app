import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/site_plans_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

/// Step 7: Site Plans Screen
class Step7SitePlansScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step7SitePlansScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step7SitePlansScreen> createState() =>
      _Step7SitePlansScreenState();
}

class _Step7SitePlansScreenState extends ConsumerState<Step7SitePlansScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _generalNotesController;
  late TextEditingController _approvedPlanComparisonController;
  late TextEditingController _siteMeasurementNumbersController;
  late TextEditingController _violationNotesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _generalNotesController = TextEditingController();
    _approvedPlanComparisonController = TextEditingController();
    _siteMeasurementNumbersController = TextEditingController();
    _violationNotesController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final sitePlans = evaluation.sitePlans;

    if (sitePlans != null) {
      _generalNotesController.text = sitePlans.generalNotes ?? '';
      _approvedPlanComparisonController.text =
          sitePlans.approvedPlanComparison ?? '';
      _siteMeasurementNumbersController.text =
          sitePlans.siteMeasurementNumbers ?? '';
      _violationNotesController.text = sitePlans.violationNotes ?? '';
    }
  }

  @override
  void dispose() {
    _generalNotesController.dispose();
    _approvedPlanComparisonController.dispose();
    _siteMeasurementNumbersController.dispose();
    _violationNotesController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create SitePlansModel
      final sitePlans = SitePlansModel(
        generalNotes: _generalNotesController.text.trim().isEmpty
            ? null
            : _generalNotesController.text.trim(),
        approvedPlanComparison:
            _approvedPlanComparisonController.text.trim().isEmpty
                ? null
                : _approvedPlanComparisonController.text.trim(),
        siteMeasurementNumbers:
            _siteMeasurementNumbersController.text.trim().isEmpty
                ? null
                : _siteMeasurementNumbersController.text.trim(),
        violationNotes: _violationNotesController.text.trim().isEmpty
            ? null
            : _violationNotesController.text.trim(),
      );

      // Update state
      ref.read(evaluationNotifierProvider.notifier).updateSitePlans(sitePlans);

      // Navigate to Step 8
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep8,
        arguments: FormStepArguments.forStep(
          step: 8,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep6,
      arguments: FormStepArguments.forStep(
        step: 6,
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
                  currentStep: 7,
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
                    nextText: 'صور وموقع العقار',
                    previousText: 'ملاحظات الدخل',
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
        _buildGeneralNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildApprovedPlanComparisonField(),
        AppSpacing.verticalSpaceMD,
        _buildSiteMeasurementNumbersField(),
        AppSpacing.verticalSpaceMD,
        _buildViolationNotesField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildGeneralNotesField(),
        AppSpacing.verticalSpaceMD,
        _buildApprovedPlanComparisonField(),
        AppSpacing.verticalSpaceMD,
        _buildSiteMeasurementNumbersField(),
        AppSpacing.verticalSpaceMD,
        _buildViolationNotesField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildGeneralNotesField() {
    return CustomTextField(
      controller: _generalNotesController,
      label: 'ملاحظات عامة',
      hint: 'ملاحظات عامة...',
      maxLines: 5,
    );
  }

  Widget _buildApprovedPlanComparisonField() {
    return CustomTextField(
      controller: _approvedPlanComparisonController,
      label: 'مقارنة المخطط المعتمد بالموقع',
      hint: 'مقارنة المخطط المعتمد بالموقع...',
      maxLines: 5,
    );
  }

  Widget _buildSiteMeasurementNumbersField() {
    return CustomTextField(
      controller: _siteMeasurementNumbersController,
      label: 'رقم المقاسات بالموقع',
      hint: 'رقم المقاسات بالموقع...',
      maxLines: 5,
    );
  }

  Widget _buildViolationNotesField() {
    return CustomTextField(
      controller: _violationNotesController,
      label: 'ملاحظات المخالفات',
      hint: 'ملاحظات المخالفات...',
      maxLines: 5,
    );
  }
}
