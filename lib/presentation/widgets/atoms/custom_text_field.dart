import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Custom text field with validation dot and RTL support
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool showValidationDot;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.showValidationDot = false,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.onTap,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
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
        
        // Text field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          onSaved: onSaved,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: autovalidateMode,
          textCapitalization: textCapitalization,
          textDirection: TextDirection.rtl,
          style: AppTypography.inputText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.placeholder,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
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
        ),
      ],
    );
  }
}