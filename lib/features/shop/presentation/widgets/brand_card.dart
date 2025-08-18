import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BrandCardData {
  final String brand;
  final String line;
  final int items;
  const BrandCardData(this.brand, this.line, this.items);
}

class BrandCard extends StatelessWidget {
  const BrandCard({required this.data});
  final BrandCardData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.12),
              cs.primary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.18), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.brand,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Iconsax.bag_2, size: 18, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        "${data.items} products",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Illustrative block
            Container(
              width: 86,
              height: double.infinity,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}
