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
  final VoidCallback? onRestore;

  const EvaluationCard({
    super.key,
    required this.evaluation,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onExport,
    this.onRestore,
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
                    // Header row - Client name and more options
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        
                        const SizedBox(width: 12),
                        // More options button (left edge in RTL)
                        _buildMoreOptionsButton(),
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

                    // Bottom row with date and status badge
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

                        // Status badge
                        _buildStatusBadge(),
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
    final status = evaluation.status ?? 'draft';
    
    // Determine colors and icon based on status
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    
    switch (status) {
      case 'completed':
        badgeColor = AppColors.success;
        badgeIcon = Icons.check_circle_rounded;
        badgeText = 'مكتمل';
        break;
      case 'deleted':
        badgeColor = AppColors.error;
        badgeIcon = Icons.cancel_rounded;
        badgeText = 'محذوف';
        break;
      default: // draft
        badgeColor = AppColors.warning;
        badgeIcon = Icons.pending_rounded;
        badgeText = 'مسودة';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [badgeColor, badgeColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
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

  Widget _buildMoreOptionsButton() {
    final isDeleted = evaluation.status == 'deleted';
    
    return PopupMenuButton<String>(
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
          case 'restore':
            onRestore?.call();
            break;
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: AppColors.cardShadow,
      offset: const Offset(0, 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: AppColors.navy,
        ),
      ),
      itemBuilder: (context) => [
        // Show restore option for deleted items
        if (isDeleted)
          PopupMenuItem<String>(
            value: 'restore',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restore_rounded,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  'استعادة',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        // Edit option (not for deleted items)
        if (!isDeleted)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Text(
                  'تعديل',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        // Export option
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_rounded,
                size: 18,
                color: const Color(0xFF2B579A), // Word blue color
              ),
              const SizedBox(width: 12),
              Text(
                'Word',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF2B579A), // Word blue color
                ),
              ),
            ],
          ),
        ),
        // Delete option - different text for deleted items
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDeleted ? Icons.delete_forever_rounded : Icons.delete_rounded,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              Text(
                isDeleted ? 'حذف نهائي' : 'حذف',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
