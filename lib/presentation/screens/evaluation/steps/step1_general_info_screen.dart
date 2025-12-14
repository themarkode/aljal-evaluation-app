import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_date_picker.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

/// Step 1: General Information Screen
class Step1GeneralInfoScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step1GeneralInfoScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step1GeneralInfoScreen> createState() =>
      _Step1GeneralInfoScreenState();
}

class _Step1GeneralInfoScreenState
    extends ConsumerState<Step1GeneralInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _requestorNameController;
  late TextEditingController _clientNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _guardPhoneController;
  late TextEditingController _siteManagerPhoneController;

  // Date values
  DateTime? _requestDate;
  DateTime? _issueDate;
  DateTime? _inspectionDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _requestorNameController = TextEditingController();
    _clientNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _clientPhoneController = TextEditingController();
    _guardPhoneController = TextEditingController();
    _siteManagerPhoneController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadEvaluation();
    });
  }

  Future<void> _loadEvaluation() async {
    // If editing an existing evaluation, load it from Firebase
    if (widget.evaluationId != null) {
      try {
        // Load fresh data when editing - loadEvaluation awaits the Firebase call
        // and updates state synchronously, so no delay is needed
        await ref
            .read(evaluationNotifierProvider.notifier)
            .loadEvaluation(widget.evaluationId!);

        // Load data into form fields immediately after evaluation is loaded
        // The state is already updated once loadEvaluation completes
        if (mounted) {
          _loadExistingData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل تحميل البيانات: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      // For new evaluation, just load existing data (might be empty)
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final generalInfo = evaluation.generalInfo;

    if (generalInfo != null) {
      setState(() {
        _requestorNameController.text = generalInfo.requestorName ?? '';
        _clientNameController.text = generalInfo.clientName ?? '';
        _ownerNameController.text = generalInfo.ownerName ?? '';
        _clientPhoneController.text = generalInfo.clientPhone ?? '';
        _guardPhoneController.text = generalInfo.guardPhone ?? '';
        _siteManagerPhoneController.text = generalInfo.siteManagerPhone ?? '';
        _requestDate = generalInfo.requestDate;
        _issueDate = generalInfo.issueDate;
        _inspectionDate = generalInfo.inspectionDate;
      });
    } else if (widget.evaluationId != null) {
      // If we have an evaluationId but no generalInfo, show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد بيانات في هذا التقييم'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _requestorNameController.dispose();
    _clientNameController.dispose();
    _ownerNameController.dispose();
    _clientPhoneController.dispose();
    _guardPhoneController.dispose();
    _siteManagerPhoneController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create GeneralInfoModel
      final generalInfo = GeneralInfoModel(
        requestorName: _requestorNameController.text.trim().isEmpty
            ? null
            : _requestorNameController.text.trim(),
        clientName: _clientNameController.text.trim().isEmpty
            ? null
            : _clientNameController.text.trim(),
        ownerName: _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        requestDate: _requestDate,
        issueDate: _issueDate,
        inspectionDate: _inspectionDate,
        clientPhone: _clientPhoneController.text.trim().isEmpty
            ? null
            : _clientPhoneController.text.trim(),
        guardPhone: _guardPhoneController.text.trim().isEmpty
            ? null
            : _guardPhoneController.text.trim(),
        siteManagerPhone: _siteManagerPhoneController.text.trim().isEmpty
            ? null
            : _siteManagerPhoneController.text.trim(),
      );

      // Update state
      ref
          .read(evaluationNotifierProvider.notifier)
          .updateGeneralInfo(generalInfo);

      // Navigate to Step 2
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep2,
        arguments: FormStepArguments.forStep(
          step: 2,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Note: We use ref.read() here instead of ref.watch() because form data
    // loading is handled in initState via _loadEvaluation(). Using watch()
    // would cause unnecessary rebuilds and the postFrameCallback anti-pattern.

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.evaluationList,
              (route) => false,
            ),
            child: Image.asset(
              'assets/images/Al_Jal_Logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.business, size: 40);
              },
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingMobileInsets,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Step Navigation Dropdown
                        StepNavigationDropdown(
                          currentStep: 1,
                          evaluationId: widget.evaluationId,
                        ),
                        const SizedBox(height: 20),
                        // Form Content
                        ResponsiveBuilder(
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
                      ],
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
                    onPrevious: _cancel,
                    nextText: 'معلومات عامة للعقار',
                    previousText: 'إلغاء',
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
        _buildRequestorNameField(),
        AppSpacing.verticalSpaceMD,
        _buildClientNameField(),
        AppSpacing.verticalSpaceMD,
        _buildOwnerNameField(),
        AppSpacing.verticalSpaceMD,
        _buildRequestDateField(),
        AppSpacing.verticalSpaceMD,
        _buildIssueDateField(),
        AppSpacing.verticalSpaceMD,
        _buildInspectionDateField(),
        AppSpacing.verticalSpaceMD,
        _buildClientPhoneField(),
        AppSpacing.verticalSpaceMD,
        _buildGuardPhoneField(),
        AppSpacing.verticalSpaceMD,
        _buildSiteManagerPhoneField(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRequestorNameField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildClientNameField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildOwnerNameField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildRequestDateField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildIssueDateField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildInspectionDateField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(child: _buildClientPhoneField()),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildGuardPhoneField()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildSiteManagerPhoneField(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Same as tablet for now
  }

  // Field builders
  Widget _buildRequestorNameField() {
    return CustomTextField(
      controller: _requestorNameController,
      label: 'اسم الجهة الطالبة للتقييم',
      hint: 'اسم الجهة الطالبة للتقييم',
    );
  }

  Widget _buildClientNameField() {
    return CustomTextField(
      controller: _clientNameController,
      label: 'العميل',
      hint: 'العميل',
    );
  }

  Widget _buildOwnerNameField() {
    return CustomTextField(
      controller: _ownerNameController,
      label: 'المالك',
      hint: 'المالك',
    );
  }

  Widget _buildRequestDateField() {
    return CustomDatePicker(
      label: 'تاريخ طلب التقييم',
      value: _requestDate,
      onChanged: (date) {
        setState(() {
          _requestDate = date;
        });
      },
    );
  }

  Widget _buildIssueDateField() {
    return CustomDatePicker(
      label: 'تاريخ إصدار التقييم',
      value: _issueDate,
      onChanged: (date) {
        setState(() {
          _issueDate = date;
        });
      },
    );
  }

  Widget _buildInspectionDateField() {
    return CustomDatePicker(
      label: 'تاريخ الكشف',
      value: _inspectionDate,
      onChanged: (date) {
        setState(() {
          _inspectionDate = date;
        });
      },
    );
  }

  Widget _buildClientPhoneField() {
    return CustomTextField(
      controller: _clientPhoneController,
      label: 'رقم العميل',
      hint: '+965',
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildGuardPhoneField() {
    return CustomTextField(
      controller: _guardPhoneController,
      label: 'رقم حارس العقار',
      hint: '+965',
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildSiteManagerPhoneField() {
    return CustomTextField(
      controller: _siteManagerPhoneController,
      label: 'رقم مسؤول الموقع',
      hint: '+965',
      keyboardType: TextInputType.phone,
    );
  }
}
