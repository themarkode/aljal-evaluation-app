import 'package:flutter_test/flutter_test.dart';
import 'package:aljal_evaluation/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('Date Formatters', () {
      test('formatDate returns formatted date string', () {
        final date = DateTime(2024, 3, 15);
        expect(Formatters.formatDate(date), '15/03/2024');
      });

      test('formatDate returns empty string for null', () {
        expect(Formatters.formatDate(null), '');
      });

      test('formatDateTime returns date and time', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        expect(Formatters.formatDateTime(date), '15/03/2024 14:30');
      });

      test('formatTime returns only time', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        expect(Formatters.formatTime(date), '14:30');
      });

      test('parseDate parses valid date string', () {
        final result = Formatters.parseDate('15/03/2024');
        expect(result?.day, 15);
        expect(result?.month, 3);
        expect(result?.year, 2024);
      });

      test('parseDate returns null for invalid string', () {
        expect(Formatters.parseDate('invalid'), null);
        expect(Formatters.parseDate(''), null);
        expect(Formatters.parseDate(null), null);
      });

      test('formatRelativeDate returns "الآن" for recent times', () {
        final now = DateTime.now();
        expect(Formatters.formatRelativeDate(now), 'الآن');
      });

      test('formatRelativeDate returns "منذ دقيقة" for 1 minute ago', () {
        final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
        expect(Formatters.formatRelativeDate(oneMinuteAgo), 'منذ دقيقة');
      });

      test('formatRelativeDate returns "منذ ساعة" for 1 hour ago', () {
        final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
        expect(Formatters.formatRelativeDate(oneHourAgo), 'منذ ساعة');
      });

      test('formatRelativeDate returns "منذ يوم" for 1 day ago', () {
        final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
        expect(Formatters.formatRelativeDate(oneDayAgo), 'منذ يوم');
      });
    });

    group('Number Formatters', () {
      test('formatNumber formats with commas and decimals', () {
        expect(Formatters.formatNumber(1234567.89), '1,234,567.89');
        expect(Formatters.formatNumber(1234567.89, decimals: 3), '1,234,567.890');
      });

      test('formatNumber returns empty string for null', () {
        expect(Formatters.formatNumber(null), '');
      });

      test('formatInteger formats without decimals', () {
        expect(Formatters.formatInteger(1234567), '1,234,567');
        expect(Formatters.formatInteger(1234567.89), '1,234,568');
      });

      test('formatPercentage adds percent sign', () {
        expect(Formatters.formatPercentage(85.5), '85.5%');
        expect(Formatters.formatPercentage(100), '100.0%');
      });

      test('formatArea adds م² suffix', () {
        expect(Formatters.formatArea(1234.56), '1,234.56 م²');
      });

      test('parseNumber removes commas and parses', () {
        expect(Formatters.parseNumber('1,234,567.89'), 1234567.89);
        expect(Formatters.parseNumber('1234'), 1234.0);
        expect(Formatters.parseNumber('invalid'), null);
        expect(Formatters.parseNumber(null), null);
      });
    });

    group('Currency Formatters', () {
      test('formatCurrency formats with KWD suffix', () {
        expect(Formatters.formatCurrency(1234.567), '1,234.567 د.ك');
      });

      test('formatCurrencyValue formats without suffix', () {
        expect(Formatters.formatCurrencyValue(1234.567), '1,234.567');
      });
    });

    group('Phone Number Formatters', () {
      test('formatKuwaitPhone formats 8-digit number', () {
        expect(Formatters.formatKuwaitPhone('12345678'), '+965 1234 5678');
      });

      test('formatKuwaitPhone handles number with country code', () {
        expect(Formatters.formatKuwaitPhone('96512345678'), '+965 1234 5678');
      });

      test('formatPhoneDisplay formats without country code', () {
        expect(Formatters.formatPhoneDisplay('12345678'), '1234 5678');
        expect(Formatters.formatPhoneDisplay('96512345678'), '1234 5678');
      });

      test('cleanPhoneNumber removes formatting', () {
        expect(Formatters.cleanPhoneNumber('+965 1234 5678'), '12345678');
        expect(Formatters.cleanPhoneNumber('96512345678'), '12345678');
      });
    });

    group('Text Formatters', () {
      test('truncate shortens text with ellipsis', () {
        expect(Formatters.truncate('Hello World', 5), 'Hello...');
        expect(Formatters.truncate('Hi', 5), 'Hi');
        expect(Formatters.truncate(null, 5), '');
      });

      test('capitalize capitalizes first letter', () {
        expect(Formatters.capitalize('hello'), 'Hello');
        expect(Formatters.capitalize('HELLO'), 'HELLO');
        expect(Formatters.capitalize(''), '');
      });

      test('toTitleCase capitalizes each word', () {
        expect(Formatters.toTitleCase('hello world'), 'Hello World');
      });
    });

    group('File Size Formatters', () {
      test('formatFileSize formats bytes correctly', () {
        expect(Formatters.formatFileSize(500), '500 B');
        expect(Formatters.formatFileSize(1024), '1.0 KB');
        expect(Formatters.formatFileSize(1024 * 1024), '1.0 MB');
        expect(Formatters.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
      });
    });

    group('Arabic Number Formatters', () {
      test('toArabicDigits converts English to Arabic', () {
        expect(Formatters.toArabicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
        expect(Formatters.toArabicDigits('Phone: 12345'), 'Phone: ١٢٣٤٥');
      });

      test('toEnglishDigits converts Arabic to English', () {
        expect(Formatters.toEnglishDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
        expect(Formatters.toEnglishDigits('هاتف: ١٢٣٤٥'), 'هاتف: 12345');
      });
    });
  });
}

