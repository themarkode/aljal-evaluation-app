import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Button type enum
enum ButtonType {
  primary,
  secondary,
  text,
  danger,
}

/// Custom button with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
  });

  /// Primary button (blue background)
  const CustomButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.primary;

  /// Secondary button (green background)
  const CustomButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.secondary;

  /// Text button (no background)
  const CustomButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.text;

  /// Danger button (red background)
  const CustomButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                AppSpacing.horizontalSpaceXS,
              ],
              Text(
                text,
                style: AppTypography.buttonText,
              ),
            ],
          );

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.white,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusMD,
            ),
            elevation: 0,
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successButton,
            foregroundColor: AppColors.white,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusMD,
            ),
            elevation: 0,
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deleteButton,
            foregroundColor: AppColors.white,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusMD,
            ),
            elevation: 0,
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusMD,
            ),
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          child: buttonChild,
        );
        break;
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
