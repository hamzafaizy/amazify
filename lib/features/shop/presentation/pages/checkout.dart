// lib/features/shop/presentation/pages/checkout.dart
import 'package:amazify/features/shop/presentation/pages/cart.dart'; // for CartItem
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// -------------------- Models --------------------

class Address {
  final String name;
  final String phone;
  final String line1;
  final String line2;
  const Address({
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final String info; // small helper text
  final double fee; // keep 0 if free
  final IconData icon;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.info,
    required this.fee,
    required this.icon,
  });
}

/// -------------------- Page --------------------

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.items,
    this.currency = 'Rs ',
    this.initialAddress,
    this.availableAddresses = const [],
    this.onPlaceOrder,
  });

  final List<CartItem> items;
  final String currency;

  final Address? initialAddress;
  final List<Address> availableAddresses;

  final VoidCallback? onPlaceOrder;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0.0;

  late Address? _selectedAddress;
  late PaymentMethod _selectedPayment;

  static const List<PaymentMethod> methods = [
    PaymentMethod(
      id: 'visa',
      name: 'Visa',
      info: 'Fast & secure',
      fee: 0,
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      id: 'master',
      name: 'Mastercard',
      info: 'Global acceptance',
      fee: 0,
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      id: 'stripe',
      name: 'Stripe',
      info: 'Cards & wallets',
      fee: 0,
      icon: Iconsax.card,
    ),
    PaymentMethod(
      id: 'paypal',
      name: 'PayPal',
      info: 'Pay with balance',
      fee: 0,
      icon: Iconsax.wallet_search,
    ),
    PaymentMethod(
      id: 'wise',
      name: 'Wise',
      info: 'Low FX fees',
      fee: 0,
      icon: Iconsax.money_send,
    ),
    PaymentMethod(
      id: 'payoneer',
      name: 'Payoneer',
      info: 'Global payouts',
      fee: 0,
      icon: Iconsax.wallet_3,
    ),
    PaymentMethod(
      id: 'redotpay',
      name: 'RedotPay',
      info: 'Crypto & cards',
      fee: 0,
      icon: Iconsax.bitcoin_card,
    ),
    PaymentMethod(
      id: 'binance',
      name: 'Binance Pay',
      info: 'Crypto wallet',
      fee: 0,
      icon: Iconsax.bitcoin_refresh,
    ),
    PaymentMethod(
      id: 'jazzcash',
      name: 'JazzCash',
      info: 'Mobile wallet (PK)',
      fee: 0,
      icon: Iconsax.wallet,
    ),
    PaymentMethod(
      id: 'easypaisa',
      name: 'Easypaisa',
      info: 'Mobile wallet (PK)',
      fee: 0,
      icon: Iconsax.wallet_1,
    ),
    PaymentMethod(
      id: 'sadapay',
      name: 'SadaPay',
      info: 'PK neobank',
      fee: 0,
      icon: Iconsax.card_pos,
    ),
    PaymentMethod(
      id: 'nayapay',
      name: 'NayaPay',
      info: 'PK wallet',
      fee: 0,
      icon: Iconsax.card_tick,
    ),
    PaymentMethod(
      id: 'bank',
      name: 'Bank Transfer',
      info: 'Manual transfer',
      fee: 0,
      icon: Iconsax.bank,
    ),
    PaymentMethod(
      id: 'other',
      name: 'Other',
      info: 'More options',
      fee: 0,
      icon: Iconsax.menu,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress =
        widget.initialAddress ??
        (widget.availableAddresses.isNotEmpty
            ? widget.availableAddresses.first
            : null);
    _selectedPayment = methods.first;
  }

  // ---- Totals (fees are free here) ----
  double get _subTotal =>
      widget.items.fold(0.0, (sum, it) => sum + (it.price * it.qty));
  double get _feesTotal => 0.0 + _selectedPayment.fee; // hook for future fees
  double get _orderTotal =>
      (_subTotal + _feesTotal - _couponDiscount).clamp(0, double.infinity);

  String _fmt(double n) => '${widget.currency}${n.toStringAsFixed(0)}';

  void _applyCoupon() {
    final code = _couponCtrl.text.trim();
    double discount = 0.0;
    if (code.isEmpty) {
      setState(() {
        _appliedCoupon = null;
        _couponDiscount = 0.0;
      });
      return;
    }
    if (code.toUpperCase() == 'SAVE10') {
      discount = _subTotal * 0.10;
    } else if (code.toUpperCase() == 'FLAT100') {
      discount = 100.0;
    } else {
      discount = 0.0;
    }
    setState(() {
      _appliedCoupon = code;
      _couponDiscount = discount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          discount > 0
              ? 'Coupon applied: -${_fmt(discount)}'
              : 'Invalid coupon',
        ),
      ),
    );
  }

  Future<void> _pickPayment() async {
    final selected = await showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, sc) => ListView.separated(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemBuilder: (_, i) {
            final m = methods[i];
            final sel = m.id == _selectedPayment.id;
            final cs = Theme.of(ctx).colorScheme;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primary.withOpacity(.12),
                child: Icon(m.icon, color: cs.primary),
              ),
              title: Text(m.name),
              subtitle: Text(
                "${m.info}${m.fee > 0 ? " • Fee ${_fmt(m.fee)}" : " • Free"}",
              ),
              trailing: sel
                  ? Icon(Iconsax.tick_circle, color: cs.primary)
                  : const Icon(Iconsax.radio),
              onTap: () => Navigator.pop(ctx, m),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemCount: methods.length,
        ),
      ),
    );
    if (selected != null) setState(() => _selectedPayment = selected);
  }

  Future<void> _pickAddress() async {
    final picked = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => _AddressPickerSheet(
        addresses: widget.availableAddresses,
        selected: _selectedAddress,
      ),
    );
    if (picked != null) setState(() => _selectedAddress = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          /// --- Cart items ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _CheckoutCartTile(
                  item: widget.items[i],
                  currency: widget.currency,
                ),
                childCount: widget.items.length,
              ),
            ),
          ),

          /// --- Coupon + Summary + Payment + Address ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  // Coupon
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Row(
                        children: [
                          Icon(Iconsax.discount_shape, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _couponCtrl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Have a coupon? Enter code',
                                suffixIcon:
                                    (_appliedCoupon?.isNotEmpty ?? false)
                                    ? Icon(
                                        Iconsax.tick_circle,
                                        color: cs.primary,
                                      )
                                    : null,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _applyCoupon(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: _applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Summary (FREE fees)
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Subtotal',
                            value: _fmt(_subTotal),
                          ),
                          const SizedBox(height: 8),
                          const _SummaryRow(
                            label: 'Shipping fee',
                            value: 'Free',
                          ),
                          const SizedBox(height: 8),
                          const _SummaryRow(label: 'Tax fee', value: 'Free'),
                          const SizedBox(height: 8),
                          const _SummaryRow(
                            label: 'Platform fee',
                            value: 'Free',
                          ),
                          if (_couponDiscount > 0) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Coupon',
                              value: "-${_fmt(_couponDiscount)}",
                            ),
                          ],
                          const SizedBox(height: 10),
                          Divider(
                            height: 1,
                            color: cs.onSurface.withOpacity(0.10),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('Order total', style: text.titleMedium),
                              const Spacer(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (c, a) =>
                                    ScaleTransition(scale: a, child: c),
                                child: Text(
                                  _fmt(_orderTotal),
                                  key: ValueKey(_orderTotal),
                                  style: text.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment method
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Payment Method', style: text.titleMedium),
                              const Spacer(),
                              TextButton(
                                onPressed: _pickPayment,
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 0,
                              right: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: cs.primary.withOpacity(.12),
                              child: Icon(
                                _selectedPayment.icon,
                                color: cs.primary,
                              ),
                            ),
                            title: Text(_selectedPayment.name),
                            subtitle: Text(
                              "${_selectedPayment.info} • ${_selectedPayment.fee > 0 ? _fmt(_selectedPayment.fee) : 'Free'}",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Shipping Address
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Shipping Address', style: text.titleMedium),
                              const Spacer(),
                              TextButton(
                                onPressed: _pickAddress,
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (_selectedAddress != null)
                            Column(
                              children: [
                                _IconLine(
                                  icon: Iconsax.user,
                                  text: _selectedAddress!.name,
                                ),
                                const SizedBox(height: 6),
                                _IconLine(
                                  icon: Iconsax.call,
                                  text: _selectedAddress!.phone,
                                ),
                                const SizedBox(height: 6),
                                _IconLine(
                                  icon: Iconsax.location,
                                  text:
                                      "${_selectedAddress!.line1}${_selectedAddress!.line2.isNotEmpty ? "\n${_selectedAddress!.line2}" : ""}",
                                  multi: true,
                                ),
                              ],
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'No address selected',
                                style: text.bodyMedium,
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

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),

      // --- Sticky bottom Checkout button ---
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _GradientButton(
          onTap: widget.items.isEmpty
              ? null
              : () {
                  widget.onPlaceOrder?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Proceeding to pay ${_fmt(_orderTotal)} via ${_selectedPayment.name}',
                      ),
                    ),
                  );
                },
          label: 'Checkout • ${_fmt(_orderTotal)}',
          icon: Iconsax.card_send,
          enabled: widget.items.isNotEmpty,
        ),
      ),
    );
  }
}

/// -------------------- UI bits (mirroring cart.dart) --------------------

class _CheckoutCartTile extends StatelessWidget {
  const _CheckoutCartTile({required this.item, required this.currency});
  final CartItem item;
  final String currency;

  String _fmt(double n) => '$currency${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageWidget = item.isNetworkImage
        ? Image.network(item.image, fit: BoxFit.cover)
        : Image.asset(item.image, fit: BoxFit.cover);

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 12),
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
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(width: 96, height: 80, child: imageWidget),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: title + variant
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (item.variant.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.variant,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right side: qty + total price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _QtyBadge(qty: item.qty),
                      //const SizedBox(height: 6),
                      Text(
                        _fmt(item.price * item.qty),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      height: 25,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Text(
        'x$qty',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
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

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, this.multi = false});
  final IconData icon;
  final String text;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: multi
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// -------------------- Address picker sheet --------------------

class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet({required this.addresses, required this.selected});
  final List<Address> addresses;
  final Address? selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No saved addresses yet.\nAdd one from your Addresses page.',
            style: text.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, sc) => ListView.builder(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: addresses.length,
        itemBuilder: (_, i) {
          final a = addresses[i];
          final isSel =
              selected != null &&
              selected!.name == a.name &&
              selected!.phone == a.phone &&
              selected!.line1 == a.line1 &&
              selected!.line2 == a.line2;

          return Card(
            elevation: isSel ? 1.5 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isSel ? cs.primary : cs.outlineVariant),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(ctx, a),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.user, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(a.name, style: text.titleMedium),
                        const Spacer(),
                        if (isSel) Icon(Iconsax.tick_circle, color: cs.primary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.call,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(a.phone, style: text.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${a.line1}${a.line2.isNotEmpty ? "\n${a.line2}" : ""}",
                            style: text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// -------------------- Gradient Button (outside card) --------------------

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  final VoidCallback? onTap;
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
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(.82)],
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
