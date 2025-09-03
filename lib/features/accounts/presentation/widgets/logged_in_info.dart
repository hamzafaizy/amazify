// lib/features/accounts/presentation/widgets/logged_in_info.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amazify/features/accounts/presentation/pages/profile_edit_page.dart';
import 'stat_card.dart';

class LoggedInInfo extends StatelessWidget {
  const LoggedInInfo({super.key, required this.name, required this.email});

  final String name;
  final String email;

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          name,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        Row(
          children: const [
            Expanded(
              child: StatCard(icon: Iconsax.box, label: 'Orders', value: '12'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Iconsax.heart,
                label: 'Wishlist',
                value: '8',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Iconsax.coin,
                label: 'Points',
                value: '420',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(CupertinoPageRoute(builder: (_) => ProfileEdit()));
                },
                icon: const Icon(Iconsax.user_edit),
                label: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: Icon(Iconsax.logout, color: cs.surface),
                label: Text('Log out', style: TextStyle(color: cs.surface)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
