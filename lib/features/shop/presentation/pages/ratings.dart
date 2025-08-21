// lib/features/shop/presentation/pages/reviews.dart
import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          "Reviews & Ratings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Description
          Text(
            "Ratings and reviews are verified and are from people who use the same type of device that you use.",
            style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Ratings summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "4.7",
                style: text.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 70,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    5,
                    (i) => Row(
                      children: [
                        Text("${5 - i}", style: text.bodySmall),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: [0.7, 0.2, 0.12, 0.1, 0.02][i],
                            backgroundColor: cs.surfaceVariant,
                            color: cs.primary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Stars + total ratings
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: cs.primary, size: 20),
                  Icon(Icons.star, color: cs.primary, size: 20),
                  Icon(Icons.star, color: cs.primary, size: 20),
                  Icon(Icons.star_half, color: cs.primary, size: 20),
                  Icon(Icons.star_border, color: cs.primary, size: 20),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text("2,345 ratings", style: text.bodySmall),
                  const Spacer(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Comments
          _ReviewTile(
            name: "Sophia Wilson",
            date: "21-Aug-2025",
            rating: 3.5,
            comment:
                "I am genuinely impressed with the app, works very smoothly and the features are useful!",
            replyBy: "Hamza Faizi",
            replyDate: "21-Aug-2025",
            reply:
                "Thank you so much, Sophia! We are thrilled you’re enjoying the app. Stay tuned for more updates. We’ve been working on a few highly-requested features that should make your experience even better, including improved performance on older devices and more customization options. If you have any specific suggestions, feel free to share—your input helps us prioritize. Thanks again for being with us!",
          ),
          const SizedBox(height: 16),
          _ReviewTile(
            name: "John Doe",
            date: "19-Aug-2025",
            rating: 4.0,
            comment:
                "Great app overall, but I’d love to see more customization options.",
            replyBy: "Hamza Faizi",
            replyDate: "20-Aug-2025",
            reply:
                "We appreciate your feedback, John! Customization features are on our roadmap. You’ll soon be able to tweak layout density, choose accent colors, and control card sizes. Keep an eye on the next couple of updates!",
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────
// REVIEW TILE WIDGET
// ──────────────────────────────
class _ReviewTile extends StatelessWidget {
  final String name, date, comment;
  final double rating;
  final String replyBy, replyDate, reply;

  const _ReviewTile({
    required this.name,
    required this.date,
    required this.comment,
    required this.rating,
    required this.replyBy,
    required this.replyDate,
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + Name + Menu
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage("assets/icons/app_icon3.png"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.more_vert, color: cs.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 6),

        // Stars + Date
        Row(
          children: [
            ...List.generate(5, (i) {
              if (i < rating.floor()) {
                return Icon(Icons.star, size: 18, color: cs.primary);
              } else if (i < rating) {
                return Icon(Icons.star_half, size: 18, color: cs.primary);
              }
              return Icon(Icons.star_border, size: 18, color: cs.primary);
            }),
            const SizedBox(width: 8),
            Text(
              date,
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Comment
        Text(comment, style: text.bodyMedium),
        const SizedBox(height: 12),

        // Reply box (with Read more)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      replyBy,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    replyDate,
                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Reply text with expandable behavior
              _ExpandableText(
                reply,
                style: text.bodyMedium,
                trimLines: 2,
                moreLabel: " Read more",
                lessLabel: " Read less",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────
// SIMPLE EXPANDABLE TEXT
// ──────────────────────────────
class _ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int trimLines;
  final String moreLabel;
  final String lessLabel;

  const _ExpandableText(
    this.text, {
    this.style,
    this.trimLines = 2,
    this.moreLabel = " Read more",
    this.lessLabel = " Read less",
    super.key,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            maxLines: _expanded ? null : widget.trimLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? widget.lessLabel : widget.moreLabel,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
