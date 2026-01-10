import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'اسم العميل',
                controller: controller,
              ),
            ),
          ),
        ),
      );

      expect(find.text('اسم العميل'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'Test Field',
                controller: controller,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      expect(controller.text, 'Test Input');
    });

    testWidgets('shows hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'Test Field',
                controller: controller,
                hint: 'Enter value here',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Enter value here'), findsOneWidget);
    });

    testWidgets('shows validation dot when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'Test Field',
                controller: controller,
                showValidationDot: true,
              ),
            ),
          ),
        ),
      );

      // Look for the validation dot container
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
        findsOneWidget,
      );
    });

    testWidgets('validates with custom validator',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Form(
                key: formKey,
                child: CustomTextField(
                  label: 'Required Field',
                  controller: controller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Validate empty form
      expect(formKey.currentState!.validate(), false);

      // Enter text and validate again
      await tester.enterText(find.byType(TextFormField), 'Some value');
      expect(formKey.currentState!.validate(), true);
    });

    testWidgets('shows required indicator when isRequired is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'Required Field',
                controller: controller,
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      // Should show asterisk for required fields
      expect(find.text(' *'), findsOneWidget);
    });

    testWidgets('can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomTextField(
                label: 'Disabled Field',
                controller: controller,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);
    });
  });
}
