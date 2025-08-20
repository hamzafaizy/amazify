import 'package:flutter/material.dart';

class VariationCard extends StatelessWidget {
  const VariationCard({
    super.key,
    this.title = 'Variation',
    this.price = 20,
    this.oldPrice = 25,
    this.inStock = true,
    this.description =
        'Lightweight, breathable upper with responsive cushioning.',
  });

  final String title;
  final double price;
  final double oldPrice;
  final bool inStock;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    // Adaptive background for M3 themes (looks elevated in light & dark)
    final Color bg =
        cs.surfaceContainerHigh; // fallback to cs.surface if needed

    return Card(
      color: bg,
      elevation: 3,
      surfaceTintColor: cs.surfaceTint,
      shadowColor: Colors.black.withOpacity(
        theme.brightness == Brightness.dark ? 0.35 : 0.08,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title (left) + Price + Stock in the same row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    textScaler: TextScaler.linear(1.4),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price:', style: text.labelSmall),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(0)}',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '\$${oldPrice.toStringAsFixed(0)}',
                          style: text.bodySmall?.copyWith(
                            color: cs.outline,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock:', style: text.labelSmall),
                    const SizedBox(height: 2),
                    Text(
                      inStock ? 'In Stock' : 'Out of Stock',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: inStock ? Colors.green : cs.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 50),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: text.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
