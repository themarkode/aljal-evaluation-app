import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import '../molecules/floor_table_row.dart';
import '../atoms/custom_button.dart';

/// Floors section organism - manages dynamic list of floors
class FloorsSection extends StatelessWidget {
  final List<FloorModel> floors;
  final void Function(int index, FloorModel floor)? onFloorChanged;
  final void Function(int index)? onFloorDeleted;
  final VoidCallback? onAddFloor;
  final int minFloors;
  final int maxFloors;

  const FloorsSection({
    super.key,
    required this.floors,
    this.onFloorChanged,
    this.onFloorDeleted,
    this.onAddFloor,
    this.minFloors = 1,
    this.maxFloors = 50,
  });

  bool get canAddMore => floors.length < maxFloors;
  bool get canDelete => floors.length > minFloors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأدوار (${floors.length})',
              style: AppTypography.fieldTitle.copyWith(
                color: AppColors.primary,
              ),
              textDirection: TextDirection.rtl,
            ),
            if (canAddMore)
              TextButton.icon(
                onPressed: onAddFloor,
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                ),
                label: const Text('إضافة دور'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),

        AppSpacing.verticalSpaceMD,

        // Floor list
        if (floors.isEmpty)
          Container(
            padding: AppSpacing.allXL,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: AppSpacing.radiusMD,
              border: Border.all(
                color: AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.layers_outlined,
                    size: 48,
                    color: AppColors.midGray,
                  ),
                  AppSpacing.verticalSpaceSM,
                  Text(
                    'لم يتم إضافة أي أدوار بعد',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  AppSpacing.verticalSpaceSM,
                  CustomButton.primary(
                    text: 'إضافة دور',
                    onPressed: onAddFloor,
                    icon: const Icon(Icons.add, color: AppColors.white),
                  ),
                ],
              ),
            ),
          )
        else
          ...floors.asMap().entries.map((entry) {
            final index = entry.key;
            final floor = entry.value;

            return FloorTableRow(
              floor: floor,
              index: index,
              onChanged: (updatedFloor) =>
                  onFloorChanged?.call(index, updatedFloor),
              onDelete: canDelete ? () => onFloorDeleted?.call(index) : null,
              canDelete: canDelete,
            );
          }),

        // Add button at bottom (if not empty)
        if (floors.isNotEmpty && canAddMore) ...[
          AppSpacing.verticalSpaceMD,
          CustomButton(
            text: 'إضافة دور آخر',
            onPressed: onAddFloor,
            type: ButtonType.text,
            icon: const Icon(Icons.add),
            isExpanded: true,
          ),
        ],

        // Max limit message
        if (!canAddMore) ...[
          AppSpacing.verticalSpaceSM,
          Container(
            padding: AppSpacing.allSM,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.radiusMD,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.horizontalSpaceXS,
                Expanded(
                  child: Text(
                    'تم الوصول للحد الأقصى من الأدوار ($maxFloors دور)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
