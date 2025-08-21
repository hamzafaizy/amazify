// lib/features/cart/cart.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:amazify/features/shop/presentation/pages/checkout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

/// Simple cart item model
class CartItem {
  final String id;
  final String title;
  final String image; // asset or network URL
  final String variant; // e.g., "Size M • Black"
  final double price;
  final bool isNetworkImage;
  int qty;
  final int maxQty;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.variant = '',
    this.qty = 1,
    this.maxQty = 10,
    this.isNetworkImage = false,
  });
}

/// Cart page
class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    this.initialItems = const [],
    this.currency = 'Rs ',
    this.onCheckout,
  });

  final List<CartItem> initialItems;
  final String currency;
  final VoidCallback? onCheckout;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late List<CartItem> _items;

  // Pricing knobs
  static const double _shippingFlat = 250.0;
  static const double _freeShipThreshold = 5000.0;

  // Attention pulse for the CTA
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    lowerBound: .98,
    upperBound: 1.02,
  )..repeat(reverse: true);

  // For staggered list entrance
  bool _mountedForStagger = false;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems.isNotEmpty
        ? List.of(widget.initialItems)
        : _demoItems();
    // kick off stagger once first build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _mountedForStagger = true);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ---- Computed totals ----
  double get _subTotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.qty));
  double get _shipping => _items.isEmpty
      ? 0
      : (_subTotal >= _freeShipThreshold ? 0 : _shippingFlat);
  double get _grandTotal => _subTotal + _shipping;

  // ---- Actions ----
  void _incQty(CartItem item) => setState(() {
    if (item.qty < item.maxQty) item.qty++;
  });

  void _decQty(CartItem item) => setState(() {
    if (item.qty > 1) item.qty--;
  });

  void _removeWithUndo(CartItem item, int index) {
    final removed = item;
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _items.insert(index, removed)),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEmpty = _items.isEmpty;

    // Pause pulse when cart is empty
    if (isEmpty && _pulseCtrl.isAnimating) _pulseCtrl.stop();
    if (!isEmpty && !_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            isEmpty ? 'My Cart' : 'My Cart (${_items.length})',
            key: ValueKey(_items.length),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
      ),

      // Animated gradient backdrop for extra flair
      body: Stack(
        children: [
          const _AnimatedBackdrop(),
          isEmpty
              ? _EmptyCart(onBrowse: () => Navigator.maybePop(context))
              : Column(
                  children: [
                    const SizedBox(height: kToolbarHeight + 50),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return _Stagger(
                            enabled: _mountedForStagger,
                            index: i,
                            child: Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: _SwipeDelete(cs: cs),
                              onDismissed: (_) => _removeWithUndo(item, i),
                              child: _LiftOnPress(
                                child: _CartTile(
                                  item: item,
                                  currency: widget.currency,
                                  onInc: () => _incQty(item),
                                  onDec: () => _decQty(item),
                                  onRemove: () => _removeWithUndo(item, i),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Frosted summary + CTA
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surface.withOpacity(0.92),
                            border: Border(
                              top: BorderSide(color: cs.outlineVariant),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            children: [
                              _FreeShipBar(
                                subtotal: _subTotal,
                                threshold: _freeShipThreshold,
                              ),
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label: 'Subtotal',
                                value: _fmt(_subTotal),
                              ),
                              _SummaryRow(
                                label: 'Shipping',
                                value: _shipping == 0
                                    ? 'FREE'
                                    : _fmt(_shipping),
                              ),
                              const SizedBox(height: 6),
                              Divider(
                                height: 1,
                                color: cs.onSurface.withOpacity(0.10),
                              ),
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label: 'Total',
                                value: _fmt(_grandTotal),
                                isBold: true,
                                size: 18,
                              ),
                              const SizedBox(height: 12),
                              ScaleTransition(
                                scale: _pulseCtrl,
                                child: _GradientButton(
                                  enabled: !isEmpty,
                                  onTap: () {
                                    if (isEmpty) return;
                                    // widget.onCheckout?.call();
                                    // _snack('Proceeding to checkout…');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutPage(
                                          items:
                                              _demoItems(), // pass from your CartPage state
                                          currency: '\$',
                                          initialAddress: const Address(
                                            name: 'Mohid Hassan',
                                            phone: '+92 3XX XXXXXXX',
                                            line1:
                                                'House 123, Street 4, Gulshan-e-Iqbal',
                                            line2: 'Karachi, Pakistan',
                                          ),
                                          availableAddresses: const [
                                            Address(
                                              name: 'Mohid Hassan',
                                              phone: '+92 3XX XXXXXXX',
                                              line1: 'Gulshan-e-Iqbal',
                                              line2: 'Karachi, Pakistan',
                                            ),
                                            Address(
                                              name: 'Office Recv.',
                                              phone: '+92 3XX XXXXXXX',
                                              line1: 'Shahrah-e-Faisal',
                                              line2: 'Karachi, Pakistan',
                                            ),
                                          ],
                                          onPlaceOrder: () {
                                            // TODO: call your API or navigate to success
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Iconsax.card_pos,
                                  label: 'Proceed to Checkout',
                                ),
                              ),
                            ],
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

  String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    return '${widget.currency}$s';
  }

  List<CartItem> _demoItems() {
    // ⭐ Increased to 5 demo items
    return [
      CartItem(
        id: 'p1',
        title: 'Amazify Sneakers',
        image: 'assets/Images/ban3.png',
        variant: 'Size 42 • Black',
        price: 4999,
        qty: 1,
      ),
      CartItem(
        id: 'p2',
        title: 'Wireless Headphones',
        image: 'assets/Images/ban2.png',
        variant: 'Matte • Grey',
        price: 2999,
        qty: 2,
      ),
      CartItem(
        id: 'p3',
        title: 'Smart Fitness Band',
        image: 'assets/Images/ban1.png',
        variant: 'Standard • Blue',
        price: 2199,
      ),
      CartItem(
        id: 'p4',
        title: 'Minimal Hoodie',
        image: 'assets/Images/ban4.png',
        variant: 'Size L • Grey',
        price: 3299,
      ),
      CartItem(
        id: 'p5',
        title: 'Classic Backpack',
        image: 'assets/Images/ban5.png',
        variant: '20L • Olive',
        price: 3899,
      ),
    ];
  }
}

// ---- Widgets ----

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.item,
    required this.currency,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  final CartItem item;
  final String currency;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageWidget = item.isNetworkImage
        ? Image.network(item.image, fit: BoxFit.cover)
        : Image.asset(item.image, fit: BoxFit.cover);

    final itemTotal = (item.price * item.qty).toStringAsFixed(0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image with subtle parallax tilt on scroll
          _Tilt(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(width: 96, height: 96, child: imageWidget),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.variant.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        item.variant,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Iconsax.minus,
                        onTap: item.qty > 1 ? onDec : null,
                      ),
                      _QtyBadge(qty: item.qty),
                      _QtyButton(
                        icon: Iconsax.add,
                        onTap: item.qty < item.maxQty ? onInc : null,
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Text(
                          '$currency$itemTotal',
                          key: ValueKey(itemTotal),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Remove
          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: Icon(Iconsax.trash, color: cs.error),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.onSurface.withOpacity(0.12)),
          color: Theme.of(context).brightness == Brightness.dark
              ? cs.surface
              : cs.surfaceContainerHighest.withOpacity(0.25),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? cs.onSurface.withOpacity(0.35) : cs.onSurface,
        ),
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.qty});
  final int qty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Text(
        '$qty',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.size = 14,
  });

  final String label;
  final String value;
  final bool isBold;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style?.copyWith(fontSize: size)),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Text(
              value,
              key: ValueKey('$label$value'),
              style: style?.copyWith(
                fontSize: size,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeDelete extends StatelessWidget {
  const _SwipeDelete({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Iconsax.trash, color: cs.error),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.bag_cross,
              size: 80,
              color: cs.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 10),
            Text(
              'Your cart is empty',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Discover amazing products and add them here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Iconsax.shop),
              label: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Pretty Free Shipping Bar ---------- */
class _FreeShipBar extends StatelessWidget {
  const _FreeShipBar({required this.subtotal, required this.threshold});
  final double subtotal;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final progress = (subtotal / threshold).clamp(0.0, 1.0);
    final need = (threshold - subtotal).clamp(0, threshold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          need == 0
              ? "You're eligible for FREE shipping!"
              : "Add Rs ${need.toStringAsFixed(0)} for FREE shipping",
          style: text.bodySmall?.copyWith(
            color: need == 0 ? cs.primary : cs.onSurface.withOpacity(.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: cs.surfaceVariant,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------- Gradient CTA Button ---------- */
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.onTap,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final bool enabled;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.enabled ? 1 : .6,
        child: AnimatedScale(
          scale: _down ? .98 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: cs.onPrimary),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------- Slide‑in stagger helper ---------- */
class _Stagger extends StatefulWidget {
  final Widget child;
  final int index;
  final bool enabled;
  const _Stagger({
    required this.child,
    required this.index,
    required this.enabled,
  });
  @override
  State<_Stagger> createState() => _StaggerState();
}

class _StaggerState extends State<_Stagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      Future.delayed(
        Duration(milliseconds: 60 * widget.index),
        () => _c.forward(),
      );
    } else {
      _c.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    final fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: widget.child),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

/* ---------- Card lift-on-press helper ---------- */
class _LiftOnPress extends StatefulWidget {
  final Widget child;
  const _LiftOnPress({required this.child});
  @override
  State<_LiftOnPress> createState() => _LiftOnPressState();
}

class _LiftOnPressState extends State<_LiftOnPress> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerCancel: (_) => setState(() => _down = false),
      onPointerUp: (_) => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..translate(0.0, _down ? -3.0 : 0.0),
        child: AnimatedScale(
          scale: _down ? 0.995 : 1,
          duration: const Duration(milliseconds: 140),
          child: widget.child,
        ),
      ),
    );
  }
}

/* ---------- Subtle tilt/parallax ---------- */
class _Tilt extends StatefulWidget {
  final Widget child;
  const _Tilt({required this.child});
  @override
  State<_Tilt> createState() => _TiltState();
}

class _TiltState extends State<_Tilt> {
  double dx = 0, dy = 0;
  void _update(PointerHoverEvent e, Size size) {
    final x = (e.localPosition.dx / size.width) * 2 - 1;
    final y = (e.localPosition.dy / size.height) * 2 - 1;
    setState(() {
      dx = x.clamp(-1.0, 1.0);
      dy = y.clamp(-1.0, 1.0);
    });
  }

  void _reset(_) => setState(() {
    dx = 0;
    dy = 0;
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) _update(e, box.size);
      },
      onExit: _reset,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-dy * 0.12)
          ..rotateY(dx * 0.12)
          ..translate(dx * 2, dy * 2),
        child: widget.child,
      ),
    );
  }
}

/* ---------- Animated gradient backdrop ---------- */
class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop();
  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.06 + 0.04 * math.sin(t * math.pi)),
                cs.secondaryContainer.withOpacity(0.05),
                cs.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
