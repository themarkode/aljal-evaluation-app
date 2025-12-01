import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';

/// Floor table row for dynamic floor entries
class FloorTableRow extends StatelessWidget {
  final FloorModel floor;
  final int index;
  final void Function(FloorModel)? onChanged;
  final VoidCallback? onDelete;
  final bool canDelete;

  const FloorTableRow({
    super.key,
    required this.floor,
    required this.index,
    this.onChanged,
    this.onDelete,
    this.canDelete = true,
  });

  void _updateFloor({
    String? floorName,
    String? floorDetails,
  }) {
    final updatedFloor = FloorModel(
      floorName: floorName ?? floor.floorName,
      floorDetails: floorDetails ?? floor.floorDetails,
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

          // Floor name
          CustomTextField(
            label: 'اسم / رقم الدور',
            initialValue: floor.floorName,
            onChanged: (value) => _updateFloor(floorName: value),
            hint: 'أدخل اسم أو رقم الدور',
          ),

          AppSpacing.verticalSpaceSM,

          // Floor details
          CustomTextField(
            label: 'تفاصيل الدور',
            initialValue: floor.floorDetails,
            onChanged: (value) => _updateFloor(floorDetails: value),
            hint: 'أدخل تفاصيل الدور',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
