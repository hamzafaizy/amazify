import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log;

/// Centralized logger utility.
/// Wraps the `logger` package to ensure consistent format and easy toggling.
class AppLogger {
  AppLogger._();

  static final _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 2, // number of method calls to show
      errorMethodCount: 5, // number of method calls if stacktrace is provided
      lineLength: 90, // width of log output
      colors: true, // color output
      printEmojis: true, // include emojis
      dateTimeFormat: log.DateTimeFormat.dateAndTime, // timestamp format
    ),
  );

  /// Set to false in production to disable logs.
  static bool isLoggingEnabled = kDebugMode;

  // ─────────────── LEVELS ───────────────

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!isLoggingEnabled) return;
    _logger.d(_stringify(message), error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!isLoggingEnabled) return;
    _logger.i(_stringify(message), error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!isLoggingEnabled) return;
    _logger.w(_stringify(message), error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!isLoggingEnabled) return;
    _logger.e(_stringify(message), error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!isLoggingEnabled) return;
    _logger.wtf(_stringify(message), error: error, stackTrace: stackTrace);
  }

  // ─────────────── HELPERS ───────────────

  static String _stringify(dynamic message) {
    if (message is Map || message is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(message);
      } catch (_) {
        return message.toString();
      }
    }
    return message?.toString() ?? 'null';
  }

  /// Log a Map/JSON with pretty formatting.
  static void json(Map<String, dynamic> data) {
    if (!isLoggingEnabled) return;
    _logger.i(const JsonEncoder.withIndent('  ').convert(data));
  }
}
