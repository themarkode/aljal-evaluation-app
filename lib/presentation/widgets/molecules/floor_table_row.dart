import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_dropdown.dart';

/// Floor table row for dynamic floor entries
class FloorTableRow extends StatelessWidget {
  final FloorModel floor;
  final int index;
  final void Function(FloorModel)? onChanged;
  final VoidCallback? onDelete;
  final bool canDelete;
  final List<String> floorTypeOptions;
  final List<String> usageTypeOptions;

  const FloorTableRow({
    super.key,
    required this.floor,
    required this.index,
    this.onChanged,
    this.onDelete,
    this.canDelete = true,
    required this.floorTypeOptions,
    required this.usageTypeOptions,
  });

  void _updateFloor({
    String? floorType,
    String? usageType,
    String? numberOfUnits,
    String? areaPerUnit,
    String? totalArea,
  }) {
    final updatedFloor = FloorModel(
      floorType: floorType ?? floor.floorType,
      usageType: usageType ?? floor.usageType,
      numberOfUnits: numberOfUnits ?? floor.numberOfUnits,
      areaPerUnit: areaPerUnit ?? floor.areaPerUnit,
      totalArea: totalArea ?? floor.totalArea,
    );
    onChanged?.call(updatedFloor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMD,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with floor number and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الدور ${index + 1}',
                style: AppTypography.fieldTitle.copyWith(
                  color: AppColors.primary,
                ),
                textDirection: TextDirection.rtl,
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                  tooltip: 'حذف الدور',
                ),
            ],
          ),

          AppSpacing.verticalSpaceSM,

          // Floor type dropdown
          CustomDropdown(
            label: 'نوع الدور',
            value: floor.floorType,
            items: floorTypeOptions,
            onChanged: (value) => _updateFloor(floorType: value),
            hint: 'اختر نوع الدور',
          ),

          AppSpacing.verticalSpaceSM,

          // Usage type dropdown
          CustomDropdown(
            label: 'نوع الاستخدام',
            value: floor.usageType,
            items: usageTypeOptions,
            onChanged: (value) => _updateFloor(usageType: value),
            hint: 'اختر نوع الاستخدام',
          ),

          AppSpacing.verticalSpaceSM,

          // Number of units
          CustomTextField(
            label: 'عدد الوحدات',
            initialValue: floor.numberOfUnits,
            onChanged: (value) => _updateFloor(numberOfUnits: value),
            keyboardType: TextInputType.number,
            hint: 'أدخل عدد الوحدات',
          ),

          AppSpacing.verticalSpaceSM,

          // Area per unit
          CustomTextField(
            label: 'مساحة الوحدة (م²)',
            initialValue: floor.areaPerUnit,
            onChanged: (value) => _updateFloor(areaPerUnit: value),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hint: 'أدخل مساحة الوحدة',
          ),

          AppSpacing.verticalSpaceSM,

          // Total area
          CustomTextField(
            label: 'المساحة الكلية (م²)',
            initialValue: floor.totalArea,
            onChanged: (value) => _updateFloor(totalArea: value),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hint: 'أدخل المساحة الكلية',
          ),
        ],
      ),
    );
  }
}
