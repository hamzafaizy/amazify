// lib/features/shop/presentation/pages/sports.dart
import 'package:amazify/features/shop/presentation/pages/product_view.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SportsPage extends StatefulWidget {
  const SportsPage({super.key});

  @override
  State<SportsPage> createState() => _SportsPageState();
}

class _SportsPageState extends State<SportsPage> {
  final Set<String> _liked = {};

  // Demo data — replace with real models/API later
  final List<_Item> equipment = const [
    _Item(
      id: 'eq1',
      title: 'Cricket Bat MRF',
      desc: 'Grade A English willow',
      brand: 'MRF',
      image:
          'https://tiimg.tistatic.com/fp/1/006/509/mr102-hd-printed-men-s-t-shirt-738.jpg',
      priceFrom: 169.0,
      priceTo: 199.0,
    ),
    _Item(
      id: 'eq2',
      title: 'Football Adidas',
      desc: 'Thermo-bonded match ball',
      brand: 'Adidas',
      image:
          'https://images.unsplash.com/photo-1543322748-33df6d3db806?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 59.0,
    ),
    _Item(
      id: 'eq3',
      title: 'Tennis Racket',
      desc: 'Graphite frame • 285g',
      brand: 'Wilson',
      image:
          'https://images.unsplash.com/photo-1521417531039-4a2365716b4b?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 129.0,
      priceTo: 149.0,
    ),
  ];

  final List<_Item> shoes = const [
    _Item(
      id: 'sh1',
      title: 'Nike ZoomX',
      desc: 'Road running • breathable',
      brand: 'Nike',
      image:
          'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 122.8,
      priceTo: 334.0,
    ),
    _Item(
      id: 'sh2',
      title: 'Adidas Predator',
      desc: 'Firm ground • control',
      brand: 'Adidas',
      image:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 199.0,
    ),
    _Item(
      id: 'sh3',
      title: 'Asics Gel-Cumulus',
      desc: 'Neutral cushion • daily',
      brand: 'Asics',
      image:
          'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 139.0,
      priceTo: 169.0,
    ),
  ];

  final List<_Item> tracks = const [
    _Item(
      id: 'ts1',
      title: 'Dri-Fit Tracksuit',
      desc: 'Lightweight • tapered',
      brand: 'Nike',
      image:
          'https://images.unsplash.com/photo-1605731414532-6b26976cc153?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 89.0,
      priceTo: 109.0,
    ),
    _Item(
      id: 'ts2',
      title: 'Essentials Set',
      desc: 'French terry • comfy',
      brand: 'Adidas',
      image:
          'https://images.unsplash.com/photo-1620799139505-2c1b66ea9d78?q=80&w=1200&auto=format&fit=crop',
      priceFrom: 79.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: CustomAppBar(
                  title: Text(
                    'Sports',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  showBackArrow: true,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            // Top banner card (simple, like Home banners)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BannerCard(
                  image:
                      'https://images.unsplash.com/photo-1521417531039-4a2365716b4b?q=80&w=1600&auto=format&fit=crop',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section: Sports Equipment
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Sports Equipment',
                onViewAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: _HorizontalCards(
                items: equipment,
                liked: _liked,
                onToggleLike: _toggleLike,
                onOpen: _openProduct,
              ),
            ),

            // Section: Sports Shoes
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Sports Shoes', onViewAll: () {}),
            ),
            SliverToBoxAdapter(
              child: _HorizontalCards(
                items: shoes,
                liked: _liked,
                onToggleLike: _toggleLike,
                onOpen: _openProduct,
              ),
            ),

            // Section: Track Suits
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Track Suits', onViewAll: () {}),
            ),
            SliverToBoxAdapter(
              child: _HorizontalCards(
                items: tracks,
                liked: _liked,
                onToggleLike: _toggleLike,
                onOpen: _openProduct,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /* ───────────────────────── Helpers ───────────────────────── */

  void _toggleLike(String id) {
    setState(() => _liked.contains(id) ? _liked.remove(id) : _liked.add(id));
  }

  void _openProduct(_Item p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductView(
          heroTag: p.id,
          images: [p.image], // plug your gallery if you have it
          title: p.title,
          brand: p.brand,
        ),
      ),
    );
  }
}

/* ─────────────────────── Models / UI Pieces ─────────────────────── */

class _Item {
  final String id, title, desc, brand, image;
  final double priceFrom;
  final double? priceTo; // null → fixed price

  const _Item({
    required this.id,
    required this.title,
    required this.desc,
    required this.brand,
    required this.image,
    required this.priceFrom,
    this.priceTo,
  });
}

/// Reusable section header (Title + View all)
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TextButton(
            onPressed: onViewAll,
            child: Text('View all', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }
}

/// Simple rounded banner card (like on Home)
class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(image, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, cs.surface.withOpacity(0.12)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable product cards (image left + content right)
class _HorizontalCards extends StatelessWidget {
  const _HorizontalCards({
    required this.items,
    required this.liked,
    required this.onToggleLike,
    required this.onOpen,
  });

  final List<_Item> items;
  final Set<String> liked;
  final void Function(String id) onToggleLike;
  final void Function(_Item p) onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: ListView.separated(
        key: const PageStorageKey('_sports_hlist'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CardH(
          data: items[i],
          liked: liked.contains(items[i].id),
          onFav: () => onToggleLike(items[i].id),
          onTap: () => onOpen(items[i]),
        ),
      ),
    );
  }
}

/// One horizontal product card with heart overlay and “+” button
class _CardH extends StatefulWidget {
  const _CardH({
    required this.data,
    required this.liked,
    required this.onFav,
    required this.onTap,
  });

  final _Item data;
  final bool liked;
  final VoidCallback onFav;
  final VoidCallback onTap;

  @override
  State<_CardH> createState() => _CardHState();
}

class _CardHState extends State<_CardH> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 330,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(.45)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  // Image area
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: SizedBox(
                      width: 120,
                      height: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: widget.data.id,
                            child: Image.network(
                              widget.data.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Heart overlay (top-right of image)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: _FavButton(
                              active: widget.liked,
                              onTap: widget.onFav,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.data.desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(.7),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              // Brand + tick
                              Icon(Icons.verified, size: 16, color: cs.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.data.brand,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Price (fixed or range)
                          Text(
                            widget.data.priceTo == null
                                ? '\$${widget.data.priceFrom.toStringAsFixed(2)}'
                                : '\$${widget.data.priceFrom.toStringAsFixed(2)} - \$${widget.data.priceTo!.toStringAsFixed(2)}',
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Curved “+” button (bottom-right; TL & BR rounded)
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: cs.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    onTap: () {
                      // TODO: Add to cart / quick add
                    },
                    child: const SizedBox(
                      width: 44,
                      height: 40,
                      child: Icon(Iconsax.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Heart (like) button with a tiny animation
class _FavButton extends StatelessWidget {
  const _FavButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active
              ? cs.errorContainer.withOpacity(.9)
              : cs.surface.withOpacity(.85),
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
        ),
        child: Icon(
          active ? Iconsax.heart5 : Iconsax.heart,
          size: 18,
          color: active ? cs.onErrorContainer : cs.onSurface,
        ),
      ),
    );
  }
}
