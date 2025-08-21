import 'package:flutter/material.dart';

/// Brand info model (shared)
class BrandInfo {
  final String name;
  final String subtitle;
  const BrandInfo(this.name, this.subtitle);
}

/// Visual/verification bundle for a brand (shared)
class BrandVisual {
  /// Accepts either a network URL (http/https) or an asset path.
  final String? imagePath;

  /// Whether to show the blue verified tick.
  final bool verified;

  const BrandVisual({this.imagePath, this.verified = false});
}

/// Reusable brand card used by the grid and elsewhere.
class CustomBrandCard extends StatelessWidget {
  const CustomBrandCard({
    super.key,
    required this.name,
    required this.description,
    this.imagePath,
    this.verified = false,
    this.onTap,
  });

  /// URL or asset path; leave null to show the initial.
  final String? imagePath;

  /// Brand display name
  final String name;

  /// One‑line description / subtitle
  final String description;

  /// Shows a blue tick if true
  final bool verified;

  /// Optional tap handler
  final VoidCallback? onTap;

  bool get _isNetwork =>
      (imagePath != null) &&
      (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));

  ImageProvider? get _provider {
    if (imagePath == null || imagePath!.trim().isEmpty) return null;
    return _isNetwork
        ? NetworkImage(imagePath!)
        : AssetImage(imagePath!) as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final card = Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar with graceful fallback to initial if image fails/absent
          _BrandAvatar(
            imageProvider: _provider,
            fallbackLetter: name.isNotEmpty ? name[0].toUpperCase() : '?',
          ),
          const SizedBox(width: 10),
          // Textual content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (verified)
                      Icon(Icons.verified, size: 16, color: cs.primary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

/// Private avatar widget with error handling (shows initial on failure).
class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar({
    required this.imageProvider,
    required this.fallbackLetter,
  });

  final ImageProvider? imageProvider;
  final String fallbackLetter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // If no image, render letter avatar directly
    if (imageProvider == null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: cs.primaryContainer.withOpacity(0.4),
        child: Text(
          fallbackLetter,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      );
    }

    // Try to load image; on error, fall back to letter
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipOval(
        child: Image(
          image: imageProvider!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: cs.primaryContainer.withOpacity(0.4),
            alignment: Alignment.center,
            child: Text(
              fallbackLetter,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

/// Public grid that renders a list of [BrandInfo] with optional [BrandVisual].
class FeaturedBrandGrid extends StatelessWidget {
  const FeaturedBrandGrid({
    super.key,
    required this.items,
    this.visuals,
    this.onItemTap,
  });

  final List<BrandInfo> items;
  final List<BrandVisual>? visuals;
  final void Function(int index, BrandInfo info)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 84,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          final info = items[i];
          final vis = (visuals != null && i < visuals!.length)
              ? visuals![i]
              : null;

          return CustomBrandCard(
            name: info.name,
            description: info.subtitle,
            imagePath: vis?.imagePath,
            verified: vis?.verified ?? false,
            onTap: onItemTap == null ? null : () => onItemTap!(i, info),
          );
        },
      ),
    );
  }
}
