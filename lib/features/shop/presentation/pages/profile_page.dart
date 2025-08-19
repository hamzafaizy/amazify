// lib/features/account/presentation/pages/profile.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // mock user state — replace with your auth/user store
  String _name = 'Hamza Faizi';
  String _email = 'support@amazify.com';
  String _avatar = 'https://i.pravatar.cc/300?img=12';
  final bool _isVerified = true;

  // mock counters — wire to your data layer later
  final int _orders = 12;
  final int _wishlist = 7;
  final int _cart = 2;

  // preferences (local toggles for demo)
  bool _notifPush = true;
  bool _notifEmail = false;
  bool _darkMode = false; // just a demo toggle here

  void _editAvatar() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery picker TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Camera TODO')));
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash),
              title: const Text('Remove photo'),
              onTap: () {
                setState(() => _avatar = '');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() async {
    final res = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditProfileSheet(name: _name, email: _email),
    );
    if (res != null) {
      setState(() {
        _name = res.name;
        _email = res.email;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  void _confirmSignOut() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be logged out of Amazify.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (yes == true) {
      // TODO: call your auth sign-out
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signed out')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Curved header with avatar & name
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              title: const Text('Profile'),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Iconsax.notification),
                      if (_notifPush || _notifEmail)
                        const Positioned(right: -2, top: -2, child: _Dot()),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () {},
                  icon: const Icon(Iconsax.setting_2),
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // gradient curve
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer,
                            cs.surfaceContainerHighest,
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _HeaderCard(
                          name: _name,
                          email: _email,
                          avatar: _avatar,
                          isVerified: _isVerified,
                          onEditAvatar: _editAvatar,
                          onEditProfile: _editProfile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _StatsRow(
                  orders: _orders,
                  wishlist: _wishlist,
                  cart: _cart,
                ),
              ),
            ),

            // Account section
            SliverToBoxAdapter(
              child: _Section(
                title: 'Account',
                children: [
                  _Tile(
                    icon: Iconsax.bag_2,
                    title: 'My Orders',
                    subtitle: 'Track, return, reorder',
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Iconsax.heart,
                    title: 'Wishlist',
                    subtitle: '$_wishlist items saved',
                    trailing: _CountPill(count: _wishlist),
                    onTap: () {
                      // Navigator.pushNamed(context, '/wishlist');
                    },
                  ),
                  _Tile(
                    icon: Iconsax.card,
                    title: 'Payment Methods',
                    subtitle: 'UPI • Cards • Cash on Delivery',
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Iconsax.location,
                    title: 'Addresses',
                    subtitle: 'Home, Office',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Preferences
            SliverToBoxAdapter(
              child: _Section(
                title: 'Preferences',
                children: [
                  _SwitchTile(
                    icon: Iconsax.notification_bing,
                    title: 'Push notifications',
                    value: _notifPush,
                    onChanged: (v) => setState(() => _notifPush = v),
                  ),
                  _SwitchTile(
                    icon: Iconsax.sms,
                    title: 'Email updates',
                    value: _notifEmail,
                    onChanged: (v) => setState(() => _notifEmail = v),
                  ),
                  _SwitchTile(
                    icon: Iconsax.moon,
                    title: 'Dark mode',
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() => _darkMode = v);
                      // TIP: to actually switch theme, call your ThemeController here
                    },
                  ),
                  _Tile(
                    icon: Iconsax.global,
                    title: 'Language',
                    subtitle: 'English (US)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language picker TODO')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Help & Legal
            SliverToBoxAdapter(
              child: _Section(
                title: 'Help & Legal',
                children: [
                  _Tile(
                    icon: Iconsax.message_question,
                    title: 'Support',
                    subtitle: 'FAQs & contact us',
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Iconsax.shield_tick,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _Tile(
                    icon: Iconsax.document_text,
                    title: 'Terms & Conditions',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Sign out
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: OutlinedButton.icon(
                  icon: const Icon(Iconsax.logout_1),
                  label: const Text('Sign out'),
                  onPressed: _confirmSignOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── UI pieces ───────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.email,
    required this.avatar,
    required this.isVerified,
    required this.onEditAvatar,
    required this.onEditProfile,
  });

  final String name;
  final String email;
  final String avatar;
  final bool isVerified;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: (avatar.isEmpty)
                      ? null
                      : NetworkImage(avatar),
                  child: avatar.isEmpty
                      ? const Icon(Iconsax.user, size: 28)
                      : null,
                ),
                Material(
                  color: cs.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onEditAvatar,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Iconsax.edit_2,
                        size: 16,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onEditProfile,
              icon: const Icon(Iconsax.edit),
              label: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.orders,
    required this.wishlist,
    required this.cart,
  });

  final int orders;
  final int wishlist;
  final int cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.bag,
            label: 'Orders',
            value: orders.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Iconsax.heart,
            label: 'Wishlist',
            value: wishlist.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Iconsax.shopping_bag,
            label: 'Cart',
            value: cart.toString(),
          ),
        ),
      ],
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

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // slightly fixed-size icon box to control width
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            // constrain text to available width
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          ...children.map(
            (w) =>
                Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.onSurface),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: (subtitle == null)
            ? null
            : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3),
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

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────── Edit profile bottom sheet ───────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.name, required this.email});
  final String name;
  final String email;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _nameCtrl = TextEditingController(text: widget.name);
  late final _emailCtrl = TextEditingController(text: widget.email);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + viewInsets),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Edit profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('Update your name and email'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Iconsax.user),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Iconsax.sms),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(
                          context,
                          _EditResult(
                            _nameCtrl.text.trim(),
                            _emailCtrl.text.trim(),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditResult {
  final String name;
  final String email;
  _EditResult(this.name, this.email);
}
