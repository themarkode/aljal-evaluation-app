import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/constants/app_constants.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';

/// A reusable AppBar for all form step screens.
/// 
/// This widget provides a consistent header across all 9 form steps with:
/// - Logo on the right (RTL)
/// - Step navigation dropdown in the center
/// - Menu button on the left (RTL)
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: FormStepAppBar(
///     currentStep: 1,
///     evaluationId: widget.evaluationId,
///     onLogoTap: () => _showExitConfirmationDialog(),
///     onSaveToMemory: _saveCurrentDataToState,
///   ),
///   // ...
/// )
/// ```
class FormStepAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The current step number (1-9)
  final int currentStep;

  /// The evaluation ID if editing an existing evaluation
  final String? evaluationId;

  /// Callback when the logo is tapped (usually shows exit confirmation)
  final VoidCallback onLogoTap;

  /// Callback to save current form data to memory before navigation
  final VoidCallback onSaveToMemory;

  /// Callback to validate the form before navigation - returns true if valid
  final bool Function()? validateBeforeNavigation;

  /// Callback when validation fails (to trigger error pulse animation)
  final VoidCallback? onValidationFailed;

  /// Whether the form is in view-only mode
  final bool isViewOnly;

  const FormStepAppBar({
    super.key,
    required this.currentStep,
    this.evaluationId,
    required this.onLogoTap,
    required this.onSaveToMemory,
    this.validateBeforeNavigation,
    this.onValidationFailed,
    this.isViewOnly = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: AppConstants.appBarToolbarHeight,
      leadingWidth: AppConstants.appBarLeadingWidth,
      // Logo on RIGHT (RTL: leading appears on right visually)
      leading: GestureDetector(
        onTap: onLogoTap,
        child: Padding(
          padding: const EdgeInsets.only(right: AppConstants.appBarLogoPaddingRight),
          child: Image.asset(
            'assets/images/Al_Jal_Logo.png',
            width: AppConstants.logoSizeSmall,
            height: AppConstants.logoSizeSmall,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.business_rounded,
                color: AppColors.primary,
                size: AppConstants.logoFallbackIconSmall,
              );
            },
          ),
        ),
      ),
      // Dropdown in CENTER
      title: StepNavigationDropdown(
        currentStep: currentStep,
        evaluationId: evaluationId,
        onSaveToMemory: onSaveToMemory,
        validateBeforeNavigation: validateBeforeNavigation,
        onValidationFailed: onValidationFailed,
        isViewOnly: isViewOnly,
      ),
      // Menu button on LEFT (RTL: actions appears on left visually)
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.appBarMenuPaddingLeft),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: AppConstants.menuButtonSize,
                height: AppConstants.menuButtonSize,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppConstants.menuButtonBorderRadius),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: AppColors.navy,
                  size: AppConstants.menuButtonIconSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

