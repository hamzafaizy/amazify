// lib/features/notifications/notifications.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum NotificationType { order, offer, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.read = false,
  });
}

/// Red badge bell icon for AppBars, etc.
class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
    required this.count,
    this.onPressed,
    this.color,
  });

  final int count;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Iconsax.notification),
          color: color ?? cs.onPrimary,
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _Filter { all, unread, order, offer, system }

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    this.initialNotifications = const [],
    this.title = 'Notifications',
  });

  final List<AppNotification> initialNotifications;
  final String title;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<AppNotification> _items;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _items = widget.initialNotifications.isNotEmpty
        ? List.of(widget.initialNotifications)
        : _demoNotifications();
    _sort();
  }

  void _sort() {
    _items.sort((a, b) => b.time.compareTo(a.time));
  }

  List<AppNotification> get _filtered {
    return _items.where((n) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.unread:
          return !n.read;
        case _Filter.order:
          return n.type == NotificationType.order;
        case _Filter.offer:
          return n.type == NotificationType.offer;
        case _Filter.system:
          return n.type == NotificationType.system;
      }
    }).toList();
  }

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.read = true;
      }
    });
  }

  void _clearRead() {
    setState(() {
      _items.removeWhere((n) => n.read);
    });
  }

  void _clearAll() {
    setState(() => _items.clear());
  }

  void _toggleRead(AppNotification n) {
    setState(() => n.read = !n.read);
  }

  void _delete(AppNotification n) {
    setState(() => _items.removeWhere((x) => x.id == n.id));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final unreadCount = _items.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear_read') _clearRead();
              if (v == 'clear_all') _clearAll();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear_read',
                child: Text('Clear read'),
              ),
              const PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            current: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Expanded(
              child: _EmptyState(onBrowse: () => Navigator.maybePop(context)),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final n = filtered[index];
                  final showHeader =
                      index == 0 ||
                      !_isSameDay(filtered[index - 1].time, n.time);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showHeader)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                          child: Text(
                            _friendlyDate(n.time),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: cs.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      Dismissible(
                        key: ValueKey(n.id),
                        background: _SwipeBG(
                          icon: n.read ? Iconsax.eye_slash : Iconsax.eye,
                          label: n.read ? 'Mark unread' : 'Mark read',
                          color: cs.primary,
                          alignLeft: true,
                        ),
                        secondaryBackground: _SwipeBG(
                          icon: Iconsax.trash,
                          label: 'Delete',
                          color: cs.error,
                          alignLeft: false,
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _toggleRead(n);
                            return false; // don’t dismiss, we only toggled
                          } else {
                            _delete(n);
                            return true;
                          }
                        },
                        child: _NotificationTile(
                          data: n,
                          onTap: () => _toggleRead(n),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // --- Demo data (replace with your backend feed) ---
  List<AppNotification> _demoNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'Order #AF-2048 Shipped',
        body: 'Your Amazify Sneakers are on the way. Track in Orders.',
        type: NotificationType.order,
        time: now.subtract(const Duration(minutes: 20)),
      ),
      AppNotification(
        id: 'n2',
        title: '🎉 Limited-Time Offer',
        body: 'Flat 10% off on Headphones. Use code SAVE10 at checkout.',
        type: NotificationType.offer,
        time: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n3',
        title: 'Payment Successful',
        body: 'Order #AF-2037 has been paid successfully.',
        type: NotificationType.order,
        time: now.subtract(const Duration(days: 1, hours: 2)),
        read: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'System Update',
        body: 'We’ve improved app performance and fixed minor bugs.',
        type: NotificationType.system,
        time: now.subtract(const Duration(days: 2, hours: 6)),
      ),
    ];
  }
}

// ---------- UI Parts ----------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onChanged});
  final _Filter current;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(String label, _Filter f, IconData icon) {
      final selected = current == f;
      return ChoiceChip.elevated(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onChanged(f),
        selectedColor: cs.primary.withOpacity(0.12),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? cs.primary : null,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: cs.onSurface.withOpacity(0.12)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('All', _Filter.all, Iconsax.category),
          const SizedBox(width: 8),
          chip('Unread', _Filter.unread, Iconsax.eye_slash),
          const SizedBox(width: 8),
          chip('Orders', _Filter.order, Iconsax.box),
          const SizedBox(width: 8),
          chip('Offers', _Filter.offer, Iconsax.discount_shape),
          const SizedBox(width: 8),
          chip('System', _Filter.system, Iconsax.setting_2),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.data, this.onTap});
  final AppNotification data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !data.read;

    final (icon, tint) = switch (data.type) {
      NotificationType.order => (Iconsax.box, cs.tertiary),
      NotificationType.offer => (Iconsax.discount_circle, cs.primary),
      NotificationType.system => (Iconsax.information, cs.secondary),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isUnread ? cs.primary.withOpacity(0.06) : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(data.time),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Unread dot
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBG extends StatelessWidget {
  const _SwipeBG({
    required this.icon,
    required this.label,
    required this.color,
    required this.alignLeft,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: alignLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (alignLeft) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color)),
          ] else ...[
            Text(label, style: TextStyle(color: color)),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.notification_bing,
              size: 80,
              color: cs.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 10),
            Text(
              'No notifications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'We’ll let you know when there’s something new.',
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

// ---------- Tiny time utils ----------

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _friendlyDate(DateTime dt) {
  final now = DateTime.now();
  if (_isSameDay(now, dt)) return 'Today';
  final yesterday = now.subtract(const Duration(days: 1));
  if (_isSameDay(yesterday, dt)) return 'Yesterday';
  return '${_month(dt.month)} ${dt.day}, ${dt.year}';
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final w = (diff.inDays / 7).floor();
  if (w < 5) return '${w}w';
  return '${time.day} ${_month(time.month)}';
}

String _month(int m) {
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
  return months[m - 1];
}
