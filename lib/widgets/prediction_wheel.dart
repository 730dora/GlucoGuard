import 'package:flutter/material.dart';
import 'dart:math'; // For pi (math)
import '../theme.dart'; // Import your app's theme

class PredictionWheel extends StatefulWidget {
  final double probability; // The value from 0.0 to 1.0

  const PredictionWheel({
    super.key,
    required this.probability,
  });

  @override
  State<PredictionWheel> createState() => _PredictionWheelState();
}

class _PredictionWheelState extends State<PredictionWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: widget.probability).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 160), // The canvas size
          painter: _GaugePainter(
            probability: _animation.value, // Pass the animated value
          ),
        );
      },
    );
  }
}

/// This is the CustomPainter that draws the gauge and needle
class _GaugePainter extends CustomPainter {
  final double probability; // The animated value (0.0 to 1.0)

  _GaugePainter({required this.probability});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the gauge's properties
    final double centerX = size.width / 2;
    final double centerY = size.height; // Pivot point at the bottom center
    final double radius = size.width / 2;
    final double strokeWidth = 22.0;

    final centerOffset = Offset(centerX, centerY);
    final rect = Rect.fromCircle(center: centerOffset, radius: radius);
    const startAngle = pi; // 180 degrees (left side)
    const sweepAngle = pi; // 180 degrees sweep to the right

    // 1. Draw the background arc (the "empty" track)
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]! // Made slightly darker to be more visible
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // 2. Draw the foreground (progress) arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          AppTheme.mint,    // Low risk color
          AppTheme.violet,  // Medium risk color
          Colors.redAccent, // High risk color
        ],
        stops: [0.0, 0.5, 1.0], // Color stops
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends

    canvas.drawArc(rect, startAngle, probability * sweepAngle, false, progressPaint);

    // 3. Draw the Needle (Pointer)
    final double needleAngle = startAngle + (probability * sweepAngle);
    final double pivotRadius = 12;
    // The needle is a long triangle
    final double needleLength = radius - (strokeWidth / 2) + 5;

    final needleTip = Offset(
      centerX + cos(needleAngle) * needleLength,
      centerY + sin(needleAngle) * needleLength,
    );
    final needleBaseLeft = Offset(
      centerX + cos(needleAngle - 0.05) * pivotRadius, // 0.05 rad = ~3 deg
      centerY + sin(needleAngle - 0.05) * pivotRadius,
    );
    final needleBaseRight = Offset(
      centerX + cos(needleAngle + 0.05) * pivotRadius,
      centerY + sin(needleAngle + 0.05) * pivotRadius,
    );

    final needlePath = Path()
      ..moveTo(needleTip.dx, needleTip.dy)
      ..lineTo(needleBaseLeft.dx, needleBaseLeft.dy)
      ..lineTo(needleBaseRight.dx, needleBaseRight.dy)
      ..close();

    // Draw the shadow for the needle
    final needleShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.save();
    canvas.translate(2, 2); // Offset the shadow down and right
    canvas.drawPath(needlePath, needleShadowPaint);
    canvas.restore();

    // Draw the main needle
    final needlePaint = Paint()
      ..color = const Color(0xFF333333) // A strong, dark grey
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePath, needlePaint);

    // 4. Draw the pivot circle (more stylish)
    final pivotShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(centerOffset, pivotRadius + 2, pivotShadowPaint); // Shadow

    final pivotPaint = Paint()..color = const Color(0xFF4A4A4A); // Dark grey pivot
    canvas.drawCircle(centerOffset, pivotRadius, pivotPaint);

    final pivotInnerPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(centerOffset, pivotRadius * 0.7, pivotInnerPaint);

    final pivotCenterPaint = Paint()..color = const Color(0xFF4A4A4A);
    canvas.drawCircle(centerOffset, pivotRadius * 0.3, pivotCenterPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.probability != probability;
  }
}