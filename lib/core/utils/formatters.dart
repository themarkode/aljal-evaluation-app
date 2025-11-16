import 'package:intl/intl.dart';

/// Formatters for dates, numbers, phone numbers, and currency
class Formatters {
  Formatters._();

  // ============================================================
  // DATE FORMATTERS
  // ============================================================

  /// Format date as dd/MM/yyyy
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date as dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Format date as dd MMMM yyyy (e.g., 15 مارس 2024)
  static String formatDateLong(DateTime? date, {String locale = 'ar'}) {
    if (date == null) return '';
    return DateFormat('dd MMMM yyyy', locale).format(date);
  }

  /// Format time as HH:mm
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('HH:mm').format(date);
  }

  /// Format date as relative time (e.g., "منذ ساعتين", "منذ يومين")
  static String formatRelativeDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'منذ يوم'
          : 'منذ ${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'منذ ساعة'
          : 'منذ ${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? 'منذ دقيقة'
          : 'منذ ${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }

  /// Parse date from dd/MM/yyyy string
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // NUMBER FORMATTERS
  // ============================================================

  /// Format number with commas (e.g., 1,234,567.89)
  static String formatNumber(num? number, {int decimals = 2}) {
    if (number == null) return '';

    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en');
    return formatter.format(number);
  }

  /// Format number as integer with commas (e.g., 1,234,567)
  static String formatInteger(num? number) {
    if (number == null) return '';

    final formatter = NumberFormat('#,##0', 'en');
    return formatter.format(number);
  }

  /// Format number as percentage (e.g., 85.5%)
  static String formatPercentage(num? number, {int decimals = 1}) {
    if (number == null) return '';

    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en');
    return '${formatter.format(number)}%';
  }

  /// Format area size (e.g., 1,234.56 م²)
  static String formatArea(num? area, {int decimals = 2}) {
    if (area == null) return '';
    return '${formatNumber(area, decimals: decimals)} م²';
  }

  /// Parse number from formatted string (removes commas)
  static double? parseNumber(String? numberString) {
    if (numberString == null || numberString.isEmpty) return null;

    // Remove commas and spaces
    final cleaned = numberString.replaceAll(RegExp(r'[,\s]'), '');
    return double.tryParse(cleaned);
  }

  // ============================================================
  // CURRENCY FORMATTERS
  // ============================================================

  /// Format currency in KWD (e.g., 1,234.567 د.ك)
  static String formatCurrency(num? amount, {int decimals = 3}) {
    if (amount == null) return '';
    return '${formatNumber(amount, decimals: decimals)} د.ك';
  }

  /// Format currency without symbol (e.g., 1,234.567)
  static String formatCurrencyValue(num? amount, {int decimals = 3}) {
    if (amount == null) return '';
    return formatNumber(amount, decimals: decimals);
  }

  // ============================================================
  // PHONE NUMBER FORMATTERS
  // ============================================================

  /// Format Kuwait phone number (+965 XXXX XXXX)
  static String formatKuwaitPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Remove country code if present
    String phoneNumber = digits;
    if (phoneNumber.startsWith('965')) {
      phoneNumber = phoneNumber.substring(3);
    }

    // Format as XXXX XXXX if 8 digits
    if (phoneNumber.length == 8) {
      return '+965 ${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4)}';
    }

    return phone; // Return original if format is unexpected
  }

  /// Format phone number for display (XXXX XXXX)
  static String formatPhoneDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Remove country code if present
    String phoneNumber = digits;
    if (phoneNumber.startsWith('965')) {
      phoneNumber = phoneNumber.substring(3);
    }

    // Format as XXXX XXXX if 8 digits
    if (phoneNumber.length == 8) {
      return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4)}';
    }

    return phone; // Return original if format is unexpected
  }

  /// Clean phone number (remove formatting, keep digits only)
  static String cleanPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Remove country code if present
    if (digits.startsWith('965') && digits.length > 3) {
      return digits.substring(3);
    }

    return digits;
  }

  // ============================================================
  // TEXT FORMATTERS
  // ============================================================

  /// Truncate text with ellipsis
  static String truncate(String? text, int maxLength,
      {String ellipsis = '...'}) {
    if (text == null || text.isEmpty) return '';

    if (text.length <= maxLength) return text;

    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Capitalize first letter
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';

    return text[0].toUpperCase() + text.substring(1);
  }

  /// Convert to title case
  static String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';

    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // ============================================================
  // FILE SIZE FORMATTERS
  // ============================================================

  /// Format file size (e.g., 1.5 MB, 234 KB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ============================================================
  // ARABIC NUMBER FORMATTERS
  // ============================================================

  /// Convert English digits to Arabic digits
  static String toArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// Convert Arabic digits to English digits
  static String toEnglishDigits(String text) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = text;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }
}
