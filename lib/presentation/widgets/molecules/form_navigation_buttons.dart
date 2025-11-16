import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../atoms/custom_button.dart';
import '../../shared/responsive/responsive_builder.dart';

/// Form navigation buttons (Previous, Next, Save)
class FormNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final bool showPrevious;
  final bool showNext;
  final bool showSave;
  final bool isLoading;
  final String? previousText;
  final String? nextText;
  final String? saveText;

  const FormNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.onSave,
    this.showPrevious = true,
    this.showNext = true,
    this.showSave = false,
    this.isLoading = false,
    this.previousText,
    this.nextText,
    this.saveText,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        // Mobile: Stack buttons vertically
        if (deviceType == DeviceType.mobile) {
          return _buildMobileLayout();
        }

        // Tablet & Desktop: Row layout
        return _buildDesktopLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Next/Save button
        if (showNext && onNext != null)
          CustomButton.primary(
            text: nextText ?? AppConstants.buttonNext,
            onPressed: onNext,
            isLoading: isLoading,
            isExpanded: true,
          ),

        if (showSave && onSave != null)
          CustomButton.secondary(
            text: saveText ?? AppConstants.buttonSave,
            onPressed: onSave,
            isLoading: isLoading,
            isExpanded: true,
          ),

        // Spacing
        if ((showNext || showSave) && showPrevious && onPrevious != null)
          AppSpacing.verticalSpaceSM,

        // Previous button
        if (showPrevious && onPrevious != null)
          CustomButton.text(
            text: previousText ?? AppConstants.buttonPrevious,
            onPressed: onPrevious,
            isExpanded: true,
          ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button (left side in RTL = right side visually)
        if (showPrevious && onPrevious != null)
          CustomButton.text(
            text: previousText ?? AppConstants.buttonPrevious,
            onPressed: onPrevious,
          )
        else
          const SizedBox.shrink(),

        // Next/Save buttons (right side in RTL = left side visually)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSave && onSave != null) ...[
              CustomButton.secondary(
                text: saveText ?? AppConstants.buttonSave,
                onPressed: onSave,
                isLoading: isLoading,
              ),
              AppSpacing.horizontalSpaceSM,
            ],
            if (showNext && onNext != null)
              CustomButton.primary(
                text: nextText ?? AppConstants.buttonNext,
                onPressed: onNext,
                isLoading: isLoading,
              ),
          ],
        ),
      ],
    );
  }
}
