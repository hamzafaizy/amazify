// lib/features/shop/presentation/pages/wishlist.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Mock data — replace with your real models/store
  final List<_WishProduct> _items = [
    _WishProduct(
      id: 'w1',
      title: 'Wireless Headphones',
      brand: 'Amazify Audio',
      imageUrl: 'https://picsum.photos/seed/w1/800/800',
      price: 4999,
    ),
    _WishProduct(
      id: 'w2',
      title: 'Smart Watch Pro',
      brand: 'Amazify Wear',
      imageUrl: 'https://picsum.photos/seed/w2/800/800',
      price: 11999,
    ),
    _WishProduct(
      id: 'w3',
      title: '4K Action Camera',
      brand: 'Amazify Cam',
      imageUrl: 'https://picsum.photos/seed/w3/800/800',
      price: 28999,
    ),
  ];

  // Local cart just for demo
  final List<_WishProduct> _cart = [];

  void _removeAt(int index) {
    final removed = _items.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed from wishlist: ${removed.title}')),
    );
  }

  void _addToCart(_WishProduct p) {
    setState(() => _cart.add(p));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added to cart: ${p.title}')));
  }

  void _moveAllToCart() {
    if (_items.isEmpty) return;
    setState(() {
      _cart.addAll(_items);
      _items.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Moved all to cart')));
  }

  void _clearAll() {
    if (_items.isEmpty) return;
    setState(() => _items.clear());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Wishlist cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Iconsax.shopping_bag),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: _CountDot(count: _cart.length),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _items.isEmpty
          ? _EmptyWishlist(
              onBrowse: () {
                // Navigate to store or home
                Navigator.maybePop(context);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = _items[index];
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  background: _DismissBg(color: cs.error),
                  onDismissed: (_) => _removeAt(index),
                  child: _WishItemTile(
                    product: p,
                    onAdd: () => _addToCart(p),
                    onRemove: () => _removeAt(index),
                  ),
                );
              },
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: const Text('Clear'),
                        onPressed: _clearAll,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Iconsax.shopping_bag),
                        label: const Text('Move all to cart'),
                        onPressed: _moveAllToCart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ────────────── Widgets ──────────────

class _WishItemTile extends StatelessWidget {
  const _WishItemTile({
    required this.product,
    required this.onAdd,
    required this.onRemove,
  });

  final _WishProduct product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {}, // TODO: open product details
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    // ...
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title, brand, price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Brand + blue tick
                    if ((product.brand ?? '').isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.brand!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    // Price
                    Text(
                      _fmt(product.price, '₨'),
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Actions column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red heart to remove
                  Material(
                    color: cs.surfaceContainerHighest.withOpacity(.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Plus button with TL & BR rounded
                  SizedBox(
                    height: 38,
                    width: 56,
                    child: TextButton(
                      onPressed: onAdd,
                      style: TextButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.heart, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Save items you love and we’ll keep them here for you.',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onBrowse,
              child: const Text('Browse the Store'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DismissBg extends StatelessWidget {
  const _DismissBg({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

// Small badge for counts (used on AppBar icon)
class _CountDot extends StatelessWidget {
  const _CountDot({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ────────────── Models & utils ──────────────

class _WishProduct {
  final String id;
  final String title;
  final String? brand;
  final String imageUrl;
  final double price;

  _WishProduct({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.brand,
  });
}

String _fmt(double v, String symbol) {
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
