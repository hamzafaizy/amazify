import 'package:amazify/features/shop/presentation/widgets/badge_button.dart';
import 'package:amazify/features/shop/presentation/widgets/brand_card.dart';
import 'package:amazify/features/shop/presentation/widgets/category_bubble.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/shop/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _brandCtrl = PageController(viewportFraction: 0.88);
  int _brandPage = 0;

  final List<_Category> _categories = const [
    _Category('Sports', Icons.sports_soccer),
    _Category('Furniture', Icons.chair_outlined),
    _Category('Electro', Icons.devices_other),
    _Category('Clothes', Icons.checkroom_outlined),
    _Category('Beauty', Icons.brush_outlined),
    _Category('Books', Icons.menu_book_outlined),
  ];

  final List<BrandCardData> _brands = const [
    BrandCardData('Nike', 'Air Zoom Series', 24),
    BrandCardData('Adidas', 'Ultraboost Line', 18),
    BrandCardData('IKEA', 'Minimal Chairs', 12),
    BrandCardData('Apple', 'Latest Accessories', 9),
  ];

  final List<_Product> _products = const [
    _Product('Nike Air Max', 129.99),
    _Product('Adidas Samba', 109.00),
    _Product('Wooden Chair', 79.50),
    _Product('Smart Watch', 199.00),
    _Product('Blue Hoodie', 49.99),
    _Product('Wireless Buds', 59.99),
    _Product('Reading Lamp', 39.50),
    _Product('Fitness Bottle', 19.99),
  ];

  final Set<int> _liked = {};

  @override
  void initState() {
    super.initState();
    _brandCtrl.addListener(() {
      final page = _brandCtrl.page?.round() ?? 0;
      if (page != _brandPage) setState(() => _brandPage = page);
    });
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======== HEADER (Curved Primary) ========
            ClipPath(
              clipper: const RoundedShape(),
              child: Container(
                width: double.infinity,

                height: 370,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.primary.withOpacity(0.85)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image (optional)
                    Positioned(
                      top: -110,
                      right: -150,
                      child: circular_fadbox(cs: cs),
                    ),
                    Positioned(
                      top: 150,
                      right: -120,
                      child: circular_fadbox(cs: cs),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //----------- Header Title -----------//
                            //----------- Custom AppBar -----------//
                            CustomAppBar(
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Discover amazing products",
                                    style: text.bodyMedium?.copyWith(
                                      color: cs.onPrimary.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Welcome to Amazify",
                                    style: text.titleLarge?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              showBackArrow: false,
                              backgroundColor: Colors.transparent,
                              actions: [
                                BadgeIconButton(
                                  icon: Iconsax.notification,
                                  count: 3,
                                  iconColor: cs.onPrimary.withOpacity(0.9),
                                  badgeColor: cs.error.withOpacity(0.9),
                                  onPressed: () {},
                                ),
                                BadgeIconButton(
                                  icon: Iconsax.shopping_bag,
                                  count: 12,
                                  iconColor: cs.onPrimary.withOpacity(0.9),
                                  badgeColor: cs.error.withOpacity(0.9),
                                  onPressed: () {},
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            /////////// Search bar /////////
                            Center(
                              child: SizedBox(
                                width: 400,
                                child: customSearchBar(
                                  hint: "Search for Store",
                                  fillColor: Colors.white.withOpacity(0.12),
                                  textColor: cs.onPrimary,
                                  iconColor: cs.onPrimary.withOpacity(0.9),
                                  borderColor: Colors.white.withOpacity(0.18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            /////////// Popular Categories /////////
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Popular Categories",
                                  style: text.titleMedium?.copyWith(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            //---------- Categories list ----------//
                            SizedBox(
                              height: 92,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 7),
                                itemBuilder: (_, i) {
                                  final c = _categories[i];
                                  return CategoryBubble(
                                    label: c.name,
                                    icon: c.icon,
                                    bg: Colors.white.withOpacity(0.16),
                                    fg: cs.onPrimary,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======== CONTENT (Rounded top) ========
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Brand swipe cards
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _brandCtrl,
                    itemCount: _brands.length,
                    itemBuilder: (_, i) => BrandCard(data: _brands[i]),
                  ),
                ),
                const SizedBox(height: 8),
                // Dots
                SizedBox(
                  height: 28,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _brands.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 5),
                    itemBuilder: (_, i) {
                      final active = i == _brandPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: active ? 22 : 5,
                        width: active ? 22 : 5,
                        decoration: BoxDecoration(
                          color: active
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Popular Products + View all
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "Popular Products",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View all"),
                      ),
                    ],
                  ),
                ),

                // Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    shrinkWrap: true,
                    itemCount: _products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (_, i) {
                      final p = _products[i];
                      final liked = _liked.contains(i);
                      return _ProductCard(
                        name: p.name,
                        price: p.price,
                        liked: liked,
                        onLike: () {
                          setState(() {
                            if (liked) {
                              _liked.remove(i);
                            } else {
                              _liked.add(i);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class circular_fadbox extends StatelessWidget {
  const circular_fadbox({super.key, required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(200),
      ),
    );
  }
}

// -------------------- Widgets & Models --------------------

class _Product {
  final String name;
  final double price;
  const _Product(this.name, this.price);
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.price,
    required this.liked,
    required this.onLike,
  });

  final String name;
  final double price;
  final bool liked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 44),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Like button
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: onLike,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked
                      ? Colors.redAccent
                      : cs.onSurface.withOpacity(0.6),
                ),
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}
