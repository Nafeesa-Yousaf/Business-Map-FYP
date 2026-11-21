import 'package:flutter/material.dart';
import 'dart:math' as math;

class WindingRoadmapWidget extends StatelessWidget {
  final List<String> steps;
  final Color primaryColor;

  const WindingRoadmapWidget({
    super.key,
    required this.steps,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double centerX = width / 2;
        final double amplitude = width * 0.25; 
        final double wavelength = 320.0;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ContinuousRoadPainter(amplitude: amplitude, wavelength: wavelength),
              ),
            ),

            Column(
              children: steps.asMap().entries.map((entry) {
                int idx = entry.key;
                String text = entry.value;
                
                double stepHeight = 150.0;
                double yCenter = idx * stepHeight + (stepHeight / 2);
                
                double xOnRoad = centerX + amplitude * math.sin((yCenter / wavelength) * 2 * math.pi);
                bool isRoadOnRight = xOnRoad > centerX;

                return Container(
                  height: stepHeight,
                  width: width,
                  child: Stack(
                    children: [
                      Positioned(
                        left: xOnRoad - 20, 
                        top: (stepHeight / 2) - 20,
                        child: _buildPin(idx),
                      ),

                      Positioned(
                        left: isRoadOnRight ? 15 : xOnRoad + 35,
                        right: isRoadOnRight ? (width - xOnRoad) + 35 : 15,
                        top: (stepHeight / 2) - 40,
                        child: Container(
                          child: Text(
                            text,
                            textAlign: isRoadOnRight ? TextAlign.right : TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPin(int idx) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          "${idx + 1}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class ContinuousRoadPainter extends CustomPainter {
  final double amplitude;
  final double wavelength;

  ContinuousRoadPainter({required this.amplitude, required this.wavelength});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..strokeCap = StrokeCap.butt;

    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    double centerX = size.width / 2;
    
    path.moveTo(centerX, 0);
    
    for (double y = 0; y <= size.height; y += 5) {
      double x = centerX + amplitude * math.sin((y / wavelength) * 2 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    var dashPath = Path();
    var dashWidth = 10.0;
    var dashSpace = 10.0;
    var distance = 0.0;
    
    for (var metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant ContinuousRoadPainter oldDelegate) => 
    oldDelegate.amplitude != amplitude || oldDelegate.wavelength != wavelength;
}
