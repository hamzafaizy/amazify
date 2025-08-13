import 'package:intl/intl.dart';

/// Utility class for formatting numbers, dates, strings, etc.
class FormatterUtils {
  FormatterUtils._(); // Private constructor

  /// Format currency with symbol (default: USD)
  static String formatCurrency(
    num amount, {
    String locale = 'en_US',
    String symbol = '\$',
  }) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(amount);
  }

  /// Format number with commas (e.g., 1,234,567)
  static String formatNumber(num number, {String locale = 'en_US'}) {
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(number);
  }

  /// Format percentage (e.g., 45%)
  static String formatPercentage(num value, {int decimalDigits = 0}) {
    return "${value.toStringAsFixed(decimalDigits)}%";
  }

  /// Format date (e.g., Jan 5, 2025)
  static String formatDate(DateTime date, {String format = 'MMM d, y'}) {
    return DateFormat(format).format(date);
  }

  /// Format date with time (e.g., Jan 5, 2025, 3:45 PM)
  static String formatDateTime(
    DateTime date, {
    String format = 'MMM d, y, h:mm a',
  }) {
    return DateFormat(format).format(date);
  }

  /// Format time only (e.g., 3:45 PM)
  static String formatTime(DateTime time, {String format = 'h:mm a'}) {
    return DateFormat(format).format(time);
  }

  /// Format phone number for local readability
  /// Example: 03001234567 → 0300 123 4567
  static String formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return "${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}";
    } else if (digits.length == 10) {
      return "(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}";
    }
    return phone;
  }

  /// Format phone number in International E.164 format
  /// Example: (PK) 03001234567 → +923001234567
  static String formatInternationalPhoneNumber(
    String phone, {
    String countryCode = '+92',
  }) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return "$countryCode$digits";
  }

  /// Mask email for privacy (e.g., j***@gmail.com)
  static String maskEmail(String email) {
    var parts = email.split('@');
    if (parts.length != 2) return email;
    var name = parts[0];
    var domain = parts[1];
    if (name.length > 1) {
      return "${name[0]}***@$domain";
    }
    return "***@$domain";
  }

  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Shorten text with ellipsis (e.g., "This is..." for UI)
  static String ellipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return "${text.substring(0, maxLength)}...";
  }
}
