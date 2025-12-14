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
import 'package:aljal_evaluation/data/models/pages_models/area_details_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

/// Step 5: Area Details Screen
class Step5AreaDetailsScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step5AreaDetailsScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step5AreaDetailsScreen> createState() =>
      _Step5AreaDetailsScreenState();
}

class _Step5AreaDetailsScreenState
    extends ConsumerState<Step5AreaDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _streetsAndInfrastructureController;
  late TextEditingController _areaPropertyTypesController;
  late TextEditingController _areaEntrancesExitsController;
  late TextEditingController _generalAreaDirectionController;
  late TextEditingController _areaRentalRatesController;
  late TextEditingController _neighboringTenantTypesController;
  late TextEditingController _areaVacancyRatesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _streetsAndInfrastructureController = TextEditingController();
    _areaPropertyTypesController = TextEditingController();
    _areaEntrancesExitsController = TextEditingController();
    _generalAreaDirectionController = TextEditingController();
    _areaRentalRatesController = TextEditingController();
    _neighboringTenantTypesController = TextEditingController();
    _areaVacancyRatesController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final areaDetails = evaluation.areaDetails;

    if (areaDetails != null) {
      _streetsAndInfrastructureController.text =
          areaDetails.streetsAndInfrastructure ?? '';
      _areaPropertyTypesController.text = areaDetails.areaPropertyTypes ?? '';
      _areaEntrancesExitsController.text = areaDetails.areaEntrancesExits ?? '';
      _generalAreaDirectionController.text =
          areaDetails.generalAreaDirection ?? '';
      _areaRentalRatesController.text = areaDetails.areaRentalRates ?? '';
      _neighboringTenantTypesController.text =
          areaDetails.neighboringTenantTypes ?? '';
      _areaVacancyRatesController.text = areaDetails.areaVacancyRates ?? '';
    }
  }

  @override
  void dispose() {
    _streetsAndInfrastructureController.dispose();
    _areaPropertyTypesController.dispose();
    _areaEntrancesExitsController.dispose();
    _generalAreaDirectionController.dispose();
    _areaRentalRatesController.dispose();
    _neighboringTenantTypesController.dispose();
    _areaVacancyRatesController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create AreaDetailsModel
      final areaDetails = AreaDetailsModel(
        streetsAndInfrastructure:
            _streetsAndInfrastructureController.text.trim().isEmpty
                ? null
                : _streetsAndInfrastructureController.text.trim(),
        areaPropertyTypes: _areaPropertyTypesController.text.trim().isEmpty
            ? null
            : _areaPropertyTypesController.text.trim(),
        areaEntrancesExits: _areaEntrancesExitsController.text.trim().isEmpty
            ? null
            : _areaEntrancesExitsController.text.trim(),
        generalAreaDirection:
            _generalAreaDirectionController.text.trim().isEmpty
                ? null
                : _generalAreaDirectionController.text.trim(),
        areaRentalRates: _areaRentalRatesController.text.trim().isEmpty
            ? null
            : _areaRentalRatesController.text.trim(),
        neighboringTenantTypes:
            _neighboringTenantTypesController.text.trim().isEmpty
                ? null
                : _neighboringTenantTypesController.text.trim(),
        areaVacancyRates: _areaVacancyRatesController.text.trim().isEmpty
            ? null
            : _areaVacancyRatesController.text.trim(),
      );

      // Update state
      ref
          .read(evaluationNotifierProvider.notifier)
          .updateAreaDetails(areaDetails);

      // Navigate to Step 6
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep6,
        arguments: FormStepArguments.forStep(
          step: 6,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep4,
      arguments: FormStepArguments.forStep(
        step: 4,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            onPressed: _goBack,
          ),
          title: StepNavigationDropdown(
            currentStep: 5,
            evaluationId: widget.evaluationId,
          ),
          actions: [
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
            const SizedBox(width: 16),
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
                  currentStep: 5,
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
        _buildStreetsAndInfrastructureField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaEntrancesExitsField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaPropertyTypesField(),
        AppSpacing.verticalSpaceMD,
        _buildGeneralAreaDirectionField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaRentalRatesField(),
        AppSpacing.verticalSpaceMD,
        _buildNeighboringTenantTypesField(),
        AppSpacing.verticalSpaceMD,
        _buildAreaVacancyRatesField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStreetsAndInfrastructureField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildAreaEntrancesExitsField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildAreaPropertyTypesField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildGeneralAreaDirectionField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildAreaRentalRatesField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildNeighboringTenantTypesField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildAreaVacancyRatesField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout();
  }

  // Field builders
  Widget _buildStreetsAndInfrastructureField() {
    return CustomTextField(
      controller: _streetsAndInfrastructureController,
      label: 'الشوارع والبنية التحتية',
      hint: 'الشوارع والبنية التحتية',
      maxLines: 2,
    );
  }

  Widget _buildAreaEntrancesExitsField() {
    return CustomTextField(
      controller: _areaEntrancesExitsController,
      label: 'مداخل ومخارج المنطقة',
      hint: 'مداخل ومخارج المنطقة',
      maxLines: 2,
    );
  }

  Widget _buildAreaPropertyTypesField() {
    return CustomTextField(
      controller: _areaPropertyTypesController,
      label: 'أنواع العقارات بالمنطقة',
      hint: 'أنواع العقارات بالمنطقة',
      maxLines: 2,
    );
  }

  Widget _buildGeneralAreaDirectionField() {
    return CustomTextField(
      controller: _generalAreaDirectionController,
      label: 'التوجه العام بالمنطقة',
      hint: 'التوجه العام بالمنطقة',
      maxLines: 2,
    );
  }

  Widget _buildAreaRentalRatesField() {
    return CustomTextField(
      controller: _areaRentalRatesController,
      label: 'معدل الإيجارات بالمنطقة',
      hint: 'معدل الإيجارات بالمنطقة',
      maxLines: 2,
    );
  }

  Widget _buildNeighboringTenantTypesField() {
    return CustomTextField(
      controller: _neighboringTenantTypesController,
      label: 'نوع المستأجرين بالعقارات المجاورة',
      hint: 'نوع المستأجرين بالعقارات المجاورة',
      maxLines: 2,
    );
  }

  Widget _buildAreaVacancyRatesField() {
    return CustomTextField(
      controller: _areaVacancyRatesController,
      label: 'معدلات الشواغر بالمنطقة',
      hint: 'معدلات الشواغر بالمنطقة',
      maxLines: 2,
    );
  }
}
