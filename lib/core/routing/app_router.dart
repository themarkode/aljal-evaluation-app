import 'package:flutter/material.dart';
import 'route_names.dart';
import 'route_arguments.dart';

/// App router - handles all route generation
class AppRouter {
  AppRouter._();

  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    switch (routeName) {
      // ========================================
      // MAIN ROUTES
      // ========================================
      
      case RouteNames.initial:
      case RouteNames.evaluationList:
        return _buildRoute(
          const Placeholder(), // TODO: Replace with EvaluationListScreen
          settings: settings,
        );

      case RouteNames.newEvaluation:
        return _buildRoute(
          const Placeholder(), // TODO: Replace with NewEvaluationScreen
          settings: settings,
        );

      case RouteNames.editEvaluation:
        if (arguments is EvaluationArguments) {
          return _buildRoute(
            const Placeholder(), // TODO: Replace with EditEvaluationScreen
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case RouteNames.viewEvaluation:
        if (arguments is EvaluationArguments) {
          return _buildRoute(
            const Placeholder(), // TODO: Replace with ViewEvaluationScreen
            settings: settings,
          );
        }
        return _errorRoute(settings);

      // ========================================
      // FORM STEP ROUTES
      // ========================================

      case RouteNames.formStep1:
        return _buildFormStepRoute(
          step: 1,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep2:
        return _buildFormStepRoute(
          step: 2,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep3:
        return _buildFormStepRoute(
          step: 3,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep4:
        return _buildFormStepRoute(
          step: 4,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep5:
        return _buildFormStepRoute(
          step: 5,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep6:
        return _buildFormStepRoute(
          step: 6,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep7:
        return _buildFormStepRoute(
          step: 7,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep8:
        return _buildFormStepRoute(
          step: 8,
          arguments: arguments,
          settings: settings,
        );

      case RouteNames.formStep9:
        return _buildFormStepRoute(
          step: 9,
          arguments: arguments,
          settings: settings,
        );

      // ========================================
      // ERROR ROUTE
      // ========================================

      default:
        return _errorRoute(settings);
    }
  }

  /// Build form step route
  static Route<dynamic> _buildFormStepRoute({
    required int step,
    required Object? arguments,
    required RouteSettings settings,
  }) {
    // Create default arguments if not provided
    final formArgs = arguments is FormStepArguments
        ? arguments
        : FormStepArguments.forStep(step: step);

    return _buildRoute(
      const Placeholder(), // TODO: Replace with FormStepScreen
      settings: settings,
    );
  }

  /// Build standard material page route
  static Route<dynamic> _buildRoute(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Build error route
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'الصفحة غير موجودة',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'المسار: ${settings.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate back or to home
                  Navigator.of(_).pushReplacementNamed(RouteNames.initial);
                },
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }

  /// Navigate to route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future<T?> navigateToAndReplace<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, Object?>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateToAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {Object? result}) {
    Navigator.of(context).pop(result);
  }

  /// Can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}