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
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:aljal_evaluation/presentation/widgets/templates/step_screen_template.dart';

/// Step 4: Floors Screen
class Step4FloorsScreen extends ConsumerStatefulWidget {
  final String? evaluationId;
  final bool isViewOnly;

  const Step4FloorsScreen({
    super.key,
    this.evaluationId,
    this.isViewOnly = false,
  });

  @override
  ConsumerState<Step4FloorsScreen> createState() => _Step4FloorsScreenState();
}

class _Step4FloorsScreenState extends ConsumerState<Step4FloorsScreen>
    with WidgetsBindingObserver, StepScreenMixin {
  final _formKey = GlobalKey<FormState>();

  List<_FloorEntry> _floors = [];

  @override
  void initState() {
    super.initState();
    initStepScreen(); // Initialize mixin

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final existingFloors = evaluation.floors;

    if (existingFloors != null && existingFloors.isNotEmpty) {
      setState(() {
        _floors = existingFloors.map((floor) {
          return _FloorEntry(
            nameController: TextEditingController(text: floor.floorName ?? ''),
            detailsController:
                TextEditingController(text: floor.floorDetails ?? ''),
          );
        }).toList();
      });
    } else {
      // Start with at least one floor
      _addFloor();
    }
  }

  @override
  void dispose() {
    disposeStepScreen(); // Clean up mixin
    for (var floor in _floors) {
      floor.nameController.dispose();
      floor.detailsController.dispose();
    }
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

  void _addFloor() {
    setState(() {
      _floors.add(_FloorEntry(
        nameController: TextEditingController(),
        detailsController: TextEditingController(),
      ));
    });
  }

  void _removeFloor(int index) {
    if (_floors.length > 1) {
      setState(() {
        _floors[index].nameController.dispose();
        _floors[index].detailsController.dispose();
        _floors.removeAt(index);
      });
    }
  }

  void _incrementCount() {
    _addFloor();
  }

  void _decrementCount() {
    if (_floors.length > 1) {
      _removeFloor(_floors.length - 1);
    }
  }

  void _saveAndContinue() {
    // In view-only mode, just navigate
    if (widget.isViewOnly) {
      StepNavigation.goToNextStep(
        context,
        currentStep: 4,
        evaluationId: widget.evaluationId,
        isViewOnly: true,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Save to memory state only (no Firebase save)
      saveCurrentDataToState();

      // Navigate to Step 5
      StepNavigation.goToNextStep(
        context,
        currentStep: 4,
        evaluationId: widget.evaluationId,
      );
    }
  }

  void _goBack() {
    // In view-only mode, just navigate
    if (widget.isViewOnly) {
      StepNavigation.goToPreviousStep(
        context,
        currentStep: 4,
        evaluationId: widget.evaluationId,
        isViewOnly: true,
      );
      return;
    }

    // Save to memory state only (no Firebase save)
    saveCurrentDataToState();

    StepNavigation.goToPreviousStep(
      context,
      currentStep: 4,
      evaluationId: widget.evaluationId,
    );
  }

  /// Save current form data to state without validation
  @override
  void saveCurrentDataToState() {
    final floors = _floors.map((floor) {
      return FloorModel(
        floorName: floor.nameController.textOrNull,
        floorDetails: floor.detailsController.textOrNull,
      );
    }).toList();
    ref.read(evaluationNotifierProvider.notifier).updateFloors(floors);
  }

  @override
  Widget build(BuildContext context) {
    return StepScreenTemplate(
      currentStep: 4,
      evaluationId: widget.evaluationId,
      formKey: _formKey,
      onNext: _saveAndContinue,
      onPrevious: _goBack,
      onLogoTap: showExitConfirmationDialog,
      onSaveToMemory: saveCurrentDataToState,
      validateBeforeNavigation: _validateForm,
      onValidationFailed: _onValidationFailed,
      isViewOnly: widget.isViewOnly,
      mobileContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Floors count
          _buildFloorsCount(),
          AppSpacing.verticalSpaceMD,

          // Floors list
          ..._buildFloorsList(),

          AppSpacing.verticalSpaceMD,

          // Add floor button
          _buildAddFloorButton(),
        ],
      ),
    );
  }

  Widget _buildFloorsCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.validationDot,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              'عدد الادوار',
              style: AppTypography.fieldTitle,
            ),
          ],
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
                onPressed: _decrementCount,
                icon: const Icon(Icons.remove),
              ),
              Text(
                '${_floors.length}',
                style: AppTypography.inputText,
              ),
              IconButton(
                onPressed: _incrementCount,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloorsList() {
    List<Widget> widgets = [];

    for (int i = 0; i < _floors.length; i++) {
      widgets.add(_buildFloorItem(i));
      if (i < _floors.length - 1) {
        widgets.add(AppSpacing.verticalSpaceMD);
      }
    }

    return widgets;
  }

  Widget _buildFloorItem(int index) {
    return Container(
      padding: AppSpacing.allMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        children: [
          // Header with delete button
          Row(
            children: [
              Expanded(
                child: Text(
                  'دور ${index + 1}',
                  style: AppTypography.fieldTitle,
                ),
              ),
              if (_floors.length > 1)
                IconButton(
                  onPressed: () => _removeFloor(index),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.error,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          AppSpacing.verticalSpaceSM,

          // Floor name field
          CustomTextField(
            controller: _floors[index].nameController,
            label: 'اسم/ رقم الدور',
            hint: 'اسم/ رقم الدور',
            showValidationDot: true,
          ),

          AppSpacing.verticalSpaceSM,

          // Floor details field
          CustomTextField(
            controller: _floors[index].detailsController,
            label: 'تفاصيل الدور',
            hint: 'تفاصيل الدور',
            maxLines: 3,
            showValidationDot: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddFloorButton() {
    return CustomButton.secondary(
      text: 'أضف دور',
      onPressed: _addFloor,
      icon: const Icon(Icons.add, color: AppColors.white),
    );
  }
}

class _FloorEntry {
  final TextEditingController nameController;
  final TextEditingController detailsController;

  _FloorEntry({
    required this.nameController,
    required this.detailsController,
  });
}
