import 'package:flutter/material.dart';
import 'package:amazify/app/theme/theme.dart';

/// Three explicit modes (no "system" here because we need a third, custom theme)
enum ThemeKind { light, dark, glass }

class ThemeController extends ChangeNotifier {
  ThemeKind _kind = ThemeKind.light;
  ThemeKind get kind => _kind;

  void set(ThemeKind k) {
    if (_kind == k) return;
    _kind = k;
    notifyListeners();
  }

  void cycle() {
    // Light -> Dark -> Glass -> Light ...
    switch (_kind) {
      case ThemeKind.light:
        set(ThemeKind.dark);
        break;
      case ThemeKind.dark:
        set(ThemeKind.glass);
        break;
      case ThemeKind.glass:
        set(ThemeKind.light);
        break;
    }
  }

  ThemeData get themeData {
    switch (_kind) {
      case ThemeKind.light:
        return AppTheme.light;
      case ThemeKind.dark:
        return AppTheme.dark;
      case ThemeKind.glass:
        return AppTheme.liquidGlass;
    }
  }
}

/// Inherited wrapper so you can read/set the mode anywhere in the tree.
class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in context');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) =>
      notifier != oldWidget.notifier;
}
