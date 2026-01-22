import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';
import 'package:aljal_evaluation/core/utils/validators/phone_validator.dart';
import 'package:aljal_evaluation/core/routing/step_navigation.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_date_picker.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step_screen_mixin.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 1: General Information Screen
class Step1GeneralInfoScreen extends ConsumerStatefulWidget {
  final String? evaluationId;
  final bool isViewOnly;

  const Step1GeneralInfoScreen({
    super.key,
    this.evaluationId,
    this.isViewOnly = false,
  });

  @override
  ConsumerState<Step1GeneralInfoScreen> createState() =>
      _Step1GeneralInfoScreenState();
}

class _Step1GeneralInfoScreenState extends ConsumerState<Step1GeneralInfoScreen>
    with WidgetsBindingObserver, StepScreenMixin {
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

  // Note: errorBlinkTrigger is now provided by StepScreenMixin (centralized)

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin (adds lifecycle observer)

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
    disposeStepScreen(); // Clean up mixin (removes lifecycle observer + errorBlinkTrigger)
    _requestorNameController.dispose();
    _clientNameController.dispose();
    _ownerNameController.dispose();
    _clientPhoneController.dispose();
    _guardPhoneController.dispose();
    _siteManagerPhoneController.dispose();
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
    // In view-only mode, just navigate without validation
    if (widget.isViewOnly) {
      StepNavigation.goToNextStep(
        context,
        currentStep: 1,
        evaluationId: widget.evaluationId,
        isViewOnly: true,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Save to memory state only (no Firebase save)
      saveCurrentDataToState();

      // Navigate to Step 2
      StepNavigation.goToNextStep(
        context,
        currentStep: 1,
        evaluationId: widget.evaluationId,
      );
    } else {
      // Validation failed - trigger blink
      _onValidationFailed();
    }
  }

  Future<void> _cancel() async {
    await showExitConfirmationDialog(); // From mixin
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final generalInfo = GeneralInfoModel(
      requestorName: _requestorNameController.textOrNull,
      clientName: _clientNameController.textOrNull,
      ownerName: _ownerNameController.textOrNull,
      requestDate: _requestDate,
      issueDate: _issueDate,
      inspectionDate: _inspectionDate,
      clientPhone: _clientPhoneController.textOrNull,
      guardPhone: _guardPhoneController.textOrNull,
      siteManagerPhone: _siteManagerPhoneController.textOrNull,
    );
    ref
        .read(evaluationNotifierProvider.notifier)
        .updateGeneralInfo(generalInfo);
  }

  @override
  Widget build(BuildContext context) {
    // Note: We use ref.read() here instead of ref.watch() because form data
    // loading is handled in initState via _loadEvaluation(). Using watch()
    // would cause unnecessary rebuilds and the postFrameCallback anti-pattern.

    return StepScreenTemplate(
      currentStep: 1,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
      onNext: _saveAndContinue,
      onPrevious: _cancel,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      isViewOnly: widget.isViewOnly,
      mobileContent: _buildMobileLayout(),
      tabletContent: _buildTabletLayout(),
      desktopContent: _buildDesktopLayout(),
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
      showValidationDot: true,
      enabled: !widget.isViewOnly,
    );
  }

  Widget _buildClientNameField() {
    return CustomTextField(
      controller: _clientNameController,
      label: 'العميل',
      hint: 'العميل',
      showValidationDot: true,
      enabled: !widget.isViewOnly,
    );
  }

  Widget _buildOwnerNameField() {
    return CustomTextField(
      controller: _ownerNameController,
      label: 'المالك',
      hint: 'المالك',
      showValidationDot: true,
      enabled: !widget.isViewOnly,
    );
  }

  Widget _buildRequestDateField() {
    return CustomDatePicker(
      label: 'تاريخ طلب التقييم',
      value: _requestDate,
      showValidationDot: true,
      enabled: !widget.isViewOnly,
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
      showValidationDot: true,
      enabled: !widget.isViewOnly,
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
      showValidationDot: true,
      enabled: !widget.isViewOnly,
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
      hint: '\u200E+965', // LTR mark to display +965 correctly in RTL
      keyboardType: TextInputType.number,
      inputFormatters: PhoneValidator.formatters(),
      validator: PhoneValidator.validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      errorBlinkTrigger: errorBlinkTrigger, // From StepScreenMixin
      enabled: !widget.isViewOnly,
    );
  }

  Widget _buildGuardPhoneField() {
    return CustomTextField(
      controller: _guardPhoneController,
      label: 'رقم حارس العقار',
      hint: '\u200E+965', // LTR mark to display +965 correctly in RTL
      keyboardType: TextInputType.number,
      inputFormatters: PhoneValidator.formatters(),
      validator: PhoneValidator.validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      errorBlinkTrigger: errorBlinkTrigger, // From StepScreenMixin
      enabled: !widget.isViewOnly,
    );
  }

  Widget _buildSiteManagerPhoneField() {
    return CustomTextField(
      controller: _siteManagerPhoneController,
      label: 'رقم مسؤول الموقع',
      hint: '\u200E+965', // LTR mark to display +965 correctly in RTL
      keyboardType: TextInputType.number,
      inputFormatters: PhoneValidator.formatters(),
      validator: PhoneValidator.validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      errorBlinkTrigger: errorBlinkTrigger, // From StepScreenMixin
      enabled: !widget.isViewOnly,
    );
  }
}
