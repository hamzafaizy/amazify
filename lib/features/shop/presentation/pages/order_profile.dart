// lib/features/shop/presentation/pages/order.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = <Order>[
      Order(
        id: 'CWWT0152',
        status: OrderStatus.processing,
        orderDate: DateTime(2025, 8, 1),
        shipDate: DateTime(2025, 11, 6),
      ),
      Order(
        id: 'ABX90231',
        status: OrderStatus.onTheWay,
        orderDate: DateTime(2025, 7, 19),
        shipDate: DateTime(2025, 7, 22),
      ),
      Order(
        id: 'ZXCV7742',
        status: OrderStatus.delivered,
        orderDate: DateTime(2025, 6, 4),
        shipDate: DateTime(2025, 6, 7),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Orders'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => OrderCard(order: orders[i]),
      ),
    );
  }
}

/* ───────────────────────── Models & Utils ───────────────────────── */

class Order {
  final String id;
  final OrderStatus status;
  final DateTime orderDate; // shown in bold below status (e.g. 01 Aug 2025)
  final DateTime shipDate; // shown under "Shipping date"

  Order({
    required this.id,
    required this.status,
    required this.orderDate,
    required this.shipDate,
  });
}

enum OrderStatus { processing, onTheWay, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.processing => 'Processing',
    OrderStatus.onTheWay => 'Shipment on the way',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };

  IconData get icon => switch (this) {
    OrderStatus.processing => Iconsax.refresh,
    OrderStatus.onTheWay => Iconsax.truck_fast,
    OrderStatus.delivered => Iconsax.tick_circle,
    OrderStatus.cancelled => Iconsax.close_circle,
  };

  Color color(ColorScheme cs) => switch (this) {
    OrderStatus.processing => cs.primary, // blue-ish from theme
    OrderStatus.onTheWay => cs.primary, // same blue family
    OrderStatus.delivered => cs.onSecondary, // green-ish if using M3
    OrderStatus.cancelled => cs.error,
  };
}

String _fmtDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final dd = d.day.toString().padLeft(2, '0');
  final mmm = months[d.month - 1];
  final yyyy = d.year.toString();
  return '$dd $mmm $yyyy';
}

/* ─────────────────────────── UI Widgets ─────────────────────────── */

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      surfaceTintColor: cs.surfaceTint,
      shadowColor: cs.shadow.withOpacity(.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status chip (blue for processing/on the way, green for delivered)
            _StatusChip(status: order.status),

            const SizedBox(height: 10),

            // ── Date row: leading ship icon, bold date, trailing right arrow
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: navigate to order detail if needed
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Iconsax.ship, size: 22, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _fmtDate(order.orderDate),
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Iconsax.arrow_right_3, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: cs.outlineVariant.withOpacity(.5)),
            const SizedBox(height: 10),

            // ── Order + ID (with prefix icon), then Shipping date (calendar + 2-line)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.receipt, color: cs.onSurfaceVariant, size: 20),
                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Order" and ID in a column
                    Text(
                      'Order',
                      style: text.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.id,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping date',
                          style: text.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fmtDate(order.shipDate),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = status.color(cs).withOpacity(.10);
    final fg = status.color(cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: bg,
        shape: StadiumBorder(side: BorderSide(color: fg.withOpacity(.35))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
