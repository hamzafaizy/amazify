// lib/features/shop/presentation/pages/product_view.dart
import 'package:amazify/features/shop/presentation/pages/ratings.dart';
import 'package:amazify/features/shop/presentation/widgets/variation_card_prod_view.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// adjust these imports to your paths
import 'package:amazify/features/shop/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';

class ProductView extends StatefulWidget {
  const ProductView({
    super.key,
    required this.heroTag,
    required this.images, // asset or network
    this.title = 'Green Nike sports shoe',
    this.brand = 'Nike',
    this.brandLogo, // asset/network path
    this.priceMin = 122.8,
    this.priceMax = 334.0,
    this.oldPrice = 459.0,
    this.discountPercent = 78,
    this.rating = 5.0,
    this.reviews = 200,
    this.inStock = true,
    this.colors = const [
      Color(0xFF1E90FF),
      Color(0xFF2ECC71),
      Color(0xFF222222),
    ],
    this.sizes = const ['40', '41', '42', '43'],
  });

  final String heroTag;
  final List<String> images;
  final String title, brand;
  final String? brandLogo;
  final double priceMin, priceMax, oldPrice;
  final int discountPercent, reviews;
  final double rating;
  final bool inStock;
  final List<Color> colors;
  final List<String> sizes;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with TickerProviderStateMixin {
  // UI state
  int _img = 0;
  int _qty = 1;
  int _color = 0;
  int _size = 0;
  bool _more = false;

  // Live price for VariationCard (NOT in the title row)
  late double _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = _computePrice(_color, _size);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // Bottom bar: qty + add to cart (unchanged UI)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            children: [
              _qtyBtn(
                Iconsax.minus,
                () => setState(() => _qty = (_qty > 1) ? _qty - 1 : 1),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Text(
                  '$_qty',
                  key: ValueKey(_qty),
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              _qtyBtn(Iconsax.add, () => setState(() => _qty++)),
              const Spacer(),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.shopping_bag),
                  label: const Text('Add to cart'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─────────────── Top Part: clipped bg + hero image + appbar + thumbnails ───────────────
            SizedBox(
              height: 420,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: RoundedShape(),
                    child: Container(
                      height: 420,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary.withOpacity(.12),
                            cs.secondary.withOpacity(.10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Product image (tap -> full screen)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 24,
                        right: 24,
                        bottom: 60,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) =>
                            FadeTransition(opacity: a, child: c),
                        child: Hero(
                          key: ValueKey(_img),
                          tag: widget
                              .heroTag, // keep hero for grid->detail transition
                          child: GestureDetector(
                            onTap: () =>
                                _openFullScreenGallery(startIndex: _img),
                            child: _image(
                              widget.images[_img],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // AppBar
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CustomAppBar(
                        showBackArrow: true,
                        backgroundColor: Colors.transparent,
                        actions: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Iconsax.heart, color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Thumbnails
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Center(
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(16),
                        color: cs.surface.withOpacity(.95),
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: SizedBox(
                            height: 64,
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, i) {
                                final selected = i == _img;
                                return InkWell(
                                  onTap: () => setState(() => _img = i),
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? cs.primary
                                            : cs.outlineVariant,
                                        width: selected ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _thumb(widget.images[i]),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemCount: widget.images.length,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─────────────── Details (Second Part) ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // rating + share
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.rating.toStringAsFixed(1)} (${widget.reviews} reviews)',
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.share),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // discount + (STATIC) price range in the title row — no dynamic change here
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade600,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${widget.discountPercent}% OFF',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${widget.priceMin.toStringAsFixed(1)} - \$${widget.priceMax.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // old price (strikethrough)
                  Text(
                    '\$${widget.oldPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // stock
                  Text(
                    'Stock: ${widget.inStock ? 'In Stock' : 'Out of Stock'}',
                    style: TextStyle(
                      color: widget.inStock ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // brand
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: widget.brandLogo == null
                            ? null
                            : (widget.brandLogo!.startsWith('http')
                                  ? NetworkImage(widget.brandLogo!)
                                  : AssetImage(widget.brandLogo!)
                                        as ImageProvider),
                        child: widget.brandLogo == null
                            ? Text(widget.brand[0])
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.brand,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ───── Variation card shows LIVE price ─────
                  VariationCard(
                    title: 'Variation',
                    price: _currentPrice, // ← dynamic
                    oldPrice: widget.oldPrice, // keep your old price
                    inStock: widget.inStock,
                    description:
                        'Great traction, breathable mesh, daily trainer.',
                  ),

                  // color
                  Text('Color', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: List.generate(widget.colors.length, (i) {
                      final sel = _color == i;
                      return InkWell(
                        onTap: () => _onSelect(
                          colorIndex: i,
                        ), // recomputes _currentPrice
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.colors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: sel ? 3 : 1.2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // size
                  Text('Size', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(widget.sizes.length, (i) {
                      final sel = _size == i;
                      return ChoiceChip(
                        label: Text(widget.sizes[i]),
                        selected: sel,
                        onSelected: (_) =>
                            _onSelect(sizeIndex: i), // recomputes _currentPrice
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // quantity (mini label)
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('56', style: Theme.of(context).textTheme.bodySmall),

                  const SizedBox(height: 16),

                  // actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Checkout'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Buy Now'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  AnimatedCrossFade(
                    firstChild: Text(
                      'Lightweight, breathable upper with responsive cushioning. Durable outsole with multi-surface grip.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      'Lightweight, breathable upper with responsive cushioning. Durable outsole with multi-surface grip. Padded collar for comfort, reinforced toe for durability, and a midfoot shank for stability during quick moves.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    crossFadeState: _more
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _more = !_more),
                      child: Text(_more ? 'Show less' : 'Show more'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),

                  // reviews row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReviewsPage()),
                      );
                    },
                    child: Row(
                      children: [
                        const Text("Reviews (200)"),
                        const Spacer(),
                        const Icon(Iconsax.arrow_right_3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Full-screen Gallery ─────────────────────────
  /// Pushes a true full-screen, swipeable, pinch-zoomable gallery.
  void _openFullScreenGallery({required int startIndex}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          images: widget.images,
          initialIndex: startIndex,
          heroTag: widget.heroTag,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ───────────────────────── Variation Selection ─────────────────────────
  /// Centralized selection handler so we always recompute price when color/size change.
  void _onSelect({int? colorIndex, int? sizeIndex}) {
    setState(() {
      if (colorIndex != null) _color = colorIndex;
      if (sizeIndex != null) _size = sizeIndex;
      _currentPrice = _computePrice(
        _color,
        _size,
      ); // update price for VariationCard
    });
  }

  /// Deterministic price within [priceMin, priceMax] based on selected color/size.
  /// Replace with a real matrix later if you have one.
  double _computePrice(int colorIdx, int sizeIdx) {
    final cDen = (widget.colors.length - 1).clamp(1, 9999);
    final sDen = (widget.sizes.length - 1).clamp(1, 9999);
    final cFrac = colorIdx / cDen;
    final sFrac = sizeIdx / sDen;
    final t = (0.6 * sFrac + 0.4 * cFrac).clamp(0.0, 1.0);
    return widget.priceMin + t * (widget.priceMax - widget.priceMin);
  }

  // ───────────────────────── UI helpers ─────────────────────────

  Widget _image(String path, {BoxFit fit = BoxFit.cover}) {
    final img = path.startsWith('http')
        ? Image.network(path, fit: fit)
        : Image.asset(path, fit: fit);
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 250),
      child: img,
    );
  }

  Widget _thumb(String path) {
    return path.startsWith('http')
        ? Image.network(path, width: 48, height: 48, fit: BoxFit.cover)
        : Image.asset(path, width: 48, height: 48, fit: BoxFit.cover);
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return Ink(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: const StadiumBorder(),
      ),
      child: IconButton(onPressed: onTap, icon: Icon(icon)),
    );
  }

  // Optional compact control
  Widget _miniQtyBtn(IconData icon, VoidCallback onTap) {
    return Ink(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: IconButton(icon: Icon(icon, size: 18), onPressed: onTap),
      ),
    );
  }
}

// ───────────────────────── Full-screen gallery page ─────────────────────────
class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
    required this.heroTag,
  });

  final List<String> images;
  final int initialIndex;
  final String heroTag;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _pc = PageController(
    initialPage: widget.initialIndex,
  );
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // full black, true full-screen
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // tap anywhere to close
        child: Stack(
          children: [
            PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: widget.images.length,
              itemBuilder: (_, i) {
                final path = widget.images[i];
                final img = path.startsWith('http')
                    ? Image.network(path, fit: BoxFit.contain)
                    : Image.asset(path, fit: BoxFit.contain);

                return Center(
                  child: Hero(
                    tag: widget.heroTag, // smooth transition from detail image
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: img,
                    ),
                  ),
                );
              },
            ),

            // Close + counter
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      '${_current + 1}/${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
