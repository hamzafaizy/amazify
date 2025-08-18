import 'package:amazify/features/shop/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Your 4 tab pages
    final pages = [
      HomePage(), // HomePage()
      Container(child: Center(child: Text('Store Page'))), // StorePage()
      Container(child: Center(child: Text('Wishlist Page'))), // WishlistPage()
      Container(child: Center(child: Text('Profile Page'))), // ProfilePage()
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: cs.surface,
        indicatorColor: cs.primary, // selected “pill”
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            label: 'Home',
            icon: Icon(Iconsax.home, color: cs.onSurfaceVariant),
            // keep selected icon white in both modes:
            selectedIcon: const Icon(Iconsax.home, color: Colors.white),
          ),
          NavigationDestination(
            label: 'Store',
            icon: Icon(Iconsax.shop, color: cs.onSurfaceVariant),
            selectedIcon: const Icon(Iconsax.shop, color: Colors.white),
          ),
          NavigationDestination(
            label: 'Wishlist',
            icon: Icon(Iconsax.heart, color: cs.onSurfaceVariant),
            selectedIcon: const Icon(Iconsax.heart, color: Colors.white),
          ),
          NavigationDestination(
            label: 'Profile',
            icon: Icon(Iconsax.user, color: cs.onSurfaceVariant),
            selectedIcon: const Icon(Iconsax.user, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
