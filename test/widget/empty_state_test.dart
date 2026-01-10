import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders with title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'لا توجد تقارير',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد تقارير'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders with subtitle when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'لا توجد تقارير',
              subtitle: 'ابدأ بإنشاء تقرير جديد',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد تقارير'), findsOneWidget);
      expect(find.text('ابدأ بإنشاء تقرير جديد'), findsOneWidget);
    });

    testWidgets('renders action widget when provided',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              action: ElevatedButton(
                onPressed: () {
                  wasPressed = true;
                },
                child: const Text('Add New'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add New'), findsOneWidget);

      await tester.tap(find.text('Add New'));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('centers content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search,
              title: 'No Results',
            ),
          ),
        ),
      );

      // EmptyState wraps content in Center
      expect(find.byType(Center), findsWidgets);
    });
  });
}
