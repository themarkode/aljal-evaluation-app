import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Custom dropdown field with validation dot and RTL support
class CustomDropdown extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? value;
  final List<String> items;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;
  final bool showValidationDot;
  final bool isRequired;
  final Widget? prefixIcon;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.showValidationDot = false,
    this.isRequired = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with validation dot
        if (label != null) ...[
          Row(
            children: [
              // Validation dot
              if (showValidationDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.validationDot,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalSpaceXS,
              ],
              // Label text
              Expanded(
                child: Text(
                  label!,
                  style: AppTypography.fieldTitle,
                ),
              ),
              // Required indicator
              if (isRequired)
                Text(
                  ' *',
                  style: AppTypography.fieldTitle.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSpaceXS,
        ],

        // Dropdown field
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                item,
                style: AppTypography.dropdownOptions,
                textDirection: TextDirection.rtl,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          onSaved: onSaved,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.placeholder,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.lightGray,
            contentPadding: AppSpacing.fieldPadding,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: AppSpacing.borderWidthThick,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppSpacing.borderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppSpacing.borderWidthThick,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.radiusMD,
              borderSide: BorderSide(
                color: AppColors.midGray,
                width: AppSpacing.borderWidth,
              ),
            ),
          ),
          style: AppTypography.dropdownOptions,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
          ),
          isExpanded: true,
          dropdownColor: AppColors.white,
          borderRadius: AppSpacing.radiusMD,
          alignment: AlignmentDirectional.centerEnd,
        ),
      ],
    );
  }
}
