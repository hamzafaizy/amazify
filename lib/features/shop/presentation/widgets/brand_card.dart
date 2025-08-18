import 'package:flutter/material.dart';

/// A clickable rounded banner image with optional border & padding.
/// Works with asset or network images.
///
/// Example:
/// RoundedBannerImage(
///   imageUrl: 'assets/Images/ban4.png',
///   width: double.infinity,
///   height: 140,
///   borderRadius: 16,
///   border: Border.all(color: Colors.black12),
///   padding: const EdgeInsets.symmetric(horizontal: 16),
///   fit: BoxFit.cover,
///   backgroundColor: Colors.transparent,
///   isNetworkImage: false,
///   onPressed: () {},
/// )
class RoundedBannerImage extends StatelessWidget {
  const RoundedBannerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isNetworkImage = false,
    this.borderRadius = 16,
    this.applyImageRadius = true,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(10),
    this.border,
    this.onPressed,
  });

  /// Required image path/URL
  final String imageUrl;

  /// Size
  final double? width;
  final double? height;

  /// Image behavior
  final BoxFit fit;
  final bool isNetworkImage;

  /// Look & feel
  final double borderRadius;
  final bool applyImageRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;

  /// Tap action
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final Widget image = isNetworkImage
        ? Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            // Optional: helpful for slow networks
            loadingBuilder: (c, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
            errorBuilder: (c, err, st) =>
                const Center(child: Icon(Icons.broken_image)),
          )
        : Image.asset(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (c, err, st) =>
                const Center(child: Icon(Icons.broken_image)),
          );

    final Widget content = applyImageRadius
        ? ClipRRect(borderRadius: radius, child: image)
        : image;

    return Padding(
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: radius,
              border: border,
            ),
            child: SizedBox(width: width, height: height, child: content),
          ),
        ),
      ),
    );
  }
}
