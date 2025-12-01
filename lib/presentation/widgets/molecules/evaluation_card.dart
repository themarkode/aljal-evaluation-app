import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/evaluation_model.dart';

/// Card widget for displaying evaluation in list/grid view
class EvaluationCard extends StatelessWidget {
  final EvaluationModel evaluation;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const EvaluationCard({
    super.key,
    required this.evaluation,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMD,
        child: Padding(
          padding: AppSpacing.cardPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with client name and more actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      evaluation.generalInfo?.clientName ?? 'بدون اسم',
                      style: AppTypography.fieldTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  // More actions button
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'export':
                          onExport?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.file_download, size: 20),
                            SizedBox(width: 8),
                            Text('مستند Word'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('حذف',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpacing.verticalSpaceXS,

              // Governorate and property type info
              if (evaluation.generalPropertyInfo?.governorate != null ||
                  evaluation.generalPropertyInfo?.propertyType != null) ...[
                Text(
                  [
                    if (evaluation.generalPropertyInfo?.governorate != null)
                      evaluation.generalPropertyInfo!.governorate!,
                    if (evaluation.generalPropertyInfo?.propertyType != null)
                      evaluation.generalPropertyInfo!.propertyType!,
                  ].join(' - '),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
                AppSpacing.verticalSpaceSM,
              ],

              // Divider
              const Divider(height: 1),

              AppSpacing.verticalSpaceSM,

              // Metadata row
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        AppSpacing.horizontalSpaceXS,
                        Expanded(
                          child: Text(
                            evaluation.updatedAt != null
                                ? Formatters.formatDate(evaluation.updatedAt)
                                : '-',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Plot number badge (if available)
                  if (evaluation.generalPropertyInfo?.plotNumber != null) ...[
                    AppSpacing.horizontalSpaceSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'قطعة ${evaluation.generalPropertyInfo!.plotNumber}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
