import 'package:amazify/features/shop/presentation/widgets/badge_button.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/product_box.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // ───────────── Top content ─────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: CustomAppBar(
                      title: Text(
                        'Store',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      showBackArrow: false,
                      backgroundColor: Colors.transparent,
                      actions: [
                        BadgeIconButton(
                          icon: Iconsax.heart,
                          count: 3,
                          iconColor: cs.onSurface.withOpacity(0.9),
                          badgeColor: cs.error.withOpacity(0.9),
                          onPressed: () {},
                        ),
                        BadgeIconButton(
                          icon: Iconsax.shopping_bag,
                          count: 12,
                          iconColor: cs.onSurface.withOpacity(0.9),
                          badgeColor: cs.error.withOpacity(0.9),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Search
                  const SizedBox(height: 16),
                  const _SearchBar(),

                  // Featured Brands
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Featured Brands',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _FeaturedBrandGrid(
                    items: [
                      _BrandInfo('Nike', '265 products'),
                      _BrandInfo('Adidas', '241 products'),
                      _BrandInfo('Puma', '118 products'),
                      _BrandInfo('Reebok', '87 products'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ───────────── Bottom sheet (tabs + content) ─────────────
          const _BottomShelf(collapsedChildSize: 0.22),
        ],
      ),
    );
  }
}

// ────────────────────────── Simple widgets ──────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products or brands',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _BrandInfo {
  final String name;
  final String subtitle;
  const _BrandInfo(this.name, this.subtitle);
}

class _FeaturedBrandGrid extends StatelessWidget {
  const _FeaturedBrandGrid({required this.items});
  final List<_BrandInfo> items;

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
          final cs = Theme.of(context).colorScheme;
          final text = Theme.of(context).textTheme;
          final item = items[i];
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer.withOpacity(0.4),
                  child: Text(
                    item.name[0],
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(Icons.verified, size: 16, color: cs.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: text.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────── Bottom shelf ──────────────────────────

class _BottomShelf extends StatelessWidget {
  const _BottomShelf({required this.collapsedChildSize});
  final double collapsedChildSize;

  static const _categories = <String>[
    'Sports',
    'Furniture',
    'Electronics',
    'Fashion',
    'Beauty',
    'Toys',
    'Books',
  ];

  static const _thumbs = [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    'https://images.unsplash.com/photo-1523381294911-8d3cead13475?w=400',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    _BrandHighlightPair pairFor(String c) {
      switch (c) {
        case 'Sports':
          return const _BrandHighlightPair('Nike', 'Adidas');
        case 'Furniture':
          return const _BrandHighlightPair('IKEA', 'Wayfair');
        case 'Electronics':
          return const _BrandHighlightPair('Samsung', 'Sony');
        case 'Fashion':
          return const _BrandHighlightPair('Zara', 'H&M');
        case 'Beauty':
          return const _BrandHighlightPair('L’Oréal', 'Sephora');
        case 'Toys':
          return const _BrandHighlightPair('LEGO', 'Mattel');
        case 'Books':
          return const _BrandHighlightPair('Penguin', 'HarperCollins');
        default:
          return const _BrandHighlightPair('Brand A', 'Brand B');
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: collapsedChildSize,
      minChildSize: collapsedChildSize,
      maxChildSize: 0.98,
      snap: true,
      builder: (context, scrollController) {
        return Material(
          color: cs.surface,
          elevation: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: DefaultTabController(
            length: _categories.length,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      isScrollable: true,
                      dividerHeight: 0,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: cs.primary,
                      unselectedLabelColor: cs.onSurfaceVariant,
                      indicator: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.primary),
                      ),
                      tabs: [
                        for (final c in _categories)
                          Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(c),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Content per tab
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final c in _categories)
                        _CategoryBody(
                          scrollController: scrollController,
                          aName: pairFor(c).a,
                          bName: pairFor(c).b,
                          aSub: 'Top picks • $c',
                          bSub: 'Trending • $c',
                          thumbs: _thumbs,
                          productCount: 8,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({
    required this.scrollController,
    required this.aName,
    required this.bName,
    required this.aSub,
    required this.bSub,
    required this.thumbs,
    required this.productCount,
  });

  final ScrollController scrollController;
  final String aName, bName, aSub, bSub;
  final List<String> thumbs;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget brandCard(String name, String sub) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer.withOpacity(0.4),
                  child: Text(
                    name[0],
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(Icons.verified, size: 18, color: cs.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: text.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1.25,
                          child: Image.network(thumbs[i], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        brandCard(aName, aSub),
        const SizedBox(height: 12),
        brandCard(bName, bSub),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'You might like',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('View all')),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (_, i) => ProductCard(
            id: 'prod_$i',
            title: 'Item ${i + 1}',
            imageUrl:
                'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=400',
            price: 49.99 + i * 5,
            discountPercent: i.isEven ? 20 : 0,
          ),
        ),
      ],
    );
  }
}

// tiny helper for brand pair labels (no extra map clutter)
class _BrandHighlightPair {
  final String a, b;
  const _BrandHighlightPair(this.a, this.b);
}
