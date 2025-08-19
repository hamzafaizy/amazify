// lib/features/cart/cart.dart
import 'package:flutter/material.dart';
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

class _CartPageState extends State<CartPage> {
  late List<CartItem> _items;
  final _couponCtrl = TextEditingController();

  // Pricing knobs
  static const double _shippingFlat = 250.0;
  static const double _freeShipThreshold = 5000.0;

  String? _appliedCoupon;
  double _couponDiscountPct = 0.0; // e.g. 0.10 = 10% off

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems.isNotEmpty
        ? List.of(widget.initialItems)
        : _demoItems();
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  // ---- Computed totals ----
  double get _subTotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.qty));

  double get _shipping => _items.isEmpty
      ? 0
      : (_subTotal >= _freeShipThreshold || _appliedCoupon == 'FREESHIP'
            ? 0
            : _shippingFlat);

  double get _discount => _subTotal * _couponDiscountPct;

  double get _grandTotal => (_subTotal - _discount) + _shipping;

  // ---- Actions ----
  void _incQty(CartItem item) {
    setState(() {
      if (item.qty < item.maxQty) item.qty++;
    });
  }

  void _decQty(CartItem item) {
    setState(() {
      if (item.qty > 1) item.qty--;
    });
  }

  void _remove(CartItem item) {
    setState(() => _items.removeWhere((e) => e.id == item.id));
  }

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    // Example rules — customize to your backend
    if (code == 'SAVE10') {
      setState(() {
        _appliedCoupon = code;
        _couponDiscountPct = 0.10;
      });
      _snack('Applied 10% discount.');
    } else if (code == 'FREESHIP') {
      setState(() {
        _appliedCoupon = code;
        _couponDiscountPct = 0.0;
      });
      _snack('Free shipping applied.');
    } else if (code.isEmpty) {
      setState(() {
        _appliedCoupon = null;
        _couponDiscountPct = 0.0;
      });
      _snack('Coupon cleared.');
    } else {
      _snack('Invalid coupon.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEmpty = _items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart (${_items.length})'),
        centerTitle: true,
      ),
      body: isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.maybePop(context))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: _SwipeDelete(cs: cs),
                        onDismissed: (_) => _remove(item),
                        child: _CartTile(
                          item: item,
                          currency: widget.currency,
                          onInc: () => _incQty(item),
                          onDec: () => _decQty(item),
                          onRemove: () => _remove(item),
                        ),
                      );
                    },
                  ),
                ),

                // Coupon + Summary
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(color: cs.onSurface.withOpacity(0.08)),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponCtrl,
                              decoration: InputDecoration(
                                hintText: 'Have a coupon? (SAVE10, FREESHIP)',
                                isDense: true,
                                prefixIcon: const Icon(Iconsax.ticket_discount),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(label: 'Subtotal', value: _fmt(_subTotal)),
                      _SummaryRow(
                        label: 'Discount',
                        value: '- ${_fmt(_discount)}',
                      ),
                      _SummaryRow(
                        label: 'Shipping',
                        value: _shipping == 0 ? 'FREE' : _fmt(_shipping),
                      ),
                      const SizedBox(height: 6),
                      Divider(height: 1, color: cs.onSurface.withOpacity(0.10)),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Total',
                        value: _fmt(_grandTotal),
                        isBold: true,
                        size: 18,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _items.isEmpty
                              ? null
                              : () {
                                  widget.onCheckout?.call();
                                  _snack('Proceeding to checkout…');
                                },
                          icon: const Icon(Iconsax.card_pos),
                          label: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _fmt(double n) {
    // Minimal currency formatter without intl:
    final s = n.toStringAsFixed(0);
    return '${widget.currency}$s';
  }

  List<CartItem> _demoItems() {
    // Replace with your products/images
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

    Widget imageWidget;
    if (item.isNetworkImage) {
      imageWidget = Image.network(item.image, fit: BoxFit.cover);
    } else {
      imageWidget = Image.asset(item.image, fit: BoxFit.cover);
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(width: 96, height: 96, child: imageWidget),
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
                      Text(
                        '$currency${(item.price * item.qty).toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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
    return Container(
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
          Text(
            value,
            style: style?.copyWith(
              fontSize: size,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
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
