import 'dart:async';
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

  /// stream controller to notify changes when moving the grid
  final StreamController _updateController = StreamController.broadcast();

  /// offset to move the grid
  Offset _offset = Offset.zero;

  GridBackgroundParams({
    this.gridSquare = 20.0,
    this.gridThickness = 0.7,
    this.secondarySquareStep = 5,
    this.backgroundColor = Colors.white,
    this.gridColor = Colors.black12,
  });

  set offset(Offset delta) {
    _offset += delta;
    _updateController.add(null);
  }

  Stream get stream => _updateController.stream;

  Offset get offset => _offset;
}

/// Uses a CustomPainter to draw a grid with the given parameters
class GridBackground extends StatelessWidget {
  final GridBackgroundParams params;

  GridBackground({
    super.key,
    GridBackgroundParams? params,
  }) : params = params ?? GridBackgroundParams();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: params.stream,
        builder: (context, snapshot) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: _GridBackgroundPainter(
                params: params,
                dx: params.offset.dx,
                dy: params.offset.dy,
              ),
            ),
          );
        });
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final GridBackgroundParams params;
  final double dx;
  final double dy;

  _GridBackgroundPainter({
    required this.params,
    required this.dx,
    required this.dy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Background
    paint.color = params.backgroundColor;
    canvas.drawRect(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        paint);

    // grid
    paint.color = params.gridColor;
    paint.style = PaintingStyle.stroke;

    // Calculate the starting points for x and y
    double startX = dx % (params.gridSquare * params.secondarySquareStep);
    double startY = dy % (params.gridSquare * params.secondarySquareStep);

    // Calculate the number of lines to draw outside the visible area
    int extraLines = 2;

    // Draw vertical lines
    for (double x = startX - extraLines * params.gridSquare;
        x < size.width + extraLines * params.gridSquare;
        x += params.gridSquare) {
      paint.strokeWidth = ((x - startX) / params.gridSquare).round() %
                  params.secondarySquareStep ==
              0
          ? params.gridThickness * 2.0
          : params.gridThickness;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = startY - extraLines * params.gridSquare;
        y < size.height + extraLines * params.gridSquare;
        y += params.gridSquare) {
      paint.strokeWidth = ((y - startY) / params.gridSquare).round() %
                  params.secondarySquareStep ==
              0
          ? params.gridThickness * 2.0
          : params.gridThickness;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridBackgroundPainter oldDelegate) {
    debugPrint('shouldRepaint ${oldDelegate.dx} $dx ${oldDelegate.dy} $dy');
    return oldDelegate.dx != dx || oldDelegate.dy != dy;
  }
}
