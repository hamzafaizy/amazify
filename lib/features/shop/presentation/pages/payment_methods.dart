// lib/features/shop/presentation/pages/payments.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Payments screen (clean + stable order, better spacing, theme-aware)
class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    this.currency = 'Rs ',
    this.totalAmount = 32999.0,
    this.savedCards = const [],
    this.onPay, // (PaymentMethod, PaymentCard?) => FutureOr<void>
  });

  final String currency;
  final double totalAmount;
  final List<PaymentCard> savedCards;
  final Future<void> Function(PaymentMethod method, PaymentCard? card)? onPay;

  @override
  State<PaymentPage> createState() => _PaymentsPageState();
}

/* ───────────────────────── Models & Enums ───────────────────────── */

enum PaymentMethod { card, jazzcash, easypaisa, cod, bank }

class PaymentCard {
  PaymentCard({
    required this.holder,
    required this.number,
    required this.expiry, // MM/YY
    this.brand,
    this.isDefault = false,
  }) {
    brand ??= _detectBrand(number);
  }

  final String holder;
  final String number;
  final String expiry;
  String? brand;
  bool isDefault;

  String get maskedNumber {
    final clean = number.replaceAll(' ', '');
    final last4 = clean.length >= 4 ? clean.substring(clean.length - 4) : clean;
    return '**** **** **** $last4';
  }

  static String _detectBrand(String num) {
    final n = num.replaceAll(' ', '');
    if (n.isEmpty) return 'Card';
    if (n.startsWith('4')) return 'Visa';
    if (n.startsWith('5')) return 'Mastercard';
    if (n.startsWith('3')) return 'Amex';
    if (n.startsWith('6')) return 'Discover';
    return 'Card';
  }
}

/* ────────────────────────── State & Logic ───────────────────────── */

class _PaymentsPageState extends State<PaymentPage> {
  late List<PaymentCard> _cards;
  PaymentMethod _selected = PaymentMethod.card;
  PaymentCard? _selectedCard;

  @override
  void initState() {
    super.initState();
    _cards = [...widget.savedCards];
    _selectedCard =
        _cards.where((c) => c.isDefault).cast<PaymentCard?>().firstOrNull ??
        (_cards.isNotEmpty ? _cards.first : null);
  }

  Future<void> _handlePay() async {
    if (_selected == PaymentMethod.card && _selectedCard == null) {
      _showSnack('Please select or add a card.');
      return;
    }
    try {
      if (widget.onPay != null) {
        await widget.onPay!(
          _selected,
          _selected == PaymentMethod.card ? _selectedCard : null,
        );
      }
      _showSnack('Payment initiated with ${_labelFor(_selected)}');
    } catch (e) {
      _showSnack('Payment failed: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /* ───────────── Add Card Sheet ───────────── */

  void _openAddCardSheet() async {
    final cs = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    final holder = TextEditingController();
    final number = TextEditingController();
    final expiry = TextEditingController();
    final cvv = TextEditingController();

    final card = await showModalBottomSheet<PaymentCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withOpacity(.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Iconsax.card, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Add new card',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Card holder name',
                    controller: holder,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Enter full name'
                        : null,
                  ),
                  _LabeledField(
                    label: 'Card number',
                    controller: number,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 19,
                    hint: '1234 5678 9012 3456',
                    inputFormat: _cardNumberFormat,
                    validator: (v) {
                      final n = (v ?? '').replaceAll(' ', '');
                      if (n.length < 15) return 'Invalid card number';
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Expiry (MM/YY)',
                          controller: expiry,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 5,
                          hint: '08/27',
                          inputFormat: _expiryFormat,
                          validator: (v) {
                            final s = (v ?? '');
                            if (!RegExp(
                              r'^(0[1-9]|1[0-2])\/\d{2}$',
                            ).hasMatch(s)) {
                              return 'Invalid expiry';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: 'CVV',
                          controller: cvv,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscure: true,
                          validator: (v) => (v == null || v.length < 3)
                              ? 'Invalid CVV'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState?.validate() != true) return;
                        final newCard = PaymentCard(
                          holder: holder.text.trim(),
                          number: number.text.trim(),
                          expiry: expiry.text.trim(),
                        );
                        Navigator.pop(ctx, newCard);
                      },
                      icon: const Icon(Iconsax.tick_square),
                      label: const Text('Save card'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (card != null) {
      setState(() {
        _cards.insert(0, card);
        _selected = PaymentMethod.card;
        _selectedCard = card;
      });
      _showSnack('Card added');
    }
  }

  /* ───────────── UI Helpers ───────────── */

  String _labelFor(PaymentMethod m) => switch (m) {
    PaymentMethod.card => 'Card',
    PaymentMethod.jazzcash => 'JazzCash',
    PaymentMethod.easypaisa => 'Easypaisa',
    PaymentMethod.cod => 'Cash on Delivery',
    PaymentMethod.bank => 'Bank Transfer',
  };

  IconData _iconFor(PaymentMethod m) => switch (m) {
    PaymentMethod.card => Iconsax.card,
    PaymentMethod.jazzcash => Iconsax.wallet_1,
    PaymentMethod.easypaisa => Iconsax.money_3,
    PaymentMethod.cod => Iconsax.box,
    PaymentMethod.bank => Iconsax.bank,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Iconsax.security_safe, color: cs.primary),
          ),
        ],
      ),

      // Sticky, tidy summary bar (FIXED: was using a Set -> unordered)
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: _BottomPayBar(
          currency: widget.currency,
          total: widget.totalAmount,
          methodIcon: _iconFor(_selected),
          methodLabel: _labelFor(_selected),
          onPay: _handlePay,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SecureBadge(),
          const SizedBox(height: 14),

          // Saved cards
          if (_cards.isNotEmpty) ...[
            _SectionHeader(
              icon: Iconsax.card_tick,
              title: 'Saved cards',
              action: TextButton.icon(
                onPressed: _openAddCardSheet,
                icon: const Icon(Iconsax.add),
                label: const Text('Add'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140, // a bit taller for less cramped look
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 4),
                itemCount: _cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final c = _cards[i];
                  final selected = identical(c, _selectedCard);
                  return _SavedCardChip(
                    card: c,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selected = PaymentMethod.card;
                        _selectedCard = c;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        if (identical(c, _selectedCard)) _selectedCard = null;
                        _cards.removeAt(i);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            _SectionHeader(
              icon: Iconsax.card_add,
              title: 'Cards',
              action: TextButton.icon(
                onPressed: _openAddCardSheet,
                icon: const Icon(Iconsax.add),
                label: const Text('Add'),
              ),
            ),
            const SizedBox(height: 8),
            _EmptyHint(
              text: 'No saved cards yet. Add one to pay faster next time.',
            ),
            const SizedBox(height: 14),
          ],

          // Payment methods
          _SectionHeader(icon: Iconsax.wallet, title: 'Payment methods'),
          const SizedBox(height: 8),
          _MethodTile(
            icon: _iconFor(PaymentMethod.card),
            title: 'Credit / Debit Card',
            subtitle: _selectedCard != null
                ? '${_selectedCard!.brand} • ${_selectedCard!.maskedNumber}'
                : 'Visa, Mastercard, etc.',
            selected: _selected == PaymentMethod.card,
            onTap: () => setState(() => _selected = PaymentMethod.card),
            trailing: TextButton(
              onPressed: _openAddCardSheet,
              child: const Text('Add card'),
            ),
          ),
          _MethodTile(
            icon: _iconFor(PaymentMethod.jazzcash),
            title: 'JazzCash',
            subtitle: 'Pay via mobile wallet',
            selected: _selected == PaymentMethod.jazzcash,
            onTap: () => setState(() => _selected = PaymentMethod.jazzcash),
          ),
          _MethodTile(
            icon: _iconFor(PaymentMethod.easypaisa),
            title: 'Easypaisa',
            subtitle: 'Pay via mobile wallet',
            selected: _selected == PaymentMethod.easypaisa,
            onTap: () => setState(() => _selected = PaymentMethod.easypaisa),
          ),
          _MethodTile(
            icon: _iconFor(PaymentMethod.cod),
            title: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            selected: _selected == PaymentMethod.cod,
            onTap: () => setState(() => _selected = PaymentMethod.cod),
          ),
          _MethodTile(
            icon: _iconFor(PaymentMethod.bank),
            title: 'Bank Transfer',
            subtitle: 'Manual transfer, upload receipt',
            selected: _selected == PaymentMethod.bank,
            onTap: () => setState(() => _selected = PaymentMethod.bank),
          ),
          const SizedBox(height: 12),

          // Summary
          _SectionHeader(icon: Iconsax.receipt_2, title: 'Summary'),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total',
            value: '${widget.currency}${_fmtMoney(widget.totalAmount)}',
            bold: true,
          ),
          const SizedBox(height: 18),

          _TinyNote(
            icon: Iconsax.shield_tick,
            text: 'Your payment details are encrypted & processed securely.',
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Widgets ───────────────────────── */

class _SecureBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: cs.primary.withOpacity(.08),
        shape: StadiumBorder(
          side: BorderSide(color: cs.primary.withOpacity(.25)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.lock, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            'Secure checkout',
            style: text.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.selected,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer.withOpacity(.25) : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant.withOpacity(.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: selected
              ? cs.primary.withOpacity(.12)
              : cs.surfaceVariant.withOpacity(.5),
          child: Icon(
            icon,
            color: selected ? cs.primary : cs.onSurfaceVariant,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              selected ? Iconsax.tick_circle : Iconsax.radio,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SavedCardChip extends StatelessWidget {
  const _SavedCardChip({
    required this.card,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final PaymentCard card;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withOpacity(.5),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    cs.primary.withOpacity(.10),
                    cs.primaryContainer.withOpacity(.18),
                  ]
                : [cs.surface, cs.surface],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row brand + delete
            Row(
              children: [
                Icon(Iconsax.card, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.brand ?? 'Card',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Iconsax.trash, size: 16, color: cs.error),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.maskedNumber,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.holder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'EXP ${card.expiry}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final st = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: bold
                ? st.titleMedium?.copyWith(fontWeight: FontWeight.w800)
                : st.bodyMedium,
          ),
        ),
        Text(
          value,
          style: bold
              ? st.titleMedium?.copyWith(fontWeight: FontWeight.w800)
              : st.bodyMedium,
        ),
      ],
    );
  }
}

class _BottomPayBar extends StatelessWidget {
  const _BottomPayBar({
    required this.currency,
    required this.total,
    required this.methodIcon,
    required this.methodLabel,
    required this.onPay,
  });

  final String currency;
  final double total;
  final IconData methodIcon;
  final String methodLabel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // IMPORTANT FIX: use a LIST, not a SET, to preserve order
    final children = <Widget>[
      Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primary.withOpacity(.12),
            child: Icon(methodIcon, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 8),
          Text(
            methodLabel,
            style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      const Spacer(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Total',
            style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            '$currency${_fmtMoney(total)}',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(width: 10),
      FilledButton.icon(
        onPressed: onPay,
        icon: const Icon(Iconsax.arrow_right_3),
        label: const Text('Pay Now'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
      ),
      child: Row(children: children),
    );
  }
}

class _TinyNote extends StatelessWidget {
  const _TinyNote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.info_circle, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.textInputAction,
    this.keyboardType,
    this.maxLength,
    this.obscure = false,
    this.validator,
    this.inputFormat,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscure;
  final String? Function(String?)? validator;
  final String Function(String)? inputFormat;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscure,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            prefixIcon: obscure ? const Icon(Iconsax.lock) : null,
          ),
          validator: validator,
          onChanged: inputFormat == null
              ? null
              : (v) {
                  // keep caret near end but stable
                  final old = controller.selection;
                  final formatted = inputFormat!(v);
                  controller.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                    composing: TextRange.empty,
                  );
                  // fallback if selection broke
                  if (old.baseOffset <= formatted.length) {
                    controller.selection = TextSelection.collapsed(
                      offset: formatted.length,
                    );
                  }
                },
        ),
      ],
    );
  }
}

/* ───────────────────────── Utils ───────────────────────── */

String _fmtMoney(double v) {
  // Simple thousands formatting without intl
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - 1 - i;
    buf.write(s[idx]);
    if ((i + 1) % 3 == 0 && idx != 0) buf.write(',');
  }
  return buf.toString().split('').reversed.join();
}

// Pure-dart input "formatters"
String _cardNumberFormat(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  final groups = <String>[];
  for (int i = 0; i < digits.length; i += 4) {
    groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
  }
  return groups.join(' ').trimRight();
}

String _expiryFormat(String input) {
  final d = input.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.length <= 2) return d;
  return '${d.substring(0, 2)}/${d.substring(2, d.length.clamp(2, 4))}';
}

/* ─────────────────────── Extensions ─────────────────────── */

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
