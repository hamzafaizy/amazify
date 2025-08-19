// lib/features/shop/presentation/pages/store_page.dart
import 'package:amazify/features/shop/presentation/widgets/product_box.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // ─────────────────────────── Mock data (swap with your repo/API) ───────────────────────────
  final List<_Product> _all = [
    _Product(
      id: 'p1',
      title: 'Wireless Headphones',
      brand: 'Amazify Audio',
      imageUrl: 'https://picsum.photos/seed/p1/800/800',
      price: 4999,
      discount: 78,
      popularity: 98,
      createdAt: DateTime(2025, 8, 10),
    ),
    _Product(
      id: 'p2',
      title: 'Smart Watch Pro',
      brand: 'Amazify Wear',
      imageUrl: 'https://picsum.photos/seed/p2/800/800',
      price: 11999,
      discount: 35,
      popularity: 92,
      createdAt: DateTime(2025, 8, 14),
    ),
    _Product(
      id: 'p3',
      title: '4K Action Camera',
      brand: 'Amazify Cam',
      imageUrl: 'https://picsum.photos/seed/p3/800/800',
      price: 28999,
      discount: 22,
      popularity: 77,
      createdAt: DateTime(2025, 8, 6),
    ),
    _Product(
      id: 'p4',
      title: 'Ergo Office Chair',
      brand: 'Amazify Home',
      imageUrl: 'https://picsum.photos/seed/p4/800/800',
      price: 17999,
      discount: 40,
      popularity: 81,
      createdAt: DateTime(2025, 8, 12),
    ),
    _Product(
      id: 'p5',
      title: 'Performance Sneakers',
      brand: 'Amazify Fit',
      imageUrl: 'https://picsum.photos/seed/p5/800/800',
      price: 7999,
      discount: 50,
      popularity: 88,
      createdAt: DateTime(2025, 8, 16),
    ),
  ];

  // ─────────────────────────── UI State ───────────────────────────
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _category; // using brand as category for demo
  SortOption _sort = SortOption.popular;

  final List<_Product> _cart = [];
  final Set<String> _wishlist = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Derived list after search/category/sort
  List<_Product> get _filteredSorted {
    Iterable<_Product> list = _all;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            (p.brand?.toLowerCase().contains(q) ?? false),
      );
    }

    if (_category != null && _category!.isNotEmpty) {
      list = list.where((p) => (p.brand ?? '') == _category);
    }

    final items = list.toList();
    switch (_sort) {
      case SortOption.popular:
        items.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case SortOption.priceLowHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return items;
  }

  List<String> get _categories => _all
      .map((p) => p.brand ?? '')
      .where((b) => b.isNotEmpty)
      .toSet()
      .toList();

  // ─────────────────────────── Actions ───────────────────────────
  void _addToCart(_Product p) {
    setState(() => _cart.add(p));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added to cart: ${p.title}')));
  }

  void _toggleWishlist(_Product p) {
    setState(() {
      if (_wishlist.contains(p.id)) {
        _wishlist.remove(p.id);
      } else {
        _wishlist.add(p.id);
      }
    });
  }

  void _openSortSheet() async {
    final choice = await showModalBottomSheet<SortOption>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SortSheet(current: _sort),
    );
    if (choice != null) {
      setState(() => _sort = choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final items = _filteredSorted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Iconsax.heart),
                if (_wishlist.isNotEmpty)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: _CountDot(count: _wishlist.length),
                  ),
              ],
            ),
          ),
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
      body: CustomScrollView(
        slivers: [
          // Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search for Store',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withOpacity(.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withOpacity(.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withOpacity(.3),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Category chips
          if (_categories.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    final c = _categories[i];
                    final selected = c == _category;
                    return ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _category = selected ? null : c;
                      }),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _categories.length,
                ),
              ),
            ),

          // Sort row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} items',
                      style: text.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openSortSheet,
                    icon: const Icon(Iconsax.sort),
                    label: Text(_sort.label),
                  ),
                  if (_query.isNotEmpty || _category != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _query = '';
                        _searchCtrl.clear();
                        _category = null;
                        _sort = SortOption.popular;
                      }),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
          ),

          // Grid of products
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final p = items[i];
                return ProductCard(
                  id: p.id,
                  title: p.title,
                  brand: p.brand,
                  imageUrl: p.imageUrl,
                  price: p.price,
                  discountPercent: p.discount,
                  currencySymbol: '₨',
                  initialFavorite: _wishlist.contains(p.id),
                  onTap: () {
                    // TODO: navigate to product details
                  },
                  onAdd: () => _addToCart(p),
                  onFavoriteChanged: (_) => _toggleWishlist(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Helpers / Models ───────────────────────────

enum SortOption { popular, priceLowHigh, priceHighLow, newest }

extension on SortOption {
  String get label {
    switch (this) {
      case SortOption.popular:
        return 'Popular';
      case SortOption.priceLowHigh:
        return 'Price: Low–High';
      case SortOption.priceHighLow:
        return 'Price: High–Low';
      case SortOption.newest:
        return 'Newest';
    }
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});
  final SortOption current;

  @override
  Widget build(BuildContext context) {
    final options = SortOption.values;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio<SortOption>(
                  value: o,
                  groupValue: current,
                  onChanged: (_) => Navigator.pop(context, o),
                ),
                title: Text(o.label),
                onTap: () => Navigator.pop(context, o),
              ),
          ],
        ),
      ),
    );
  }
}

class _Product {
  final String id;
  final String title;
  final String? brand;
  final String imageUrl;
  final double price;
  final int discount; // %
  final int popularity; // 0..100
  final DateTime createdAt;

  _Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.popularity,
    required this.createdAt,
    this.brand,
  });
}

// A tiny badge used on app bar icons
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
