import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Collapsible section header (blue background with white text)
class SectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final VoidCallback? onTap;
  final bool isCollapsible;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.isCollapsed = false,
    this.onTap,
    this.isCollapsible = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isCollapsible ? onTap : null,
      child: Container(
        padding: AppSpacing.allMD,
        decoration: BoxDecoration(
          color: AppColors.sectionHeader,
          borderRadius: AppSpacing.radiusMD,
        ),
        child: Row(
          children: [
            // Chevron icon (if collapsible)
            if (isCollapsible) ...[
              Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: AppColors.white,
                size: 24,
              ),
              AppSpacing.horizontalSpaceSM,
            ],

            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.sectionHeader,
                textDirection: TextDirection.rtl,
              ),
            ),

            // Trailing widget
            if (trailing != null) ...[
              AppSpacing.horizontalSpaceSM,
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
