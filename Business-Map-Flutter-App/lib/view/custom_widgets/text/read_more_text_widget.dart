import 'package:flutter/material.dart';

class ReadMoreTextWidget extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ReadMoreTextWidget({
    super.key,
    required this.text,
    this.trimLines = 2,
    this.style,
  });

  @override
  State<ReadMoreTextWidget> createState() => _ReadMoreTextWidgetState();
}

class _ReadMoreTextWidgetState extends State<ReadMoreTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = widget.style ?? theme.textTheme.bodyMedium;
        
        // Create a TextPainter to check if text exceeds trimLines
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isTruncated = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: textStyle,
              maxLines: isExpanded ? null : widget.trimLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isTruncated)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? 'Read less' : 'Read more',
                    style: textStyle?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
