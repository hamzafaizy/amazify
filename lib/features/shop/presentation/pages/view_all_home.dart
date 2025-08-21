// lib/features/shop/presentation/pages/view_all.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Your widgets
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/product_box.dart';
import 'package:amazify/features/shop/presentation/pages/product_view.dart';

class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key, this.title = 'Popular Products', this.items});

  final String title;
  final List<ProductItem>? items;

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

/* ───────────────────────── Models & Sorting ───────────────────────── */

class ProductItem {
  final String id;
  final String title;
  final String image; // asset or network
  final String brand;
  final double price;
  final double? oldPrice;
  final double rating; // 0..5
  final bool onSale;
  final DateTime createdAt;
  final int popularity; // higher = more popular

  const ProductItem({
    required this.id,
    required this.title,
    required this.image,
    required this.brand,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.onSale = false,
    required this.createdAt,
    this.popularity = 0,
  });
}

enum SortOption { name, priceHigh, priceLow, sale, newest, popularity }

const _sortLabels = {
  SortOption.name: 'Name',
  SortOption.priceHigh: 'Higher price',
  SortOption.priceLow: 'Lower price',
  SortOption.sale: 'Sale',
  SortOption.newest: 'Newest',
  SortOption.popularity: 'Popularity',
};

List<ProductItem> _sortItems(List<ProductItem> list, SortOption by) {
  final items = [...list];
  switch (by) {
    case SortOption.name:
      items.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      break;
    case SortOption.priceHigh:
      items.sort((b, a) => a.price.compareTo(b.price));
      break;
    case SortOption.priceLow:
      items.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOption.sale:
      items.sort((b, a) {
        final aSale = a.onSale ? 1 : 0;
        final bSale = b.onSale ? 1 : 0;
        final saleCmp = aSale.compareTo(bSale);
        if (saleCmp != 0) return -saleCmp; // onSale first
        final aDisc = (a.oldPrice ?? a.price) - a.price;
        final bDisc = (b.oldPrice ?? b.price) - b.price;
        return bDisc.compareTo(aDisc);
      });
      break;
    case SortOption.newest:
      items.sort((b, a) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOption.popularity:
      items.sort((b, a) => a.popularity.compareTo(b.popularity));
      break;
  }
  return items;
}

/* ───────────────────────── Page ───────────────────────── */

class _ViewAllPageState extends State<ViewAllPage> {
  SortOption _sort = SortOption.popularity;

  final List<String> _variants = const [
    'https://backend.orbitvu.com/sites/default/files/image/sport-shoe-white-background.jpeg',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200',
    'https://images.unsplash.com/photo-1523381294911-8d3cead13475?q=80&w=1200',
  ];

  late List<ProductItem> _all = widget.items ?? _demoItems;
  List<ProductItem> get _sorted => _sortItems(_all, _sort);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          showBackArrow: true,
          title: Text(widget.title), // many CustomAppBar impls expect String
          actions: const [],
        ),
      ),
      body: Column(
        children: [
          // Sort row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _SortBox(
                    value: _sort,
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                ),
                const SizedBox(width: 10),
                // Results count (small helper)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(.5),
                    ),
                  ),
                  child: Text(
                    '${_sorted.length} items',
                    style: text.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated grid (cross-fade when sorting)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: LayoutBuilder(
                key: ValueKey(_sort), // rebuild on sort change with animation
                builder: (context, c) {
                  final width = c.maxWidth;
                  final crossAxisCount = width >= 1200
                      ? 5
                      : width >= 900
                      ? 4
                      : width >= 600
                      ? 3
                      : 2;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .68,
                    ),
                    itemCount: _sorted.length,
                    itemBuilder: (context, i) {
                      final item = _sorted[i];
                      final heroTag = item.id;

                      // Staggered fade + slide
                      final delay = Duration(milliseconds: 40 * i);
                      return _StaggeredItem(
                        delay: delay,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductView(
                                  heroTag: heroTag,
                                  images: _variants,
                                  title: item.title,
                                  brand: item.brand,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: heroTag,
                            // Use your ProductCard from product_box.dart
                            child: ProductCard(
                              id: item.id,
                              title: item.title,
                              imageUrl: item.image,
                              price: item.price,
                              discountPercent: item.oldPrice == null
                                  ? 0
                                  : (((item.oldPrice! - item.price) /
                                                item.oldPrice!) *
                                            100)
                                        .clamp(0, 99)
                                        .round(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── UI Bits ───────────────────────── */

class _SortBox extends StatelessWidget {
  const _SortBox({required this.value, required this.onChanged});

  final SortOption value;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: value,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1),
          borderRadius: BorderRadius.circular(12),
          items: SortOption.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(_sortLabels[e]!, style: text.bodyMedium),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Simple staggered fade+slide for grid items
class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/* ───────────────────────── Demo Data ───────────────────────── */

final List<ProductItem> _demoItems = [
  ProductItem(
    id: 'p1',
    title: 'Nike Air Zoom Pegasus 41',
    image:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200',
    brand: 'Nike',
    price: 12999,
    oldPrice: 15999,
    rating: 4.8,
    onSale: true,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    popularity: 95,
  ),
  ProductItem(
    id: 'p2',
    title: 'Adidas Ultraboost Light',
    image:
        'https://images.unsplash.com/photo-1543508282-6319a3e2621f?q=80&w=1200',
    brand: 'Adidas',
    price: 18999,
    rating: 4.6,
    onSale: false,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    popularity: 85,
  ),
  ProductItem(
    id: 'p3',
    title: 'Puma RS-X Reinvent',
    image:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200',
    brand: 'Puma',
    price: 10999,
    oldPrice: 13999,
    rating: 4.3,
    onSale: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    popularity: 78,
  ),
  ProductItem(
    id: 'p4',
    title: 'New Balance 9060',
    image:
        'https://images.unsplash.com/photo-1523381294911-8d3cead13475?q=80&w=1200',
    brand: 'New Balance',
    price: 21499,
    rating: 4.7,
    onSale: false,
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    popularity: 90,
  ),
  ProductItem(
    id: 'p5',
    title: 'ASICS Gel-Kayano 31',
    image:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200',
    brand: 'ASICS',
    price: 17499,
    oldPrice: 19999,
    rating: 4.5,
    onSale: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    popularity: 88,
  ),
];
