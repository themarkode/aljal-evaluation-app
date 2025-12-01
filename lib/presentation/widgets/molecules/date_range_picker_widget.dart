import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../atoms/custom_button.dart';

/// Date range picker widget for filtering
class DateRangePickerWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? startDate, DateTime? endDate)?
      onDateRangeSelected;
  final VoidCallback? onClear;

  const DateRangePickerWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.onDateRangeSelected,
    this.onClear,
  });

  @override
  State<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _selectStartDate() async {
    final date = await UIHelpers.showDatePickerDialog(
      context,
      initialDate: _startDate,
      lastDate: _endDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await UIHelpers.showDatePickerDialog(
      context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _handleApply() {
    widget.onDateRangeSelected?.call(_startDate, _endDate);
  }

  void _handleClear() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: AppSpacing.allLG,
          child: Text(
            'تحديد الفترة الزمنية',
            style: AppTypography.heading,
            textDirection: TextDirection.rtl,
          ),
        ),

        const Divider(height: 1),

        Padding(
          padding: AppSpacing.allLG,
          child: Column(
            children: [
              // Start date
              InkWell(
                onTap: _selectStartDate,
                borderRadius: AppSpacing.radiusMD,
                child: Container(
                  padding: AppSpacing.fieldPadding,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppSpacing.radiusMD,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppSpacing.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      AppSpacing.horizontalSpaceSM,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'من تاريخ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _startDate != null
                                  ? Formatters.formatDate(_startDate)
                                  : 'اختر التاريخ',
                              style: _startDate != null
                                  ? AppTypography.dropdownOptions
                                  : AppTypography.placeholder,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.verticalSpaceMD,

              // End date
              InkWell(
                onTap: _selectEndDate,
                borderRadius: AppSpacing.radiusMD,
                child: Container(
                  padding: AppSpacing.fieldPadding,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppSpacing.radiusMD,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppSpacing.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      AppSpacing.horizontalSpaceSM,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إلى تاريخ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _endDate != null
                                  ? Formatters.formatDate(_endDate)
                                  : 'اختر التاريخ',
                              style: _endDate != null
                                  ? AppTypography.dropdownOptions
                                  : AppTypography.placeholder,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.verticalSpaceXL,

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton.text(
                      text: 'مسح',
                      onPressed: _handleClear,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Expanded(
                    child: CustomButton.primary(
                      text: 'تطبيق',
                      onPressed: _handleApply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
