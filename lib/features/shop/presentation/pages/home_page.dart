import 'package:amazify/features/shop/presentation/pages/cart.dart';
import 'package:amazify/features/shop/presentation/pages/notifications.dart';
import 'package:amazify/features/shop/presentation/pages/product_view.dart';
import 'package:amazify/features/shop/presentation/widgets/badge_button.dart';
import 'package:amazify/features/shop/presentation/widgets/brand_card.dart';
import 'package:amazify/features/shop/presentation/widgets/category_bubble.dart';
import 'package:amazify/features/shop/presentation/widgets/circular_fabox.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/dashed_carousal_ind.dart';
import 'package:amazify/features/shop/presentation/widgets/product_box.dart';
import 'package:amazify/features/shop/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/shop/presentation/widgets/search_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  final controller = CarouselSliderController(); // v5+ controller
  int current = 0;

  final variants = [
    'https://backend.orbitvu.com/sites/default/files/image/sport-shoe-white-background.jpeg',
    'assets/products/p11.jpg',
    'assets/products/p12.jpg',
    'assets/products/p13.jpg',
    'assets/products/p5.png',
  ];

  final List<String> images = [
    'assets/Images/ban1.png',
    'assets/Images/ban2.png',
    'assets/Images/ban3.png',
    'assets/Images/ban4.png',
    'assets/Images/ban5.png',
  ];
  final List<Category> _categories = const [
    Category('Sports', Icons.sports_soccer),
    Category('Furniture', Icons.chair_outlined),
    Category('Electro', Icons.devices_other),
    Category('Clothes', Icons.checkroom_outlined),
    Category('Beauty', Icons.brush_outlined),
    Category('Books', Icons.menu_book_outlined),
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationsPage(),
                                      ),
                                    );
                                  },
                                ),
                                BadgeIconButton(
                                  icon: Iconsax.shopping_bag,
                                  count: 12,
                                  iconColor: cs.onPrimary.withOpacity(0.9),
                                  badgeColor: cs.error.withOpacity(0.9),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartPage(),
                                      ),
                                    );
                                  },
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
                const SizedBox(height: 12),
                // Brand swipe cards
                Center(
                  child: SizedBox(
                    height: 220,
                    width: 400,
                    child: CarouselSlider(
                      carouselController: controller,
                      items: images.map((path) {
                        return RoundedBannerImage(
                          imageUrl: path,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          borderRadius: 16,
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 220,
                        viewportFraction: 1,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          setState(() => current = index);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Dashed indicator
                DashedCarouselIndicator(
                  length: images.length,
                  currentIndex: current,
                  dashWidth: 18,
                  dashHeight: 3.5,
                  spacing: 6,
                  activeScale: 1.8,
                  activeColor: cs.primary,
                  inactiveColor: cs.onSurface.withOpacity(0.25),
                  onTap: (i) => controller.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ), // Dots
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
                // Grid
                SizedBox(
                  width: double.infinity,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 8,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, i) {
                      final id = 'product_$i';
                      final image =
                          'https://backend.orbitvu.com/sites/default/files/image/sport-shoe-white-background.jpeg';

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ProductView(
                                heroTag: id,
                                images: variants,
                                title: 'Sport Shoe $i',
                                brand: 'Nike',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: id,
                          child: ProductCard(
                            id: id,
                            title: 'Sport Shoe $i',
                            imageUrl: image,
                            price: 50,
                            discountPercent: 50,
                          ),
                        ),
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
