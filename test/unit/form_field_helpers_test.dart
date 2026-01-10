import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljal_evaluation/core/utils/form_field_helpers.dart';

void main() {
  group('FormFieldHelpers', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('textOrNull', () {
      test('returns trimmed text when not empty', () {
        controller.text = '  Hello World  ';
        expect(controller.textOrNull, 'Hello World');
      });

      test('returns null when empty', () {
        controller.text = '';
        expect(controller.textOrNull, null);
      });

      test('returns null when only whitespace', () {
        controller.text = '   ';
        expect(controller.textOrNull, null);
      });
    });

    group('intOrNull', () {
      test('returns parsed int when valid', () {
        controller.text = '  123  ';
        expect(controller.intOrNull, 123);
      });

      test('returns null when empty', () {
        controller.text = '';
        expect(controller.intOrNull, null);
      });

      test('returns null when invalid number', () {
        controller.text = 'abc';
        expect(controller.intOrNull, null);
      });

      test('returns null when decimal number', () {
        controller.text = '123.45';
        expect(controller.intOrNull, null);
      });

      test('handles negative numbers', () {
        controller.text = '-42';
        expect(controller.intOrNull, -42);
      });
    });

    group('doubleOrNull', () {
      test('returns parsed double when valid', () {
        controller.text = '  123.45  ';
        expect(controller.doubleOrNull, 123.45);
      });

      test('returns null when empty', () {
        controller.text = '';
        expect(controller.doubleOrNull, null);
      });

      test('returns null when invalid number', () {
        controller.text = 'abc';
        expect(controller.doubleOrNull, null);
      });

      test('handles integers', () {
        controller.text = '123';
        expect(controller.doubleOrNull, 123.0);
      });

      test('handles negative numbers', () {
        controller.text = '-42.5';
        expect(controller.doubleOrNull, -42.5);
      });
    });

    group('textOrDefault', () {
      test('returns text when not empty', () {
        controller.text = 'Hello';
        expect(controller.textOrDefault('Default'), 'Hello');
      });

      test('returns default when empty', () {
        controller.text = '';
        expect(controller.textOrDefault('Default'), 'Default');
      });

      test('returns default when whitespace only', () {
        controller.text = '   ';
        expect(controller.textOrDefault('Default'), 'Default');
      });
    });

    group('intOrDefault', () {
      test('returns parsed int when valid', () {
        controller.text = '42';
        expect(controller.intOrDefault(0), 42);
      });

      test('returns default when empty', () {
        controller.text = '';
        expect(controller.intOrDefault(0), 0);
      });

      test('returns default when invalid', () {
        controller.text = 'abc';
        expect(controller.intOrDefault(-1), -1);
      });
    });

    group('doubleOrDefault', () {
      test('returns parsed double when valid', () {
        controller.text = '42.5';
        expect(controller.doubleOrDefault(0.0), 42.5);
      });

      test('returns default when empty', () {
        controller.text = '';
        expect(controller.doubleOrDefault(0.0), 0.0);
      });

      test('returns default when invalid', () {
        controller.text = 'abc';
        expect(controller.doubleOrDefault(-1.0), -1.0);
      });
    });
  });
}

