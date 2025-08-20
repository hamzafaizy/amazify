// lib/features/shop/presentation/pages/productview.dart
import 'package:amazify/features/shop/presentation/pages/cart.dart';
import 'package:amazify/features/shop/presentation/pages/notifications.dart';
import 'package:amazify/features/shop/presentation/widgets/badge_button.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/shop/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProductView extends StatefulWidget {
  const ProductView({
    super.key,
    required this.heroTag,
    required this.images,
    this.title = 'Nike Air Zoom Pegasus 41',
    this.brand = 'Nike',
    this.price = 129.99,
    this.currency = '\$',
    this.rating = 4.7,
    this.reviews = 268,
    this.initialIndex = 0,
  });

  final String heroTag;
  final List<String> images;
  final String title;
  final String brand;
  final double price;
  final String currency;
  final double rating;
  final int reviews;
  final int initialIndex;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late int _i = widget.initialIndex.clamp(
    0,
    (widget.images.isEmpty ? 1 : widget.images.length) - 1,
  );
  bool _fav = false;
  int _qty = 1;
  int _size = 1;
  int _color = 0;
  bool _open = false;

  List<String> get _imgs => widget.images.isEmpty
      ? [
          'assets/products/p1.jpg',
          'assets/products/p2.png',
          'assets/products/p7.jpg',
        ]
      : widget.images;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ======== HEADER (Curved Primary) ========

          // ───────── Hero image with overlay appbar ─────────
          SliverAppBar(
            //backgroundColor: Colors.amber,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            floating: false,
            expandedHeight: 360,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
              child: _roundIcon(
                icon: Iconsax.arrow_left_2,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                child: _roundIcon(
                  icon: _fav ? Iconsax.heart5 : Iconsax.heart,
                  onTap: () => setState(() => _fav = !_fav),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Hero(
                    key: ValueKey(_imgs[_i]),
                    tag: widget.heroTag,
                    child: _img(_imgs[_i], height: 320),
                  ),
                ),
              ),
            ),
          ),

          // ───────── Variant thumbnails ─────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.transparent,
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _imgs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, idx) {
                  final sel = idx == _i;
                  return GestureDetector(
                    onTap: () => setState(() => _i = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        //color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sel ? cs.primary : cs.outlineVariant,
                          width: sel ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _img(
                          _imgs[idx],
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ───────── Curved details sheet ─────────
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: RoundedShape(),
              child: Container(
                color: cs.surface,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.brand}\n',
                                  style: text.labelLarge?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.title,
                                  style: text.titleLarge?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.currency}${widget.price.toStringAsFixed(2)}',
                          style: text.headlineSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        Icon(
                          Iconsax.star1,
                          size: 18,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.rating}',
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '  (${widget.reviews} reviews)',
                          style: text.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Size
                    Text(
                      'Size',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: List.generate(4, (i) {
                        final labels = ['US 7', 'US 8', 'US 9', 'US 10'];
                        final sel = i == _size;
                        return ChoiceChip(
                          label: Text(labels[i]),
                          selected: sel,
                          onSelected: (_) => setState(() => _size = i),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selectedColor: cs.primaryContainer,
                          labelStyle: TextStyle(
                            color: sel ? cs.onPrimaryContainer : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Color
                    Text(
                      'Color',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final colors = [
                          Colors.black,
                          Colors.red,
                          Colors.blue,
                          Colors.grey,
                        ];
                        final sel = i == _color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _color = i),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: sel ? cs.primary : cs.outlineVariant,
                                  width: sel ? 2 : 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Quantity
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _qtyBox(
                          context,
                          value: _qty,
                          onMinus: () =>
                              setState(() => _qty = (_qty - 1).clamp(1, 99)),
                          onPlus: () =>
                              setState(() => _qty = (_qty + 1).clamp(1, 99)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _open
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        'Experience cushioning and responsiveness with the Pegasus 41. Mesh upper, responsive midsole, and durable outsole built for everyday runs.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      secondChild: Text(
                        'Experience cushioning and responsiveness with the Pegasus 41. Mesh upper for breathable comfort, redesigned midsole for smoother transitions, and durable outsole built for everyday runs.\n\n'
                        '• Breathable mesh upper\n'
                        '• Responsive foam midsole\n'
                        '• Durable rubber outsole\n'
                        '• True-to-size fit',
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _open = !_open),
                      icon: Icon(
                        _open ? Iconsax.arrow_up_1 : Iconsax.arrow_down_1,
                        size: 18,
                      ),
                      label: Text(_open ? 'Show less' : 'Read more'),
                    ),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Iconsax.add, size: 18),
                            label: const Text('Add to Cart'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Iconsax.flash, size: 18),
                            label: const Text('Buy Now'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
          ),
        ],
      ),
    );
  }

  // helpers
  Widget _img(
    String p, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
  }) {
    final isNet = p.startsWith('http');
    return isNet
        ? Image.network(p, height: height, width: width, fit: fit)
        : Image.asset(p, height: height, width: width, fit: fit);
  }

  Widget _roundIcon({required IconData icon, VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }

  Widget _qtyBox(
    BuildContext ctx, {
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final cs = Theme.of(ctx).colorScheme;
    final text = Theme.of(ctx).textTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _qtyBtn(Iconsax.minus, onMinus),
          Container(width: 1, height: 28, color: cs.outlineVariant),
          SizedBox(
            width: 46,
            child: Center(
              child: Text(
                '$value',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: cs.outlineVariant),
          _qtyBtn(Iconsax.add, onPlus),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(icon, size: 18),
    ),
  );
}
