// lib/features/shop/presentation/pages/wishlist.dart
import 'package:amazify/features/shop/presentation/pages/home_page.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/product_box.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final items = _demoWishlist; // TODO: replace with your real wishlist source

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100
        ? 5
        : width >= 900
        ? 4
        : width >= 650
        ? 3
        : 2;
    final aspectRatio = width >= 900 ? 0.82 : 0.74;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: false,
        title: Text(
          'Wishlist',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Go to Home',
            icon: const Icon(Iconsax.add),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HomePage()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: items.isEmpty
          ? _EmptyState(
              onBrowse: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (_) => false,
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return ProductCard(
                    id: p.id,
                    title: p.title,
                    imageUrl: p.imageUrl,
                    price: p.price,
                    discountPercent: p.discountPercent,
                    brand: p.brand,
                    currencySymbol: '₨',
                    initialFavorite: true,
                    onTap: () {
                      // TODO: navigate to product details
                    },
                    onAdd: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.title} added to cart')),
                      );
                    },
                    onFavoriteChanged: (fav) {
                      // TODO: update wishlist state
                    },
                  );
                },
              ),
            ),
      backgroundColor: cs.surface,
    );
  }
}

/// ───────────────────────── Demo data (replace with real state) ─────────────────────────

class WishlistItem {
  final String id, title, imageUrl, brand;
  final double price;
  final int discountPercent;
  const WishlistItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discountPercent,
    this.brand = '',
  });
}

const _demoWishlist = <WishlistItem>[
  WishlistItem(
    id: '1',
    title: 'Nike Air Zoom',
    imageUrl: 'https://picsum.photos/seed/airzoom/600/600',
    price: 18999,
    discountPercent: 20,
    brand: 'Nike',
  ),
  WishlistItem(
    id: '2',
    title: 'Adidas Ultraboost',
    imageUrl: 'https://picsum.photos/seed/ultra/600/600',
    price: 21999,
    discountPercent: 15,
    brand: 'Adidas',
  ),
  WishlistItem(
    id: '3',
    title: 'Sony WH-1000XM4',
    imageUrl: 'https://picsum.photos/seed/sony/600/600',
    price: 79999,
    discountPercent: 10,
    brand: 'Sony',
  ),
  WishlistItem(
    id: '4',
    title: 'IKEA Markus Chair',
    imageUrl: 'https://picsum.photos/seed/markus/600/600',
    price: 59999,
    discountPercent: 25,
    brand: 'IKEA',
  ),
  WishlistItem(
    id: '5',
    title: 'Puma Running Tee',
    imageUrl: 'https://picsum.photos/seed/puma/600/600',
    price: 3499,
    discountPercent: 30,
    brand: 'Puma',
  ),
  WishlistItem(
    id: '6',
    title: 'Logitech MX Master 3S',
    imageUrl: 'https://picsum.photos/seed/mx/600/600',
    price: 24999,
    discountPercent: 12,
    brand: 'Logitech',
  ),
];

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.heart, size: 56),
            const SizedBox(height: 12),
            Text('Your wishlist is empty', style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Save items you love and find them here later.',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBrowse,
              child: const Text('Browse products'),
            ),
          ],
        ),
      ),
    );
  }
}
