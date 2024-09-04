import 'package:flutter/material.dart';

/// Defines grid parameters.
class GridBackgroundParams extends ChangeNotifier {
  /// [gridSquare] is the raw size of the grid square when scale is 1
  GridBackgroundParams({
    double gridSquare = 20.0,
    this.gridThickness = 0.7,
    this.secondarySquareStep = 5,
    this.backgroundColor = Colors.white,
    this.gridColor = Colors.black12,
    void Function(double scale)? onScaleUpdate,
  }) : rawGridSquareSize = gridSquare {
    if (onScaleUpdate != null) {
      _onScaleUpdateListeners.add(onScaleUpdate);
    }
  }

  ///
  factory GridBackgroundParams.fromMap(Map<String, dynamic> map) {
    final params = GridBackgroundParams(
      gridSquare: map['gridSquare'] as double? ?? 20.0,
      gridThickness: map['gridThickness'] as double? ?? 0.7,
      secondarySquareStep: map['secondarySquareStep'] as int? ?? 5,
      backgroundColor: Color(map['backgroundColor'] as int? ?? 0xFFFFFFFF),
      gridColor: Color(map['gridColor'] as int? ?? 0xFFFFFFFF),
    )
      ..scale = map['scale'] as double? ?? 1.0
      .._offset = Offset(
        map['offset.dx'] as double? ?? 0.0,
        map['offset.dy'] as double? ?? 0.0,
      );

    return params;
  }

  /// Unscaled size of the grid square
  /// i.e. the size of the square when scale is 1
  final double rawGridSquareSize;

  /// Thickness of lines.
  final double gridThickness;

  /// How many vertical or horizontal lines to draw the marked lines.
  final int secondarySquareStep;

  /// Grid background color.
  final Color backgroundColor;

  /// Grid lines color.
  final Color gridColor;

  /// offset to move the grid
  Offset _offset = Offset.zero;

  /// Scale of the grid.
  double scale = 1;

  /// Add listener for scaling
  void addOnScaleUpdateListener(void Function(double scale) listener) {
    _onScaleUpdateListeners.add(listener);
  }

  /// Remove listener for scaling
  void removeOnScaleUpdateListener(void Function(double scale) listener) {
    _onScaleUpdateListeners.remove(listener);
  }

  final List<void Function(double scale)> _onScaleUpdateListeners = [];

  ///
  set offset(Offset delta) {
    _offset += delta;
    notifyListeners();
  }

  ///
  void setScale(double factor, Offset focalPoint) {
    _offset = Offset(
      focalPoint.dx * (1 - factor),
      focalPoint.dy * (1 - factor),
    );
    scale = factor;

    for (final listener in _onScaleUpdateListeners) {
      listener(scale);
    }
    notifyListeners();
  }

  /// size of the grid square with scale applied
  double get gridSquare => rawGridSquareSize * scale;

  ///
  Offset get offset => _offset;

  ///
  Map<String, dynamic> toMap() {
    return {
      'offset.dx': _offset.dx,
      'offset.dy': _offset.dy,
      'scale': scale,
      'gridSquare': rawGridSquareSize,
      'gridThickness': gridThickness,
      'secondarySquareStep': secondarySquareStep,
      'backgroundColor': backgroundColor.value,
      'gridColor': gridColor.value,
    };
  }
}

/// Uses a CustomPainter to draw a grid with the given parameters
class GridBackground extends StatelessWidget {
  GridBackground({
    super.key,
    GridBackgroundParams? params,
  }) : params = params ?? GridBackgroundParams();
  final GridBackgroundParams params;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: params,
      builder: (context, _) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _GridBackgroundPainter(
              params: params,
              dx: params.offset.dx,
              dy: params.offset.dy,
            ),
          ),
        );
      },
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter({
    required this.params,
    required this.dx,
    required this.dy,
  });

  final GridBackgroundParams params;
  final double dx;
  final double dy;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Background
    paint.color = params.backgroundColor;
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      paint,
    );

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
