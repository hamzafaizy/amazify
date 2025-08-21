// lib/features/account/presentation/pages/profile.dart
import 'package:amazify/features/shop/presentation/pages/cart.dart';
import 'package:amazify/features/shop/presentation/pages/addreses_profile.dart';
import 'package:amazify/features/shop/presentation/pages/notifications.dart';
import 'package:amazify/features/shop/presentation/pages/order_profile.dart';
import 'package:amazify/features/shop/presentation/pages/payment_methods.dart';
import 'package:amazify/features/shop/presentation/pages/payments_profile.dart'
    hide PaymentCard;
import 'package:amazify/features/shop/presentation/pages/profile_edit.dart';
import 'package:amazify/features/shop/presentation/widgets/badge_button.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:amazify/features/shop/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/shop/presentation/widgets/circular_fabox.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notify = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,

      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // ======== HEADER (Curved Primary) - background only ========
                Stack(
                  children: [
                    ClipPath(
                      clipper: const RoundedShape(),
                      child: Container(
                        width: double.infinity,
                        height: 260,
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
                            Positioned(
                              top: -110,
                              right: -150,
                              child: circular_fadbox(cs: cs),
                            ),
                            Positioned(
                              top: 120,
                              right: -120,
                              child: circular_fadbox(cs: cs),
                            ),

                            // Intentionally no app bar / titles / search etc — top kept empty.
                            // Avatar overlapping the curve:
                          ],
                        ),
                      ),
                    ),
                    CustomAppBar(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Accounts",
                            style: text.titleLarge?.copyWith(
                              color: cs.onSurface,
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
                          iconColor: cs.onSurface.withOpacity(0.9),
                          badgeColor: cs.error.withOpacity(0.9),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        BadgeIconButton(
                          icon: Iconsax.shopping_bag,
                          count: 12,
                          iconColor: cs.onSurface.withOpacity(0.9),
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
                  ],
                ),

                // ======== CONTENT ========
                const SizedBox(height: 60),

                // Name + email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'Hamza Faizi',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'hamza@example.com',
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick stats cards
                      Row(
                        children: [
                          _StatCard(
                            icon: Iconsax.box,
                            label: 'Orders',
                            value: '12',
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Iconsax.heart,
                            label: 'Wishlist',
                            value: '8',
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Iconsax.coin,
                            label: 'Points',
                            value: '420',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => ProfileEdit(),
                                  ),
                                );
                              },
                              icon: const Icon(Iconsax.user_edit),
                              label: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Log out
                              },
                              icon: const Icon(Iconsax.logout),
                              label: const Text('Log out'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sections
                      _SectionHeader(title: 'Account'),
                      _Tile(
                        icon: Iconsax.box,
                        title: 'My Orders',
                        subtitle: 'Track, return, or buy again',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrdersPage(),
                            ),
                          );
                        },
                      ),
                      _Tile(
                        icon: Iconsax.heart,
                        title: 'Wishlist',
                        subtitle: 'Your saved items',
                        onTap: () {},
                      ),
                      _Tile(
                        icon: Iconsax.card,
                        title: 'Payments',
                        subtitle: 'Cards, wallets & refunds',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                currency: 'Rs ',
                                totalAmount: 42999,

                                onPay: (method, card) async {
                                  // TODO: call your backend/payment gateway here
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _Tile(
                        icon: Iconsax.location,
                        title: 'Addresses',
                        subtitle: 'Shipping & billing',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddresesPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _SectionHeader(title: 'Preferences'),
                      _SwitchTile(
                        icon: Iconsax.notification,
                        title: 'Notifications',
                        value: _notify,
                        onChanged: (v) => setState(() => _notify = v),
                      ),
                      _SwitchTile(
                        icon: Iconsax.moon,
                        title: 'Dark Mode',
                        value: _darkMode,
                        onChanged: (v) {
                          // You can wire this to your theme controller
                          setState(() => _darkMode = v);
                        },
                      ),
                      const SizedBox(height: 12),

                      _SectionHeader(title: 'Support'),
                      _Tile(
                        icon: Iconsax.message_question,
                        title: 'Help & Support',
                        subtitle: 'FAQs and contact us',
                        onTap: () {},
                      ),
                      _Tile(
                        icon: Iconsax.shield_tick,
                        title: 'Privacy & Security',
                        subtitle: 'Permissions & policies',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 170,
              left: 50,
              right: 50,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage(
                          'assets/icons/app_icon3.png', // replace if you have a user photo
                        ),
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // TODO: pick image
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.edit,
                            size: 16,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Widgets ─────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.2,
              color: cs.onSurface.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.onSurface.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: text.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
