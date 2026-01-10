import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Custom text field with validation dot, RTL support, and error blink animation
class CustomTextField extends StatefulWidget {
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
  /// Notifier to trigger error blink animation. Increment value to trigger blink.
  /// Use the errorBlinkTrigger from StepScreenMixin for centralized control.
  final ValueNotifier<int>? errorBlinkTrigger;

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
    this.errorBlinkTrigger,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Listen to blink trigger from mixin
    widget.errorBlinkTrigger?.addListener(_onBlinkTrigger);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorBlinkTrigger != oldWidget.errorBlinkTrigger) {
      oldWidget.errorBlinkTrigger?.removeListener(_onBlinkTrigger);
      widget.errorBlinkTrigger?.addListener(_onBlinkTrigger);
    }
  }

  @override
  void dispose() {
    widget.errorBlinkTrigger?.removeListener(_onBlinkTrigger);
    _blinkController.dispose();
    super.dispose();
  }

  void _onBlinkTrigger() {
    // Only blink if field has error
    if (_currentError != null && _currentError!.isNotEmpty) {
      _triggerBlink();
    }
  }

  void _triggerBlink() async {
    // Blink 3 times quickly (on-off-on-off-on-off)
    for (int i = 0; i < 3; i++) {
      await _blinkController.forward();
      await _blinkController.reverse();
    }
  }

  String? _validate(String? value) {
    final error = widget.validator?.call(value);
    // Update current error for blink check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentError = error;
        });
      }
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with validation dot
        if (widget.label != null) ...[
          Row(
            children: [
              // Label text (appears on RIGHT in RTL)
              Text(
                widget.label!,
                style: AppTypography.fieldTitle,
              ),
              // Required indicator
              if (widget.isRequired)
                Text(
                  ' *',
                  style: AppTypography.fieldTitle.copyWith(
                    color: AppColors.error,
                  ),
                ),
              // Spacer to push dot to the left in RTL
              const Spacer(),
              // Validation dot (appears on LEFT in RTL)
              if (widget.showValidationDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.validationDot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 22.5), // Space from left edge in RTL
              ],
            ],
          ),
          AppSpacing.verticalSpaceXS,
        ],

        // Text field
        AnimatedBuilder(
          animation: _blinkAnimation,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              initialValue: widget.initialValue,
              validator: _validate,
              onChanged: widget.onChanged,
              onSaved: widget.onSaved,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              inputFormatters: widget.inputFormatters,
              focusNode: widget.focusNode,
              onTap: widget.onTap,
              onFieldSubmitted: widget.onFieldSubmitted,
              autovalidateMode: widget.autovalidateMode,
              textCapitalization: widget.textCapitalization,
              textDirection: TextDirection.rtl,
              style: AppTypography.inputText,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.placeholder,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor:
                    widget.enabled ? AppColors.white : AppColors.lightGray,
                contentPadding: AppSpacing.fieldPadding,
                // Animated error style - opacity changes during blink
                errorStyle: TextStyle(
                  color: AppColors.error.withOpacity(_blinkAnimation.value),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
            );
          },
        ),
      ],
    );
  }
}
