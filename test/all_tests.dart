/// Main test entry point
/// 
/// Run all tests with: flutter test test/all_tests.dart
/// Run with coverage: flutter test --coverage test/all_tests.dart
/// 
/// Test categories:
/// - Unit tests: Business logic, utilities, models
/// - Widget tests: UI components in isolation

// Unit Tests
import 'unit/formatters_test.dart' as formatters_test;
import 'unit/form_field_helpers_test.dart' as form_field_helpers_test;

// Widget Tests
import 'widget/custom_button_test.dart' as custom_button_test;
import 'widget/custom_text_field_test.dart' as custom_text_field_test;
import 'widget/loading_indicator_test.dart' as loading_indicator_test;
import 'widget/empty_state_test.dart' as empty_state_test;

void main() {
  // Unit Tests
  formatters_test.main();
  form_field_helpers_test.main();

  // Widget Tests
  custom_button_test.main();
  custom_text_field_test.main();
  loading_indicator_test.main();
  empty_state_test.main();
}

