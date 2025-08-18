// lib/features/shop/presentation/widgets/productcard.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProductsCard extends StatelessWidget {
  const ProductsCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.compareAtPrice,
    this.rating = 0,
    this.reviewCount,
    this.brand,
    this.currencySymbol = '₨',
    this.isFavorite = false,
    this.isNew = false,
    this.heroTag,
    this.width,
    this.padding,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.onLongPress,
    this.showAddButton = true,
  });

  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? compareAtPrice;
  final double rating; // 0..5
  final int? reviewCount;
  final String? brand;

  final String currencySymbol;
  final bool isFavorite;
  final bool isNew;

  final String? heroTag;
  final double? width;
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onLongPress;
  final bool showAddButton;

  bool get _isOnSale =>
      (compareAtPrice != null && compareAtPrice! > price && price > 0);

  int get _discountPercent {
    if (!_isOnSale) return 0;
    final pct = (1 - (price / (compareAtPrice ?? price))) * 100;
    return pct.clamp(0, 99).round();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.35), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(10),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + badges + favorite
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      _HeroImage(
                        imageUrl: imageUrl,
                        tag: heroTag ?? 'product_$id',
                        borderRadius: 12,
                      ),
                      // BADGES
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isNew) _Badge(label: 'NEW', color: cs.tertiary),
                            if (_isOnSale)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: _Badge(
                                  label: '-$_discountPercent%',
                                  color: cs.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // FAVORITE
                      Positioned(
                        right: 6,
                        top: 6,
                        child: _CircleIconButton(
                          icon: isFavorite ? Iconsax.heart5 : Iconsax.heart,
                          filled: isFavorite,
                          tooltip: isFavorite
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                          onPressed: onToggleFavorite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (brand != null && brand!.trim().isNotEmpty)
                  Text(
                    brand!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: .2,
                    ),
                  ),
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                // Rating
                if (rating > 0) _RatingRow(rating: rating, count: reviewCount),
                if (rating > 0) const SizedBox(height: 6),

                // Price + Add button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _PriceBlock(
                        price: price,
                        compareAtPrice: compareAtPrice,
                        currencySymbol: currencySymbol,
                      ),
                    ),
                    if (showAddButton)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _AddButton(onPressed: onAddToCart),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Subwidgets ----------

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.imageUrl,
    required this.tag,
    required this.borderRadius,
  });

  final String imageUrl;
  final String tag;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Graceful loading
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return _ImageSkeleton();
        },
        errorBuilder: (_, __, ___) => _ImageError(),
        frameBuilder: (c, child, frame, _) {
          if (frame == null) {
            return _ImageSkeleton();
          }
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 250),
            child: child,
          );
        },
      ),
    );

    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, __, ___, ____, _____) =>
          Material(color: Colors.transparent, child: image),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: image,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: color,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.black.withOpacity(.04)),
        ),
        shadows: const [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: onColor,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = filled ? cs.primary : cs.surface.withOpacity(.8);
    final fg = filled ? cs.onPrimary : cs.onSurface;

    final child = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: fg,
      style: IconButton.styleFrom(
        backgroundColor: bg,
        minimumSize: const Size(36, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, this.count});
  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.price,
    required this.compareAtPrice,
    required this.currencySymbol,
  });

  final double price;
  final double? compareAtPrice;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final priceStr = _fmt(price, currencySymbol);
    final compareStr = (compareAtPrice != null && compareAtPrice! > price)
        ? _fmt(compareAtPrice!, currencySymbol)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compareStr != null)
          Text(
            compareStr,
            style: text.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          priceStr,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  static String _fmt(double v, String symbol) {
    // Formats like ₨1,499.99 or $49.90 (simple, intl-free)
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    final parts = s.split('.');
    final whole = parts[0];
    final frac = parts.length > 1 ? '.${parts[1]}' : '';
    final withCommas = _addCommas(whole);
    return '$symbol$withCommas$frac';
  }

  static String _addCommas(String x) {
    final buf = StringBuffer();
    for (int i = 0; i < x.length; i++) {
      final pos = x.length - i;
      buf.write(x[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Add to cart',
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Iconsax.shopping_bag, size: 18),
        label: const Text('Add'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(70, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surfaceContainerHighest, cs.surfaceContainerHigh],
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.broken_image_rounded, color: cs.onSurfaceVariant),
    );
  }
}
