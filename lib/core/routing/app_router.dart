import 'package:flutter/material.dart';
import 'route_names.dart';
import 'route_arguments.dart';

// Import screens
import 'package:aljal_evaluation/presentation/screens/evaluation/evaluation_list_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step1_general_info_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step2_general_property_info_screen.dart';
// TODO: Import Step3PropertyDescriptionScreen once it's created with correct class name
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step4_floors_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step5_area_details_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step6_income_notes_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step7_site_plans_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step8_property_images_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/steps/step9_additional_data_screen.dart';
import 'package:aljal_evaluation/presentation/screens/evaluation/view_evaluation_screen.dart';

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
          const EvaluationListScreen(),
          settings: settings,
        );

      case RouteNames.newEvaluation:
        // New evaluation starts at step 1
        return _buildRoute(
          Step1GeneralInfoScreen(evaluationId: null),
          settings: settings,
        );

      case RouteNames.editEvaluation:
        if (arguments is EvaluationArguments) {
          // Edit evaluation starts at step 1
          return _buildRoute(
            Step1GeneralInfoScreen(evaluationId: arguments.evaluationId),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case RouteNames.viewEvaluation:
        if (arguments is EvaluationArguments) {
          return _buildRoute(
            ViewEvaluationScreen(evaluationId: arguments.evaluationId),
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
    // Extract evaluation ID from arguments
    final formArgs = arguments is FormStepArguments
        ? arguments
        : FormStepArguments.forStep(step: step);

    final evaluationId = formArgs.evaluationId;

    // Return appropriate step screen
    Widget screen;
    switch (step) {
      case 1:
        screen = Step1GeneralInfoScreen(evaluationId: evaluationId);
        break;
      case 2:
        screen = Step2GeneralPropertyInfoScreen(evaluationId: evaluationId);
        break;
      case 3:
        // TODO: Step3 file currently has wrong class name - routing to Step 4 temporarily
        // Once Step3PropertyDescriptionScreen is created, replace this
        screen = Step4FloorsScreen(evaluationId: evaluationId);
        break;
      case 4:
        screen = Step4FloorsScreen(evaluationId: evaluationId);
        break;
      case 5:
        screen = Step5AreaDetailsScreen(evaluationId: evaluationId);
        break;
      case 6:
        screen = Step6IncomeNotesScreen(evaluationId: evaluationId);
        break;
      case 7:
        screen = Step7SitePlansScreen(evaluationId: evaluationId);
        break;
      case 8:
        screen = Step8PropertyImagesScreen(evaluationId: evaluationId);
        break;
      case 9:
        screen = Step9AdditionalDataScreen(evaluationId: evaluationId);
        break;
      default:
        screen = Step1GeneralInfoScreen(evaluationId: evaluationId);
    }

    return _buildRoute(screen, settings: settings);
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
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
          backgroundColor: Colors.red,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.initial,
                    (route) => false,
                  );
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
