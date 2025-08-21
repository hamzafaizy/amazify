// lib/features/shop/presentation/pages/brand.dart
import 'package:flutter/material.dart';
import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';
import 'package:amazify/features/shop/presentation/widgets/custombrandcard.dart';

class BrandPage extends StatelessWidget {
  const BrandPage({super.key});

  List<BrandInfo> get _brands => const [
    BrandInfo('Nike', 'Sportswear & sneakers'),
    BrandInfo('Acer', 'Laptops & monitors'),
    BrandInfo('Adidas', 'Sportswear & shoes'),
    BrandInfo('Jordan', 'Basketball & lifestyle'),
    BrandInfo('Puma', 'Sportswear & essentials'),
    BrandInfo('Apple', 'Phones, laptops & more'),
    BrandInfo('Zara', 'Fashion & apparel'),
    BrandInfo('Samsung', 'Phones, TVs & appliances'),
    BrandInfo('Sony', 'Electronics & gaming'),
    BrandInfo('Gucci', 'Luxury fashion'),
    BrandInfo('Dell', 'Laptops & desktops'),
    BrandInfo('Lenovo', 'PCs & accessories'),
  ];

  // PNG logos via Clearbit Logo API (good for demos; swap with assets later)
  List<BrandVisual> get _visuals => const [
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/nike.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/acer.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/adidas.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/jordan.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/puma.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/apple.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/zara.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/samsung.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/sony.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/gucci.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/dell.com',
      verified: true,
    ),
    BrandVisual(
      imagePath: 'https://logo.clearbit.com/lenovo.com',
      verified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackArrow: true, title: Text('Brand')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FeaturedBrandGrid(
          items: _brands,
          visuals: _visuals,
          // Optional navigation on tap:
          // onItemTap: (i, info) => Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => BrandProductsPage(brand: info.name)),
          // ),
        ),
      ),
    );
  }
}
