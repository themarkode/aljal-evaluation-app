import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  });

  const LoadingIndicator.small({
    super.key,
    this.color,
  })  : size = 20,
        strokeWidth = 2;

  const LoadingIndicator.large({
    super.key,
    this.color,
  })  : size = 60,
        strokeWidth = 5;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: AppSpacing.allXL,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.radiusLG,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingIndicator(),
                    if (message != null) ...[
                      AppSpacing.verticalSpaceMD,
                      Text(
                        message!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
