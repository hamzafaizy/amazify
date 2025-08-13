// lib/widgets/glass.dart
import 'package:amazify/core/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Simple inherited widget to let children know which ThemeModeType is active.
class InheritedThemeMode extends InheritedWidget {
  const InheritedThemeMode({
    super.key,
    required this.mode,
    required super.child,
  });

  final ThemeModeType mode;

  static InheritedThemeMode of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedThemeMode>()!;

  @override
  bool updateShouldNotify(covariant InheritedThemeMode oldWidget) =>
      mode != oldWidget.mode;
}

/// Use this instead of [Card] when you want an element that becomes liquid glass
/// automatically if the global theme mode is [ThemeModeType.liquidGlass].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appTheme = InheritedThemeMode.of(context);
    final content = Padding(padding: padding, child: child);

    if (appTheme.mode == ThemeModeType.liquidGlass) {
      return LiquidGlass(
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(24),
        ),
        settings: LiquidGlassSettings(
          thickness: 10,
          blend: 28,
          glassColor: scheme.surface.withOpacity(0.18),
          ambientStrength: 0.8,
          lightIntensity: 1.4,
          saturation: 0.9,
          lightness: 1.0,
        ),
        child: content,
      );
    }

    // Fallback to a normal Material card look for light/dark
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: content,
    );
  }
}

/// Puts your page into a Stack with a background image/gradient so the
/// glass refraction has something to sample.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({super.key, required this.title, required this.body});
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appTheme = InheritedThemeMode.of(context);

    Widget scaffold = Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(padding: const EdgeInsets.all(16), child: body),
      backgroundColor: Colors.transparent,
    );

    if (appTheme.mode != ThemeModeType.liquidGlass) return scaffold;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background to refract — customize for your brand
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(0.25),
                scheme.surface,
                scheme.secondary.withOpacity(0.20),
              ],
            ),
          ),
        ),
        scaffold,
      ],
    );
  }
}

// -------------- GLASS BUTTON --------------
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.padding,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final mode = InheritedThemeMode.of(context).mode;
    final scheme = Theme.of(context).colorScheme;
    final content = Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: icon == null
          ? child
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon!, const SizedBox(width: 8), child],
            ),
    );

    if (mode == ThemeModeType.liquidGlass) {
      return LiquidGlass(
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(18),
        ),
        settings: LiquidGlassSettings(
          thickness: 9,
          blend: 24,
          glassColor: scheme.surface.withOpacity(0.18),
          ambientStrength: 0.9,
          lightIntensity: 1.2,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: scheme.onSurface),
            child: IconTheme.merge(
              data: IconThemeData(color: scheme.onSurface),
              child: content,
            ),
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: child,
      style: icon == null ? FilledButton.styleFrom(padding: padding) : null,
    );
  }
}

// -------------- GLASS ICON BUTTON --------------
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isGlass =
        InheritedThemeMode.of(context).mode == ThemeModeType.liquidGlass;
    final scheme = Theme.of(context).colorScheme;

    if (isGlass) {
      return LiquidGlass(
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(16),
        ),
        settings: LiquidGlassSettings(
          thickness: 8,
          blend: 22,
          glassColor: scheme.surface.withOpacity(0.2),
          ambientStrength: 0.5,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: scheme.onSurface),
        ),
      );
    }

    return IconButton.filled(onPressed: onPressed, icon: Icon(icon));
  }
}

// -------------- GLASS TEXT FIELD --------------
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isGlass =
        InheritedThemeMode.of(context).mode == ThemeModeType.liquidGlass;
    final scheme = Theme.of(context).colorScheme;

    final field = TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );

    if (!isGlass) return field; // use the theme's normal InputDecorationTheme

    return LiquidGlass(
      shape: const LiquidRoundedSuperellipse(borderRadius: Radius.circular(20)),
      settings: LiquidGlassSettings(
        thickness: 8,
        blend: 20,
        glassColor: scheme.surface.withOpacity(0.22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: field,
      ),
    );
  }
}

// -------------- GLASS APP BAR --------------
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({super.key, required this.title, this.actions});
  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isGlass =
        InheritedThemeMode.of(context).mode == ThemeModeType.liquidGlass;
    final scheme = Theme.of(context).colorScheme;

    final bar = AppBar(
      title: title,
      centerTitle: true,
      actions: actions,
      backgroundColor: isGlass ? Colors.transparent : scheme.surface,
      elevation: 0,
    );

    if (!isGlass) return bar;

    return LiquidGlass(
      shape: const LiquidRoundedRectangle(borderRadius: Radius.circular(0)),
      settings: LiquidGlassSettings(
        thickness: 10,
        blend: 26,
        glassColor: scheme.surface.withOpacity(0.16),
        ambientStrength: 0.35,
        lightIntensity: 1.2,
      ),
      child: bar,
    );
  }
}

// -------------- GLASS FAB --------------
class GlassFAB extends StatelessWidget {
  const GlassFAB({super.key, required this.onPressed, this.icon = Icons.add});
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isGlass =
        InheritedThemeMode.of(context).mode == ThemeModeType.liquidGlass;
    final scheme = Theme.of(context).colorScheme;

    final fab = FloatingActionButton(onPressed: onPressed, child: Icon(icon));

    if (!isGlass) return fab;

    return LiquidGlass(
      shape: const LiquidRoundedRectangle(borderRadius: Radius.circular(56)),
      settings: LiquidGlassSettings(
        thickness: 12,
        blend: 24,
        glassColor: scheme.surface.withOpacity(0.18),
        ambientStrength: 0.5,
        lightIntensity: 1.4,
      ),
      child: fab,
    );
  }
}

// -------------- GLASS BOTTOM NAVIGATION BAR --------------
class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    final isGlass =
        InheritedThemeMode.of(context).mode == ThemeModeType.liquidGlass;
    final scheme = Theme.of(context).colorScheme;

    final bar = BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      backgroundColor: isGlass ? Colors.transparent : scheme.surface,
      elevation: 0,
    );

    if (!isGlass) return bar;

    return LiquidGlass(
      shape: const LiquidRoundedSuperellipse(borderRadius: Radius.circular(24)),
      settings: LiquidGlassSettings(
        thickness: 10,
        blend: 24,
        glassColor: scheme.surface.withOpacity(0.16),
        lightIntensity: 1.1,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: bar,
      ),
    );
  }
}
