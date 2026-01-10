import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/confirmation_dialog.dart';

/// A mixin that provides common functionality for all step screens.
/// 
/// This mixin handles:
/// - App lifecycle management (auto-save when app goes to background)
/// - Exit confirmation dialog
/// - Common navigation patterns
/// - Centralized error blink animation trigger
/// 
/// Usage:
/// ```dart
/// class _Step1GeneralInfoScreenState extends ConsumerState<Step1GeneralInfoScreen>
///     with WidgetsBindingObserver, StepScreenMixin {
///   
///   @override
///   void saveCurrentDataToState() {
///     // Implement your step-specific save logic
///   }
///   
///   @override
///   void initState() {
///     super.initState();
///     initStepScreen(); // Initialize the mixin
///   }
///   
///   @override
///   void dispose() {
///     disposeStepScreen(); // Clean up the mixin
///     super.dispose();
///   }
///   
///   // Use errorBlinkTrigger with CustomTextField:
///   CustomTextField(
///     controller: myController,
///     errorBlinkTrigger: errorBlinkTrigger, // From mixin
///   )
/// }
/// ```
mixin StepScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T>, WidgetsBindingObserver {
  
  /// Override this method to save current form data to state.
  /// This is called when auto-saving or before navigation.
  void saveCurrentDataToState();

  /// Notifier to trigger error blink animation on all fields.
  /// Increment the value to trigger a blink animation on all listening fields.
  /// 
  /// Usage: Pass this to CustomTextField's errorBlinkTrigger parameter.
  final ValueNotifier<int> errorBlinkTrigger = ValueNotifier<int>(0);

  /// Triggers the error blink animation on all fields listening to errorBlinkTrigger.
  /// Call this when validation fails to draw attention to error messages.
  void triggerErrorBlink() {
    errorBlinkTrigger.value++;
  }

  /// Initialize the step screen mixin.
  /// Call this in your initState() method.
  void initStepScreen() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dispose the step screen mixin.
  /// Call this in your dispose() method.
  void disposeStepScreen() {
    WidgetsBinding.instance.removeObserver(this);
    errorBlinkTrigger.dispose();
  }

  /// Handles app lifecycle changes for auto-saving.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Auto-save when app goes to background or is about to be closed
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      autoSaveOnBackground();
    }
  }

  /// Auto-saves the current form data when app goes to background.
  Future<void> autoSaveOnBackground() async {
    saveCurrentDataToState();
    await ref.read(evaluationNotifierProvider.notifier).saveAsDraft();
  }

  /// Shows exit confirmation dialog when trying to leave the form.
  /// 
  /// Returns the result of the dialog:
  /// - 'primary' if user chose to save
  /// - 'secondary' if user chose to discard
  /// - null if user dismissed the dialog
  Future<void> showExitConfirmationDialog() async {
    final result = await ConfirmationDialog.show(
      context: context,
      title: 'تنبيه',
      message: 'هل تريد حفظ التغييرات قبل المغادرة؟',
      primaryButtonText: 'حفظ',
      secondaryButtonText: 'تجاهل',
    );

    if (result == 'primary') {
      // Save and exit
      saveCurrentDataToState();
      await ref.read(evaluationNotifierProvider.notifier).saveAsDraft();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.evaluationList,
          (route) => false,
        );
      }
    } else if (result == 'secondary') {
      // Discard and exit
      ref.read(evaluationNotifierProvider.notifier).resetEvaluation();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.evaluationList,
          (route) => false,
        );
      }
    }
    // If null (dismissed via X), do nothing - stay on current screen
  }
}

