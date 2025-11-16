import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Green validation dot indicator for required fields
class ValidationDot extends StatelessWidget {
  final bool isVisible;
  final double size;
  final Color? color;

  const ValidationDot({
    super.key,
    this.isVisible = true,
    this.size = AppConstants.validationDotSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return SizedBox(width: size, height: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.validationDot,
        shape: BoxShape.circle,
      ),
    );
  }
}
