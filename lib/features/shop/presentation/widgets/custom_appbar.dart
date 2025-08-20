// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = true,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.elevation,
  });

  final Widget? title;
  final List<Widget>? actions;
  final IconData? leadingIcon;
  final VoidCallback? leadingOnPressed;
  final bool showBackArrow;
  final double height;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTransparentBg =
        backgroundColor != null && backgroundColor!.opacity == 0.0;

    Widget? buildLeading() {
      if (leadingIcon != null) {
        return IconButton(
          icon: Icon(leadingIcon, color: theme.colorScheme.onSurface),
          onPressed: leadingOnPressed ?? () => Navigator.of(context).maybePop(),
        );
      }
      if (showBackArrow && Navigator.canPop(context)) {
        return IconButton(
          icon: const Icon(Iconsax.arrow_left),
          color: theme.colorScheme.onSurface,
          onPressed: leadingOnPressed ?? () => Navigator.of(context).maybePop(),
        );
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
      child: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0, // make the title start from the very beginning
        title: title,
        leading: buildLeading(),
        actions: actions,

        // Background & elevation
        backgroundColor: backgroundColor,
        elevation: isTransparentBg ? 0 : (elevation ?? 0),
        scrolledUnderElevation: 0,
        shadowColor: isTransparentBg ? Colors.transparent : null,
        surfaceTintColor: Colors
            .transparent, // remove Material 3 overlay/tint (fixes "slight color" box)
        // Keep text/icon colors consistent
        foregroundColor: theme.colorScheme.onSurface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),

        // (Optional) status bar icons adapt to theme background
        systemOverlayStyle: isTransparentBg
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : null,
      ),
    );
  }
}
