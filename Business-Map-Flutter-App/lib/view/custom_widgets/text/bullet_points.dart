
import 'package:business_map/utils/app_text_style.dart';
import 'package:flutter/material.dart';

class BulletPoints extends StatefulWidget {
  final List<String> points;
  final int initialCount;

  const BulletPoints({
    super.key,
    required this.points,
    this.initialCount = 3,
  });

  @override
  State<BulletPoints> createState() => _BulletPointsState();
}

class _BulletPointsState extends State<BulletPoints> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleCount = isExpanded
        ? widget.points.length
        : widget.initialCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.points
            .take(visibleCount)
            .map(
              (point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• "),
                Expanded(
                  child: Text(
                    point,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
        if (widget.points.length > widget.initialCount)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? "Read less" : "Read more",
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

