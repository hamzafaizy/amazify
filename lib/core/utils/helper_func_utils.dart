// lib/utils/helper_utils.dart
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Misc, UI, and navigation helpers for quick reuse across the app.
class HelperUtils {
  HelperUtils._(); // no instances

  // ───────────────────────── UI / THEME ─────────────────────────

  /// Parse a color from hex like `#2979FF`, `2979FF`, or ARGB `#FF2979FF`.
  /// Optionally override opacity (0..1).
  static Color getColor(String hex, {double? opacity}) {
    var cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) cleaned = 'FF$cleaned'; // add alpha if missing
    final value = int.tryParse(cleaned, radix: 16) ?? 0xFF000000;
    var color = Color(value);
    if (opacity != null) color = color.withOpacity(opacity.clamp(0.0, 1.0));
    return color;
  }

  /// True when the current theme is dark.
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ───────────────────────── TEXT / DATES ─────────────────────────

  /// Truncate long text. Adds ellipsis by default.
  static String truncateText(
    String text, {
    int maxLength = 120,
    bool ellipsis = true,
  }) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + (ellipsis ? '…' : '');
  }

  /// Format a date using intl patterns (e.g., 'MMM d, y', 'y-MM-dd').
  static String getFormattedDate(DateTime date, {String pattern = 'MMM d, y'}) {
    return DateFormat(pattern).format(date);
  }

  // ───────────────────────── COLLECTIONS ─────────────────────────

  /// Remove duplicates while keeping original order (stable).
  static List<T> removeDuplicates<T>(Iterable<T> items) {
    final seen = HashSet<T>();
    final result = <T>[];
    for (final item in items) {
      if (seen.add(item)) result.add(item);
    }
    return result;
  }

  // ───────────────────────── SCREEN / LAYOUT ─────────────────────────

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;

  static EdgeInsets mediaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;
  static double bottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// Convenience: wrap list of widgets with padding around each child.
  static List<Widget> wrapWidgetsWithPadding(
    List<Widget> children, {
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return children.map((w) => Padding(padding: padding, child: w)).toList();
  }

  /// Create a Wrap with sensible defaults (great for chips/tags/grids).
  static Widget spacedWrap({
    required List<Widget> children,
    double spacing = 8,
    double runSpacing = 8,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Align(
      alignment: alignment,
      child: Wrap(spacing: spacing, runSpacing: runSpacing, children: children),
    );
  }

  /// Responsive helper: returns true if width >= breakpoint.
  static bool isWide(BuildContext context, {double breakpoint = 800}) =>
      screenWidth(context) >= breakpoint;

  // ───────────────────────── FEEDBACK ─────────────────────────

  /// Show a SnackBar anywhere.
  static void showSnackBar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  /// Quick alert dialog. Returns true if confirmed, false if canceled, null if dismissed.
  static Future<bool?> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool showCancel = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showCancel)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Haptic feedback helper (light impact by default).
  static Future<void> hapticLight() => HapticFeedback.lightImpact();

  // ───────────────────────── NAVIGATION ─────────────────────────

  static Future<T?> navigateTo<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> navigateAndReplace<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).pushReplacement<T, T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  static void goBack<T>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<T>(result);
    }
  }

  // ───────────────────────── MISC ─────────────────────────

  /// Copy text to clipboard with optional callback.
  static Future<void> copyToClipboard(
    String text, {
    VoidCallback? onCopied,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    onCopied?.call();
  }

  /// Clamp a value between [min] and [max].
  static num clamp(num value, num min, num max) =>
      math.min(math.max(value, min), max);
}

/// Handy extensions so calls read nicely: `context.isDarkMode`, `context.width`, etc.
extension BuildContextX on BuildContext {
  bool get isDarkMode => HelperUtils.isDarkMode(this);
  double get width => HelperUtils.screenWidth(this);
  double get height => HelperUtils.screenHeight(this);
  Size get screenSize => HelperUtils.screenSize(this);
  double get statusBar => HelperUtils.statusBarHeight(this);
  double get bottomInset => HelperUtils.bottomSafeArea(this);

  void showSnack(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => HelperUtils.showSnackBar(
    this,
    message,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  Future<bool?> alert({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool showCancel = true,
  }) => HelperUtils.showAlert(
    this,
    title: title,
    message: message,
    confirmText: confirmText,
    cancelText: cancelText,
    showCancel: showCancel,
  );
}
