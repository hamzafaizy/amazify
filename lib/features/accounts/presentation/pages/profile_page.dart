// lib/features/accounts/presentation/pages/profile_page.dart
import 'package:amazify/core/common/entities/user.dart' hide User;
import 'package:amazify/core/widgets/custom_appbar.dart';
import 'package:amazify/features/cart/presentation/pages/cart_page.dart';
import 'package:amazify/features/cart/presentation/widgets/badge_button.dart';
import 'package:amazify/features/orders/presentation/pages/order_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// From your catalog widgets (you already have these)
import 'package:amazify/features/catalog/presentation/widgets/rounded_clipper.dart';
import 'package:amazify/features/catalog/presentation/widgets/circular_fab_box.dart';

// Local widgets (split out)
import '../widgets/profile_header.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/logged_out_info.dart';
import '../widgets/logged_in_info.dart';
import '../widgets/section_header.dart';
import '../widgets/tile_row.dart';
import '../widgets/switch_tile_row.dart';

// Other pages
import 'package:amazify/features/accounts/presentation/pages/addresses_profile_page.dart';
import 'package:amazify/features/accounts/presentation/pages/payment_methods_page.dart';
import 'package:amazify/features/accounts/presentation/pages/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notify = true;
  bool _darkMode = false;

  // TODO: wire this to your auth state provider/bloc
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();

    // Listen for login/logout changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _loggedIn = user != null; // ✅ true if logged in, false if not
      });
    });
  }

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
                // ======== Curved primary header background ========
                Stack(
                  children: [
                    ClipPath(
                      clipper: const RoundedShape(),
                      child: ProfileHeaderBackground(cs: cs),
                    ),
                    CustomAppBar(
                      title: Text(
                        "Accounts",
                        style: text.titleLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
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

                const SizedBox(height: 40),

                // ======== Content ========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _loggedIn
                          ? LoggedInInfo(
                              name: 'Hamza Faizi',
                              email: 'hamza@example.com',
                            )
                          : const LoggedOutInfo(),

                      const SizedBox(height: 2),

                      const SectionHeader(title: 'Account'),
                      TileRow(
                        icon: Iconsax.box,
                        title: 'My Orders',
                        subtitle: 'Track, return, or buy again',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrdersPage()),
                        ),
                      ),
                      TileRow(
                        icon: Iconsax.heart,
                        title: 'Wishlist',
                        subtitle: 'Your saved items',
                        onTap: () {},
                      ),
                      TileRow(
                        icon: Iconsax.card,
                        title: 'Payments',
                        subtitle: 'Cards, wallets & refunds',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              currency: 'Rs ',
                              totalAmount: 42999,
                              onPay: (method, card) async {
                                // TODO: call your backend/payment gateway
                              },
                            ),
                          ),
                        ),
                      ),
                      TileRow(
                        icon: Iconsax.location,
                        title: 'Addresses',
                        subtitle: 'Shipping & billing',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddresesPage(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const SectionHeader(title: 'Preferences'),
                      SwitchTileRow(
                        icon: Iconsax.notification,
                        title: 'Notifications',
                        value: _notify,
                        onChanged: (v) => setState(() => _notify = v),
                      ),
                      SwitchTileRow(
                        icon: Iconsax.moon,
                        title: 'Dark Mode',
                        value: _darkMode,
                        onChanged: (v) {
                          // TODO: wire to app theme controller
                          setState(() => _darkMode = v);
                        },
                      ),

                      const SizedBox(height: 12),
                      const SectionHeader(title: 'Support'),
                      TileRow(
                        icon: Iconsax.message_question,
                        title: 'Help & Support',
                        subtitle: 'FAQs and contact us',
                        onTap: () {},
                      ),
                      TileRow(
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

            // Avatar overlapping the header curve
            Positioned(
              top: 170,
              left: 50,
              right: 50,
              child: Center(
                child: ProfileAvatar(
                  loggedIn: _loggedIn,
                  onEditTap: () {
                    // TODO: pick profile image
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
