import 'package:flutter/material.dart';

/// Defines grid parameters
class GridBackgroundParams {
  /// square size
  final double gridSquare;

  /// thickness of lines
  final double gridThickness;

  /// how many vertical or horizontal lines to draw the marked lines
  final int secondarySquareStep;

  /// grid background color
  final Color backgroundColor;
  
  /// grid lines color
  final Color gridColor;

  const GridBackgroundParams({
    this.gridSquare = 20.0,
    this.gridThickness = 0.7,
    this.secondarySquareStep = 5,
    this.backgroundColor = Colors.white,
    this.gridColor = Colors.black12,
  });
}

/// Uses a CustomPainter to draw a grid with the given parameters
class GridBackground extends StatelessWidget {
  final GridBackgroundParams params;

  const GridBackground({
    super.key,
    this.params = const GridBackgroundParams(),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _GridBackgroundPainter(
          params: params,
        ),
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final GridBackgroundParams params;

  _GridBackgroundPainter({
    required this.params,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Path p = Path();

    // Background
    paint.color = params.backgroundColor;
    canvas.drawRect(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        paint);

    // grid
    paint.color = params.gridColor;
    paint.style = PaintingStyle.stroke;

    double x = params.gridSquare;
    int n = 1;
    while (x < size.width) {
      if (n % params.secondarySquareStep == 0) {
        paint.strokeWidth = params.gridThickness * 2.0;
      } else {
        paint.strokeWidth = params.gridThickness;
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += params.gridSquare;
      n++;
    }

    double y = params.gridSquare;
    n = 1;
    while (y < size.height) {
      if (n % params.secondarySquareStep == 0) {
        paint.strokeWidth = params.gridThickness * 2.0;
      } else {
        paint.strokeWidth = params.gridThickness;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += params.gridSquare;
      n++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
