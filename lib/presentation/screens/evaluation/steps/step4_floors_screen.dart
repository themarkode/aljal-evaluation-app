import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';

/// Step 4: Floors Screen
class Step4FloorsScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step4FloorsScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step4FloorsScreen> createState() => _Step4FloorsScreenState();
}

class _Step4FloorsScreenState extends ConsumerState<Step4FloorsScreen> {
  final _formKey = GlobalKey<FormState>();

  List<_FloorEntry> _floors = [];

  @override
  void initState() {
    super.initState();

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
    for (var floor in _floors) {
      floor.nameController.dispose();
      floor.detailsController.dispose();
    }
    super.dispose();
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
    if (_formKey.currentState?.validate() ?? false) {
      // Create FloorModel list
      final floors = _floors.map((floor) {
        return FloorModel(
          floorName: floor.nameController.text.trim().isEmpty
              ? null
              : floor.nameController.text.trim(),
          floorDetails: floor.detailsController.text.trim().isEmpty
              ? null
              : floor.detailsController.text.trim(),
        );
      }).toList();

      // Update state
      ref.read(evaluationNotifierProvider.notifier).updateFloors(floors);

      // Navigate to Step 5
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep5,
        arguments: FormStepArguments.forStep(
          step: 5,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep3,
      arguments: FormStepArguments.forStep(
        step: 3,
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
                  currentStep: 4,
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
                    child: Column(
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
                  ),
                ),
                // Navigation buttons
                FormNavigationButtons(
                  currentStep: 4,
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

  Widget _buildFloorsCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عدد الادوار',
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
          ),

          AppSpacing.verticalSpaceSM,

          // Floor details field
          CustomTextField(
            controller: _floors[index].detailsController,
            label: 'تفاصيل الدور',
            hint: 'تفاصيل الدور',
            maxLines: 3,
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
