import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Empty state widget for lists and screens
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: AppSpacing.allXL,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.midGray,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            // Title
            Text(
              title,
              style: AppTypography.heading,
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              AppSpacing.verticalSpaceSM,
              Text(
                subtitle!,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (action != null) ...[
              AppSpacing.verticalSpaceLG,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
