// lib/utils/helper_utils.dart
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Misc, UI, and navigation helpers for quick reuse across the app.
class HelperUtils {
  HelperUtils._(); // no instances

  // ───────────────────────── UI / THEME ─────────────────────────

  /// Parse a color from hex:
  /// - RGB:   #2979FF / 2979FF
  /// - ARGB:  #FF2979FF
  /// - Short: #ABC (=> #AABBCC), #FABC (=> #FFAABBCC)
  /// Optionally override opacity (0..1).
  static Color getColor(String hex, {double? opacity}) {
    var cleaned = hex.replaceAll('#', '').trim();

    // Expand short forms (#RGB or #ARGB)
    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((c) => '$c$c').join(); // RRGGBB
      cleaned = 'FF$cleaned'; // add alpha
    } else if (cleaned.length == 4) {
      final a = cleaned[0] * 2;
      final r = cleaned[1] * 2;
      final g = cleaned[2] * 2;
      final b = cleaned[3] * 2;
      cleaned = '$a$r$g$b';
    } else if (cleaned.length == 6) {
      cleaned = 'FF$cleaned'; // add alpha if missing
    }

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

  /// Unfocus keyboard safely.
  static void unfocus(BuildContext context) {
    final scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus && scope.hasFocus) {
      scope.unfocus();
    }
  }

  // ───────────────────────── FEEDBACK ─────────────────────────

  /// Show a SnackBar anywhere. Does nothing if no ScaffoldMessenger is present.
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
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showCancel)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Haptic feedback helper (light impact by default), safely ignored on unsupported platforms.
  static Future<void> hapticLight() async {
    try {
      // Avoid spamming haptics on web/desktop
      if (kIsWeb) return;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
          await HapticFeedback.lightImpact();
          break;
        default:
          // No-op for other platforms
          break;
      }
    } on PlatformException {
      // Silently ignore haptic failures
    }
  }

  // ───────────────────────── NAVIGATION ─────────────────────────

  static Future<T?> navigateTo<T>(BuildContext context, Widget page) async {
    final nav = Navigator.maybeOf(context);
    if (nav == null) return null;
    if (!context.mounted) return null;
    return nav.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    Widget page,
  ) async {
    final nav = Navigator.maybeOf(context);
    if (nav == null) return null;
    if (!context.mounted) return null;
    return nav.pushReplacement<T, T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
  ) async {
    final nav = Navigator.maybeOf(context);
    if (nav == null) return null;
    if (!context.mounted) return null;
    return nav.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  static void goBack<T>(BuildContext context, [T? result]) {
    final nav = Navigator.maybeOf(context);
    if (nav == null) return;
    if (nav.canPop()) {
      nav.pop<T>(result);
    }
  }

  // ───────────────────────── MISC ─────────────────────────

  /// Copy text to clipboard with optional callback. Silently ignores failures.
  static Future<void> copyToClipboard(
    String text, {
    VoidCallback? onCopied,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      onCopied?.call();
    } catch (_) {
      // Some platforms (web/desktop sandbox) may throw — safely ignore
    }
  }

  /// Clamp a value between [min] and [max].
  static num clamp(num value, num min, num max) =>
      math.min(math.max(value, min), max);

  /// Run a function after the current frame (safe for showing dialogs/snacks in initState).
  static void onNextFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }
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
    Duration duration = const Duration(seconds: 3),
  }) => HelperUtils.showSnackBar(
    this,
    message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );

  Future<bool?> alert({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool showCancel = true,
    bool barrierDismissible = true,
  }) => HelperUtils.showAlert(
    this,
    title: title,
    message: message,
    confirmText: confirmText,
    cancelText: cancelText,
    showCancel: showCancel,
    barrierDismissible: barrierDismissible,
  );

  void unfocusKeyboard() => HelperUtils.unfocus(this);
}
