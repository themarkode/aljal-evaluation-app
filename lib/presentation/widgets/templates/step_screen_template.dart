import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/app_drawer.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/form_step_app_bar.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';

/// A template widget for all form step screens.
/// 
/// This template provides the common structure for all 9 step screens:
/// - RTL Directionality
/// - Scaffold with background color
/// - AppDrawer
/// - FormStepAppBar
/// - SafeArea with Form
/// - Scrollable content area
/// - FormNavigationButtons at the bottom
/// 
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return StepScreenTemplate(
///     currentStep: 1,
///     evaluationId: widget.evaluationId,
///     formKey: _formKey,
///     onNext: _saveAndContinue,
///     onPrevious: _cancel,
///     onLogoTap: showExitConfirmationDialog,
///     onSaveToMemory: saveCurrentDataToState,
///     mobileContent: _buildMobileLayout(),
///     tabletContent: _buildTabletLayout(),
///   );
/// }
/// ```
class StepScreenTemplate extends StatelessWidget {
  /// The current step number (1-9)
  final int currentStep;

  /// The evaluation ID if editing an existing evaluation
  final String? evaluationId;

  /// The form key for validation
  final GlobalKey<FormState> formKey;

  /// Callback for the "Next" button
  final VoidCallback onNext;

  /// Callback for the "Previous" button
  final VoidCallback onPrevious;

  /// Callback when the logo is tapped (usually shows exit confirmation)
  final VoidCallback onLogoTap;

  /// Callback to save current form data to memory before navigation
  final VoidCallback onSaveToMemory;

  /// Content to display on mobile devices
  final Widget mobileContent;

  /// Content to display on tablet devices (defaults to mobileContent if not provided)
  final Widget? tabletContent;

  /// Content to display on desktop devices (defaults to tabletContent if not provided)
  final Widget? desktopContent;

  /// Optional custom navigation buttons widget
  final Widget? customNavigationButtons;

  /// Whether to show the form navigation buttons (default: true)
  final bool showNavigationButtons;

  /// Callback to validate the form before navigation - returns true if valid
  final bool Function()? validateBeforeNavigation;

  /// Callback when validation fails (to trigger error pulse animation)
  final VoidCallback? onValidationFailed;

  const StepScreenTemplate({
    super.key,
    required this.currentStep,
    this.evaluationId,
    required this.formKey,
    required this.onNext,
    required this.onPrevious,
    required this.onLogoTap,
    required this.onSaveToMemory,
    required this.mobileContent,
    this.tabletContent,
    this.desktopContent,
    this.customNavigationButtons,
    this.showNavigationButtons = true,
    this.validateBeforeNavigation,
    this.onValidationFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(),
        appBar: FormStepAppBar(
          currentStep: currentStep,
          evaluationId: evaluationId,
          onLogoTap: onLogoTap,
          onSaveToMemory: onSaveToMemory,
          validateBeforeNavigation: validateBeforeNavigation,
          onValidationFailed: onValidationFailed,
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingMobileInsets,
                    child: ResponsiveBuilder(
                      builder: (context, deviceType) {
                        switch (deviceType) {
                          case DeviceType.mobile:
                            return mobileContent;
                          case DeviceType.tablet:
                            return tabletContent ?? mobileContent;
                          case DeviceType.desktop:
                            return desktopContent ?? tabletContent ?? mobileContent;
                        }
                      },
                    ),
                  ),
                ),
                // Navigation buttons
                if (showNavigationButtons)
                  customNavigationButtons ??
                      FormNavigationButtons(
                        currentStep: currentStep,
                        onNext: onNext,
                        onPrevious: onPrevious,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

