import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';
import '../molecules/search_bar_widget.dart';
import '../atoms/custom_button.dart';

/// Toolbar for evaluation list - search, filter, view toggle
class EvaluationListToolbar extends StatelessWidget {
  final String? searchQuery;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool isGridView;
  final VoidCallback? onViewToggle;
  final VoidCallback? onAddNew;
  final bool hasActiveFilters;

  const EvaluationListToolbar({
    super.key,
    this.searchQuery,
    this.onSearchChanged,
    this.onFilterTap,
    this.isGridView = false,
    this.onViewToggle,
    this.onAddNew,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Search and filter row
        Padding(
          padding: AppSpacing.allMD,
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: SearchBarWidget(
                  initialValue: searchQuery,
                  onChanged: onSearchChanged,
                  hintText: 'بحث عن طريق اسم العميل...',
                ),
              ),

              AppSpacing.horizontalSpaceSM,

              // Filter button
              Container(
                decoration: BoxDecoration(
                  color: hasActiveFilters ? AppColors.primary : AppColors.white,
                  borderRadius: AppSpacing.radiusMD,
                  border: Border.all(
                    color:
                        hasActiveFilters ? AppColors.primary : AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasActiveFilters
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                  onPressed: onFilterTap,
                  tooltip: 'فلتر',
                ),
              ),

              AppSpacing.horizontalSpaceSM,

              // View toggle button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppSpacing.radiusMD,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    isGridView ? Icons.view_list : Icons.grid_view,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: onViewToggle,
                  tooltip: isGridView ? 'عرض القائمة' : 'عرض الشبكة',
                ),
              ),
            ],
          ),
        ),

        // Add new button
        if (onAddNew != null)
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: CustomButton.primary(
              text: 'إضافة تقرير جديد',
              onPressed: onAddNew,
              isExpanded: true,
              icon: const Icon(Icons.add, color: AppColors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: AppSpacing.allMD,
      child: Row(
        children: [
          // Search bar
          Expanded(
            flex: 3,
            child: SearchBarWidget(
              initialValue: searchQuery,
              onChanged: onSearchChanged,
              hintText: 'بحث عن طريق اسم العميل...',
            ),
          ),

          AppSpacing.horizontalSpaceMD,

          // Filter button
          Container(
            decoration: BoxDecoration(
              color: hasActiveFilters ? AppColors.primary : AppColors.white,
              borderRadius: AppSpacing.radiusMD,
              border: Border.all(
                color: hasActiveFilters ? AppColors.primary : AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    hasActiveFilters ? AppColors.white : AppColors.textPrimary,
              ),
              onPressed: onFilterTap,
              tooltip: 'فلتر',
            ),
          ),

          AppSpacing.horizontalSpaceSM,

          // View toggle button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppSpacing.radiusMD,
              border: Border.all(
                color: AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: IconButton(
              icon: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color: AppColors.textPrimary,
              ),
              onPressed: onViewToggle,
              tooltip: isGridView ? 'عرض القائمة' : 'عرض الشبكة',
            ),
          ),

          AppSpacing.horizontalSpaceMD,

          // Add new button
          if (onAddNew != null)
            CustomButton.primary(
              text: 'إضافة تقرير جديد',
              onPressed: onAddNew,
              icon: const Icon(Icons.add, color: AppColors.white),
            ),
        ],
      ),
    );
  }
}
