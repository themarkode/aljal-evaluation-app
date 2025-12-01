import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';

/// Search bar widget with clear button
class SearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final String? hintText;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      textDirection: TextDirection.rtl,
      style: AppTypography.inputText,
      decoration: InputDecoration(
        hintText: widget.hintText ?? AppConstants.placeholderSearch,
        hintStyle: AppTypography.placeholder,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                ),
                onPressed: _handleClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
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
      ),
    );
  }
}
