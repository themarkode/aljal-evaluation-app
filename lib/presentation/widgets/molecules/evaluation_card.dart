import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/evaluation_model.dart';

/// Beautiful modern card widget for displaying evaluation
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top colored strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Client icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.navy.withOpacity(0.1),
                                AppColors.navyLight.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.navy,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Client name and info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evaluation.generalInfo?.clientName ?? 'بدون اسم',
                                style: AppTypography.cardTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                evaluation.generalInfo?.requestorName ?? 'بدون جهة طالبة',
                                style: AppTypography.cardSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        
                        // Status badge
                        _buildStatusBadge(),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info row with property details
                    if (_hasPropertyInfo) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            // Location
                            if (evaluation.generalPropertyInfo?.governorate != null)
                              _buildInfoChip(
                                Icons.location_on_rounded,
                                evaluation.generalPropertyInfo!.governorate!,
                              ),
                            
                            if (evaluation.generalPropertyInfo?.plotNumber != null) ...[
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                Icons.grid_view_rounded,
                                'قطعة ${evaluation.generalPropertyInfo!.plotNumber}',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bottom row with date and actions
                    Row(
                      children: [
                        // Date
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          evaluation.updatedAt != null
                              ? Formatters.formatDate(evaluation.updatedAt)
                              : '-',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Action buttons
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: AppColors.navy,
                          onTap: onEdit,
                          tooltip: 'تعديل',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.description_rounded,
                          color: AppColors.success,
                          onTap: onExport,
                          tooltip: 'مستند Word',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: AppColors.error,
                          onTap: onDelete,
                          tooltip: 'حذف',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasPropertyInfo =>
      evaluation.generalPropertyInfo?.governorate != null ||
      evaluation.generalPropertyInfo?.plotNumber != null;

  Widget _buildStatusBadge() {
    final isComplete = evaluation.status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: isComplete
            ? AppColors.successGradient
            : LinearGradient(colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? AppColors.success : AppColors.warning).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isComplete ? 'مكتمل' : 'مسودة',
            style: AppTypography.badge,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
