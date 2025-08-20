// lib/features/shop/presentation/widgets/productcard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discountPercent, // e.g. 78
    this.brand,
    this.currencySymbol = '₨',
    this.initialFavorite = false,
    this.onTap,
    this.onAdd,
    this.onFavoriteChanged,
    this.width,
  });

  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int discountPercent;
  final String? brand;
  final String currencySymbol;

  final bool initialFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final ValueChanged<bool>? onFavoriteChanged;

  final double? width;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _favorite = widget.initialFavorite;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          color: cs.tertiaryContainer,
          width: widget.width,
          child: Stack(
            alignment: Alignment.bottomRight,
            fit: StackFit.expand,
            children: [
              // MAIN COLUMN CONTENT
              Padding(
                padding: const EdgeInsets.only(
                  left: 3,
                  right: 3,
                  top: 3,
                  bottom: 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE with overlays
                    Expanded(
                      child: Stack(
                        children: [
                          // product image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (c, child, prog) =>
                                    prog == null ? child : _ImageSkeleton(),
                                errorBuilder: (_, __, ___) => _ImageError(),
                              ),
                            ),
                          ),
                          // left-top discount badge
                          Positioned(
                            left: 10,
                            top: 10,
                            child: _DiscountBadge(
                              percent: widget.discountPercent,
                            ),
                          ),
                          // right-top heart
                          Positioned(
                            right: 10,
                            top: 10,
                            child: _HeartButton(
                              isActive: _favorite,
                              onTap: () {
                                setState(() => _favorite = !_favorite);
                                widget.onFavoriteChanged?.call(_favorite);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Brand + blue tick (subtitle)
                    if ((widget.brand ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.brand!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelMedium?.copyWith(
                                  color: cs.tertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.verified, size: 16, color: Colors.blue),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Price (bold)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.currencySymbol,
                              style: GoogleFonts.robotoMono(
                                textStyle:
                                    (text.titleMedium ?? const TextStyle())
                                        .copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize:
                                              (text.titleMedium?.fontSize ??
                                                  16) *
                                              .8,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          letterSpacing: -0.2,
                                        ),
                              ),
                            ),
                            TextSpan(text: ' '), // small gap
                            TextSpan(
                              text: _fmt(widget.price, ''),
                              style: GoogleFonts.robotoMono(
                                textStyle:
                                    (text.titleMedium ?? const TextStyle())
                                        .copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          letterSpacing: -0.2,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ), // space for bottom-right + button overlay
                  ],
                ),
              ),

              // bottom-right + button with only TL & BR rounded
              Positioned(
                right: 0,
                bottom: 0,
                child: _PlusButton(
                  onPressed: widget.onAdd,
                  background: cs.primary,
                  foreground: cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(double v, String symbol) {
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    final parts = s.split('.');
    final whole = parts[0];
    final frac = parts.length > 1 ? '.${parts[1]}' : '';
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final pos = whole.length - i;
      buf.write(whole[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(',');
    }
    return '$symbol${buf.toString()}$frac';
  }
}

// ——— Sub-widgets ———

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: Colors.amber, // yellow as requested
        shape: const StadiumBorder(),
        shadows: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Colors.black12),
        ],
      ),
      child: Text(
        '-$percent%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isActive, this.onTap});
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withOpacity(.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isActive ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isActive ? Colors.red : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({
    this.onPressed,
    required this.background,
    required this.foreground,
  });

  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(0),
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          '+',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
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
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
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
