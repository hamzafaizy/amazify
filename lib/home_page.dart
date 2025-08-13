import 'package:amazify/core/theme/custom_theme/theme_toggle.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageCtrl = PageController(viewportFraction: .9);
  int _bannerIndex = 0;
  bool _loading = false; // (only used by pull-to-refresh; harmless if unused)
  final _liked = <int>{};

  // Fake data — swap with your backend/bloc later.
  final _categories = const [
    'All',
    'Phones',
    'Laptops',
    'Audio',
    'Wearables',
    'Gaming',
  ];
  final _banners = const [
    'Summer Sale • Up to 40% off',
    'New Arrivals • Wearables',
    'Weekend Deals • Gaming',
  ];
  final _products = List.generate(
    12,
    (i) => _Product(
      id: i,
      name: [
        'AirPods Max',
        'Pixel 9',
        'PS5 Controller',
        'MacBook Air',
        'Galaxy Watch',
        'Sony XM5',
        'iPad Air',
        'ThinkPad X1',
        'Nintendo Switch',
        'Kindle',
        'Beats Fit Pro',
        'Logitech MX',
      ][i % 12],
      price: [
        579,
        999,
        69,
        1199,
        279,
        399,
        599,
        1899,
        299,
        149,
        199,
        129,
      ][i % 12].toDouble(),
      rating: [
        4.7,
        4.3,
        4.8,
        4.6,
        4.1,
        4.5,
        4.4,
        4.6,
        4.2,
        4.0,
        4.3,
        4.7,
      ][i % 12],
    ),
  );

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: false,
              title: Text(
                'Amazify',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    height: 1000,
                    width: 1000,
                    child: ThemeToggle(),
                  ), // ⬅️ pretty 3‑way toggle
                ),
              ],
            ),

            // Search + filter row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
            ),

            // Categories chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(_categories[i]),
                    selected: i == 0,
                    onSelected: (_) {},
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _categories.length,
                ),
              ),
            ),

            // Banner carousel
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemCount: _banners.length,
                      itemBuilder: (_, i) => _BannerCard(text: _banners[i]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_banners.length, (i) {
                      final active = i == _bannerIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: active ? 18 : 6,
                        decoration: BoxDecoration(
                          color: active ? cs.primary : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Popular Products',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
              ),
            ),

            // Products grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 250,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate((context, i) {
                  final p = _products[i];
                  final liked = _liked.contains(p.id);
                  return _ProductCard(
                    product: p,
                    liked: liked,
                    onLike: () => setState(() {
                      liked ? _liked.remove(p.id) : _liked.add(p.id);
                    }),
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Open ${p.name}')));
                    },
                  );
                }, childCount: _products.length),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
        ],
        onDestinationSelected: (_) {},
        selectedIndex: 0,
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.tertiaryContainer],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -10,
              child: Icon(
                Icons.shopping_bag,
                size: 140,
                color: cs.onPrimaryContainer.withOpacity(.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onLike,
    required this.liked,
  });

  final _Product product;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 48),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: text.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                    color: liked ? cs.error : null,
                    tooltip: 'Save',
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded),
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

class _Product {
  final int id;
  final String name;
  final double price;
  final double rating;
  const _Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
  });
}
