import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';

/// Custom date picker field with validation dot and RTL support
class CustomDatePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final DateTime? value;
  final String? Function(DateTime?)? validator;
  final void Function(DateTime?)? onChanged;
  final void Function(DateTime?)? onSaved;
  final bool enabled;
  final bool showValidationDot;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget? prefixIcon;

  const CustomDatePicker({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.showValidationDot = false,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
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

        // Date picker field
        FormField<DateTime>(
          initialValue: value,
          validator: (val) => validator?.call(val),
          onSaved: onSaved,
          builder: (fieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: enabled
                      ? () async {
                          UIHelpers.hideKeyboard(context);
                          final selectedDate =
                              await UIHelpers.showDatePickerDialog(
                            context,
                            initialDate: value,
                            firstDate: firstDate,
                            lastDate: lastDate,
                          );

                          if (selectedDate != null) {
                            fieldState.didChange(selectedDate);
                            onChanged?.call(selectedDate);
                          }
                        }
                      : null,
                  borderRadius: AppSpacing.radiusMD,
                  child: Container(
                    padding: AppSpacing.fieldPadding,
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.white : AppColors.lightGray,
                      borderRadius: AppSpacing.radiusMD,
                      border: Border.all(
                        color: fieldState.hasError
                            ? AppColors.error
                            : AppColors.border,
                        width: AppSpacing.borderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Prefix icon
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          AppSpacing.horizontalSpaceSM,
                        ],
                        // Date text
                        Expanded(
                          child: Text(
                            value != null
                                ? Formatters.formatDate(value)
                                : hint ?? 'اختر التاريخ',
                            style: value != null
                                ? AppTypography.inputText
                                : AppTypography.placeholder,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        // Calendar icon
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Error text
                if (fieldState.hasError) ...[
                  AppSpacing.verticalSpaceXS,
                  Text(
                    fieldState.errorText!,
                    style: AppTypography.errorText,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
